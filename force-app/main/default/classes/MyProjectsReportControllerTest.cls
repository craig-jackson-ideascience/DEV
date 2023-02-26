@istest
public class MyProjectsReportControllerTest {
    
    @testSetup static void setup(){
        Account acc = TestDataUtils.createAccount('free training Account');

        Contact con = TestDataUtils.createContact('test','linuxtest',acc.Id);

        User standard = TestFactory.getUser();

        Opportunity oppt= TestFactory.getOpportunity();
        oppt.OwnerId = standard.id;
        update oppt;
        
        Asset ass =  TestFactory.getAsset();
        ass.UsageEndDate = ass.UsageEndDate.addDays(2);
        ass.OwnerId = standard.Id;
        update ass;
        
        oppt.Parent_Asset__c =ass.id;
        update oppt;
    }
    
    @isTest
    static  void testAssetDetail(){
        
        Opportunity opp = [Select ID, Name From Opportunity Where Name = 'Opportunity testing 1'];
        
        User userdetail = [Select ID, email From User Where email ='standarduser123@testorg.com'];
        System.debug('userdetail' +userdetail);
        

        List<Asset> listofasset = [Select ID,Name,ownerid, InstallDate,UsageEndDate,Price,Opportunity__c,Opportunity__r.Name,Product2.ID,Product2.Name,Projects__r.Name,
                                   Projects__c,OpportunityLineItem__c, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState,Account.P_O_Required__c,
                                   Account.BillingPostalCode, Account.BillingCountry,Contact.Name,Contact.Email,Projects__r.OwnerId,Product2.Family,Bill_To_Account__c,(select id,StageName,Name from Opportunities__r)
                                   from Asset WHERE Opportunity__c =: opp.ID];
		system.debug('listofasset: ' + listofasset[0]);
        Project_Role__c objProjectRole = new Project_Role__c();
        objProjectRole.status__c ='Active';
        objProjectRole.Contact__c = [select id from contact limit 1].id;
        objProjectRole.Role__c ='Billing Contact';
        objProjectRole.Opportunity__c = opp.Id;
        objProjectRole.Opportunity_Line_Item__c = listofasset[0].OpportunityLineItem__c;
        objProjectRole.PrimaryContact__c = true;
        insert objProjectRole;
		
        test.startTest();
        MyProjectsReportController mycon = new  MyProjectsReportController(userdetail.ID);
        mycon.getAssetDetails();
        blob csvblob=  mycon.csvGenerate(listofasset);
        System.assert(csvblob != null);
        test.stopTest();
        
        
    }
    
}