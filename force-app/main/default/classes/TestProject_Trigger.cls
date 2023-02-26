@isTest
public class TestProject_Trigger{
	static testmethod void testTrigger(){

		// Insert  test products with or without Number_of_Years_Required__c
		List<Product2> prod = new List<Product2>();
		prod.add(new Product2(Name = 'Laptop X200', Family = 'Membership', Tax_Class__c = 'T1', NetSuite_Revenue_Schedule__c = '6'));
		prod.add(new Product2(Name = 'Laptop X300', Family = 'Membership', Tax_Class__c = 'T1', NetSuite_Revenue_Schedule__c = '6'));
		prod.add(new Product2(Name = 'Laptop X300', Family = 'Membership', Tax_Class__c = 'T1', NetSuite_Revenue_Schedule__c = '6'));
		insert prod;

		// Get standard price book ID
		// This is available irrespective of the state of SeeAllData.
		Id pricebookId = Test.getStandardPricebookId();

		// Create a custom price book
		Pricebook2 customPB = new Pricebook2(Name = 'Custom Pricebook', isActive = true);
		insert customPB;

		// 1. Insert price book entries for the standard price book
		// Standard price book entries require the standard price book ID we got earlier
		// also for custom price book entries for custom pricebook that we created

		List<PricebookEntry> pbe = new List<PricebookEntry>();
		pbe.add(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod[0].Id, UnitPrice = 1000, IsActive = true));
		pbe.add(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod[1].Id, UnitPrice = 2000, IsActive = true));
		pbe.add(new PricebookEntry(Pricebook2Id = customPB.id, Product2Id = prod[0].Id, UnitPrice = 4000, IsActive = true));
		pbe.add(new PricebookEntry(Pricebook2Id = customPB.id, Product2Id = prod[1].Id, UnitPrice = 5000, IsActive = true));

		insert pbe;

		// Fetching RecordType Ids of Project object
		//List<RecordType> recordType_list = new List<RecordType>([Select Id, Name From RecordType Where SobjectType = 'Project__c' order by name]);
		// Fetching Record Type Id for Product detail
		Id proDetailRecordType = [Select Id, Name
		                          From RecordType
		                          Where SobjectType = 'Product_Details__c' and Name = 'Membership'].Id;

		// insert custom object - PROJECT
		List<Project__c> prjct = new List<Project__c>();

		// insert custom object - PRODUCT DETAILS
		/*if(recordType_list!=null && recordType_list.size()>0){

		 for(RecordType rt : recordType_list){

		 if(rt.Name == 'Incorporated Entity'){
		 prjct.add(new Project__c(Name = 'testing11'  , Status__c='Planned', RecordTypeId=rt.Id,Category__c='Incorporated' ));
		 prjct.add(new Project__c(Name = 'testing12' ,  Status__c='Planned', RecordTypeId=rt.Id,Category__c='Incorporated' ));
		 }
		 else{
		 prjct.add(new Project__c(Name = 'testing1'  , Status__c='Planned', NS_Deferred_Revenue_Account__c = '282' , NS_Department__c = '10' , NetSuite_Class__c = 'External P&Ls : CII' , NS_Income_GL_Account__c = '297' , RecordTypeId=rt.Id,Category__c='Incorporated' ));
		 prjct.add(new Project__c(Name = 'testing2' , Status__c='Planned' , NS_Deferred_Revenue_Account__c = '282' , NS_Department__c = '10' , NetSuite_Class__c = 'External P&Ls : CII' , NS_Income_GL_Account__c = '297' , RecordTypeId=rt.Id,Category__c='Incorporated' ));

		 }

		 }

		 if(prjct!=null && prjct.size()>0)
		 insert prjct;

		 }*/

		prjct.add(new Project__c(Name = 'testing11', Status__c = 'Planned', Category__c = 'Incorporated Entity', Slug__c = 'testing1'));
		prjct.add(new Project__c(Name = 'testing12', Status__c = 'Planned', Category__c = 'Incorporated Entity', Slug__c = 'testing2'));

		prjct.add(new Project__c(Name = 'testing1', Status__c = 'Planned', NS_Deferred_Revenue_Account__c = '282', NS_Department__c = '10', NetSuite_Class__c = 'External P&Ls : CII', NS_Income_GL_Account__c = '297', Category__c = 'Incorporated Entity', Slug__c = 'testing3'));
		prjct.add(new Project__c(Name = 'testing2', Status__c = 'Planned', NS_Deferred_Revenue_Account__c = '282', NS_Department__c = '10', NetSuite_Class__c = 'External P&Ls : CII', NS_Income_GL_Account__c = '297', Category__c = 'Incorporated Entity', Slug__c = 'testing4'));
		if (prjct != null && prjct.size() > 0){
			insert prjct;
		}

		List<Product_Details__c> proDetail = new List<Product_Details__c>();

		proDetail.add(new Product_Details__c(RecordTypeId = proDetailRecordType, Products__c = prod[0].Id, Project__c = prjct[0].Id, Description__c = 'Test Membership Product Detail'));
		proDetail.add(new Product_Details__c(RecordTypeId = proDetailRecordType, Products__c = prod[1].Id, Project__c = prjct[1].Id, Description__c = 'Test Membership Product Detail', NetSuite_Class__c = '276', NS_Deferred_Revenue_Account__c = '284', NS_Department__c = '2', Netsuite_ID__c = '2632', NS_Income_GL_Account__c = '171', NS_Revenue_Schedule__c = '6'));
		proDetail.add(new Product_Details__c(RecordTypeId = proDetailRecordType, Products__c = prod[0].Id, Project__c = prjct[2].Id, Description__c = 'Test Membership Product Detail'));
		proDetail.add(new Product_Details__c(RecordTypeId = proDetailRecordType, Products__c = prod[1].Id, Project__c = prjct[3].Id, Description__c = 'Test Membership Product Detail'));
		insert proDetail;

		try{
			prjct[0].Status__c = 'Active';
			prjct[1].Status__c = 'Active';
			prjct[2].Status__c = 'Active';
			prjct[3].Status__c = 'Active';
			update prjct;
		} catch (Exception ae){
		}
	}

	static testmethod void updateAccountPicklist_Test(){
		//Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Directed Fund'].Id;
		testFactory.getAccount();
		Project__c proj = new Project__c();
		proj.Name = 'New Test Project';
		//proj.RecordTypeId = directedProjectId;
		proj.Status__c = 'Planned';
		proj.Type__c = 'Membership';
		proj.Category__c = 'Subproject';
		proj.LF_Membership_Required__c = true;
		proj.Manual_Status_Check__c = false;
		proj.Slug__c = 'testing';
		insert proj;

		proj.Status__c = 'Active';
		proj.Manual_Status_Check__c = false;
		Test.startTest();
		update proj;
		Test.stopTest();

		System.assertEquals(True, [Select Project_Processing__c
		                           From Project__c
		                           Where Name = 'New Test Project'].Project_Processing__c);
	}

	static testmethod void updateEDandPMgrUserFields(){
		User usr = TestFactory.getUser();
		usr.IsActive = TRUE;
		update usr;

		Contact con = new Contact();
		con.LastName = 'testContact';
		con.Email = 'standarduser123@testorg.com';
		Insert con;

		//Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Directed Fund'].Id;

		Project__c proj = new Project__c();
		proj.Name = 'Test Project';
		//proj.RecordTypeId = directedProjectId;
		proj.Status__c = 'Planned';
		proj.Type__c = 'Membership';
		proj.Category__c = 'Subproject';
		proj.LF_Membership_Required__c = true;
		proj.Project_Type__c = 'Project Group';
		proj.Program_Manager__c = con.id;
		proj.Executive_Director__c = con.id;
		proj.Slug__c = 'testing';
        Insert proj;

		Project__c project = [Select ID, Program_Manager_U__c, Program_Manager__c, Executive_Director_U__c
		                      From Project__c
		                      WHERE Name = 'Test Project'];

		System.assertEquals(project.Program_Manager_U__c, usr.id);
		System.assertEquals(project.Executive_Director_U__c, usr.id);
	}

	@isTest
	public static void updateDaysToDeduct_Test(){
		//Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Directed Fund'].Id;


		Account acc = new Account(Name = 'Test account', billingStreet = 'street', billingCountry = 'brasil');
		insert acc;

		Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id, email = 'test@gmail.com');
		insert con;

		Opportunity oppt = new Opportunity(Name = 'Opportunity testing 1', accountId = acc.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		Product2 prod = new Product2(Name = 'TestP', productcode = 'test', Family = 'Membership');
		insert prod;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;

		Project__c project1 = new Project__c(Name = 'LF Networking', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Subsidiary_ID__c = 8, Slug__c = 'testing');
		insert project1;

		Product_Details__c proDetail = new Product_Details__c(Netsuite_ID__c = '1111', Project__c = project1.id, Products__c = prod.id, Price__c = 100, Description__c = 'Test Membership Product Detail');
		insert proDetail;

		OpportunityLineItem oli = new OpportunityLineItem(Billing_Contact__c = con.id, Representative_Voting_Contact__c = con.id, Authorized_Signatory__c = con.Id, Projects__c = project1.id, Product_Details__c = proDetail.id, OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, start_date__c = date.today(), end_date__c = date.today().addDays(2), Number_of_years_required__c = 1, order__c = 1, NetSuite_ID__c = '14823', NS_Entity_ID__c = '18765', Renewal_type__c = 'Prorate');
		insert oli;

		OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = oppt.id, contactid = con.id, role = 'Decision Maker');
		insert ocr;

		List<Asset> assetList = new List<Asset>();

		Asset assetObj2 = new Asset(Name = 'Test Asset', Projects__c = oli.Projects__c, usageenddate = Date.newInstance(System.today().year(), 12, 05), Auto_Renew__c = TRUE, Renewal_Opportunity_Created__c = FALSE, CNCF_Level__c = oli.CNCF_Level__c, Press_Release_Announcement__c = oli.No_Press_Release_Announcement__c, Display_Logo_On_Website__c = oli.Display_Logo_On_Website__c, NetSuite_Id__c = oli.NetSuite_Id__c, NS_Entity_ID__c = oli.NS_Entity_ID__c, order__c = oli.order__c, Bill_To_Account__c = oli.Opportunity.Bill_To_Account__c, Bill_To_Address__c = oli.Opportunity.Bill_To_Address__c, OpportunityLineItem__c = oli.id, Opportunity__c = oppt.Id);
		assetList.add(assetObj2);
		insert assetList;
		Opportunity renewOppt = new Opportunity(Name = 'Opportunity testing 1', accountId = acc.Id, StageName = '5. Decision Commitment', Type = 'Renewal', CloseDate = Date.today().addDays(4), parent_asset__c = assetList[0].Id);
		insert renewOppt;
		OpportunityLineItem renewoli = new OpportunityLineItem(Projects__c = project1.id, Product_Details__c = proDetail.id, OpportunityId = renewOppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, start_date__c = date.today(), end_date__c = date.today().addDays(2), Number_of_years_required__c = 1, order__c = 1);
		insert renewoli;

		List<OpportunityLineItem> oppLineItem = [SELECT Id, OpportunityId, opportunity.parent_asset__r.UsageEndDate, Opportunity.closedate, Projects__r.Days_to_Deduct__c
		                                         FROM OpportunityLineItem
		                                         WHERE Projects__c = :project1.id and Opportunity.Hold__c = false and opportunity.IsClosed = false and opportunity.type like 'Renewal%' and opportunity.parent_asset__c != null];
		System.debug('project 1' + project1.id);
		system.debug(oppLineItem.size());
		Test.startTest();
		project1.Days_to_Deduct__c = '60';
		update project1;
		Test.stopTest();

		// System.assertEquals(True, [Select Project_Processing__c From Project__c Where Name = 'New Test Project'].Project_Processing__c);
	}
}