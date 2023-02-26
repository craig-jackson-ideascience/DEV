@isTest
private class PurchaseHistoryControllerTest{
	@testSetup
	static void setup(){
		//Creating Project Record Id
		//Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Directed Fund'].Id;
		Id MembershipOppId = [Select Id, Name
		                      From RecordType
		                      Where SobjectType = 'Opportunity' and Name = 'Membership'].Id;
		testFactory.getAccount();
		Project__c testProjObj = new Project__c();
		testProjObj.Name = 'New Test Project';
		//testProjObj.RecordTypeId = directedProjectId;
		testProjObj.Status__c = 'Planned';
		testProjObj.Type__c = 'Membership';
		testProjObj.Category__c = 'Directed Fund';
		testProjObj.Manual_Status_Check__c = false;
		testProjObj.Slug__c = 'testing';
		insert testProjObj;
		// Creating Account Record in Test Class
		Account testAcntObj = new Account();
		testAcntObj.Name = 'Test Acnt Record';
		insert testAcntObj;

		// Creating Product2 Record in Test Class
		Product2 testProdObj = new Product2();
		testProdObj.Name = 'Test Prod Record';
		testProdObj.Family = 'Membership';
		insert testProdObj;

		// Creating Purchase History Record in Test Class
		Asset testAssetObj = new Asset();
		testAssetObj.Name = 'Test Asset Record';
		testAssetObj.AccountId = testAcntObj.Id;
		testAssetObj.Projects__c = testProjObj.Id;
		testAssetObj.Status = 'Active';
		testAssetObj.SalesOrderNumber__c = '';
		testAssetObj.Skip_NetSuite_Sync__c = false;
		testAssetObj.Annual_Full_Price__c = 500;
		testAssetObj.Price = 50000.0;
		testAssetObj.SalesOrderStatus__c = 'Open';
		testAssetObj.PurchaseDate = date.today()-1;
		testAssetObj.InstallDate = date.today()-1;

		insert testAssetObj;
	}

	static testMethod void getAssetListTest(){
		PurchaseHistoryController purchaseHistoryController = new PurchaseHistoryController();
		Test.startTest();
		purchaseHistoryController.getCustombaseUrl();
		purchaseHistoryController.getAssetList();
		Test.stopTest();
		system.assert(purchaseHistoryController.getCustombaseUrl() != null, 'Base Url should not be null');
	}
}