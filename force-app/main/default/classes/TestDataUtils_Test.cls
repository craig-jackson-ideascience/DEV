/*
Test Class of TestDataUtils 
*/
@isTest
public Class TestDataUtils_Test{

    /**
     * Test Methods to cover different methods of TestDataUtils 
     */ 
    @isTest
    static void noFlagMethod_Test(){
    
        //User
        User user = TestDataUtils.createUser('TestDataUtils');
        System.assertNotEquals(null, user.Id,'Id must be populated on record');

        //Account
        Account account = TestDataUtils.createAccount('TestData');
        System.assertNotEquals(null, account.Id,'Id must be populated on record');

        //Contact
        Contact contact = TestDataUtils.createContact('firstname','lastname',account.id);
        System.assertNotEquals(null, contact.Id,'Id must be populated on record');

        //Opportunity
        Opportunity oppId = TestDataUtils.createOpenOpportunity(account.id,'testdata opp','2. Discovery');
        System.assertNotEquals(null, opportunity.Id,'Id must be populated on record');

        //Opportunity
        Opportunity closedOppId = TestDataUtils.createClosedOpportunity(account.id,'testdata opp','2. Discovery');
        System.assertEquals('2. Discovery', closedOppId.StageName,'Stage must be 2. Discovery on opportunity');

        //OppContactRole
        OpportunityContactRole billingContact = TestDataUtils.createBillingContact(oppId.id,contact.id);
        System.assertNotEquals(null, billingContact.Id,'Id must be populated on record');

        //Product
        Product2 product = TestDataUtils.createProduct('Free Training','description',6,'Training');
        System.assertNotEquals(null, product.Id,'Id must be populated on record');

        //PricebookEntry
        PricebookEntry pricebookentry = TestDataUtils.createPriceBookEntryID(product.id);
        System.assertNotEquals(null, pricebookentry.Id,'Id must be populated on record');

        //OpportunityLineItem
        OpportunityLineItem oppLineItem = TestDataUtils.createOpportunityProduct(oppId.id,pricebookentry.id);
        System.assertNotEquals(null, oppLineItem.Id,'Id must be populated on record');

        
    }

    @isTest
    static void flagMethod_Test(){
    
        User user = TestDataUtils.createUser(true,'TestDataUtils78');
        System.assertNotEquals(null, user.Id,'Id must be populated on record');

        Account account =  TestDataUtils.createAccount(true,'Test 12 Account');   
        System.assertNotEquals(null, account.Id,'Id must be populated on record');

         //Contact
         Contact contact = TestDataUtils.createContact('firstname','lastname',account.id);
         System.assertNotEquals(null, contact.Id,'Id must be populated on record');
 

        Lead ledd=TestDataUtils.createLead(true,'Test','Lead1','Lead1 Company','Content','test21134@test.com');
        System.assertNotEquals(null, lead.Id,'Id must be populated on record');

        Opportunity opportunity = TestDataUtils.createOpenOpportunity(true,account.Id,'New Deal 5 Test','2. Discovery');
        System.assertNotEquals(null, lead.Id,'Id must be populated on record');

        Profile_by_allowed_Opportunity_Type__c pb =TestDataUtils.createProfileAllowedOpportunityType (true,'Test demo Setting', 'System Administrator');
        System.assertNotEquals(null, pb.Id,'Id must be populated on record');
        
        Product2 prod = TestDataUtils.createProduct(true,'Laptop X2001','Test Product',true,'Membership');
        System.assertNotEquals(null, prod.Id,'Id must be populated on record');
        
        
        PricebookEntry pbEntry = TestDataUtils.createPriceBookEntryID(true,prod.Id);
        System.assertNotEquals(null, pbEntry.Id,'Id must be populated on record');

        Project__c project= TestDataUtils.createProject(true,'The Linux Foundation','Membership','Linux Foundation','Planned');
        System.assertNotEquals(null, project.Id,'Id must be populated on record');

        project.Status__c='Active';
        project.Funding__c ='Funded';
        update project;

        Event__c event= TestDataUtils.createEvent(false,'Test Event 989','Event','LF Event','Active');
        System.assertEquals(null, event.Id,'Id should not be populated');

        event.BillFromProject__c =project.id;
        insert event;
        System.assertNotEquals(null, event.Id,'Id must be populated on record');

        Training__c training =TestDataUtils.createTraining(true,'Test demo Training','Training','Android Development Training','Active');
        System.assertNotEquals(null, training.Id,'Id must be populated on record');

        Product_Details__c prodDetail=TestDataUtils.createProductDetail(true,project.Id,null,null,prod.Id);
        System.assertNotEquals(null, prodDetail.Id,'Id must be populated on record');

        Asset asset = TestDataUtils.createAsset(false,'ABC Asset demo',account.id,prod.Id,'Purchased');
        asset.RecordTypeId=System.label.Corporate_Asset_Record_Type;
        insert asset;
        System.assertNotEquals(null, asset.Id,'Id must be populated on record');

        OpportunityLineItem opportunitylineitem = TestDataUtils.createOpportunityProduct(true,opportunity.Id,pbEntry.Id);
        System.assertNotEquals(null, opportunitylineitem.Id,'Id must be populated on record');

        Project_Role__c votingRole =  TestDataUtils.createProjectRole(true,contact.id,'Billing Contact',opportunity.Id,opportunitylineitem.Id,asset.Id,true);
        System.assertNotEquals(null, votingRole.Id,'Id must be populated on record');

    }
}