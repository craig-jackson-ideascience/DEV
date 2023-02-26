@IsTest
public class AssetSyncToNetSuiteController_Test {
    @testSetup
    public static void setupData(){
        
        Endpoints__c endPoint = new Endpoints__c();
        endPoint.name = 'For Membership Asset';
        endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=90&deploy=4';
        insert endPoint;
        
        Endpoints__c endPoint2 = new Endpoints__c();
        endPoint2.Name = 'For Product Details';
        endPoint2.Endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=41&deploy=1';
        endPoint2.Password__c = 'jYdpn8sp22F8C45b';
        endPoint2.User_Id__c = 'nsapi@linuxfoundation.org';
        endPoint2.Nlauth_Account__c = '4010327_SB1';
        insert endPoint2;
        
        
        Account a = new Account();
        a.Name = 'TestAccount';
        a.billingstreet  = 'Test';
        a.billingcity  = 'Testcity';
        a.billingstate  = 'TX';
        a.billingPostalCode = '123';
        a.billingCountry = 'US';
        a.P_O_Required__c=true;
        a.Event_PO_required__c=true;
        insert a;
        
        System.debug(a + '====> a');
        
        Contact con = new Contact(lastname = 'testCreateAsset', email = 'AssetonClosedWon@gmail.com', accountid = a.id);
        insert con;
        
        Product2 prod = new Product2(Name = 'Product', Family = 'Membership', Tax_Class__c = 'test');
        insert prod;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        PricebookEntry pbID = [select Id from PricebookEntry where isactive = true limit 1];
        Opportunity o = new Opportunity();
        OpportunityLineItem ol = new OpportunityLineItem();
        
        
        o.AccountId = a.Id;
        o.Name = 'test';
        o.StageName = '2. Discovery';
        o.Type = 'Renewal';
        o.CloseDate = date.today();
        o.Bill_To_Account__c = a.Id;
        insert o;
        system.debug('o----->'+o.Id);
        OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = o.id, contactid = con.id, role = 'Membership Decision Maker', IsPrimary = True);
        insert ocr;
        
        Project__c prj = new Project__c(Name = 'testing11', Status__c = 'Planned',Category__c = 'Directed Fund', Subsidiary_ID__c = 8, Slug__c = 'testing');
        insert prj;
        
        
        Product_Details__c Pd = new Product_Details__c();
        Pd.Price__c = 56;
        pd.Project__c = prj.Id;
        Pd.NS_Income_GL_Account__c = '290';
        pd.NS_Deferred_Revenue_Account__c = '284';
        pd.NS_Department__c = '10';
        pd.NS_Revenue_Schedule__c = '29';
        Pd.Netsuite_Sync__c = false;
        pd.Products__c = prod.id;
        Pd.Duration__c = '45';
        Pd.Description__c = 'Description_Test';
        Pd.Tier__c = 'Test';
        pd.Netsuite_ID__c = '889955';
        insert Pd;
        
        ol.OpportunityId = o.Id;
        ol.Quantity = 1;
        ol.UnitPrice = 2.00;
        ol.PricebookEntryId = pbId.Id;
        ol.start_date__c = Date.newInstance(2016, 8, 1);
        ol.end_date__c = date.today().addDays(2);
        ol.Technical_Contact__c = con.Id;
        ol.Technical_Contact_2__c = con.Id;
        ol.Technical_Contact_3__c = con.Id;
        ol.PO_Contact__c = con.Id;
        ol.Authorized_Signatory__c = con.Id;
        ol.Representative_Voting_Contact__c = con.Id;
        ol.Marketing_Contact__c = con.Id;
        ol.Press_Contact__c = con.Id;
        ol.Legal_Contact__c = con.Id;
        ol.Billing_Contact__c = con.Id;
        ol.billing_contact2__c = con.Id;
        ol.billing_contact3__c = con.Id;
        ol.Marketing_Contact_2__c = con.Id;
        ol.Marketing_Contact_3__c = con.Id;
        ol.Projects__c = prj.Id;
        ol.Product_Details__c = pd.id;
        ol.AgreementDate__c = Date.today().addDays(4);
        ol.description__c = 'Test desc';
        insert ol;
        
        o.StageName = '3.Quote';
        update o;
        o.StageName = '4.Contract';
        update o;
        o.StageName = '5.Decision Commitment';
        update o;
        
        Asset ast =  TestFactory.getAsset();
        ast.Opportunity__c=o.id;
        ast.OpportunityLineItem__c = ol.Id;
        ast.usageenddate = null;
        update ast;
        
    }
    @isTest
    public static void AssetSyncToNetSuiteController_test(){
        Test.startTest();
        Asset ast = [SELECT Id from Asset LIMIT 1];
        //ast.InstallDate = date.today();
        ast.memo__c = 'This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli';
        update ast;
        Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        String result =AssetSyncToNetSuiteController.validateAndSyncToNetSuite(ast.Id);
        System.assert(result.contains('memo cant be more than 999 chars '));
    }
    
    @isTest
    public static void AssetSyncToNetSuiteController_test2(){
        Test.startTest();
        Asset ast = [SELECT Id from Asset LIMIT 1];
        OpportunityLineItem oli = [SELECT Id from OpportunityLineItem LIMIT 1];
        ast.InstallDate = date.today();
        oli.description__c = 'This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli,This is test description oli';
        update oli;
        update ast;
        Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        String result = AssetSyncToNetSuiteController.validateAndSyncToNetSuite(ast.Id);
        System.assert(result.contains('End Date cannot be null'));        
        
    }
    @isTest
    public static void AssetSyncToNetSuiteController_test3(){
        Asset ast = [SELECT Id from Asset LIMIT 1];
        ast.InstallDate = system.today();
        ast.Memo__c = 'Test memo';
        ast.usageenddate = system.today();
        update ast;
        OpportunityLineItem oli = [SELECT Id from OpportunityLineItem LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        String result = AssetSyncToNetSuiteController.validateAndSyncToNetSuite(ast.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void AssetSyncStartDate_test(){
        Test.startTest();
        Asset ast = [SELECT Id from Asset LIMIT 1];
        OpportunityLineItem oli = [SELECT Id from OpportunityLineItem LIMIT 1];
		oli.Start_Date__c = null;
        update oli;
        Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        String result =AssetSyncToNetSuiteController.validateAndSyncToNetSuite(ast.Id);
        System.assert(result.contains('The Start Date is not populated'));
    }
    
    @isTest
    public static void AssetSyncAssetStartDate_test(){
        Test.startTest();
        Asset ast = [SELECT Id from Asset LIMIT 1];
        ast.InstallDate = null;
        update ast;
        Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        String result =AssetSyncToNetSuiteController.validateAndSyncToNetSuite(ast.Id);
        System.assert(result.containsIgnoreCase('Start Date Cannot be null'));
    }
    
    @isTest
    public static void AssetSyncProductDetail_test(){
        Test.startTest();
        Asset ast = [SELECT Id from Asset LIMIT 1];
        ast.InstallDate = date.today();
        ast.usageenddate = date.today();
		update ast;
        Product_Details__c pd = [SELECT Id,Netsuite_ID__c,Subsidiary_ID__c,Project__r.Subsidiary_ID__c from Product_Details__c LIMIT 1];
		pd.Netsuite_ID__c = null;
        update pd;
        Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        String result =AssetSyncToNetSuiteController.validateAndSyncToNetSuite(ast.Id);
        System.assert(result.containsIgnoreCase('Product Detail netsuiteId cannot be blank'));
        
        pd.Netsuite_ID__c ='889955';
        pd.Project__r.Subsidiary_ID__c = null;
        update pd;
        result =AssetSyncToNetSuiteController.validateAndSyncToNetSuite(ast.Id);
        System.assert(result.containsIgnoreCase('Product Detail subsidiary cannot be blank'));
    }
    
}