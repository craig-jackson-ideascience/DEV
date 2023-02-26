public class ConvertLeadToContactBatch implements Database.Batchable<SObject>, Schedulable{
	String query;
	List<Lead> existingLeadList = new List<Lead>();
	List<Contact> existingContactList = new List<Contact>();
	Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Contact.fields.getMap();
	String ContactFieldNames;
    List<String> checkBoxFieldsString;
	Utility mergeUtility = new Utility();
	Set<Id> existingContactIdSet = new Set<Id>();
	//Schedule 's Execute method to call batch
	public void execute(SchedulableContext sc){
		Database.executeBatch(new ConvertLeadToContactBatch(), 10);
	}

	//Constructor
	public ConvertLeadToContactBatch(){
		Map<String, Object> returnedMap = mergeUtility.getFieldNames(schemaFieldMap);
		this.ContactFieldNames = (String)returnedMap.get('FieldNames');
		this.checkBoxFieldsString = (List<String>)returnedMap.get('CheckboxFields');
		this.query = this.ContactFieldNames + ',Owner.isActive' + 
											',(SELECT Id,Alternate_Email_Address__c FROM Alternate_Emails__r) FROM Contact WHERE CreatedDate=today';
	}

	//Constructor
	public ConvertLeadToContactBatch(String query){
		Map<String, Object> returnedMap = mergeUtility.getFieldNames(schemaFieldMap);
		this.ContactFieldNames = (String)returnedMap.get('FieldNames');
		this.checkBoxFieldsString = (List<String>)returnedMap.get('CheckboxFields');
		this.query = query;
	}

	//Start of the batch
	public Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('query ' + query);
		return Database.getQueryLocator(query);
	}

	//Execute of Batch
	public void execute(Database.BatchableContext BC, List<Contact> scope){
		System.debug('in');
		//Call method to merge duplicate contacts and convert lead to contact
		mergeContactsAndLeadsBasedOnEmail(scope);
	}

	//Finish of batch
	public void finish(Database.BatchableContext info){
	}

	//Method to merge duplicate contacts and convert lead to contact
	public void mergeContactsAndLeadsBasedOnEmail(List<Contact> scope){
		Map<String, List<Contact>> emailVsContact = new Map<String, List<Contact>>();

		//Iterate through each record
		for (Contact contact : scope){

			//Insert record to a map if alternateEmail does not exist
			Boolean hasAlternateEmail = false;
			for (Alternate_Email__c alternateEmail : contact.Alternate_Emails__r){
				if (alternateEmail.Alternate_Email_Address__c == contact.Email){
					hasAlternateEmail = true;
					break;
				}
			}
			if (!hasAlternateEmail){
				emailVsContact.put(contact.Email, new List<Contact>{contact});
			}
		}
		System.debug('emailVsContact ' + emailVsContact);
		if (!emailVsContact.isEmpty()){

			//Get Alternate Email
			getAlternateEmail(emailVsContact);

			//If duplicates Contact found then merge the contacts
			if (!existingContactIdSet.isEmpty()){
				//Call method to Merge contacts
				mergeContact(emailVsContact);
			}

			//If lead found with same email then convert it to contact
			if (!existingLeadList.isEmpty()){
				//Call method to convert lead to contact
				convertLeadToContact(emailVsContact);
			}
		}
	}

	//method to Merge contacts
	public void mergeContact(Map<String, List<Contact>> emailVsContact){
		String dupeQuery = this.ContactFieldNames + ' FROM Contact' + 
												  ' WHERE Id IN: existingContactIdSet';
		Map<Id, Contact> duplicateContactMap = new Map<Id, Contact>((List<Contact>)Database.query(dupeQuery));
		Set<String> externalIdString = Utility.contactExternalIdSet;
		Boolean doMerge = true;
		System.debug('externalIdString ' + externalIdString);

		List<String> fieldNamesList = this.ContactFieldNames.split(',');
		System.debug('bef fieldNamesList ' + fieldNamesList);
		fieldNamesList.remove(0);
		System.debug('af fieldNamesList ' + fieldNamesList);
		for (String email : emailVsContact.keyset()){
			System.debug(emailVsContact.get(email).size());
			if (emailVsContact.get(email).size() > 1){
				Contact masterContact = emailVsContact.get(email).get(0);
				Contact masterContactToMerge = new Contact(id = masterContact.Id);
				Contact duplicateContact = duplicateContactMap.get(emailVsContact.get(email).get(1).Id);

				for (String fieldName : fieldNamesList){
					if (externalIdString.contains(fieldName) && masterContact.get(fieldName) != null && duplicateContact.get(fieldName) != null && masterContact.get(fieldName) != duplicateContact.get(fieldName)){
						System.debug('IN NO Merge');
						doMerge = false;
						break;
					}
					if (masterContact.get(fieldName) == null && duplicateContact.get(fieldName) != null){
						masterContactToMerge.put(fieldName, duplicateContact.get(fieldName));
					}
					//if field is checkbox field and the checkbox is checked on duplicateContact then move it to masterContact
					if (checkBoxFieldsString.contains(fieldName) && masterContact.get(fieldName) == false && duplicateContact.get(fieldName) == true){
						masterContactToMerge.put(fieldName, duplicateContact.get(fieldName));
					}
				}
				System.debug('masterContact ' + masterContactToMerge);
				System.debug('duplicateContact ' + duplicateContact);
				if (doMerge){
					System.debug('Merge');
					Database.MergeResult mergeResult = Database.merge(masterContactToMerge, duplicateContact);
					System.debug('mergeResult ' + mergeResult);
				}
				doMerge = true;
			}
		}
	}

	//method to convert lead to contact
	public void convertLeadToContact(Map<String, List<Contact>> emailVsContact){
		list<Database.LeadConvert> leadsToBeConverted = new list<Database.LeadConvert>();
		User salesOpUser = [SELECT Id
		                    FROM User
		                    WHERE Name = :Label.User_to_assign_to_lead];
		for (Lead lead : existingLeadList){
			Contact conversionContact = emailVsContact.get(lead.Email).get(0);
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(lead.Id);
			lc.setAccountId(conversionContact.AccountId);
			lc.setContactId(conversionContact.Id);
			Id ownerId = conversionContact.Owner.IsActive ? conversionContact.OwnerId : salesOpUser.Id;
			lc.setOwnerId(ownerId);
			lc.setConvertedStatus(LABEL.Lead_Converted_Status);
			lc.setDoNotCreateOpportunity(true);
			leadsToBeConverted.add(lc);
		}
		System.debug('leadsToBeConverted ' + leadsToBeConverted);
		if (!leadsToBeConverted.isEmpty()){
			List<Database.LeadConvertResult> lcr = Database.convertLead(leadsToBeConverted);
			System.debug('lcr ' + lcr.size()+' ' + lcr);
		}
	}

	//Method to get Alternate email
	public void getAlternateEmail(Map<String, List<Contact>> emailVsContact){
		List<Alternate_Email__c> alternateEmailList = [SELECT Id, Alternate_Email_Address__c, Contact_Name__c, Lead_Name__c
		                                               FROM Alternate_Email__c
		                                               WHERE Alternate_Email_Address__c IN :emailVsContact.keySet() AND (Contact_Name__c != null OR (Lead_Name__c != null AND Lead_Name__r.IsConverted = false))];

		for (Alternate_Email__c alternateEmail : alternateEmailList){

			if (alternateEmail.Contact_Name__c != null){
				existingContactIdSet.add(alternateEmail.Contact_Name__c);
				emailVsContact.get(alternateEmail.Alternate_Email_Address__c).add(new Contact(Id = alternateEmail.Contact_Name__c));

			} else if (alternateEmail.Lead_Name__c != null){
				existingLeadList.add(new Lead(Id = alternateEmail.Lead_Name__c, Email = alternateEmail.Alternate_Email_Address__c));
			}
		}
	}
}