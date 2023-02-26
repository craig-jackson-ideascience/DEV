@isTest
private class OppJoinNowVerificationControllerTest{
	@isTest
	static void testGetDetails1(){
		Id idPDRecordType = Schema.SObjectType.Product_Details__c.getRecordTypeInfosByDeveloperName().get('Membership').getRecordTypeId();
		Account acc = TestFactory.getAccount();
		Project__c project1 = new Project__c(Name = 'test Project', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Slug__c = 'testing');
		insert project1;
		Opportunity oppt = new Opportunity(Name = 'Opportunity testing 2', Original_Renewal_Amount__c = 0, accountId = acc.Id, StageName = '2. Discovery', Type = 'New Business', CloseDate = Date.today().addDays(4));
		insert oppt;
		Id pricebookId = Test.getStandardPricebookId();

		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;
		Product2 prod = TestDataUtils.createProduct('hyperledger', 'description', 6, 'Membership');

		Product_Details__c prodDetails = TestDataUtils.createProductDetail(true, project1.Id, null, null, prod.Id);
		prodDetails.RecordTypeId = idPDRecordType;
		prodDetails.Price__c = 4000;
		update prodDetails;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;
		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;
		Quote objQuote = new Quote(OpportunityId = oppt.Id, Name = 'Test Quote', Pricebook2Id = pbk.Id, Status = 'Review Pending');
		insert objQuote;
		oppt.SyncedQuoteId = objQuote.Id;
		update oppt;
		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, totalprice = 4000, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project1.id, product_Details__c = prodDetails.Id);
		insert oli;

		OppJoinNowVerificationController.getDetails(oppt.Id);
	}

	@isTest
	static void testGetDetails2(){
		Id idPDRecordType = Schema.SObjectType.Product_Details__c.getRecordTypeInfosByDeveloperName().get('Membership').getRecordTypeId();
		Account acc = TestFactory.getAccount();
		acc.No_Of_Employess__c = '250';
		acc.NumberOfEmployees = 550;
		acc.Company_Type__c = 'Private';
		update acc;

		Project__c project1 = new Project__c(Name = 'test Project', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Slug__c = 'testing');
		insert project1;
		Opportunity oppt = new Opportunity(Name = 'Opportunity testing 2', Original_Renewal_Amount__c = 0, accountId = acc.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4));
		oppt.Join_Now_Company_Type__c = 'Private';
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();

		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;
		Product2 prod = TestDataUtils.createProduct('hyperledger', 'description', 6, 'Membership');

		Product_Details__c prodDetails = TestDataUtils.createProductDetail(true, project1.Id, null, null, prod.Id);
		prodDetails.RecordTypeId = idPDRecordType;
		prodDetails.Start_Tier__c = 1;
		prodDetails.End_Tier__c = 300;
		prodDetails.Price__c = 4000;
		update prodDetails;

		Product_Details__c prodDetails2 = TestDataUtils.createProductDetail(true, project1.Id, null, null, prod.Id);
		prodDetails2.RecordTypeId = idPDRecordType;
		prodDetails2.Start_Tier__c = 400;
		prodDetails2.End_Tier__c = 1000;
		prodDetails2.Price__c = 4000;
		update prodDetails2;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;
		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;
		Quote objQuote = new Quote(OpportunityId = oppt.Id, Name = 'Test Quote', Pricebook2Id = pbk.Id, Status = 'Review Pending');
		insert objQuote;
		oppt.SyncedQuoteId = objQuote.Id;
		update oppt;

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, totalprice = 4000, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project1.id, product_Details__c = prodDetails.Id);
		oli.Membership_Tier__c = '500';
		oli.Start_Tier__c = 1;
		oli.End_Tier__c = 300;
		insert oli;

		OppJoinNowVerificationController.getDetails(oppt.Id);

		OppJoinNowVerificationController.makeUpdates(oppt.Id, 'useAccountValue', '', '', '');

		OppJoinNowVerificationController.makeUpdates(oppt.Id, 'useJoinNowValue', '', '', '');
	}
}