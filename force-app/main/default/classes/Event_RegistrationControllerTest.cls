@IsTest
private class Event_RegistrationControllerTest{
	@TestSetup
	static void testSetup(){
		
        Project__c parentProject = new Project__c();
        parentProject.Name = 'Parent Project';
        parentProject.Slug__c = 'test_parent_slug';
        insert parentProject;
        
        Project__c proj2 = new Project__c(
            Name = 'The Linux Foundation',
            Category__c = 'Directed Fund',
            Status__c = 'Active',
            Funding__c = 'Funded',
            Slug__c = 'test_slug',
            Project_Entity_Name__c = 'test formal name',
            Start_Date__c = Date.today(),
            Industry__c = 'Automotive',
            Parent_Entity_Relationship__c = parentProject.Id,
            Parent_Project__c = parentProject.Id,
            Model__c = 'Membership',
            Technology__c = 'Storage',
            Technical_Activity_Type__c = 'Open Data'
        );
        insert proj2;
		/* account */
		Account account = TestFactory.getAccount();

		/* contact */
		Contact contact = TestFactory.getContact();

		/* opportunity */
		Opportunity oppt = new Opportunity(Name = 'Opportunity testing 1', accountId = account.Id, CloseDate = Date.today().addDays(4), StageName = 'Closed Won');
		insert oppt;

		/* event */
		List<Event__c> eventList = new List<Event__c>();
		Event__c event1 = new Event__c(Name = 'Test Event1', Category__c = 'Project Event', Start_Date__c = date.today().addDays(-2), Status__c = 'Active', BillFromProject__c = proj2.Id);
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
        eventReg.Cvent_Registration_Status__c = 'Accepted';
        eventReg.Cvent_Registration_RegistrationDate__c = date.today().addDays(-3);
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

	@IsTest
	static void getAllEventsTest(){
		Map<String, Object> result = EventDashboard_RegistrationController.getAllEvents('test');
		System.assertEquals(1, result.keySet().size());
	}

	@IsTest
	static void getRegistrationDetailsTest(){
		List<Event__c> listOfEvent = [SELECT Id
		                              FROM Event__c];
		Set<Id> setOfEventId = new Set<Id>();
		for (Event__c event : listOfEvent){
			setOfEventId.add(event.Id);
		}
        Map<String, Object> result = EventDashboard_RegistrationController.getRegistrationDetails(JSON.serialize(setOfEventId));
		System.assertEquals(3, result.keySet().size());
	}
    
    @IsTest
	static void getRegistrationDetails_1Test(){
		List<Event__c> listOfEvent = [SELECT Id
		                              FROM Event__c];
		Set<Id> setOfEventId = new Set<Id>();
		for (Event__c event : listOfEvent){
			setOfEventId.add(event.Id);
		}
        Event_Registrations__c eventReg = new Event_Registrations__c();
		eventReg.Name = 'Test eventReg';
		eventReg.Contact__c = [SELECT ID FROM Contact LIMIT 1].Id;
		eventReg.Event__c = listOfEvent[0].Id;
		eventReg.Cvent_Registration_Id__c = 'testventregistraio';
		eventReg.Cvent_Registration_FirstName__c = 'test FirstName1';
		eventReg.Cvent_Registration_LastName__c = 'test LastName1';
        eventReg.Cvent_Registration_Status__c = 'Accepted';
        eventReg.Cvent_Registration_RegistrationDate__c = date.today().addDays(-3);
		eventReg.Data_Source__c = 'Manual Entry';
		insert eventReg;
		Map<String, Object> result = EventDashboard_RegistrationController.getRegistrationDetails(JSON.serialize(setOfEventId));
		System.assertEquals(3, result.keySet().size());
	}

}