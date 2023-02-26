/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 29-08-2019.
 * Description: EventAndProjectRolesReportCtrlTest
 ********************************************************/
@isTest
public class EventAndProjectRolesReportCtrl_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@TestSetup
	static void createTestData(){
		//Account
		Account account = TestDataUtils.createAccount(true,'Test Account');
        
		//Contact
		List<Contact> contactList = new List<Contact>();
		for (Integer i = 1; i < 4; i++){
			contactList.add(new Contact(FirstName = 'Contact', LastName = 'Contact' + i, Email = 'test@contact' + i + '.com'));
		}
		insert contactList;

		//Project
		Project__c project = TestDataUtils.createProject(true, 'The Linux Foundation', 'Event', 'Directed Fund', 'Planned');
		project.Status__c = 'Active';
		project.Funding__c = 'Funded';
		update project;

		//Event
		Event__c evt = new Event__c(Event_Name__c = 'KubeCon', Name = 'KubeCon',     // Event Name
		Status__c = 'Complete',                                                                                                                                                   // Event Status
		Category__c = 'LF Event',                                                                                                                                                 // Category
		BillFromProject__c = project.id,  //ID                                                                                                                                  // Bill From Project
		Start_Date__c = system.today()-20,                                                                                                                                // Event Start Date
		Capacity__c = 0,                                                                                                                                           // Event Start Time
		End_Date__c = system.today()-10,                                                                                                                                  // Event End Date
		Registration_Source__c = 'RegOnline',                                                                                                                                            // Event End Time
		Event_Location_Name__c = 'Twitter HQ One 10th Street Expansion',                                                                                                          // Event Location Name
		Event_Published__c = false,                                                                                                                                               // Event Published
		Event_Location_Address__c = 'One 10th Street',                                                                                                                            // Event Location Address
		Event_Location_City__c = 'San Francisco',                                                                                                                                 // Event Location City
		Event_Location_State__c = 'California',                                                                                                                                   // Event Location State
		Event_Location_Country__c = 'United States',                                                                                                                              // Event Location Country
		Event_Location_Zip__c = '94103',                                                                                                                                          // Event Location Zip
		Embassy__c = 'US',                                                                                                                                                        // Embassy
		Cvent_Event_Is_Sandbox__c = false,                                                                                                                                          // Type
		Netsuite_Sync__c = false                                                                                                                                                // Netsuite Sync
		);
		insert evt;


		//Project
		Project__c proj = new Project__c(Name = 'Test Event Name', Category__c = 'Incorporated Entity', Slug__c = 'proj_slug');
		Project__c proj1 = new Project__c(Name = 'Test Event Name1', Category__c = 'Incorporated Entity', Slug__c = 'proj1_slug');
		Project__c proj2 = new Project__c(Name = 'Test Event Name2', Category__c = 'Incorporated Entity', Slug__c = 'proj2_slug');
		insert new List<Project__c>{proj, proj1, proj2};
		
		//EventRegistration
		Event_Registrations__c eventeRegistration = new Event_Registrations__c(Name = 'Event Registraion 1 ', Event__c = evt.Id, Contact__c = contactList[0].Id, Data_Source__c = 'Cvent');
		Event_Registrations__c eventeRegistration1 = new Event_Registrations__c(Name = 'Event Registraion 2', Event__c = evt.Id, Contact__c = contactList[1].Id, Data_Source__c = 'Cvent');
		Event_Registrations__c eventeRegistration2 = new Event_Registrations__c(Name = 'Event Registraion 3', Event__c = evt.Id, Contact__c = contactList[2].Id, Data_Source__c = 'Cvent');
		insert new List<Event_Registrations__c>{eventeRegistration, eventeRegistration1, eventeRegistration2};

		//Asset
		Asset asset = new Asset(Name = 'Asset', Number_of_Years_Required__c = 2, Projects__c = proj.Id, AccountId = account.Id);
		Asset asset1 = new Asset(Name = 'Asset1', Number_of_Years_Required__c = 3, Projects__c = proj1.Id, AccountId = account.Id);
		Asset asset2 = new Asset(Name = 'Asset2', Number_of_Years_Required__c = 4, Projects__c = proj2.Id, AccountId = account.Id);
		insert new List<Asset>{asset, asset1, asset2};
		

		//ProjectRole
		Project_Role__c pr = new Project_Role__c(Asset__c = asset.Id, Contact__c = contactList[0].Id, Role__c = 'Marketing Contact');
		Project_Role__c pr1 = new Project_Role__c(Asset__c =asset1.Id, Contact__c = contactList[1].Id, Role__c = 'Marketing Contact');
		Project_Role__c pr2 = new Project_Role__c(Asset__c =asset2.Id, Contact__c = contactList[2].Id, Role__c = 'Marketing Contact');
		insert new List<Project_Role__c>{pr, pr1, pr2};

		//Campaign
		Campaign campaign = new Campaign(Name = 'etst Campaign', Description = 'test Desc');
		insert campaign;
	}

	/**
	 * TestMethods for the Controller Class
	 */
	@isTest
	public static void eventsReportTest(){
		Event__c evt = [SELECT Id
		                FROM Event__c
		                LIMIT 1];
		EventAndProjectRolesReportCtrl ctrl = new EventAndProjectRolesReportCtrl();

		ctrl.filterType = 'events';
		ctrl.EventID = evt.Id;
		Test.startTest();
		boolean n = ctrl.hasNext;
		boolean p = ctrl.hasPrevious;
		ctrl.emailOptOut = 'false';
		ctrl.sortExpression = 'DESC';
		ctrl.eventSelectedMethod();
		ctrl.projectSelectedMethod();
		ctrl.callReport();
		ctrl.clearFilter();
		ctrl.getSortDirection();
		ctrl.sortWrapperList();
		ctrl.setCon.setPageSize = 1;
		ctrl.next();
		ctrl.next();
		ctrl.previous();
		Test.stopTest();
		System.debug(ctrl.reportWrapperList + '====> ctrl.reportWrapperList');
		System.debug(ctrl.reportWrapperList.size()+'====> ctrl.reportWrapperList');

		//Asserts
		System.assertEquals(3,ctrl.reportWrapperList.size(),'List Must have 3 records');
	}

	@isTest
	public static void eventsReportTest1(){
		Event__c evt = [SELECT Id
		                FROM Event__c
		                LIMIT 1];
		Project__c proj = [SELECT Id
		                   FROM Project__c
		                   LIMIT 1];

		EventAndProjectRolesReportCtrl ctrl = new EventAndProjectRolesReportCtrl();
		ctrl.filterType = 'events';
		ctrl.EventID = evt.Id;
		ctrl.ProjectID = proj.Id;
		Test.startTest();
		boolean n = ctrl.hasNext;
		boolean p = ctrl.hasPrevious;
		ctrl.sortExpression = 'DESC';
		ctrl.eventSelectedMethod();
		ctrl.projectSelectedMethod();
		ctrl.callReport();
		ctrl.clearFilter();
		ctrl.getSortDirection();
		ctrl.sortWrapperList();
		Test.stopTest();

		//Asserts
		System.assert(ctrl.reportWrapperList.isEmpty(), 'List must be empty');
	}

	@isTest
	public static void eventsReportTest2(){
		Event__c evt = [SELECT Id
		                FROM Event__c
		                LIMIT 1];
		Project__c proj = [SELECT Id
		                   FROM Project__c
		                   LIMIT 1];

		EventAndProjectRolesReportCtrl ctrl = new EventAndProjectRolesReportCtrl();
		ctrl.filterType = 'events';
		ctrl.EventID = evt.Id;
		ctrl.ProjectID = proj.Id;
		Test.startTest();
		boolean n = ctrl.hasNext;
		boolean p = ctrl.hasPrevious;
		ctrl.emailOptOut = 'true';

		ctrl.sortExpression = 'DESC';
		ctrl.eventSelectedMethod();
		ctrl.projectSelectedMethod();
		ctrl.callReport();
		ctrl.clearFilter();
		ctrl.getSortDirection();
		ctrl.sortWrapperList();
		Test.stopTest();
		System.debug(ctrl.reportWrapperList + '====> ctrl.reportWrapperList');
		System.debug(ctrl.reportWrapperList.size()+'====> ctrl.reportWrapperList');

		//Asserts
		System.assert(ctrl.reportWrapperList.isEmpty(), 'List must be empty');
	}

	@isTest
	public static void sortReportTest(){
		Event__c evt = [SELECT Id
		                FROM Event__c
		                LIMIT 1];
		EventAndProjectRolesReportCtrl ctrl = new EventAndProjectRolesReportCtrl();

		ctrl.filterType = 'events';
		ctrl.EventID = evt.Id;
		Test.startTest();
		boolean n = ctrl.hasNext;
		boolean p = ctrl.hasPrevious;
		ctrl.emailOptOut = 'false';
		ctrl.sortExpression = 'DESC';
		ctrl.eventSelectedMethod();
		ctrl.projectSelectedMethod();
		ctrl.callReport();
		ctrl.clearFilter();
		ctrl.getSortDirection();
		ctrl.sortWrapperList();
		ctrl.sortExpression = 'cnt.Name';
		ctrl.sortWrapperList();
		ctrl.sortExpression = 'cnt.FirstName';
		ctrl.sortWrapperList();
		ctrl.sortExpression = 'cnt.LastName';
		ctrl.sortWrapperList();
		ctrl.sortExpression = 'cnt.MailingCountry';
		ctrl.sortWrapperList();
		ctrl.sortExpression = 'cnt.Email';
		ctrl.sortWrapperList();
		ctrl.sortExpression = 'cnt.HasOptedOutOfEmail';
		ctrl.sortWrapperList();
		ctrl.sortExpression = 'projRole.Asset__r.Projects__r.Name';
		ctrl.sortWrapperList();
		ctrl.sortExpression = 'projRole.Role__c';
		ctrl.sortWrapperList();
		ctrl.sortExpression = 'projRole.PrimaryContact__c';
		ctrl.sortWrapperList();
		ctrl.sortExpression = 'event.Name';
		ctrl.sortWrapperList();
		ctrl.sortExpression = 'event.Start_Date__c';
		ctrl.sortWrapperList();
		ctrl.sortExpression = 'event.Event_Location_Country__c';
		ctrl.sortWrapperList();
		Test.stopTest();
		//Asserts		
		System.assertEquals(3,ctrl.reportWrapperList.size(),'List must have 3 elements');
	}

	@isTest
	public static void projectReportTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c WHERE Name='Test Event Name'
		                   LIMIT 1];
		EventAndProjectRolesReportCtrl ctrl = new EventAndProjectRolesReportCtrl();
		ctrl.filterType = 'projects';
		ctrl.ProjectID = proj.Id;
		Test.startTest();
		ctrl.sortExpression = 'DESC';
		ctrl.projectSelectedMethod();
		ctrl.callReport();
		ctrl.clearFilter();
		ctrl.getSortDirection();
		ctrl.sortWrapperList();
		Test.stopTest();
		//Asserts
		System.assertEquals(1,ctrl.reportWrapperList.size(),'List must have one element');
	}

	@isTest
	public static void addtoCampaign(){
		Project__c proj = [SELECT Id
		                   FROM Project__c
		                   LIMIT 1];
		Campaign camp = [SELECT Id
		                 FROM Campaign
		                 LIMIT 1];
		EventAndProjectRolesReportCtrl ctrl = new EventAndProjectRolesReportCtrl();
		ctrl.filterType = 'projects';
		ctrl.ProjectID = proj.Id;
		ctrl.campaignId = camp.Id;
		Test.startTest();
		ctrl.sortExpression = 'DESC';
		ctrl.projectSelectedMethod();
		ctrl.callReport();
		ctrl.addToCampaign();
		ctrl.addSelectedToCampaign();
		ctrl.cancelAddtoCampaign();
		Test.stopTest();
		System.debug(ctrl.reportWrapperList + '====> ctrl.reportWrapperList');
		System.debug(ctrl.reportWrapperList.size()+'====> ctrl.reportWrapperList');
		Integer count = [SELECT count()
		                 FROM CampaignMember];
		//Asserts
		System.assertEquals(0,count, 'There must be no campaignmembers');
	}
}