@isTest
public class NSProductDetailHelper_Test {
    
    @testSetup
    static void setup(){
        Endpoints__c endPoint = new Endpoints__c();
        endPoint.name = 'For Product Details';
        endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=11';
        insert endPoint;
        
        Product2 prod = new Product2();
        prod.name = 'Test_Prod';
        insert prod;
        Project__c prj = new Project__c(Name = 'testing11', Status__c = 'Planned',Category__c = 'Subproject', Subsidiary_ID__c = 8, Slug__c = 'test_slug');
        insert prj;
        
        Product_Details__c Pd = new Product_Details__c();
        Pd.Products__c = prod.id;
        Pd.Price__c = 56;
        Pd.NS_Income_GL_Account__c = 'Membership Dues : Platinum Membership';
        pd.NS_Deferred_Revenue_Account__c = '284';
        pd.NS_Department__c = '10';
        pd.NS_Revenue_Schedule__c = '29';
        Pd.Netsuite_Sync__c = false;
        Pd.Duration__c = '45';
        Pd.Description__c = 'Description_Test';
        Pd.Tier__c = 'Test';
        Pd.Job_Code__c = 'test';
        PD.NetSuite_Class__c = 'test';
        PD.NetSuite_Name_Override__c = 'test';
        insert Pd;
    }
    
    @isTest
    static void test_mappingFromSFToNSThroughBatch(){
         Product_Details__c pd = [SELECT ID FROM Product_Details__c LIMIT 1];  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());        
        NSProductDetailHelper.mappingFromSFToNSThroughBatch(pd.Id);
        Test.stopTest();        
        System.assertEquals([SELECT Netsuite_ID__c FROM Product_Details__c WHERE Id = :pd.Id].Netsuite_ID__c,'12345' );
    }
    
    @isTest
    static void test_mappingFromSFToNS(){
        Product_Details__c pd = [SELECT ID FROM Product_Details__c LIMIT 1];  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());        
        NSProductDetailHelper.mappingFromSFToNS(pd.Id,new Map<Id,Product_Details__c>{pd.Id=> pd});
        Test.stopTest();        
        System.assertEquals([SELECT Netsuite_ID__c FROM Product_Details__c WHERE Id = :pd.Id].Netsuite_ID__c,'12345' );
    }

}