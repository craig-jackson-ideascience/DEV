/**
 * SearchCventRegistrationBatch : Batch Class for Searching Registration from Cvent System and put into the salesforce Log Object
 * Database.executeBatch(new SearchCventRegistrationBatch(),50) - Need to be run with the scope of 50
 * Batch is scheduled for every 15 minutes
 * Test Class - CventCalloutUtility_Test class
 */
public class SearchCventRegistrationBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful, Schedulable{
	//Class variables
	public CventCalloutUtility cventUtility = new CventCalloutUtility();
	public static Utility utilityInstance = new Utility();
	public String cventSessionHeader = '';
	public Cvent_Integration__c cventIntegration = Cvent_Integration__c.getOrgDefaults();
	public String lastSyncedTime = cventUtility.getESTDateTime(cventIntegration.Registration_Last_Synced__c);
	public Boolean hasError = false;
	public Integer errorCount = 0;
	public String emailErrorString = '<p> SearchCventRegistrationBatch Class has failed with the following error(s) populated on API Request Log Records: <br/></p>';
	public SearchCventRegistrationBatch(){
	}

	//Schedule 's Execute method to call batch
	public void execute(SchedulableContext sc){
		Database.executeBatch(new SearchCventRegistrationBatch(), 50);
	}

	//Start of Batch
	public List<String> start(Database.BatchableContext bc){

		List<CventAPI.Event> cventEventsList = new List<CventAPI.Event>();
		List<String> eventIdStringList = new List<String>();
		try{
			
			//Login
			cventSessionHeader = cventUtility.cventLogin();

			if (String.isNotEmpty(cventSessionHeader) && !cventSessionHeader.contains('Error : ')){

				//Active and completed Status String List
				List<String> statusList = cventIntegration.Event_Statuses__c.split(';');

				//LastModified Filter
				Integer month = Integer.valueOf(cventIntegration.Events_Retrieval_Months__c);
				DateTime sixMonthsBackDate = cventUtility.convertDateToDateTime(System.today().addMonths(-month));

				//Search Events
				CventAPI.IdArray eventIdArray = cventUtility.searchEvents(cventSessionHeader, statusList, sixMonthsBackDate);

				if (eventIdArray != null){
					eventIdStringList.addAll(eventIdArray.Id);
				}
			} else{
				String apiLogId = APIRequestLog.createApiRequestlog(cventSessionHeader, 'Cvent - SearchCventRegistrationBatch Start Error while logging in');
				generateErrorString(apiLogId);


			}
		} catch (Exception e){
			System.debug('Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());

			String errorMessage = '#--Exception at--#' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString();
			String apiLogId = APIRequestLog.createApiRequestlog(errorMessage, 'Cvent - SearchCventRegistrationBatch Start Error');
			generateErrorString(apiLogId);


		}
		return eventIdStringList;
	}

	//Execute of Batch
	public void execute(Database.BatchableContext bc, List<String> scope){

		try{
			System.debug('lastSyncedTime ' + lastSyncedTime);
			if (String.isNotEmpty(cventSessionHeader) && !cventSessionHeader.contains('Error : ')){

				CventAPI.IdArray registrationIdArray;

				//Search Try-Catch block
				try{
					//Search Registrations
					registrationIdArray = cventUtility.searchRegistrations(scope, lastSyncedTime, cventSessionHeader);

				} catch (Exception e){
					System.debug('Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());
					if (e.getMessage().contains('SESSION_EXPIRED')){
						//Login-Again for session Header
						cventSessionHeader = cventUtility.cventLogin();
						registrationIdArray = cventUtility.searchRegistrations(scope, lastSyncedTime, cventSessionHeader);
					} else{
						String apiLogId = APIRequestLog.createApiRequestlog(e.getMessage(), 'Cvent - SearchCventRegistrationBatch Execute Error While searching registrations');
						generateErrorString(apiLogId);


					}

				}

				if (registrationIdArray != null){

					List<Cvent_Registration_Log__c> registrationLogsToUpsert = cventUtility.getCventLogsToInsertRecords(registrationIdArray.Id);

					//Upsert
					if (!registrationLogsToUpsert.isEmpty()){
						Database.upsert (registrationLogsToUpsert, Cvent_Registration_Log__c.Fields.Cvent_Id__c, false);
					}
				}
			} else{
				String apiLogId = APIRequestLog.createApiRequestlog(cventSessionHeader, 'Cvent - SearchCventRegistrationBatch Execute Error while logging in');
				generateErrorString(apiLogId);


			}
		} catch (Exception e){
			System.debug('Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());

			String errorMessage = '#--Exception at--#' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString();
			String apiLogId = APIRequestLog.createApiRequestlog(errorMessage, 'Cvent - SearchCventRegistrationBatch Execute Error');
			generateErrorString(apiLogId);

		}
	}

	//Finish of batch
	public void finish(Database.BatchableContext bc){


		if (hasError){
			cventUtility.sendErrorMail('SearchCventRegistrationBatch Class Error', emailErrorString);
		} else{
			//Update Event Registration Last syncing time on custom setting
			Cvent_Integration__c updationSetting = new Cvent_Integration__c();
			updationSetting.Id = cventIntegration.Id;
			updationSetting.Registration_Last_Synced__c = DateTime.now();
			update updationSetting;
		}
		//Call Retrieve batch for retrieving registration details from cvent
		if (!Test.isRunningTest()){
			Integer batchSize = cventIntegration.Retrieve_Batch_Size__c != null ? Integer.valueOf(cventIntegration.Retrieve_Batch_Size__c) : 200;
			Database.executeBatch(new RetrieveRegistrationsFromCventBatch(), batchSize);
		}
	}

	private void generateErrorString(String apiLogId){
		errorCount += 1;
		emailErrorString += errorCount + '. <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + apiLogId + '"> APIRequest Log - ' + errorCount + '</a> <br/>';
		hasError = true;
	}
}