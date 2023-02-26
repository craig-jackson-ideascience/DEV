/**
 * Test class for CventSync
 * @author Cloudroute Solutions
 */
@isTest
public class CventSync_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@testSetup
	static void testCreateData(){

		Cvent_Integration__c cventIntegration = TestDataUtils.createCventIntegrationSetting(true);

		//Account
		Account account = TestDataUtils.createAccount(true, 'Test Account');

		//Contact
		Contact contact = new Contact();
		contact.AccountId = account.Id;
		contact.FirstName = 'unknown';
		contact.LastName = 'unknown';
		contact.Email = 'testUnknown@noreply.com';
		insert contact;

		//Project
		Project__c project = TestDataUtils.createProject(true, 'The Linux Foundation', 'Event', 'Directed Fund', 'Planned');
		project.Status__c = 'Active';
		project.Funding__c = 'Funded';
		update project;

		//Event
		Event__c event = new Event__c(Name = 'Test Event', Category__c = 'Project Event', BillFromProject__c = project.Id, Cvent_Event_Id__c = 'TestCventId123444');
		insert event;

		//Event Registration
		Event_Registrations__c eventReg = new Event_Registrations__c();
		eventReg.Name = 'Test eventReg';
		eventReg.Contact__c = contact.Id;
		eventReg.Event__c = event.Id;
		eventReg.Cvent_Registration_Id__c = 'testventregistraion56789';
		eventReg.Cvent_Registration_FirstName__c = 'test FirstName';
		eventReg.Cvent_Registration_LastName__c = 'test LastName';
		eventReg.Data_Source__c = 'Manual Entry';
		insert eventReg;
	}

	/**
	 * getFileName_test : Test Method for the getFileName - which retuens the filename for the event
	 */
	@isTest
	static void getFileName_test(){
		Test.startTest();
		Event__c event = [SELECT Id
		                  FROM Event__c
		                  LIMIT 1];
		String returnedResponse = CventSync.getFileName(event.Id);

		//Asserts
		System.assertEquals('Test Event Missing Event Registrations File', returnedResponse,'Must contains "Missing Event Registrations File" as string');
		Test.stopTest();
	}

	/**
	 * getEventRegistrationIds_test : Test Method for the getEventRegistrationIds - which retuens the EventRegistrations for the event
	 */
	@isTest
	static void getEventRegistrationIds_test(){

		//Test
		Test.startTest();
		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Event__c event = [SELECT Id
		                  FROM Event__c
		                  LIMIT 1];
		String returnedString = CventSync.getCventData(event.Id);
		Test.stopTest();

		//Asserts
		System.assertEquals('success', returnedString,'Something went wrong');
	}
}