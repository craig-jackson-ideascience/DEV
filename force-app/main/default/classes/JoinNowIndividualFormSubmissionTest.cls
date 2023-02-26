/********************************************************
 * Created by: CloudRoute @ CloudRoute Solutions
 * Created Date: 16/04/20.
 * Description: JoinNowIndividualFormSubmissionTest
 ********************************************************/

@isTest
public class JoinNowIndividualFormSubmissionTest {
    @TestSetup static void generateTestData() {

        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account acc1=new Account();
        acc1.RecordTypeId=recordTypeId;
        acc1.P_O_Required__c=false;
        acc1.FirstName = 'TestPersonAccountFirst';
        acc1.LastName = 'TestPersonAccountLast';
        acc1.PersonEmail = 'test1@user.com';
        acc1.P_O_Required__c=false;
        insert acc1;

        Account acc2=new Account();
        acc2.RecordTypeId=recordTypeId;
        acc2.P_O_Required__c=false;
        acc2.FirstName = 'TestPersonAccountFirst';
        acc2.LastName = 'TestPersonAccountLast';
        acc2.PersonEmail = 'test2@user.com';
        acc2.P_O_Required__c=false;
        insert acc2;

        Account acc=new Account();
        acc.Name='test name';
        insert acc;

        lead l = new lead();
        l.lastName = 'Test l LastName';
        l.company = 'Test l Company';
        l.Email = 'test@leadRecord.com';
        l.status = 'working';
        insert l;

        lead learRec = new lead();
        learRec.lastName = 'Test l LastName';
        learRec.company = 'Test l Company';
        learRec.Email = 'test2@leadRecord.com';
        learRec.status = 'working';
        insert learRec;


        Contact con = new Contact();
        con.firstName = 'Test First name';
        con.lastName = 'Test last Name';
        con.accountId = acc.Id;
        con.email = 'test2@Con.com';
        insert con;

        Contact con1 = new Contact();
        con1.firstName = 'Test First name';
        con1.lastName = 'Test last Name';
        con1.email = 'test1@Con.com';
        con1.accountId = acc.Id;
        insert con1;

        
        Contact con3 = new Contact();
        con3.firstName = 'Test First name';
        con3.lastName = 'Test last Name';
        con3.email = 'test3@Con.com';
        con3.accountId = acc.Id;
        con3.Title = 'Test';
        con3.phone = '1234';
        con3.Twitter_ID__c = 'Test';
        con3.GitHub_ID__c = 'Test ID';
        con3.LinkedIn_ID__c = 'Linkdin ID';
        con3.MailingStreet = 'Test Street';
        con3.MailingCity = 'Test City';
        con3.MailingState = 'Test State';
        con3.MailingCountry = 'Test Country';
        con3.MailingPostalCode = '123';
        con3.Username__c = 'Test UserName';
        insert con3;

        Contact con4 = new Contact();
        con4.firstName = 'Test First name';
        con4.lastName = 'Test 8 Name';
        con4.email = 'test4@Con.com';
        con4.accountId = acc.Id;
        con4.Title = 'Test';
        con4.phone = '1234';
        con4.Twitter_ID__c = 'Test Test';
        con4.GitHub_ID__c = ' Test Test Test ID';
        con4.LinkedIn_ID__c = 'Test Test Linkdin ID';
        con4.MailingStreet = 'Test Test Test Street';
        con4.MailingCity = 'Test Test Test City';
        con4.MailingState = 'Test Test Test State';
        con4.MailingCountry = 'Test Test Test Country';
        con4.MailingPostalCode = '123';
        con4.Username__c = 'Test Test Test UserName';
        insert con4;

        Alternate_Email__c altEmail3 = [Select ID from Alternate_Email__c where Alternate_Email_Address__c = 'test3@Con.com'];
        delete altEmail3;

        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Tax_Class__c = 'T1';
        p.IsActive = true;
        p.Family = 'Membership';
        insert p;

        Project__c pj = new Project__c();
        pj.Name = 'Test project';
        pj.Type__c = 'Membership';
        pj.Project_Type__c = 'Project';
        pj.Project_Entity_Name__c = 'Test P Name';
        pj.Category__c = 'Subproject';
        pj.Slug__c = 'testing';
        insert pj;

        Product_Details__c pd = new Product_Details__c();
        pd.Project__c = pj.Id;
        pd.Products__c = p.Id;
        pd.Price__c = 20;
        pd.Status__c = 'Active';
        pd.Description__c = 'test';
        insert pd;

        Product_Details__c pd1 = new Product_Details__c();
        pd1.Products__c = p.Id;
        pd1.Description__c = 'test';
        insert pd1;

        List<Alternate_Email__c> altEmails = new List<Alternate_Email__c> ();
        for (integer i = 0; i < 20; i++) {

            Alternate_Email__c alt = new Alternate_Email__c();
            Alternate_Email__c altl = new Alternate_Email__c();

            alt.Alternate_Email_Address__c = 'Test' + i + '@test.com';
            alt.Contact_Name__c = con.id;
            altl.Lead_Name__c = l.id;
            alt.Active__c = true;
            altEmails.add(alt);
            altEmails.add(altl);
        }

        Alternate_Email__c altl = new Alternate_Email__c();
        altl.Alternate_Email_Address__c = 'test30@gmail.com';
        altl.Lead_Name__c = l.id;
        altl.Active__c = true;
        altEmails.add(altl);

        insert altEmails;

        Pricebook2 priceBook=new Pricebook2();
        priceBook.Name='Standard';
        priceBook.IsActive=True;
        insert priceBook;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        PriceBookEntry priceEntry=new PriceBookEntry();
        priceEntry.Pricebook2Id=priceBook.Id;
        priceEntry.Product2Id=p.id;
        priceEntry.UnitPrice = 10000;
        priceEntry.IsActive = true;
        insert priceEntry;

        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType ='Opportunity' AND Name = 'Event'];

        Opportunity opp=new Opportunity();
        opp.AccountId=acc.Id;
          opp.Name='Test Oppo';
        opp.StageName='Qualified';
        opp.CloseDate=date.today();
        opp.RecordTypeId = rt.Id;
        opp.Pricebook2Id=priceBook.Id;
        

        //opp.Project__c = pj.id;

        insert opp;

        OpportunityLineItem oli= new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.PricebookEntryId=priceEntry.Id;
        oli.Product2Id=p.id;
        oli.Projects__c = pd.Project__c;
        oli.Project__c = pd.Project__r.Name;
        oli.Product_Details__c = pd.Id;
        oli.Start_Date__c = Date.today().addmonths(1).tostartofmonth();
        oli.Quantity = 1;
        oli.UnitPrice = pd.Price__c;
        oli.Representative_Voting_Contact__c = acc.PersonContactId;
        oli.Authorized_Signatory__c = acc.PersonContactId;
        oli.Billing_Contact__c = acc.PersonContactId;
        insert oli;


        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opp.Id;
        ocr.ContactId = con.Id;
        ocr.Role = 'Membership Decision Maker';
        insert  ocr;


    }

    @isTest static void testProcessForm() {

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];

        RestRequest request = new RestRequest();
        request.requestUri = '/JoinNowIndividualForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"pm_primary_con_street" : "pm_primary_con_street", "pm_primary_con_city" : "pm_primary_con_city", "pm_primary_con_state" : "pm_primary_con_state", "pm_primary_con_country" : "pm_primary_con_country", "pm_primary_con_postalCode" : "1111", "pm_project" : "' + pj.Id + '", "pm_product_detail" : "' + pd.Id + '", "pm_fees" : 100, "pm_primary_con_id" : "' + con.Id + '", "pm_primary_con_fname" : "pm_primary_con_fname", "pm_primary_con_lname" : "pm_primary_con_lname", "pm_primary_con_title" : "pm_primary_con_title", "pm_primary_con_emailParam" : "test@joinNowIndividual.com", "pm_primary_con_phone" : "pm_primary_con_phone", "pm_primary_con_twitter" : "pm_primary_con_twitter", "pm_primary_con_github" : "pm_primary_con_github", "pm_primary_con_linkedIn" : "pm_primary_con_linkedIn", "category" : "category"}');
        RestContext.request = request;
        RestResponse response = RestContext.response;

        Test.startTest();
        String result = JoinNowIndividualFormSubmission.processForm();
        Test.stopTest();

        //  String result = JoinNowFormSubmission.processForm();
        system.debug(' result : ' + result);
        System.assert(result != null);

    }

    @isTest static void testProcessForm2(){

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];

        RestRequest request = new RestRequest();
        request.requestUri = '/JoinNowIndividualForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"pm_primary_con_street" : "pm_primary_con_street", "pm_primary_con_city" : "pm_primary_con_city", "pm_primary_con_state" : "pm_primary_con_state", "pm_primary_con_country" : "pm_primary_con_country", "pm_primary_con_postalCode" : "1111", "pm_project" : "' + pj.Id + '", "pm_product_detail" : "' + pd.Id + '", "pm_fees" : 100, "pm_primary_con_id" : "", "pm_primary_con_fname" : "pm_primary_con_fname", "pm_primary_con_lname" : "pm_primary_con_lname", "pm_primary_con_title" : "pm_primary_con_title", "pm_primary_con_emailParam" : "test@joinNowIndividual.com", "pm_primary_con_phone" : "pm_primary_con_phone", "pm_primary_con_twitter" : "pm_primary_con_twitter", "pm_primary_con_github" : "pm_primary_con_github", "pm_primary_con_linkedIn" : "pm_primary_con_linkedIn", "category" : "category"}');
        RestContext.request = request;
        RestResponse response = RestContext.response;

        Test.startTest();
        String result = JoinNowIndividualFormSubmission.processForm();
        Test.stopTest();

        //  String result = JoinNowFormSubmission.processForm();
        system.debug(' result : ' + result);
        System.assert(result != null);

    }

    @isTest static void testProcessForm3() {

        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];

        RestRequest request = new RestRequest();
        request.requestUri = '/JoinNowIndividualForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"pm_primary_con_street" : "pm_primary_con_street", "pm_primary_con_city" : "pm_primary_con_city", "pm_primary_con_state" : "pm_primary_con_state", "pm_primary_con_country" : "pm_primary_con_country", "pm_primary_con_postalCode" : "1111", "pm_project" : "' + pj.Id + '", "pm_product_detail" : "' + pd.Id + '", "pm_fees" : 100, "pm_primary_con_id" : "", "pm_primary_con_fname" : "pm_primary_con_fname", "pm_primary_con_lname" : "pm_primary_con_lname", "pm_primary_con_title" : "pm_primary_con_title", "pm_primary_con_emailParam" : "test@leadRecord.com", "pm_primary_con_phone" : "pm_primary_con_phone", "pm_primary_con_twitter" : "pm_primary_con_twitter", "pm_primary_con_github" : "pm_primary_con_github", "pm_primary_con_linkedIn" : "pm_primary_con_linkedIn", "category" : "category"}');
        RestContext.request = request;
        RestResponse response = RestContext.response;

        Test.startTest();
        String result = JoinNowIndividualFormSubmission.processForm();
        Test.stopTest();

        //  String result = JoinNowFormSubmission.processForm();
        system.debug(' result : ' + result);
        System.assert(result != null);

    }


    @isTest static void testProcessForm4() {

        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        List<Contact> conList = [Select Id, email from Contact limit 2];
        RestRequest request = new RestRequest();
        request.requestUri = '/JoinNowIndividualForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"pm_primary_con_street" : "pm_primary_con_street", "pm_primary_con_city" : "pm_primary_con_city", "pm_primary_con_state" : "pm_primary_con_state", "pm_primary_con_country" : "pm_primary_con_country", "pm_primary_con_postalCode" : "1111", "pm_project" : "' + pj.Id + '", "pm_product_detail" : "' + pd.Id + '", "pm_fees" : 100, "pm_primary_con_id" : "'+conList[1].ID+'", "pm_primary_con_fname" : "pm_primary_con_fname", "pm_primary_con_lname" : "pm_primary_con_lname", "pm_primary_con_title" : "pm_primary_con_title", "pm_primary_con_emailParam" : "'+conList[0].Email+'", "pm_primary_con_phone" : "pm_primary_con_phone", "pm_primary_con_twitter" : "pm_primary_con_twitter", "pm_primary_con_github" : "pm_primary_con_github", "pm_primary_con_linkedIn" : "pm_primary_con_linkedIn", "category" : "category"}');
        RestContext.request = request;
        RestResponse response = RestContext.response;

        Test.startTest();
        String result = JoinNowIndividualFormSubmission.processForm();
        Test.stopTest();

        //  String result = JoinNowFormSubmission.processForm();
        system.debug(' result : ' + result);
        System.assert(result != null);

    }


    
    @isTest static void testProcessForm5() {

        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        List<Contact> conList = [Select Id, email from Contact where email = 'test3@Con.com'];
        RestRequest request = new RestRequest();
        request.requestUri = '/JoinNowIndividualForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"pm_primary_con_street" : "pm_primary_con_street", "pm_primary_con_city" : "pm_primary_con_city", "pm_primary_con_state" : "pm_primary_con_state", "pm_primary_con_country" : "pm_primary_con_country", "pm_primary_con_postalCode" : "1111", "pm_project" : "' + pj.Id + '", "pm_product_detail" : "' + pd.Id + '", "pm_fees" : 100, "pm_primary_con_id" : "'+conList[0].ID+'", "pm_primary_con_fname" : "pm_primary_con_fname", "pm_primary_con_lname" : "pm_primary_con_lname", "pm_primary_con_title" : "pm_primary_con_title", "pm_primary_con_emailParam" : "test1@Con.com", "pm_primary_con_phone" : "pm_primary_con_phone", "pm_primary_con_twitter" : "pm_primary_con_twitter", "pm_primary_con_github" : "pm_primary_con_github", "pm_primary_con_linkedIn" : "pm_primary_con_linkedIn", "category" : "category"}');
        RestContext.request = request;
        RestResponse response = RestContext.response;

        Test.startTest();
        String result = JoinNowIndividualFormSubmission.processForm();
        Test.stopTest();

        //  String result = JoinNowFormSubmission.processForm();
        system.debug(' result : ' + result);
        System.assert(result != null);

    }
    
    
    @isTest static void testProcessForm6() {

        

        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        List<Contact> conList = [Select Id, email from Contact where email = 'test3@Con.com'];

        RestRequest request = new RestRequest();
        request.requestUri = '/JoinNowIndividualForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"pm_primary_con_street" : "pm_primary_con_street", "pm_primary_con_city" : "pm_primary_con_city", "pm_primary_con_state" : "pm_primary_con_state", "pm_primary_con_country" : "pm_primary_con_country", "pm_primary_con_postalCode" : "1111", "pm_project" : "' + pj.Id + '", "pm_product_detail" : "' + pd.Id + '", "pm_fees" : 100, "pm_primary_con_id" : "'+conList[0].ID+'", "pm_primary_con_fname" : "pm_primary_con_fname", "pm_primary_con_lname" : "pm_primary_con_lname", "pm_primary_con_title" : "pm_primary_con_title", "pm_primary_con_emailParam" : "test2@user.com", "pm_primary_con_phone" : "pm_primary_con_phone", "pm_primary_con_twitter" : "pm_primary_con_twitter", "pm_primary_con_github" : "pm_primary_con_github", "pm_primary_con_linkedIn" : "pm_primary_con_linkedIn", "category" : "category"}');
        RestContext.request = request;
        RestResponse response = RestContext.response;

        Test.startTest();
        String result = JoinNowIndividualFormSubmission.processForm();
        Test.stopTest();

        //  String result = JoinNowFormSubmission.processForm();
        system.debug(' result : ' + result);
        System.assert(result != null);

    }


    @isTest static void testupsertOpportunity(){


        Account acc = [SELECT Id, Name, PersonContactId,FirstName,LastName,PersonTitle,PersonEmail,Phone,Twitter_ID__pc,GitHub_ID__pc,LinkedIn_ID__pc,RecordTypeId, IsPersonAccount FROM Account LIMIT 1];

        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        List<Contact> conList = [Select Id, email from Contact where email = 'test3@Con.com'];

        Pricebook2 priceBook=new Pricebook2();
        priceBook.Name='Standard';
        priceBook.IsActive=True;
        insert priceBook;
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Tax_Class__c = 'T1';
        p.IsActive = true;
        p.Family = 'Membership';
        insert p;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        PriceBookEntry priceEntry=new PriceBookEntry();
        priceEntry.Pricebook2Id=priceBook.Id;
        priceEntry.Product2Id=p.id;
        priceEntry.UnitPrice = 10000;
        priceEntry.IsActive = true;
        insert priceEntry;

        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType ='Opportunity' AND Name = 'Event'];

        Opportunity opp=new Opportunity();
        opp.AccountId=acc.Id;
        opp.Name='Test Oppo';
        opp.StageName='Qualified';
        opp.CloseDate=date.today();
        opp.RecordTypeId = rt.Id;
        opp.Pricebook2Id=priceBook.Id;
        opp.Billing_Contact__c = conList[0].Id;

        insert opp;
        
        /*RestRequest request = new RestRequest();
        request.requestUri = '/JoinNowIndividualForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"pm_primary_con_street" : "pm_primary_con_street", "pm_primary_con_city" : "pm_primary_con_city", "pm_primary_con_state" : "pm_primary_con_state", "pm_primary_con_country" : "pm_primary_con_country", "pm_primary_con_postalCode" : "1111", "pm_project" : "' + pj.Id + '", "pm_product_detail" : "' + pd.Id + '", "pm_fees" : 100, "pm_primary_con_id" : "'+conList[0].ID+'", "pm_primary_con_fname" : "pm_primary_con_fname", "pm_primary_con_lname" : "pm_primary_con_lname", "pm_primary_con_title" : "pm_primary_con_title", "pm_primary_con_emailParam" : "test2@user.com", "pm_primary_con_phone" : "pm_primary_con_phone", "pm_primary_con_twitter" : "pm_primary_con_twitter", "pm_primary_con_github" : "pm_primary_con_github", "pm_primary_con_linkedIn" : "pm_primary_con_linkedIn", "category" : "category"}');
        
        //request.requestBody = Blob.valueOf('{"pm_primary_con_street" : "pm_primary_con_street", "pm_primary_con_city" : "pm_primary_con_city", "pm_primary_con_state" : "pm_primary_con_state", "pm_primary_con_country" : "pm_primary_con_country", "pm_primary_con_postalCode" : "1111", "pm_project" : "' + pj.Id + '", "pm_product_detail" : "' + pd.Id + '", "pm_fees" : 100, "pm_primary_con_id" : "'+conList[0].ID+'", "pm_primary_con_fname" : "pm_primary_con_fname", "pm_primary_con_lname" : "pm_primary_con_lname", "pm_primary_con_title" : "pm_primary_con_title", "pm_primary_con_emailParam" : "test2@user.com", "pm_primary_con_phone" : "pm_primary_con_phone", "pm_primary_con_twitter" : "pm_primary_con_twitter", "pm_primary_con_github" : "pm_primary_con_github", "pm_primary_con_linkedIn" : "pm_primary_con_linkedIn", "category" : "category"}');
        RestContext.request = request;
        RestResponse response = RestContext.response;
        Blob requestBodyBlob = request.requestBody;
        String requestBody = requestBodyBlob.toString();
        //JoinNowIndividualRequestWrapper fd = (JoinNowIndividualRequestWrapper) JSON.deserialize(requestBody, JoinNowIndividualRequestWrapper.class);
        //fd.pm_product_detail = pd.Id;
        
        Test.startTest();
        String result = JoinNowFormSubmission.processForm();
        //JoinNowIndividualFormSubmission.upsertOpportunity(fd, acc, true);
        
        Test.stopTest();*/

    }


    
    @isTest static void testProcessForm8() {
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        List<Contact> conList = [Select Id, email from Contact where email = 'test4@Con.com' limit 1];

        RestRequest request = new RestRequest();
        request.requestUri = '/JoinNowIndividualForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"pm_primary_con_street" : "pm_primary_con_street", "pm_primary_con_city" : "pm_primary_con_city", "pm_primary_con_state" : "pm_primary_con_state", "pm_primary_con_country" : "pm_primary_con_country", "pm_primary_con_postalCode" : "1111", "pm_project" : "' + pj.Id + '", "pm_product_detail" : "' + pd.Id + '", "pm_fees" : 100, "pm_primary_con_id" : "", "pm_primary_con_fname" : "pm_primary_con_fname", "pm_primary_con_lname" : "pm_primary_con_lname", "pm_primary_con_title" : "pm_primary_con_title", "pm_primary_con_emailParam" : "'+conList[0].Email+'", "pm_primary_con_phone" : "pm_primary_con_phone", "pm_primary_con_twitter" : "pm_primary_con_twitter", "pm_primary_con_github" : "pm_primary_con_github", "pm_primary_con_linkedIn" : "pm_primary_con_linkedIn", "category" : "category"}');
        RestContext.request = request;
        RestResponse response = RestContext.response;

        Test.startTest();
        String result = JoinNowIndividualFormSubmission.processForm();
        Test.stopTest();

        //  String result = JoinNowFormSubmission.processForm();
        system.debug(' result : ' + result);
        System.assert(result != null);
    }

    
    @isTest static void testProcessForm9() {
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        List<Lead> leadList = [Select Id, email from Lead limit 1];

        RestRequest request = new RestRequest();
        request.requestUri = '/JoinNowIndividualForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"pm_primary_con_street" : "pm_primary_con_street", "pm_primary_con_city" : "pm_primary_con_city", "pm_primary_con_state" : "pm_primary_con_state", "pm_primary_con_country" : "pm_primary_con_country", "pm_primary_con_postalCode" : "1111", "pm_project" : "' + pj.Id + '", "pm_product_detail" : "' + pd.Id + '", "pm_fees" : 100, "pm_primary_con_id" : "", "pm_primary_con_fname" : "pm_primary_con_fname", "pm_primary_con_lname" : "pm_primary_con_lname", "pm_primary_con_title" : "pm_primary_con_title", "pm_primary_con_emailParam" : "'+leadList[0].Email+'", "pm_primary_con_phone" : "pm_primary_con_phone", "pm_primary_con_twitter" : "pm_primary_con_twitter", "pm_primary_con_github" : "pm_primary_con_github", "pm_primary_con_linkedIn" : "pm_primary_con_linkedIn", "category" : "category"}');
        RestContext.request = request;
        RestResponse response = RestContext.response;

        Test.startTest();
        String result = JoinNowIndividualFormSubmission.processForm();
        Test.stopTest();

        //  String result = JoinNowFormSubmission.processForm();
        system.debug(' result : ' + result);
        System.assert(result != null);
    }


    
    @isTest static void testProcessForm10() {
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        List<Lead> leadList = [Select Id, email from Lead where email  = 'test2@leadRecord.com' limit 1];

        RestRequest request = new RestRequest();
        request.requestUri = '/JoinNowIndividualForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"pm_primary_con_street" : "pm_primary_con_street", "pm_primary_con_city" : "pm_primary_con_city", "pm_primary_con_state" : "pm_primary_con_state", "pm_primary_con_country" : "pm_primary_con_country", "pm_primary_con_postalCode" : "1111", "pm_project" : "' + pj.Id + '", "pm_product_detail" : "' + pd.Id + '", "pm_fees" : 100, "pm_primary_con_id" : "", "pm_primary_con_fname" : "pm_primary_con_fname", "pm_primary_con_lname" : "pm_primary_con_lname", "pm_primary_con_title" : "pm_primary_con_title", "pm_primary_con_emailParam" : "'+leadList[0].Email+'", "pm_primary_con_phone" : "pm_primary_con_phone", "pm_primary_con_twitter" : "pm_primary_con_twitter", "pm_primary_con_github" : "pm_primary_con_github", "pm_primary_con_linkedIn" : "pm_primary_con_linkedIn", "category" : "category"}');
        RestContext.request = request;
        RestResponse response = RestContext.response;

        Test.startTest();
        String result = JoinNowIndividualFormSubmission.processForm();
        Test.stopTest();

        //  String result = JoinNowFormSubmission.processForm();
        system.debug(' result : ' + result);
        System.assert(result != null);
    }

}