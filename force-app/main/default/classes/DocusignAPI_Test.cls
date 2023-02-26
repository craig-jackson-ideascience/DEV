@isTest
public class DocusignAPI_Test{
	@TestSetup
	static void testData(){
	}

	@isTest
	static void mDebugUntruncated_Test(){
		DocusignAPI.mDebugUntruncated('hello');
	}

	@isTest
	static void getPRValue_Test(){
		Docusign_Settings__c setting = new Docusign_Settings__c();
		setting.AccountID__c = '34b9d81f-63d3-48cb-968d-72fc1a9df29f';
		//Docusign_Settings__c setting = Docusign_Settings__c.getOrgDefaults();
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		Account acc = new Account(Name = 'Test account', billingStreet = 'street');
		insert acc;

		Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
		insert con;

		Project__c project1 = new Project__c(Name = 'test Project', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Slug__c = 'testing1');
		insert project1;

		Opportunity oppt = new Opportunity(Name = 'Opportunity testing 1', accountId = acc.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		Product2 prod = new Product2(Name = 'TestP', productcode = 'test');
		insert prod;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project1.id);
		insert oli;
		oliList.add(oli);

		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c objProjectRole = new Project_Role__c();
		objProjectRole.status__c = 'Active';
		objProjectRole.Contact__c = con.id;
		objProjectRole.Role__c = 'Billing Contact';
		objProjectRole.PrimaryContact__c = true;
		objProjectRole.Opportunity__c = oppt.Id;
		objProjectRole.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole);

		Project_Role__c objProjectRole1 = new Project_Role__c();
		objProjectRole1.status__c = 'Active';
		objProjectRole1.Contact__c = con.id;
		objProjectRole1.Role__c = 'Representative/Voting Contact';
		objProjectRole1.PrimaryContact__c = true;
		objProjectRole1.Opportunity__c = oppt.Id;
		objProjectRole1.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole1);

		Project_Role__c objProjectRole2 = new Project_Role__c();
		objProjectRole2.status__c = 'Active';
		objProjectRole2.Contact__c = con.id;
		objProjectRole2.Role__c = 'Technical Contact';
		objProjectRole2.PrimaryContact__c = true;
		objProjectRole2.Opportunity__c = oppt.Id;
		objProjectRole2.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole2);

		Project_Role__c objProjectRole3 = new Project_Role__c();
		objProjectRole3.status__c = 'Active';
		objProjectRole3.Contact__c = con.id;
		objProjectRole3.Role__c = 'Marketing Contact';
		objProjectRole3.PrimaryContact__c = true;
		objProjectRole3.Opportunity__c = oppt.Id;
		objProjectRole3.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole3);

		Project_Role__c objProjectRole4 = new Project_Role__c();
		objProjectRole4.status__c = 'Active';
		objProjectRole4.Contact__c = con.id;
		objProjectRole4.Role__c = 'Press Contact';
		objProjectRole4.PrimaryContact__c = true;
		objProjectRole4.Opportunity__c = oppt.Id;
		objProjectRole4.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole4);

		Project_Role__c objProjectRole5 = new Project_Role__c();
		objProjectRole5.status__c = 'Active';
		objProjectRole5.Contact__c = con.id;
		objProjectRole5.Role__c = 'Legal Contact';
		objProjectRole5.PrimaryContact__c = true;
		objProjectRole5.Opportunity__c = oppt.Id;
		objProjectRole5.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole5);

		Project_Role__c objProjectRole6 = new Project_Role__c();
		objProjectRole6.status__c = 'Active';
		objProjectRole6.Contact__c = con.id;
		objProjectRole6.Role__c = 'Authorized Signatory';
		objProjectRole6.PrimaryContact__c = true;
		objProjectRole6.Opportunity__c = oppt.Id;
		objProjectRole6.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole6);

		Project_Role__c objProjectRole7 = new Project_Role__c();
		objProjectRole7.status__c = 'Active';
		objProjectRole7.Contact__c = con.id;
		objProjectRole7.Role__c = 'Event Sponsorship';
		objProjectRole7.PrimaryContact__c = true;
		objProjectRole7.Opportunity__c = oppt.Id;
		objProjectRole7.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole7);

		Project_Role__c objProjectRole8 = new Project_Role__c();
		objProjectRole8.status__c = 'Active';
		objProjectRole8.Contact__c = con.id;
		objProjectRole8.Role__c = 'PO Contact';
		objProjectRole8.PrimaryContact__c = true;
		objProjectRole8.Opportunity__c = oppt.Id;
		objProjectRole8.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole8);

		insert projectRoles;

		Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp());

		Test.startTest();
		String envelopId = DocusignApi.createEnvelope(oppt.Id);

		Test.stopTest();
	}

	@isTest
	static void getLFMergeFields_Test(){
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		Account acc = new Account(Name = 'Test account', billingStreet = 'street');
		insert acc;

		Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
		insert con;

		Project__c project1 = new Project__c(Name = 'The Linux Foundation', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Slug__c = 'testing2');
		insert project1;

		Opportunity oppt = new Opportunity(Name = 'Opportunity testing 1', accountId = acc.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		Product2 prod = new Product2(Name = 'TestP', productcode = 'test');
		insert prod;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project1.id);
		insert oli;
		oliList.add(oli);

		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c objProjectRole = new Project_Role__c();
		objProjectRole.status__c = 'Active';
		objProjectRole.Contact__c = con.id;
		objProjectRole.Role__c = 'Billing Contact';
		objProjectRole.PrimaryContact__c = true;
		objProjectRole.Opportunity__c = oppt.Id;
		objProjectRole.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole);

		Project_Role__c objProjectRole1 = new Project_Role__c();
		objProjectRole1.status__c = 'Active';
		objProjectRole1.Contact__c = con.id;
		objProjectRole1.Role__c = 'Representative/Voting Contact';
		objProjectRole1.PrimaryContact__c = true;
		objProjectRole1.Opportunity__c = oppt.Id;
		objProjectRole1.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole1);

		Project_Role__c objProjectRole2 = new Project_Role__c();
		objProjectRole2.status__c = 'Active';
		objProjectRole2.Contact__c = con.id;
		objProjectRole2.Role__c = 'Technical Contact';
		objProjectRole2.PrimaryContact__c = true;
		objProjectRole2.Opportunity__c = oppt.Id;
		objProjectRole2.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole2);

		Project_Role__c objProjectRole3 = new Project_Role__c();
		objProjectRole3.status__c = 'Active';
		objProjectRole3.Contact__c = con.id;
		objProjectRole3.Role__c = 'Marketing Contact';
		objProjectRole3.PrimaryContact__c = true;
		objProjectRole3.Opportunity__c = oppt.Id;
		objProjectRole3.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole3);

		Project_Role__c objProjectRole4 = new Project_Role__c();
		objProjectRole4.status__c = 'Active';
		objProjectRole4.Contact__c = con.id;
		objProjectRole4.Role__c = 'Press Contact';
		objProjectRole4.PrimaryContact__c = true;
		objProjectRole4.Opportunity__c = oppt.Id;
		objProjectRole4.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole4);

		Project_Role__c objProjectRole5 = new Project_Role__c();
		objProjectRole5.status__c = 'Active';
		objProjectRole5.Contact__c = con.id;
		objProjectRole5.Role__c = 'Legal Contact';
		objProjectRole5.PrimaryContact__c = true;
		objProjectRole5.Opportunity__c = oppt.Id;
		objProjectRole5.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole5);

		Project_Role__c objProjectRole6 = new Project_Role__c();
		objProjectRole6.status__c = 'Active';
		objProjectRole6.Contact__c = con.id;
		objProjectRole6.Role__c = 'Authorized Signatory';
		objProjectRole6.PrimaryContact__c = true;
		objProjectRole6.Opportunity__c = oppt.Id;
		objProjectRole6.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole6);

		Project_Role__c objProjectRole7 = new Project_Role__c();
		objProjectRole7.status__c = 'Active';
		objProjectRole7.Contact__c = con.id;
		objProjectRole7.Role__c = 'Event Sponsorship';
		objProjectRole7.PrimaryContact__c = true;
		objProjectRole7.Opportunity__c = oppt.Id;
		objProjectRole7.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole7);

		Project_Role__c objProjectRole8 = new Project_Role__c();
		objProjectRole8.status__c = 'Active';
		objProjectRole8.Contact__c = con.id;
		objProjectRole8.Role__c = 'PO Contact';
		objProjectRole8.PrimaryContact__c = true;
		objProjectRole8.Opportunity__c = oppt.Id;
		objProjectRole8.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole8);

		insert projectRoles;

		Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp());

		Test.startTest();
		DocusignApi.createEnvelope(oppt.Id);

		Test.stopTest();
	}

	@isTest
	static void sendEnvelop_Test(){
		Docusign_Settings__c setting = new Docusign_Settings__c();
		setting.AccountID__c = '34b9d81f-63d3-48cb-968d-72fc1a9df29f';
		//Docusign_Settings__c setting = Docusign_Settings__c.getOrgDefaults();
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		Account acc = new Account(Name = 'Test account', billingStreet = 'street');
		insert acc;

		Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
		insert con;

		Project__c project1 = new Project__c(Name = 'test Project', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Slug__c = 'testing4');
		insert project1;

		Opportunity oppt = new Opportunity(Name = 'Opportunity testing 1', accountId = acc.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		Product2 prod = new Product2(Name = 'TestP', productcode = 'test');
		insert prod;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project1.id);
		insert oli;
		oliList.add(oli);

		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c objProjectRole = new Project_Role__c();
		objProjectRole.status__c = 'Active';
		objProjectRole.Contact__c = con.id;
		objProjectRole.Role__c = 'Billing Contact';
		objProjectRole.PrimaryContact__c = true;
		objProjectRole.Opportunity__c = oppt.Id;
		objProjectRole.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole);

		Project_Role__c objProjectRole1 = new Project_Role__c();
		objProjectRole1.status__c = 'Active';
		objProjectRole1.Contact__c = con.id;
		objProjectRole1.Role__c = 'Representative/Voting Contact';
		objProjectRole1.PrimaryContact__c = true;
		objProjectRole1.Opportunity__c = oppt.Id;
		objProjectRole1.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole1);

		Project_Role__c objProjectRole2 = new Project_Role__c();
		objProjectRole2.status__c = 'Active';
		objProjectRole2.Contact__c = con.id;
		objProjectRole2.Role__c = 'Technical Contact';
		objProjectRole2.PrimaryContact__c = true;
		objProjectRole2.Opportunity__c = oppt.Id;
		objProjectRole2.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole2);

		Project_Role__c objProjectRole3 = new Project_Role__c();
		objProjectRole3.status__c = 'Active';
		objProjectRole3.Contact__c = con.id;
		objProjectRole3.Role__c = 'Marketing Contact';
		objProjectRole3.PrimaryContact__c = true;
		objProjectRole3.Opportunity__c = oppt.Id;
		objProjectRole3.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole3);

		Project_Role__c objProjectRole4 = new Project_Role__c();
		objProjectRole4.status__c = 'Active';
		objProjectRole4.Contact__c = con.id;
		objProjectRole4.Role__c = 'Press Contact';
		objProjectRole4.PrimaryContact__c = true;
		objProjectRole4.Opportunity__c = oppt.Id;
		objProjectRole4.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole4);

		Project_Role__c objProjectRole5 = new Project_Role__c();
		objProjectRole5.status__c = 'Active';
		objProjectRole5.Contact__c = con.id;
		objProjectRole5.Role__c = 'Legal Contact';
		objProjectRole5.PrimaryContact__c = true;
		objProjectRole5.Opportunity__c = oppt.Id;
		objProjectRole5.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole5);

		Project_Role__c objProjectRole6 = new Project_Role__c();
		objProjectRole6.status__c = 'Active';
		objProjectRole6.Contact__c = con.id;
		objProjectRole6.Role__c = 'Authorized Signatory';
		objProjectRole6.PrimaryContact__c = true;
		objProjectRole6.Opportunity__c = oppt.Id;
		objProjectRole6.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole6);

		Project_Role__c objProjectRole7 = new Project_Role__c();
		objProjectRole7.status__c = 'Active';
		objProjectRole7.Contact__c = con.id;
		objProjectRole7.Role__c = 'Event Sponsorship';
		objProjectRole7.PrimaryContact__c = true;
		objProjectRole7.Opportunity__c = oppt.Id;
		objProjectRole7.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole7);

		Project_Role__c objProjectRole8 = new Project_Role__c();
		objProjectRole8.status__c = 'Active';
		objProjectRole8.Contact__c = con.id;
		objProjectRole8.Role__c = 'PO Contact';
		objProjectRole8.PrimaryContact__c = true;
		objProjectRole8.Opportunity__c = oppt.Id;
		objProjectRole8.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole8);

		insert projectRoles;

		Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp());

		Test.startTest();
		String envelopId = DocusignApi.createEnvelope(oppt.Id);
		//System.assertEquals('test', envelopId);
		DocusignApi.sendEnvelope(envelopId);
		Test.stopTest();
	}

	@isTest
	static void getPreviewURL_Test(){
		Docusign_Settings__c setting = new Docusign_Settings__c();
		setting.AccountID__c = '34b9d81f-63d3-48cb-968d-72fc1a9df29f';
		//Docusign_Settings__c setting = Docusign_Settings__c.getOrgDefaults();
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		Account acc = new Account(Name = 'Test account', billingStreet = 'street');
		insert acc;

		Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
		insert con;

		Project__c project1 = new Project__c(Name = 'test Project', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Slug__c = 'testing3');
		insert project1;

		Opportunity oppt = new Opportunity(Name = 'Opportunity testing 1', accountId = acc.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		Product2 prod = new Product2(Name = 'TestP', productcode = 'test');
		insert prod;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project1.id);
		insert oli;
		oliList.add(oli);

		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c objProjectRole = new Project_Role__c();
		objProjectRole.status__c = 'Active';
		objProjectRole.Contact__c = con.id;
		objProjectRole.Role__c = 'Billing Contact';
		objProjectRole.PrimaryContact__c = true;
		objProjectRole.Opportunity__c = oppt.Id;
		objProjectRole.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole);

		Project_Role__c objProjectRole1 = new Project_Role__c();
		objProjectRole1.status__c = 'Active';
		objProjectRole1.Contact__c = con.id;
		objProjectRole1.Role__c = 'Representative/Voting Contact';
		objProjectRole1.PrimaryContact__c = true;
		objProjectRole1.Opportunity__c = oppt.Id;
		objProjectRole1.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole1);

		Project_Role__c objProjectRole2 = new Project_Role__c();
		objProjectRole2.status__c = 'Active';
		objProjectRole2.Contact__c = con.id;
		objProjectRole2.Role__c = 'Technical Contact';
		objProjectRole2.PrimaryContact__c = true;
		objProjectRole2.Opportunity__c = oppt.Id;
		objProjectRole2.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole2);

		Project_Role__c objProjectRole3 = new Project_Role__c();
		objProjectRole3.status__c = 'Active';
		objProjectRole3.Contact__c = con.id;
		objProjectRole3.Role__c = 'Marketing Contact';
		objProjectRole3.PrimaryContact__c = true;
		objProjectRole3.Opportunity__c = oppt.Id;
		objProjectRole3.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole3);

		Project_Role__c objProjectRole4 = new Project_Role__c();
		objProjectRole4.status__c = 'Active';
		objProjectRole4.Contact__c = con.id;
		objProjectRole4.Role__c = 'Press Contact';
		objProjectRole4.PrimaryContact__c = true;
		objProjectRole4.Opportunity__c = oppt.Id;
		objProjectRole4.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole4);

		Project_Role__c objProjectRole5 = new Project_Role__c();
		objProjectRole5.status__c = 'Active';
		objProjectRole5.Contact__c = con.id;
		objProjectRole5.Role__c = 'Legal Contact';
		objProjectRole5.PrimaryContact__c = true;
		objProjectRole5.Opportunity__c = oppt.Id;
		objProjectRole5.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole5);

		Project_Role__c objProjectRole6 = new Project_Role__c();
		objProjectRole6.status__c = 'Active';
		objProjectRole6.Contact__c = con.id;
		objProjectRole6.Role__c = 'Authorized Signatory';
		objProjectRole6.PrimaryContact__c = true;
		objProjectRole6.Opportunity__c = oppt.Id;
		objProjectRole6.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole6);

		Project_Role__c objProjectRole7 = new Project_Role__c();
		objProjectRole7.status__c = 'Active';
		objProjectRole7.Contact__c = con.id;
		objProjectRole7.Role__c = 'Event Sponsorship';
		objProjectRole7.PrimaryContact__c = true;
		objProjectRole7.Opportunity__c = oppt.Id;
		objProjectRole7.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole7);

		Project_Role__c objProjectRole8 = new Project_Role__c();
		objProjectRole8.status__c = 'Active';
		objProjectRole8.Contact__c = con.id;
		objProjectRole8.Role__c = 'PO Contact';
		objProjectRole8.PrimaryContact__c = true;
		objProjectRole8.Opportunity__c = oppt.Id;
		objProjectRole8.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole8);

		insert projectRoles;
		Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp());

		Test.startTest();
		String envelopId = DocusignApi.createEnvelope(oppt.Id);
		//System.assertEquals('test', envelopId);
		String retType = DocusignApi.getPreviewURL(envelopId);
		Test.stopTest();
		System.assertEquals(null, retType);
	}

	@isTest
	static void voidEnvelop_Test(){
		Docusign_Settings__c setting = new Docusign_Settings__c();
		setting.AccountID__c = '34b9d81f-63d3-48cb-968d-72fc1a9df29f';
		//Docusign_Settings__c setting = Docusign_Settings__c.getOrgDefaults();
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		Account acc = new Account(Name = 'Test account', billingStreet = 'street');
		insert acc;

		Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
		insert con;

		User standardUser = TestFactory.getUser();

		Project__c project1 = new Project__c(Name = 'test Project', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Project_Signatory__c = standardUser.Id, Slug__c = 'testing5');
		insert project1;

		Opportunity oppt = new Opportunity(Name = 'Opportunity testing 1', accountId = acc.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		Product2 prod = new Product2(Name = 'TestP', productcode = 'test');
		insert prod;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project1.id);
		insert oli;
		oliList.add(oli);

		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c objProjectRole = new Project_Role__c();
		objProjectRole.status__c = 'Active';
		objProjectRole.Contact__c = con.id;
		objProjectRole.Role__c = 'Billing Contact';
		objProjectRole.PrimaryContact__c = true;
		objProjectRole.Opportunity__c = oppt.Id;
		objProjectRole.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole);

		Project_Role__c objProjectRole1 = new Project_Role__c();
		objProjectRole1.status__c = 'Active';
		objProjectRole1.Contact__c = con.id;
		objProjectRole1.Role__c = 'Representative/Voting Contact';
		objProjectRole1.PrimaryContact__c = true;
		objProjectRole1.Opportunity__c = oppt.Id;
		objProjectRole1.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole1);

		Project_Role__c objProjectRole2 = new Project_Role__c();
		objProjectRole2.status__c = 'Active';
		objProjectRole2.Contact__c = con.id;
		objProjectRole2.Role__c = 'Technical Contact';
		objProjectRole2.PrimaryContact__c = true;
		objProjectRole2.Opportunity__c = oppt.Id;
		objProjectRole2.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole2);

		Project_Role__c objProjectRole3 = new Project_Role__c();
		objProjectRole3.status__c = 'Active';
		objProjectRole3.Contact__c = con.id;
		objProjectRole3.Role__c = 'Marketing Contact';
		objProjectRole3.PrimaryContact__c = true;
		objProjectRole3.Opportunity__c = oppt.Id;
		objProjectRole3.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole3);

		Project_Role__c objProjectRole4 = new Project_Role__c();
		objProjectRole4.status__c = 'Active';
		objProjectRole4.Contact__c = con.id;
		objProjectRole4.Role__c = 'Press Contact';
		objProjectRole4.PrimaryContact__c = true;
		objProjectRole4.Opportunity__c = oppt.Id;
		objProjectRole4.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole4);

		Project_Role__c objProjectRole5 = new Project_Role__c();
		objProjectRole5.status__c = 'Active';
		objProjectRole5.Contact__c = con.id;
		objProjectRole5.Role__c = 'Legal Contact';
		objProjectRole5.PrimaryContact__c = true;
		objProjectRole5.Opportunity__c = oppt.Id;
		objProjectRole5.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole5);

		Project_Role__c objProjectRole6 = new Project_Role__c();
		objProjectRole6.status__c = 'Active';
		objProjectRole6.Contact__c = con.id;
		objProjectRole6.Role__c = 'Authorized Signatory';
		objProjectRole6.PrimaryContact__c = true;
		objProjectRole6.Opportunity__c = oppt.Id;
		objProjectRole6.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole6);

		Project_Role__c objProjectRole7 = new Project_Role__c();
		objProjectRole7.status__c = 'Active';
		objProjectRole7.Contact__c = con.id;
		objProjectRole7.Role__c = 'Event Sponsorship';
		objProjectRole7.PrimaryContact__c = true;
		objProjectRole7.Opportunity__c = oppt.Id;
		objProjectRole7.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole7);

		Project_Role__c objProjectRole8 = new Project_Role__c();
		objProjectRole8.status__c = 'Active';
		objProjectRole8.Contact__c = con.id;
		objProjectRole8.Role__c = 'PO Contact';
		objProjectRole8.PrimaryContact__c = true;
		objProjectRole8.Opportunity__c = oppt.Id;
		objProjectRole8.Opportunity_Line_Item__c = oli.Id;
		projectRoles.add(objProjectRole8);

		insert projectRoles;

		Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp());

		Test.startTest();
		String envelopId = DocusignApi.createEnvelope(oppt.Id);
		//System.assertEquals('test', envelopId);
		HttpResponse response = DocusignApi.voidEnvelope(envelopId, 'void msg test');
		System.assertEquals('OK', response.getStatus());
		HttpResponse success = DocusignApi.reSendEnvelope(envelopId);
		System.assertEquals('OK', success.getStatus());
		HttpResponse successOfgetDocument = DocusignApi.getDocument(envelopId);
		System.assertEquals('OK', successOfgetDocument.getStatus());
		Test.stopTest();
	}
}