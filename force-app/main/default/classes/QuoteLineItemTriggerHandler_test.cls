@isTest
public class QuoteLineItemTriggerHandler_test{
	@isTest
	static void updateRollupFields_test(){
		Account acc = new Account(Name = 'Test account');
		insert acc;

		Contact contact = new Contact();
		contact.AccountId = acc.Id;
		contact.LastName = 'Test Contact';
		insert contact;

		Training__c training = new Training__c(Name = 'test Training');
		insert training;
		Id trainingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();
		Opportunity oppt = new Opportunity(RecordTypeId = trainingRecordTypeId, Name = 'Opportunity testing for Contactrole', accountId = acc.Id, Billing_Contact__c = contact.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		List<Product2> productList = new List<Product2>();

		Product2 prod = new Product2(Name = 'Certification', productcode = 'test', Type__c = 'Certification');
		Product2 prod2 = new Product2(Name = 'E-Learning', productcode = 'test2', Type__c = 'E-Learning');

		productList.add(prod);
		productList.add(prod2);
		insert productList;

		List<PriceBookEntry> priceBookEntryList = new List<PriceBookEntry>();
		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		priceBookEntryList.add(standardPbe);

		PriceBookEntry standardPbe2 = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod2.ID, isActive = true, unitPrice = 34);
		priceBookEntryList.add(standardPbe2);

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		priceBookEntryList.add(pbe);

		PriceBookEntry pbe2 = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod2.ID, unitPrice = 20.0, useStandardPrice = false);
		priceBookEntryList.add(pbe2);

		insert priceBookEntryList;
		Project__c project1 = new Project__c(Name = 'test Project', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Slug__c = 'testing');
		insert project1;

		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Product2Id = prod.Id, Required_Active_LF_Membership__c = true, training__c = training.Id, Bill_From__c = 'The Linux Foundation');
		OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe2.ID, Product2Id = prod2.Id, Required_Active_LF_Membership__c = true, training__c = training.Id, parent_product__c = prod.Id);
		oliList.add(oli);
		oliList.add(oli2);
		insert oliList;


		Quote quote = new Quote();
		quote.Name = 'Test Quote';
		quote.OpportunityId = oppt.Id;
		insert quote;

		List<QuoteLineItem> qliList = new List<QuoteLineItem>();
		QuoteLineItem qli = new QuoteLineItem(QuoteId = quote.Id, OpportunityLineItemId = oli.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Product2Id = prod.Id, training__c = training.Id);
		QuoteLineItem qli2 = new QuoteLineItem(QuoteId = quote.Id, Quantity = 3, OpportunityLineItemId = oli2.Id, unitPrice = 20, PriceBookEntryId = pbe2.ID, Product2Id = prod2.Id, parent_product__c = prod.Id, Parent_OppLineItem__c = oli.Id);
		qliList.add(qli);
		qliList.add(qli2);
		insert qliList;

		System.assertEquals(60, [SELECT Id, RollUp_UnitPrice__c
		                         FROM QuoteLineItem
		                         WHERE parent_product__c = ''][0].RollUp_UnitPrice__c);
	}

	@istest
	public static void recalculateSalesPrice_Test(){
		Account acc = new Account(Name = 'Test account');
		insert acc;

		Contact contact = new Contact();
		contact.AccountId = acc.Id;
		contact.LastName = 'Test Contact';
		insert contact;

		Id trainingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();
		Opportunity oppt = new Opportunity(RecordTypeId = trainingRecordTypeId, Name = 'Opportunity testing for Contactrole', accountId = acc.Id, Billing_Contact__c = contact.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		List<Product2> productList = new List<Product2>();

		Product2 prod = new Product2(Name = 'Certification', productcode = 'test', Type__c = 'Certification');
		Product2 prod2 = new Product2(Name = 'E-Learning', productcode = 'test2', Type__c = 'E-Learning');

		productList.add(prod);
		productList.add(prod2);
		insert productList;

		List<PriceBookEntry> priceBookEntryList = new List<PriceBookEntry>();
		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		priceBookEntryList.add(standardPbe);

		PriceBookEntry standardPbe2 = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod2.ID, isActive = true, unitPrice = 34);
		priceBookEntryList.add(standardPbe2);

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		priceBookEntryList.add(pbe);

		PriceBookEntry pbe2 = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod2.ID, unitPrice = 20.0, useStandardPrice = false);
		priceBookEntryList.add(pbe2);

		insert priceBookEntryList;
		Project__c project1 = new Project__c(Name = 'test Project', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Slug__c = 'testing');
		insert project1;

		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Product2Id = prod.Id);
		OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe2.ID, Product2Id = prod2.Id);
		oliList.add(oli);
		oliList.add(oli2);
		insert oliList;


		Quote quote = new Quote();
		quote.Name = 'Test Quote';
		quote.OpportunityId = oppt.Id;
		insert quote;
		List<QuoteLineItem> qliList = new List<QuoteLineItem>();
		QuoteLineItem qli = new QuoteLineItem(QuoteId = quote.Id, OpportunityLineItemId = oli.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Product2Id = prod.Id);
		QuoteLineItem qli2 = new QuoteLineItem(QuoteId = quote.Id, Quantity = 3, OpportunityLineItemId = oli2.Id, unitPrice = 20, PriceBookEntryId = pbe2.ID, Product2Id = prod2.Id);
		qliList.add(qli);
		qliList.add(qli2);
		Test.startTest();
		insert qliList;
		QuoteLineItem quoteLineItemObj = [Select Id, Initial_Price__c
		                                  From QuoteLineItem
		                                  WHERE Id = :qliList[0].Id];
		System.assertNotEquals(null, quoteLineItemObj.Initial_Price__c);
		qliList[0].Discount_in_amount__c = 10;
		update qliList[0];
		QuoteLineItem quoteLineItemObj1 = [Select Id, UnitPrice
		                                   From QuoteLineItem
		                                   WHERE Id = :qliList[0].Id];
		System.assertEquals(15, quoteLineItemObj1.UnitPrice);

		Test.stoptest();
	}

	@isTest
	static void prepopulateQuantityAndDiscountOnChildProduct_test(){
		Account acc = new Account(Name = 'Test account');
		insert acc;

		Contact contact = new Contact();
		contact.AccountId = acc.Id;
		contact.LastName = 'Test Contact';
		insert contact;

		Training__c training = new Training__c(Name = 'test Training', Category__c = 'Bundle');
		insert training;
		Id trainingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();
		Opportunity oppt = new Opportunity(RecordTypeId = trainingRecordTypeId, Name = 'Opportunity testing for Contactrole', accountId = acc.Id, Billing_Contact__c = contact.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert oppt;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		List<Product2> productList = new List<Product2>();

		Product2 prod = new Product2(Name = 'Certification', productcode = 'test', Type__c = 'Certification');
		Product2 prod2 = new Product2(Name = 'E-Learning', productcode = 'test2', Type__c = 'E-Learning');

		productList.add(prod);
		productList.add(prod2);
		insert productList;

		List<PriceBookEntry> priceBookEntryList = new List<PriceBookEntry>();
		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		priceBookEntryList.add(standardPbe);

		PriceBookEntry standardPbe2 = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod2.ID, isActive = true, unitPrice = 34);
		priceBookEntryList.add(standardPbe2);

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		priceBookEntryList.add(pbe);

		PriceBookEntry pbe2 = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod2.ID, unitPrice = 20.0, useStandardPrice = false);
		priceBookEntryList.add(pbe2);

		insert priceBookEntryList;
		Project__c project1 = new Project__c(Name = 'test Project', Type__c = 'Membership', Category__c = 'Subproject', Status__c = 'Planned', Slug__c = 'testing');
		insert project1;

		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, Type__c = 'Training', PriceBookEntryId = pbe.ID, Product2Id = prod.Id, Required_Active_LF_Membership__c = true, training__c = training.Id, Bill_From__c = 'The Linux Foundation');
		OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 20, Type__c = 'Training', PriceBookEntryId = pbe2.ID, Product2Id = prod2.Id, Required_Active_LF_Membership__c = true, training__c = training.Id, parent_product__c = prod.Id);
		oliList.add(oli);
		oliList.add(oli2);
		insert oliList;
		system.debug('olilist ' + oliList);

		Quote quote = new Quote();
		quote.Name = 'Test Quote';
		quote.OpportunityId = oppt.Id;
		insert quote;

		List<QuoteLineItem> qliList = new List<QuoteLineItem>();
		QuoteLineItem qli = new QuoteLineItem(QuoteId = quote.Id, OpportunityLineItemId = oli.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Product2Id = prod.Id, training__c = training.Id);
		QuoteLineItem qli2 = new QuoteLineItem(QuoteId = quote.Id, Quantity = 3, OpportunityLineItemId = oli2.Id, unitPrice = 20, PriceBookEntryId = pbe2.ID, Product2Id = prod2.Id, parent_product__c = prod.Id, Parent_OppLineItem__c = oli.Id);
		qliList.add(qli);
		qliList.add(qli2);
		insert qliList;
		system.debug([SELECT Id, Quantity, Parent_OppLineItem__c, parent_product__c
		              FROM QuoteLineItem
		              WHERE QuoteId = :quote.Id]);
		Test.startTest();
		qli.Quantity = 10;
		update qli;
		Test.stopTest();
		System.assertEquals(10, [SELECT Id, Quantity
		                         FROM QuoteLineItem
		                         WHERE Id = :qli2.Id
		                         LIMIT 1].Quantity);
	}
}