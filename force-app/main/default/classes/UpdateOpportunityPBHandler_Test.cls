@isTest
public class UpdateOpportunityPBHandler_Test{
	@isTest
	static void createTestMethod(){

		//Creating Project Record Id
		//Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Subproject'].Id;
		Account acc = testFactory.getAccount();

		Profile p = [SELECT Id
		             FROM Profile
		             WHERE Name = 'Standard User'];
		User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'mystandarduser@testorg.com');
		insert u;

		list<Project__c> projectList = new list<Project__c>();
		list<Project__c> projectBlankList = new list<Project__c>();
		for (Integer i = 1; i < 5; i++){
			Project__c testProjObj = new Project__c();
			testProjObj.Name = 'New Test Project' + i;
			testProjObj.Category__c = 'Subproject';
			testProjObj.Status__c = 'Planned';
			testProjObj.Type__c = 'Membership';
			testProjObj.Pipeline_Stage__c = 'Exploratory Discussions';
			testProjObj.Manual_Status_Check__c = false;
			testProjObj.Opportunity_Owner__c = u.ID;
			testProjObj.Slug__c = 'testing' + i;
			projectList.add(testProjObj);
		}

		insert projectList;

		Opportunity oppty = new Opportunity();
		oppty.Name = 'Test Opportunity';
		oppty.AccountId = acc.id;
		oppty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
		oppty.StageName = '2. Discovery';
		oppty.CloseDate = System.today();
		oppty.Type = 'Renewal';
		insert oppty;

		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		Product2 prod = new Product2(Name = 'TestP', productcode = 'test');
		insert prod;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppty.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = projectList[0].id);
		insert oli;

		//Starting Test Class Method
		Test.startTest();
		// Callig apex Class Method
		updateOpportunityPBHandler.updateOpportunityOwner(projectList);
		updateOpportunityPBHandler.updateOpportunityOwner(projectBlankList);

		Test.stopTest();
	}
}