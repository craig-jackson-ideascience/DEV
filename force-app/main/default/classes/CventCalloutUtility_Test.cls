@isTest
public with sharing class CventCalloutUtility_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@testSetup
	public static void createTestData(){
		Cvent_Integration__c cventIntegration = TestDataUtils.createCventIntegrationSetting(true);
	}
	/*
	 Test Method for SearchCventRegistrationBatch batch
	 */
	@isTest
	static void SearchCventRegistrationBatchTest(){

		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		Database.executeBatch(new SearchCventRegistrationBatch());
		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Cvent_Registration_Log__c
		                        WHERE Cvent_Id__c != null].size(), 'There must be a record');
	}
	/*
	 Test Method for SearchCventRegistrationBatch batch for schedular
	 */
	@isTest
	static void SearchCventRegistrationSchedularTest(){

		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		SearchCventRegistrationBatch searchBatch = new SearchCventRegistrationBatch();
		searchBatch.execute(null);
		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Cvent_Registration_Log__c
		                        WHERE Cvent_Id__c != null].size(), 'There must be a record');
	}
	/*
	 Test Method for SearchCventRegistrationBatch batch for exception
	 */
	@isTest
	static void SearchBatchExceptionTest(){

		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Cvent_Integration__c cventIntegration = Cvent_Integration__c.getOrgDefaults();
		cventIntegration.Cvent_Password__c = 'expired';
		update cventIntegration;
		Test.startTest();
		try{
			Database.executeBatch(new SearchCventRegistrationBatch());
		} catch (Exception e){
		}
		Test.stopTest();
		System.assertEquals(false, [select id, Source__c, Request_Body__c, createddate
		                            from API_Request__c
		                            where source__c like '%cvent%'].isEmpty(), 'There must be a record');
	}
	/*
	 Test Method for SearchCventRegistrationBatch batch for exception
	 */
	@isTest
	static void SearchBatchExceptionTest1(){

		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Cvent_Integration__c cventIntegration = Cvent_Integration__c.getOrgDefaults();
		cventIntegration.Cvent_Password__c = 'TestSearch';
		update cventIntegration;
		Test.startTest();
		try{
			Database.executeBatch(new SearchCventRegistrationBatch());
		} catch (Exception e){
		}
		Test.stopTest();
		System.assertEquals(false, [select id, Source__c, Request_Body__c, createddate
		                            from API_Request__c
		                            where source__c like '%cvent%'].isEmpty(), 'There must be a record');
	}
	/*
	 Test Method for SearchCventRegistrationBatch batch for exception
	 */
	@isTest
	static void SearchBatchExceptionTest2(){

		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Cvent_Integration__c cventIntegration = Cvent_Integration__c.getOrgDefaults();
		cventIntegration.Cvent_Password__c = 'error';
		update cventIntegration;
		Test.startTest();
		try{
			Database.executeBatch(new SearchCventRegistrationBatch());
		} catch (Exception e){
		}
		Test.stopTest();
		System.assertEquals(false, [select id, Source__c, Request_Body__c, createddate
		                            from API_Request__c
		                            where source__c like '%cvent%'].isEmpty(), 'There must be a record');
	}
	/*
	 Test Method for RetrieveRegistrationsFromCventBatch
	 */
	@isTest
	static void RetrieveRegistrationsFromCventBatchTest(){
		Cvent_Registration_Log__c cventRegistrationLog = TestDataUtils.createCventRegistrationLog(true, 'TestSearchId45768', 'Registration');
		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		Database.executeBatch(new RetrieveRegistrationsFromCventBatch());
		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Cvent_Registration_Log__c
		                        WHERE Retrieved__c != null].size(), 'There must be a record');
	}
	/*
	 Test Method for RetrieveRegistrationsFromCventBatch batch for exception
	 */
	@isTest
	static void RetrieveBatchExceptionTest(){

		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Cvent_Integration__c cventIntegration = Cvent_Integration__c.getOrgDefaults();
		cventIntegration.Cvent_Password__c = 'exception';
		update cventIntegration;
		Cvent_Registration_Log__c cventRegistrationLog = TestDataUtils.createCventRegistrationLog(true, 'TestSearchId45768', 'Registration');
		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		String query = 'SELECT Id, Cvent_Id__c FROM Cvent_Registration_Log__c WHERE Cvent_Id__c != null AND Retrieved__c = null AND Type__c = \'Registration\'';
		Database.executeBatch(new RetrieveRegistrationsFromCventBatch(query));
		Test.stopTest();
		System.assertEquals(true, ![select id, Source__c, Request_Body__c, createddate
		                            from API_Request__c
		                            where source__c like '%cvent%'].isEmpty(), 'There must be a record');
	}
	/*
	 Test Method for RetrieveRegistrationsFromCventBatch batch for exception
	 */
	@isTest
	static void RetrieveBatchExceptionTest1(){

		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Cvent_Registration_Log__c cventRegistrationLog = TestDataUtils.createCventRegistrationLog(true, 'TestSessionExpired', 'Registration');
		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		String query = 'SELECT Id, Cvent_Id__c FROM Cvent_Registration_Log__c WHERE Cvent_Id__c != null AND Retrieved__c = null AND Type__c = \'Registration\'';
		Database.executeBatch(new RetrieveRegistrationsFromCventBatch(query));
		Test.stopTest();
		System.assertEquals(true, ![select id, Source__c, Request_Body__c, createddate
		                            from API_Request__c
		                            where source__c like '%cvent%'].isEmpty(), 'There must be a record');
	}
	/*
	 Test Method for RetrieveRegistrationsFromCventBatch batch for exception
	 */
	@isTest
	static void RetrieveBatchExceptionTest2(){

		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Cvent_Registration_Log__c cventRegistrationLog = TestDataUtils.createCventRegistrationLog(true, 'TestSessionExpiredForContact', 'Registration');
		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		String query = 'SELECT Id, Cvent_Id__c FROM Cvent_Registration_Log__c WHERE Cvent_Id__c != null AND Retrieved__c = null AND Type__c = \'Registration\'';
		Database.executeBatch(new RetrieveRegistrationsFromCventBatch(query));
		Test.stopTest();
		System.assertEquals(true, ![select id, Source__c, Request_Body__c, createddate
		                            from API_Request__c
		                            where source__c like '%cvent%'].isEmpty(), 'There must be a record');
	}
	/*
	 Test Method for batch : when there is no record in salesforce with the registration email
	 */
	@isTest
	static void noRecordInSFWithEmail_Test(){
		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		testDataForCventRegistrationBatch();

		Database.executeBatch(new RetrieveRegistrationsFromCventBatch());

		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Event_registrations__c
		                        WHERE Cvent_Registration_Id__c != null].size(), 'There must be an event registration');
	}
	/*
	 Test Method for CventRegistrationBatch Exception on cventLog record
	 */
	@isTest
	static void CventRegistrationError_Test(){
		Cvent_Registration_Log__c cventRegistrationLog = TestDataUtils.createCventRegistrationLog(true, 'TestWrongEmail', 'Registration');
		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		Database.executeBatch(new RetrieveRegistrationsFromCventBatch());
		Test.stopTest();
		System.assertNotEquals(null, [SELECT Id, Sfdc_Upsert_Last_Error__c
		                              FROM Cvent_Registration_Log__c
		                              WHERE Cvent_Id__c = 'TestWrongEmail'].Sfdc_Upsert_Last_Error__c, 'Error must be populated on cventLog Record');
	}
	/*
	 Test Method for CventRegistrationBatch Exception on cventLog record for contact details
	 */
	@isTest
	static void CventRegistrationErrorForContact_Test(){
		Cvent_Registration_Log__c cventRegistrationLog = TestDataUtils.createCventRegistrationLog(true, 'TestWrongContact', 'Registration');
		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		Database.executeBatch(new RetrieveRegistrationsFromCventBatch());
		Test.stopTest();
		System.assertNotEquals(null, [SELECT Id, Sfdc_Upsert_Last_Error__c
		                              FROM Cvent_Registration_Log__c
		                              WHERE Cvent_Id__c = 'TestWrongContact'].Sfdc_Upsert_Last_Error__c, 'Error must be populated on cventLog Record for contact details');
	}
	/*
	 Test Method for batch : when there is contact record in salesforce with the registration email
	 */
	@isTest
	static void contactRecordWithEmail_Test(){
		Test.setMock(WebServiceMock.class, new CventSyncMock());


		//Account
		Account account = TestDataUtils.createAccount(false, 'Test Account');
		account.billingCountry = 'brasil';
		account.billingStreet = 'new';
		insert account;

		//Contact
		Contact con = new Contact(lastname = 'testContact', email = 'test@email.com', accountid = account.id);
		insert con;
		Test.startTest();
		testDataForCventRegistrationBatch();

		Database.executeBatch(new RetrieveRegistrationsFromCventBatch());

		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Event_registrations__c
		                        WHERE Cvent_Registration_Id__c != null AND Contact__c = :con.Id].size(), 'There must be an event registration');
	}
	/*
	 Test Method for batch : when there is lead record in salesforce with the registration email
	 */
	@isTest
	static void leadRecordWithEmail_Test(){
		Test.setMock(WebServiceMock.class, new CventSyncMock());

		Account anonAccount = TestDataUtils.createAccount(true, 'Individual - No Account');

		Lead lead1 = TestDataUtils.createLead(true, 'TESTING 1', 'Test Lead 1', 'test 1', null, 'test@email.com');

		Test.startTest();
		testDataForCventRegistrationBatch();

		Database.executeBatch(new RetrieveRegistrationsFromCventBatch());


		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Event_registrations__c
		                        WHERE Cvent_Registration_Id__c != null].size(), 'There must be an event registration');
	}
	/*
	 Test Method for DeleteSuccessfulRegistrationLogsBatch batch
	 */
	@isTest
	static void deletionCventLogs_Test(){
		Test.setMock(WebServiceMock.class, new CventSyncMock());

		Cvent_Registration_Log__c cventRegistrationLog = TestDataUtils.createCventRegistrationLog(false, 'TestSearchId45768', 'Registration');
		cventRegistrationLog.retrieved__c = Datetime.now();
		cventRegistrationLog.Successfully_Processed__c = true;
		insert cventRegistrationLog;
		/* Datetime sevendaysBack = Datetime.now().addDays(-8);
		 Test.setLastModifiedDate(cventRegistrationLog.Id, sevendaysBack);
		 */
		String query = 'SELECT Id FROM Cvent_Registration_Log__c WHERE Retrieved__c != null AND Successfully_Processed__c = true';
		Test.startTest();

		Database.executeBatch(new DeleteSuccessfulRegistrationLogsBatch(query));

		Test.stopTest();
		System.assertEquals(0, [SELECT Id
		                        FROM Cvent_Registration_Log__c
		                        WHERE Retrieved__c != null AND Successfully_Processed__c = true].size(), 'There must not be an Cvent_Registration_Log__c record');
	}
	/*
	 Test Method for DeleteSuccessfulRegistrationLogsBatch batch
	 */
	@isTest
	static void deletionSchedular(){
		Test.setMock(WebServiceMock.class, new CventSyncMock());

		Cvent_Registration_Log__c cventRegistrationLog = TestDataUtils.createCventRegistrationLog(false, 'TestSearchId45768', 'Registration');
		cventRegistrationLog.retrieved__c = Datetime.now();
		cventRegistrationLog.Successfully_Processed__c = true;
		insert cventRegistrationLog;

		Test.startTest();

		DeleteSuccessfulRegistrationLogsBatch deleteBatch = new DeleteSuccessfulRegistrationLogsBatch();
		deleteBatch.execute(null);

		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Cvent_Registration_Log__c
		                        WHERE Retrieved__c != null AND Successfully_Processed__c = true].size(), 'There must be an Cvent_Registration_Log__c record');
	}
	/*
	 Test Method for DeleteSuccessfulRegistrationLogsBatch batch
	 */
	@isTest
	static void deletionSchedularTest(){
		Test.setMock(WebServiceMock.class, new CventSyncMock());

		Cvent_Registration_Log__c cventRegistrationLog = TestDataUtils.createCventRegistrationLog(false, 'TestSearchId45768', 'Registration');
		cventRegistrationLog.retrieved__c = Datetime.now();
		cventRegistrationLog.Successfully_Processed__c = true;
		insert cventRegistrationLog;

		Test.startTest();

		Database.executeBatch(new DeleteSuccessfulRegistrationLogsBatch());

		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Cvent_Registration_Log__c
		                        WHERE Retrieved__c != null AND Successfully_Processed__c = true].size(), 'There must be an Cvent_Registration_Log__c record');
	}

	/*
	 * Helper Method for Creation of Cvent_Registration_Log__c
	 */
	public static void testDataForCventRegistrationBatch(){
		Cvent_Registration_Log__c cventRegistrationLog = TestDataUtils.createCventRegistrationLog(true, 'TestSearchId45768', 'Registration');
		Project__c project = TestDataUtils.createProject(true, 'The Linux Foundation', 'Event', 'Directed Fund', 'Planned');

		Event__c evt = TestDataUtils.createEvent(false, 'Test Event', 'Unfunded', 'Project Event', 'Planned');
		evt.Cvent_Event_Id__c = 'TestEventId';
		evt.Registration_Source__c = 'Cvent';
		insert evt;
	}
}