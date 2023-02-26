/***
 ** Created by Cloudroute Solutions on 25-03-2021
 ** Test class for Chart_RevenueControllerTest
 ***/
@IsTest
private class Chart_RevenueControllerTest{
	@TestSetup
	static void testSetup(){
		
        Project__c parentProj = new Project__c(Name = 'Parent project', slug__c = 'parent');
        insert parentProj;
        
		/* project */
		Project__c proj = new Project__c();
		proj.Name = 'testProject1';
		proj.Project_Status__c = 'Active';
		proj.Category__c = 'Subproject';
        proj.Slug__c = 'testproj';
        proj.Funding__c = 'Unfunded';
        proj.Project_Entity_Name__c = 'The Linux Foundation';
        proj.Start_Date__c = system.today();
        proj.Industry__c = 'Non-profit Organizations';
        proj.Model__c = 'Alternate Funding';
        proj.Technology__c = 'Blockchain';
        proj.Technical_Activity_Type__c = 'Open Source Software';
        proj.Description__c = 'description';
        proj.Parent_Entity_Relationship__c = parentProj.Id;
        proj.Parent_Project__c = parentProj.Id;
		insert proj;

		/* account */
		Account account = new Account(Name = 'TestAbc');
		insert account;

		/* opportunity */
		Opportunity oppt = new Opportunity();
		oppt.Name = 'Opportunity testing 1';
		oppt.AccountId = account.Id;
		oppt.StageName = '2. Discovery';
		oppt.CloseDate = Date.today().addDays(4);
		insert oppt;

		/* product */
		Product2 prod = new Product2();
		prod.Name = 'Platinum Membership';
		prod.ProductCode = 'test';
		prod.Family = 'Membership';
		prod.isActive = true;
		insert prod;

		/* pricebook and pricebook entry */
		Id pricebookId = Test.getStandardPricebookId();
		PriceBookEntry priceBookEntry = new PriceBookEntry();
		priceBookEntry.PriceBook2Id = pricebookId;
		priceBookEntry.Product2Id = prod.ID;
		priceBookEntry.IsActive = true;
		priceBookEntry.UnitPrice = 34;
		insert priceBookEntry;

		/* opportunity line item */
		OpportunityLineItem oli = new OpportunityLineItem();
		oli.OpportunityId = oppt.Id;
		oli.Quantity = 2;
		oli.UnitPrice = 20;
		oli.PriceBookEntryId = priceBookEntry.ID;
		insert oli;

		/* assets */
		List<Asset> listOfAsset = new List<Asset>();
		for (Integer i = 0; i < 5; i++){
			Asset asset = new Asset();
			asset.Name = 'Test';
			asset.AccountId = account.ID;
			asset.Projects__c = proj.ID;
			asset.Status = 'Active';
            asset.Opportunity__c = oppt.ID;
            asset.Product2Id = prod.ID;
            asset.OpportunityLineItem__c = oli.id;
            asset.InstallDate = System.today();
            asset.Price = 10000;
			listOfAsset.add(asset);
		}
		
        
        Product2 prod2 = new Product2();
        prod2.Name = 'Silver Membership - MPSF';
        prod2.ProductCode = 'test1';
        prod2.Family = 'Membership';
        prod2.isActive = true;
        insert prod2;
        
        Product2 prod3 = new Product2();
        prod3.Name = 'Silver Membership';
        prod3.ProductCode = 'test1';
        prod3.Family = 'Membership';
        prod3.isActive = true;
        insert prod3;
        
        Asset asset2 = new Asset();
        asset2.Name = 'Test1';
        asset2.AccountId = account.ID;
        asset2.Projects__c = proj.ID;
        asset2.Status = 'Active';
        asset2.Opportunity__c = oppt.ID;
        asset2.Product2Id = prod2.ID;
        asset2.OpportunityLineItem__c = oli.id;
        asset2.InstallDate = System.today();
        asset2.Price = 10000;
        
        Asset asset3 = new Asset();
        asset3.Name = 'Test1';
        asset3.AccountId = account.ID;
        asset3.Projects__c = proj.ID;
        asset3.Status = 'Active';
        asset3.Opportunity__c = oppt.ID;
        asset3.Product2Id = prod3.ID;
        asset3.OpportunityLineItem__c = oli.id;
        asset3.InstallDate = System.today();
        asset3.Price = 10000;
        
        listOfAsset.add(asset2);
        listOfAsset.add(asset3);
        insert listOfAsset;
	}

	@IsTest
	static void getFilteredChartDataTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c  where slug__c = 'testproj'];
		List<String> selectedDates = new List<String>{'2022-02-22', '2020-03-22'};
            List<String> purchaseList = new List<String>{'Renewal'};
		String result = Chart_RevenueController.getFilteredChartData(proj.Id, '', selectedDates, JSON.serialize(purchaseList), 'March-2022', false);
		System.assertNotEquals(null, result);
	}

    @IsTest
	static void getLessThanEqualChartDataTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c  where slug__c = 'testproj'];
		List<String> selectedDates = new List<String>{'2022-02-22', '2020-03-22'};
		String result = Chart_RevenueController.getFilteredChartData(proj.Id, 'lessThanEqual', selectedDates, null, 'March-2022', false);
		System.assertNotEquals(null, result);
	}

    @IsTest
	static void getFilteredChartDataLessThanEqualTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c  where slug__c = 'testproj'];
		List<String> selectedDates = new List<String>{'2022-02-22', '2020-03-22'};
		String result = Chart_RevenueController.getFilteredChartData(proj.Id, 'between', selectedDates, null, 'March-2022', false);
		System.assertNotEquals(null, result);
	}

    @IsTest
	static void getFilteredChartDataGreaterThanEqualTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c  where slug__c = 'testproj'];
		List<String> selectedDates = new List<String>{'2022-02-22', '2020-03-22'};
		String result = Chart_RevenueController.getFilteredChartData(proj.Id, 'greaterThanEqual', selectedDates, null, 'March-2022', false);
		System.assertNotEquals(null, result);
	}

    @IsTest
	static void getFilteredChartDataEqualTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c  where slug__c = 'testproj'];
		List<String> selectedDates = new List<String>{'2022-02-22'};
		String result = Chart_RevenueController.getFilteredChartData(proj.Id, 'equal', selectedDates, null, 'March-2022', false);
		System.assertNotEquals(null, result);
        selectedDates.add('2022-02-24');
        String result1 = Chart_RevenueController.getFilteredChartData(proj.Id, 'equal', selectedDates, null, 'March-2022', false);
	}

    @IsTest
	static void getFilteredChartDataEqualLessThanTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c  where slug__c = 'testproj'];
		List<String> selectedDates = new List<String>{'THIS_YEAR_Plus_To_Date'};
		String result = Chart_RevenueController.getFilteredChartData(proj.Id, 'equalLessThan', selectedDates, null, 'December-2022', false);
		System.assertNotEquals(null, result);
	}
    
    @IsTest
    static void getFilteredChartDataEqualLessThanTest1(){
        Project__c proj = [SELECT Id
                           FROM Project__c  where slug__c = 'testproj'];
        List<String> selectedDates = new List<String>{'Fiscal_Quarter_Plus_To_Date'};
            String result = Chart_RevenueController.getFilteredChartData(proj.Id, 'equalLessThan', selectedDates, null, 'December-2022', false);
        //System.assertNotEquals(null, result);
    }
    
    @IsTest
    static void getFilteredChartDataEqualLessThanTest2(){
        Project__c proj = [SELECT Id
                           FROM Project__c  where slug__c = 'testproj'];
        List<String> selectedDates = new List<String>{'Fiscal_Year_Plus_To_Date'};
            String result = Chart_RevenueController.getFilteredChartData(proj.Id, 'equalLessThan', selectedDates, null, 'December-2022', false);
        //System.assertNotEquals(null, result);
    }

    @IsTest
	static void getFilteredChartDataMonthlyTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c  where slug__c = 'testproj'];
		List<String> selectedDates = new List<String>{'2022-02-22', '2020-03-22'};
		String result = Chart_RevenueController.getFilteredChartData(proj.Id, 'between', selectedDates, null, 'March-2022', true);
		System.assertNotEquals(null, result);
	}
    
    @IsTest
    static void getListOfAssets1(){
        Project__c proj = [SELECT Id
                           FROM Project__c  where slug__c = 'testproj'];
        List<String> selectedDates = new List<String>{'2022-02-22', '2020-03-22'};
        Chart_RevenueController.getListOfAssets(proj.Id, 'between', selectedDates, null, null, null,null, true, true, null);
        //System.assertNotEquals(null, result);
    }

	@IsTest
	static void getActiveMembersTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c  where slug__c = 'testproj'];
		Double result = Chart_RevenueController.getActiveMembers(proj.Id);
		//System.assertEquals(5.0, result);
	}

	@IsTest
	static void getFilteredTableDataTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c  where slug__c = 'testproj'];
		List<String> selectedDates = new List<String>{'2020-02-22', '2022-03-22'};
		Chart_RevenueController.ReturnAssetWrapper result = Chart_RevenueController.getFilteredTableData(proj.Id, 'between', selectedDates, null, 'March-2022', 'Platinum Membership', false, true);
		System.assertNotEquals(null, result);
	}

	@IsTest
	static void getPurchaseTypesTest(){
		List<String> result = Chart_RevenueController.getPurchaseTypes();
		System.assertEquals(5, result.size());
	}
    
    @isTest
    static void prepareMapForAggregatePurchaseHistTest(){
        test.startTest();
        Project__c proj = [SELECT Id
		                   FROM Project__c  where slug__c = 'testproj' LIMIT 1];
        List<AggregateResult> lfSilverMemberMpsfSum = [SELECT SUM(Price)total, Name year, AssetLevel month  FROM Asset WHERE Product2.Name = 'Silver Membership - MPSF' and Projects__c =: proj.Id AND Status IN ('Active', 'Completed', 'Expired', 'Purchased') GROUP BY Name, AssetLevel];
        Chart_RevenueController.prepareMapForAggregatePurchaseHist(lfSilverMemberMpsfSum, new Map<String, Decimal>{}, true);
        test.stopTest();
    }
}