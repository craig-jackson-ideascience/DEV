/**
 * CventRegistrationBatch Created by Cloudroute Solutions on 01-05-2021
 * To create cvent registrations records from cvent logs
 * Database.executeBatch(new CventRegistrationBatch());
 * Test Class - CventCalloutUtility_Test class
 */
public with sharing class CventRegistrationBatch implements Database.Batchable<sObject>{
	/* list of datetime fields */
	List<String> dateTimeFieldsList = new List<String>{'RegistrationDate', 'LastModifiedDate'};
	public Utility utilityInstance = new Utility();
	public Map<String, String> registrationVsSfFieldMap = new Map<String, String>();
	public Map<String, String> contactVsSfFieldMap = new Map<String, String>();
	public Map<String, String> sessionFieldMappings = new Map<String, String>();
	public Cvent_Integration__c cventIntegration = Cvent_Integration__c.getOrgDefaults();
	public CventCalloutUtility cventUtility = new CventCalloutUtility();
	public string query = '';
	public Map<String, Cvent_Registration_Log__c> cventRegistrationLogMap = new Map<String, Cvent_Registration_Log__c>();
	public Map<String, CventAPI.Registration> cventRegistrationWrapperMapLog = new Map<String, CventAPI.Registration>();
	public String cventContactId = LABEL.Cvent_Contact_Id;
	public Map<String, Cvent_Registration_Log__c> cventLogsToUpdate = new Map<String, Cvent_Registration_Log__c>();
	public Boolean hasError = false;
	public Integer errorCount = 0;
	public String emailErrorString = '<p> CventRegistrationBatch Class has failed with the following error(s) populated on API Request Log Records: <br/></p>';
	//Constructor
	public CventRegistrationBatch(){
		getFieldMetadataMap();
	}

	public CventRegistrationBatch(String runQuery){
		this.query = runQuery;
		getFieldMetadataMap();
	}

	/**
	 * getFieldMetadataMap : Method to get the FieldMapping From Metadata to Map
	 */
	public void getFieldMetadataMap(){
		/* prepare map of cvent field VS salesforce field */
		for (Cvent_to_Event_Mapping__mdt cventMetadata : [SELECT Cvent_Field__c, Salesforce_Field__c, Type__c
		                                                  FROM Cvent_to_Event_Mapping__mdt
		                                                  WHERE Type__c IN ('Registration', 'Contact', 'Session')]){
			if (cventMetadata.Type__c == 'Registration'){
				registrationVsSfFieldMap.put(cventMetadata.Cvent_Field__c, cventMetadata.Salesforce_Field__c);
			} else if (cventMetadata.Type__c == 'Contact'){
				contactVsSfFieldMap.put(cventMetadata.Cvent_Field__c, cventMetadata.Salesforce_Field__c);
			} else if (cventMetadata.Type__c == 'Session'){
				sessionFieldMappings.put(cventMetadata.Cvent_Field__c, cventMetadata.Salesforce_Field__c);
			}
		}
	}

	/* batch start method */
	public Database.QueryLocator start(Database.BatchableContext batchableContext){

		/* query cvent registration logs */
		if (String.isEmpty(query)){
			query = 'SELECT Id, Cvent_Data__c, Cvent_Id__c, Retrieved__c, Searched__c, Sfdc_Upsert_Attempts_Count__c, Sfdc_Upsert_Last_Attempt_Time__c, Sfdc_Upsert_Last_Error__c, Cvent_Contact_Details__c FROM Cvent_Registration_Log__c WHERE Retrieved__c != null AND Successfully_Processed__c = false AND Sfdc_Upsert_Attempts_Count__c < 3 AND Type__c = \'Registration\'';
		}

		return Database.getQueryLocator(query);
	}

	/* batch execute method */
	public void execute(Database.BatchableContext batchableContext, List<Cvent_Registration_Log__c> listOfRegistrationLog){
		//Call method for processing the Logs to EventRegistration Object
		processRegistration(listOfRegistrationLog);
	}

	/* batch finish method */
	public void finish(Database.BatchableContext batchableContext){
		if (hasError){
			cventUtility.sendErrorMail('CventRegistrationBatch Class Error', emailErrorString);
		}
	}

	/**
	 * @description processRegistration : Method for processing the Logs to EventRegistration Object
	 * @param  listOfRegistrationLog : List of Logs to be processed
	 */
	public void processRegistration(List<Cvent_Registration_Log__c> listOfRegistrationLog){
		try{

			//Initialize variables
			Set<String> setOfAlternateEmail = new Set<String>();
			
			List<Alternate_Email__c> listOfAlternateEmail = new List<Alternate_Email__c>();
			List<Event_Registrations__c> listOfEventRegist = new List<Event_Registrations__c>();
			Set<String> successfulEventRegistrationsIds = new Set<String>();

			/* iterate over queried records */
			for (Cvent_Registration_Log__c cventLog : listOfRegistrationLog){

				/**
				 * Prepare different collections for CventIds,Map of Registration Log and Desrialize Registration Wrapper
				 */				
				CventAPI.Registration cventRegistration = (CventAPI.Registration)JSON.deserialize(cventLog.Cvent_Data__c, CventAPI.Registration.class);
				System.debug('cventRegistration.EmailAddress ' + cventRegistration.EmailAddress);
				System.debug('cventRegistration.SourceId ' + cventRegistration.SourceId);

				if (cventRegistration.EmailAddress != null){
					setOfAlternateEmail.add(cventRegistration.EmailAddress);

				}
				
				cventRegistrationWrapperMapLog.put(cventRegistration.Id, cventRegistration);
				cventRegistrationLogMap.put(cventLog.Cvent_Id__c, cventLog);

			}
			
			/* query alternate emails */
			if (!setOfAlternateEmail.isEmpty()){
				listOfAlternateEmail = [SELECT Id, Name, Lead_Name__c, Contact_Name__c, Alternate_Email_Address__c, Contact_name__r.Username__c, Lead_name__r.Username__c
				                        FROM Alternate_Email__c
				                        WHERE Alternate_Email_Address__c IN :setOfAlternateEmail];
			}
			System.debug('#--listOfAlternateEmail--#' + listOfAlternateEmail.size());

			List<Contact> listOfContToCreate = new List<Contact>();
			List<Lead> listOfLeadToConvert = new List<Lead>();
			Map<String, String> mapOfSourceVsContactId = new Map<String, String>();

			/**
			 * call Method to prepare the contact which is to be mapped to event registration
			 */
			prepareContactToAdd(listOfContToCreate, listOfLeadToConvert, listOfAlternateEmail, mapOfSourceVsContactId);


			//Map to store ErrorMessage which is a result of while converting the lead/creating new contact against the Email Address
			Map<String, String> emailVsErrorMap = new Map<String, String>();

			/* convert lead */
			if (!listOfLeadToConvert.isEmpty()){
				Integer leadCount = 0;

				//Update lead
				List<Database.SaveResult> updateLeads = Database.update(listOfLeadToConvert, false);
				for (Database.SaveResult result : updateLeads){
					//If result is unsuccessful
					if (!result.isSuccess()){
						String errorMessage = 'Attempted to convert a Lead but unable to do for - ' + listOfLeadToConvert[leadCount].Id + '--';
						for (Database.Error err : result.getErrors()){
							errorMessage += string.valueOf(err.getMessage())+'\n';
						}
						emailVsErrorMap.put(listOfLeadToConvert[leadCount].Email, errorMessage);

					}
				}
			}

			/* insert contacts */
			System.debug('#--listOfContToCreate--#' + listOfContToCreate.size());
			Integer count = 0;
			if (!listOfContToCreate.isEmpty()){
				//Insert new contact
				List<Database.SaveResult> insertContacts = Database.insert(listOfContToCreate, false);
				for (Database.SaveResult result : insertContacts){
					String key =  listOfContToCreate[count].Email.toLowerCase();

					if (result.isSuccess()){
						mapOfSourceVsContactId.put(key, listOfContToCreate[count].Id);
					} else{
						String errorMessage = 'On creation of contact with email - ' + listOfContToCreate[count].Email + '---';
						Boolean hasError = false;
						for (Database.Error err : result.getErrors()){
							if (err.getMessage().contains('INVALID_EMAIL_ADDRESS')){

								mapOfSourceVsContactId.put(key, cventContactId);
								hasError = false;
								break;

							} else{
								errorMessage += err.getMessage()+'\n';
								hasError = true;
							}
						}
						if (hasError){
							emailVsErrorMap.put(listOfContToCreate[count].Email, errorMessage);
						}

					}
					count++;
				}
			}

			/* query contact converted id */
			Map<Id, Lead> mapOfConvertedLead = new Map<Id, Lead>();
			if (!listOfLeadToConvert.isEmpty()){
				mapOfConvertedLead = new Map<Id, Lead>([SELECT Id, ConvertedContactId
				                                        FROM Lead
				                                        WHERE Id IN :listOfLeadToConvert]);
			}
			Set<String> cventIdSet = cventRegistrationWrapperMapLog.keySet();

			//Retrieve Existing Salesforce Registration based on Cvent_Registration_Id__c
			String query = 'SELECT Id,Contact__c,Event__c,Name,';
			//Filtering the list to set and then again to list as the map may contains duplicate field value
			List<String> registrtaionFields = new List<String>(new Set<String>(registrationVsSfFieldMap.values()));
			query += String.join(registrtaionFields, ',');
			query += ' FROM Event_Registrations__c WHERE Cvent_Registration_Id__c IN: cventIdSet';
			List<Event_Registrations__c> salesforceRegistrationList = Database.query(query);

			//Map for storing Cvent_Registration_Id__c against registrtaion.
			Map<String, Event_Registrations__c> salesforceRegistrationMap = new Map<String, Event_Registrations__c>();
			//Iterate on events and create a map
			for (Event_Registrations__c registrtn : salesforceRegistrationList){
				salesforceRegistrationMap.put(registrtn.Cvent_Registration_Id__c, registrtn);
			}

			/*
			 Iterate on Records mapped the fields accordingly.
			 */
			for (Cvent_Registration_Log__c cventLog : listOfRegistrationLog){
				CventAPI.Registration cventRegistration = cventRegistrationWrapperMapLog.get(cventLog.Cvent_Id__c);

				//If errorMap contains then populate it on log records
				if (emailVsErrorMap.containsKey(cventRegistration.EmailAddress)){
					Cvent_Registration_Log__c updateLog = new Cvent_Registration_Log__c(Id = cventLog.Id);
					updateLog.Sfdc_Upsert_Last_Error__c = emailVsErrorMap.get(cventRegistration.EmailAddress);
					updateLog.sfdc_upsert_last_attempt_time__c = DateTime.now();
					updateLog.sfdc_upsert_attempts_count__c = cventLog.sfdc_upsert_attempts_count__c != null ? cventLog.sfdc_upsert_attempts_count__c + 1 : 1;
					cventLogsToUpdate.put(cventLog.Cvent_Id__c, updateLog);
				} else{

					//Map the fields

					Event_Registrations__c eventRegistToUpsert = new Event_Registrations__c();

					//Salesforce Registration
					Event_Registrations__c salesforceRegistration = salesforceRegistrationMap.containsKey(cventRegistration.Id) ? salesforceRegistrationMap.get(cventRegistration.Id) : null;

					//Flag for change in field
					Boolean hasChange = false;
					/* external id*/
					eventRegistToUpsert.Cvent_Registration_Id__c = cventLog.Cvent_Id__c;

					/** Amount Calculation :Start
					 * Calculate Amount,AmountDue,AmountPaid fields to
					 * cvent_registration so that field mapper will do its work
					 */
					Double amount = 0;
					Double amountDue = 0;
					Double amountPaid = 0;
					if (cventRegistration.OrderDetail != null){

						Set<String> productIdSet = new Set<String>();
						//Iterate on OrderDetail and get the sum of all 3 amount fields
						for (CventAPI.OrderDetail orderDetail : cventRegistration.OrderDetail){
							if (!productIdSet.contains(orderDetail.ProductId)){
								productIdSet.add(orderDetail.ProductId);
								amount += orderDetail.Amount;
								amountDue += orderDetail.AmountDue;
								amountPaid += orderDetail.AmountPaid;

							}
						}
					}
					//Add sum to the wrapper fields
					cventRegistration.Amount = amount;
					cventRegistration.AmountDue = amountDue;
					cventRegistration.AmountPaid = amountPaid;
					/**Amount Calculation : End */

					/** Cvent Registration Question : Start
					 * Mapiing for Cvent Registration Question to Registration fields
					 */
					String answer = '';
					if (cventRegistration.EventSurveyDetail != null){

						for (CventAPI.EventSurveyDetail evtSurveyDetail : cventRegistration.EventSurveyDetail){
							answer += prepareQuestionAnswerString(evtSurveyDetail);


							if (registrationVsSfFieldMap.containsKey(evtSurveyDetail.QuestionText) && evtSurveyDetail.AnswerText != null && !evtSurveyDetail.AnswerText.isEmpty()){


								//TODO: Area Of interest seperation
								String fieldValue = String.join(evtSurveyDetail.AnswerText, ',');
								String salesforceField = registrationVsSfFieldMap.get(evtSurveyDetail.QuestionText);

								if (String.isnotBlank(fieldValue) && (salesforceRegistration == null || salesforceRegistration.get(salesforceField) != fieldValue)){

									eventRegistToUpsert.put(salesforceField, fieldValue);
									hasChange = true;
								}
							}

						}
					}
					cventRegistration.Answer = answer;
					/** Cvent Registration Question : End*/

					/*
					 * Converting the Cvent Regsitration Instance to Map<String,Object> because to get the fieldname of wrapper
					 * dynamically by referring to the key
					 */
					Map<String, Object> cventRegistrationDataMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(cventRegistration));

					Map<String, Object> contactDataMap = new Map<String, Object>();

					/**
					 * Need to Deserialize Contact Details as we populate Cvent Contact Details on Salesforce Event Registrations as well
					 */
					CventAPI.Contact contactWrapper = new CventAPI.Contact();

					if (String.isNotBlank(cventLog.Cvent_Contact_Details__c)){

						contactDataMap = (Map<String, Object>)JSON.deserializeUntyped(cventLog.Cvent_Contact_Details__c);
						contactWrapper = (CventAPI.Contact)JSON.deserialize(cventLog.Cvent_Contact_Details__c, CventAPI.Contact.class);
					}

					/**
					 * Dynamic Field mapping from Metadata :Start
					 */
					for (String field : registrationVsSfFieldMap.keySet()){

						String salesforceField = cventRegistrationDataMap.containsKey(field) || contactDataMap.containsKey(field) ? registrationVsSfFieldMap.get(field) : '';

						Object fieldValue = cventRegistrationDataMap.containsKey(field) ? cventRegistrationDataMap.get(field) : (contactDataMap.containsKey(field) ? contactDataMap.get(field) : '');

						//If instance map contains the field
						if (String.isNotEmpty(salesforceField)){

							//If value is empty then move to the next field
							if (fieldValue == null || fieldValue == ''){

								continue;
							}
							/* date time fields*/
							else if (dateTimeFieldsList.contains(field)){
								DateTime gmtTime = cventUtility.otherTimeToGMTTime((String)fieldValue, cventIntegration.Cvent_Time_Zone__c);

								if (salesforceRegistration == null || salesforceRegistration.get(salesforceField) != gmtTime){
									eventRegistToUpsert.put(salesforceField, gmtTime);
									hasChange = true;

								}
							} else{
								/**
								 *Remaining map all field by typecasting if needed
								 */
								if (salesforceRegistration == null || salesforceRegistration.get(salesforceField) != fieldValue){
									utilityInstance.assignValuesToField(eventRegistToUpsert, salesforceField, fieldValue, 'Event_Registrations__c');
									hasChange = true;

								}
							}
						}
					}
					/**
					 * Dynamic Field mapping from Metadata :End  */


					/* Mapping Contact Field on Registration :Start */

					String leadContactId = mapOfSourceVsContactId.get(cventRegistration.EmailAddress.toLowerCase());

					String contactId = mapOfConvertedLead.containsKey(leadContactId) ? mapOfConvertedLead.get(leadContactId).ConvertedContactId : leadContactId;

					if (salesforceRegistration == null || salesforceRegistration.get('Contact__c') != contactId){
						System.debug('In leadContactId ' + salesforceRegistration);
						System.debug('In contactId ' + contactId);

						eventRegistToUpsert.put('Contact__c', contactId);
						hasChange = true;

					}
					/* Mapping Contact Field on Registration :End */


					/* Mapping Event Field on Registration :Start */
					if (cventRegistrationDataMap.containsKey('EventId')){
						System.debug('#Event #' + String.valueOf(cventRegistrationDataMap.get('EventId')));
						eventRegistToUpsert.Event__r = new Event__c(Cvent_Event_Id__c = (String)cventRegistrationDataMap.get('EventId'));
						hasChange = true;

					}
					/* Mapping Event Field on Registration :End */

					/**
					 * Iterate on Custom Field of contact Wrapper to map it on Registration fields
					 */
					if (contactWrapper.CustomFieldDetail != null){

						for (CventAPI.CustomFieldDetail customField : contactWrapper.CustomFieldDetail){


							//If Field contains in the metadatamap then put it into the event instance
							if (registrationVsSfFieldMap.containsKey(customField.FieldName)){

								String salesforceField = registrationVsSfFieldMap.get(customField.FieldName);

								if (String.isNotEmpty(customField.FieldValue) && (salesforceRegistration == null || salesforceRegistration.get(salesforceField) != customField.FieldValue)){
									eventRegistToUpsert.put(salesforceField, customField.FieldValue);
									hasChange = true;

								}

							}
						}
					}
					/**Custom Field Of Contact Mapping : End */

					if (salesforceRegistration == null){
						//On create only populate DataSOurce
						eventRegistToUpsert.Data_Source__c = 'Cvent';
					} else{
						System.debug('salesforceRegistration.Id ' + salesforceRegistration.Id);
						//On update Populate Id
						eventRegistToUpsert.Id = salesforceRegistration.Id;
						successfulEventRegistrationsIds.add(salesforceRegistration.Cvent_Registration_Id__c);
					}


					/**Mapping Name : Start */
					if (cventRegistrationDataMap.containsKey('FirstName') && cventRegistrationDataMap.containsKey('LastName') && cventRegistrationDataMap.containsKey('EventTitle')){
						String registrationName = String.valueOf(cventRegistrationDataMap.get('FirstName'))+' ' + String.valueOf(cventRegistrationDataMap.get('LastName'))+'-' + String.valueOf(cventRegistrationDataMap.get('EventTitle'));
						if (salesforceRegistration == null || salesforceRegistration.get('Name') != registrationName){
							eventRegistToUpsert.Name = registrationName.length() > 80 ? registrationName.substring(0, 80) : registrationName;
							hasChange = true;

						}
					}
					/**Mapping Name : End */

					System.debug('eventRegistToUpsert ' + eventRegistToUpsert);
					//if there is a change in field value or is going to create the registration then add to list
					if (hasChange){
						//Add to list
						listOfEventRegist.add(eventRegistToUpsert);
					}
				}

			}
			System.debug('#--listOfEventRegist--#' + listOfEventRegist.size());

			//Upsert the registrations
			List<Database.UpsertResult> upsertResults = Database.upsert(listOfEventRegist, Schema.Event_Registrations__c.Cvent_Registration_Id__c, false);

			Integer countRegistration = 0;
			List<Session__c> sessionListToInsert = new List<Session__c>();

			for (Database.UpsertResult result : upsertResults){
				Cvent_Registration_Log__c currentLog = cventRegistrationLogMap.get(listOfEventRegist[countRegistration].Cvent_Registration_Id__c);
				Id logId = currentLog.Id;
				Cvent_Registration_Log__c updateLog = new Cvent_Registration_Log__c(Id = logId);
				if (result.isSuccess()){
					updateLog.Successfully_Processed__c = true;
					updateLog.Sfdc_Upsert_Last_Error__c = '';
					successfulEventRegistrationsIds.add(listOfEventRegist[countRegistration].Cvent_Registration_Id__c);
				} else{
					String errorMessage = '';
					for (Database.Error err : result.getErrors()){
						errorMessage += string.valueOf(err.getMessage());
					}

					updateLog.Sfdc_Upsert_Last_Error__c = errorMessage;
					updateLog.sfdc_upsert_last_attempt_time__c = DateTime.now();
					updateLog.sfdc_upsert_attempts_count__c = currentLog.sfdc_upsert_attempts_count__c != null ? currentLog.sfdc_upsert_attempts_count__c + 1 : 1;


				}
				cventLogsToUpdate.put(currentLog.Cvent_Id__c, updateLog);
				countRegistration++;
			}
			System.debug('#--successfulEventRegistrationsIds--#' + successfulEventRegistrationsIds.size());
			/**
			 * Upsert Related Sessions to salesforce
			 */
			if (!successfulEventRegistrationsIds.isEmpty()){
				processSessions(successfulEventRegistrationsIds);
			}

			System.debug('#--cventLogsToUpdate--#' + cventLogsToUpdate.size());


		} catch (Exception ex){
			System.debug('#--Exception at--#' + ex.getLineNumber()+' ' + ex.getMessage()+' ' + ex.getStackTraceString());
			String errorMessage = '#--Exception at--#' + ex.getLineNumber()+' ' + ex.getMessage()+' ' + ex.getStackTraceString();
			String apiLogId = APIRequestLog.createApiRequestlog(errorMessage, 'Cvent - CventRegistrationBatch Error');
			generateErrorString(apiLogId);

		} finally{

			/**
			 * On UnSuccessful/Successful processing of registration leads to Updation of its corresponding logs with the errormessages or Success Checkbox
			 */
			if (!cventLogsToUpdate.isEmpty()){
				List<Database.SaveResult> cventUpdateResults = Database.update(cventLogsToUpdate.values());
			}
		}
	}

	/**
	 *processSessions : Method for Upsert Related Sessions to salesforce
	 @param successfulEventRegistrationsIds : Cvent_Registration_Id__c of Registrations whose session is to be upserted
	 */
	public void processSessions(Set<String> successfulEventRegistrationsIds){
		Map<String, Session__c> sessionToUpsert = new Map<String, Session__c>();
		Map<String, String> sessionCventVsRegistrationCvent = new Map<String, String>();
		//Retrieve sessions
		List<Session__c> salesforceSessionsList = [SELECT Id, Cvent_Id__c, Session_Name__c, Participant__c, Registered__c
		                                           FROM Session__c
		                                           WHERE Event_Registration__r.Cvent_Registration_Id__c IN :successfulEventRegistrationsIds];
		Map<String, Session__c> cventIdVsSessionMap = new Map<String, Session__c>();

		//Iterate and have a map of Cvent_Id__c against session
		for (Session__c session : salesforceSessionsList){
			cventIdVsSessionMap.put(session.Cvent_Id__c, session);
		}

		//Iterate on records
		for (String cventRegId : successfulEventRegistrationsIds){
			CventAPI.Registration cventRegistration = cventRegistrationWrapperMapLog.containsKey(cventRegId) ? cventRegistrationWrapperMapLog.get(cventRegId) : null;
			if (cventRegistration != null){

				if (cventRegistration.OrderDetail != null){

					//Iterate on Oreder Detail
					for (CventAPI.OrderDetail orderDetail : cventRegistration.OrderDetail){
						if (!sessionToUpsert.containsKey(orderDetail.ProductId)){
							//Salesforce session
							Session__c salesforceSession = cventIdVsSessionMap.containsKey(orderDetail.ProductId) ? cventIdVsSessionMap.get(orderDetail.ProductId) : null;
							Sobject session = new Session__c();
							//Flag for change in field
							Boolean hasChange = false;
							Map<String, Object> cventRecordMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(orderDetail));

							//Field Mappings
							for (String cventField : sessionFieldMappings.keySet()){
								if (cventRecordMap.containsKey(cventField)){
									String salesforceField = sessionFieldMappings.get(cventField);
									Object cventValue = cventRecordMap.get(cventField);

									//If value is empty then move to the next field
									if (cventValue == null || cventValue == ''){

										continue;
									} else{
										if (salesforceSession == null || salesforceSession.get(salesforceField) != cventValue){
											utilityInstance.assignValuesToField(session, salesforceField, cventValue, 'Session__c');
											hasChange = true;
										}
									}
								}

							}
							//If creating new session
							if (salesforceSession == null){
								((Session__c)session).Event_Registration__r = new Event_Registrations__c(Cvent_Registration_Id__c = cventRegistration.Id);

							} else{
								//if updating
								session.Id = salesforceSession.Id;
							}

							//if there is a change in field value or is a new instance for creation
							if (hasChange){
								String sessionCventId = (String)session.get('Cvent_Id__c');
								sessionToUpsert.put(sessionCventId, (Session__c)session);
								sessionCventVsRegistrationCvent.put(sessionCventId, cventRegId);
							}
						}
					}
				}
			}
		}
		System.debug('#--sessionToUpsert--#' + sessionToUpsert.size());
		//Upsert
		if (!sessionToUpsert.isEmpty()){
			//Upsert the Sessions
			List<Session__c> sessionsToUpsertList = sessionToUpsert.values();
			List<Database.UpsertResult> sessionUpsertResults = Database.upsert(sessionsToUpsertList, Schema.Session__c.Id, false);

			Integer countSession = 0;

			for (Database.UpsertResult result : sessionUpsertResults){

				//If unsuccessful
				if (!result.isSuccess()){
					String errorMessage = '';
					for (Database.Error err : result.getErrors()){
						errorMessage += string.valueOf(err.getMessage());
					}
					String regId = sessionCventVsRegistrationCvent.get(sessionsToUpsertList[countSession].Cvent_Id__c);
					Cvent_Registration_Log__c cventLog = cventLogsToUpdate.containsKey(regId) ? cventLogsToUpdate.get(regId) : new Cvent_Registration_Log__c(Sfdc_Upsert_Last_Error__c = '');
					cventLog.Sfdc_Upsert_Last_Error__c += 'Session Related Error : ' + errorMessage;
					cventLog.Successfully_Processed__c = false;
					cventLogsToUpdate.put(regId, cventLog);
				}


				countSession++;
			}

		}
	}

	/**
	 * prepareQuestionAnswerString : Method for preparing a string for eventSurvey Detail as "
	 * Question:
	 * How Old are yoy?
	 * Response:
	 * 20
	 * "
	 * @param  evtSurveyDetail : eventSurveyDetail
	 */
	public static String prepareQuestionAnswerString(CventAPI.EventSurveyDetail evtSurveyDetail){
		String returnString = '\n' + 'Question:' + '\n';
		returnString += evtSurveyDetail.QuestionText + '\n';
		returnString += 'Response:' + '\n';
		returnString += (evtSurveyDetail.AnswerText != null ? String.join(evtSurveyDetail.AnswerText, ',') : '')+'\n';
		return returnString;
	}

	/**
	 * prepareContactToAdd : Method to prepare the contact which is to be mapped to event registration
	 * check if contact exists on alternate email , if not check if lead exists, if yes converts, if not create new contact
	 * @param  listOfContToCreate      : Pass by reference parameter which contains the contacts which is to be inserted
	 * @param  listOfLeadToConvert     : Pass by reference parameter which contains the lead which is to be converted
	 * @param  listOfAlternateEmail    : List of alternateemail ehich will help to get the contact/lead
	 * @param  mapOfSourceVsContactId  : Pass by reference parameter which contains the source or email as key against the contactId/leadid
	 */
	private void prepareContactToAdd(List<Contact> listOfContToCreate, List<Lead> listOfLeadToConvert, List<Alternate_Email__c> listOfAlternateEmail, Map<String, String> mapOfSourceVsContactId){

		//call method for getting a map which has source/email as key against the alternateemail record
		Map<String, Alternate_Email__c> sourceOrEmailVsEmail = getAlternateEmailMap(listOfAlternateEmail);

		//iterate
		for (CventAPI.Registration registration : cventRegistrationWrapperMapLog.values()){
			//Set the key for map
			String key =  registration.EmailAddress.toLowerCase();
			System.debug('#--key--#' + key);

			//Get the alternaterecord against the key
			Alternate_Email__c email = sourceOrEmailVsEmail.containsKey(key) ? sourceOrEmailVsEmail.get(key) : null;
			System.debug('#--email--#' + email);
			if (email != null){
				//call method to get the lead/contact associated with the alternate email
				Id leadContId = getLeadOrContactInstance(email, listOfLeadToConvert, registration.EmailAddress);
				System.debug('#--leadContId--#' + leadContId);

				//map of Source/Email against the lead/contact
				mapOfSourceVsContactId.put(key, leadContId);

			} else{
				/* no contact/lead found, create new */

				Map<String, Object> mapOfRegistrtnDetails = (Map<String, Object>)JSON.deserializeUntyped(cventRegistrationLogMap.get(registration.Id).Cvent_Data__c);
				Contact newContact = new Contact();
				for (String field : contactVsSfFieldMap.keySet()){
					if (mapOfRegistrtnDetails.containsKey(field)){
						String salesforceField = contactVsSfFieldMap.get(field);
						String fieldValue = String.valueOf(mapOfRegistrtnDetails.get(field));
						newContact.put(salesforceField, fieldValue);
					}
				}

				//Additional Fields
				newContact.LeadSource = 'lf-event';
				newContact.Lead_Source_Detail__c = registration.EventTitle;
				newContact.Description = 'Record created from Cvent/Salesforce integration';
				listOfContToCreate.add(newContact);

			}
		}
	}

	/**
	 * getAlternateEmailMap : Method for getting a map which has source/email as key against the alternateemail record
	 * @param  listOfAlternateEmail  : AlternateEmailList
	 */
	private static Map<String, Alternate_Email__c> getAlternateEmailMap(List<Alternate_Email__c> listOfAlternateEmail){
		System.debug('#--listOfAlternateEmail--#' + listOfAlternateEmail.size());
		Map<String, Alternate_Email__c> emailAddressVsAlternateEmailMap = new Map<String, Alternate_Email__c>();

		//loop
		for (Alternate_Email__c alternateEmail : listOfAlternateEmail){
			String email = alternateEmail.Alternate_Email_Address__c;
			System.debug('alternateEmail ' + alternateEmail);
			
				emailAddressVsAlternateEmailMap.put(alternateEmail.Alternate_Email_Address__c, alternateEmail);
			
		}

		return emailAddressVsAlternateEmailMap;
	}

	/**
	 * getLeadOrContactInstance : Method to get the lead/contact Id associated with the alternate email
	 * @param  email : AlternateEmail Record
	 * @param  listOfLeadToConvert :  Pass by reference parameter which contains the lead which is to be converted
	 * @param  emailAddress : cventEmailAddress
	 */
	private static Id getLeadOrContactInstance(Alternate_Email__c email, List<Lead> listOfLeadToConvert, String emailAddress){
		Id leadContactId;
		if (String.isNotBlank(email.Contact_Name__c)){
			leadContactId = email.Contact_Name__c;
		} else if (String.isNotBlank(email.Lead_Name__c)){
			Lead lead = new Lead();
			lead.Id = email.Lead_Name__c;
			lead.Convert_Lead__c = true;
			lead.Cvent_Registration_Email__c = emailAddress;
			listOfLeadToConvert.add(lead);
			leadContactId = email.Lead_Name__c;
		}
		return leadContactId;
	}

	private void generateErrorString(String apiLogId){
		errorCount += 1;
		emailErrorString += errorCount + '. <a href="' + URL.getSalesforceBaseUrl().toExternalForm()+'/' + apiLogId + '"> APIRequest Log - ' + errorCount + '</a> <br/>';
		hasError = true;
	}
}