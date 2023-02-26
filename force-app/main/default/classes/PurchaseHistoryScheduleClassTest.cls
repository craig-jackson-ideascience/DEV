@isTest
Private class PurchaseHistoryScheduleClassTest{
	/**
	 * TestSetup inserting required data for test class
	 */
	@testSetup
	static void setup(){
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
		Insert testAssetObj;
		Datetime yesterday = Datetime.now().addDays(-2);
		Test.setCreatedDate(testAssetObj.Id, yesterday);
	}

	/**
	 * testScheduledJob : method to test the schedule class
	 */
	static testmethod void testScheduledJob(){
		String cronExpression = '0 0 5 * * ?';
		//String cronExpression = '0 0 0 15 3 ? 2022';
		Test.startTest();
		// Schedule the test job
		String jobId = System.schedule('ScheduledApexTest', cronExpression, new PurchaseHistoryScheduleClass());
		Test.stopTest();

		//Asserts - as Email sent is in async execution hence the limit of invocation is 0
		System.assertEquals(1, [SELECT Name, CreatedDate
		                        FROM Asset
		                        WHERE SalesOrderNumber__c = '' AND Skip_NetSuite_Sync__c = false AND Price != 0 AND createddate < :System.now()-1 AND 
                                Status IN ('Purchased', 'Active') AND RecordType.Name IN ('Corporate', 'Corporate_Training')].size(), 'List must have one Record');
	}
}