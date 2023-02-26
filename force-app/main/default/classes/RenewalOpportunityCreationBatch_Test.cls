/**
 * Test class for RenewalOpportunityCreationBatch
 */
@isTest
public class RenewalOpportunityCreationBatch_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@testsetup
	static void createTestData(){

		Account acc = TestDataUtils.createAccount(false, 'Test Account');
		acc.billingCountry = 'brasil';
		acc.billingStreet = 'new';
		insert acc;
        
        Address__c add = new Address__c(Account__c = acc.Id, Name = 'Test Account Brasil', City__c = 'XYZ', Country__c = 'Brasil', Street__c='XYZ');
        insert add;

		Contact contact = new Contact(LastName = 'Test Contact', AccountId = acc.Id, email = 'test@gmail.com');
		insert contact;

		Opportunity opportunity = new Opportunity(Name = 'Renewal Opportunity Testing Shanghai Molian Information Technology Co, Ltd - RISC-V International - Strategic Membership', accountId = acc.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True', Bill_To_Account__c= acc.Id, Bill_To_Address__c = add.Id);
		insert opportunity;

		//Product
		Product2 prod = TestDataUtils.createProduct(true, 'Laptop X2001', 'Test Product', true, 'Membership');
		//PriceBookEntry
		PricebookEntry standardPrice = TestDataUtils.createPriceBookEntryID(true, prod.Id);

		Project__c project1 = new Project__c(Name = 'LF Networking', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Subsidiary_ID__c = 8, Slug__c = 'testing');
		insert project1;

        List<Product_Details__c> lstProductDetails = new List<Product_Details__c>();
		Product_Details__c proDetail = new Product_Details__c(Netsuite_ID__c = '1111', Project__c = project1.id, Products__c = prod.id, Price__c = 100, Description__c = 'Test', Renewal_Type__c ='Prorate',  Number_of_years_required__c = '1');
		//insert proDetail;
		lstProductDetails.add(proDetail);
        Product_Details__c proDetail1 = new Product_Details__c(Netsuite_ID__c = '2222', Project__c = project1.id, Products__c = prod.id, Price__c = 200, Description__c = 'Test', Renewal_Type__c ='Non-Prorate',  Number_of_years_required__c = '1');
		//insert proDetail1;
		lstProductDetails.add(proDetail1);
		insert lstProductDetails;
        
        List<opportunityLineItem> lstOli = new List<opportunityLineItem>();
		OpportunityLineItem opportunityLineItem = new OpportunityLineItem(Billing_Contact__c = contact.id, Representative_Voting_Contact__c = contact.id, Authorized_Signatory__c = contact.Id, Projects__c = project1.id, Product_Details__c = proDetail.id, OpportunityId = opportunity.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = standardPrice.ID, start_date__c = date.today(), end_date__c = date.today().addDays(2), Number_of_years_required__c = 1, order__c = 1, NetSuite_ID__c = '14823', NS_Entity_ID__c = '18765', Renewal_type__c = 'Prorate');
		//insert opportunityLineItem;
        lstOli.add(opportunityLineItem);
        OpportunityLineItem opportunityLineItem1 = new OpportunityLineItem(Billing_Contact__c = contact.id, Representative_Voting_Contact__c = contact.id, Authorized_Signatory__c = contact.Id, Projects__c = project1.id, Product_Details__c = proDetail.id, OpportunityId = opportunity.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = standardPrice.ID, start_date__c = date.today(), end_date__c = date.today().addDays(2), Number_of_years_required__c = 1, order__c =1, NetSuite_ID__c = '14823', NS_Entity_ID__c = '18765', Renewal_type__c = 'Prorate');
		//insert opportunityLineItem1;
         lstOli.add(opportunityLineItem1);
        OpportunityLineItem opportunityLineItem2 = new OpportunityLineItem(Billing_Contact__c = contact.id, Representative_Voting_Contact__c = contact.id, Authorized_Signatory__c = contact.Id, Projects__c = project1.id, Product_Details__c = proDetail.id, OpportunityId = opportunity.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = standardPrice.ID, start_date__c = date.today(), end_date__c = date.today().addDays(2), Number_of_years_required__c = 1, order__c = null, NetSuite_ID__c = '14823', NS_Entity_ID__c = '18765', Renewal_type__c = 'Prorate');
		//insert opportunityLineItem2;
         lstOli.add(opportunityLineItem2);
        OpportunityLineItem opportunityLineItem3 = new OpportunityLineItem(Billing_Contact__c = contact.id, Representative_Voting_Contact__c = contact.id, Authorized_Signatory__c = contact.Id, Projects__c = project1.id, Product_Details__c = proDetail1.id, OpportunityId = opportunity.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = standardPrice.ID, start_date__c = date.today(), end_date__c = date.today().addDays(2), Number_of_years_required__c = 1, order__c =1, NetSuite_ID__c = '14823', NS_Entity_ID__c = '18765', Renewal_type__c = 'Non-Prorate');
		//insert opportunityLineItem3;
 		lstOli.add(opportunityLineItem3);
        insert lstOli;
		OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = opportunity.id, contactid = contact.id, role = 'Decision Maker');
		insert ocr;

        List<Asset> lstAsset = new List<Asset>();
		Asset asset = new Asset(Name = 'Test Asset', AccountID = acc.Id, Projects__c = opportunityLineItem.Projects__c, usageenddate = Date.newInstance(System.today().year(), 12, 05), Auto_Renew__c = TRUE, Renewal_Opportunity_Created__c = FALSE, CNCF_Level__c = opportunityLineItem.CNCF_Level__c, Press_Release_Announcement__c = opportunityLineItem.No_Press_Release_Announcement__c, Display_Logo_On_Website__c = opportunityLineItem.Display_Logo_On_Website__c, NetSuite_Id__c = opportunityLineItem.NetSuite_Id__c, NS_Entity_ID__c = opportunityLineItem.NS_Entity_ID__c, order__c = opportunityLineItem.order__c, Bill_To_Account__c = acc.Id , Bill_To_Address__c = add.Id , OpportunityLineItem__c = opportunityLineItem.id, Opportunity__c = opportunity.Id);
		//insert asset;
		lstAsset.add(asset);
        Asset asset1 = new Asset(Name = 'Test Asset 1', AccountID = acc.Id, Projects__c = opportunityLineItem1.Projects__c, usageenddate = Date.newInstance(System.today().year(), 03, 05), Auto_Renew__c = TRUE, Renewal_Opportunity_Created__c = FALSE, CNCF_Level__c = opportunityLineItem1.CNCF_Level__c, Press_Release_Announcement__c = opportunityLineItem1.No_Press_Release_Announcement__c, Display_Logo_On_Website__c = opportunityLineItem1.Display_Logo_On_Website__c, NetSuite_Id__c = opportunityLineItem1.NetSuite_Id__c, NS_Entity_ID__c = opportunityLineItem1.NS_Entity_ID__c, order__c = opportunityLineItem1.order__c, Bill_To_Account__c = acc.Id , Bill_To_Address__c = add.Id , OpportunityLineItem__c = opportunityLineItem1.id, Opportunity__c = opportunity.Id);
		//insert asset1;
		lstAsset.add(asset1);
        Asset asset2 = new Asset(Name = 'Test Asset 1', AccountID = acc.Id, Projects__c = opportunityLineItem2.Projects__c, usageenddate = Date.newInstance(System.today().year(), 03, 05), Auto_Renew__c = TRUE, Renewal_Opportunity_Created__c = FALSE, CNCF_Level__c = opportunityLineItem2.CNCF_Level__c, Press_Release_Announcement__c = opportunityLineItem2.No_Press_Release_Announcement__c, Display_Logo_On_Website__c = opportunityLineItem2.Display_Logo_On_Website__c, NetSuite_Id__c = opportunityLineItem2.NetSuite_Id__c, NS_Entity_ID__c = opportunityLineItem2.NS_Entity_ID__c, order__c = 1 , Bill_To_Account__c = acc.Id , Bill_To_Address__c = add.Id , OpportunityLineItem__c = opportunityLineItem2.id, Opportunity__c = opportunity.Id);
		//insert asset2;
		lstAsset.add(asset2);
        Asset asset3 = new Asset(Name = 'Test Asset 1', AccountID = acc.Id, Projects__c = opportunityLineItem3.Projects__c, usageenddate = Date.newInstance(System.today().year(), 03, 05), Auto_Renew__c = TRUE, Renewal_Opportunity_Created__c = FALSE, CNCF_Level__c = opportunityLineItem3.CNCF_Level__c, Press_Release_Announcement__c = opportunityLineItem3.No_Press_Release_Announcement__c, Display_Logo_On_Website__c = opportunityLineItem3.Display_Logo_On_Website__c, NetSuite_Id__c = opportunityLineItem3.NetSuite_Id__c, NS_Entity_ID__c = opportunityLineItem3.NS_Entity_ID__c, order__c = opportunityLineItem3.order__c, Bill_To_Account__c = acc.Id , Bill_To_Address__c = add.Id , OpportunityLineItem__c = opportunityLineItem3.id, Opportunity__c = opportunity.Id);
		//insert asset3;
		lstAsset.add(asset3);
        insert lstAsset;
        
        Datetime twoMonthsBefore = Datetime.now().addDays(-65);
		Test.setCreatedDate(asset.Id, twoMonthsBefore);
		Test.setCreatedDate(asset1.Id, twoMonthsBefore);
		Test.setCreatedDate(asset2.Id, twoMonthsBefore);
        Test.setCreatedDate(asset3.Id, twoMonthsBefore);
        //ProjectRoles
		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c billingRole = TestDataUtils.createProjectRole(false, contact.id, 'Billing Contact', opportunity.Id, opportunityLineItem.Id, asset.Id, true);
		projectRoles.add(billingRole);

		Project_Role__c votingRole = TestDataUtils.createProjectRole(false, contact.id, 'Representative/Voting Contact', opportunity.Id, opportunityLineItem.Id, asset.Id, true);
		projectRoles.add(votingRole);

		Project_Role__c technicalRole = TestDataUtils.createProjectRole(false, contact.id, 'Technical Contact', opportunity.Id, opportunityLineItem.Id, asset.Id, true);
		projectRoles.add(technicalRole);

		Project_Role__c marketingRole = TestDataUtils.createProjectRole(false, contact.id, 'Marketing Contact', opportunity.Id, opportunityLineItem.Id, asset.Id, true);
		projectRoles.add(marketingRole);

		Project_Role__c pressRole = TestDataUtils.createProjectRole(false, contact.id, 'Press Contact', opportunity.Id, opportunityLineItem.Id, asset.Id, true);
		projectRoles.add(pressRole);

		Project_Role__c legalRole = TestDataUtils.createProjectRole(false, contact.id, 'Legal Contact', opportunity.Id, opportunityLineItem.Id, asset.Id, true);
		projectRoles.add(legalRole);

		insert projectRoles;
	}

	/**
	 * testBatchApex: test method for batchClass
	 */
	@IsTest
	static void testBatchApex(){
		Test.startTest();
		String pastDate = String.valueOf(Date.today());
		System.debug(pastDate);
		String qry = 'SELECT id,OpportunityLineItem__c,UsageEndDate,Renewal_Opportunity_Created__c ,Bill_To_Address__c,Bill_To_Account__c,' + 
					 'order__c, NS_Entity_ID__c,NetSuite_Id__c,Display_Logo_On_Website__c,Press_Release_Announcement__c,CNCF_Level__c,' + 
					 'Opportunity__c,Projects__r.Days_to_Deduct__c,AccountID FROM Asset WHERE Renewal_Opportunity_Created__c = FALSE and Auto_Renew__c = TRUE ' + 
					 'and DAY_ONLY(convertTimezone(CreatedDate)) <=' + pastDate + '  and Projects__c!=null and ' + 
					 'Opportunity__c !=null and Status !=\'Invoice Cancelled\'';

		system.debug('__qry____' + qry);
		Database.executebatch(new RenewalOpportunityCreationBatch(qry));
		Test.stopTest();
		List<Asset> assetList = [Select Id
		                         from Asset
		                         where Renewal_Opportunity_Created__c = true AND Renewal_Opportunity_Created__c = true];

		//Asserts
		System.assertEquals(4, assetList.size(),'List must contain 1 Element');
	}

	/**
	 * testScheduleBatchApex: test method for scheduler part of class
	 */
	@IsTest
	static void testScheduleBatchApex(){
        List<Asset> deleteAssetRec = [Select Id From Asset Where Name='Test Asset 1'];
        delete deleteAssetRec;
		Test.startTest();
		ScheduleRenewalOpportunityCreationBatch sc = new ScheduleRenewalOpportunityCreationBatch();
		sc.execute(null);
		Test.stopTest();
		List<Asset> assetList = [Select Id
		                         from Asset
		                         where Renewal_Opportunity_Created__c = true AND Renewal_Opportunity_Created__c = true];

		//Asserts
		System.assertEquals(1, assetList.size(),'List must contain 1 Element');
	}

	/**
	 * parametrizedContructorwithDate_Test: test method for Batch class
	 */
	@IsTest
	static void parametrizedContructorwithDate_Test(){
		Test.startTest();
		Database.executebatch(new RenewalOpportunityCreationBatch(30, null, System.today().month(), System.today().day()));
		Test.stopTest();
		List<Asset> assetList = [Select Id
		                         from Asset
		                         where Renewal_Opportunity_Created__c = true AND Renewal_Opportunity_Created__c = true];

		//Asserts
		System.assertEquals(4, assetList.size(),'List must contain 1 Element');
	}

	/**
	 * parametrizedContructorwithQuery_Test: test method for Batch class
	 */
	@IsTest
	static void parametrizedContructorwithQuery_Test(){
		Test.startTest();
		String pastDate = String.valueOf(Date.today());
		System.debug(pastDate);
		String qry = 'SELECT id,OpportunityLineItem__c,UsageEndDate,Renewal_Opportunity_Created__c ,Bill_To_Address__c,Bill_To_Account__c,' + 
					 'order__c, NS_Entity_ID__c,NetSuite_Id__c,Display_Logo_On_Website__c,Press_Release_Announcement__c,CNCF_Level__c,' + 
					 'Opportunity__c,Projects__r.Days_to_Deduct__c,AccountID FROM Asset WHERE Renewal_Opportunity_Created__c = FALSE and Auto_Renew__c = TRUE ' + 
					 'and DAY_ONLY(convertTimezone(CreatedDate)) <=' + pastDate + '  and Projects__c!=null and ' + 
					 'Opportunity__c !=null and Status !=\'Invoice Cancelled\'';

		system.debug('__qry____' + qry);
		Database.executebatch(new RenewalOpportunityCreationBatch(null, qry, null, null));
		Test.stopTest();
		List<Asset> assetList = [Select Id
		                         from Asset
		                         where Renewal_Opportunity_Created__c = true AND Renewal_Opportunity_Created__c = true];

		//Asserts
		System.assertEquals(4, assetList.size(),'List must contain 1 Element');
	}
}