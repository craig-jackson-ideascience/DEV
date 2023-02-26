public class EventRegistrationTriggerHandler implements ITriggerHandler{
	public static void BeforeInsert(List<SObject> triggerNew){
	}

	public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap){
	}

	public static void BeforeDelete(Map<Id, Sobject> oldMap){
		//call before delete actions
	}

	public static void AfterInsert(Map<Id, SObject> newMap){
		updatecontactLeadTechnology((Map<Id, Event_Registrations__c>)newMap, null);
		populateUnknownContactName((Map<Id, Event_Registrations__c>)newMap, null);
		updateInterestOnContactTechnology((Map<Id, Event_Registrations__c>)newMap, null);
		updateContactFields((Map<Id, Event_Registrations__c>)newMap, null);
	}

	public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){
		updatecontactLeadTechnology((Map<Id, Event_Registrations__c>)newMap, (Map<Id, Event_Registrations__c>)oldMap);
		populateUnknownContactName((Map<Id, Event_Registrations__c>)newMap, (Map<Id, Event_Registrations__c>)oldMap);
		updateInterestOnContactTechnology((Map<Id, Event_Registrations__c>)newMap, (Map<Id, Event_Registrations__c>)oldMap);
		updateContactFields((Map<Id, Event_Registrations__c>)newMap, (Map<Id, Event_Registrations__c>)oldMap);
	}

	public static void AfterDelete(Map<Id, Sobject> oldMap){
	}

	public static void AfterUnDelete(Map<Id, Sobject> newMap){
		//call after undelete actions
	}

	public Boolean IsDisabled(){
		return false;
	}

	public static void populateUnknownContactName(Map<Id, Event_Registrations__c> newMap, Map<Id, Event_Registrations__c> oldMap){
		List<Event_Registrations__c> eventRegistrations = [SELECT Id, Name, Cvent_Registration_FirstName__c, Cvent_Registration_LastName__c, Contact__r.FirstName, Contact__r.LastName
		                                                   FROM Event_Registrations__c
		                                                   WHERE Id IN :newMap.values() AND ((Contact__r.FirstName = '%Unknown%' AND Cvent_Registration_FirstName__c != '') OR (Contact__r.LastName = '%Unknown%' AND Cvent_Registration_LastName__c != ''))];
		if (!eventRegistrations.isEmpty()){
			List<Contact> contactsToUpdate = new List<Contact>();
			for (Event_Registrations__c eventReg : eventRegistrations){
				Contact contact = new Contact(Id = eventReg.Contact__c);
				if (eventReg.Contact__r.FirstName.containsIgnoreCase('unknown') && String.isNotBlank(eventReg.Cvent_Registration_FirstName__c)){
					contact.FirstName = eventReg.Cvent_Registration_FirstName__c;
				}
				if (eventReg.Contact__r.LastName.containsIgnoreCase('unknown') && String.isNotBlank(eventReg.Cvent_Registration_LastName__c)){
					contact.LastName = eventReg.Cvent_Registration_LastName__c;
				}
				contactsToUpdate.add(contact);
			}
			if (!contactsToUpdate.isEmpty()){
				update contactsToUpdate;
			}
		}
	}

	public static void updateContactLeadTechnology(Map<Id, Event_Registrations__c> newMap, Map<Id, Event_Registrations__c> oldMap){
		set<Id> setContactIds = new set<Id>();
		set<Id> setLeadIds = new set<Id>();
		set<Id> setEventRegistrationIds = new set<Id>();
		set<Id> setEventId = new set<Id>();
		List<String> lstStrLead = new List<String>();
		List<String> lstStrContact = new List<String>();
		List<Contact> lstContact = new List<Contact>();
		map<Id, Contact> mapContactUpdate = new map<Id, Contact>();
		Contact objContact = new Contact();
		List<Contact> lstContacttactUpdate = new List<Contact>();
		List<Lead> lstLeadUpdate = new List<Lead>();
		List<string> lstString = new List<String>();
		Event_Registrations__c oldER = new Event_Registrations__c();
		For (Event_Registrations__c objEventRegistration : newMap.values()){
			setEventRegistrationIds.add(objEventRegistration.id);
			if (oldMap != null){
				oldER = oldMap.get(objEventRegistration.id);
			}
			if (oldER.Event__c != objEventRegistration.Event__c || oldER.Contact__c != objEventRegistration.Contact__c){
				if (objEventRegistration.Contact__c != null){
					setContactIds.add(objEventRegistration.Contact__c);
				}
				if (objEventRegistration.Event__c != null){
					setEventId.add(objEventRegistration.Event__c);
				}
			}
		}

		map<Id, Contact> mapContact = new Map<Id, Contact>([Select id, Technology__c, (Select id, Contact__c
		                                                                               from Event_Registrations__r)
		                                                    From Contact
		                                                    where id IN :setContactIds]);
		map<Id, Event__c> mapEvent = new map<Id, Event__c>([Select id, Technology__c, (Select id, Event__c
		                                                                               from Event_Registrations__r)
		                                                    from Event__c
		                                                    where id IN :setEventId]);
		For (Event_Registrations__c objEventRegistration : newMap.values()){
			if (oldMap != null){
				oldER = oldMap.get(objEventRegistration.id);
			}
			if (oldER.Event__c != objEventRegistration.Event__c || oldER.Contact__c != objEventRegistration.Contact__c){
				lstStrContact.clear();
				lstStrLead.clear();
				lstString.clear();
				if (objEventRegistration.Event__c != null){
					Event__c objEvent = mapEvent.get(objEventRegistration.Event__c);
					lstString.add(objEvent.Technology__c);
				}
				if (objEventRegistration.Contact__c != null){
					objContact = mapContact.get(objEventRegistration.Contact__c);
					lstStrContact.add(objContact.Technology__c);
				}
				if (objContact.id != null){
					lstContact.addALL(Utility.updateTechnologyOnContact(objContact, lstString, lstStrContact));
				}
			}
		}
		if (lstContact.size() > 0){
			mapContactUpdate.putAll(lstContact);
			system.debug('mapContactUpdate-->' + mapContactUpdate);
			update mapContactUpdate.values();
		}
	}

	//Method to map ',' seperated Cvent_Registration_AreasOfInterest__c field of eventRegistration to contact's technology field by';' seperated'
	public static void updateInterestOnContactTechnology(Map<Id, Event_Registrations__c> newMap, Map<Id, Event_Registrations__c> oldMap){

		//Get Picklist values of technology FIeld of Contact
		Set<String> pickSetValuesSet = new Set<String>(Utility.getPickListValuesIntoList('Contact', 'Technology__c'));
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		Set<Id> contactIdSet = new Set<Id>();
		Map<Id, Contact> mapOfContactToUpdate = new Map<Id, Contact>();
		List<Event_Registrations__c> evtRegistrationList = new List<Event_Registrations__c>();
		//Iterate
		for (Event_Registrations__c newEvntRegistration : newMap.values()){

			//If Cvent_Registration_AreasOfInterest__c is changed then map it to Technology Field of Contact
			if (newEvntRegistration.Cvent_Registration_AreasOfInterest__c != null && newEvntRegistration.Contact__c != null && (oldMap == null || newEvntRegistration.Cvent_Registration_AreasOfInterest__c != oldMap.get(newEvntRegistration.Id).Cvent_Registration_AreasOfInterest__c)){
				contactIdSet.add(newEvntRegistration.Contact__c);
				evtRegistrationList.add(newEvntRegistration);
			}
		}
		if (!evtRegistrationList.isEmpty()){
			Map<Id, Contact> mapOfContact = new Map<Id, Contact>([SELECT Id, Technology__c
			                                                      FROM Contact
			                                                      WHERE Id IN :contactIdSet]);
			for (Event_Registrations__c evtReg : evtRegistrationList){

				if (mapOfContact.containsKey(evtReg.Contact__c) || mapOfContactToUpdate.containsKey(evtReg.Contact__c)){

					//Get the Contact
					Contact con = mapOfContactToUpdate.containsKey(evtReg.Contact__c) ? mapOfContactToUpdate.get(evtReg.Contact__c) : mapOfContact.get(evtReg.Contact__c);

					//for existing Contact  if it doesn't end with ; add ;
					String contactTechnology = con.technology__c != null ? con.technology__c : '';
					if (String.isNotEmpty(con.technology__c) && !con.technology__c.endsWith(';')){
						contactTechnology += ';';
					}
					//Iterate through picklist values
					for (String pickValue : pickSetValuesSet){

						//If Area of interest field contains the picklist values then add to the technology with ';' seperated
						if (evtReg.Cvent_Registration_AreasOfInterest__c.contains(pickValue) && !contactTechnology.contains(pickValue)){
							System.debug('selectedpickvalue ' + pickValue);
							contactTechnology += pickValue + ';';
						}
					}

					if (contactTechnology != con.technology__c){
						mapOfContactToUpdate.put(evtReg.Contact__c, new Contact(Id = evtReg.Contact__c, Technology__c = contactTechnology));
					}
				}
			}


			if (!mapOfContactToUpdate.isEmpty()){
				//update
				update mapOfContactToUpdate.values();
			}
		}
	}

	//Method to update contact from eventRegistration
	public static void updateContactFields(Map<Id, Event_Registrations__c> newMap, Map<Id, Event_Registrations__c> oldMap){

		//variables
		Map<string, String> registrationVsContactField = new Map<String, String>();
		Map<Id, Contact> mapOfContactToUpdate = new Map<Id, Contact>();
		Set<String> eventRegistrationFieldSet = new Set<string>();
		Set<Id> contactIdSet = new Set<Id>();
		List<Event_Registrations__c> evtRegistrationList = new List<Event_Registrations__c>();

		//Retrieve Metadata that stores mapping
		List<Cvent_Event_Registration_Mapping__mdt> cventMappingList = [SELECT Event_Registration_Field__c, Contact_Field__c
		                                                                FROM Cvent_Event_Registration_Mapping__mdt];

		//create map of eventregistration Field VS Contact's field
		for (Cvent_Event_Registration_Mapping__mdt cventMap : cventMappingList){
			registrationVsContactField.put(cventMap.Event_Registration_Field__c, cventMap.Contact_Field__c);
			if (cventMap.Event_Registration_Field__c.contains(',')){
				eventRegistrationFieldSet.addAll(cventMap.Event_Registration_Field__c.split(','));
			} else{
				eventRegistrationFieldSet.add(cventMap.Event_Registration_Field__c);
			}

		}

		//Iterate
		for (Event_Registrations__c newEvntRegistration : newMap.values()){

			//Iterate on eventRegistration's fields
			for (String eventRegistrationField : eventRegistrationFieldSet){

				//If on Insert or on update there is a change in field value
				if ((oldMap == null || newEvntRegistration.get(eventRegistrationField) != oldMap.get(newEvntRegistration.Id).get(eventRegistrationField)) && newEvntRegistration.get(eventRegistrationField) != null && newEvntRegistration.Contact__c != null){
					contactIdSet.add(newEvntRegistration.Contact__c);
					evtRegistrationList.add(newEvntRegistration);
					break;
				}
			}
		}
		system.debug('contactIdSet ' + contactIdSet.size());
		if (!contactIdSet.isEmpty()){
			String query = 'SELECT Id,';
			query += string.join(registrationVsContactField.values(), ',');
			query += ' FROM Contact WHERE Id IN :contactIdSet';
			system.debug('query ' + query);
			Set<String> nameSet = new Set<String>{'FirstName', 'LastName'};
			//Retrieve Contact
			Map<Id, Contact> mapOfContact = new Map<Id, Contact>((List<Contact>)Database.query(query));
			Map<Id, Set<Id>> contactVsRegistrationIdsMap = new Map<Id, Set<Id>>();
			for (Event_Registrations__c evtReg : evtRegistrationList){

				//Contains in map?
				if (mapOfContact.containsKey(evtReg.Contact__c) || mapOfContactToUpdate.containsKey(evtReg.Contact__c)){
					Contact contact = mapOfContactToUpdate.containsKey(evtReg.Contact__c) ? mapOfContactToUpdate.get(evtReg.Contact__c) : mapOfContact.get(evtReg.Contact__c);
					Boolean hasChange = false;

					//Iterate on each field mappings
					for (String evtRegField : registrationVsContactField.keySet()){
						String contactField = registrationVsContactField.get(evtRegField);
						//system.debug('contactField ' + contactField);
						//system.debug('evtRegField ' + evtRegField);
						// system.debug('con '+contact.get(contactField)+' evtReg.get(evtRegField ) '+evtReg.get(evtRegField));

						//As for mailingStreet , multiple field is mapped from eventregistration
						if (evtRegField.contains(',') && contact.get(contactField) == null){

							//get mailing street
							String street = getMailingStreet(evtRegField.split(','), evtReg);
							if (String.isNotEmpty(street)){
								contact.put(contactField, street);
								hasChange = true;
								//system.debug(contact.get(contactField));
							}

						}
						//For normal field
						else if ((contact.get(contactField) == null || evtRegField == 'Cvent_Company_URL__c' || (nameSet.contains(contactField) && ((String) contact.get(contactField)).toLowerCase().contains('unknown'))) && evtReg.get(evtRegField) != null){

							contact.put(contactField, evtReg.get(evtRegField));
							hasChange = true;
							//system.debug(contact.get(contactField));
						}
					}
					system.debug('contact ' + contact);
					if (hasChange){
						mapOfContactToUpdate.put(evtReg.Contact__c, contact);
						if (!contactVsRegistrationIdsMap.containsKey(evtReg.Contact__c)){
							contactVsRegistrationIdsMap.put(evtReg.Contact__c, new Set<Id>());
						}
						contactVsRegistrationIdsMap.get(evtReg.Contact__c).add(evtReg.Id);
					}

				}
			}
			system.debug('mapOfContactToUpdate ' + mapOfContactToUpdate);
			if (!mapOfContactToUpdate.isEmpty()){
				//update
				List<Contact> contactList = mapOfContactToUpdate.values();
				//update
				List<Database.SaveResult> updateContactResults = Database.update(contactList, false);
				Integer count = 0;
				for (Database.SaveResult result : updateContactResults){
					//If result is unsuccessful
					if (!result.isSuccess()){
						system.debug('result ' + result);
						if (contactVsRegistrationIdsMap.containsKey(contactList[count].Id)){

							String errorMessage = 'Error while processing contact from EventRegistrationTriggerHandler for - ' + contactList[count].Id + '  ';
							for (Database.Error err : result.getErrors()){
								errorMessage += string.valueOf(err.getMessage())+'\n';
							}
							system.debug('errorMessage ' + errorMessage);

							for (Id registrationId : contactVsRegistrationIdsMap.get(contactList[count].Id)){

								newMap.get(registrationId).addError(errorMessage);
							}
						}
					}
					count++;
				}
				//update mapOfContactToUpdate.values();
			}
		}
	}

	public static String getMailingStreet(List<String> eventRegFieldList, Event_Registrations__c eventRegistration){
		String completeAddress = '';
		Integer i = 1;
		//Iterate
		for (String eventRegistrtnField : eventRegFieldList){

			//Append if field is not Empty
			if (String.isNotEmpty((String) eventRegistration.get(eventRegistrtnField))){
				completeAddress += ' ' + eventRegistration.get(eventRegistrtnField);
			}
			//As WorkAddress is not Empty then return that or else iterate more to get Mailing Street
			if (i == 3 && String.isNotEmpty(completeAddress)){
				break;
			}
			i++;
		}
		return completeAddress;
	}
}