@isTest
public class CreateRenewalTest
{
    static testMethod void MethodTest() 
    {
                Test.startTest();

        Endpoints__c endPoint = new Endpoints__c();
        endPoint.name = 'For Membership Details';
        endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=4';
        insert endPoint;
        
         Endpoints__c endPoint2 = new Endpoints__c();
        endPoint2.name = 'For Product Details';
        endPoint2.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=11';
        insert endPoint2;
        
        Id oppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        
        
       
        
        //Added
        
         Id MyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        //Account a = [select Id from Account limit 1];
        Account a = new account();
        a.name = 'Tes1t';
        a.BillingCountry = 'brasil';
        a.billingStreet = 'new';
        insert a ;

        Account a1 = new account();
        a1.name = 'Test 1111';
        a1.BillingCountry = 'brasil';
        a1.billingStreet = 'new';

        insert a1 ;
        Contact cont = new Contact(lastname = 'testCreateAsset1', email = 'AssetonClosedWo1n@gmail.com', accountid = a.id);
        insert cont;

        String baseUrl = string.valueof(System.URL.getSalesforceBaseUrl());
        ID priceBookIDs = Test.getStandardPricebookId();

        Product2 prods = new Product2();
        prods.Name = 'test111';
        prods.Family = 'Event';
        prods.IsActive = true;
        insert prods;

        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Product2Id = prods.id;
        standardPrice.UnitPrice = 234;
        standardPrice.IsActive = true;
        standardPrice.Pricebook2Id = pricebookIds;
        insert standardPrice;

        //PricebookEntry pbID = [select Id from PricebookEntry where isactive=true limit 1];

        Opportunity o = new Opportunity();
        OpportunityLineItem ol = new OpportunityLineItem();

        o.recordTypeId = MyRecTypeId;
        o.AccountId = a.Id;
        o.Name = 'test111';
        o.StageName = '2. Discovery';
        o.Type = 'Existing Business';
        o.CloseDate = date.today();
        o.Bill_To_Account__c = a1.Id;
        insert o;
        
        List<Project__c> projects = new List<Project__c>();
        projects.add(new Project__c(Name = 'testing111', Status__c = 'Planned',Category__c = 'Subproject', Subsidiary_ID__c = 8, Project_code__c = 'LF'));
        projects.add(new Project__c(Name = 'The Linux Foundation', Status__c = 'Planned',Category__c = 'Subproject',Subsidiary_ID__c = 8));
        insert projects;
        
       /* Event__c eventObj = new Event__c(name = 'testevt112', BillFromProject__c = projects[0].id, End_Date__c = Date.newInstance(2016, 12, 9), Start_Date__c = Date.newInstance(2016, 12, 9),Cvent_Event_Id__c='D43D3567-16E0-4AF2-45C6-6FE960E57384');
        insert eventObj;*/

        Event__c event = new Event__c(
            Event_Name__c = 'KubeCon',
            Name= 'KubeCon',    // Event Name
            Status__c = 'Complete',                                                                                                                                                  // Event Status
            Category__c = 'LF Event',                                                                                                                                                // Category
            BillFromProject__c = projects[1].id, //ID                                                                                                                                  // Bill From Project
            Start_Date__c = system.today() - 20,                                                                                                                               // Event Start Date
            Capacity__c = 0,                                                                                                                                          // Event Start Time
            End_Date__c = system.today() - 10,                                                                                                                                 // Event End Date
            Registration_Source__c = 'RegOnline',                                                                                                                                           // Event End Time
            Event_Location_Name__c = 'Twitter HQ One 10th Street Expansion',                                                                                                         // Event Location Name
            Event_Published__c = false,                                                                                                                                              // Event Published
            Event_Location_Address__c = 'One 10th Street',                                                                                                                           // Event Location Address
            Event_Location_City__c = 'San Francisco',                                                                                                                                // Event Location City
            Event_Location_State__c = 'California',                                                                                                                                  // Event Location State
            Event_Location_Country__c = 'United States',                                                                                                                             // Event Location Country
            Event_Location_Zip__c = '94103',                                                                                                                                         // Event Location Zip
            Embassy__c = 'US',                                                                                                                                                       // Embassy
            Cvent_Event_Is_Sandbox__c = false,                                                                                                                                             // NS Department
            //Type__c = 'Email',                                                                                                                                                       // Type
            Netsuite_Sync__c = false                                                                                                                                                // Netsuite Sync
        );
        insert event;

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
        pd.Event__c = event.id;
        pd.Products__c = prods.id;
        insert Pd;

        ol.OpportunityId = o.Id;
        ol.Quantity = 1;
        ol.UnitPrice = 2.00;
        ol.PricebookEntryId = standardPrice.Id;
        //ol.start_date__c=date.today();
        ol.start_date__c = Date.newInstance(2016, 8, 1);
        ol.end_date__c = date.today().addDays(2);
        ol.Technical_Contact__c = cont.Id;
        ol.Representative_Voting_Contact__c = cont.Id;
        ol.Marketing_Contact__c = cont.Id;
        ol.Press_Contact__c = cont.Id;
        ol.Legal_Contact__c = cont.Id;
        ol.Billing_Contact__c = cont.Id;
        ol.billing_contact2__c = cont.Id;
        ol.billing_contact3__c = cont.Id;
        ol.Event__c = event.id;
        ol.Projects__c = projects[0].Id;
        ol.Product_Details__c = pd.id;
        ol.PO_Number__c = '8899774455';
        ol.Skip_NetSuite_Sync__c = FALSE;
        //ol.End_Date__c= Date.newInstance(2016, 12, 9);
        insert ol;


        OpportunityContactRole ocrs = new OpportunityContactRole(opportunityid = o.id, contactid = cont.id, role = 'Membership Decision Maker', IsPrimary = True);
        insert ocrs;

        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Sent', dsfs__Opportunity__c = o.id);
        insert ds;

        Account_And_Project__c accProObj = new Account_And_Project__c();
        accProObj.Account__c = a.id;
        accProObj.Project__c = projects[0].id;
        accProObj.Subsidiary_ID__c = '8';
        insert accProObj;
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        
        Asset asset = new Asset();
        asset.Opportunity__c = o.Id;
        asset.Name = 'Test Asset';
        asset.AccountId = a.ID;
        asset.Projects__c = projects[0].id ;
        asset.Status = 'Active';
        insert asset;
        
        List<Asset> asst= [SELECT id,OpportunityLineItem__c,UsageEndDate,Renewal_Opportunity_Created__c FROM Asset where id=:asset.id];
        System.debug('___asst__'+asst);
        
        List<Asset> asstToUpdate= new List<Asset>();               
        
        if(asst != null && asst.size()>0){
            for(Asset ast : asst){
                ast.UsageEndDate=date.today().addDays(30);
                ast.Projects__c=projects[0].id;
                asstToUpdate.add(ast);
            }
        }
        
        system.debug('___asstToUpdate__'+asstToUpdate);
        if(asstToUpdate != null && asstToUpdate.size()>0){
            update asstToUpdate;
        }
        
        //system.debug('____asstToUpdate[0].Id___'+asstToUpdate[0].Id);
        
        Project_Role__c role = new Project_Role__c(Asset__c = asstToUpdate[0].Id , Contact__c = cont.Id , Role__c = 'Technical Contact');
        insert role;
        
        String jsonBody = AssetToSalesOrderHelper.createJSONFromOtherThanMemeberShipAsset(asset.Id , o.Id, new map<id,Opportunity> ());
        system.debug('jsonBody----->'+jsonBody);
        
        

        
        
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
        Test.stopTest();

                CreateRenewal.executeBatchForAutoRenewal(asstToUpdate[0].id);

        
    }
    
}