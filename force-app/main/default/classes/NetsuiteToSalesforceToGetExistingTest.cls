@isTest
public with sharing class NetsuiteToSalesforceToGetExistingTest {
   public static testmethod void  testing(){
        Test.startTest();
        
        
        Endpoints__c endPt = new Endpoints__c();
        endPt.Endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=37&deploy=1&recordtype=salesorder&id=';
        endPt.Password__c = 'M3IIcWqcr8Fp' ; 
        endPt.User_Id__c = 'sfcontractor@linuxfoundation.org';
        endPt.name = 'To Get Sales Order Status From NS';
        insert endPt;
        
        Set<String> ids = new Set<String>();
        Account acc = new Account();
       	acc.Name = 'TEST ACC';
        insert acc;
        Asset assetObj = new Asset ();
        assetObj.name = 'Test';
        assetObj.Number_of_Years_Required__c = 1;
        assetObj.NetSuite_ID__c = '39394';
       	assetObj.AccountId = acc.id;
        insert assetObj;
        
        //string netsuiteId = '39394';
        
        ids.add(assetObj.id);
        NetsuiteToSalesforceToGetExistingData a = new NetsuiteToSalesforceToGetExistingData(ids);
        //a.fillingInfo(ids);
        database.executebatch(a);
        Test.stopTest();
    }
    
}