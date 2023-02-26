@isTest
private class ProjectMemberSummaryControllerTest {

    @isTest static void testGettingCorporateMemberships() {
        Account acc = TestFactory.getAccount();
        Project__c proj = TestFactory.getProject();
        Product2 prod = TestFactory.getProduct2();
        
        Membership__c memb = new Membership__c();
        memb.Account__c = acc.Id;
        memb.Project__c = proj.Id;
        memb.Product__c = prod.Id;
        memb.Annual_Price__c = 50000;
        memb.End_Date__c = Date.today();
        insert memb;
        
        List<AggregateResult> groupedResults = ProjectMemberSummaryController.getCorporateMemberships(proj.Id);
        System.assert(groupedResults.size() == 1);
    }
    
    @isTest static void testGettingIndividualMemberships() {
        Id individualRTID = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        
        Contact con = TestFactory.getContact();
        Project__c proj = TestFactory.getProject();
        Product2 prod = TestFactory.getProduct2();
        
        Asset asst = new Asset();
        asst.Name = 'Test individual asset';
        asst.RecordTypeId = individualRTID;
        asst.ContactId = con.Id;
        asst.Projects__c = proj.Id;
        asst.Product2Id = prod.Id;
        asst.Skip_NetSuite_Sync__c = true;
        asst.Status = 'Active';
        asst.UsageEndDate = System.today();
        insert asst;
        
        List<AggregateResult> groupedResults = ProjectMemberSummaryController.getIndividualMemberships(proj.Id);
        System.assert(groupedResults.size() == 1);
    }

}