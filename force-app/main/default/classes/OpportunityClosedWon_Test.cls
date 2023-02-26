/**
 * Test class for OpportunityClosedWon
 */
@IsTest
public class OpportunityClosedWon_Test{
    static Id membershipRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
    static Id eventRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Event').getRecordTypeId();
    static Id trainingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();
    /**
     * TestSetup inserting required data for test class
     */
    @TestSetup
    static void createTestData(){

        //EndPoints
        List<Endpoints__c> endPointList = new List<Endpoints__c>();

        Endpoints__c endPoint = new Endpoints__c();
        endPoint.name = 'For Membership Asset';
        endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=90&deploy=4';
        endPointList.add(endPoint);

        Endpoints__c endPoint1 = new Endpoints__c();
        endPoint1.name = 'For Other than Membership Asset';
        endPoint1.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=89&deploy=11';
        endPointList.add(endPoint1);

        Endpoints__c endPoint2 = new Endpoints__c();
        endPoint2.name = 'For Product Details';
        endPoint2.Endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=41&deploy=1';
        endPoint2.Password__c = 'jYdpn8sp22F8C45b';
        endPoint2.User_Id__c = 'nsapi@linuxfoundation.org';
        endPoint2.Nlauth_Account__c = '4010327_SB1';
        endPointList.add(endPoint2);
        System.debug('endPoint1 ' + endPoint1);
        System.debug('endPoint ' + endPoint);
        System.debug('endPoint1 ' + endPoint2);

        insert endPointList;

        Account a = new Account();
        a.Name = 'TestAccount';
        a.billingstreet = 'Test';
        a.billingcity = 'Testcity';
        a.billingstate = 'TX';
        a.billingPostalCode = '123';
        a.billingCountry = 'US';
        insert a;

        System.debug(a + '====> a');

        Contact con = new Contact(lastname = 'testCreateAsset', email = 'AssetonClosedWon@gmail.com', accountid = a.id);
        insert con;

        //Membership opp
        Opportunity o = new Opportunity();
        List<Opportunity> oppList = new List<Opportunity>();
        o.AccountId = a.Id;
        o.Name = 'test';
        o.StageName = '2. Discovery';
        o.Type = 'Existing Business';
        o.CloseDate = date.today();
        o.Bill_To_Account__c = a.Id;
        o.Individual__c = true;
        o.RecordTypeID = membershipRecordId;

        //Event opp
        Opportunity eventOpp = new Opportunity();
        eventOpp.recordTypeId = eventRecordTypeId;
        eventOpp.AccountId = a.Id;
        eventOpp.Name = 'test event';
        eventOpp.StageName = '2. Discovery';
        eventOpp.Type = 'Existing Business';
        eventOpp.CloseDate = date.today();
        eventOpp.Bill_To_Account__c = a.Id;
        oppList.add(o);
        oppList.add(eventOpp);

        //Training opp
        Opportunity trainingOpp = new Opportunity();
        trainingOpp.recordTypeId = trainingRecordTypeId;
        trainingOpp.AccountId = a.Id;
        trainingOpp.Name = 'test event';
        trainingOpp.StageName = '2. Discovery';
        trainingOpp.Type = 'Existing Business';
        trainingOpp.CloseDate = date.today();
        trainingOpp.Bill_To_Account__c = a.Id;
        trainingOpp.Billing_Contact__c = con.Id;
        oppList.add(trainingOpp);

        insert oppList;

        OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = o.id, contactid = con.id, role = 'Membership Decision Maker', IsPrimary = True);
        insert ocr;

        Project__c prj = TestDataUtils.createProject(true, 'The Linux Foundation', 'Event', 'Directed Fund', 'Planned');
        prj.Subsidiary_ID__c = 8;
        prj.Status__c = 'Active';
        prj.Funding__c = 'Funded';
        update prj;

        Event__c evt = TestDataUtils.createEvent(false, 'Test Event', 'Unfunded', 'LF Event', 'Planned');
        evt.BillFromProject__c = prj.Id;
        evt.Event_Location_Country__c = 'United Kingdom';
        insert evt;

        Training__c training = new Training__c(Name = 'test Training', Is_Dummy_Product__c = true);
        insert training;

        List<Product2> prodList = new List<Product2>();
        Product2 prod = new Product2(Name = 'Individual Membership', Family = 'Membership', Tax_Class__c = 'test');
        prodList.add(prod);

        Product2 prod1 = new Product2(Name = 'Event Product', Family = 'Event', Tax_Class__c = 'test');
        prodList.add(prod1);

        Product2 prod2 = new Product2(Name = 'Training Product', Family = 'Training', Tax_Class__c = 'test');
        prodList.add(prod2);
        insert prodList;

        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        for (Product2 product : prodList){
            PricebookEntry standardPrice = new PricebookEntry();
            standardPrice.Product2Id = product.id;
            standardPrice.UnitPrice = 234;
            standardPrice.IsActive = true;
            standardPrice.Pricebook2Id = Test.getStandardPricebookId();
            pbeList.add(standardPrice);
        }
        insert pbeList;

        List<Product_Details__c> prodDetailList = new List<Product_Details__c>();
        Product_Details__c productDetail = new Product_Details__c();
        productDetail.Price__c = 56;
        productDetail.Project__c = prj.Id;
        productDetail.NS_Income_GL_Account__c = '290';
        productDetail.NS_Deferred_Revenue_Account__c = '284';
        productDetail.NS_Department__c = '10';
        productDetail.NS_Revenue_Schedule__c = '29';
        productDetail.Netsuite_Sync__c = false;
        productDetail.Products__c = prod.id;
        productDetail.Duration__c = '45';
        productDetail.Description__c = 'Description_Test';
        productDetail.Tier__c = 'Test';
        productDetail.Netsuite_ID__c = '889955';
        productDetail.End_Tier__c = 100;
        productDetail.Start_Tier__c = 10;
        prodDetailList.add(productDetail);

        Product_Details__c prodDetail1 = new Product_Details__c();
        prodDetail1.Price__c = 56;
        prodDetail1.NS_Income_GL_Account__c = '290';
        prodDetail1.NS_Deferred_Revenue_Account__c = '284';
        prodDetail1.NS_Department__c = '10';
        prodDetail1.NS_Revenue_Schedule__c = '29';
        prodDetail1.Products__c = prod1.id;
        prodDetail1.Netsuite_Sync__c = false;
        prodDetail1.Duration__c = '45';
        prodDetail1.Description__c = 'Description_Test';
        prodDetail1.Tier__c = 'Test';
        prodDetail1.Netsuite_ID__c = '889955';
        prodDetail1.Event__c = evt.Id;
        prodDetailList.add(prodDetail1);

        Product_Details__c prodDetail2 = new Product_Details__c();
        prodDetail2.Price__c = 56;
        prodDetail2.NS_Income_GL_Account__c = '290';
        prodDetail2.NS_Deferred_Revenue_Account__c = '284';
        prodDetail2.NS_Department__c = '10';
        prodDetail2.NS_Revenue_Schedule__c = '29';
        prodDetail2.Products__c = prod2.id;
        prodDetail2.Netsuite_Sync__c = false;
        prodDetail2.Duration__c = '45';
        prodDetail2.Description__c = 'Description_Test';
        prodDetail2.Tier__c = 'Test';
        prodDetail2.Netsuite_ID__c = '889955';
        prodDetail2.Training__c = training.Id;
        productDetail.Start_Tier__c = 10;
        prodDetailList.add(prodDetail2);

        insert prodDetailList;

        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        Integer i = 0;
        for (Opportunity opp : oppList){
            OpportunityLineItem lineItem = new OpportunityLineItem();

            lineItem.OpportunityId = opp.Id;
            lineItem.Quantity = 1;
            lineItem.UnitPrice = 2.00;
            lineItem.PricebookEntryId = pbeList[i].Id;
            lineItem.start_date__c = Date.newInstance(2016, 8, 1);
            lineItem.end_date__c = date.today().addDays(2);
            lineItem.Description__c = 'test';
            if (i == 0){
                lineItem.Representative_Voting_Contact__c = con.Id;
                lineItem.Marketing_Contact__c = con.Id;
                lineItem.Technical_Contact__c = con.Id;
                lineItem.Press_Contact__c = con.Id;
                lineItem.Legal_Contact__c = con.Id;
                lineItem.Projects__c = prj.Id;
                lineItem.Billing_Contact__c = con.Id;

            } else if (i == 1){
                lineItem.Event__c = evt.Id;

            } else if (i == 2){
                lineItem.Billing_Contact__c = con.Id;

                lineItem.Training__c = training.Id;
                lineItem.Skip_NetSuite_Sync__c = true;
            }


            lineItem.Product_Details__c = prodDetailList[i].id;
            lineItem.PO_Number__c = '8899774455';
            i++;
            oppLineItemList.add(lineItem);
        }

        insert oppLineItemList;

        List<Project_Role__c> projectRoles = new List<Project_Role__c>();
        Project_Role__c objProjectRole = new Project_Role__c();
        objProjectRole.status__c = 'Active';
        objProjectRole.Contact__c = con.id;
        objProjectRole.Role__c = 'Representative/Voting Contact';
        objProjectRole.PrimaryContact__c = true;
        objProjectRole.Opportunity__c = o.Id;
        objProjectRole.Opportunity_Line_Item__c = oppLineItemList[0].Id;
        projectRoles.add(objProjectRole);
        Project_Role__c objProjectRole1 = new Project_Role__c();
        objProjectRole1.status__c = 'Active';
        objProjectRole1.Contact__c = con.id;
        objProjectRole1.Role__c = 'Billing Contact';
        objProjectRole1.PrimaryContact__c = true;
        objProjectRole1.Opportunity__c = o.Id;
        objProjectRole1.Opportunity_Line_Item__c = oppLineItemList[0].Id;
        projectRoles.add(objProjectRole1);
        Project_Role__c objProjectRole2 = new Project_Role__c();
        objProjectRole2.status__c = 'Active';
        objProjectRole2.Contact__c = con.id;
        objProjectRole2.Role__c = 'Marketing Contact';
        objProjectRole2.Opportunity__c = o.Id;
        objProjectRole2.Opportunity_Line_Item__c = oppLineItemList[0].Id;
        projectRoles.add(objProjectRole2);
        insert projectRoles;

        o.StageName = '3.Quote';
        eventOpp.StageName = '3.Quote';

        update new List<Opportunity>{ o, eventOpp };
        o.StageName = '4.Contract';
        eventOpp.StageName = '4.Contract';
        update new List<Opportunity>{ o, eventOpp };

        o.StageName = '5.Decision Commitment';
        eventOpp.StageName = '5.Decision Commitment';
        update new List<Opportunity>{ o, eventOpp };
    }

    /**
	 *membershipOppClosedWon_Test : Test method for closing membership opportunity
	 */
    @IsTest
    static void membershipOppClosedWon_Test(){
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());

        Opportunity opp = [SELECT iD
                           FROM Opportunity
                           WHERE RecordTypeId = :membershipRecordId];
        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();


        System.assertEquals(1, [SELECT count()
                                FROM Asset
                                WHERE Opportunity__c = :opp.id], 'Asset must got created');
    }

	/**
	 *eventOppClosedWon_Test : Test method for closing event opportunity
	 */
    @IsTest
    static void eventOppClosedWon_Test(){
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());

        Opportunity opp = [SELECT Id
                           FROM Opportunity
                           WHERE RecordTypeId = :eventRecordTypeId];
        Test.startTest();
        opp.StageName = 'Closed Won';
        try{
            update opp;
        } catch (Exception ex){
            System.debug('Exception: ' + ex + ', Message: ' + ex.getMessage() + ', Line Number: ' + ex.getLineNumber() + '\n' + ex.getStackTraceString());
            System.assertEquals(0, [SELECT count()
            FROM Opportunity 
            WHERE Id =: opp.Id and StageName = 'Closed Won'], 'Opportunity should not be Closed Won as billing contact on lineitem is blank');
        }
        Test.stopTest();
    }

    /**
	 *trainingOppClosedWon_Test : Test method for closing training opportunity
	 */
    @IsTest
    static void trainingOppClosedWon_Test(){
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());

        Opportunity opp = [SELECT Id
                           FROM Opportunity
                           WHERE RecordTypeId = :trainingRecordTypeId
                           LIMIT 1];
        Test.startTest();
        opp.StageName = 'Closed Won';
       
            update opp;
        
        Test.stopTest();
        System.assertEquals(1, [SELECT count()
                                FROM Asset
                                WHERE Opportunity__c = :opp.id], 'Asset must got created');
    }
}