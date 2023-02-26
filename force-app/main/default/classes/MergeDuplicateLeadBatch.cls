public class MergeDuplicateLeadBatch implements Database.Batchable<SObject>, Schedulable{
	String query;
	//List<Lead> existingLeadList = new List<Lead>();
	List<Contact> existingContactList = new List<Contact>();
	Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Lead.fields.getMap();
	public String leadFieldNames;
    List<String> checkBoxFieldsString;
	Set<Id> existingLeadIdSet = new Set<Id>();
	Utility mergeUtility = new Utility();
	//Schedule 's Execute method to call batch
	public void execute(SchedulableContext sc){
		Database.executeBatch(new MergeDuplicateLeadBatch(), 10);
	}

	//Constructor
	public MergeDuplicateLeadBatch(){
		Map<String, Object> returnedMap = mergeUtility.getFieldNames(schemaFieldMap);
		this.leadFieldNames = (String)returnedMap.get('FieldNames');
		this.checkBoxFieldsString = (List<String>)returnedMap.get('CheckboxFields');
		this.query = this.leadFieldNames + 
			',(SELECT Id,Alternate_Email_Address__c FROM Alternate_Emails__r) FROM Lead' + 
			' WHERE CreatedDate=today AND IsConverted=false';
	}

	//Constructor
	public MergeDuplicateLeadBatch(String query){
		Map<String, Object> returnedMap = mergeUtility.getFieldNames(schemaFieldMap);
		this.leadFieldNames = (String)returnedMap.get('FieldNames');
		this.checkBoxFieldsString = (List<String>)returnedMap.get('CheckboxFields');
		this.query = query;
	}

	//Start of the batch
	public Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('query ' + query);
		system.debug('leadFieldNames' + this.leadFieldNames);
		return Database.getQueryLocator(query);
	}

	//Execute of Batch
	public void execute(Database.BatchableContext BC, List<Lead> scope){
		System.debug('in');
		//Call method to merge duplicate lead and if contact exist with same email then convert it to contact
		mergeDuplicateLeads(scope);
	}

	//Finish of batch
	public void finish(Database.BatchableContext info){
	}

	//Method to merge duplicate lead and if contact exist with same email then convert it to contact
	public void mergeDuplicateLeads(List<Lead> scope){
		System.debug('scope ' + scope.size()+' ' + scope);
		Map<String, List<Lead>> emailVsLead = new Map<String, List<Lead>>();

		for (Lead lead : scope){
			if (lead.Email != null){
				Boolean hasAlternateEmail = false;
				for (Alternate_Email__c alternateEmail : lead.Alternate_Emails__r){
					if (alternateEmail.Alternate_Email_Address__c == lead.Email){
						hasAlternateEmail = true;
						break;
					}
				}
				if (!hasAlternateEmail){
					emailVsLead.put(lead.Email, new List<Lead>{lead});
				}
			}
		}
		System.debug('emailVsLead ' + emailVsLead.size()+' ' + emailVsLead);

		if (!emailVsLead.isEmpty()){
			getAlternateEmail(emailVsLead);
			System.debug('existingContactList ' + existingContactList.size()+' ' + existingContactList);
			System.debug('existingLeadIdSet ' + existingLeadIdSet.size()+' ' + existingLeadIdSet);
			if (!existingContactList.isEmpty()){
				convertLeadToContact(emailVsLead);
			}
			if (!existingLeadIdSet.isEmpty()){
				mergeLeads(emailVsLead);
			}
		}
	}

	//Method to get Alternate email
	public void getAlternateEmail(Map<String, List<Lead>> emailVsLead){
		List<Alternate_Email__c> alternateEmailList = [SELECT Id, Alternate_Email_Address__c, Contact_Name__c, Lead_Name__c, Contact_Name__r.AccountId, Contact_Name__r.OwnerId, Contact_Name__r.Owner.IsActive
		                                               FROM Alternate_Email__c
		                                               WHERE Alternate_Email_Address__c IN :emailVsLead.keyset()];
		User salesOpUser = [SELECT Id
		                    FROM User
		                    WHERE Name = :Label.User_to_assign_to_lead];
		for (Alternate_Email__c alternateEmail : alternateEmailList){
			if (alternateEmail.Contact_Name__c != null){
				Contact existingContact = new Contact(Id = alternateEmail.Contact_Name__c, Email = alternateEmail.Alternate_Email_Address__c, AccountId = alternateEmail.Contact_Name__r.AccountId);
				existingContact.OwnerId = alternateEmail.Contact_Name__r.Owner.IsActive ? alternateEmail.Contact_Name__r.OwnerId : salesOpUser.Id;

				existingContactList.add(existingContact);

			} else if (alternateEmail.Lead_Name__c != null){
				existingLeadIdSet.add(alternateEmail.Lead_Name__c);
				emailVsLead.get(alternateEmail.Alternate_Email_Address__c).add(new Lead(Id = alternateEmail.Lead_Name__c));
			}
		}
	}

	//Method to merge duplicate leads
	public void mergeLeads(Map<String, List<Lead>> emailVsLead){

		String dupeQuery = this.leadFieldNames + ' FROM Lead' + 
												' WHERE Id IN: existingLeadIdSet';
		Map<Id, Lead> duplicateLeadMap = new Map<Id, Lead>((List<Lead>)Database.query(dupeQuery));
		List<String> fieldNamesList = this.leadFieldNames.split(',');
		System.debug('bef fieldNamesList ' + fieldNamesList);
		fieldNamesList.remove(0);
		System.debug('af fieldNamesList ' + fieldNamesList);

		for (String email : emailVsLead.keyset()){
			System.debug(emailVsLead.get(email).size());
			if (emailVsLead.get(email).size() > 1){
				Lead masterLead = emailVsLead.get(email).get(0);
                Lead masterLeadToMerge = new Lead(Id = masterLead.Id);
				Lead duplicateLead = duplicateLeadMap.get(emailVsLead.get(email).get(1).Id);

				for (String fieldName : fieldNamesList){
					if (masterLead.get(fieldName) == null && duplicateLead.get(fieldName) != null){
						masterLeadToMerge.put(fieldName, duplicateLead.get(fieldName));
					}
					//if field is checkbox field and the checkbox is checked on duplicateLead then move it to masterLead
					if (checkBoxFieldsString.contains(fieldName) && masterLead.get(fieldName) == false && duplicateLead.get(fieldName) == true){
						masterLeadToMerge.put(fieldName, duplicateLead.get(fieldName));
					}
				}

				Database.MergeResult mergeResult = Database.merge(masterLeadToMerge, duplicateLead);
				System.debug('mergeResult ' + mergeResult);
			}
		}
	}

	//Method to convert lead to contact
	public void convertLeadToContact(Map<String, List<Lead>> emailVsLead){
		list<Database.LeadConvert> leadsToBeConverted = new list<Database.LeadConvert>();
		for (Contact contact : existingContactList){
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(emailVsLead.get(contact.Email).get(0).Id);
			lc.setAccountId(contact.AccountId);
			lc.setContactId(contact.Id);
			lc.setOwnerId(contact.OwnerId);
			lc.setConvertedStatus(LABEL.Lead_Converted_Status);
			lc.setDoNotCreateOpportunity(true);
			leadsToBeConverted.add(lc);
		}
		System.debug('leadsToBeConverted ' + leadsToBeConverted.size()+' ' + leadsToBeConverted);
		if (!leadsToBeConverted.isEmpty()){
			List<Database.LeadConvertResult> lcr = Database.convertLead(leadsToBeConverted);
			System.debug('lcr ' + lcr.size()+' ' + lcr);
		}
	}
}