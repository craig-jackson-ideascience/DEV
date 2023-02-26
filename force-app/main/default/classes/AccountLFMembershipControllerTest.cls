@isTest
private class AccountLFMembershipControllerTest {

    @isTest static void testGettingLFMembership() {
        Account acc = TestFactory.getAccount();
        Product2 prod = TestFactory.getProduct2();
        
        Project__c lfProj = new Project__c();
        lfProj.Name = 'The Linux Foundation';
        lfProj.Category__c = 'Incorporated Entity';
        lfProj.Slug__c ='thelf';
        insert lfProj;
        
        Membership__c memb = new Membership__c();
        memb.Account__c = acc.Id;
        memb.Project__c = lfProj.Id;
        memb.Product__c = prod.Id;
        memb.Start_Date__c = Date.newInstance(2019, 8, 1);
        memb.End_Date__c = Date.newInstance(2020, 8, 1);
        insert memb;
        
        List<String> membDetails = AccountLFMembershipController.getLFMembershipDetails(acc.Id);
        System.assert(membDetails[0] == 'Expired');
        System.assert(membDetails[1] == prod.Name);
        System.assert(membDetails[2] == '2019');
        System.assert(membDetails[3] == '8/1/2020');
    }
    
    //This tests scenario where there could be multiple 
    //LF memberships
    @isTest static void testGettingLFMembership2() {
        Account acc = TestFactory.getAccount();
        Product2 prod = TestFactory.getProduct2();
        
        Project__c lfProj = new Project__c();
        lfProj.Name = 'The Linux Foundation';
        lfProj.Category__c = 'Incorporated Entity';
        lfProj.Slug__c ='thelf';
        insert lfProj;
        
        Membership__c memb = new Membership__c();
        memb.Account__c = acc.Id;
        memb.Project__c = lfProj.Id;
        memb.Product__c = prod.Id;
        memb.Start_Date__c = Date.newInstance(2019, 8, 1);
        memb.End_Date__c = Date.newInstance(2020, 8, 1);
        insert memb;
        
        Membership__c memb2 = new Membership__c();
        memb2.Account__c = acc.Id;
        memb2.Project__c = lfProj.Id;
        memb2.Product__c = prod.Id;
        memb2.Start_Date__c = Date.newInstance(2019, 8, 1);
        memb2.End_Date__c = system.today().addYears(1);       
        insert memb2;
        //Test if there is 1 active membership and 1 expired membership
        List<String> membDetails = AccountLFMembershipController.getLFMembershipDetails(acc.Id);
        System.assert(membDetails[0] == 'Active');
        System.assert(membDetails[1] == prod.Name);
        System.assert(membDetails[2] == '2019');
        System.assert(membDetails[3] == system.today().addYears(1).format());
        
        //Test if 2 memberships are Expired and no active memberships
        memb2.End_Date__c = system.today().addYears(-1);
        update memb2;
        
        List<String> membDetails2 = AccountLFMembershipController.getLFMembershipDetails(acc.Id);
        system.debug('membdetails: ' + membDetails2[0]);
        System.assert(membDetails2[0] == 'Expired');
        System.assert(membDetails2[1] == prod.Name);
        System.assert(membDetails2[2] == '2019');
        System.assert(membDetails2[3] == system.today().addYears(-1).format());
    }
    
    @isTest static void testGettingAtRiskRenewals() {
        Account acc = TestFactory.getAccount();
        
        Id membershipRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.Hold__c = true;
        opp.Hold_Reason__c = 'Awaiting PO';
        opp.CloseDate = Date.today();
        opp.StageName = '2. Discovery';
        opp.RecordTypeId = membershipRTId;
        opp.Type = 'Renewal';
        insert opp;
        
        List<Opportunity> opps = AccountLFMembershipController.getAtRiskRenewals(acc.Id);
        system.debug('opps size: ' + opps.size());
        System.assert(opps.size() == 1);
    }
    
}