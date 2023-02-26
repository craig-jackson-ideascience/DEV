@isTest
private class CallOutToNetSuiteTrigger_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@TestSetup
	static void createTestData(){

		Endpoints__c endPoint = new Endpoints__c();
		endPoint.name = 'For Product Details';
		endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=11';
		insert endPoint;
		Product2 prod = TestDataUtils.createProduct(true, 'Test_Prod', 'Test Product', true, 'Membership');
		Project__c project = TestDataUtils.createProject(false, 'testing11', 'Membership', 'Directed Fund', 'Planned');
		project.Subsidiary_ID__c = 8;
		insert project;
	}

	/**
	 * Test Methods for CalloutToNetsuoteTrigger with different scenarios
	 */
	@isTest
	static void updateProdDetails_Test(){
		Product2 product = [SELECT Id
		                    FROM Product2
		                    WHERE Name = 'Test_Prod'];
		Product_Details__c prodDetail = new Product_Details__c();
		prodDetail.Products__c = product.id;
		prodDetail.Price__c = 56;
		prodDetail.NS_Income_GL_Account__c = 'Membership Dues : Platinum Membership';
		prodDetail.NS_Deferred_Revenue_Account__c = '284';
		prodDetail.NS_Department__c = '10';
		prodDetail.NS_Revenue_Schedule__c = '29';
		prodDetail.Netsuite_Sync__c = false;
		prodDetail.Duration__c = '45';
		prodDetail.Description__c = 'Description_Test';
		prodDetail.Tier__c = 'Test';
		prodDetail.Job_Code__c = 'test';
		prodDetail.NetSuite_Class__c = 'test';
		prodDetail.NetSuite_Name_Override__c = 'test';
		insert prodDetail;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());

		prodDetail.Netsuite_Sync__c = true;
		update prodDetail;

		Test.stopTest();

		//Asserts
		System.assertEquals('12345',[SELECT Netsuite_ID__c
		                     FROM Product_Details__c
		                     WHERE Id = :prodDetail.Id].Netsuite_ID__c, 'NetsuiteId must be 12345');
	}

	@isTest
	static void updateProdDetails1_Test(){

		Product2 product = [SELECT Id
		                    FROM Product2
		                    WHERE Name = 'Test_Prod'];

		Product_Details__c prodDetail = new Product_Details__c();
		prodDetail.Products__c = product.id;
		prodDetail.Price__c = 56;
		prodDetail.NS_Income_GL_Account__c = 'Membership Dues : Platinum Membership';
		prodDetail.NS_Deferred_Revenue_Account__c = '284';
		prodDetail.NS_Department__c = '10';
		prodDetail.NS_Revenue_Schedule__c = '29';
		prodDetail.Netsuite_Sync__c = false;
		prodDetail.Duration__c = '45';
		prodDetail.Description__c = 'Description_Test';
		prodDetail.Tier__c = 'Test';
		insert prodDetail;

		prodDetail.Netsuite_Sync__c = true;
		update prodDetail;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
		//Manually called this method for coverage
		
        set <string> prodDetailIDSet = new set <string>();
        prodDetailIDSet.add(prodDetail.id);
        Database.executebatch(new BatchForProjectEvent(prodDetailIDSet));
		//NSProductDetailHelper.mappingFromSFToNSThroughBatch(prodDetail.id);
		Test.stopTest();

		//Asserts
		System.assertEquals('12345',[SELECT Netsuite_ID__c
		                     FROM Product_Details__c
		                     WHERE Id = :prodDetail.Id].Netsuite_ID__c,'NetsuiteId must be 12345');
	}

	@isTest
	static void updateProdDetails2_Test(){

		Product2 product = [SELECT Id
		                    FROM Product2
		                    WHERE Name = 'Test_Prod'];
		Project__c project = [SELECT Id
		                      FROM Project__c
		                      WHERE Name = 'testing11'];
		Product_Details__c prodDetail = new Product_Details__c();
		prodDetail.RecordTypeId = Schema.SObjectType.Product_Details__c.getRecordTypeInfosByName().get('Training').getRecordTypeId();
		prodDetail.Products__c = product.id;
		prodDetail.Price__c = 56;
		prodDetail.Project__c = project.id;
		prodDetail.NS_Income_GL_Account__c = '290';
		prodDetail.NS_Deferred_Revenue_Account__c = '284';
		prodDetail.NS_Department__c = '10';
		prodDetail.NS_Revenue_Schedule__c = '29';
		prodDetail.Netsuite_Sync__c = false;
		prodDetail.Duration__c = '45';
		prodDetail.Netsuite_ID__c = '123456';
		prodDetail.Description__c = 'Description_Test';
		prodDetail.Tier__c = 'Test';
		prodDetail.NetSuite_Class__c = '';
		insert prodDetail;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());

		prodDetail.Netsuite_Sync__c = true;
		update prodDetail;

		Test.stopTest();

		//Asserts
		System.assertEquals('12345',[SELECT Netsuite_ID__c
		                     FROM Product_Details__c
		                     WHERE Id = :prodDetail.Id].Netsuite_ID__c,'NetsuiteId must be 12345');
	}

	@isTest
	public static void updateProdDetails3_Test(){

		Product2 product = [SELECT Id
		                    FROM Product2
		                    WHERE Name = 'Test_Prod'];
		Project__c project = [SELECT Id
		                      FROM Project__c
		                      WHERE Name = 'testing11'];

		Product_Details__c prodDetail = new Product_Details__c();
		prodDetail.RecordTypeId = Schema.SObjectType.Product_Details__c.getRecordTypeInfosByName().get('Training').getRecordTypeId();
		prodDetail.Products__c = product.id;
		prodDetail.Price__c = 56;
		prodDetail.Project__c = project.id;
		prodDetail.NS_Income_GL_Account__c = '290';
		prodDetail.NS_Deferred_Revenue_Account__c = '284';
		prodDetail.NS_Department__c = '10';
		prodDetail.NS_Revenue_Schedule__c = '29';
		prodDetail.Netsuite_Sync__c = false;
		prodDetail.NetSuite_Class__c = '';
		prodDetail.Job_Code__c = '123';
		prodDetail.Duration__c = '45';
		prodDetail.Netsuite_ID__c = '123456';
		prodDetail.Description__c = 'Description_Test';
		prodDetail.Tier__c = 'Test';
		insert prodDetail;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());

		prodDetail.Netsuite_Sync__c = true;
		update prodDetail;

		Test.stopTest();

		//Asserts
		System.assertEquals('12345',[SELECT Netsuite_ID__c
		                     FROM Product_Details__c
		                     WHERE Id = :prodDetail.Id].Netsuite_ID__c,'NetsuiteId must be 12345');
	}

	/**
	 * Test Methods for getting error if different Fields having null value
	 */
	@isTest
	public static void getErrors_Test(){

		List<Product2> productListToInsert = new List<Product2>();
		for (Integer i = 0; i < 10; i++){
			Product2 prod = new Product2();
			prod.name = 'Test_Prod' + i;
			prod.Family = 'Membership';
			productListToInsert.add(prod);
		}
		insert productListToInsert;
		Product2 product = [SELECT Id
		                    FROM Product2
		                    WHERE Name = 'Test_Prod'];
		Project__c project = [SELECT Id
		                      FROM Project__c
		                      WHERE Name = 'testing11'];

		List<Product_Details__c> productDetailListToInsert = new List<Product_Details__c>();
		for (Integer i = 0; i < 10; i++){
			Product_Details__c prodDetail = new Product_Details__c();
			prodDetail.RecordTypeId = Schema.SObjectType.Product_Details__c.getRecordTypeInfosByName().get('Training').getRecordTypeId();
			prodDetail.Products__c = productListToInsert[i].id;
			prodDetail.Price__c = 56;
			prodDetail.Project__c = project.id;
			prodDetail.NS_Income_GL_Account__c = '290';
			prodDetail.NS_Deferred_Revenue_Account__c = '284';
			prodDetail.NS_Department__c = '10';
			prodDetail.NS_Revenue_Schedule__c = '29';
			prodDetail.Netsuite_Sync__c = false;
			prodDetail.NetSuite_Class__c = '';
			prodDetail.Job_Code__c = '123';
			prodDetail.Duration__c = '45';
			prodDetail.Netsuite_ID__c = '123456';
			prodDetail.Description__c = 'Description_Test';
			prodDetail.Tier__c = 'Test';
			productDetailListToInsert.add(prodDetail);

		}
		//Price Null
		Product_Details__c prodDetail = new Product_Details__c();
		prodDetail.Products__c = product.id;
		prodDetail.Project__c = project.id;
		prodDetail.NS_Income_GL_Account__c = '290';
		prodDetail.NS_Deferred_Revenue_Account__c = '284';
		prodDetail.NS_Department__c = '10';
		prodDetail.NS_Revenue_Schedule__c = '29';
		prodDetail.Netsuite_Sync__c = false;
		prodDetail.NetSuite_Class__c = '';
		prodDetail.Job_Code__c = '123';
		prodDetail.Duration__c = '45';
		prodDetail.Netsuite_ID__c = '123456';
		prodDetail.Description__c = 'Description_Test';
		prodDetail.Tier__c = 'Test';
		prodDetail.Netsuite_Sync__c = true;
		productDetailListToInsert.add(prodDetail);

		//Products__c Null
		Product_Details__c prodDetail1 = new Product_Details__c();
		prodDetail1.Price__c = 56;
		prodDetail1.Project__c = project.id;
		prodDetail1.NS_Income_GL_Account__c = '290';
		prodDetail1.NS_Deferred_Revenue_Account__c = '284';
		prodDetail1.NS_Department__c = '10';
		prodDetail1.NS_Revenue_Schedule__c = '29';
		prodDetail1.Netsuite_Sync__c = false;
		prodDetail1.NetSuite_Class__c = '';
		prodDetail1.Job_Code__c = '123';
		prodDetail1.Duration__c = '45';
		prodDetail1.Netsuite_ID__c = '123456';
		prodDetail1.Description__c = 'Description_Test';
		prodDetail1.Tier__c = 'Test';
		prodDetail1.Netsuite_Sync__c = true;
		productDetailListToInsert.add(prodDetail1);

		Database.insert(productDetailListToInsert, false);

		List<Product_Details__c> productDetailListToUpdate = new List<Product_Details__c>();

		productDetailListToInsert[0].Netsuite_Sync__c = true;
		productDetailListToInsert[0].price__c = null;
		productDetailListToUpdate.add(productDetailListToInsert[0]);

		productDetailListToInsert[2].Netsuite_Sync__c = true;
		productDetailListToInsert[2].NS_Income_GL_Account__c = null;
		productDetailListToUpdate.add(productDetailListToInsert[2]);


		productDetailListToInsert[3].Netsuite_Sync__c = true;
		productDetailListToInsert[3].NS_Deferred_Revenue_Account__c = null;
		productDetailListToUpdate.add(productDetailListToInsert[3]);


		productDetailListToInsert[4].Netsuite_Sync__c = true;
		productDetailListToInsert[4].NS_Revenue_Schedule__c = null;
		productDetailListToUpdate.add(productDetailListToInsert[4]);

		productDetailListToInsert[5].Netsuite_Sync__c = true;
		productDetailListToInsert[5].Products__c = null;
		productDetailListToUpdate.add(productDetailListToInsert[5]);

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());

		List<Database.SaveResult> saveResultsList = Database.update(productDetailListToUpdate, false);

		//AssertsTest.stopTest();
		System.assertEquals(false, saveResultsList[0].isSuccess(),'Updation of product detail must be successful');
	}
}