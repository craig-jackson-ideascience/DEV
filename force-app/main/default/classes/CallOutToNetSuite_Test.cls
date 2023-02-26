/********************************************************
* Created by: Martand Atrey @ CloudRoute Solutions
* Created Date: 12-11-2019.
* Description: CallOutToNetSuite_Test
********************************************************/
@isTest
public class CallOutToNetSuite_Test {
    
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
    static void callingCallOutToNetForBatch(){  
         Product_Details__c pd = [SELECT ID FROM Product_Details__c LIMIT 1];    

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        
        String jsonString = '{"itemid":"test","subsidiary":"0","incomeaccount":"Membership Dues : Platinum Membership","department":"10","deferredrevenueaccount":"284","revrecschedule":"29","class":"test","location":"test","taxschedule":"1","recordtype":"NonInventorySaleItem"}';
        CallOutToNetSuite.callingCallOutToNetForBatch(jsonString, pd.Id);
        Test.stopTest();
        
        System.assertEquals([SELECT Netsuite_ID__c FROM Product_Details__c WHERE Id = :pd.Id].Netsuite_ID__c,'12345' );
        
    }
    
    @isTest
    static void callingCallOutToNet(){
        Product_Details__c pd = [SELECT ID FROM Product_Details__c LIMIT 1];     
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new CallOutToNetSuiteMockHttp());
        
        String jsonString = '{"itemid":"test","subsidiary":"0","incomeaccount":"Membership Dues : Platinum Membership","department":"10","deferredrevenueaccount":"284","revrecschedule":"29","class":"test","location":"test","taxschedule":"1","recordtype":"NonInventorySaleItem"}';
        CallOutToNetSuite.callingCallOutToNet(jsonString, pd.Id);
        Test.stopTest();
        
        System.assertEquals([SELECT Netsuite_ID__c FROM Product_Details__c WHERE Id = :pd.Id].Netsuite_ID__c,'12345' );
        
    }
}