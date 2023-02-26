@istest
public class UpdateStatusOfAssetsBatchTest {
    @testSetup static void setup(){
        
        Training__c obj = new Training__c();
        obj.Category__c = 'Subscription';
        obj.Name = 'Test Subscription';
        insert obj;

        Training__c objRec = [Select ID from Training__c where Name  = 'Test Subscription' limit 1];
        RecordType recTypeObj = [SELECT Id,DeveloperName,Name,SobjectType FROM RecordType where Name = 'Corporate' and SobjectType = 'Asset' limit 1];

        Project__c proj  = TestFactory.getProject();
        Opportunity oppt = TestFactory.getOpportunity();
        oppt.Amount = 4000;
        update oppt;
        
        Opportunity oppt1 = TestFactory.getOpportunity();
        oppt1.Amount = 0;
        update oppt1;
        
        
        Product2 prod = TestFactory.getProduct2();
        Account acc = TestFactory.getAccount();
        OpportunityLineItem oli = TestFactory.getOpportunityLineItem();

        Asset asst = new Asset();
        asst.RecordTypeId = recTypeObj.ID;
        asst.Name = 'Test SubscriptionAsset';
        asst.Training__c = objRec.ID;
        asst.Price = 2000;
        asst.AccountId = acc.ID; 
        asst.Projects__c = proj.ID;
        asst.Status = 'Active';
        asst.PurchaseDate = Date.today().addYears(-1).addDays(1); 
        asst.UsageEndDate = system.today();
        asst.Number_of_Years_Required__c = 1;
        asst.Opportunity__c = oppt.ID;
        asst.OpportunityLineItem__c = oli.id;
        asst.Auto_Renew__c = TRUE;
        asst.Product2Id = prod.ID;
        insert asst;
        
        
        Asset asst1 = new Asset();
        asst1.RecordTypeId = recTypeObj.ID;
        asst1.Name = 'Test SubscriptionAsset';
        asst1.Training__c = objRec.ID;
        asst1.Price = 0;
        asst1.AccountId = acc.ID; 
        asst1.Projects__c = proj.ID;
        asst1.Status = 'Active';
        asst1.PurchaseDate = Date.today().addYears(-1).addDays(1); 
        asst1.UsageEndDate = system.today();
        asst1.Number_of_Years_Required__c = 1;
        asst1.Opportunity__c = oppt1.ID;
        asst1.OpportunityLineItem__c = oli.id;
        asst1.Auto_Renew__c = TRUE;
        asst1.Product2Id = prod.ID;
        insert asst1;
    }
    
    static testmethod void updatePaidAssets(){
        Test.startTest();
            ScheduleUpdateStatusOfAssetsBatch sc = new ScheduleUpdateStatusOfAssetsBatch();
            sc.execute(null);
        Test.stopTest();
        List<Asset> assetRecs = [Select Id, Status from Asset where Status = 'Expired' and Price >0 ];
        System.assertEquals(1, assetRecs.size());
    }
    
    static testmethod void updateFreeAssets(){
        Test.startTest();
            UpdateStatusOfAssetsBatch sc = new UpdateStatusOfAssetsBatch(Date.today());
            Database.executeBatch(sc, 100);
        Test.stopTest();
        List<Asset> assetRecs = [Select Id, Status from Asset where Status = 'Expired' and Price = 0];
        System.assertEquals(1, assetRecs.size());
    }
    
}