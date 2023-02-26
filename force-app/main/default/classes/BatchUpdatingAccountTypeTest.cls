/*
* Test Class For-BatchUpdatingAccountType and BatchUpdatingAccountTypeHelper Class
*/ 
@isTest
public class BatchUpdatingAccountTypeTest
{
    //create TestData
    @testsetup
    static void setup(){
        Project__c proj  = TestFactory.getProject();
        Opportunity oppt = TestFactory.getOpportunity();
        Product2 prod = TestFactory.getProduct2();
        Account acc = TestFactory.getAccount();
        acc.Type = 'Open';
        update acc;
        OpportunityLineItem oli = TestFactory.getOpportunityLineItem();
        
        Asset asst = new Asset(Name = 'Test Asset',AccountId = acc.ID, Projects__c = proj.ID , Status = 'Active', 
                               UsageEndDate = system.today(),Number_of_Years_Required__c = 1,Opportunity__c = oppt.ID,
                               OpportunityLineItem__c = oli.id,Auto_Renew__c = TRUE,Product2Id = prod.ID);
        insert asst;
        
        // insert another account
        Account acc1 = new Account(Name = 'Test Account 1', Phone = '11111',Website = 'testaccount.com', BillingCity = 'Littleton',
                                   BillingState = 'Colorado', BillingPostalCode = '80120', BillingCountry = 'United States',
                                   BillingStreet = '1601-1649 W Weaver Ave', Type='Customer');
        insert acc1;
        // insert another asset
        Asset asst1 = new Asset(Name = 'Test Asset 1',AccountId = acc1.ID, Projects__c = proj.ID , Status = 'Expired', UsageEndDate = system.today().addDays(-10), Number_of_Years_Required__c = 1);
        insert asst1;
    }
    
    //Test BatchUpdatingAccountType batch without passing Query
    @IsTest
    private static void testBatchApex() {
        
        Test.startTest();
        BatchUpdatingAccountType obj = new BatchUpdatingAccountType(null);
        Database.executeBatch(obj, 100);
        Test.stopTest();
        System.assertEquals('Former Customer',[SELECT Id,Name,Type FROM Account WHERE Name ='Test Account 1' Limit 1 ].Type );
 
    }
    
    //Test BatchUpdatingAccountType batch with passing Query
    @IsTest
    private static void testBatchApex1() {
        
        Test.startTest();
        BatchUpdatingAccountType obj = new BatchUpdatingAccountType('SELECT Id, Type from Account  WHERE Type != \'Former Customer\'');
        Database.executeBatch(obj, 100);
        Test.stopTest();
        System.assertEquals('Former Customer',[SELECT Id,Name,Type FROM Account WHERE Name ='Test Account 1' Limit 1 ].Type );

    }
}