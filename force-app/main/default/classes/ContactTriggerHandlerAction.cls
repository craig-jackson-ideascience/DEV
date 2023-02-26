public class ContactTriggerHandlerAction{
	public void insertAleternateEmail(List<Contact> contactList, set<String> emailIDString){
		List<Alternate_Email__c> alternateEmailList = new List<Alternate_Email__c>();
		Map<id, id> mapofEmailAddrerss = new Map<id, id>();
		list<Alternate_Email__c> alternativeEmailQueryList = [Select id, contact_Name__c, Primary_Email__c, Alternate_Email_Address__c, Active__c
		                                                      from Alternate_Email__c
		                                                      where Alternate_Email_Address__c in :emailIDString and contact_name__c in :contactList];
		system.debug('1#--#' + alternativeEmailQueryList);
		Map<String, Alternate_Email__c> emailVsAlternateEmail = new Map<String, Alternate_Email__c>();
		if (!alternativeEmailQueryList.isEmpty()){
			emailVsAlternateEmail = getAlternateEmailMap(alternativeEmailQueryList);
		}
		for (Contact contact : contactList){
			if (contact.email != null){
				Alternate_Email__c alternateEmail = new Alternate_Email__c();
				alternateEmail.Active__c = true;
				alternateEmail.Alternate_Email_Address__c = contact.email;
				alternateEmail.contact_Name__c = contact.id;
				alternateEmail.Primary_Email__c = TRUE;
				if (userinfo.getName() != null && userinfo.getName() == 'TI User'){
					alternateEmail.Primary_System__c = 'TI';
				}
				System.debug('alternateEmail' + alternateEmail);
				if (emailVsAlternateEmail.containsKey(contact.email)){
					alternateEmail.id = emailVsAlternateEmail.get(contact.email).Id;
					System.debug('alternateEmail' + alternateEmail.id);
				}
				alternateEmailList.add(alternateEmail);
			}
		}
		if (alternateEmailList.size() > 0){
			upsert alternateEmailList;
		}
	}

	public Map<String, Alternate_Email__c> getAlternateEmailMap(List<Alternate_Email__c> alternateEmailList){
		Map<String, Alternate_Email__c> emailVsAlternateEmail = new Map<String, Alternate_Email__c>();
		for (Alternate_Email__c alternateEmail : alternateEmailList){
			emailVsAlternateEmail.put(alternateEmail.Alternate_Email_Address__c, alternateEmail);
		}
		return emailVsAlternateEmail;
	}

	public void addvalidationError(Set<String> emailIdString, List<Contact> contactList){
		list<Alternate_Email__c> alternativeEmailQueryList = [Select Id, Name, Alternate_Email_Address__c, Contact_name__c, Lead_Name__c
		                                                      from Alternate_Email__c
		                                                      where Alternate_Email_Address__c in :emailIdString];
		System.debug('#-alternativeEmailQueryList-#' + alternativeEmailQueryList);
		Map<String, Alternate_Email__c> emailVsAlternateEmail = new Map<String, Alternate_Email__c>();
		if (!alternativeEmailQueryList.isEmpty()){
			emailVsAlternateEmail = getAlternateEmailMap(alternativeEmailQueryList);
		}
		for (Contact cont : contactList){
			if (cont.email != null){

				if (emailVsAlternateEmail.containsKey(cont.email) && (cont.id != emailVsAlternateEmail.get(cont.email).Contact_name__c || emailVsAlternateEmail.get(cont.email).Lead_Name__c != null)){
					cont.addError('Alternate Email Address Already Exists:-' + emailVsAlternateEmail.get(cont.email).Name);

				}
			}
		}
	}

	public void contactWithAdditionalEmail(List<Contact> listofContactwithAdditionalEmail, set<String> additionalEmailString){
		List<Alternate_Email__c> alternateEmailList = new List<Alternate_Email__c>();
		list<Alternate_Email__c> alternativeEmailQueryList = [Select id, contact_Name__c, Primary_Email__c, Alternate_Email_Address__c, Active__c
		                                                      from Alternate_Email__c
		                                                      where Alternate_Email_Address__c in :additionalEmailString and contact_name__c in :listofContactwithAdditionalEmail];
		system.debug('#2--#' + alternativeEmailQueryList);
		Map<String, Alternate_Email__c> emailVsAlternateEmail = new Map<String, Alternate_Email__c>();
		if (!alternativeEmailQueryList.isEmpty()){
			emailVsAlternateEmail = getAlternateEmailMap(alternativeEmailQueryList);
		}
		for (Contact contact : listofContactwithAdditionalEmail){
			if (contact.Additional_Email__c != null){
				Alternate_Email__c alternateEmail = new Alternate_Email__c();
				alternateEmail.Active__c = true;
				alternateEmail.Alternate_Email_Address__c = contact.Additional_Email__c;
				alternateEmail.contact_Name__c = contact.id;
				if (emailVsAlternateEmail.containsKey(contact.Additional_Email__c)){
					alternateEmail.id = emailVsAlternateEmail.get(contact.Additional_Email__c).Id;
				}
				alternateEmailList.add(alternateEmail);
			}

		}
		if (alternateEmailList.size() > 0){
			upsert alternateEmailList;
		}
	}

	public void deleteAlternateEmail(List<contact> contactList, Set<Id> alternateEmails){
		Set<Id> winningContactIdList = new Set<Id>();
		for (Contact contact : contactList){
			if (contact.MasterRecordId != null)
				winningContactIdList.add(contact.MasterRecordId);
		}
		String query = 'SELECT ID FROM Alternate_Email__c WHERE Id IN:alternateEmails';
		if (!winningContactIdList.IsEmpty()){
			query += ' AND Contact_Name__c NOT IN:winningContactIdList';
		}
		List<Alternate_Email__c> deleteList = Database.query(query);
		if (deleteList.size() > 0)
			delete deleteList;
	}

	public void getMasterRecordIdsToBeProcessed(Map<Id, Contact> oldMap){
		Set<Id> winningContactIdSet = new Set<Id>();
		for (Contact contact : oldMap.values()){
			if (contact.MasterRecordId != null)
				winningContactIdSet.add(contact.MasterRecordId);
		}
		if (winningContactIdSet.size() > 0){
			processAlternateEmail(winningContactIdSet);
		}
	}

	public void processAlternateEmail(Set<Id> winningContactIdSet){
		List<Alternate_Email__c> alternateEmails = [SELECT Id, Contact_Name__c, Contact_Name__r.Email, Primary_Email__c, Alternate_Email_Address__c
		                                            FROM Alternate_Email__c
		                                            WHERE Contact_Name__c IN :winningContactIdSet];
		for (Alternate_Email__c alternateEmail : alternateEmails){
			if (alternateEmail.Alternate_Email_Address__c == alternateEmail.Contact_Name__r.Email){
				alternateEmail.Primary_Email__c = true;
				alternateEmail.During_Merge_change__c = true;
			} else{
				alternateEmail.Primary_Email__c = false;
			}

		}
		if (!alternateEmails.isEmpty()){
			update alternateEmails;
		}
	}

	//method to merge contact based on cventemail field
	public void checkCventEmail(Map<Id, Contact> newContactMap, Map<Id, Contact> oldContactMap){
		Map<String, List<Contact>> cventMailByContacts = new Map<String, List<Contact>>();
		Map<String, Alternate_Email__c> emailVsAlternateEmail = new Map<String, Alternate_Email__c>();
		for (Contact con : newContactMap.values()){
			//if cvent registration email is populated
			if (con.Cvent_Registration_Email__c != null && con.Cvent_Registration_Email__c != con.Email && (oldContactMap == null || (oldContactMap != null && con.Cvent_Registration_Email__c != oldContactMap.get(con.Id).Cvent_Registration_Email__c))){
				//add to map
				cventMailByContacts.put(con.Cvent_Registration_Email__c, new List<Contact>{con});
			}
		}
		if (!cventMailByContacts.isEmpty()){
			//call method to getexistingContactIdSet
			Set<Id> existingContactIdSet = getAlternateEmailMap(cventMailByContacts, emailVsAlternateEmail);
			System.debug('existingContactIdSet ' + existingContactIdSet);
			System.debug('cventMailByContacts ' + cventMailByContacts);

			//Serialize map as in future we cant pass it
			String emailVsContactListString = json.serialize(cventMailByContacts);
			String emailVsAlternateEmailString = json.serialize(emailVsAlternateEmail);

			//call method to merge
			mergeContact(emailVsContactListString, existingContactIdSet, emailVsAlternateEmailString);
		}
	}

	//method to Merge contacts
	@future
	public static void mergeContact(String emailVsContactListString, Set<Id> existingContactIdSet, String emailVsAlternateEmailString){
		//deserialize the map
		Map<String, List<Contact>> emailVsContact = (Map<String, List<Contact>>)Json.deserialize(emailVsContactListString, Map<String, List<Contact>>.class);
		Map<String, Alternate_Email__c> emailVsAlternateEmail = (Map<String, Alternate_Email__c>)Json.deserialize(emailVsAlternateEmailString, Map<String, Alternate_Email__c>.class);

		list<Alternate_Email__c> alternativeEmailList = new list<Alternate_Email__c>();
		Boolean doMerge = true;
		List<String> fieldNamesList = new List<String>();
		//set of fields to consider if present on both records then no need to merge
		Set<String> externalIdString = Utility.contactexternalIdSet;
		Map<Id, Contact> masterContactMap = new Map<Id, Contact>();
		List<String> checkBoxFieldsString = new List<String>();
		//set is not empty
		if (!existingContactIdSet.isEmpty()){
			Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Contact.fields.getMap();
			Utility mergeUtility = new Utility();
			//Retrieve all fields of existing contact
			Map<String, Object> returnedMap = mergeUtility.getFieldNames(schemaFieldMap);
			String contactFieldNames = (String)returnedMap.get('FieldNames');
			checkBoxFieldsString = (List<String>)returnedMap.get('CheckboxFields');
			String dupeQuery = ContactFieldNames + ' FROM Contact' + 
													' WHERE Id IN: existingContactIdSet';
			masterContactMap = new Map<Id, Contact>((List<Contact>)Database.query(dupeQuery));
			System.debug('externalIdString ' + externalIdString);
			fieldNamesList = ContactFieldNames.split(',');
			System.debug('bef fieldNamesList ' + fieldNamesList);
			fieldNamesList.remove(0);
			System.debug('af fieldNamesList ' + fieldNamesList);
		}

		//Iterate through map
		for (String email : emailVsContact.keyset()){
			System.debug(emailVsContact.get(email).size());
			//If duplicate exists
			if (emailVsContact.get(email).size() > 1){
				//Existing Contact is master because it contains cvent mail as primary email
				Contact masterContact = masterContactMap.get(emailVsContact.get(email).get(1).Id);
				//Duplicate contact is trigger's contact
				Contact duplicateContact = emailVsContact.get(email).get(0);
				//Instance that can be merge
				Contact duplicateContactToMerge = new Contact(id = duplicateContact.Id);
				System.debug('masterContact ' + masterContact);
				System.debug('duplicateContact ' + duplicateContact);
				//Iterate through each fields
				for (String fieldName : fieldNamesList){
					//If both record contains value on specified set of external id then dont merge and throw error
					if (externalIdString.contains(fieldName) && masterContact.get(fieldName) != null && duplicateContact.get(fieldName) != null && masterContact.get(fieldName) != duplicateContact.get(fieldName)){
						System.debug('IN NO Merge');
						doMerge = false;
						duplicateContact.addError('Duplicate Contact Exist with different username');
						break;
					}
					//populate fields from duplicate to master if master's field is null
					if (masterContact.get(fieldName) == null && duplicateContact.get(fieldName) != null){
						masterContact.put(fieldName, duplicateContact.get(fieldName));
					}
					//if field is checkbox field and the checkbox is checked on duplicateContact then move it to masterContact
					if (checkBoxFieldsString.contains(fieldName) && masterContact.get(fieldName) == false && duplicateContact.get(fieldName) == true){
						masterContact.put(fieldName, duplicateContact.get(fieldName));
					}
				}
				System.debug('masterContact ' + masterContact);
				System.debug('duplicateContact ' + duplicateContact);

				//merge
				if (doMerge){
					System.debug('Merge');
					Database.MergeResult mergeResult = Database.merge(masterContact, duplicateContactToMerge);
					System.debug('mergeResult ' + mergeResult);
				}
				doMerge = true;
			}
			//if no duplicate contact exist then create alternate email of cvent mail
			else if (emailVsContact.get(email).size() == 1 && !emailVsAlternateEmail.containskey(email)){
				Contact contact = emailVsContact.get(email)[0];
				Alternate_Email__c alternateEmail = new Alternate_Email__c();
				alternateEmail.Active__c = true;
				alternateEmail.Alternate_Email_Address__c = contact.Cvent_Registration_Email__c;
				alternateEmail.contact_Name__c = contact.id;
				alternateEmail.Primary_Email__c = TRUE;
				alternativeEmailList.add(alternateEmail);

			}
		}
		//insert alternateemail
		if (!alternativeEmailList.isEmpty()){
			insert alternativeEmailList;
		}
	}

	//method to get existing contactid
	public Set<Id> getAlternateEmailMap(Map<String, List<Contact>> cventMailByContacts, Map<String, Alternate_Email__c> emailVsAlternateEmail){
		List<Lead> existingLeadList = new List<Lead>();
		Set<Id> existingContactIdSet = new Set<Id>();
		List<Alternate_Email__c> alternateEmailList = [SELECT Id, Alternate_Email_Address__c, Contact_Name__c, Lead_Name__c, Contact_Name__r.OwnerId, Contact_Name__r.AccountId, Contact_Name__r.Owner.IsActive
		                                               FROM Alternate_Email__c
		                                               WHERE Alternate_Email_Address__c IN :cventMailByContacts.keySet() AND (Contact_Name__c != null OR (Lead_Name__c != null AND Lead_Name__r.IsConverted = false))];
		for (Alternate_Email__c alternateEmail : alternateEmailList){
			emailVsAlternateEmail.put(alternateEmail.Alternate_Email_Address__c, alternateEmail);
			if (alternateEmail.Contact_Name__c != null && alternateEmail.Contact_Name__c != cventMailByContacts.get(alternateEmail.Alternate_Email_Address__c)[0].Id){
				existingContactIdSet.add(alternateEmail.Contact_Name__c);
				cventMailByContacts.get(alternateEmail.Alternate_Email_Address__c).add(new Contact(Id = alternateEmail.Contact_Name__c));
			} else if (alternateEmail.Lead_Name__c != null){
				existingLeadList.add(new Lead(Id = alternateEmail.Lead_Name__c, Email = alternateEmail.Alternate_Email_Address__c));
			}

		}
		if (!existingLeadList.isEmpty()){
			convertLeadToContact(cventMailByContacts, existingLeadList);
		}
		return existingContactIdSet;
	}

	//method to convert lead to contact
	public void convertLeadToContact(Map<String, List<Contact>> emailVsContact, List<Lead> existingLeadList){
		list<Database.LeadConvert> leadsToBeConverted = new list<Database.LeadConvert>();
		for (Lead lead : existingLeadList){
			Contact conversionContact = emailVsContact.get(lead.Email).get(0);
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(lead.Id);
			lc.setAccountId(conversionContact.AccountId);
			lc.setContactId(conversionContact.Id);
			lc.setOwnerId(UserInfo.getUserId());
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
}