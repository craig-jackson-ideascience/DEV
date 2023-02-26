@isTest
private class CampaignDispositionControllerTest{
	/**
	 * TestSetup inserting required data for test class
	 */
	@testSetup
	static void createTestData(){
		//prep Campaign and Project data
		Project__c proj = TestFactory.getProject();
		Campaign camp = new Campaign();
		camp.Name = 'Test Campaign';
		camp.Description = 'Test Campaign';
		camp.Type = 'Webinar';
		camp.Status = 'Planned';
		camp.StartDate = Date.today();
		camp.Project__c = proj.Id;
		insert camp;

		//insert some status to prevent unexpected behavior from test
		CampaignMemberStatus defaultStatus = new CampaignMemberStatus();
		defaultStatus.CampaignId = camp.Id;
		defaultStatus.Label = 'Default';
		defaultStatus.IsDefault = true;
		defaultStatus.HasResponded = true;
		insert defaultStatus;
	}

	@isTest
	static void testCheckingForAndAddingStatuses(){

		Campaign campaign = [SELECT Id
		                     FROM Campaign
		                     LIMIT 1];
		//insert any disposition status to make sure addStatuses() doesn't delete it
		CampaignMemberStatus workingStatus = new CampaignMemberStatus();
		workingStatus.CampaignId = campaign.Id;
		workingStatus.Label = '5. Working';
		insert workingStatus;

		//check for statuses (negative test)
		Boolean statusesFound1 = CampaignDispositionController.checkForStatuses(campaign.Id);
		System.assertEquals(false, statusesFound1, 'Status Must be false');

		//add disposition statuses
		CampaignDispositionController.addStatuses(campaign.Id);

		//check for statuses (positive test)
		Boolean statusesFound2 = CampaignDispositionController.checkForStatuses(campaign.Id);
		System.assertEquals(true, statusesFound2, 'Status Must be true');
	}

	@isTest
	static void testCustomer(){

		Campaign campaign = [SELECT Id
		                     FROM Campaign
		                     LIMIT 1];
		Project__c proj = [SELECT Id
		                   FROM Project__c
		                   LIMIT 1];

		//add disposition statuses
		CampaignDispositionController.addStatuses(campaign.Id);

		//prep data needed for a customer
		Account acc = new Account();
		acc.Name = 'Acme';
		acc.Website = 'acme.com';
		insert acc;

		Lead ld = new Lead();
		ld.LastName = 'Smith';
		ld.Company = 'Test';
		ld.Email = 'smith@acme.com'; //for test, associate Lead with Account by email domain only
		insert ld;

		Contact con = new Contact();
		con.LastName = 'Jones';
		con.AccountId = acc.Id; //for test, associate Contact with Account directly
		con.Email = 'jones@gmail.com'; //and not by email domain
		insert con;

		Product2 prod = TestFactory.getProduct2();

		Membership__c memb = new Membership__c();
		memb.Account__c = acc.Id;
		memb.Project__c = proj.Id;
		memb.Product__c = prod.Id;
		memb.Start_Date__c = Date.today().addDays(-5);
		memb.End_Date__c = Date.today().addDays(360);
		insert memb;

		//add Lead and Contact as Campaign Members
		CampaignMember cm1 = new CampaignMember();
		cm1.LeadId = ld.Id;
		cm1.CampaignId = campaign.Id;
		insert cm1;

		CampaignMember cm2 = new CampaignMember();
		cm2.ContactId = con.Id;
		cm2.CampaignId = campaign.Id;
		insert cm2;

		//update statuses
		CampaignDispositionController.updateStatuses(campaign.Id, proj.Id);

		//verify statuses
		List<CampaignMember> cms = new List<CampaignMember>();
		cms = [SELECT Status
		       FROM CampaignMember];
		System.assertEquals(2, cms.size(), 'List must have 2 records');
		for (CampaignMember cm : cms){
			System.assertEquals('Customer', cm.Status, 'Status must be \'Customer\'');
		}

		//get statuses that were just updated
		CampaignDispositionController.getPriorAutoDispositionedData(campaign.Id);
	}

	@isTest
	static void testUnqualified(){

		Project__c proj = [SELECT Id
		                   FROM Project__c
		                   LIMIT 1];

		Campaign campaign = [SELECT Id
		                     FROM Campaign
		                     LIMIT 1];
		//add disposition statuses
		CampaignDispositionController.addStatuses(campaign.Id);

		//prep data for unqualified Campaign Members
		List<Lead> leads = new List<Lead>();
		List<Contact> contacts = new List<Contact>();

		Lead ld = new Lead();
		ld.LastName = 'Smith';
		ld.Company = 'Test';
		ld.Email = 'smith@college.edu';
		leads.add(ld);

		Contact con = new Contact();
		con.LastName = 'Jones';
		con.Email = 'jones@agency.gov';
		contacts.add(con);

		Contact con2 = new Contact();
		con2.LastName = 'McNabb';
		con2.Email = 'mcnabb@nonprofit.org';
		contacts.add(con2);

		Lead ld2 = new Lead();
		ld2.LastName = 'Young';
		ld2.Email = 'young@gmail.com';
		leads.add(ld2);

		Contact con3 = new Contact();
		con3.LastName = 'Rice';
		con3.Email = 'rice@hotmail.com';
		contacts.add(con3);

		insert leads;
		insert contacts;

		//add Leads and Contacts as Campaign Members
		List<CampaignMember> cms = new List<CampaignMember>();
		for (Integer i = 0; i < leads.size(); i++){
			CampaignMember cm = new CampaignMember();
			cm.LeadId = leads[i].Id;
			cm.CampaignId = campaign.Id;
			cms.add(cm);
		}
		for (Integer i = 0; i < contacts.size(); i++){
			CampaignMember cm = new CampaignMember();
			cm.ContactId = contacts[i].Id;
			cm.CampaignId = campaign.Id;
			cms.add(cm);
		}
		insert cms;

		//update statuses
		CampaignDispositionController.updateStatuses(campaign.Id, proj.Id);

		//verify statuses
		List<CampaignMember> cms2 = new List<CampaignMember>();
		cms2 = [SELECT Status
		        FROM CampaignMember];
		System.assertEquals(5, cms2.size(), 'List must have 5 records');
		for (CampaignMember cm : cms2){
			System.assertEquals('2a. Unqualified', cm.Status);
		}
	}

	@isTest
	static void testExistingOpp(){

		Project__c proj = [SELECT Id
		                   FROM Project__c
		                   LIMIT 1];

		Campaign campaign = [SELECT Id
		                     FROM Campaign
		                     LIMIT 1];
		//add disposition statuses
		CampaignDispositionController.addStatuses(campaign.Id);

		//prep data needed for existing opp Campaign Members
		Account acc = new Account();
		acc.Name = 'Acme';
		acc.Website = 'acme.com';
		insert acc;

		Lead ld = new Lead();
		ld.LastName = 'Smith';
		ld.Company = 'Test';
		ld.Email = 'smith@acme.com'; //for test, associate Lead with Account by email domain only
		insert ld;

		Contact con = new Contact();
		con.LastName = 'Jones';
		con.AccountId = acc.Id; //for test, associate Contact with Account directly
		con.Email = 'jones@gmail.com'; //and not by email domain
		insert con;

		Opportunity opp = new Opportunity();
		Id membershipRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
		opp.Name = 'Acme Opp';
		opp.AccountId = acc.Id;
		opp.Type = 'New Business';
		opp.RecordTypeId = membershipRTId;
		opp.CloseDate = Date.today().addDays(30);
		opp.StageName = '5. Decision Commitment';
		insert opp;

		Product2 prod = new Product2();
		prod.Name = 'Test Membership Product';
		prod.ProductCode = 'test';
		prod.Family = 'Membership';
		prod.IsActive = true;
		insert prod;

		Product_Details__c pd = new Product_Details__c();
		pd.Products__c = prod.Id;
		pd.Project__c = proj.Id;
		pd.Description__c = 'Test Product Details';
		pd.Price__c = 500;
		insert pd;

		PriceBookEntry pbe = TestFactory.getPriceBookEntry();
		OpportunityLineItem oli = new OpportunityLineItem();
		oli.OpportunityId = opp.Id;
		oli.Quantity = 1;
		oli.UnitPrice = 500;
		oli.PriceBookEntryId = pbe.ID;
		oli.Product_Details__c = pd.Id;
		insert oli;

		//add Lead and Contact as Campaign Members
		CampaignMember cm1 = new CampaignMember();
		cm1.LeadId = ld.Id;
		cm1.CampaignId = campaign.Id;
		insert cm1;

		CampaignMember cm2 = new CampaignMember();
		cm2.ContactId = con.Id;
		cm2.CampaignId = campaign.Id;
		insert cm2;

		//update statuses
		CampaignDispositionController.updateStatuses(campaign.Id, proj.Id);

		//verify statuses
		List<CampaignMember> cms = new List<CampaignMember>();
		cms = [SELECT Status
		       FROM CampaignMember];
		System.assertEquals(2, cms.size(), 'List must return 2 records');
		for (CampaignMember cm : cms){
			System.assertEquals('2b. Existing Opp', cm.Status, 'Status must be \'2b. Existing Opp\'');
		}
	}

	//this method is used for coverage over the CampaignDispositionBatch class
	@isTest
	static void testBatch(){

		Campaign campaign = [SELECT Id
		                     FROM Campaign
		                     LIMIT 1];
		Project__c proj = [SELECT Id
		                   FROM Project__c
		                   LIMIT 1];

		//add disposition statuses
		CampaignDispositionController.addStatuses(campaign.Id);

		//create 100 unqualified Leads
		List<Lead> leads = new List<Lead>();
		for (Integer i = 0; i < 100; i++){
			Lead ld = new Lead();
			ld.LastName = 'Lead ' + i;
			ld.Company = 'Test';
			ld.Email = 'test' + i + '@acme.edu';
			leads.add(ld);
		}
		insert leads;

		//add Leads as Campaign Members
		List<CampaignMember> cms = new List<CampaignMember>();
		for (Integer i = 0; i < 100; i++){
			CampaignMember cm = new CampaignMember();
			cm.LeadId = leads[i].Id;
			cm.CampaignId = campaign.Id;
			cms.add(cm);
		}
		insert cms;

		//update statuses -- because there are 100 Campaign Members, this will kick off batch
		Test.startTest(); //necessary for batch testing
		CampaignDispositionController.updateStatuses(campaign.Id, proj.Id);
		Test.stopTest(); //necessary for batch testing

		//verify statuses
		List<CampaignMember> cms2 = new List<CampaignMember>();
		cms2 = [SELECT Status
		        FROM CampaignMember];
		System.assertEquals(100, cms2.size(), 'List must have 100 records');
		for (CampaignMember cm : cms2){
			System.assertEquals('2a. Unqualified', cm.Status, 'Status must be \'2a. Unqualified\'');
		}
	}
}