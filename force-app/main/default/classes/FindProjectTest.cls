@isTest
public class FindProjectTest{
	@isTest
	public static void testDataSetup(){
		Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
		insert prod;

		Project__c proj = new Project__c(Name = 'The Linux Foundation', Category__c = 'Incorporated Entity', Slug__c = 'testing');
		Insert proj;

		Id pricebookId = Test.getStandardPricebookId();

		PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
		insert standardPrice;

		Pricebook2 customPB = new Pricebook2(Name = 'Custom Pricebook', isActive = true);
		insert customPB;

		PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
		insert customPrice;
		Account acc = new Account(name = 'Test Account');
		insert acc;
		Contact objContact = new Contact(FirstName = 'Hal', Lastname = 'Jordan', AccountId = acc.Id, MailingCountry = 'United States', Email = 'hal.jordan@example.com');
		Insert objContact;
		opportunity opp = new opportunity(name = 'Test Opportunity', AccountId = acc.id, CloseDate = Date.newInstance(2016, 12, 9), stageName = 'Closed Lost', ForecastCategoryName = 'Pipeline', PaymentTerms__c = 'Net 30', type = 'New Business', Amount = 5676, Loss_Reason__c = 'Other', Pricebook2Id = customPB.Id);
		insert opp;

		OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.id, TotalPrice = 664557, End_Date__c = Date.newInstance(2016, 12, 9), Start_Date__c = Date.newInstance(2015, 01, 01), Quantity = 56, Projects__c = proj.id, PricebookEntryId = customPrice.Id);
		insert oppLineItem;


		id oppId = opp.id;
		string ProjectName = proj.Name;
		string ReciName = objContact.name;
		FindProject obj = new FindProject();
		obj.OppId = oppId;
		system.debug('Opportunity' + obj.objopp);
		system.debug('Opportunity' + obj.objoppLine);
		system.debug('Opportunity' + obj.objpro);
	}
}