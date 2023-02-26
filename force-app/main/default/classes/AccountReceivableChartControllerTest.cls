/* Test Class For - AccountReceivableChartController class
 */ 
@isTest
public class AccountReceivableChartControllerTest {
    
    //create data
    @TestSetup
    public static void setupdata(){
        Project__c testProject =TestFactory.getProject();
        Opportunity oppt = TestFactory.getOpportunity();
        Product2 prod = TestFactory.getProduct2();
        Account acc = TestFactory.getAccount();
        OpportunityLineItem oli = TestFactory.getOpportunityLineItem();
        
        Id recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Asset asst = new Asset(Name = 'TEstcreateasset',RecordTypeId=recordTypeId,AccountId = acc.ID, Projects__c = testProject.ID ,
                               Status = 'Active', UsageEndDate = system.today(), Number_of_Years_Required__c = 1,Opportunity__c = oppt.ID, 
                               OpportunityLineItem__c = oli.id,Auto_Renew__c = TRUE,Product2Id = prod.ID,SalesOrderStatus__c='Open',
                               PaymentTerms__c ='Net 30',Price =10000,
                               purchasedate=Date.newinstance(2020,9,8));
        insert asst;
        asset ast =[select id,days__c from asset where id=:asst.id];
        system.debug('days '+ast.days__c);
        
    }
    
    //Test method for getSelectedProjectDetails
    @isTest 
    public static void getSelectedProjectDetails_test(){
        
        Id prjId =[SELECT ID from project__c LIMIT 1].Id;
        Project__c returnedProject = AccountReceivableChartController.getSelectedProjectDetails(prjId);
        system.assertEquals('Test Project',returnedProject.Name );
        
    }
    
    //Test method for getAccountReceivableDetails
    @isTest 
    public static void getAccountReceivableDetails_test(){
        Id prjId =[SELECT ID from project__c LIMIT 1].Id;
        String returnedString = AccountReceivableChartController.getAccountReceivableDetails(prjId,'120');
        system.assertNotEquals(null,returnedString );
    }
    
    //Test method for getAccountReceivableTableDetails
    @isTest 
    public static void getAccountReceivableTableDetails_test(){
        Id prjId =[SELECT ID from project__c LIMIT 1].Id;
        List<integer> intList = new List<Integer>{120};
        List<Asset> returnedAssetList = AccountReceivableChartController.getAccountReceivableTableDetails(
            prjId,JSON.serialize(intList),false,null,true);
        system.assertNotEquals(0,returnedAssetList.size());
    }
}