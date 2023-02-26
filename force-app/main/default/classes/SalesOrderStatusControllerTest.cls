@isTest
public class SalesOrderStatusControllerTest {
    
    @testSetup
    public static void setup(){
        Endpoints__c endPoint = new Endpoints__c();
        endPoint.Name = 'To Get Sales Order Status From NS';
        endPoint.Endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=43&deploy=1';
        endPoint.Password__c = 'jYdpn8sp22F8C45b';
        endPoint.User_Id__c = 'nsapi@linuxfoundation.org';
        endPoint.Nlauth_Account__c = '4010327_SB1';
        insert endPoint;
        
        Account acc = new Account();
        acc.Name = 'TEST ACC';
        insert acc;
        Asset assetObj = new Asset ();
        assetObj.name = 'Test';
        assetObj.Number_of_Years_Required__c = 1;
        assetObj.NetSuite_ID__c = '1539958';
        assetObj.AccountId = acc.id;
        assetObj.Skip_NetSuite_Sync__c = true;
        insert assetObj;
    }
    
    @isTest
    static void getStatusTest(){
        Asset asset =  [Select Id From Asset LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NetSuiteToSalesforce_Mock ());
        SalesOrderStatusController.getSalesOrderStatus(asset.Id);
		Test.stopTest();        
        System.assertEquals('Open',[SELECT Id,SalesOrderStatus__c FROM Asset LIMIT 1].SalesOrderStatus__c);
    }
}