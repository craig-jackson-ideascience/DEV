@isTest
public class CallOutToNetSuiteForAssetTest {
    @isTest
    static  void testOpportunityClosedWon() {

        Id MyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Event').getRecordTypeId();

        Endpoints__c endPoint = new Endpoints__c();
        endPoint.name = 'For Other than Membership Asset';
        endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=89&deploy=11';
        insert endPoint;

        Endpoints__c endPoint2 = new Endpoints__c();
        endPoint2.name = 'For Product Details';
        endPoint2.endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=41&deploy=1';
        insert endPoint2;

        //Account a = [select Id from Account limit 1];
        Account a = new account();
        a.name = 'Test';
        a.BillingCountry = 'brasil';
        a.billingStreet = 'new';
        insert a ;

        Account a1 = new account();
        a1.name = 'Test 1';
        a1.BillingCountry = 'brasil';
        a1.billingStreet = 'new';

        insert a1 ;
        Contact con = new Contact(lastname = 'testCreateAsset', email = 'AssetonClosedWon@gmail.com', accountid = a.id);
        insert con;

        String baseUrl = string.valueof(System.URL.getSalesforceBaseUrl());
        ID priceBookID = Test.getStandardPricebookId();

        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Event';
        prod.IsActive = true;
        insert prod;

        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Product2Id = prod.id;
        standardPrice.UnitPrice = 234;
        standardPrice.IsActive = true;
        standardPrice.Pricebook2Id = pricebookId;
        insert standardPrice;

        //PricebookEntry pbID = [select Id from PricebookEntry where isactive=true limit 1];

        Opportunity o = new Opportunity();
        OpportunityLineItem ol = new OpportunityLineItem();

        o.recordTypeId = MyRecTypeId;
        o.AccountId = a.Id;
        o.Name = 'test';
        o.StageName = '2. Discovery';
        o.Type = 'Existing Business';
        o.CloseDate = date.today();
        o.Bill_To_Account__c = a1.Id;
        insert o;
        
        List<Project__c> projects = new List<Project__c>();
        projects.add(new Project__c(Name = 'testing11',Notifications_Group__c = 'test@test.com',Do_Not_Invoice__c = true,Category__c = 'Directed Fund', Subsidiary_ID__c = 8, Project_code__c = 'LF'
                                   ,Status__c='Active',Funding__c='Funded', Slug__c = 'test_slug1', Model__c = 'Membership'));
        projects.add(new Project__c(Name = 'The Linux Foundation',Notifications_Group__c = 'test@test.com',Do_Not_Invoice__c = true, Status__c = 'Planned',Category__c = 'Directed Fund',Subsidiary_ID__c = 8, Slug__c = 'test_slug'));
        insert projects;
        
        Event__c eventObj = new Event__c(name = 'test',Status__c = 'Active', BillFromProject__c = projects[0].id, End_Date__c = Date.newInstance(2016, 12, 9), Start_Date__c = Date.newInstance(2016, 12, 9));
        insert eventObj;


        Product_Details__c Pd = new Product_Details__c();
        Pd.Price__c = 56;
        //Pd.Subsidiary__c='The Linux Foundation';
        Pd.NS_Income_GL_Account__c = '290';
        pd.NS_Deferred_Revenue_Account__c = '284';
        pd.NS_Department__c = '10';
        pd.NS_Revenue_Schedule__c = '29';
        Pd.Netsuite_Sync__c = false;
        Pd.Duration__c = '45';
        Pd.Description__c = 'Description_Test';
        Pd.Tier__c = 'Test';
        pd.Netsuite_ID__c = '889955';
        //pd.Project__c=prj.id;
        pd.Event__c = eventObj.id;
        pd.Products__c = prod.id;
        insert Pd;

        ol.OpportunityId = o.Id;
        ol.Quantity = 1;
        ol.UnitPrice = 2.00;
        ol.PricebookEntryId = standardPrice.Id;
        //ol.start_date__c=date.today();
        ol.start_date__c = Date.newInstance(2016, 8, 1);
        ol.end_date__c = date.today().addDays(2);
        ol.Prorate__c = true;
        ol.Technical_Contact__c = con.Id;
        ol.Representative_Voting_Contact__c = con.Id;
        ol.Marketing_Contact__c = con.Id;
        ol.Press_Contact__c = con.Id;
        ol.Legal_Contact__c = con.Id;
        ol.Billing_Contact__c = con.Id;
        ol.billing_contact2__c = con.Id;
        ol.billing_contact3__c = con.Id;
        ol.Event__c = eventObj.id;
        ol.Projects__c = projects[0].Id;
        ol.Product_Details__c = pd.id;
        ol.PO_Number__c = '8899774455';
        ol.Skip_NetSuite_Sync__c = FALSE;
        //ol.End_Date__c= Date.newInstance(2016, 12, 9);
        insert ol;

        OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = o.id, contactid = con.id, role = 'Membership Decision Maker', IsPrimary = True);
        insert ocr;

    Test.startTest();
        

        Account_And_Project__c accProObj = new Account_And_Project__c();
        accProObj.Account__c = a.id;
        accProObj.Project__c = projects[0].id;
        accProObj.Subsidiary_ID__c = '8';
        insert accProObj;
        
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Completed', dsfs__Opportunity__c = o.id);
        insert ds;

        /*Account_And_Project__c accProObj=new Account_And_Project__c();
        accProObj.Account__c = a.id;
        accProObj.Project__c =prj.id;
        accProObj.Subsidiary_ID__c = '8';
        insert accProObj;*/


        
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        Test.stopTest();
        
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
            String OpportunityFieldNames;

            for(String ss : schemaFieldMap.keyset()){
                if(ss != ''){
                    if(OpportunityFieldNames != null){
                        OpportunityFieldNames += ',' + ss;
                    }else{
                        OpportunityFieldNames = ss;
                    }
                }
            }
            Id opportunityid=o.Id;
            Map<Id,opportunity> oppMap = new Map<Id, Opportunity>((List<Opportunity>)
            database.query('select '+OpportunityFieldNames+' FROM Opportunity where id=:opportunityid'));
        Id assetId = [SELECT Id , Name FROM Asset WHERE Opportunity__c = :opportunityid limit 1].id;
        String jsonBody = AssetToSalesOrderHelper.createJSONFromOtherThanMemeberShipAsset(assetId , opportunityid, oppMap);
        //String jsonBody='{"items":[{"revrecenddate":"12/9/2016","revrecstartdate":"12/9/2016","amount":2.00,"quantity":1,"price":1,"item":"889955"}],"custbody_pal_invoice":"F","custbody_sugar_reference":"https://linuxfoundation--stage.my.salesforce.com/0066s000002bgMw","subsidiary":8,"custbody_additional_email_2":"assetonclosedwon@gmail.com","custbody_additional_email_1":"assetonclosedwon@gmail.com","otherrefnum":"8899774455","custbody_primary_email":"assetonclosedwon@gmail.com","recordtype":"salesorder","billaddress":"Test 1\nnew\n  \nBrazil","location":null,"custbody_corp_training_bundle_":"F","Project_Code__c":"LF","accId":"0016s00000BeVO6AAN","syncAccount":"{\"country\":\"BR\",\"state\":\"\",\"zip\":\"\",\"city\":\"\",\"addr1\":\"new\",\"phone\":null,\"url\":null,\"recordtype\":\"customer\",\"subsidiary\":\"8\",\"entityid\":\"Test - LF\",\"companyname\":\"Test\"}","entity":null}';
        system.debug('jsc '+jsonBody);
        list<Asset> assetList = [select id, Skip_NetSuite_Sync__c from Asset where Opportunity__c =:opportunityid AND Skip_NetSuite_Sync__c = FALSE ];
        Boolean checkAssetRecord = False;    
        system.debug('**assetList'+assetList);
            set<id> assetIds = new set <id>();
            for(Asset assetObj : assetList) {
                    if(assetObj != null){
                        assetIds.add(assetObj.id);
                        checkAssetRecord =  True;
                    }
            }
            if(checkAssetRecord == True){
                   CallOutToNetSuiteForAsset.callOutToNet( endPoint.endpoint__c , 'POST' ,jsonBody  , assetId, assetIds); 
                }
                
          
        
        }
    
    @isTest
    static void testCalloitToNetSuite(){
        Endpoints__c endPoint = new Endpoints__c();
        endPoint.name = 'For Membership Asset';
        endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=90&deploy=4';
        insert endPoint;

        Endpoints__c endPoint2 = new Endpoints__c();
        endPoint2.name = 'For Product Details';
        endPoint2.endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=41&deploy=1';
        insert endPoint2;
        
        Asset ast =  TestFactory.getAsset();
        //create product details
        Product_Details__c Pd = new Product_Details__c();
        Pd.Price__c = 56;
        Pd.NS_Income_GL_Account__c = '290';
        pd.NS_Deferred_Revenue_Account__c = '284';
        pd.NS_Department__c = '10';
        pd.NS_Revenue_Schedule__c = '29';
        Pd.Netsuite_Sync__c = false;
        Pd.Duration__c = '45';
        Pd.Description__c = 'Description_Test';
        Pd.Tier__c = 'Test';
        pd.Netsuite_ID__c = '889955';
        pd.Project__c=[SELECT ID FROM Project__c LIMIT 1].ID;
        pd.Products__c = [SELECT ID FROM Product2 LIMIT 1].ID;
        insert Pd;
        
        OpportunityLineItem oli = new OpportunityLineItem(Id= ast.OpportunityLineItem__c,Product_Details__c = pd.Id);
        update oli;

        Opportunity opp= [SELECT Id FROM Opportunity WHERE ID=: ast.Opportunity__c];
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
		Test.startTest();
       	String jsonBody = AssetToSalesOrderHelper.createJSONFromMemeberShipAsset(new Set<String>{ast.Id},ast.Opportunity__c,new Map<Id,Opportunity>{ast.Opportunity__c=>opp});
        CallOutToNetSuiteForAsset.callingCallOutToNet(jsonBody,endPoint.endpoint__c,new Set<String>{ast.Id});
        Test.stopTest();
        System.assertEquals('SO8624',[SELECT SalesOrderNumber__c FROM Asset WHERE ID=: ast.ID].SalesOrderNumber__c);

    }
    
    @isTest
    static void testNSAssetTriggerHelper(){
        Endpoints__c endPoint = new Endpoints__c();
        endPoint.name = 'For Membership Asset';
        endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=90&deploy=4';
        insert endPoint;

        Endpoints__c endPoint2 = new Endpoints__c();
        endPoint2.name = 'For Product Details';
        endPoint2.endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=41&deploy=1';
        insert endPoint2;
        
        Asset ast =  TestFactory.getAsset();
        //create product details
        Product_Details__c Pd = new Product_Details__c();
        Pd.Price__c = 56;
        Pd.NS_Income_GL_Account__c = '290';
        pd.NS_Deferred_Revenue_Account__c = '284';
        pd.NS_Department__c = '10';
        pd.NS_Revenue_Schedule__c = '29';
        Pd.Netsuite_Sync__c = false;
        Pd.Duration__c = '45';
        Pd.Description__c = 'Description_Test';
        Pd.Tier__c = 'Test';
        pd.Netsuite_ID__c = '889955';
        pd.Project__c=[SELECT ID FROM Project__c LIMIT 1].ID;
        pd.Products__c = [SELECT ID FROM Product2 LIMIT 1].ID;
        insert Pd;
        
        OpportunityLineItem oli = new OpportunityLineItem(Id= ast.OpportunityLineItem__c,Product_Details__c = pd.Id);
        update oli;

        Opportunity opp= [SELECT Id FROM Opportunity WHERE ID=: ast.Opportunity__c];
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
		Test.startTest();
        NSAssetTriggerHelper.checkRecordTypeAndCallNS(new Set<Id>{ast.Id},ast.Opportunity__c,new Map<Id,Opportunity>{ast.Opportunity__c=>opp});
        Test.stopTest();
        System.assertEquals('SO8624',[SELECT SalesOrderNumber__c FROM Asset WHERE ID=: ast.ID].SalesOrderNumber__c);

    }
    
}