/*
 * Test CLass For-AccountIsMemberBatch Class
 */ 
@isTest
public class AccountIsMemberBatchTest {
    
    //create TestData
    @TestSetup
    static void makeData(){   
        Asset asset = TestFactory.getAsset();
        
        // insert another account
        Account acc1 = new Account();
        acc1.Name ='Is Member Acc';
        acc1.Website ='ismember.com';
        acc1.IsMember__c = true;
        insert acc1;
        
        // insert asset record
        Asset asst = new Asset(Name = 'IsMemberAccountAsset',AccountId = acc1.ID,
        Status = 'Active', Number_of_Years_Required__c = 1);
        insert asst;
        
    }
    
    //Test Scheduler without passing Query
    @isTest
    public static void testScheduler(){
        Test.startTest();
        AccountIsMemberBatch actSch = new AccountIsMemberBatch();
        actSch.execute(null);
        Test.stopTest();
        System.assertEquals(True, [SELECT Id,Account.IsMember__c FROM Asset LIMIT 1].Account.IsMember__c);
    }
    
    //Test Scheduler with passing Query
    @isTest
    public static void testScheduler1(){
        Test.startTest();
        AccountIsMemberBatch actSch = new AccountIsMemberBatch('SELECT ID,AccountID FROM ASSET');
        Database.executeBatch(actSch);
        Test.stopTest();
        System.assertEquals(False, [SELECT Id,Account.IsMember__c FROM Asset Where Account.Name='Is Member Acc' Limit 1].Account.IsMember__c);
    }

   
}