@isTest
public Class OpportunityProductTriggerTest{

	@testSetup
	private static void createTestData() {
		/* quote sync field */
		QuoteSyncField__c quoteSyncField = new QuoteSyncField__c(Name = 'PaymentTerms__c', OppSyncField__c = 'PaymentTerms__c');
		insert quoteSyncField;

		/* quote line sync field */
		QuoteLineSyncField__c quoteLineSyncField = new QuoteLineSyncField__c(Name = 'Agreement_Date__c', OppLineSyncField__c = 'AgreementDate__c');
		insert quoteLineSyncField;


		User standard = TestFactory.getUser();
        User user = TestDataUtils.createUser(true,'TestUser');

		Account acc = new Account(Name = 'Test account', billingStreet = 'street');
		insert acc;

		Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
		insert con;

		//INSERT MEMBERSHIP PRODUCT
		Product2 prodId = TestDataUtils.createProduct('Platinumm Membership', 'description', 6, 'Membership');
		prodId.IsActive = true;
		update prodId;
		//INSERT FREE TRAINING PRODUCT
		Product2 prodId2 = TestDataUtils.createProduct('Free Training', 'description', 6, 'Training');

		List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = Test.getStandardPricebookId(), Product2Id = prodId.ID, isActive = true, unitPrice = 34);
		pbeList.add(standardPbe);

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = Test.getStandardPricebookId(), isActive = true, Product2Id = prodId2.ID, unitPrice = 20.0, useStandardPrice = false);
		pbeList.add(pbe);
		insert pbeList;

	}

	static testmethod void updateOpportunityOwner(){
		List<User> userList =[SELECT Id FROM User WHERE Lastname IN ('mike','jordan')];
		Project__c project = TestFactory.getProject();
		Project.Name = 'The Linux Foundation';
		project.Opportunity_Owner__c = userList[0].id;
		update project;
		
		Opportunity opportunity = TestFactory.getOpportunity();
		PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Product2.Family = 'Membership' LIMIT 1];

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opportunity.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project.id);
		insert oli;

		Opportunity opp = [Select Id, Owner.Name
		                   From Opportunity];

		System.assertEquals(userList[0].id, opp.OwnerId);

		Project__c prj = TestDataUtils.createProject(true, 'Test Linux Foundation', 'Event', 'Directed Fund', 'Planned');
        prj.Subsidiary_ID__c = 8;
        prj.Status__c = 'Active';
        prj.Funding__c = 'Funded';
		prj.Renewal_Owner__c = userList[1].id;
        update prj;

		OpportunityLineItem oppline = new OpportunityLineItem(OpportunityId = opportunity.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = prj.id);
		insert oppline;

		//System.assertEquals(userList[1].id, opp.OwnerId);
	}

	@istest
	static void oppLineSyncMethod_Test(){
		Opportunity memberShipOpp = TestFactory.getOpportunity();

		PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Product2.Family = 'Membership' LIMIT 1];

		Project__c project = TestFactory.getProject();

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = memberShipOpp.Id, Quantity = 2, UnitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project.Id);
		insert oli;
		List<OpportunityLineItem> oliList = [SELECT Id,PriceBookEntryId,Product2Id,OpportunityId,Projects__c
		                                     FROM OpportunityLineItem
		                                     Where Projects__c != null];
											 Quote quote = new Quote();
		quote.Name = 'Test Quote';
		quote.OpportunityId = memberShipOpp.Id;
		insert quote;

		
			QuoteLineItem qli = new QuoteLineItem(QuoteId = quote.Id, OpportunityLineItemId = oli.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = oli.PriceBookEntryId, Projects__c = oli.Projects__c);
	
	
		insert qli;
		
		Test.startTest();
		Opportunity oppt = new Opportunity(Id = memberShipOpp.Id);
		oppt.SyncedQuoteId = quote.id;
		update oppt;
		oli.AgreementDate__c = Date.today() + 2;
		update oli;
		Test.stopTest();
	}
	
	static testMethod void prorateOpportunityLineItem_Test() {
		Opportunity opportunity = TestFactory.getOpportunity();
		opportunity.Type = 'Renewal';
		opportunity.Original_Renewal_Amount__c = 0;
		update opportunity;

		PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Product2.Family = 'Membership' LIMIT 1];

		List<User> userList =[SELECT Id FROM User WHERE Lastname IN ('mike','jordan')];
		Project__c project = TestFactory.getProject();
		project.Opportunity_Owner__c = userList[0].id;
		update project;

		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.Quantity = 0.567;
        opportunityLineItem.Renewal_Type__c = 'Prorate';
        opportunityLineItem.PO_Number__c = '123';
        opportunityLineItem.TotalPrice = 10000.00;
        opportunityLineItem.PricebookEntryId = pbe.id;
        opportunityLineItem.OpportunityId = opportunity.Id;
		opportunityLineItem.Projects__c = project.id;
		oliList.add(opportunityLineItem);

		OpportunityLineItem opportunityLineItem1 = new OpportunityLineItem();
        opportunityLineItem1.Quantity = 0.567;
        opportunityLineItem1.Renewal_Type__c = 'Non-Prorate';
        opportunityLineItem1.PO_Number__c = '123';
        opportunityLineItem1.TotalPrice = 10000.00;
        opportunityLineItem1.PricebookEntryId = pbe.id;
        opportunityLineItem1.OpportunityId = opportunity.Id;
		opportunityLineItem1.Projects__c = project.id;
		oliList.add(opportunityLineItem1);
        insert oliList;  
        System.assertEquals(10000.00, [SELECT Id,Original_Renewal_Amount__c	 FROM Opportunity WHERE Id =: opportunity.Id].Original_Renewal_Amount__c, 'Original renewal Amount must got updated');

        
        Test.startTest();
        oliList[0].PO_Number__c = '345';
        oliList[1].PO_Number__c = '345';
        update oliList;
   
        OpportunityLineItem oli2 = [select id, quantity from OpportunityLineItem where id = :oliList[0].id];
        System.assertEquals(0.567, oli2.Quantity, 'Original quantity was incorrectly overridden');

        OpportunityLineItem oli3 = [select id, quantity from OpportunityLineItem where id = :oliList[1].id];
		system.assertEquals(1, oli3.Quantity, 'For Non-Prorate quantity should have been 1.0'); 

        Test.stopTest();
    }
    
  

	@isTest
	static void insertContactRoleForIndividualMembership_test(){
		Account acc = new Account(Name = 'Test account');
		insert acc;

		Contact contact = new Contact();
		contact.AccountId = acc.Id;
		contact.LastName = 'Test Contact';
		insert contact;

		Project__c project1 = new Project__c(Name = 'test Project', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Slug__c = 'testing');
		insert project1;

		Opportunity oppt = new Opportunity(Name = 'Opportunity testing for Contactrole', accountId = acc.Id, Billing_Contact__c = contact.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		Product2 prod = new Product2(Name = 'Individual Membership', productcode = 'test');
		insert prod;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Product2Id = prod.Id, Required_Active_LF_Membership__c = true, Projects__c = project1.id);
		insert oli;

		System.assertEquals('Membership Decision Maker', [SELECT Id, OpportunityId, Role
		                                                  FROM OpportunityContactRole
		                                                  WHERE Contact.Name = 'Test Contact'].Role);
	}

	@isTest
	static void updateEngagementTypeOnOpportunity_test(){
		Account acc = new Account(Name = 'Test account');
		insert acc;

		Contact contact = new Contact();
		contact.AccountId = acc.Id;
		contact.LastName = 'Test Contact';
		insert contact;

		Training__c training = new Training__c(Name = 'test Training');
		insert training;

		Opportunity oppt = new Opportunity(Name = 'Opportunity testing for Contactrole', accountId = acc.Id, Billing_Contact__c = contact.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		Product2 prod = new Product2(Name = 'Certification', productcode = 'test', Type__c = 'Certification');
		insert prod;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Product2Id = prod.Id, Required_Active_LF_Membership__c = true, training__c = training.Id);
		insert oli;

		System.assertEquals('Certification', [SELECT Id, Engagement_Type__c
		                                      FROM Opportunity
		                                      WHERE Id = :oppt.Id][0].Engagement_Type__c);
	}

	@isTest
	static void updateInvoiceMemo_test(){
		Account acc = [SELECT Id FROM Account LIMIT 1];
		Contact con = [SELECT Id FROM Contact LIMIT 1];

		Training__c training = new Training__c(Name = 'test Training');
		insert training;

		Opportunity oppt = new Opportunity(Name = 'Opportunity testing for Contactrole', accountId = acc.Id, Billing_Contact__c = con.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True', Corporate_Training_Bundle__c = true, NetSuite_Invoice_Memo__c = 'Bulk');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
	
		Product2 prod = new Product2(Name = 'Certification', productcode = 'test', Type__c = 'Certification');
		insert prod;

		Product2 prod2 = new Product2(Name = 'Bulk', productcode = 'test bulk', Type__c = 'Bundle');
		insert prod2;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;


		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = standardPbe.ID, Product2Id = prod.Id, Required_Active_LF_Membership__c = true, training__c = training.Id, parent_Product__c = prod2.Id);
		insert oli;

		System.assertEquals('Certification', [SELECT Id, Engagement_Type__c
		                                      FROM Opportunity
		                                      WHERE Id = :oppt.Id][0].Engagement_Type__c);
		System.assertEquals('Bulk', [SELECT Id, NetSuite_Invoice_Memo__c
		                             FROM OpportunityLineItem
		                             WHERE Id = :oli.Id][0].NetSuite_Invoice_Memo__c);
	}

	
	@isTest
	static void updateInvoiceMemo_test1(){
		Account acc = [SELECT Id FROM Account LIMIT 1];
		Contact con = [SELECT Id FROM Contact LIMIT 1];

		Training__c training = new Training__c(Name = 'test Training');
		insert training;

		Opportunity oppt = new Opportunity(Name = 'Opportunity testing for Contactrole', accountId = acc.Id, Billing_Contact__c = con.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True', Corporate_Training_Bundle__c = true, NetSuite_Invoice_Memo__c = 'Bulk');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
	
		Product2 prod = new Product2(Name = 'Certification', productcode = 'test', Type__c = 'Certification');
		insert prod;

		Product2 prod2 = new Product2(Name = 'Bulk', productcode = 'test bulk', Type__c = 'Bundle');
		insert prod2;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry standardPbe1 = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod2.ID, isActive = true, unitPrice = 34);
		insert standardPbe1;


		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = standardPbe.ID, Product2Id = prod2.Id, Required_Active_LF_Membership__c = true, training__c = training.Id);
		insert oli;

		OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = standardPbe1.ID, Product2Id = prod.Id, Required_Active_LF_Membership__c = true, training__c = training.Id, parent_Product__c = prod2.Id,Parent_OppLineItem__c = oli.Id);
		insert oli2;

	oli.Description__c = 'Bundle Prod';
	oli.PO_Number__c = '534423';
	oli.NetSuite_Invoice_Memo__c = 'Test';
	update oli;
		System.assertEquals('534423', [SELECT Id, PO_Number__c
		                             FROM OpportunityLineItem
		                             WHERE Id = :oli2.Id][0].PO_Number__c);
	}

	@isTest
	public static void updateRenewalOpportunityOwner(){
		User standard = TestFactory.getUser();
		Project__c project = TestFactory.getProject();
		Project.Name = 'The Linux Foundation';
		project.Opportunity_Owner__c = standard.id;
		update project;
		Account acc = [SELECT Id FROM Account LIMIT 1];
		

		Contact con = [SELECT Id FROM Contact LIMIT 1];
		Opportunity opportunity1 = TestFactory.getOpportunity();
		opportunity1.Project_Name__c = project.Id;
		update opportunity1;
		PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Product2.Family = 'Membership' LIMIT 1];

		OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opportunity1.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project.id);
		insert oli2;

		OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opportunity1.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project.id);
		insert oli1;

	Asset asst1 = new Asset(Name = 'TEstcreateasset',AccountId = acc.Id,
                               Projects__c = project.Id , Status = 'Active',Opportunity__c = opportunity1.Id
                              );
        insert asst1;

		acc.LF_Membership_Only__c = false;
		update acc;
		Opportunity opportunity = new Opportunity(Name = 'Opportunity testing 1', accountId = acc.Id, StageName = '2. Discovery', CloseDate = Date.today().addDays(4),Parent_Asset__c=asst1.Id);
		opportunity.type = 'Renewal';
		insert opportunity;

		Product2 prod = new Product2(Name = 'Silver Membership', productcode = 'test');
		insert prod;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = Test.getStandardPricebookId(), Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opportunity.Id, Quantity = 2, Product2Id = prod.Id, unitPrice = 20, PriceBookEntryId = standardPbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project.id);
		insert oli;

		Opportunity opp = [Select Id, Owner.Name
		                   From Opportunity WHERE Id =: opportunity.Id];

		System.assertEquals(standard.id, opp.OwnerId);
	}

	@isTest
	public static void updateTrainingAndProductDetails_test(){

		Account acc = new Account(Name = 'Test account');
		insert acc;

		Contact contact = new Contact();
		contact.AccountId = acc.Id;
		contact.LastName = 'Test Contact';
		insert contact;

		Training__c training = new Training__c(Name = 'test Training');
		insert training;

		Id trainingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();

		Opportunity oppt = new Opportunity(Name = 'Opportunity testing for Contactrole', accountId = acc.Id, Billing_Contact__c = contact.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True', RecordTypeId = trainingRecordTypeId, NetSuite_Invoice_Memo__c = 'Bulk', Preferred_Invoice_Method__c = 'EMail');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		Product2 prod = new Product2(Name = 'Certification', productcode = 'test', Type__c = 'Certification', Family = 'Training', isActive = true);
		insert prod;

		Product2 prod2 = new Product2(Name = 'Bulk', productcode = 'test bulk', Type__c = 'Bundle', Family = 'Training', isActive = true);
		insert prod2;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Product2Id = prod.Id, Required_Active_LF_Membership__c = true, training__c = training.Id, parent_Product__c = prod2.Id);
		insert oli;

		Training__c newTraining = new Training__c(Name = 'test Training 2');
		insert newTraining;

		Product_Details__c Pd = new Product_Details__c();
		Pd.Price__c = 56;
		Pd.NS_Income_GL_Account__c = '290';
		pd.NS_Deferred_Revenue_Account__c = '284';
		pd.NS_Department__c = '10';
		pd.NS_Revenue_Schedule__c = '29';
		Pd.Netsuite_Sync__c = false;
		Pd.Duration__c = '45';
		Pd.Description__c = 'Description_Test';
		Pd.Tier__c = 'Test';
		pd.Netsuite_ID__c = '889955';
		pd.Training__c = newTraining.Id;
		pd.Products__c = prod.id;
		insert Pd;

		oli.Overwrite_Training_Product__c = newTraining.Id;
		update oli;
		System.assertEquals(newTraining.Id, [SELECT Id, Training__c
		                                     FROM OpportunityLineItem
		                                     WHERE Id = :oli.Id][0].Training__c);
	}

	@isTest
	public static void testUpdateAssociatedRoles(){
		Account acc = new Account(Name = 'Test account');
		insert acc;

		Contact con = new Contact();
		con.AccountId = acc.Id;
		con.LastName = 'Test Contact';
		insert con;

		Contact con2 = new Contact();
		con2.AccountId = acc.Id;
		con2.LastName = 'Test Contact2';
		insert con2;

		Training__c training = new Training__c(Name = 'test Training');
		insert training;

		Id trainingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();

		Opportunity opp = new Opportunity(Name = 'Opportunity testing for Contactrole', accountId = acc.Id, Billing_Contact__c = con.Id, StageName = '2. Discovery', Type = 'New Business', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True', RecordTypeId = trainingRecordTypeId, NetSuite_Invoice_Memo__c = 'Bulk', Preferred_Invoice_Method__c = 'Email');
		insert opp;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		//INSERT MEMBERSHIP PRODUCT
		Product2 prod = TestDataUtils.createProduct('hyperledger', 'description', 6, 'Membership');

		//INSERT MEMBERSHIP PRODUCT
		Product2 prod2 = TestDataUtils.createProduct('hyperledger2', 'description', 6, 'Membership');

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;

		Project__c project = TestDataUtils.createProject(true, 'The Linux Foundation', 'Event', 'Subproject', 'Planned');

		OpportunityLineItem oli = TestDataUtils.createOpportunityProduct(opp.id, pbe.id);
		oli.Projects__c = project.Id;
		oli.Technical_Contact__c = con.Id;
		oli.Marketing_Contact__c = con.Id;
		oli.Press_Contact__c = con.Id;
		oli.Legal_Contact__c = con.Id;
		oli.PO_Contact__c = con.Id;
		oli.Authorized_Signatory__c = con.Id;
		oli.Billing_Contact__c = con.Id;
		oli.Billing_Contact2__c = con.Id;
		oli.Billing_Contact3__c = con.Id;
		oli.Marketing_Contact_2__c = con.Id;
		oli.Marketing_Contact_3__c = con.Id;
		oli.Technical_Contact_2__c = con.Id;
		oli.Technical_Contact_3__c = con.Id;
		oli.Sponsorship_Contact__c = con.Id;
		update oli;

		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c objProjectRole = new Project_Role__c();
		objProjectRole.status__c = 'Active';
		objProjectRole.Contact__c = con.id;
		objProjectRole.Role__c = 'Billing Contact';
		objProjectRole.Opportunity__c = opp.Id;
		objProjectRole.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole);

		Project_Role__c objProjectRole1 = new Project_Role__c();
		objProjectRole1.status__c = 'Active';
		objProjectRole1.Contact__c = con.id;
		objProjectRole1.Role__c = 'Representative/Voting Contact';
		objProjectRole1.Opportunity__c = opp.Id;
		objProjectRole1.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole1);

		Project_Role__c objProjectRole2 = new Project_Role__c();
		objProjectRole2.status__c = 'Active';
		objProjectRole2.Contact__c = con.id;
		objProjectRole2.Role__c = 'Technical Contact';
		objProjectRole2.Opportunity__c = opp.Id;
		objProjectRole2.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole2);

		Project_Role__c objProjectRole3 = new Project_Role__c();
		objProjectRole3.status__c = 'Active';
		objProjectRole3.Contact__c = con.id;
		objProjectRole3.Role__c = 'Marketing Contact';
		objProjectRole3.Opportunity__c = opp.Id;
		objProjectRole3.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole3);

		Project_Role__c objProjectRole4 = new Project_Role__c();
		objProjectRole4.status__c = 'Active';
		objProjectRole4.Contact__c = con.id;
		objProjectRole4.Role__c = 'Press Contact';
		objProjectRole4.Opportunity__c = opp.Id;
		objProjectRole4.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole4);

		Project_Role__c objProjectRole5 = new Project_Role__c();
		objProjectRole5.status__c = 'Active';
		objProjectRole5.Contact__c = con.id;
		objProjectRole5.Role__c = 'Legal Contact';
		objProjectRole5.Opportunity__c = opp.Id;
		objProjectRole5.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole5);

		Project_Role__c objProjectRole6 = new Project_Role__c();
		objProjectRole6.status__c = 'Active';
		objProjectRole6.Contact__c = con.id;
		objProjectRole6.Role__c = 'Authorized Signatory';
		objProjectRole6.Opportunity__c = opp.Id;
		objProjectRole6.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole6);

		Project_Role__c objProjectRole7 = new Project_Role__c();
		objProjectRole7.status__c = 'Active';
		objProjectRole7.Contact__c = con.id;
		objProjectRole7.Role__c = 'Event Sponsorship';
		objProjectRole7.Opportunity__c = opp.Id;
		objProjectRole7.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole7);

		Project_Role__c objProjectRole8 = new Project_Role__c();
		objProjectRole8.status__c = 'Active';
		objProjectRole8.Contact__c = con.id;
		objProjectRole8.Role__c = 'PO Contact';
		objProjectRole8.Opportunity__c = opp.Id;
		objProjectRole8.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole8);

		Project_Role__c objProjectRole9 = new Project_Role__c();
		objProjectRole9.status__c = 'Active';
		objProjectRole9.Contact__c = con.id;
		objProjectRole9.Role__c = 'Technical Contact 3';
		objProjectRole9.Opportunity__c = opp.Id;
		objProjectRole9.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole9);

		Project_Role__c objProjectRole10 = new Project_Role__c();
		objProjectRole10.status__c = 'Active';
		objProjectRole10.Contact__c = con.id;
		objProjectRole10.Role__c = 'Technical Contact 2';
		objProjectRole10.Opportunity__c = opp.Id;
		objProjectRole10.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole10);

		Project_Role__c objProjectRole11 = new Project_Role__c();
		objProjectRole11.status__c = 'Active';
		objProjectRole11.Contact__c = con.id;
		objProjectRole11.Role__c = 'Billing Contact 2';
		objProjectRole11.Opportunity__c = opp.Id;
		objProjectRole11.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole11);

		Project_Role__c objProjectRole12 = new Project_Role__c();
		objProjectRole12.status__c = 'Active';
		objProjectRole12.Contact__c = con.id;
		objProjectRole12.Role__c = 'Billing Contact 3';
		objProjectRole12.Opportunity__c = opp.Id;
		objProjectRole12.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole12);

		Project_Role__c objProjectRole13 = new Project_Role__c();
		objProjectRole13.status__c = 'Active';
		objProjectRole13.Contact__c = con.id;
		objProjectRole13.Role__c = 'Marketing Contact 2';
		objProjectRole13.Opportunity__c = opp.Id;
		objProjectRole13.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole13);

		Project_Role__c objProjectRole14 = new Project_Role__c();
		objProjectRole14.status__c = 'Active';
		objProjectRole14.Contact__c = con.id;
		objProjectRole14.Role__c = 'Marketing Contact 3';
		objProjectRole14.Opportunity__c = opp.Id;
		objProjectRole14.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole14);

		insert projectRoles;

		Test.startTest();
		//to update
		oli.Representative_Voting_Contact__c = con2.Id;
		oli.Technical_Contact__c = con2.Id;
		oli.Marketing_Contact__c = con2.Id;
		oli.Press_Contact__c = con2.Id;
		oli.Legal_Contact__c = con2.Id;
		oli.PO_Contact__c = con2.Id;
		oli.Authorized_Signatory__c = con2.Id;
		oli.Billing_Contact__c = con2.Id;
		oli.Billing_Contact2__c = con2.Id;
		oli.Billing_Contact3__c = con2.Id;
		oli.Marketing_Contact_2__c = con2.Id;
		oli.Marketing_Contact_3__c = con2.Id;
		oli.Technical_Contact_2__c = con2.Id;
		oli.Technical_Contact_3__c = con2.Id;
		oli.Sponsorship_Contact__c = con2.Id;
		OpportunityProductTriggerHandler.OpportunityProductTriggerRecursion = true;
		update oli;
		Test.stopTest();

		//to delete
		oli.Representative_Voting_Contact__c = null;
		oli.Technical_Contact__c = null;
		oli.Marketing_Contact__c = null;
		oli.Press_Contact__c = null;
		oli.Legal_Contact__c = null;
		oli.PO_Contact__c = null;
		oli.Authorized_Signatory__c = null;
		oli.Billing_Contact__c = null;
		oli.Billing_Contact2__c = null;
		oli.Billing_Contact3__c = null;
		oli.Marketing_Contact_2__c = null;
		oli.Marketing_Contact_3__c = null;
		oli.Technical_Contact_2__c = null;
		oli.Technical_Contact_3__c = null;
		oli.Sponsorship_Contact__c = null;
		OpportunityProductTriggerHandler.OpportunityProductTriggerRecursion = true;
		update oli;

		delete oli;
	}

	public static testMethod void testinsertChildProductDetail(){

		Account acc = TestDataUtils.createAccount(true, 'Test Account');
		Opportunity oppt = TestDataUtils.createOpenOpportunity(false, acc.Id, 'New Deal Test', '2. Discovery');
		oppt.Type = 'New Business';
		insert oppt;

		List<Product2> prodList = new List<Product2>();
		Product2 prod = TestDataUtils.createProduct(false, 'Laptop X200', 'Test Product', true, 'Membership');
		prod.IsActive = true;
		prodList.add(prod);

		Product2 prod1 = TestDataUtils.createProduct(false, 'Laptop X300', 'Test New Product', true, 'Membership');
		prod1.IsActive = true;
		prodList.add(prod1);
		insert prodList;

		List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
		PricebookEntry pbEntry = TestDataUtils.createPriceBookEntryID(false, prodList[0].Id);
		PricebookEntry pbEntry1 = TestDataUtils.createPriceBookEntryID(false, prodList[1].Id);
		pricebookEntryList.add(pbEntry);
		pricebookEntryList.add(pbEntry1);
		insert pricebookEntryList;

		//just to make standard pricbook.isstandard field accessible in code as without this we were not able to get this.
		Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
		update standardPricebook;

		List<Project__c> projectList = new List<Project__c>();
		Project__c project = TestDataUtils.createProject(true, 'test Project', 'Membership', 'Subproject', 'Planned');
		project.status__c = 'Active';
		project.Type__c = 'Membership';
		project.Category__c = 'Subproject';
		project.Model__c = 'Membership';
		project.LF_Membership_Required__c = true;
		project.Manual_Status_Check__c = false;
		projectList.add(project);

		Project__c project1 = TestDataUtils.createProject(false, 'test Child Project', 'Membership', 'Subproject', 'Planned');
		project1.Status__c = 'Planned';
		project1.Type__c = 'Membership';
		project1.Category__c = 'Subproject';
		project1.Model__c = 'Membership';
		project1.LF_Membership_Required__c = true;
		project1.Manual_Status_Check__c = false;
        project1.Slug__c = 'testing1';
        insert project1;

        project1.Status__c = 'Active';
        projectList.add(project1);

		update projectList;

		Product_Details__c pd = TestDataUtils.createProductDetail(false, projectList[0].Id, null, null, prodList[0].Id);
		pd.status__c = 'Active';
		pd.Price__c = 6000;
		insert pd;

		Product_Details__c pd1 = TestDataUtils.createProductDetail(false, projectList[1].Id, null, null, prodList[1].Id);
		pd1.status__c = 'Active';
		pd1.Price__c = 6000;
		pd1.Parent_Product_Detail__c = pd.Id;
		insert pd1;
		Id prodId = prodList[1].Id;

		OpportunityLineItem oli = TestDataUtils.createOpportunityProduct(false, oppt.Id, pricebookEntryList[0].Id);
		oli.Product_Details__c = pd.Id;
		oli.projects__c = projectList[0].Id;

		Test.startTest();
		insert oli;
		Test.stopTest();
	}
	
	static testmethod void updateRenewalOpportunityFields_Test(){
			User standard = TestFactory.getUser();
			Project__c project = TestFactory.getProject();
			Project.Name = 'The Linux Foundation';
			project.Opportunity_Owner__c = standard.id;
			update project;
			Account acc = [SELECT Id FROM Account LIMIT 1];
			
	
			Contact con = [SELECT Id FROM Contact LIMIT 1];
		
			PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Product2.Family = 'Membership' LIMIT 1];
	
			
	
			acc.NumberofEmployees = 200;
			update acc;
			Opportunity opportunity = new Opportunity(Name = 'Opportunity testing 1', accountId = acc.Id, StageName = '2. Discovery', CloseDate = Date.today().addDays(4));
			opportunity.type = 'Renewal';
			insert opportunity;
	
			Product2 prod = new Product2(Name = 'Associate Membership', productcode = 'test',Family = 'Membership');
			insert prod;
	
			PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = Test.getStandardPricebookId(), Product2Id = prod.ID, isActive = true, unitPrice = 34);
			insert standardPbe;
	
			Product_Details__c prodDetail = new Product_Details__c();
			prodDetail.Price__c = 56;
			prodDetail.Project__c = project.Id;
			prodDetail.NS_Income_GL_Account__c = '290';
			prodDetail.NS_Deferred_Revenue_Account__c = '284';
			prodDetail.NS_Department__c = '10';
			prodDetail.NS_Revenue_Schedule__c = '29';
			prodDetail.Netsuite_Sync__c = false;
			prodDetail.Products__c = prod.id;
			prodDetail.Duration__c = '45';
			prodDetail.Description__c = 'Description_Test';
			prodDetail.End_Tier__c = 100;
			prodDetail.Netsuite_ID__c = '889955';
			insert prodDetail;

			OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opportunity.Id, Quantity = 2, Product2Id = prod.Id, unitPrice = 20, PriceBookEntryId = standardPbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project.id,product_details__c = prodDetail.Id);
			insert oli;
	
			Opportunity opp = [Select Id, Owner.Name
							   From Opportunity WHERE Id =: opportunity.Id];
	
			System.assertEquals(standard.id, opp.OwnerId);
		}
}