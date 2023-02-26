/*
 * Test Class For-BatchReplaceAssetStatus and BatchUpdateAssetAsActive Class
 */ 
@isTest
public class BatchReplaceAssetStatusTest {
    
    //create TestData
    @TestSetup
    static void makeData(){   
        // First Account  
        Account acc1 = new Account(Name='Membership Account',Website ='membership.com');
        insert acc1;
        // Second Account
        Account acc2 = new Account(Name ='Training Account',Website ='training.com');
        insert acc2;
        // Membership Product
        Product2 prod1 = new Product2(Name = 'Membership Product',productcode='MP', Family='Membership',isActive = true);
        insert prod1; 
        // Training Product
        Product2 prod2 = new Product2(Name = 'Training Product',productcode='TP', Family='Training',isActive = true);
        insert prod2; 
        // Membership Asset1
        Asset asst1 = new Asset(Name = 'Membership Asset1',AccountId = acc1.ID, Status = 'Active', InstallDate = Date.newInstance(2019, 2, 17), UsageEndDate = Date.newInstance(2020, 2, 17), 
                               Number_of_Years_Required__c = 1, Auto_Renew__c = TRUE,Product2Id = prod1.ID);
        insert asst1;
        // Membership Asset2
        Asset asst2 = new Asset(Name = 'Membership Asset2',AccountId = acc1.ID, Status = 'Active', InstallDate = System.today()+10, UsageEndDate = System.today()+30, 
                               Number_of_Years_Required__c = 1, Auto_Renew__c = TRUE,Product2Id = prod1.ID);
        insert asst2;
        // Membership Asset3
        Asset asst3 = new Asset(Name = 'Membership Asset3',AccountId = acc1.ID, Status = 'Purchased', InstallDate = System.today()-10, UsageEndDate = System.today()+30, 
                               Number_of_Years_Required__c = 1, Auto_Renew__c = TRUE,Product2Id = prod1.ID);
        insert asst3;
        // Training Asset
        Asset asst4 = new Asset(Name = 'Training Asset',AccountId = acc2.ID, Status = 'Active', InstallDate = Date.newInstance(2019, 2, 17), UsageEndDate = Date.newInstance(2020, 2, 17), 
                               Number_of_Years_Required__c = 1, Auto_Renew__c = TRUE,Product2Id = prod2.ID);
        insert asst4;
    }
    
    //Test BatchReplaceAssetStatus without passing Query
    @isTest
    public static void testScheduler(){
        Test.startTest();
        BatchReplaceAssetStatus actSch = new BatchReplaceAssetStatus();
        actSch.execute(null);
        Test.stopTest();
        System.assertEquals('Expired', [SELECT Id,Status FROM Asset Where Name='Membership Asset1' Limit 1].Status);
        System.assertEquals('Completed', [SELECT Id,Status FROM Asset Where Name='Training Asset' Limit 1].Status);
    }
    
    //Test BatchReplaceAssetStatus with passing Query
   @isTest
    public static void testScheduler1(){
        Test.startTest();
        BatchReplaceAssetStatus actSch = new BatchReplaceAssetStatus('SELECT id,status,UsageEndDate,Product2.Family FROM Asset WHERE status NOT IN (\'Completed\',\'Invoice Cancelled\', \'Expired\', \'Associate Cancelled\') '+
                'AND UsageEndDate <'+String.Valueof(Date.today()));
        Database.executeBatch(actSch);
        Test.stopTest();
        System.assertEquals('Expired', [SELECT Id,Status FROM Asset Where Name='Membership Asset1' Limit 1].Status);
        System.assertEquals('Completed', [SELECT Id,Status FROM Asset Where Name='Training Asset' Limit 1].Status);
    }

    //Test BatchUpdateAssetAsActive without passing Query
    @isTest
    public static void testScheduler2(){
        Test.startTest();
        BatchUpdateAssetAsActive actSch = new BatchUpdateAssetAsActive();
        actSch.execute(null);
        Test.stopTest();
        System.assertEquals('Purchased', [SELECT Id,Status FROM Asset Where Name='Membership Asset2' Limit 1].Status);
        System.assertEquals('Active', [SELECT Id,Status FROM Asset Where Name='Membership Asset3' Limit 1].Status);
    }
    
    //Test BatchUpdateAssetAsActive with passing Query
    @isTest
    public static void testScheduler3(){
        Test.startTest();
        BatchUpdateAssetAsActive actSch = new BatchUpdateAssetAsActive('SELECT id,status,InstallDate, UsageEndDate, Product2.Family FROM Asset where Product2.Family = \'Membership\' AND status != \'Invoice Cancelled\' AND Status != \'Associate Cancelled\'');
        Database.executeBatch(actSch);
        Test.stopTest();
        System.assertEquals('Purchased', [SELECT Id,Status FROM Asset Where Name='Membership Asset2' Limit 1].Status);
        System.assertEquals('Active', [SELECT Id,Status FROM Asset Where Name='Membership Asset3' Limit 1].Status);
    }
}