/*
 Test Class of GetEventFromCvent Class
 */
@isTest
public with sharing class GetEventFromCvent_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@testSetup
	public static void createTestData(){
		Cvent_Integration__c cventIntegration = TestDataUtils.createCventIntegrationSetting(true);

		Project__c project = TestDataUtils.createProject(true, 'The Linux Foundation', 'Event', 'Directed Fund', 'Planned');
		project.Status__c = 'Active';
		project.Funding__c = 'Funded';
		update project;
	}
	/*
	 Test Method batch
	 */
	@IsTest
	static void batchDataTest(){

		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		GetEventFromCvent getEventBatch = new GetEventFromCvent();
		List<CventAPI.Event> cventEventsList = getEventBatch.start(null);
		Database.executeBatch(new GetEventFromCvent(cventEventsList));
		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Event__c
		                        WHERE Cvent_Event_Id__c != null].size(), 'There must be an event');
	}
	@IsTest
	static void batchDataConstructorTest(){

		Cvent_Integration__c cventIntegration = Cvent_Integration__c.getOrgDefaults();
		List<String> statusList = cventIntegration.Event_Statuses__c.split(';');
		DateTime lastSyncedTime = DateTime.now().adddays(-1);
		Project__c project = [SELECT Id
		                      FROM Project__c
		                      WHERE Name = 'The Linux Foundation'];
		Event__c evt = TestDataUtils.createEvent(false, 'TestTitle', 'Unfunded', 'LF Event', 'Planned');
		evt.BillFromProject__c = project.Id;
		evt.Event_Location_Country__c = 'United Kingdom';
		insert evt;
		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		Database.executeBatch(new GetEventFromCvent(statusList, lastSyncedTime));
		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Event__c
		                        WHERE Cvent_Event_Id__c != null].size(), 'There must be an event');
	}
	@IsTest
	static void schedularTest(){


		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		GetEventFromCvent getEventBatch = new GetEventFromCvent();
		getEventBatch.execute(null);
		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Event__c
		                        WHERE Cvent_Event_Id__c != null].size(), 'There must be an event');
	}
	/*
	 Test Method for GetEventFromCvent batch for exception
	 */
	@isTest
	static void getEventFromCventExceptionTest(){

		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Cvent_Integration__c cventIntegration = Cvent_Integration__c.getOrgDefaults();
		cventIntegration.Cvent_Password__c = 'expired';
		update cventIntegration;
		Test.startTest();
		Database.executeBatch(new GetEventFromCvent());
		Test.stopTest();
		System.assertEquals(false, [select id, Source__c, Request_Body__c, createddate
		                            from API_Request__c
		                            where source__c like '%cvent%'].isEmpty(), 'There must be a record');
	}
	/*
	 Test Method for GetEventFromCvent batch for exception
	 */
	@isTest
	static void getEventFromCventExceptionTest1(){

		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Cvent_Integration__c cventIntegration = Cvent_Integration__c.getOrgDefaults();
		cventIntegration.Cvent_Password__c = 'SearchEvent';
		update cventIntegration;
		Test.startTest();
		Database.executeBatch(new GetEventFromCvent());
		Test.stopTest();
		System.assertNotEquals(null, [select id, Sfdc_Upsert_Last_Error__c
		                            from Cvent_Registration_Log__c
		                            where Type__c ='Event' LIMIT 1].Sfdc_Upsert_Last_Error__c, 'There must be a error on cvent Log record');
	}
}