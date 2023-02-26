/**
 * Test class for CNCF_DashboardController
 * @author Cloudroute Solutions
 */
@IsTest
private class CNCF_DashboardController_Test{
	/**
	 * testSetup inserting required data for test class
	 */
	@TestSetup
	static void testSetup(){
		/* project */

		Project__c parentProj = new Project__c(Name = 'Parent project', slug__c = 'parent');
        insert parentProj;

		List<Project__c> listOfProj = new List<Project__c>();
		Project__c proj1 = new Project__c();
		proj1.Name = 'The Linux Foundation';
		proj1.Project_Status__c = 'Active';
		proj1.Category__c = 'Subproject';
        proj1.Slug__c = 'testing';
        proj1.Project_Entity_Name__c = 'Testing';
        proj1.Start_Date__c = System.today();
        proj1.Funding__c = 'Funded';
        proj1.Industry__c = 'Non-profit Organizations';
        proj1.Model__c = 'Alternate Funding';
        proj1.Technology__c = 'Blockchain';
        proj1.Technical_Activity_Type__c = 'Open Source Software';
        proj1.Description__c = 'description';
		proj1.Parent_Entity_Relationship__c = parentProj.Id;
		proj1.Parent_Project__c = parentProj.Id;
		listOfProj.add(proj1);

		Project__c proj2 = new Project__c();
		proj2.Name = 'Test Proj';
		proj2.Slug__c = 'cncf';
		proj2.Project_Status__c = 'Active';
		proj2.Status__c = 'Planned';
		proj2.Funding__c = 'Funded';
		proj2.Category__c = 'Directed Fund';
        proj2.Project_Entity_Name__c = 'Testing';
        proj2.Start_Date__c = System.today();
        proj2.Funding__c = 'Funded';
        proj2.Funding__c = 'Funded';
        proj2.Industry__c = 'Non-profit Organizations';
        proj2.Model__c = 'Alternate Funding';
        proj2.Technology__c = 'Blockchain';
        proj2.Technical_Activity_Type__c = 'Open Source Software';
        proj2.Description__c = 'description';
		proj2.Parent_Entity_Relationship__c = parentProj.Id;
		proj2.Parent_Project__c = parentProj.Id;
		listOfProj.add(proj2);
		insert listOfProj;

		listOfProj[1].Status__c = 'Active';
		update listOfProj[1];

		/* account */
		Account account = new Account();
		account.Name = 'Test Account';
		insert account;

		/* pricebook id */
		Id standardPriceBookId = Test.getStandardPricebookId();

		/* opportunity */
		Opportunity oppt = new Opportunity();
		oppt.Name = 'Opportunity testing 1';
		oppt.AccountId = account.Id;
		oppt.CloseDate = Date.today().addDays(4);
		oppt.StageName = '2. Discovery';
		oppt.Pricebook2Id = standardPriceBookId;
		insert oppt;

		/* event */
		List<Event__c> eventList = new List<Event__c>();
		Event__c event1 = new Event__c();
		event1.Name = 'Test Event1';
		event1.Category__c = 'Project Event';
		event1.Start_Date__c = date.today().addDays(-3);
		event1.Status__c = 'Active';
		event1.BillFromProject__c = proj2.Id;
		eventList.add(event1);
		Event__c event2 = new Event__c();
		event2.Name = 'Test Event2';
		event2.Category__c = 'Project Event';
		event2.Start_Date__c = date.today().addDays(-2);
		event2.Status__c = 'Active';
		event2.BillFromProject__c = proj2.Id;
		eventList.add(event2);
		insert eventList;

		/* product */
		Product2 prod = new Product2();
		prod.Name = 'Test Product';
		prod.Family = 'Membership';
		prod.IsActive = true;
		insert prod;

		/* pricebook entry */
		PriceBookEntry priceBookEntry = new PriceBookEntry();
		priceBookEntry.PriceBook2Id = standardPriceBookId;
		priceBookEntry.Product2Id = prod.Id;
		priceBookEntry.IsActive = true;
		priceBookEntry.UnitPrice = 100;
		insert priceBookEntry;

		/* opportunity line items */
		List<OpportunityLineItem> listOfItems = new List<OpportunityLineItem>();
		for (Integer i = 0; i < 5; i++){
			OpportunityLineItem item = new OpportunityLineItem();
			item.Product2Id = prod.Id;
			item.OpportunityId = oppt.Id;
			item.Quantity = 2;
			item.UnitPrice = 100;
			item.Event__c = event2.Id;
			listOfItems.add(item);
		}
		insert listOfItems;
	}

	/**
	 * getAllCNCFEventsTest test method for getAllCNCFEvents
	 */
	@IsTest
	static void getAllCNCFEventsTest(){
		String jsonResult = CNCF_DashboardController.getAllCNCFEvents();
		List<CNCF_DashboardController.CNCFWrapper> result = (List<CNCF_DashboardController.CNCFWrapper>)JSON.deserialize(jsonResult, List<CNCF_DashboardController.CNCFWrapper>.class);
		System.assertEquals(1, result.size());
	}
}