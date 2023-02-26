@isTest
public class SOStatusUpdateFromNSBatchTest{
	@isTest
	static void testCallout1(){

		Endpoints__c endPoint = new Endpoints__c();
		endPoint.Name = 'To Get Sales Order ID From NS';
		endPoint.Endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=39&deploy=1';
		endPoint.Password__c = 'jYdpn8sp22F8C45b';
		endPoint.User_Id__c = 'nsapi@linuxfoundation.org';
		endPoint.Nlauth_Account__c = '4010327_SB1';
		insert endPoint;

		Account account = new Account();
		account.Name = 'Test Account';
		insert account;

		Contact contact = new Contact();
		contact.AccountId = account.Id;
		contact.LastName = 'Test Contact';
		contact.Email = 'testContact@noReply.com';
		insert contact;

		Project__c project = new Project__c();
		project.Name = 'The Linux Foundation';
		project.Category__c = 'Separately Incorporated';
		project.Funding__c = 'Funded';
		project.Status__c = 'Active';
        project.Slug__c = 'testing';
        project.Model__c = 'Alternate Funding';
		insert project;

		Event__c event = new Event__c();
		event.Name = 'Test event';
		event.BillFromProject__c = project.Id;
		event.Category__c = 'LF Event';
		insert event;

		EMS__c ems = new EMS__c();
		ems.Name = 'Test Hotel Commissions';
		ems.Amount__c = 123;
		ems.Bill_To_Account__c = account.Id;
		ems.Contact__c = contact.Id;
		ems.Description__c = 'Test Description';
		ems.StartDate__c = System.today();
		ems.Event__c = event.Id;
		ems.Bill_From__c = project.Id;
		ems.NetSuite_ID__c = '1539958';
		insert ems;

		Test.setMock(HttpCalloutMock.class, new NetSuiteToSalesforce_Mock());
		Test.startTest();
		SOStausUpdateFromNSBatch batch = new SOStausUpdateFromNSBatch('EMS__c');
		Database.executeBatch(batch);
		Test.stopTest();

		System.assertEquals([SELECT Id, SalesOrder_Status__c
		                     FROM EMS__c
		                     WHERE Id = :ems.Id].SalesOrder_Status__c, 'Closed');
	}

	@isTest
	static void testSchedule(){
		SOStausUpdateFromNSBatch batch = new SOStausUpdateFromNSBatch('EMS__c');
		batch.execute(null);
	}
}