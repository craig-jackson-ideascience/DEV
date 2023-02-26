/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 15-11-2019.
 * Description: EventTriggerHandlerTest
 * Modified - April 2021 @Cloudroute Solutions
 ********************************************************/
@isTest
public class EventTriggerHandlerTest{
	/**
	 * TestSetup inserting required data for test class
	 */
	@TestSetup
	static void createTestData(){
		Project__c project = TestDataUtils.createProject(true, 'The Linux Foundation', 'Event', 'Directed Fund', 'Planned');
		project.Status__c = 'Active';
		project.Funding__c = 'Funded';
		update project;
	}

	/**
	 * Test UseCase for Not Creating EMS On LF Event Insertion
	 */
	@isTest
	public static void noEMSCreationForLFEvent_Test(){

		Test.startTest();
		Project__c project = [SELECT Id
		                      FROM Project__c
		                      WHERE Name = 'The Linux Foundation'];
		Event__c evt = TestDataUtils.createEvent(false, 'Test Event', 'Unfunded', 'LF Event', 'Planned');
		evt.BillFromProject__c = project.Id;
        evt.Event_Location_Country__c = 'United Kingdom';
		insert evt;
		Test.stopTest();

		//Asserts
		System.assertEquals(0, [SELECT count()
		                        From EMS__c ],'No Record should return');
		delete evt;
	}

	/**
	 * Test UseCase for Creating EMS On Project Event Insertion
	 */
	@isTest
	public static void emsCreationForProjectEventOnInsert_Test(){
		Test.startTest();
		Project__c project = [SELECT Id
		                      FROM Project__c
		                      WHERE Name = 'The Linux Foundation'];
		Event__c evt = new Event__c(Name = 'Test Event', Category__c = 'Project Event');
		evt.BillFromProject__c = project.Id;
        evt.Event_Location_Country__c = 'United Kingdom';
		insert evt;
		Test.stopTest();
		System.assertEquals(1, [SELECT count()
		                        From EMS__c ],'List must contain 1 record');
	}

	/**
	 * test method for automateEMSCreation on Updation of event
	 */
	@isTest
	public static void automateEMSCreationOnUpdate_Test(){
		Test.startTest();
		Project__c project = [SELECT Id
		                      FROM Project__c
		                      WHERE Name = 'The Linux Foundation'];
		Event__c evt = TestDataUtils.createEvent(false, 'Test Event', 'Unfunded', 'LF Event', 'Planned');
		evt.BillFromProject__c = project.Id;
        evt.Event_Location_Country__c = 'United Kingdom';
		insert evt;
		evt.Category__c = 'Project Event';
		update evt;
		Test.stopTest();
		System.assertEquals(1, [SELECT count()
		                        From EMS__c ],'List must contain 1 record');
	}

	/**
	 * test method for updateEms
	 */
	@isTest
	public static void updateEms_Test(){
		Test.startTest();
		ID projectAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Project Account').getRecordTypeId();
		Account account = new Account(Name = 'The Linux Foundation', RecordTypeId = projectAccountRecordTypeId);
		insert account;
		Project__c parentProject = [SELECT Id
		                            FROM Project__c
		                            WHERE Name = 'The Linux Foundation'];
		parentProject.Project_Type__c = 'Project Group';
        parentProject.Slug__c = 'parentproject';
		update parentProject;

		Project__c project = TestDataUtils.createProject(false, 'TestProject', 'Event', 'Directed Fund', 'Planned');
        project.Slug__c = 'test_slug';
		project.Status__c = 'Active';
		project.Funding__c = 'Funded';
		project.Parent_Project__c = parentProject.Id;
		insert project;

		Event__c evt = new Event__c(Name = 'Test Ecvent', Category__c = 'Project Event');
		evt.BillFromProject__c = project.Id;
        evt.Event_Location_Country__c = 'United States';
		insert evt;
		evt.BillFromProject__c = parentProject.Id;
		update evt;
		Test.stopTest();
		//AssertsTest.stopTest();
		System.assertEquals(account.Id, [SELECT Bill_To_Account__c
		                                 From EMS__c
		                                 LIMIT 1].Bill_To_Account__c,'AccountId should be \''+account.Id+'\'');
	}
}