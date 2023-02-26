/********************************************************
 * Created by: CloudRoute @ CloudRoute Solutions
 * Created Date: 04/11/19.
 * Description: RenewalFormTest
 ********************************************************/

@IsTest
public class RenewalFormTest {

    @IsTest
    public static void testBehavior() {

        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        lead l = new lead();
        l.lastName = 'Test l LastName';
        l.company = 'Test l Company';
        l.Email = 'testLead@testlinux.com';
        l.status = 'working';
        insert l;
        
        // create alternate email
        Alternate_Email__c alt1 = new Alternate_Email__c(
            Alternate_Email_Address__c	= 'abclead@gmail.com',
            Lead_Name__c = l.Id,
            Active__c = true
        );
        insert alt1;

        Contact con = new Contact();
        con.firstName = 'Test First name';
        con.lastName = 'Test last Name';
        con.email = 'testCon@testlinux.com';
        con.accountId = acc.Id;
        insert con;
        
        // create alternate email
        Alternate_Email__c alt2 = new Alternate_Email__c(
            Alternate_Email_Address__c	= 'abccontac@gmail.com',
            Contact_Name__c = con.Id,
            Active__c = true
        );
        insert alt2;

        Project__c pj = new Project__c();
        pj.Name = 'Test project';
        pj.Type__c = 'Membership';
        pj.Project_Entity_Name__c = 'Test P Name';
        pj.Category__c = 'Subproject';
        pj.Slug__c = 'testing';
        insert pj;

        Id pricebookId = Test.getStandardPricebookId();

        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Tax_Class__c = 'T1';
        p.IsActive = true;
        p.Family = 'Membership';
        insert p;

        PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = p.Id,
                UnitPrice = 100.00,
                IsActive = true
        );
        insert pbEntry;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = Date.today().addMonths(1);
        opp.StageName = '2. Discovery';
        opp.AccountId = acc.id;
        insert opp;

        OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Quantity = 1,
                PricebookEntryId = pbEntry.Id,
                TotalPrice = pbEntry.UnitPrice,
                Project__c = pj.Id
        );
        insert oli;

        RestRequest request = new RestRequest();
        request.requestUri = '/RenewalForm/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"voting_con_fname":"voting_con_fname","voting_con_lname":"voting_con_lname","voting_con_email":"testLead@linuxtest.com","voting_con_title":"voting_con_title","voting_con_twitter":"voting_con_twitter","voting_con_github":"voting_con_github","voting_con_linkedin":"voting_con_linkedin","legal_con_fname":"legal_con_fname","legal_con_lname":"legal_con_lname","legal_con_email":"testcon@linuxtest.com","legal_con_title":"legal_con_title","legal_con_twitter":"legal_con_twitter","legal_con_github":"legal_con_github","legal_con_linkedin":"legal_con_linkedin","pr_con_fname":"pr_con_fname","pr_con_lname":"pr_con_lname","pr_con_email":"test@linuxtest.com","pr_con_title":"pr_con_title","pr_con_twitter":"pr_con_twitter","pr_con_github":"pr_con_github","pr_con_linkedin":"pr_con_linkedin","billing_con_1_fname":"billing_con_1_fname","billing_con_1_lname":"billing_con_1_lname","billing_con_1_email":"test@testlinux.com","billing_con_1_title":"billing_con_1_title","billing_con_1_twitter":"billing_con_1_twitter","billing_con_1_github":"billing_con_1_github","billing_con_1_linkedin":"billing_con_1_linkedin","billing_con_2_fname":"billing_con_2_fname","billing_con_2_lname":"billing_con_2_lname","billing_con_2_email":"test@testlinux.com","billing_con_2_title":"billing_con_2_title","billing_con_2_twitter":"billing_con_2_twitter","billing_con_2_github":"billing_con_2_github","billing_con_2_linkedin":"billing_con_2_linkedin","billing_con_3_fname":"billing_con_3_fname","billing_con_3_lname":"billing_con_3_lname","billing_con_3_email":"test@testlinux.com","billing_con_3_title":"billing_con_3_title","billing_con_3_twitter":"billing_con_3_twitter","billing_con_3_github":"billing_con_3_github","billing_con_3_linkedin":"billing_con_3_linkedin","mkt_con_1_fname":"mkt_con_1_fname","mkt_con_1_lname":"mkt_con_1_lname","mkt_con_1_email":"test@testlinux.com","mkt_con_1_title":"mkt_con_1_title","mkt_con_1_twitter":"mkt_con_1_twitter","mkt_con_1_github":"mkt_con_1_github","mkt_con_1_linkedin":"mkt_con_1_linkedin","mkt_con_2_fname":"mkt_con_2_fname","mkt_con_2_lname":"mkt_con_2_lname","mkt_con_2_email":"test@testlinux.com","mkt_con_2_title":"mkt_con_2_title","mkt_con_2_twitter":"mkt_con_2_twitter","mkt_con_2_github":"mkt_con_2_github","mkt_con_2_linkedin":"mkt_con_2_linkedin","mkt_con_3_fname":"mkt_con_3_fname","mkt_con_3_lname":"mkt_con_3_lname","mkt_con_3_email":"test@testlinux.com","mkt_con_3_title":"mkt_con_3_title","mkt_con_3_twitter":"mkt_con_3_twitter","mkt_con_3_github":"mkt_con_3_github","mkt_con_3_linkedin":"mkt_con_3_linkedin","tech_con_1_fname":"tech_con_1_fname","tech_con_1_lname":"tech_con_1_lname","tech_con_1_email":"test@testlinux.com","tech_con_1_title":"tech_con_1_title","tech_con_1_twitter":"tech_con_1_twitter","tech_con_1_github":"tech_con_1_github","tech_con_1_linkedin":"tech_con_1_linkedin","tech_con_2_fname":"tech_con_2_fname","tech_con_2_lname":"tech_con_2_lname","tech_con_2_email":"test@testlinux.com","tech_con_2_title":"tech_con_2_title","tech_con_2_twitter":"tech_con_2_twitter","tech_con_2_github":"tech_con_2_github","tech_con_2_linkedin":"tech_con_2_linkedin","tech_con_3_fname":"tech_con_3_fname","tech_con_3_lname":"tech_con_3_lname","tech_con_3_email":"abclead@gmail.com","tech_con_3_title":"tech_con_3_title","tech_con_3_twitter":"tech_con_3_twitter","tech_con_3_github":"tech_con_3_github","tech_con_3_linkedin":"tech_con_3_linkedin","oppId":"' + opp.Id + '","oliId":"' + oli.Id + '"}');
        RestContext.request = request;

        String result = RenewalFormSubmission.processForm();

        System.assertEquals(true, [Select isConverted From Lead Where Id=:l.Id Limit 1].isConverted, 'Lead is not converted');
    }
}