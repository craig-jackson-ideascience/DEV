@isTest
public class createQuoteOnRenewalOf_OppBatch_Test {
    @isTest
    public static void createQuoteonRenewal(){
        //Account
        Account account = TestDataUtils.createAccount(false,'Test Account');
        account.billingCountry = 'brasil';
        account.billingStreet = 'new';
        insert account ;
        
        //Contact
        Contact contact = new Contact(lastname = 'testContact', email = 'testcontactno@gmail.com', accountid = account.id);
        insert contact;
  
        Opportunity opportunity = new Opportunity(Name = 'Test',
                                           AccountId = account.Id,
                                           CloseDate = Date.newInstance(2023, 9, 8),
                                           StageName = '5. Decision Commitment',
                                           Type = 'Renewal',
                                           PaymentTerms__c = 'Net 30',
                                           SyncedQuoteId = null,
                                           RecordTypeId = '01241000000Zut4AAC',
                                           Opportunity_PO_Required__c = true);
        insert opportunity;
        
		//Product
        Product2 prod = TestDataUtils.createProduct(true,'Laptop X2001','Test Product',true,'Membership');
        //PriceBookEntry
        PricebookEntry standardPrice = TestDataUtils.createPriceBookEntryID(true,prod.Id);
        
        //Project
        Project__c prj = new Project__c(Name = 'testing11', Do_not_Invoice__c = true,Status__c = 'Planned',Category__c = 'Subproject', Subsidiary_ID__c = 8, Project_code__c = 'LF',slug__c='vccu');
        insert prj;
        
        //Product Details
        Product_Details__c productDetail = new Product_Details__c();
        productDetail.Price__c = 56;
        productDetail.NS_Income_GL_Account__c = '290';
        productDetail.NS_Deferred_Revenue_Account__c = '284';
        productDetail.NS_Department__c = '10';
        productDetail.NS_Revenue_Schedule__c = '29';
        productDetail.Netsuite_Sync__c = false;
        productDetail.Duration__c = '45';
        productDetail.Description__c = 'Description_Test';
        productDetail.Tier__c = 'Test';
        productDetail.Netsuite_ID__c = '889955';
        productDetail.Project__c = prj.id;
        productDetail.Products__c = prod.id;
        insert productDetail;
        
        OpportunityLineItem opportunitylineitem = TestDataUtils.createOpportunityProduct(false,opportunity.Id,standardPrice.Id);        
        opportunitylineitem.start_date__c = Date.newInstance(2016, 8, 1);
        opportunitylineitem.end_date__c = date.today().addDays(2);
        opportunitylineitem.Projects__c = prj.Id;
        opportunitylineitem.Product_Details__c = productDetail.id;
        opportunitylineitem.PO_Number__c = '8899774455';
        insert opportunitylineitem;
        
        //Project Roles
        List<Project_Role__c> projectRoles = new List<Project_Role__c>();
        Project_Role__c billingRole =  TestDataUtils.createProjectRole(false,contact.id,'Billing Contact',opportunity.Id,opportunitylineitem.Id,null,true);
        projectRoles.add(billingRole);
        
        Project_Role__c votingRole =  TestDataUtils.createProjectRole(false,contact.id,'Representative/Voting Contact',opportunity.Id,opportunitylineitem.Id,null,true);
        projectRoles.add(votingRole);
        insert projectRoles;
                             
        Test.startTest();
        createQuoteOnRenewalOf_POReqd_OppBatch obj = new createQuoteOnRenewalOf_POReqd_OppBatch();
        database.executeBatch(obj);
        Test.stopTest();
    }
}