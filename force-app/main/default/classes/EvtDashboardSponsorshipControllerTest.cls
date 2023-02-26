@IsTest
private class EvtDashboardSponsorshipControllerTest{
	@TestSetup
	static void testSetup(){

		Project__c parentProj = new Project__c(Name = 'Parent project', slug__c = 'parent');
		insert parentProj;

		/* project */
		List<Project__c> listOfProj = new List<Project__c>();
		Project__c proj1 = new Project__c();
		proj1.Name = 'The Linux Foundation';
		proj1.Project_Status__c = 'Active';
		proj1.Category__c = 'Subproject';
		proj1.Slug__c = 'testing1';
		proj1.Project_Entity_Name__c = 'The Linux Foundation';
		proj1.Start_Date__c = System.today();
		proj1.Funding__c = 'Funded';
		proj1.Industry__c = 'Non-profit Organizations';
		proj1.Parent_Entity_Relationship__c = parentProj.Id;
		proj1.Model__c = 'Alternate Funding';
		proj1.Parent_Project__c = parentProj.Id;
		proj1.Technology__c = 'Blockchain';
		proj1.Technical_Activity_Type__c = 'Open Source Software';
		listOfProj.add(proj1);

		Project__c proj2 = new Project__c();
		proj2.Name = 'Test Proj';
		proj2.Project_Status__c = 'Active';
		proj2.Status__c = 'Planned';
		proj2.Funding__c = 'Funded';
		proj2.Category__c = 'Directed Fund';
		proj2.Slug__c = 'testing2';
		proj2.Project_Entity_Name__c = 'The Linux Foundation';
		proj2.Start_Date__c = System.today();
		proj2.Funding__c = 'Funded';
		proj2.Industry__c = 'Non-profit Organizations';
		proj2.Parent_Entity_Relationship__c = parentProj.Id;
		proj2.Model__c = 'Alternate Funding';
		proj2.Parent_Project__c = parentProj.Id;
		proj2.Technology__c = 'Blockchain';
		proj2.Technical_Activity_Type__c = 'Open Source Software';
		listOfProj.add(proj2);
		insert listOfProj;

		proj2.Status__c = 'Active';
        update proj2;

		/* account */
		Account account = TestFactory.getAccount();

		/* contact */
		Contact contact = TestFactory.getContact();

		/* opportunity */
		Opportunity oppt = new Opportunity(Name = 'Opportunity testing 1', accountId = account.Id, CloseDate = Date.today().addDays(4), StageName = 'Closed Won');
		insert oppt;

		/* event */
		List<Event__c> eventList = new List<Event__c>();
		Event__c event1 = new Event__c(Name = 'Test Event1', Category__c = 'Project Event', Start_Date__c = date.today().addDays(-3), Status__c = 'Active', BillFromProject__c = proj2.Id);
		eventList.add(event1);
		Event__c event2 = new Event__c(Name = 'Test Event2', Category__c = 'Project Event', Start_Date__c = date.today().addDays(-2), Status__c = 'Active', BillFromProject__c = proj2.Id);
		eventList.add(event2);
		insert eventList;

		/* event registeration */
		Event_Registrations__c eventReg = new Event_Registrations__c();
		eventReg.Name = 'Test eventReg';
		eventReg.Contact__c = contact.Id;
		eventReg.Event__c = eventList[0].Id;
		eventReg.Cvent_Registration_Id__c = 'testventregistraion56789';
		eventReg.Cvent_Registration_FirstName__c = 'test FirstName';
		eventReg.Cvent_Registration_LastName__c = 'test LastName';
		eventReg.Data_Source__c = 'Manual Entry';
		insert eventReg;

		/* asset */
		Asset asset = TestFactory.getAsset();
		List<Asset> assetList = [SELECT Event__c, PurchaseDate, Price
		                         FROM Asset
		                         WHERE Name = 'TEstcreateasset'];
		for (Asset a : assetList){
			a.Event__c = eventList[0].Id;
			a.PurchaseDate = date.today().addDays(-1);
			a.Price = 100;
		}
		update assetList;
	}

	//Test for getLastSeventDaysEvents Method
	@IsTest
	static void getLastSevenDaysEventsTest(){
		List<Event__c> event = EventDashboard_SponsorshipsController.getLastSevenDaysEvents();
		System.assertEquals(1, event.size());
	}

	@IsTest
	static void getWeekNumbersTest(){
		Map<String, String> result = EventDashboard_SponsorshipsController.getWeekNumbers();
		System.assertEquals(2, result.keySet().size());
	}

	@IsTest
	static void getActiveSponsoredEventsTest(){
		List<String> listOfSelectedEvents = new List<String>{};
		listOfSelectedEvents.add('Test Event1');
		listOfSelectedEvents.add('Test Event2');
		List<EventDashboard_SponsorshipsController.EventWrapper> result = EventDashboard_SponsorshipsController.getActiveSponsoredEvents(listOfSelectedEvents);
		System.assertEquals(1, result.size());
	}
}