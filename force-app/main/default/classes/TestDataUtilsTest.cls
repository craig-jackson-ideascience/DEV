@isTest
Public Class TestDataUtilsTest{

    private static testMethod void TestDataUtilss(){
    
        TestDataUtils td = new TestDataUtils();
        User userid = TestDataUtils.createUser('TestDataUtils');
        Account accId = TestDataUtils.createAccount('TestData');
        Contact conId = TestDataUtils.createContact('firstname','lastname',accId.id);
        Opportunity oppId = TestDataUtils.createOpenOpportunity(accId.id,'testdata opp','2. Discovery');
        Opportunity closedOppId = TestDataUtils.createClosedOpportunity(accId.id,'testdata opp','2. Discovery');
        OpportunityContactRole billingContact = TestDataUtils.createBillingContact(oppId.id,conId.id);
        Product2 prodId = TestDataUtils.createProduct('Free Training','description',6,'Training');
        PricebookEntry pbid = TestDataUtils.createPriceBookEntryID(prodId.id);
        OpportunityLineItem oppProdID = TestDataUtils.createOpportunityProduct(oppId.id,pbid.id);

        
        //TestDataUtils.insertWorkThanks();
        //TestDataUtils.insertWorkBadge();
        //TestDataUtils.insertWorkBadgeDefinition();
        
    }
    private static testMethod void TestDataUtilsMethod(){
    
        TestDataUtils td = new TestDataUtils();
        User userid = TestDataUtils.createUser(true,'TestDataUtils78');
        Account acc =  TestDataUtils.createAccount(true,'Test 12 Account');   
        Lead ld=TestDataUtils.createLead(true,'Test','Lead1','Lead1 Company','Content','test21134@test.com');
        Opportunity oppt = TestDataUtils.createOpenOpportunity(true,acc.Id,'New Deal 5 Test','2. Discovery');
        Profile_by_allowed_Opportunity_Type__c pb =TestDataUtils.createProfileAllowedOpportunityType (true,'Test demo Setting', 'System Administrator');
        Product2 prod = TestDataUtils.createProduct(true,'Laptop X2001','Test Product',true,'Membership');
        PricebookEntry pbEntry = TestDataUtils.createPriceBookEntryID(true,prod.Id);
        Project__c project= TestDataUtils.createProject(true,'The Linux Foundation','Membership','Linux Foundation','Planned');
        project.Status__c = 'Active';
        project.Manual_Status_Check__c = false;
        project.Funding__c = 'Funded';
        update project;
        Event__c event= TestDataUtils.createEvent(false,'Test Event 989','Event','LF Event','Active');
        event.BillFromProject__c =project.id;
        
        insert event;
        Training__c tc =TestDataUtils.createTraining(true,'Test demo Training','Training','Android Development Training','Active');
        Product_Details__c pd=TestDataUtils.createProductDetail(true,project.Id,null,null,prod.Id);
        Asset asst = TestDataUtils.createAsset(false,'ABC Asset demo',acc.id,prod.Id,'Purchased');
        asst.RecordTypeId=System.label.Corporate_Asset_Record_Type;
        insert asst;
        OpportunityLineItem oli = TestDataUtils.createOpportunityProduct(true,oppt.Id,pbEntry.Id);

        //TestDataUtils.insertWorkThanks();
        //TestDataUtils.insertWorkBadge();
        //TestDataUtils.insertWorkBadgeDefinition();
        
    }
}