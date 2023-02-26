@isTest
public class JoinNowFormSubmissionTest {
    
    @TestSetup static void generateTestData() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Website = 'joinnowform.com';
        insert acc;
        
        lead l = new lead();
        l.lastName = 'Test l LastName';
        l.company = 'Test l Company';
        l.Email = 'test@test.com';
        l.status = 'working';
        insert l;
        
        lead secLead = new lead();
        secLead.lastName = ' secLead LN';
        secLead.company = ' secLead Cmp';
        secLead.Email = 'secLead@secLead.com';
        secLead.status = 'Unqualified';
        insert secLead;
        
        Contact con = new Contact();
        con.firstName = 'Test First name';
        con.lastName = 'Test last Name';
        con.accountId = acc.Id;
        insert con;
        
        Contact con1 = new Contact();
        con1.firstName = 'Test First name';
        con1.lastName = 'Test last Name';
        con1.accountId = acc.Id;
        con1.Email='contact1@joinnow.com';
        insert con1;
        
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
        pd.Description__c = 'Test';
        insert pd;
        
        Product_Details__c pd1 = new Product_Details__c();
        pd1.Products__c = p.Id;
        pd1.Description__c = 'Test';
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
        altl.Alternate_Email_Address__c = 'Test30@test.com';
        altl.Lead_Name__c = l.id;
        altl.Active__c = true;
        altEmails.add(altl);
        
        Alternate_Email__c altl2 = new Alternate_Email__c();
        altl2.Alternate_Email_Address__c = 'Test121@test.com';
        altl2.Lead_Name__c = secLead.id;
        altl2.Active__c = true;
        altEmails.add(altl2);
        
        insert altEmails;
        
        Address__c adressRec = new Address__c();
        adressRec.Account__c = acc.ID; 
        adressRec.Name = 'Test';
        adressRec.Street__c = 'Test';
        adressRec.City__c = 'Mumbai';
        adressRec.State__c = 'Maharshtra';
        adressRec.Country__c = 'India';
        adressRec.Zip_Postal_Code__c = '567896';
        insert adressRec;
        
    }
    
    @isTest static void testProcessform1() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        
        PricebookEntry pbe = new PricebookEntry(product2id = p.Id, unitprice = 1000, pricebook2id = Test.getStandardPricebookId(), isActive = true, UseStandardPrice = false);
        insert pbe;
        Opportunity opp = new Opportunity(Name='Membership Opportunity',AccountId = acc.Id, Type='New Business',StageName='5. Decision Commitment',CloseDate = Date.today());
        insert opp;
        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId=opp.Id,Product2Id=p.Id,Projects__c=pj.Id,Product_Details__c=pd.Id,PricebookEntryId = pbe.Id,Quantity=1,UnitPrice=1000 );
        insert lineItem;
        
        RestRequest request = new RestRequest();
        request.requestUri = '/JoinNowForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{ "company": "Test Company","sign_msa":true, "website": "https://www.joinnowform.com/submit","pm_product": "' + pd.id + '","display_logo": true, "press_release_announcement": true, "preferred_invoice_method": "email", "category": "","address": "Test address", "city": "Test city", "state": "Test state", "zip": "Test zip", "employeeSize": "Test employeeSize", "po_con_name": "New PO Contact Person", "po_con_emailParam": "pocintact@joinnow.com", "pm_primary_con_emailParam": "Test@test.com", "pm_primary_con_fname": "Test First Name", "pm_primary_con_lname": "Test Last Name", "pm_primary_con_title": "Test title", "pm_primary_con_phone": "987654321", "pm_primary_con_twitter": "TestNameTwitter", "pm_primary_con_github": "TestNameGithub","pm_primary_con_linkedIn": "TestNameLinkedin", "pm_billing_con_emailParam": "Test@test.com", "pm_billing_con_fname": "Test First Name", "pm_billing_con_lname": "Test Last Name", "pm_billing_con_title": "Test title", "pm_billing_con_phone": "987654321", "pm_authSig_emailParam": "Test@test.com", "pm_authSig_fname": "Test First Name", "pm_authSig_lname": "Test Last Name", "pm_authSig_title": "Test title", "pm_authSig_con_phone": "987654321", "pm_inv_con_emailParam": "Test@test.com", "pm_inv_con_fname": "Test First Name", "pm_inv_con_lname": "Test Last Name", "pm_inv_con_title": "Test title", "pm_inv_con_phone": "987654321", "pm_tech_con_1_emailParam": "Test@test.com", "pm_tech_con_1_fname": "Test First Name", "pm_tech_con_1_lname": "Test Last Name", "pm_tech_con_1_title": "Test title", "pm_tech_con_phone": "987654321", "pm_tech_con_2_emailParam": "Test@test.com", "pm_tech_con_2_fname": "Test First Name", "pm_tech_con_2_lname": "Test Last Name", "pm_tech_con_2_title": "Test title", "pm_tech_con_2_phone": "987654321", "pm_tech_con_3_emailParam": "Test@test.com", "pm_tech_con_3_fname": "Test First Name", "pm_tech_con_3_lname": "Test Last Name", "pm_tech_con_3_title": "Test title", "pm_tech_con_3_phone": "987654321", "pm_mkt_con_1_emailParam": "Test@test.com", "pm_mkt_con_1_fname": "Test First Name", "pm_mkt_con_1_lname": "Test Last Name", "pm_mkt_con_1_title": "Test title", "pm_mkt_con_1_phone": "987654321", "pm_mkt_con_2_emailParam": "Test@test.com", "pm_mkt_con_2_fname": "Test First Name", "pm_mkt_con_2_lname": "Test Last Name", "pm_mkt_con_2_title": "Test title", "pm_mkt_con_2_phone": "987654321", "pm_pr_con_emailParam": "Test@test.com", "pm_pr_con_fname": "Test First Name", "pm_pr_con_lname": "Test Last Name", "pm_pr_con_title": "Test title", "pm_pr_con_phone": "987654321", "pm_legal_con_emailParam": "Test@test.com", "pm_legal_con_fname": "Test First Name", "pm_legal_con_lname": "Test Last Name", "pm_legal_con_title": "Test title", "pm_legal_con_phone": "987654321", "lm_primary_con_emailParam": "Test@test.com", "lm_primary_con_fname": "Test First Name", "lm_primary_con_lname": "Test Last Name", "lm_primary_con_title": "Test title", "lm_primary_con_phone": "987654321", "lm_billing_con_emailParam": "Test@test.com", "lm_billing_con_fname": "Test First Name", "lm_billing_con_lname": "Test Last Name", "lm_billing_con_title": "Test title", "lm_billing_con_phone": "987654321", "lm_authSig_emailParam": "Test@test.com", "lm_authSig_fname": "Test First Name", "lm_authSig_lname": "Test Last Name", "lm_authSig_title": "Test title", "lm_authSig_phone": "987654321", "lm_inv_con_emailParam": "Test@test.com", "lm_inv_con_fname": "Test First Name", "lm_inv_con_lname": "Test Last Name", "lm_inv_con_title": "Test title", "lm_inv_con_phone": "987654321", "lm_tech_con_1_emailParam": "Test@test.com", "lm_tech_con_1_fname": "Test First Name", "lm_tech_con_1_lname": "Test Last Name", "lm_tech_con_title": "Test title", "lm_tech_con_phone": "987654321", "lm_tech_con_2_emailParam": "Test@test.com", "lm_tech_con_2_fname": "Test First Name", "lm_tech_con_2_lname": "Test Last Name", "lm_tech_con_2_title": "Test title", "lm_tech_con_2_phone": "987654321", "lm_tech_con_3_emailParam": "Test@test.com", "lm_tech_con_3_fname": "Test First Name", "lm_tech_con_3_lname": "Test Last Name", "lm_tech_con_3_title": "Test title", "lm_tech_con_3_phone": "987654321", "lm_mkt_con_1_emailParam": "Test@test.com", "lm_mkt_con_1_fname": "Test First Name", "lm_mkt_con_1_lname": "Test Last Name", "lm_mkt_con_1_title": "Test title", "lm_mkt_con_1_phone": "987654321", "lm_mkt_con_2_emailParam": "Test@test.com", "lm_mkt_con_2_fname": "Test First Name", "lm_mkt_con_2_lname": "Test Last Name", "lm_mkt_con_2_title": "Test title", "lm_mkt_con_2_phone": "987654321", "lm_pr_con_emailParam": "Test@test.com", "lm_pr_con_fname": "Test First Name", "lm_pr_con_lname": "Test Last Name", "lm_pr_con_title": "Test title", "lm_pr_con_phone": "987654321", "lm_legal_con_emailParam": "Test@test.com", "lm_legal_con_fname": "Test First Name", "lm_legal_con_lname": "Test Last Name", "lm_legal_con_title": "Test title", "pm_project": "' + pj.id + '", "lm_legal_con_phone": "987654321" ,  "pm_primary_con_id": "", "pm_billing_con_id": "", "pm_authSig_id": "", "pm_inv_con_id": "", "pm_tech_con_1_id": "", "pm_tech_con_2_id": "", "pm_tech_con_3_id": "", "pm_mkt_con_1_id": "", "pm_mkt_con_2_id": "", "pm_pr_con_id": "", "pm_legal_con_id": "", "lm_primary_con_id": "", "lm_billing_con_id": "", "lm_authSig_id": "", "lm_inv_con_id": "", "lm_tech_con_1_id": "", "lm_tech_con_2_id": "", "lm_tech_con_3_id": "", "lm_mkt_con_1_id": "", "lm_mkt_con_2_id": "", "lm_pr_con_id": "", "lm_legal_con_id": "", "pm_primary_con_subscribed": false, "pm_billing_con_subscribed": false, "pm_authSig_subscribed": false, "pm_inv_con_subscribed": false, "pm_tech_con_1_subscribed": false, "pm_tech_con_2_subscribed": false, "pm_tech_con_3_subscribed": false, "pm_mkt_con_1_subscribed": false, "pm_mkt_con_2_subscribed": false, "pm_pr_con_subscribed": false, "pm_legal_con_subscribed": false, "lm_primary_con_subscribed": false, "lm_billing_con_subscribed": false, "lm_authSig_subscribed": false, "lm_inv_con_subscribed": false, "lm_tech_con_1_subscribed": false, "lm_tech_con_2_subscribed": false, "lm_tech_con_3_subscribed": false, "lm_mkt_con_1_subscribed": false, "lm_mkt_con_2_subscribed": false, "lm_pr_con_subscribed": false, "lm_legal_con_subscribed": false, "billto_account_name": "TestCompanyForJoinNow", "billto_city": "Mumbai", "billto_country": "India", "billto_zip": "400709", "billto_state": "Maharashtra","billto_street": "MG Road"}');
        RestContext.request = request;
        RestResponse response = RestContext.response;
        Test.startTest();
        String result = JoinNowFormSubmission.processForm();
        Test.stopTest();
        system.debug(' result : ' + result);
        System.assert(result != null);
    }
    
    @isTest static void testProcessform2() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Alternate_Email__c ae = [Select Id From Alternate_Email__c Where Contact_Name__c=: con.Id Limit 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        
        Address__c address = new Address__c(Account__c= acc.Id, Name= 'Test Address', Street__c= 'Test', City__c= 'Test', State__c= 'Test', Country__c= 'Test', Zip_Postal_Code__c= 'Test');
        insert address;
        
        PricebookEntry pbe = new PricebookEntry(product2id = p.Id, unitprice = 1000, pricebook2id = Test.getStandardPricebookId() ,CurrencyIsoCode='USD',isActive = true, UseStandardPrice = false);
        insert pbe;
        Opportunity opp = new Opportunity(Name='Membership Opportunity',AccountId = acc.Id, Type='New Business',StageName='5. Decision Commitment',CloseDate = Date.today());
        insert opp;
        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId=opp.Id,Product2Id=p.Id,Projects__c=pj.Id,Product_Details__c=pd.Id,PricebookEntryId = pbe.Id,Quantity=1,UnitPrice=1000 );
        insert lineItem;
        
        List<Project_Role__c> lstProjectRoles = new List<Project_Role__c>();
        Project_Role__c projectRole = new Project_Role__c (Contact__c = con.Id, Status__c='Active', Alternate_Email__c= ae.Id, Role__c='Billing Contact', Opportunity__c= opp.Id, Opportunity_Line_Item__c = lineItem.Id, PrimaryContact__c = true);
        lstProjectRoles.add(projectRole);
        Project_Role__c projectRole1 = new Project_Role__c (Contact__c = con.Id, Status__c='Active', Alternate_Email__c= ae.Id, Role__c='Representative/Voting Contact', Opportunity__c= opp.Id, Opportunity_Line_Item__c = lineItem.Id, PrimaryContact__c = true);
        lstProjectRoles.add(projectRole1);
        Project_Role__c projectRole2 = new Project_Role__c (Contact__c = con.Id, Status__c='Active', Alternate_Email__c= ae.Id, Role__c='Authorized Signatory', Opportunity__c= opp.Id, Opportunity_Line_Item__c = lineItem.Id, PrimaryContact__c = true);
        lstProjectRoles.add(projectRole2);
        Project_Role__c projectRole3 = new Project_Role__c (Contact__c = con.Id, Status__c='Active', Alternate_Email__c= ae.Id, Role__c='Technical Contact', Opportunity__c= opp.Id, Opportunity_Line_Item__c = lineItem.Id, PrimaryContact__c = true);
        lstProjectRoles.add(projectRole3);
        Insert lstProjectRoles;
        
        RestRequest request1 = new RestRequest();
        request1.requestUri = '/JoinNowForm/';
        request1.httpMethod = 'POST';
        request1.addHeader('Content-Type', 'application/json');
        request1.requestBody = Blob.valueOf('{ "accountId": "' + acc.id + '", "sign_msa":true,"billto_account_id": "' + address.id + '", "preferred_invoice_method": "email", "logo_url":"https://lf-master-organization-logos-prod.s3.us-east-2.amazonaws.com/account.svg", "country":"India", "website":"joinnowtest.com", "category": "", "pm_product": "' + pd.id + '", "pm_project": "' + pj.id + '", "lm_product": "' + pd.id + '", "pm_primary_con_id": "", "pm_billing_con_id": "' + con.id + '", "pm_authSig_id": "' + con.id + '", "pm_pr_con_id": "' + con.id + '", "pm_legal_con_id": "' + con.id + '", "pm_inv_con_id": "' + con.id + '", "pm_tech_con_1_id": "' + con.id + '", "pm_tech_con_2_id": "' + con.id + '", "pm_tech_con_3_id": "' + con.id + '", "pm_mkt_con_1_id": "' + con.id + '", "pm_mkt_con_2_id": "' + con.id + '", "lm_primary_con_id": "' + con.id + '", "lm_billing_con_id": "' + con.id + '", "lm_authSig_id": "' + con.id + '", "lm_pr_con_id": "' + con.id + '", "lm_legal_con_id": "' + con.id + '", "lm_inv_con_id": "' + con.id + '", "lm_tech_con_1_id": "' + con.id + '", "lm_tech_con_2_id": "' + con.id + '", "lm_tech_con_3_id": "' + con.id + '", "lm_mkt_con_1_id": "' + con.id + '", "lm_mkt_con_2_id": "' + con.id + '", "company": "Test Company", "address": "Test address", "city": "Test city", "state": "Test state", "zip": "Test zip", "employeeSize": "Test employeeSize", "display_logo": true, "press_release_announcement": true, "pm_primary_con_invoice_copy": false, "po_con_name": "Test Name 1", "po_con_emailParam": "Test1@test.com", "pm_primary_con_emailParam": "Test@test.com", "pm_primary_con_fname": "Test First Name", "pm_primary_con_lname": "Test Last Name", "pm_primary_con_title": "Test title", "pm_primary_con_phone": "987654321", "pm_billing_con_emailParam": "test@test.com", "pm_billing_con_fname": "Test First Name", "pm_billing_con_lname": "Test Last Name", "pm_billing_con_title": "Test title", "pm_billing_con_phone": "987654321", "pm_authSig_emailParam": "Test2@test.com", "pm_authSig_fname": "Test First Name", "pm_authSig_lname": "Test Last Name", "pm_authSig_title": "Test title", "pm_authSig_con_phone": "987654321", "pm_inv_con_emailParam": "Test3@test.com", "pm_inv_con_fname": "Test First Name", "pm_inv_con_lname": "Test Last Name", "pm_inv_con_title": "Test title", "pm_inv_con_phone": "987654321", "pm_tech_con_1_emailParam": "Test4@test.com", "pm_tech_con_1_fname": "Test First Name", "pm_tech_con_1_lname": "Test Last Name", "pm_tech_con_1_title": "Test title", "pm_tech_con_1_phone": "987654321", "pm_tech_con_2_emailParam": "contact1@joinnow.com", "pm_tech_con_2_fname": "Test First Name", "pm_tech_con_2_lname": "Test Last Name", "pm_tech_con_2_title": "Test title", "pm_tech_con_2_phone": "9876543", "pm_tech_con_2_twitter": "TestNameTwitter", "pm_tech_con_2_github": "TestNameGithub","pm_tech_con_2_linkedIn": "TestNameLinkedin", "pm_tech_con_3_emailParam": "Test6@test.com", "pm_tech_con_3_fname": "Test First Name", "pm_tech_con_3_lname": "Test Last Name", "pm_tech_con_3_title": "Test title", "pm_tech_con_3_phone": "987654321", "pm_mkt_con_1_emailParam": "Test7@test.com", "pm_mkt_con_1_fname": "Test First Name", "pm_mkt_con_1_lname": "Test Last Name", "pm_mkt_con_1_title": "Test title", "pm_mkt_con_1_phone": "987654321", "pm_mkt_con_2_emailParam": "Test8@test.com", "pm_mkt_con_2_fname": "Test First Name", "pm_mkt_con_2_lname": "Test Last Name", "pm_mkt_con_2_title": "Test title", "pm_mkt_con_2_phone": "987654321", "pm_pr_con_emailParam": "Test9@test.com", "pm_pr_con_fname": "Test First Name", "pm_pr_con_lname": "Test Last Name", "pm_pr_con_title": "Test title", "pm_pr_con_phone": "987654321", "pm_legal_con_emailParam": "Test10@test.com", "pm_legal_con_fname": "Test First Name", "pm_legal_con_lname": "Test Last Name", "pm_legal_con_title": "Test title", "pm_legal_con_phone": "987654321", "lm_primary_con_emailParam": "Test11@test.com", "lm_primary_con_fname": "Test First Name", "lm_primary_con_lname": "Test Last Name", "lm_primary_con_title": "Test title", "lm_primary_con_phone": "987654321", "lm_billing_con_emailParam": "Test12@test.com", "lm_billing_con_fname": "Test First Name", "lm_billing_con_lname": "Test Last Name", "lm_billing_con_title": "Test title", "lm_billing_con_phone": "987654321", "lm_authSig_emailParam": "Test13@test.com", "lm_authSig_fname": "Test First Name", "lm_authSig_lname": "Test Last Name", "lm_authSig_title": "Test title", "lm_authSig_phone": "987654321", "lm_inv_con_emailParam": "Test14@test.com", "lm_inv_con_fname": "Test First Name", "lm_inv_con_lname": "Test Last Name", "lm_inv_con_title": "Test title", "lm_inv_con_phone": "987654321", "lm_tech_con_1_emailParam": "Test15@test.com", "lm_tech_con_1_fname": "Test First Name", "lm_tech_con_1_lname": "Test Last Name", "lm_tech_con_title": "Test title", "lm_tech_con_phone": "987654321", "lm_tech_con_2_emailParam": "Test16@test.com", "lm_tech_con_2_fname": "Test First Name", "lm_tech_con_2_lname": "Test Last Name", "lm_tech_con_2_title": "Test title", "lm_tech_con_2_phone": "987654321", "lm_tech_con_3_emailParam": "Test17@test.com", "lm_tech_con_3_fname": "Test First Name", "lm_tech_con_3_lname": "Test Last Name", "lm_tech_con_3_title": "Test title", "lm_tech_con_3_phone": "987654321", "lm_mkt_con_1_emailParam": "Test18@test.com", "lm_mkt_con_1_fname": "Test First Name", "lm_mkt_con_1_lname": "Test Last Name", "lm_mkt_con_1_title": "Test title", "lm_mkt_con_1_phone": "987654321", "lm_mkt_con_2_emailParam": "Test19@test.com", "lm_mkt_con_2_fname": "Test First Name", "lm_mkt_con_2_lname": "Test Last Name", "lm_mkt_con_2_title": "Test title", "lm_mkt_con_2_phone": "987654321", "lm_pr_con_emailParam": "Test20@test.com", "lm_pr_con_fname": "Test First Name", "lm_pr_con_lname": "Test Last Name", "lm_pr_con_title": "Test title", "lm_pr_con_phone": "987654321", "lm_legal_con_emailParam": "Test21@test.com", "lm_legal_con_fname": "Test First Name", "lm_legal_con_lname": "Test Last Name", "lm_legal_con_title": "Test title", "lm_legal_con_phone": "987654321", "pm_primary_con_subscribed": false, "pm_billing_con_subscribed": false, "pm_authSig_subscribed": false, "pm_inv_con_subscribed": false, "pm_tech_con_1_subscribed": false, "pm_tech_con_2_subscribed": false, "pm_tech_con_3_subscribed": false, "pm_mkt_con_1_subscribed": false, "pm_mkt_con_2_subscribed": false, "pm_pr_con_subscribed": false, "pm_legal_con_subscribed": false, "lm_primary_con_subscribed": false, "lm_billing_con_subscribed": false, "lm_authSig_subscribed": false, "lm_inv_con_subscribed": false, "lm_tech_con_1_subscribed": false, "lm_tech_con_2_subscribed": false, "lm_tech_con_3_subscribed": false, "lm_mkt_con_1_subscribed": false, "lm_mkt_con_2_subscribed": false, "lm_pr_con_subscribed": false, "lm_legal_con_subscribed": false }');
        RestContext.request = request1;
        RestResponse response1 = RestContext.response;
        
        Test.startTest();
        String result1 = JoinNowFormSubmission.processForm();
        Test.stopTest();
        system.debug(' result1 : ' + result1);
        System.assert(result1 != null);
    }
    
    @isTest static void testInsertProjectRoles(){
        Id MembershipOppId = [Select Id, Name From RecordType Where SobjectType = 'Opportunity' and Name='Membership'].Id;
        
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        // Creating Account Record in Test Class
        Account testAcntObj = new Account();
        testAcntObj.Name='Test Acnt Record' ;
        insert testAcntObj;
        
        Contact anotherCon = new Contact(FirstName='Another',LastName='Contact',Email='anothercontact@joinnow.com',AccountId = testAcntObj.Id);
        insert anotherCon;
        
        Alternate_Email__c ae = [Select ID From Alternate_Email__c WHERE Alternate_Email_Address__c='anothercontact@joinnow.com' Limit 1];
        
        
        // Creating Purchase History Record in Test Class
        Asset testAssetObj = new Asset();
        testAssetObj.Name ='Test Asset Record' ;
        testAssetObj.AccountId = testAcntObj.Id;
        testAssetObj.Projects__c = pj.Id;
        testAssetObj.Status = 'Active';
        testAssetObj.Price = 50000.0;
        testAssetObj.SalesOrderStatus__c = 'Open';
        testAssetObj.PurchaseDate = date.today()-1;
        testAssetObj.InstallDate = date.today()-1;
        insert testAssetObj;
        
        // Create Opportunity Record
        Opportunity testOppObj= new Opportunity(RecordTypeId=MembershipOppId,Name='Opportunity testing 1' , accountId=testAcntObj.Id , StageName='2. Discovery' ,Type='New Business', CloseDate=Date.today().addDays(4),Renewal_Opportunity_Closed__c='True' );
        insert testOppObj;
        
        // This is how we get the Standard PriceBook Id.  Prior to Summer '14, we needed
        // to use SeeAllData=true, so this is a big improvement
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = testOppObj.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 1 * pbEntry.UnitPrice,
            Project__c=pj.id,
            Product_Details__c = pd.Id
        );
        insert oli;
        system.debug('Opportunity RecordS:'+oli);
        
        List<Project_Role__c> lstProjectRoles = new List<Project_Role__c>();
        Project_Role__c projectRole = new Project_Role__c (Contact__c = anotherCon.Id, Status__c='Active', Alternate_Email__c= ae.Id, Role__c='Marketing Contact', Opportunity__c= testOppObj.Id, Opportunity_Line_Item__c = oli.Id, PrimaryContact__c = true);
        lstProjectRoles.add(projectRole);
        Project_Role__c projectRole1 = new Project_Role__c (Contact__c = anotherCon.Id, Status__c='Active', Alternate_Email__c= ae.Id, Role__c='Representative/Voting Contact', Opportunity__c= testOppObj.Id, Opportunity_Line_Item__c = oli.Id, PrimaryContact__c = true);
        lstProjectRoles.add(projectRole1);
        Project_Role__c projectRole2 = new Project_Role__c (Contact__c = anotherCon.Id, Status__c='Active', Alternate_Email__c= ae.Id, Role__c='Press Contact', Opportunity__c= testOppObj.Id, Opportunity_Line_Item__c = oli.Id, PrimaryContact__c = true);
        lstProjectRoles.add(projectRole2);
        Project_Role__c projectRole3 = new Project_Role__c (Contact__c = anotherCon.Id, Status__c='Active', Alternate_Email__c= ae.Id, Role__c='Technical Contact', Opportunity__c= testOppObj.Id, Opportunity_Line_Item__c = oli.Id, PrimaryContact__c = true);
        lstProjectRoles.add(projectRole3);
        Insert lstProjectRoles;
        
        //Creating Account Project Record
        Account_And_Project__c testAcntProjectObj=new Account_And_Project__c();
        testAcntProjectObj.Account__c=testAcntObj.id;
        testAcntProjectObj.Project__c=pj.id;
        insert testAcntProjectObj;
        
        Campaign campaign =  TestFactory.getCampaign();
        campaign.Type = 'Web Form - Join Now';
        campaign.Project__c = pj.Id;
        upsert campaign;
        
        CampaignMember cm= new CampaignMember();
        cm.ContactId = con.Id ;
        cm.CampaignId = campaign.Id;
        cm.Status = 'Sent';
        insert cm;
        
        String JSONTest = '{ "accountId": "' + testAcntObj.id + '", "category": "", "pm_product": "' + pd.id + '", "pm_project": "' + pj.id + '", "pm_po":"9999", "mode":"test","sign_msa":true, "lm_product": "' + pd.id + '", "pm_primary_con_id":  "' + con.id + '", "pm_billing_con_id": "' + con.id + '", "pm_authSig_id": "' + con.id + '", "pm_pr_con_id": "' + con.id + '", "pm_legal_con_id": "' + con.id + '", "pm_inv_con_id": "' + con.id + '", "pm_tech_con_1_id": "' + con.id + '", "pm_tech_con_2_id": "' + con.id + '", "pm_tech_con_3_id": "' + con.id + '", "pm_mkt_con_1_id": "' + con.id + '", "pm_mkt_con_2_id": "' + con.id + '", "lm_primary_con_id": "' + con.id + '", "lm_billing_con_id": "' + con.id + '", "lm_authSig_id": "' + con.id + '", "lm_pr_con_id": "' + con.id + '", "lm_legal_con_id": "' + con.id + '", "lm_inv_con_id": "' + con.id + '", "lm_tech_con_1_id": "' + con.id + '", "lm_tech_con_2_id": "' + con.id + '", "lm_tech_con_3_id": "' + con.id + '", "lm_mkt_con_1_id": "' + con.id + '", "lm_mkt_con_2_id": "' + con.id + '", "company": "Test Company", "address": "Test address", "city": "Test city", "state": "Test state", "zip": "Test zip", "employeeSize": "Test employeeSize", "display_logo": true, "press_release_announcement": true, "pm_primary_con_invoice_copy": false, "po_con_name": "Test Name 1", "po_con_emailParam": "Test1@test.com", "pm_primary_con_emailParam": "Test@test.com", "pm_primary_con_fname": "Test First Name", "pm_primary_con_lname": "Test Last Name", "pm_primary_con_title": "Test title", "pm_primary_con_phone": "987654321", "pm_billing_con_emailParam": "test@test.com", "pm_billing_con_fname": "Test First Name", "pm_billing_con_lname": "Test Last Name", "pm_billing_con_title": "Test title", "pm_billing_con_phone": "987654321", "pm_authSig_emailParam": "Test2@test.com", "pm_authSig_fname": "Test First Name", "pm_authSig_lname": "Test Last Name", "pm_authSig_title": "Test title", "pm_authSig_con_phone": "987654321", "pm_inv_con_emailParam": "Test3@test.com", "pm_inv_con_fname": "Test First Name", "pm_inv_con_lname": "Test Last Name", "pm_inv_con_title": "Test title", "pm_inv_con_phone": "987654321", "pm_tech_con_1_emailParam": "Test4@test.com", "pm_tech_con_1_fname": "Test First Name", "pm_tech_con_1_lname": "Test Last Name", "pm_tech_con_1_title": "Test title", "pm_tech_con_1_phone": "987654321", "pm_tech_con_2_emailParam": "Test5@test.com", "pm_tech_con_2_fname": "Test First Name", "pm_tech_con_2_lname": "Test Last Name", "pm_tech_con_2_title": "Test title", "pm_tech_con_2_phone": "987654321", "pm_tech_con_3_emailParam": "Test6@test.com", "pm_tech_con_3_fname": "Test First Name", "pm_tech_con_3_lname": "Test Last Name", "pm_tech_con_3_title": "Test title", "pm_tech_con_3_phone": "987654321", "pm_mkt_con_1_emailParam": "Test7@test.com", "pm_mkt_con_1_fname": "Test First Name", "pm_mkt_con_1_lname": "Test Last Name", "pm_mkt_con_1_title": "Test title", "pm_mkt_con_1_phone": "987654321", "pm_mkt_con_2_emailParam": "Test8@test.com", "pm_mkt_con_2_fname": "Test First Name", "pm_mkt_con_2_lname": "Test Last Name", "pm_mkt_con_2_title": "Test title", "pm_mkt_con_2_phone": "987654321", "pm_pr_con_emailParam": "Test9@test.com", "pm_pr_con_fname": "Test First Name", "pm_pr_con_lname": "Test Last Name", "pm_pr_con_title": "Test title", "pm_pr_con_phone": "987654321", "pm_legal_con_emailParam": "Test10@test.com", "pm_legal_con_fname": "Test First Name", "pm_legal_con_lname": "Test Last Name", "pm_legal_con_title": "Test title", "pm_legal_con_phone": "987654321", "lm_primary_con_emailParam": "Test11@test.com", "lm_primary_con_fname": "Test First Name", "lm_primary_con_lname": "Test Last Name", "lm_primary_con_title": "Test title", "lm_primary_con_phone": "987654321", "lm_billing_con_emailParam": "Test12@test.com", "lm_billing_con_fname": "Test First Name", "lm_billing_con_lname": "Test Last Name", "lm_billing_con_title": "Test title", "lm_billing_con_phone": "987654321", "lm_authSig_emailParam": "Test13@test.com", "lm_authSig_fname": "Test First Name", "lm_authSig_lname": "Test Last Name", "lm_authSig_title": "Test title", "lm_authSig_phone": "987654321", "lm_inv_con_emailParam": "Test14@test.com", "lm_inv_con_fname": "Test First Name", "lm_inv_con_lname": "Test Last Name", "lm_inv_con_title": "Test title", "lm_inv_con_phone": "987654321", "lm_tech_con_1_emailParam": "Test15@test.com", "lm_tech_con_1_fname": "Test First Name", "lm_tech_con_1_lname": "Test Last Name", "lm_tech_con_title": "Test title", "lm_tech_con_phone": "987654321", "lm_tech_con_2_emailParam": "Test16@test.com", "lm_tech_con_2_fname": "Test First Name", "lm_tech_con_2_lname": "Test Last Name", "lm_tech_con_2_title": "Test title", "lm_tech_con_2_phone": "987654321", "lm_tech_con_3_emailParam": "Test17@test.com", "lm_tech_con_3_fname": "Test First Name", "lm_tech_con_3_lname": "Test Last Name", "lm_tech_con_3_title": "Test title", "lm_tech_con_3_phone": "987654321", "lm_mkt_con_1_emailParam": "Test18@test.com", "lm_mkt_con_1_fname": "Test First Name", "lm_mkt_con_1_lname": "Test Last Name", "lm_mkt_con_1_title": "Test title", "lm_mkt_con_1_phone": "987654321", "lm_mkt_con_2_emailParam": "Test19@test.com", "lm_mkt_con_2_fname": "Test First Name", "lm_mkt_con_2_lname": "Test Last Name", "lm_mkt_con_2_title": "Test title", "lm_mkt_con_2_phone": "987654321", "lm_pr_con_emailParam": "Test20@test.com", "lm_pr_con_fname": "Test First Name", "lm_pr_con_lname": "Test Last Name", "lm_pr_con_title": "Test title", "lm_pr_con_phone": "987654321", "lm_legal_con_emailParam": "Test21@test.com", "lm_legal_con_fname": "Test First Name", "lm_legal_con_lname": "Test Last Name", "lm_legal_con_title": "Test title", "lm_legal_con_phone": "987654321", "pm_primary_con_subscribed": false, "pm_billing_con_subscribed": false, "pm_authSig_subscribed": false, "pm_inv_con_subscribed": false, "pm_tech_con_1_subscribed": false, "pm_tech_con_2_subscribed": false, "pm_tech_con_3_subscribed": false, "pm_mkt_con_1_subscribed": false, "pm_mkt_con_2_subscribed": false, "pm_pr_con_subscribed": false, "pm_legal_con_subscribed": false, "lm_primary_con_subscribed": false, "lm_billing_con_subscribed": false, "lm_authSig_subscribed": false, "lm_inv_con_subscribed": false, "lm_tech_con_1_subscribed": false, "lm_tech_con_2_subscribed": false, "lm_tech_con_3_subscribed": false, "lm_mkt_con_1_subscribed": false, "lm_mkt_con_2_subscribed": false, "lm_pr_con_subscribed": false, "lm_legal_con_subscribed": false }';
        RestRequest request1 = new RestRequest();
        request1.requestUri = '/JoinNowForm/';
        request1.httpMethod = 'POST';
        request1.addHeader('Content-Type', 'application/json');
        request1.requestBody = Blob.valueOf(JSONTest);
        RestContext.request = request1;
        RestResponse response1 = RestContext.response;
        
        Opportunity opp = [SELECT Id, (SELECT Id from OpportunityLineItems) from Opportunity LIMIT 1];
        System.debug('oppTestClass: ' + opp);
        Test.startTest();
        String result1 = JoinNowFormSubmission.processForm();
        JoinNowFormSubmission.insertProjectRoles(new List<OpportunityLineItem>{opp.OpportunityLineItems}, (JoinNowRequestWrapper) JSON.deserialize(result1, JoinNowRequestWrapper.class), opp.Id);
        Test.stopTest();
    }
    
    
    @isTest static void testProcessform3() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        Address__c adrObj = [Select ID from Address__c Limit 1];
        
        RestRequest request2 = new RestRequest();
        request2.requestUri = '/JoinNowForm/';
        request2.httpMethod = 'POST';
        request2.addHeader('Content-Type', 'application/json');
        request2.requestBody = Blob.valueOf('{"pm_primary_con_id":"","pm_product": "' + pd.id + '","display_logo": true, "sign_msa":true,"press_release_announcement": true, "preferred_invoice_method": "email", "category": "Research (Universities, Labs, other alliances, etc)", "pm_billing_con_id":"", "pm_authSig_id":"", "pm_pr_con_id": "", "pm_legal_con_id": "", "pm_inv_con_id": "", "pm_tech_con_1_id": "", "pm_tech_con_2_id": "", "pm_tech_con_3_id": "", "pm_mkt_con_1_id": "", "pm_mkt_con_2_id": "", "lm_primary_con_id": "", "lm_billing_con_id": "", "lm_authSig_id": "", "lm_pr_con_id": "", "lm_legal_con_id":"", "lm_inv_con_id": "", "lm_tech_con_1_id": "", "lm_tech_con_2_id": "", "lm_tech_con_3_id": "", "lm_mkt_con_1_id": "", "lm_mkt_con_2_id": "", "company": "Test Company", "address": "Test address", "city": "Test city", "state": "Test state", "zip": "Test zip", "employeeSize": "Test employeeSize", "po_con_name": "Test", "po_con_emailParam": "Test1@test.com", "pm_primary_con_emailParam": "Test@test.com", "pm_primary_con_fname": "Test First Name", "pm_primary_con_lname": "Test Last Name", "pm_primary_con_title": "Test title", "pm_primary_con_phone": "987654321", "pm_billing_con_emailParam": "Test1@test.com", "pm_billing_con_fname": "Test First Name", "pm_billing_con_lname": "Test Last Name", "pm_billing_con_title": "Test title", "pm_billing_con_phone": "987654321", "pm_authSig_emailParam": "Test2@test.com", "pm_authSig_fname": "Test First Name", "pm_authSig_lname": "Test Last Name", "pm_authSig_title": "Test title", "pm_authSig_con_phone": "987654321", "pm_inv_con_emailParam": "Test3@test.com", "pm_inv_con_fname": "Test First Name", "pm_inv_con_lname": "Test Last Name", "pm_inv_con_title": "Test title", "pm_inv_con_phone": "987654321", "pm_tech_con_1_emailParam": "Test4@test.com", "pm_tech_con_1_fname": "Test First Name", "pm_tech_con_1_lname": "Test Last Name", "pm_tech_con_1_title": "Test title", "pm_tech_con_1_phone": "987654321", "pm_tech_con_2_emailParam": "Test5@test.com", "pm_tech_con_2_fname": "Test First Name", "pm_tech_con_2_lname": "Test Last Name", "pm_tech_con_2_title": "Test title", "pm_tech_con_2_phone": "987654321", "pm_tech_con_3_emailParam": "Test6@test.com", "pm_tech_con_3_fname": "Test First Name", "pm_tech_con_3_lname": "Test Last Name", "pm_tech_con_3_title": "Test title", "pm_tech_con_3_phone": "987654321", "pm_mkt_con_1_emailParam": "Test7@test.com", "pm_mkt_con_1_fname": "Test First Name", "pm_mkt_con_1_lname": "Test Last Name", "pm_mkt_con_1_title": "Test title", "pm_mkt_con_1_phone": "987654321", "pm_mkt_con_2_emailParam": "Test8@test.com", "pm_mkt_con_2_fname": "Test First Name", "pm_mkt_con_2_lname": "Test Last Name", "pm_mkt_con_2_title": "Test title", "pm_mkt_con_2_phone": "987654321", "pm_pr_con_emailParam": "Test9@test.com", "pm_pr_con_fname": "Test First Name", "pm_pr_con_lname": "Test Last Name", "pm_pr_con_title": "Test title", "pm_pr_con_phone": "987654321", "pm_legal_con_emailParam": "Test10@test.com", "pm_legal_con_fname": "Test First Name", "pm_legal_con_lname": "Test Last Name", "pm_legal_con_title": "Test title", "pm_legal_con_phone": "987654321", "lm_primary_con_emailParam": "Test11@test.com", "lm_primary_con_fname": "Test First Name", "lm_primary_con_lname": "Test Last Name", "lm_primary_con_title": "Test title", "lm_primary_con_phone": "987654321", "lm_billing_con_emailParam": "Test12@test.com", "lm_billing_con_fname": "Test First Name", "lm_billing_con_lname": "Test Last Name", "lm_billing_con_title": "Test title", "lm_billing_con_phone": "987654321", "lm_authSig_emailParam": "Test13@test.com", "lm_authSig_fname": "Test First Name", "lm_authSig_lname": "Test Last Name", "lm_authSig_title": "Test title", "lm_authSig_phone": "987654321", "lm_inv_con_emailParam": "Test14@test.com", "lm_inv_con_fname": "Test First Name", "lm_inv_con_lname": "Test Last Name", "lm_inv_con_title": "Test title", "lm_inv_con_phone": "987654321", "lm_tech_con_1_emailParam": "Test15@test.com", "lm_tech_con_1_fname": "Test First Name", "lm_tech_con_1_lname": "Test Last Name", "lm_tech_con_title": "Test title", "lm_tech_con_phone": "987654321", "lm_tech_con_2_emailParam": "Test16@test.com", "lm_tech_con_2_fname": "Test First Name", "lm_tech_con_2_lname": "Test Last Name", "lm_tech_con_2_title": "Test title", "lm_tech_con_2_phone": "987654321", "lm_tech_con_3_emailParam": "Test17@test.com", "lm_tech_con_3_fname": "Test First Name", "lm_tech_con_3_lname": "Test Last Name", "lm_tech_con_3_title": "Test title", "lm_tech_con_3_phone": "987654321", "lm_mkt_con_1_emailParam": "Test18@test.com", "lm_mkt_con_1_fname": "Test First Name", "lm_mkt_con_1_lname": "Test Last Name", "lm_mkt_con_1_title": "Test title", "lm_mkt_con_1_phone": "987654321", "lm_mkt_con_2_emailParam": "Test19@test.com", "lm_mkt_con_2_fname": "Test First Name", "lm_mkt_con_2_lname": "Test Last Name", "lm_mkt_con_2_title": "Test title", "lm_mkt_con_2_phone": "987654321", "lm_pr_con_emailParam": "Test20@test.com", "lm_pr_con_fname": "Test First Name", "lm_pr_con_lname": "Test Last Name", "lm_pr_con_title": "Test title", "lm_pr_con_phone": "987654321", "lm_legal_con_emailParam": "Test21@test.com", "lm_legal_con_fname": "Test First Name", "lm_legal_con_lname": "Test Last Name", "lm_legal_con_title": "Test title", "pm_project": "' + pj.Id + '", "lm_legal_con_phone": "987654321" ,"pm_primary_con_subscribed":false,"pm_billing_con_subscribed":false,"pm_authSig_subscribed":false,"pm_inv_con_subscribed":false,"pm_tech_con_1_subscribed":false,"pm_tech_con_2_subscribed":false,"pm_tech_con_3_subscribed":false,"pm_mkt_con_1_subscribed":false,"pm_mkt_con_2_subscribed":false,"pm_pr_con_subscribed":false,"pm_legal_con_subscribed":false,"lm_primary_con_subscribed":false,"lm_billing_con_subscribed":false,"lm_authSig_subscribed":false,"lm_inv_con_subscribed":false,"lm_tech_con_1_subscribed":false,"lm_tech_con_2_subscribed":false,"lm_tech_con_3_subscribed":false,"lm_mkt_con_1_subscribed":false,"lm_mkt_con_2_subscribed":false,"lm_pr_con_subscribed":false,"lm_legal_con_subscribed":false}');
        RestContext.request = request2;
        RestResponse response2 = RestContext.response;
        
        Test.startTest();
        String result2 = JoinNowFormSubmission.processForm();
        Test.stopTest();
        
    }
    
    @isTest static void testProcessform4() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        
        RestRequest request = new RestRequest();
        request.requestUri = '/JoinNowForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{ "committeeData": [{"ContactID": "","FirstName": "Test","LastName": "Committee1","Email": "testcommittee1@gmail.com","Title": "Developer","committeeType": ["Technical Project"]}],"mode": "test","sign_msa":true,"company": "Test Company","pm_po": "257PO","pm_product": "' + pd.id + '","display_logo": true, "press_release_announcement": true, "preferred_invoice_method": "email", "category": "","address": "Test address", "city": "Test city", "state": "Test state", "zip": "Test zip", "employeeSize": "Test employeeSize", "po_con_name": "Test Name", "po_con_emailParam": "Test1@test.com","pm_po_required": true, "pm_primary_con_emailParam": "", "pm_primary_con_fname": "Test First Name", "pm_primary_con_lname": "Test Last Name", "pm_primary_con_title": "Test title", "pm_primary_con_phone": "987654321", "pm_billing_con_emailParam": "Test@test.com", "pm_billing_con_fname": "Test First Name", "pm_billing_con_lname": "Test Last Name", "pm_billing_con_title": "Test title", "pm_billing_con_phone": "987654321", "pm_authSig_emailParam": "Test@test.com", "pm_authSig_fname": "Test First Name", "pm_authSig_lname": "Test Last Name", "pm_authSig_title": "Test title", "pm_authSig_con_phone": "987654321", "pm_inv_con_emailParam": "Test@test.com", "pm_inv_con_fname": "Test First Name", "pm_inv_con_lname": "Test Last Name", "pm_inv_con_title": "Test title", "pm_inv_con_phone": "987654321", "pm_tech_con_1_emailParam": "Test@test.com", "pm_tech_con_1_fname": "Test First Name", "pm_tech_con_1_lname": "Test Last Name", "pm_tech_con_1_title": "Test title", "pm_tech_con_phone": "987654321", "pm_tech_con_2_emailParam": "Test@test.com", "pm_tech_con_2_fname": "Test First Name", "pm_tech_con_2_lname": "Test Last Name", "pm_tech_con_2_title": "Test title", "pm_tech_con_2_phone": "987654321", "pm_tech_con_3_emailParam": "Test@test.com", "pm_tech_con_3_fname": "Test First Name", "pm_tech_con_3_lname": "Test Last Name", "pm_tech_con_3_title": "Test title", "pm_tech_con_3_phone": "987654321", "pm_mkt_con_1_emailParam": "Test@test.com", "pm_mkt_con_1_fname": "Test First Name", "pm_mkt_con_1_lname": "Test Last Name", "pm_mkt_con_1_title": "Test title", "pm_mkt_con_1_phone": "987654321", "pm_mkt_con_2_emailParam": "Test@test.com", "pm_mkt_con_2_fname": "Test First Name", "pm_mkt_con_2_lname": "Test Last Name", "pm_mkt_con_2_title": "Test title", "pm_mkt_con_2_phone": "987654321", "pm_pr_con_emailParam": "Test@test.com", "pm_pr_con_fname": "Test First Name", "pm_pr_con_lname": "Test Last Name", "pm_pr_con_title": "Test title", "pm_pr_con_phone": "987654321", "pm_legal_con_emailParam": "Test@test.com", "pm_legal_con_fname": "Test First Name", "pm_legal_con_lname": "Test Last Name", "pm_legal_con_title": "Test title", "pm_legal_con_phone": "987654321", "lm_primary_con_emailParam": "Test@test.com", "lm_primary_con_fname": "Test First Name", "lm_primary_con_lname": "Test Last Name", "lm_primary_con_title": "Test title", "lm_primary_con_phone": "987654321", "lm_billing_con_emailParam": "Test@test.com", "lm_billing_con_fname": "Test First Name", "lm_billing_con_lname": "Test Last Name", "lm_billing_con_title": "Test title", "lm_billing_con_phone": "987654321", "lm_authSig_emailParam": "Test@test.com", "lm_authSig_fname": "Test First Name", "lm_authSig_lname": "Test Last Name", "lm_authSig_title": "Test title", "lm_authSig_phone": "987654321", "lm_inv_con_emailParam": "Test@test.com", "lm_inv_con_fname": "Test First Name", "lm_inv_con_lname": "Test Last Name", "lm_inv_con_title": "Test title", "lm_inv_con_phone": "987654321", "lm_tech_con_1_emailParam": "Test@test.com", "lm_tech_con_1_fname": "Test First Name", "lm_tech_con_1_lname": "Test Last Name", "lm_tech_con_title": "Test title", "lm_tech_con_phone": "987654321", "lm_tech_con_2_emailParam": "Test@test.com", "lm_tech_con_2_fname": "Test First Name", "lm_tech_con_2_lname": "Test Last Name", "lm_tech_con_2_title": "Test title", "lm_tech_con_2_phone": "987654321", "lm_tech_con_3_emailParam": "Test@test.com", "lm_tech_con_3_fname": "Test First Name", "lm_tech_con_3_lname": "Test Last Name", "lm_tech_con_3_title": "Test title", "lm_tech_con_3_phone": "987654321", "lm_mkt_con_1_emailParam": "Test@test.com", "lm_mkt_con_1_fname": "Test First Name", "lm_mkt_con_1_lname": "Test Last Name", "lm_mkt_con_1_title": "Test title", "lm_mkt_con_1_phone": "987654321", "lm_mkt_con_2_emailParam": "Test@test.com", "lm_mkt_con_2_fname": "Test First Name", "lm_mkt_con_2_lname": "Test Last Name", "lm_mkt_con_2_title": "Test title", "lm_mkt_con_2_phone": "987654321", "lm_pr_con_emailParam": "Test@test.com", "lm_pr_con_fname": "Test First Name", "lm_pr_con_lname": "Test Last Name", "lm_pr_con_title": "Test title", "lm_pr_con_phone": "987654321", "lm_legal_con_emailParam": "Test@test.com", "lm_legal_con_fname": "Test First Name", "lm_legal_con_lname": "Test Last Name", "lm_legal_con_title": "Test title", "pm_project": "' + pj.id + '", "lm_legal_con_phone": "987654321" , "pm_primary_con_id":"' + con.id + '" , "pm_billing_con_id": "", "pm_authSig_id": "", "pm_inv_con_id": "", "pm_tech_con_1_id": "", "pm_tech_con_2_id": "", "pm_tech_con_3_id": "", "pm_mkt_con_1_id": "", "pm_mkt_con_2_id": "", "pm_pr_con_id": "", "pm_legal_con_id": "", "lm_primary_con_id": "", "lm_billing_con_id": "", "lm_authSig_id": "", "lm_inv_con_id": "", "lm_tech_con_1_id": "", "lm_tech_con_2_id": "", "lm_tech_con_3_id": "", "lm_mkt_con_1_id": "", "lm_mkt_con_2_id": "", "lm_pr_con_id": "", "lm_legal_con_id": "", "pm_primary_con_subscribed": false, "pm_billing_con_subscribed": false, "pm_authSig_subscribed": false, "pm_inv_con_subscribed": false, "pm_tech_con_1_subscribed": false, "pm_tech_con_2_subscribed": false, "pm_tech_con_3_subscribed": false, "pm_mkt_con_1_subscribed": false, "pm_mkt_con_2_subscribed": false, "pm_pr_con_subscribed": false, "pm_legal_con_subscribed": false, "lm_primary_con_subscribed": false, "lm_billing_con_subscribed": false, "lm_authSig_subscribed": false, "lm_inv_con_subscribed": false, "lm_tech_con_1_subscribed": false, "lm_tech_con_2_subscribed": false, "lm_tech_con_3_subscribed": false, "lm_mkt_con_1_subscribed": false, "lm_mkt_con_2_subscribed": false, "lm_pr_con_subscribed": false, "lm_legal_con_subscribed": false, "billto_account_name": "TestCompanyForJoinNow", "billto_city": "Mumbai", "billto_country": "India", "billto_zip": "400709", "billto_state": "Maharashtra","billto_street": "MG Road"}');
        RestContext.request = request;
        RestResponse response = RestContext.response;
        
        Test.startTest();
        String result = JoinNowFormSubmission.processForm();
        Test.stopTest();
        system.debug(' result : ' + result);
        System.assert(result != null);
    }
    
    @isTest static void testProcessform5() {
        
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = '/JoinNowForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{ "accountId": "a2g2M000002PUmMQAW","company": "Test Company","pm_po": "257PO","pm_product": "' + pd.id + '","display_logo": true, "press_release_announcement": true, "preferred_invoice_method": "email", "category": "","address": "Test address", "city": "Test city", "state": "Test state", "zip": "Test zip", "employeeSize": "Test employeeSize", "po_con_name": "Test Name", "po_con_emailParam": "Test1@test.com","pm_po_required": true, "pm_primary_con_emailParam": "Test@test.com", "pm_primary_con_fname": "Test First Name", "pm_primary_con_lname": "Test Last Name", "pm_primary_con_title": "Test title", "pm_primary_con_phone": "987654321", "pm_billing_con_emailParam": "Test@test.com", "pm_billing_con_fname": "Test First Name", "pm_billing_con_lname": "Test Last Name", "pm_billing_con_title": "Test title", "pm_billing_con_phone": "987654321", "pm_authSig_emailParam": "Test@test.com", "pm_authSig_fname": "Test First Name", "pm_authSig_lname": "Test Last Name", "pm_authSig_title": "Test title", "pm_authSig_con_phone": "987654321", "pm_inv_con_emailParam": "Test@test.com", "pm_inv_con_fname": "Test First Name", "pm_inv_con_lname": "Test Last Name", "pm_inv_con_title": "Test title", "pm_inv_con_phone": "987654321", "pm_tech_con_1_emailParam": "Test@test.com", "pm_tech_con_1_fname": "Test First Name", "pm_tech_con_1_lname": "Test Last Name", "pm_tech_con_1_title": "Test title", "pm_tech_con_phone": "987654321", "pm_tech_con_2_emailParam": "Test@test.com", "pm_tech_con_2_fname": "Test First Name", "pm_tech_con_2_lname": "Test Last Name", "pm_tech_con_2_title": "Test title", "pm_tech_con_2_phone": "987654321", "pm_tech_con_3_emailParam": "Test@test.com", "pm_tech_con_3_fname": "Test First Name", "pm_tech_con_3_lname": "Test Last Name", "pm_tech_con_3_title": "Test title", "pm_tech_con_3_phone": "987654321", "pm_mkt_con_1_emailParam": "Test@test.com", "pm_mkt_con_1_fname": "Test First Name", "pm_mkt_con_1_lname": "Test Last Name", "pm_mkt_con_1_title": "Test title", "pm_mkt_con_1_phone": "987654321", "pm_mkt_con_2_emailParam": "Test@test.com", "pm_mkt_con_2_fname": "Test First Name", "pm_mkt_con_2_lname": "Test Last Name", "pm_mkt_con_2_title": "Test title", "pm_mkt_con_2_phone": "987654321", "pm_pr_con_emailParam": "Test@test.com", "pm_pr_con_fname": "Test First Name", "pm_pr_con_lname": "Test Last Name", "pm_pr_con_title": "Test title", "pm_pr_con_phone": "987654321", "pm_legal_con_emailParam": "Test@test.com", "pm_legal_con_fname": "Test First Name", "pm_legal_con_lname": "Test Last Name", "pm_legal_con_title": "Test title", "pm_legal_con_phone": "987654321", "lm_primary_con_emailParam": "Test@test.com", "lm_primary_con_fname": "Test First Name", "lm_primary_con_lname": "Test Last Name", "lm_primary_con_title": "Test title", "lm_primary_con_phone": "987654321", "lm_billing_con_emailParam": "Test@test.com", "lm_billing_con_fname": "Test First Name", "lm_billing_con_lname": "Test Last Name", "lm_billing_con_title": "Test title", "lm_billing_con_phone": "987654321", "lm_authSig_emailParam": "Test@test.com", "lm_authSig_fname": "Test First Name", "lm_authSig_lname": "Test Last Name", "lm_authSig_title": "Test title", "lm_authSig_phone": "987654321", "lm_inv_con_emailParam": "Test@test.com", "lm_inv_con_fname": "Test First Name", "lm_inv_con_lname": "Test Last Name", "lm_inv_con_title": "Test title", "lm_inv_con_phone": "987654321", "lm_tech_con_1_emailParam": "Test@test.com", "lm_tech_con_1_fname": "Test First Name", "lm_tech_con_1_lname": "Test Last Name", "lm_tech_con_title": "Test title", "lm_tech_con_phone": "987654321", "lm_tech_con_2_emailParam": "Test@test.com", "lm_tech_con_2_fname": "Test First Name", "lm_tech_con_2_lname": "Test Last Name", "lm_tech_con_2_title": "Test title", "lm_tech_con_2_phone": "987654321", "lm_tech_con_3_emailParam": "Test@test.com", "lm_tech_con_3_fname": "Test First Name", "lm_tech_con_3_lname": "Test Last Name", "lm_tech_con_3_title": "Test title", "lm_tech_con_3_phone": "987654321", "lm_mkt_con_1_emailParam": "Test@test.com", "lm_mkt_con_1_fname": "Test First Name", "lm_mkt_con_1_lname": "Test Last Name", "lm_mkt_con_1_title": "Test title", "lm_mkt_con_1_phone": "987654321", "lm_mkt_con_2_emailParam": "Test@test.com", "lm_mkt_con_2_fname": "Test First Name", "lm_mkt_con_2_lname": "Test Last Name", "lm_mkt_con_2_title": "Test title", "lm_mkt_con_2_phone": "987654321", "lm_pr_con_emailParam": "Test@test.com", "lm_pr_con_fname": "Test First Name", "lm_pr_con_lname": "Test Last Name", "lm_pr_con_title": "Test title", "lm_pr_con_phone": "987654321", "lm_legal_con_emailParam": "Test@test.com", "lm_legal_con_fname": "Test First Name", "lm_legal_con_lname": "Test Last Name", "lm_legal_con_title": "Test title", "pm_project": "' + pj.id + '", "lm_legal_con_phone": "987654321" ,  "pm_primary_con_id": "", "pm_billing_con_id": "", "pm_authSig_id": "", "pm_inv_con_id": "", "pm_tech_con_1_id": "", "pm_tech_con_2_id": "", "pm_tech_con_3_id": "", "pm_mkt_con_1_id": "", "pm_mkt_con_2_id": "", "pm_pr_con_id": "", "pm_legal_con_id": "", "lm_primary_con_id": "", "lm_billing_con_id": "", "lm_authSig_id": "", "lm_inv_con_id": "", "lm_tech_con_1_id": "", "lm_tech_con_2_id": "", "lm_tech_con_3_id": "", "lm_mkt_con_1_id": "", "lm_mkt_con_2_id": "", "lm_pr_con_id": "", "lm_legal_con_id": "", "pm_primary_con_subscribed": false, "pm_billing_con_subscribed": false, "pm_authSig_subscribed": false, "pm_inv_con_subscribed": false, "pm_tech_con_1_subscribed": false, "pm_tech_con_2_subscribed": false, "pm_tech_con_3_subscribed": false, "pm_mkt_con_1_subscribed": false, "pm_mkt_con_2_subscribed": false, "pm_pr_con_subscribed": false, "pm_legal_con_subscribed": false, "lm_primary_con_subscribed": false, "lm_billing_con_subscribed": false, "lm_authSig_subscribed": false, "lm_inv_con_subscribed": false, "lm_tech_con_1_subscribed": false, "lm_tech_con_2_subscribed": false, "lm_tech_con_3_subscribed": false, "lm_mkt_con_1_subscribed": false, "lm_mkt_con_2_subscribed": false, "lm_pr_con_subscribed": false, "lm_legal_con_subscribed": false, "billto_account_name": "TestCompanyForJoinNow", "billto_city": "Mumbai", "billto_country": "India", "billto_zip": "400709", "billto_state": "Maharashtra","billto_street": "MG Road"}');
        RestContext.request = request;
        RestContext.response = response;
        
        String result = JoinNowFormSubmission.processForm();
        System.assert(result != null);
    }
    
    @isTest static void testProcessform6() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = '/JoinNowForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{ "accountId": "' + acc.id +'","company": "Test Company","pm_po": "257PO","pm_product": "a2g2M000002PUmMQAW","display_logo": true, "press_release_announcement": true, "preferred_invoice_method": "email", "category": "","address": "Test address", "city": "Test city", "state": "Test state", "zip": "Test zip", "employeeSize": "Test employeeSize", "po_con_name": "Test Name", "po_con_emailParam": "Test1@test.com","pm_po_required": true, "pm_primary_con_emailParam": "Test@test.com", "pm_primary_con_fname": "Test First Name", "pm_primary_con_lname": "Test Last Name", "pm_primary_con_title": "Test title", "pm_primary_con_phone": "987654321", "pm_billing_con_emailParam": "Test@test.com", "pm_billing_con_fname": "Test First Name", "pm_billing_con_lname": "Test Last Name", "pm_billing_con_title": "Test title", "pm_billing_con_phone": "987654321", "pm_authSig_emailParam": "Test@test.com", "pm_authSig_fname": "Test First Name", "pm_authSig_lname": "Test Last Name", "pm_authSig_title": "Test title", "pm_authSig_con_phone": "987654321", "pm_inv_con_emailParam": "Test@test.com", "pm_inv_con_fname": "Test First Name", "pm_inv_con_lname": "Test Last Name", "pm_inv_con_title": "Test title", "pm_inv_con_phone": "987654321", "pm_tech_con_1_emailParam": "Test@test.com", "pm_tech_con_1_fname": "Test First Name", "pm_tech_con_1_lname": "Test Last Name", "pm_tech_con_1_title": "Test title", "pm_tech_con_phone": "987654321", "pm_tech_con_2_emailParam": "Test@test.com", "pm_tech_con_2_fname": "Test First Name", "pm_tech_con_2_lname": "Test Last Name", "pm_tech_con_2_title": "Test title", "pm_tech_con_2_phone": "987654321", "pm_tech_con_3_emailParam": "Test@test.com", "pm_tech_con_3_fname": "Test First Name", "pm_tech_con_3_lname": "Test Last Name", "pm_tech_con_3_title": "Test title", "pm_tech_con_3_phone": "987654321", "pm_mkt_con_1_emailParam": "Test@test.com", "pm_mkt_con_1_fname": "Test First Name", "pm_mkt_con_1_lname": "Test Last Name", "pm_mkt_con_1_title": "Test title", "pm_mkt_con_1_phone": "987654321", "pm_mkt_con_2_emailParam": "Test@test.com", "pm_mkt_con_2_fname": "Test First Name", "pm_mkt_con_2_lname": "Test Last Name", "pm_mkt_con_2_title": "Test title", "pm_mkt_con_2_phone": "987654321", "pm_pr_con_emailParam": "Test@test.com", "pm_pr_con_fname": "Test First Name", "pm_pr_con_lname": "Test Last Name", "pm_pr_con_title": "Test title", "pm_pr_con_phone": "987654321", "pm_legal_con_emailParam": "Test@test.com", "pm_legal_con_fname": "Test First Name", "pm_legal_con_lname": "Test Last Name", "pm_legal_con_title": "Test title", "pm_legal_con_phone": "987654321", "lm_primary_con_emailParam": "Test@test.com", "lm_primary_con_fname": "Test First Name", "lm_primary_con_lname": "Test Last Name", "lm_primary_con_title": "Test title", "lm_primary_con_phone": "987654321", "lm_billing_con_emailParam": "Test@test.com", "lm_billing_con_fname": "Test First Name", "lm_billing_con_lname": "Test Last Name", "lm_billing_con_title": "Test title", "lm_billing_con_phone": "987654321", "lm_authSig_emailParam": "Test@test.com", "lm_authSig_fname": "Test First Name", "lm_authSig_lname": "Test Last Name", "lm_authSig_title": "Test title", "lm_authSig_phone": "987654321", "lm_inv_con_emailParam": "Test@test.com", "lm_inv_con_fname": "Test First Name", "lm_inv_con_lname": "Test Last Name", "lm_inv_con_title": "Test title", "lm_inv_con_phone": "987654321", "lm_tech_con_1_emailParam": "Test@test.com", "lm_tech_con_1_fname": "Test First Name", "lm_tech_con_1_lname": "Test Last Name", "lm_tech_con_title": "Test title", "lm_tech_con_phone": "987654321", "lm_tech_con_2_emailParam": "Test@test.com", "lm_tech_con_2_fname": "Test First Name", "lm_tech_con_2_lname": "Test Last Name", "lm_tech_con_2_title": "Test title", "lm_tech_con_2_phone": "987654321", "lm_tech_con_3_emailParam": "Test@test.com", "lm_tech_con_3_fname": "Test First Name", "lm_tech_con_3_lname": "Test Last Name", "lm_tech_con_3_title": "Test title", "lm_tech_con_3_phone": "987654321", "lm_mkt_con_1_emailParam": "Test@test.com", "lm_mkt_con_1_fname": "Test First Name", "lm_mkt_con_1_lname": "Test Last Name", "lm_mkt_con_1_title": "Test title", "lm_mkt_con_1_phone": "987654321", "lm_mkt_con_2_emailParam": "Test@test.com", "lm_mkt_con_2_fname": "Test First Name", "lm_mkt_con_2_lname": "Test Last Name", "lm_mkt_con_2_title": "Test title", "lm_mkt_con_2_phone": "987654321", "lm_pr_con_emailParam": "Test@test.com", "lm_pr_con_fname": "Test First Name", "lm_pr_con_lname": "Test Last Name", "lm_pr_con_title": "Test title", "lm_pr_con_phone": "987654321", "lm_legal_con_emailParam": "Test@test.com", "lm_legal_con_fname": "Test First Name", "lm_legal_con_lname": "Test Last Name", "lm_legal_con_title": "Test title", "pm_project": "' + pj.id + '", "lm_legal_con_phone": "987654321" ,  "pm_primary_con_id": "", "pm_billing_con_id": "", "pm_authSig_id": "", "pm_inv_con_id": "", "pm_tech_con_1_id": "", "pm_tech_con_2_id": "", "pm_tech_con_3_id": "", "pm_mkt_con_1_id": "", "pm_mkt_con_2_id": "", "pm_pr_con_id": "", "pm_legal_con_id": "", "lm_primary_con_id": "", "lm_billing_con_id": "", "lm_authSig_id": "", "lm_inv_con_id": "", "lm_tech_con_1_id": "", "lm_tech_con_2_id": "", "lm_tech_con_3_id": "", "lm_mkt_con_1_id": "", "lm_mkt_con_2_id": "", "lm_pr_con_id": "", "lm_legal_con_id": "", "pm_primary_con_subscribed": false, "pm_billing_con_subscribed": false, "pm_authSig_subscribed": false, "pm_inv_con_subscribed": false, "pm_tech_con_1_subscribed": false, "pm_tech_con_2_subscribed": false, "pm_tech_con_3_subscribed": false, "pm_mkt_con_1_subscribed": false, "pm_mkt_con_2_subscribed": false, "pm_pr_con_subscribed": false, "pm_legal_con_subscribed": false, "lm_primary_con_subscribed": false, "lm_billing_con_subscribed": false, "lm_authSig_subscribed": false, "lm_inv_con_subscribed": false, "lm_tech_con_1_subscribed": false, "lm_tech_con_2_subscribed": false, "lm_tech_con_3_subscribed": false, "lm_mkt_con_1_subscribed": false, "lm_mkt_con_2_subscribed": false, "lm_pr_con_subscribed": false, "lm_legal_con_subscribed": false, "billto_account_name": "TestCompanyForJoinNow", "billto_city": "Mumbai", "billto_country": "India", "billto_zip": "400709", "billto_state": "Maharashtra","billto_street": "MG Road"}');
        RestContext.request = request;
        RestContext.response = response;
        
        String result = JoinNowFormSubmission.processForm();
        System.assert(result != null);
    }
    
    @isTest static void testProcessform7() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = '/JoinNowForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{ "accountId": "' + acc.id +'","company": "Test Company","pm_po": "257PO","pm_product": "' + pd.id + '","display_logo": true, "press_release_announcement": true, "preferred_invoice_method": "email", "category": "","address": "Test address", "city": "Test city", "state": "Test state", "zip": "Test zip", "employeeSize": "Test employeeSize", "po_con_name": "Test Name", "po_con_emailParam": "Test1@test.com","pm_po_required": true, "pm_primary_con_emailParam": "Test@test.com", "pm_primary_con_fname": "Test First Name", "pm_primary_con_lname": "Test Last Name", "pm_primary_con_title": "Test title", "pm_primary_con_phone": "987654321", "pm_billing_con_emailParam": "Test@test.com", "pm_billing_con_fname": "Test First Name", "pm_billing_con_lname": "Test Last Name", "pm_billing_con_title": "Test title", "pm_billing_con_phone": "987654321", "pm_authSig_emailParam": "Test@test.com", "pm_authSig_fname": "Test First Name", "pm_authSig_lname": "Test Last Name", "pm_authSig_title": "Test title", "pm_authSig_con_phone": "987654321", "pm_inv_con_emailParam": "Test@test.com", "pm_inv_con_fname": "Test First Name", "pm_inv_con_lname": "Test Last Name", "pm_inv_con_title": "Test title", "pm_inv_con_phone": "987654321", "pm_tech_con_1_emailParam": "Test@test.com", "pm_tech_con_1_fname": "Test First Name", "pm_tech_con_1_lname": "Test Last Name", "pm_tech_con_1_title": "Test title", "pm_tech_con_phone": "987654321", "pm_tech_con_2_emailParam": "Test@test.com", "pm_tech_con_2_fname": "Test First Name", "pm_tech_con_2_lname": "Test Last Name", "pm_tech_con_2_title": "Test title", "pm_tech_con_2_phone": "987654321", "pm_tech_con_3_emailParam": "Test@test.com", "pm_tech_con_3_fname": "Test First Name", "pm_tech_con_3_lname": "Test Last Name", "pm_tech_con_3_title": "Test title", "pm_tech_con_3_phone": "987654321", "pm_mkt_con_1_emailParam": "Test@test.com", "pm_mkt_con_1_fname": "Test First Name", "pm_mkt_con_1_lname": "Test Last Name", "pm_mkt_con_1_title": "Test title", "pm_mkt_con_1_phone": "987654321", "pm_mkt_con_2_emailParam": "Test@test.com", "pm_mkt_con_2_fname": "Test First Name", "pm_mkt_con_2_lname": "Test Last Name", "pm_mkt_con_2_title": "Test title", "pm_mkt_con_2_phone": "987654321", "pm_pr_con_emailParam": "Test@test.com", "pm_pr_con_fname": "Test First Name", "pm_pr_con_lname": "Test Last Name", "pm_pr_con_title": "Test title", "pm_pr_con_phone": "987654321", "pm_legal_con_emailParam": "Test@test.com", "pm_legal_con_fname": "Test First Name", "pm_legal_con_lname": "Test Last Name", "pm_legal_con_title": "Test title", "pm_legal_con_phone": "987654321", "lm_primary_con_emailParam": "Test@test.com", "lm_primary_con_fname": "Test First Name", "lm_primary_con_lname": "Test Last Name", "lm_primary_con_title": "Test title", "lm_primary_con_phone": "987654321", "lm_billing_con_emailParam": "Test@test.com", "lm_billing_con_fname": "Test First Name", "lm_billing_con_lname": "Test Last Name", "lm_billing_con_title": "Test title", "lm_billing_con_phone": "987654321", "lm_authSig_emailParam": "Test@test.com", "lm_authSig_fname": "Test First Name", "lm_authSig_lname": "Test Last Name", "lm_authSig_title": "Test title", "lm_authSig_phone": "987654321", "lm_inv_con_emailParam": "Test@test.com", "lm_inv_con_fname": "Test First Name", "lm_inv_con_lname": "Test Last Name", "lm_inv_con_title": "Test title", "lm_inv_con_phone": "987654321", "lm_tech_con_1_emailParam": "Test@test.com", "lm_tech_con_1_fname": "Test First Name", "lm_tech_con_1_lname": "Test Last Name", "lm_tech_con_title": "Test title", "lm_tech_con_phone": "987654321", "lm_tech_con_2_emailParam": "Test@test.com", "lm_tech_con_2_fname": "Test First Name", "lm_tech_con_2_lname": "Test Last Name", "lm_tech_con_2_title": "Test title", "lm_tech_con_2_phone": "987654321", "lm_tech_con_3_emailParam": "Test@test.com", "lm_tech_con_3_fname": "Test First Name", "lm_tech_con_3_lname": "Test Last Name", "lm_tech_con_3_title": "Test title", "lm_tech_con_3_phone": "987654321", "lm_mkt_con_1_emailParam": "Test@test.com", "lm_mkt_con_1_fname": "Test First Name", "lm_mkt_con_1_lname": "Test Last Name", "lm_mkt_con_1_title": "Test title", "lm_mkt_con_1_phone": "987654321", "lm_mkt_con_2_emailParam": "Test@test.com", "lm_mkt_con_2_fname": "Test First Name", "lm_mkt_con_2_lname": "Test Last Name", "lm_mkt_con_2_title": "Test title", "lm_mkt_con_2_phone": "987654321", "lm_pr_con_emailParam": "Test@test.com", "lm_pr_con_fname": "Test First Name", "lm_pr_con_lname": "Test Last Name", "lm_pr_con_title": "Test title", "lm_pr_con_phone": "987654321", "lm_legal_con_emailParam": "Test@test.com", "lm_legal_con_fname": "Test First Name", "lm_legal_con_lname": "Test Last Name", "lm_legal_con_title": "Test title", "pm_project":"a2g2M000002PUmMQAW", "lm_legal_con_phone": "987654321" ,  "pm_primary_con_id": "", "pm_billing_con_id": "", "pm_authSig_id": "", "pm_inv_con_id": "", "pm_tech_con_1_id": "", "pm_tech_con_2_id": "", "pm_tech_con_3_id": "", "pm_mkt_con_1_id": "", "pm_mkt_con_2_id": "", "pm_pr_con_id": "", "pm_legal_con_id": "", "lm_primary_con_id": "", "lm_billing_con_id": "", "lm_authSig_id": "", "lm_inv_con_id": "", "lm_tech_con_1_id": "", "lm_tech_con_2_id": "", "lm_tech_con_3_id": "", "lm_mkt_con_1_id": "", "lm_mkt_con_2_id": "", "lm_pr_con_id": "", "lm_legal_con_id": "", "pm_primary_con_subscribed": false, "pm_billing_con_subscribed": false, "pm_authSig_subscribed": false, "pm_inv_con_subscribed": false, "pm_tech_con_1_subscribed": false, "pm_tech_con_2_subscribed": false, "pm_tech_con_3_subscribed": false, "pm_mkt_con_1_subscribed": false, "pm_mkt_con_2_subscribed": false, "pm_pr_con_subscribed": false, "pm_legal_con_subscribed": false, "lm_primary_con_subscribed": false, "lm_billing_con_subscribed": false, "lm_authSig_subscribed": false, "lm_inv_con_subscribed": false, "lm_tech_con_1_subscribed": false, "lm_tech_con_2_subscribed": false, "lm_tech_con_3_subscribed": false, "lm_mkt_con_1_subscribed": false, "lm_mkt_con_2_subscribed": false, "lm_pr_con_subscribed": false, "lm_legal_con_subscribed": false, "billto_account_name": "TestCompanyForJoinNow", "billto_city": "Mumbai", "billto_country": "India", "billto_zip": "400709", "billto_state": "Maharashtra","billto_street": "MG Road"}');
        RestContext.request = request;
        RestContext.response = response;
        
        String result = JoinNowFormSubmission.processForm();
        System.assert(result != null);
    }
    
     @isTest static void testProcessform8() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Product_Details__c pd = [SELECT Id FROM Product_Details__c Where Project__c != null LIMIT 1];
        Project__c pj = [SELECT Id FROM Project__c LIMIT 1];
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestUri = '/JoinNowForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{ "accountId": "' + acc.id + '","company": "Test Company","pm_po": "257PO","pm_product": "' + pd.id + '","display_logo": true, "press_release_announcement": true, "preferred_invoice_method": "email", "category": "","address": "Test address", "city": "Test city", "state": "Test state", "zip": "Test zip", "employeeSize": "Test employeeSize", "po_con_name": "Test Name", "po_con_emailParam": "Test1@test.com", "pm_po_required": true, "pm_billing_con_emailParam": "Test@test.com", "pm_billing_con_fname": "Test First Name", "pm_billing_con_lname": "Test Last Name", "pm_billing_con_title": "Test title", "pm_billing_con_phone": "987654321", "pm_authSig_emailParam": "Test@test.com", "pm_authSig_fname": "Test First Name", "pm_authSig_lname": "Test Last Name", "pm_authSig_title": "Test title", "pm_authSig_con_phone": "987654321", "pm_inv_con_emailParam": "Test@test.com", "pm_inv_con_fname": "Test First Name", "pm_inv_con_lname": "Test Last Name", "pm_inv_con_title": "Test title", "pm_inv_con_phone": "987654321", "pm_tech_con_1_emailParam": "Test@test.com", "pm_tech_con_1_fname": "Test First Name", "pm_tech_con_1_lname": "Test Last Name", "pm_tech_con_1_title": "Test title", "pm_tech_con_phone": "987654321", "pm_tech_con_2_emailParam": "Test@test.com", "pm_tech_con_2_fname": "Test First Name", "pm_tech_con_2_lname": "Test Last Name", "pm_tech_con_2_title": "Test title", "pm_tech_con_2_phone": "987654321", "pm_tech_con_3_emailParam": "Test@test.com", "pm_tech_con_3_fname": "Test First Name", "pm_tech_con_3_lname": "Test Last Name", "pm_tech_con_3_title": "Test title", "pm_tech_con_3_phone": "987654321", "pm_mkt_con_1_emailParam": "Test@test.com", "pm_mkt_con_1_fname": "Test First Name", "pm_mkt_con_1_lname": "Test Last Name", "pm_mkt_con_1_title": "Test title", "pm_mkt_con_1_phone": "987654321", "pm_mkt_con_2_emailParam": "Test@test.com", "pm_mkt_con_2_fname": "Test First Name", "pm_mkt_con_2_lname": "Test Last Name", "pm_mkt_con_2_title": "Test title", "pm_mkt_con_2_phone": "987654321", "pm_pr_con_emailParam": "Test@test.com", "pm_pr_con_fname": "Test First Name", "pm_pr_con_lname": "Test Last Name", "pm_pr_con_title": "Test title", "pm_pr_con_phone": "987654321", "pm_legal_con_emailParam": "Test@test.com", "pm_legal_con_fname": "Test First Name", "pm_legal_con_lname": "Test Last Name", "pm_legal_con_title": "Test title", "pm_legal_con_phone": "987654321", "lm_primary_con_emailParam": "Test@test.com", "lm_primary_con_fname": "Test First Name", "lm_primary_con_lname": "Test Last Name", "lm_primary_con_title": "Test title", "lm_primary_con_phone": "987654321", "lm_billing_con_emailParam": "Test@test.com", "lm_billing_con_fname": "Test First Name", "lm_billing_con_lname": "Test Last Name", "lm_billing_con_title": "Test title", "lm_billing_con_phone": "987654321", "lm_authSig_emailParam": "Test@test.com", "lm_authSig_fname": "Test First Name", "lm_authSig_lname": "Test Last Name", "lm_authSig_title": "Test title", "lm_authSig_phone": "987654321", "lm_inv_con_emailParam": "Test@test.com", "lm_inv_con_fname": "Test First Name", "lm_inv_con_lname": "Test Last Name", "lm_inv_con_title": "Test title", "lm_inv_con_phone": "987654321", "lm_tech_con_1_emailParam": "Test@test.com", "lm_tech_con_1_fname": "Test First Name", "lm_tech_con_1_lname": "Test Last Name", "lm_tech_con_title": "Test title", "lm_tech_con_phone": "987654321", "lm_tech_con_2_emailParam": "Test@test.com", "lm_tech_con_2_fname": "Test First Name", "lm_tech_con_2_lname": "Test Last Name", "lm_tech_con_2_title": "Test title", "lm_tech_con_2_phone": "987654321", "lm_tech_con_3_emailParam": "Test@test.com", "lm_tech_con_3_fname": "Test First Name", "lm_tech_con_3_lname": "Test Last Name", "lm_tech_con_3_title": "Test title", "lm_tech_con_3_phone": "987654321", "lm_mkt_con_1_emailParam": "Test@test.com", "lm_mkt_con_1_fname": "Test First Name", "lm_mkt_con_1_lname": "Test Last Name", "lm_mkt_con_1_title": "Test title", "lm_mkt_con_1_phone": "987654321", "lm_mkt_con_2_emailParam": "Test@test.com", "lm_mkt_con_2_fname": "Test First Name", "lm_mkt_con_2_lname": "Test Last Name", "lm_mkt_con_2_title": "Test title", "lm_mkt_con_2_phone": "987654321", "lm_pr_con_emailParam": "Test@test.com", "lm_pr_con_fname": "Test First Name", "lm_pr_con_lname": "Test Last Name", "lm_pr_con_title": "Test title", "lm_pr_con_phone": "987654321", "lm_legal_con_emailParam": "Test@test.com", "lm_legal_con_fname": "Test First Name", "lm_legal_con_lname": "Test Last Name", "lm_legal_con_title": "Test title", "pm_project": "' + pj.id + '", "lm_legal_con_phone": "987654321" ,  "pm_primary_con_id": "a2g2M000002PUmMQAW", "pm_billing_con_id": "a2g2M000002PUmMQAW", "pm_authSig_id": "a2g2M000002PUmMQAW", "pm_inv_con_id": "a2g2M000002PUmMQAW", "pm_tech_con_1_id": "a2g2M000002PUmMQAW", "pm_tech_con_2_id": "a2g2M000002PUmMQAW", "pm_tech_con_3_id": "a2g2M000002PUmMQAW", "pm_mkt_con_1_id": "a2g2M000002PUmMQAW", "pm_mkt_con_2_id": "a2g2M000002PUmMQAW", "pm_pr_con_id": "a2g2M000002PUmMQAW", "pm_legal_con_id": "a2g2M000002PUmMQAW", "lm_primary_con_id": "a2g2M000002PUmMQAW", "lm_billing_con_id": "a2g2M000002PUmMQAW", "lm_authSig_id": "a2g2M000002PUmMQAW", "lm_inv_con_id": "a2g2M000002PUmMQAW", "lm_tech_con_1_id": "a2g2M000002PUmMQAW", "lm_tech_con_2_id": "a2g2M000002PUmMQAW", "lm_tech_con_3_id": "a2g2M000002PUmMQAW", "lm_mkt_con_1_id": "a2g2M000002PUmMQAW", "lm_mkt_con_2_id": "a2g2M000002PUmMQAW", "lm_pr_con_id": "a2g2M000002PUmMQAW", "lm_legal_con_id": "a2g2M000002PUmMQAW", "pm_primary_con_subscribed": false, "pm_billing_con_subscribed": false, "pm_authSig_subscribed": false, "pm_inv_con_subscribed": false, "pm_tech_con_1_subscribed": false, "pm_tech_con_2_subscribed": false, "pm_tech_con_3_subscribed": false, "pm_mkt_con_1_subscribed": false, "pm_mkt_con_2_subscribed": false, "pm_pr_con_subscribed": false, "pm_legal_con_subscribed": false, "lm_primary_con_subscribed": false, "lm_billing_con_subscribed": false, "lm_authSig_subscribed": false, "lm_inv_con_subscribed": false, "lm_tech_con_1_subscribed": false, "lm_tech_con_2_subscribed": false, "lm_tech_con_3_subscribed": false, "lm_mkt_con_1_subscribed": false, "lm_mkt_con_2_subscribed": false, "lm_pr_con_subscribed": false, "lm_legal_con_subscribed": false, "billto_account_name": "TestCompanyForJoinNow", "billto_city": "Mumbai", "billto_country": "India", "billto_zip": "400709", "billto_state": "Maharashtra","billto_street": "MG Road"}');
        RestContext.request = request;
        RestContext.response = response;
        
        String result = JoinNowFormSubmission.processForm();
        System.assert(result != null);
    }
    
    @isTest static void testCheckWithSinglePersonAccount(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'PersonAccount'].Id;
        
        Account prsAcc = New Account();
        prsAcc.RecordTypeId = RecordTypeId;
        prsAcc.FirstName = 'Fname';
        prsAcc.LastName = 'PrsAcc';
        Insert prsAcc;
        
        String conId = [SELECT PersonContactId From Account WHERE Id = :prsAcc.Id].PersonContactId;
        
        JoinNowUtility.checkForPersonAccount(conId, True, acc.Id);
        
    }   
    
    @isTest static void testCheckWithMultiplePersonAccount(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'PersonAccount'].Id;
        
        Account prsAcc = New Account();
        prsAcc.RecordTypeId = RecordTypeId;
        prsAcc.FirstName = 'Fname';
        prsAcc.LastName = 'PrsAcc';
        Insert prsAcc;
        
        String conId = [SELECT PersonContactId From Account WHERE Id = :prsAcc.Id].PersonContactId;
        Set<Id> conIds = new Set<Id>{conId};
            JoinNowUtility.checkForPersonAccount(conIds, acc.Id);
    }    
    
    @isTest static void testMergeDuplicateContacts(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'PersonAccount'].Id;
        
        sObject masterContact = new Contact(FirstName='Master',LastName='Contact',Email='mastercon@merge.com',AccountId=acc.Id);
        Insert masterContact;
        string masterRecordId = [Select Id From Contact Where Email ='mastercon@merge.com' Limit 1].Id;
        
        sObject duplicateContact = new Contact(FirstName='Duplicate',LastName='Contact',Email='duplicatecon@merge.com',AccountId=acc.Id,Title ='Developer',Phone='123987654',Twitter_ID__c='xyz',GitHub_ID__c='xyz',LinkedIn_ID__c='xyz',MailingStreet='xyz',MailingCity='xyz',MailingState='xyz',MailingCountry='xyz',MailingPostalCode='xyz',Username__c='duplicate');
        Insert duplicateContact;
        string duplicateRecordId = [Select Id From Contact Where Email ='duplicatecon@merge.com' Limit 1].Id;
        
        JoinNowUtility.EmailAndContactDetails wrapperObj = new JoinNowUtility.EmailAndContactDetails('mastercon@merge.com',masterRecordId, masterContact, 'duplicatecon@merge.com', duplicateRecordId , duplicateContact, 'false');
        JoinNowUtility.emailOrConIdvsEmailOrConid.put('mastercon@merge.com',masterRecordId);
        
        List <JoinNowUtility.EmailAndContactDetails> listWrapperObj = new List<JoinNowUtility.EmailAndContactDetails>() ;
        
        listWrapperObj.add(wrapperObj);
        
        JoinNowUtility.mergeDuplicateContacts(listWrapperObj);
        
    }    
}