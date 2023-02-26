@isTest
public class CurrentYearRevenueProjectBatchTest{
	@isTest
	static void Test1(){

		Account acc = new Account();
		acc.Name = 'Test';
		acc.Current_Year_Spend__c = 2000;
		insert acc;
		List<Asset> lstAsset = new List<Asset>();
		Project__c project = new Project__c();
		project.Name = 'Test Project';
		project.Type__c = 'Membership';
		project.Category__c = 'Subproject';
		project.Pipeline_Stage__c = 'Engaged';
		project.Slug__c = 'testing';
		insert project;
		Project__c P = [SELECT Id, Name
		                FROM Project__c];
		System.assertEquals('Test Project', P.Name);
		Asset assetObj = new Asset();
		assetObj.Name = 'Test Asset';
		assetObj.AccountId = acc.Id;
		assetObj.Projects__c = P.Id;
		assetObj.Status = 'Purchased';
		assetObj.PurchaseDate = Date.today();
		assetObj.Price = 15000;
		assetObj.Number_of_Years_Required__c = 1;
		insert assetObj;
		Asset a = [SELECT Id, Name, Projects__c
		           FROM Asset];
		System.assertEquals('Test Asset', a.Name);
		System.assertEquals(P.Id, a.Projects__c);
		P = [SELECT Id, Name, (SELECT Id
		                       FROM Assets__r)
		     FROM Project__c
		     WHERE Name = 'Test Project'];
		lstAsset = [SELECT Id, Price
		            FROM Asset
		            WHERE Name = 'Test Asset'];
		for (Asset rec : lstAsset){
			rec.Price = rec.Price + 2000;
		}

		update lstAsset;
		Test.startTest();
		CurrentYearRevenueProjectBatch obj = new CurrentYearRevenueProjectBatch();
		DataBase.executeBatch(obj, 200);
		Test.stopTest();
	}
}