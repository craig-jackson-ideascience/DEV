@isTest
private class AccountSponsorshipSummaryControllerTest {
    
    @testsetup
    static void setup(){
        Account acc = new Account();
        acc.Name='Test Account';
        acc.Website ='google.com';
        Insert acc; 
        Project__c proj = TestFactory.getProject();
        Product2 prod = TestFactory.getProduct2();
        
        prod.Family = 'Event';
        update prod;
        
        Project__c lfProj = new Project__c();
        lfProj.Name = 'The Linux Foundation';
        lfProj.Slug__c ='thelf';
        lfProj.Category__c = 'Incorporated Entity';
        insert lfProj;
        
        Event__c evt = new Event__c();
        evt.Name = 'Test event';
        evt.Category__c = 'Webinar';
        evt.Type__c = 'Event';
        evt.Status__c = 'Planned';
        evt.Registration_Source__c ='Cvent';
        insert evt;
        
        String yearString = String.valueOf( System.today().year() );
        
        Asset asst = new Asset();
        asst.Name = 'Test sponsorship';
        asst.AccountId = acc.Id;
        asst.Event__c = evt.Id;
        asst.Projects__c = proj.Id;
        asst.Product2Id = prod.Id;
        asst.Skip_NetSuite_Sync__c = true;
        asst.Status = 'Active';
        asst.Year__c = yearString;
        insert asst;
    }

    @isTest static void testGettingSponsorships() {      
        Account acc= [SElECT Id FROM Account WHERE Name='Test Account'];
        List<Asset> assets = AccountSponsorshipSummaryController.getSponsorships(acc.Id,acc.Id);
        System.assert(assets.size() == 1);
    }
    
    @isTest static void testTrainingSponsorships() {
       Product2 prod = [SELECT ID,Family FROM Product2 LIMIT 1];
        prod.Family = 'Training';
        update prod;
        String yearString = String.valueOf( System.today().year() );
		Account acc = [SELECT ID FROM Account LIMIT 1];
        Asset asst = new Asset();
        asst.Name = 'Test sponsorship';
        asst.AccountId = acc.Id;
        asst.Event__c = [SELECT Id FROM Event__C LIMIT 1].ID;
        asst.Projects__c = [SELECT ID FROM Project__c WHERE Name ='The Linux Foundation' LIMIT 1].ID;
        asst.Product2Id = prod.Id;
        asst.Skip_NetSuite_Sync__c = true;
        asst.Status = 'Active';
        asst.Year__c = yearString;
        asst.RecordTypeId = Utility.corporateRecordTypeId;
        insert asst;       
        
        List<Asset> assets = AccountSponsorshipSummaryController.getTrainingSponsorships(acc.Id,null);
        System.assert(assets.size() == 1);
    }
    @isTest static void testGettingSponsorships1() {      
        Account acc= [SElECT Id FROM Account WHERE Name='Test Account'];
        List<Asset> assets = AccountSponsorshipSummaryController.getSponsorships(acc.Id,null);
        System.assert(assets.size() == 1);
    }
    
    @isTest static void testTrainingSponsorships1() {       
       
        Product2 prod = [SELECT ID,Family FROM Product2 LIMIT 1];
        prod.Family = 'Training';
        update prod;
        String yearString = String.valueOf( System.today().year() );
		Account acc = [SELECT ID FROM Account LIMIT 1];
        Asset asst = new Asset();
        asst.Name = 'Test sponsorship';
        asst.AccountId = acc.Id;
        asst.Event__c = [SELECT Id FROM Event__C LIMIT 1].ID;
        asst.Projects__c = [SELECT ID FROM Project__c WHERE Name ='The Linux Foundation' LIMIT 1].ID;
        asst.Product2Id = prod.Id;
        asst.Skip_NetSuite_Sync__c = true;
        asst.Status = 'Active';
        asst.Year__c = yearString;
        asst.RecordTypeId = Utility.corporateRecordTypeId;
        insert asst;       
        
        List<Asset> assets = AccountSponsorshipSummaryController.getTrainingSponsorships(acc.Id,acc.Id);
        System.assert(assets.size() == 1);
    }

}