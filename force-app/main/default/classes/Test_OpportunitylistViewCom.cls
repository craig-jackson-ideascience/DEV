@isTest
public class Test_OpportunitylistViewCom{
	@isTest
	static void Test_getOpportunityLineItem(){
		String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
		Account acc = new Account(FirstName = 'Test account', LastName = 'acc', billingStreet = 'street', RecordTypeId = recordTypeId);
		insert acc;

		Project__c project1 = new Project__c(Name = 'test Project', Type__c = 'Membership', Category__c = 'Directed Fund', Status__c = 'Planned', Slug__c = 'testing');
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

		List<OpportunityLineItem> lstOli = new List<OpportunityLineItem>();

		Test.startTest();
		lstOli = OpportunitylistViewCom.getOpportunityLineItem(acc.Id, 'Name', true);
		System.assertEquals(1, lstOli.size());
		Test.stopTest();
	}
}