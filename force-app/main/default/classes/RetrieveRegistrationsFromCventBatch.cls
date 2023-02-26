/**
 * RetrieveRegistrationsFromCventBatch : Batch Class for retrieving Registrations from Cvent System and put into the Log Object of salesforce
 * Database.executeBatch(new RetrieveRegistrationsFromCventBatch());
 * Test Class - CventCalloutUtility_Test class
 */
public class RetrieveRegistrationsFromCventBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
	//Class variables
	public CventCalloutUtility cventUtility = new CventCalloutUtility();
	public static Utility utilityInstance = new Utility();
	public String cventSessionHeader = '';
	public Cvent_Integration__c cventIntegration = Cvent_Integration__c.getOrgDefaults();
	public string query = '';
	public Boolean hasError = false;
	public Integer errorCount = 0;
	public String emailErrorString = '<p> RetrieveRegistrationsFromCventBatch Class has failed with the following error(s) populated on API Request Log Records: <br/></p>';
	//Constructor
	public RetrieveRegistrationsFromCventBatch(){
	}

	public RetrieveRegistrationsFromCventBatch(String runQuery){
		this.query = runQuery;
	}

	//Start of batch
	public Database.QueryLocator start(Database.BatchableContext bc){
		/* try{ */
			//Login
			cventSessionHeader = cventUtility.cventLogin();
			/* query cvent registration logs */
			if (String.isEmpty(query)){
				query = 'SELECT Id, Cvent_Id__c FROM Cvent_Registration_Log__c WHERE Cvent_Id__c != null AND Retrieved__c = null AND Type__c = \'Registration\' AND (Read_Write_Count__c < 3 OR Read_Write_Count__c = null)';
			}
			return Database.getQueryLocator(query);

		/* } catch (Exception e){
			System.debug('Exception: ' + e + ', Message: ' + e.getMessage()+', Line Number: ' + e.getLineNumber()+'\n' + e.getStackTraceString());
			String errorMessage = '#--Exception at--#' + e.getLineNumber()+' ' + e.getMessage()+' ' + e.getStackTraceString();
			String apiLogId = APIRequestLog.createApiRequestlog(errorMessage, 'Cvent - RetrieveRegistrationsFromCventBatch Start Error');
			generateErrorString(apiLogId);

		}
		return null; */
	}

	//Execute of batch
	public void execute(Database.BatchableContext bc, List<Cvent_Registration_Log__c> records){


		try{
			system.debug('cventSessionHeader ' + cventSessionHeader);
			if (String.isNotEmpty(cventSessionHeader) && !cventSessionHeader.contains('Error : ')){

				CventAPI.IdArray registrationIdArray = new CventAPI.IdArray();
				Set<String> registrationIdList = new Set<String>();
				for (Cvent_Registration_Log__c cventRegistration : records){
					registrationIdList.add(cventRegistration.Cvent_Id__c);
				}

				registrationIdArray.Id = new List<String>(registrationIdList);

				List<CventAPI.Registration> registrationList;
				//Retrieve Try-Catch block
				try{
					//Retrieve Registrations
					registrationList = cventUtility.retrieveRegistrations(registrationIdArray, cventSessionHeader);

				} catch (Exception e){
					System.debug('Exception: ' + e + ', Message: ' + e.getMessage()+', Line Number: ' + e.getLineNumber()+'\n' + e.getStackTraceString());
					if (e.getMessage().contains('SESSION_EXPIRED')){
						//Login-Again for session Header
						cventSessionHeader = cventUtility.cventLogin();
						registrationList = cventUtility.retrieveRegistrations(registrationIdArray, cventSessionHeader);
					} else{
						String apiLogId = APIRequestLog.createApiRequestlog(e.getMessage(), 'Cvent - RetrieveRegistrationsFromCventBatch Execute Error While retrieving registrations');
						generateErrorString(apiLogId);


					}
				}

				if (registrationList != null){
					List<Cvent_Registration_Log__c> registrationLogsToUpsert = new List<Cvent_Registration_Log__c>();

					Set<String> cventContactIdSet = new Set<String>();
					//Iterate on registration and create a set of cventcontactId
					for (CventAPI.Registration cventRegistration : registrationList){
						if (String.isNotBlank(cventRegistration.ContactId)){
							cventContactIdSet.add(cventRegistration.ContactId);
						}
					}
					CventAPI.ArrayOfContact contactArrayResult = new CventAPI.ArrayOfContact();
					Map<String, String> cventContactMap = new Map<String, String>();

					//If cventcontactid set is not empty then retrieve the contacts from cvent
					if (!cventContactIdSet.isEmpty()){
						CventAPI.IdArray contactIdArray = new CventAPI.IdArray();
						contactIdArray.Id = new List<String>(cventContactIdSet);
						CventAPI.V200611Soap api = new CventAPI.V200611Soap();
						api.CventSessionHeader = new CventAPI.CventSessionHeader();
						api.CventSessionHeader.CventSessionValue = cventSessionHeader;
						//Retrieve Contacts Try-Catch block
						try{
							//Retrieve Contacts
							contactArrayResult = api.RetrieveContacts(contactIdArray);

						} catch (Exception e){
							System.debug('Exception: ' + e + ', Message: ' + e.getMessage()+', Line Number: ' + e.getLineNumber()+'\n' + e.getStackTraceString());
							if (e.getMessage().contains('SESSION_EXPIRED')){
								//Login-Again for session Header
								cventSessionHeader = cventUtility.cventLogin();
								api.CventSessionHeader.CventSessionValue = cventSessionHeader;

								//Retrieve Contacts
								contactArrayResult = api.RetrieveContacts(contactIdArray);
							} else{
								String apiLogId = APIRequestLog.createApiRequestlog(e.getMessage(), 'Cvent - RetrieveRegistrationsFromCventBatch Execute Error While retrieving contacts');
								generateErrorString(apiLogId);


							}
						}
						if (contactArrayResult != null && contactArrayResult.Contact != null){

							//Iterate and create a map of Cvent ContactId Vs CventData
							for (CventAPI.Contact contact : contactArrayResult.Contact){
								cventContactMap.put(contact.Id, JSON.serialize(contact));
							}
						}
					}
					System.debug('#--registrationList--#' + registrationList.size());
					//Iterate on Registrations
					for (CventAPI.Registration cventRegistration : registrationList){

						//Does Id contains in the list which is been used for reterieve
						if (registrationIdList.contains(cventRegistration.Id)){
							//Procss the cvent data to field of log instance
							String cventData = JSON.serialize(cventRegistration);
							Cvent_Registration_Log__c cventRegistrationLog = new Cvent_Registration_Log__c(Cvent_Id__c = cventRegistration.Id, Cvent_Data__c = cventData, Retrieved__c = DateTime.now());
							if (cventContactMap.containsKey(cventRegistration.contactId)){
								cventRegistrationLog.Cvent_Contact_Details__c = cventContactMap.get(cventRegistration.contactId);
								cventRegistrationLog.Read_Write_Count__c = cventRegistrationLog.Read_Write_Count__c != null ? cventRegistrationLog.Read_Write_Count__c + 1 : 1;
							}
							System.debug('cventRegistrationLog ' + cventRegistrationLog);
							registrationLogsToUpsert.add(cventRegistrationLog);
							registrationIdList.remove(cventRegistration.Id);
						}

					}

					//Iterate on list and if it is not retrieved then increment the read/write count
					for (String cventId : registrationIdList){
						Cvent_Registration_Log__c cventRegistrationLog = new Cvent_Registration_Log__c(Cvent_Id__c = cventId, Cvent_Data__c = '');
						cventRegistrationLog.Read_Write_Count__c = cventRegistrationLog.Read_Write_Count__c != null ? cventRegistrationLog.Read_Write_Count__c + 1 : 1;
						registrationLogsToUpsert.add(cventRegistrationLog);

					}
					System.debug('#--registrationLogsToUpsert--#' + registrationLogsToUpsert.size());

					//Upsert

					if (!registrationLogsToUpsert.isEmpty()){
						List<Database.UpsertResult> upsertResults = Database.upsert(registrationLogsToUpsert, Schema.Cvent_Registration_Log__c.Cvent_Id__c, false);

					}
				}
			} else{
				String apiLogId = APIRequestLog.createApiRequestlog(cventSessionHeader, 'Cvent - RetrieveRegistrationsFromCventBatch Execute Error while logging in');
				generateErrorString(apiLogId);


			}
		} catch (Exception e){
			System.debug('Exception: ' + e + ', Message: ' + e.getMessage()+', Line Number: ' + e.getLineNumber()+'\n' + e.getStackTraceString());
			String errorMessage = '#--Exception at--#' + e.getLineNumber()+' ' + e.getMessage()+' ' + e.getStackTraceString();
			String apiLogId = APIRequestLog.createApiRequestlog(errorMessage, 'Cvent - RetrieveRegistrationsFromCventBatch Execute Error');
			generateErrorString(apiLogId);

		}
	}

	//Finish of batch
	public void finish(Database.BatchableContext bc){
		if (hasError){
			cventUtility.sendErrorMail('RetrieveRegistrationsFromCventBatch Class Error', emailErrorString);
		}
		//Call betch for processing the log records to registration records
		Database.executeBatch(new CventRegistrationBatch(), 80);
	}

	private void generateErrorString(String apiLogId){
		errorCount += 1;
		emailErrorString += errorCount + '. <a href="' + URL.getSalesforceBaseUrl().toExternalForm()+'/' + apiLogId + '"> APIRequest Log - ' + errorCount + '</a> <br/>';
		hasError = true;
	}
}