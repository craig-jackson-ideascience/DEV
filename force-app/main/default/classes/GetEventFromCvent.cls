/**
 * GetEventFromCvent : Batch Class for retrieving Events from Cvent System and put into the salesforce
 * Database.executeBatch(new GetEventFromCvent());
 * Batch is scheduled for every 30 minutes
 * Test class - GetEventFromCvent_Test class
 */
public class GetEventFromCvent implements Database.Batchable<CventAPI.Event>, Database.AllowsCallouts, Schedulable, Database.Stateful{
	//Class variables
	public Map<String, String> cventVsSalesforceFieldMap = new Map<String, String>();
	public CventCalloutUtility cventUtility = new CventCalloutUtility();
	public Utility utilityInstance = new Utility();
	public Cvent_Integration__c cventIntegration = Cvent_Integration__c.getOrgDefaults();
	public List<CventAPI.Event> cventEventsList = new List<CventAPI.Event>();
	public List<String> statusList = cventIntegration.Event_Statuses__c.split(';');
	public DateTime lastSyncedTime = cventIntegration.Event_Last_Synced__c;
	public Boolean hasError = false;
	public Integer errorCount = 0;
	public String emailErrorString = '<p> GetEventFromCvent Batch Class has failed with the following error(s) populated on API Request Log Records: <br/></p>';
	//Constructor
	public GetEventFromCvent(){
		getfieldMetadata();
	}

	public GetEventFromCvent(List<CventAPI.Event> cventRetrievedEventsList){
		this.cventEventsList = cventRetrievedEventsList;
		getfieldMetadata();
	}

	public GetEventFromCvent(List<String> statusList, DateTime lastSyncTime){
		if (statusList != null){
			this.statusList = statusList;
		}
		if (lastSyncTime != null){
			this.lastSyncedTime = lastSyncTime;
		}
		getfieldMetadata();
	}

	/**
	 * getFieldMetadataMap : Method to get the FieldMapping From Metadata to Map
	 */
	public void getfieldMetadata(){
		for (Cvent_to_Event_Mapping__mdt cventMetadata : [SELECT Cvent_Field__c, Salesforce_Field__c
		                                                  FROM Cvent_to_Event_Mapping__mdt
		                                                  WHERE Type__c = 'Event']){
			cventVsSalesforceFieldMap.put(cventMetadata.Cvent_Field__c, cventMetadata.Salesforce_Field__c);
		}
	}

	//Schedule 's Execute method to call batch
	public void execute(SchedulableContext sc){
		Database.executeBatch(new GetEventFromCvent());
	}

	//Start of Batch
	public List<CventAPI.Event> start(Database.BatchableContext bc){


		try{
			if (cventEventsList.isEmpty()){
				//Call Method to get Events from Cvent
				cventEventsList = cventUtility.searchAndRetrieveEvents(statusList, lastSyncedTime);

			}
		} catch (Exception ex){
			System.debug('Exception: ' + ex + ', Message: ' + ex.getMessage() + ', Line Number: ' + ex.getLineNumber() + '\n' + ex.getStackTraceString());

			String errorMessage = '#--Exception at--#' + ex.getLineNumber() + ' ' + ex.getMessage() + ' ' + ex.getStackTraceString();
			String apiLogId = APIRequestLog.createApiRequestlog(errorMessage, 'Cvent - GetEventFromCvent Start Error');
			generateErrorString(apiLogId);

		}

		// collect the batches of records or objects to be passed to execute
		return cventEventsList;
	}

	//Execute of Batch
	public void execute(Database.BatchableContext bc, List<CventAPI.Event> cventEventList){
		//call method for processing cvent event records
		try{
			processCventEventRecords(cventEventList);
		} catch (Exception ex){
			System.debug('Exception: ' + ex + ', Message: ' + ex.getMessage() + ', Line Number: ' + ex.getLineNumber() + '\n' + ex.getStackTraceString());
			String errorMessage = '#--Exception at--#' + ex.getLineNumber() + ' ' + ex.getMessage() + ' ' + ex.getStackTraceString();
			String apiLogId = APIRequestLog.createApiRequestlog(errorMessage, 'Cvent - GetEventFromCvent Execute Error');
			generateErrorString(apiLogId);

		}
	}

	//Finish of Batch
	public void finish(Database.BatchableContext bc){

		/*Sending Email Start*/
		if (hasError){
			cventUtility.sendErrorMail('GetEventFromCvent Batch Class Error', emailErrorString);
		} else{
			//Update Event Last syncing time on custom setting
			Cvent_Integration__c updationSetting = new Cvent_Integration__c();
			updationSetting.Id = cventIntegration.Id;
			updationSetting.Event_Last_Synced__c = DateTime.now();
			update updationSetting;
		}
	}

	/**
	 * processCventEventRecords : Method for processing the cventEventWrapper records to Salesforce Event Record
	 * @param  cventEventList : List of Wrapper Records
	 */
	public void processCventEventRecords(List<CventAPI.Event> cventEventList){


		List<Event__c> eventsToUpsert = new List<Event__c>();
		List<String> dateTimeFieldsList = new List<String>{ 'EventStartDate', 'EventEndDate' };
		Set<String> cventIdSet = new Set<String>();
		Set<String> eventNameSet = new Set<String>();
		Map<String, String> cventIdVsCventSerializaDataMap = new Map<String, String>();
		//Iterate on records and get the cventids and title list ready
		for (CventAPI.Event cventEvent : cventEventList){
			cventIdSet.add(cventEvent.Id);
			eventNameSet.add(cventEvent.EventTitle);
		}

		//Retrieve Events based on CventId or Event Name
		String query = 'SELECT Id,';
		query += String.join(cventVsSalesforceFieldMap.values(), ',');
		query += ' FROM Event__c WHERE Cvent_Event_Id__c IN: cventIdSet OR (Cvent_Event_Id__c =  null AND Name IN: eventNameSet)';
		List<Event__c> eventsList = Database.query(query);
		Map<String, Event__c> eventsMap = new Map<String, Event__c>();

		//Iterate on events and create a map
		for (Event__c event : eventsList){
			String key = event.Cvent_Event_Id__c != null ? event.Cvent_Event_Id__c : event.Name;
			eventsMap.put(key, event);
		}

		//Iterate on records
		for (CventAPI.Event cventEvent : cventEventList){
			//Salesforce event
			Event__c salesforceEvent = eventsMap.containsKey(cventEvent.Id) ? eventsMap.get(cventEvent.Id) : (eventsMap.containsKey(cventEvent.EventTitle) ? eventsMap.get(cventEvent.EventTitle) : null);
			Sobject event = new Event__c();


			//Flag for change in field
			Boolean hasChange = false;
			if (!cventEvent.CustomFieldDetail.isEmpty()){

				/**
				 Iterate on custom field of cvent : Custom Field Cvent is a list of Object to the wrapper
				 */
				for (CventAPI.CustomFieldDetail customField : cventEvent.CustomFieldDetail){

					//If Field contains in the metadatamap then put it into the event instance
					if (cventVsSalesforceFieldMap.containsKey(customField.FieldName)){
						String salesforceField = cventVsSalesforceFieldMap.get(customField.FieldName);
						if (salesforceEvent == null || salesforceEvent.get(salesforceField) != customField.FieldValue){
							//Call method for assigning cvent value by typecasting if needed based on datatype of salesforcefield
							utilityInstance.assignValuesToField(event, salesforceField, customField.FieldValue, 'Event__c');
							hasChange = true;
						}


					}
				}
			}

			/*
			 * Converting the Wrapper Instance to Map<String,Object> because to get the fieldname of wrapper
			 * dynamically by referring to the key
			 */
			String jsonReq = Json.serialize(cventEvent);

			Map<String, Object> cventRecordMap = (Map<String, Object>)JSON.deserializeUntyped(jsonReq);


			//Iterate on metadata
			for (String cventField : cventVsSalesforceFieldMap.keySet()){

				//If instance map contains the field
				if (cventRecordMap.containsKey(cventField)){

					String salesforceField = cventVsSalesforceFieldMap.get(cventField);
					Object cventValue = cventRecordMap.get(cventField);


					//If value is empty then move to the next field
					if (cventValue == null || cventValue == ''){
						continue;
					}
					//if field is name and its length is more then 80 chars then trim it to 80characters
					else if (salesforceField == 'Name' && ((String) cventValue).length() > 80){
						String partialString = ((String) cventValue).substring(0, 80);
						hasChange = setEventFieldValues(salesforceField, salesforceEvent, (Object) partialString, event, hasChange);

					}

					/*Wrapper field is of datetime and salesforce field is date
					 *so we need to take just the date part of datetime
					 */
					else if (dateTimeFieldsList.contains(cventField)){
						Date datevalue = Date.valueOf(((String) cventValue).substringBefore('T'));
						hasChange = setEventFieldValues(salesforceField, salesforceEvent, (Object) datevalue, event, hasChange);

					}

					/**
					 Wrapper field is of datetime but in EST Timezone and
					 *in salesforce we need GMT TimeZone so conversion is done
					 */
					else if (cventField == 'LastModifiedDate'){
						//2020-10-22T11:28:38.777Z
						DateTime gmtTime = cventUtility.otherTimeToGMTTime((String) cventValue, cventIntegration.Cvent_Time_Zone__c);
						hasChange = setEventFieldValues(salesforceField, salesforceEvent, (Object) gmtTime, event, hasChange);

					}

					/**
					 *Remaining map all field by typecasting if needed
					 */
					else{

						if (salesforceEvent == null || salesforceEvent.get(salesforceField) != cventValue){
							utilityInstance.assignValuesToField(event, salesforceField, cventValue, 'Event__c');
							hasChange = true;
						}
					}
				}

			}

			if (salesforceEvent == null){
				event.put('Registration_Source__c', 'Cvent');
			} else{
				event.Id = salesforceEvent.Id;
			}
			System.debug('event ' + event);
			//if there is a change in field value
			if (hasChange){

				//Add to list
				eventsToUpsert.add((Event__c)event);
				cventIdVsCventSerializaDataMap.put(cventEvent.Id, jsonReq);

			}
		}
		System.debug('#--eventsToUpsert--#' + eventsToUpsert.size());

		//Upsert
		if (!eventsToUpsert.isEmpty()){
			List<Database.UpsertResult> eventUpsertResults = Database.upsert (eventsToUpsert, Schema.Event__c.Id, false);
			List<Cvent_Registration_Log__c> cventLogsToUpsert = new List<Cvent_Registration_Log__c>();
			Integer eventCount = 0;

			//Iterate on result of dml
			for (Database.UpsertResult result : eventUpsertResults){
				//If unsuccessful
				if (!result.isSuccess()){
					String errorMessage = '';
					for (Database.Error err : result.getErrors()){
						errorMessage += string.valueOf(err.getMessage());
					}
					//Log the error
					Cvent_Registration_Log__c cventLog = new Cvent_Registration_Log__c();
					String cventId = eventsToUpsert[eventCount].Cvent_Event_Id__c;
					cventLog.Cvent_Id__c = cventId;
					cventLog.Cvent_Data__c = cventIdVsCventSerializaDataMap.get(cventId);
					cventLog.Retrieved__c = Datetime.now();
					cventLog.Type__c = 'Event';
					cventLog.Sfdc_Upsert_Last_Error__c = errorMessage;
					cventLog.sfdc_upsert_last_attempt_time__c = DateTime.now();
					cventLog.sfdc_upsert_attempts_count__c = cventLog.sfdc_upsert_attempts_count__c != null ? cventLog.sfdc_upsert_attempts_count__c + 1 : 1;
					cventLogsToUpsert.add(cventLog);

					eventCount++;
				}

			}
			if (!cventLogsToUpsert.isEmpty()){
				//Upsert the Event Log error
				Database.upsert (cventLogsToUpsert, Schema.Cvent_Registration_Log__c.Cvent_Id__c, false);
			}

		}
	}

	/**
	 * @description setEventFieldValues description
	 * @param  salesforceField : salesforceField api name
	 * @param  salesforceEvent : salesforce event record
	 * @param  cventValue      : field value in cvent
	 * @param  event      : event that is to be upserted
	 * @param  hasChange   : boolean flag
	 */
	public Boolean setEventFieldValues(String salesforceField, Event__c salesforceEvent, Object cventValue, sObject event, Boolean hasChange){
		Boolean changeInValue = hasChange;
		if (salesforceEvent == null || salesforceEvent.get(salesforceField) != cventValue){
			event.put(salesforceField, cventValue);
			//If field is not Cvent_Event_LastModifiedDate__c then consider there is a change in field
			if (salesforceField != 'Cvent_Event_LastModifiedDate__c'){
				changeInValue = true;
			}
		}
		return changeInValue;
	}

	private void generateErrorString(String apiLogId){
		errorCount += 1;
		emailErrorString += errorCount + '. <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + apiLogId + '"> APIRequest Log - ' + errorCount + '</a> <br/>';
		hasError = true;
	}
}