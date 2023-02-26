/*
 Test Class-CventSync_Test
 * */
public with sharing class CventSync{
	/**
	 * @description getFileName : method to get the file name for the event
	 * @param  eventID : Id of event
	 */
	@AuraEnabled
    public static string getFileName(String eventID){
        List<Event__c> events = [SELECT Id, Name FROM Event__c WHERE Id =: eventID AND Cvent_Event_Id__c != null LIMIT 1];
        if(events != null && !events.isEmpty()){
            string fileName = events[0].Name +' Missing Event Registrations File';
            return fileName;
        }else{
             return 'error';
        }
    }

	/**
	 * @description getCventData : Method to get the Cvent Data
	 * @param  eventID : Id of event
	 */
	@AuraEnabled
	public static string getCventData(String eventID){
		//String cventEventID
		CventCalloutUtility cventUtility = new CventCalloutUtility();
		List<Event__c> events = [SELECT Id, Cvent_Event_Id__c
		                         FROM Event__c
		                         WHERE Id = :eventID AND Cvent_Event_Id__c != null
		                         LIMIT 1];

		if (events != null && !events.isEmpty()){
			//create filters
			CventAPI.Filter eventIdfilter = cventUtility.getCventFilter('EventId', 'Equals', events[0].Cvent_Event_Id__c, null);
			CventAPI.CvSearch cvSearchObject = cventUtility.getCvSearchObject('AndSearch', new List<CventAPI.Filter>{eventIdFIlter});
			String cventSessionHeader = cventUtility.cventLogin();

			if (String.isNotEmpty(cventSessionHeader) && !cventSessionHeader.contains('Error : ')){

				CventAPI.IdArray result = cventUtility.cventSearch(cventSessionHeader, 'Registration', cvSearchObject);
				Set<String> existingRegistrationIds = getEventRegistrationIds(eventID);
				List<String> missingIds = new List<String>();
				for (String cventID : result.Id){
					if (!existingRegistrationIds.contains(cventID)){
						missingIds.add(cventID);
					}
				}
				//generate files out of missingIDs
				if (!missingIds.isEmpty()){
					List<Cvent_Registration_Log__c> registrationLogsToInsert = cventUtility.getCventLogsToInsertRecords(missingIds);
                    System.debug('registrationLogsToInsert '+registrationLogsToInsert.size());
					if (!registrationLogsToInsert.isEmpty()){
						Database.insert(registrationLogsToInsert);
					}
                    return 'success';
				} else{
					return 'info : There is no information about missing registrations.';
				}
			} else{
				return cventSessionHeader;
			}
		} else{
			//Below code is used for file download testing
			/*string testString = 'php -f cli-registrations-requeue.php F7B0CAFB-B468-401A-9C2F-AFD8562F123A && \\'+'\n';
			 testString += 'php -f cli-registrations-requeue.php F7B0CAFB-B468-401A-9C2F-AFD8562F123A && \\'+'\n';
			 testString += 'php -f cli-registrations-requeue.php F7B0CAFB-B468-401A-9C2F-AFD8562F123A';
			 return EncodingUtil.base64Encode(Blob.valueOf(testString));*/
			return 'error';
		}
	}

	/**
	 * @description getEventRegistrationIds : Method to get the Event Registration Ids for an event
	 * @param  eventID : Id of event
	 */
	private static Set<String> getEventRegistrationIds(String eventID){
		Set<String> existingRegistrationIds = new Set<String>();
		for (Event_Registrations__c reg : [SELECT ID, Cvent_Registration_Id__c
		                                   FROM Event_Registrations__c
		                                   WHERE Event__c = :eventID]){
			existingRegistrationIds.add(reg.Cvent_Registration_Id__c);
		}
		return existingRegistrationIds;
	}
}