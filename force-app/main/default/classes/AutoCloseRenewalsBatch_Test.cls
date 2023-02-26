/*
 *Test Class of AutoCloseRenewalsBatch Class
 */
@isTest
public class AutoCloseRenewalsBatch_Test {
    
    /**
	 * TestSetup inserting required data for test class
	 */
    @testSetup
    static  void createTestaData() {
        //Endpoints
        Endpoints__c endPoint = new Endpoints__c();
        endPoint.name = 'For Membership Asset';
        endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=90&deploy=4';
        
        Endpoints__c endPoint2 = new Endpoints__c();
        endPoint2.name = 'For Product Details';
        endPoint2.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=11';
        insert new List<Endpoints__c>{endPoint,endPoint2};
                    
        //Account
        Account account = TestDataUtils.createAccount(false,'Test Account');
        account.billingCountry = 'brasil';
        account.billingStreet = 'new';
        insert account ;
        
        //Contact
        Contact contact = new Contact(lastname = 'testContact', email = 'testcontactno@gmail.com', accountid = account.id);
        insert contact;
        
        //Product
        Product2 prod = TestDataUtils.createProduct(true,'Laptop X2001','Test Product',true,'Membership');
        //PriceBookEntry
        PricebookEntry standardPrice = TestDataUtils.createPriceBookEntryID(true,prod.Id);
        
        //Opportunity
        Opportunity opportunity = new Opportunity();
        OpportunityLineItem oppLineitem = new OpportunityLineItem();
        
        opportunity.AccountId = account.Id;
        opportunity.Name = 'test';
        opportunity.StageName = '2. Discovery';
        opportunity.Type = 'Renewal';
        opportunity.CloseDate = date.today();
        opportunity.Bill_To_Account__c = account.Id;
        opportunity.Hold__c=false;
        insert opportunity;
        
        //Project
        Project__c prj = new Project__c(Name = 'testing11',Slug__c='testing', Do_not_Invoice__c = true,Status__c = 'Planned',Category__c = 'Subproject', Subsidiary_ID__c = 8, Project_code__c = 'LF');
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
        
        //OppLineItem
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
        
    }
    
    /**
	 *batch_Test : Test Method for opportunity whose close date is today by calling batch
	 */
    @isTest
    static  void batch_Test() {
        Opportunity opportunity =[SELECT Id FROM Opportunity WHERE Type ='Renewal' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE Email='testcontactno@gmail.com' LIMIT 1];
        OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = opportunity.id, 
                                                                contactid = contact.id, role = 'Membership Decision Maker', IsPrimary = True);
        insert ocr;
        
        //Test
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        Test.startTest();
        Database.executeBatch(new AutoCloseRenewalsBatch(),1);
        Test.stopTest();
        
        //Asserts
        System.assertEquals('Closed Won', [SELECT Id,StageName from Opportunity where Id =: opportunity.Id].StageName,'Opportunity must be closed won');
    }
    
    /**
	 *batchError_Test : Test method to pupulate autocloseerror on opportunity
	 */
    @isTest
    static  void batchError_Test() {
        
        String query = 'SELECT Id,StageName,CloseDate,Auto_Close_Error__c,Hold__c,Type,'+
            '(select id,dsfs__Envelope_Status__c from R00N80000002fD9vEAE__r where dsfs__Envelope_Status__c=\'Completed\')'+
            ' FROM Opportunity WHERE Type =\'Renewal\' LIMIT 1';
        
        //Test
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        Test.startTest();
        Database.executeBatch(new AutoCloseRenewalsBatch(query),1);
        Test.stopTest();
        
        //Asserts
        System.assertNotEquals(null, [SELECT ID,Auto_Close_Error__c from Opportunity where Type ='Renewal' LIMIT 1].Auto_Close_Error__c,'Error Must be populated ');
    }

    /**
	 *schedular_Test : Test Method for AutoCloseRenewalsBatch Schedular
	 */
    @isTest
    static  void schedular_Test() {
        Opportunity opportunity =[SELECT Id FROM Opportunity WHERE Type ='Renewal' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE Email='testcontactno@gmail.com' LIMIT 1];
        OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = opportunity.id, 
                                                                contactid = contact.id, role = 'Membership Decision Maker', IsPrimary = True);
        insert ocr;
        
        //Test
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        Test.startTest();
        AutoCloseRenewalsBatch autoCloseBatch = new AutoCloseRenewalsBatch();
        //Calls the Execute of schedular
        autoCloseBatch.execute(null);
        Test.stopTest();
        
         //Asserts
        System.assertEquals('Closed Won', [SELECT Id,StageName from Opportunity where Id =: opportunity.Id].StageName,'Opportunity must be closed won');
    }
    
}