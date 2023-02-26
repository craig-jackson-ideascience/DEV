/**
 * Test class for CloneEvents
 */
@isTest
public class CloneEvents_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@TestSetup
	static void createTestData(){

		Product2 prod = TestDataUtils.createProduct(true, 'Laptop X2001', 'Test Product', true, 'Event');

		PricebookEntry pbEntry = TestDataUtils.createPriceBookEntryID(true, prod.Id);

		Project__c project = TestDataUtils.createProject(true, 'The Linux Foundation', 'Event', 'Directed Fund', 'Planned');
		project.Status__c = 'Active';
		project.Funding__c = 'Funded';
        project.Model__c = 'Membership';
		update project;

		Event__c evt = new Event__c(Name = 'Test Ecvent', Category__c = 'LF Event', BillFromProject__c = project.Id);
		insert evt;
        
        Event__c evt1 = new Event__c(Name = 'TestEvt LinuxCon/CloudOpen North America 2013 - Additional Sponsor Opportunities', Category__c = 'LF Event', BillFromProject__c = project.Id);
		insert evt1;

		Product_Details__c pd = new Product_Details__c(Event__c = evt.Id, Description__c = 'Test', Products__c = prod.Id, Tier__c = 'Gold', Sub_Category__c = 'EventSponsorship');
		insert pd;
        
        Product_Details__c pd1 = new Product_Details__c(Event__c = evt1.Id, Description__c = 'Test', Products__c = prod.Id, Tier__c = 'Gold', Sub_Category__c = 'EventSponsorship');
		insert pd1;
	}
    
	@isTest
	static void cloneEventSuccess(){
		Event__c event = [SELECT Id FROM Event__c Where Name='Test Ecvent' LIMIT 1];

		//Tests
		Test.startTest();
		string cloneEventId = CloneEvents.clone_method(event.id);
		Test.stopTest();

		//Asserts
		System.assert(cloneEventId != null);
	}
    
    @isTest
	static void cloneEventFail(){
		Event__c event = [SELECT Id FROM Event__c Where Name='TestEvt LinuxCon/CloudOpen North America 2013 - Additional Sponsor Opportunities' LIMIT 1];

		//Tests
		Test.startTest();
		string cloneEventId = CloneEvents.clone_method(event.id);
		Test.stopTest();
        
	}
}