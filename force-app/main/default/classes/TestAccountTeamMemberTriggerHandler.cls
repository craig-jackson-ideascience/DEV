/*
* Test Class For-AccountTeamMemberTriggerHandler Class
*/ 
@isTest
public class TestAccountTeamMemberTriggerHandler {

    public static testmethod void setupTestData(){
        // get user
        User standard = TestFactory.getUser();
        // get account
        Account acc = TestFactory.getAccount();
        // get project
        Project__c project = TestFactory.getProject();
        // create cutsom setting record
        Team_Member_for_Project__c objTMFP = new Team_Member_for_Project__c();
        objTMFP.Name=project.id;
        objTMFP.Role__C = 'HL- POC';
        Insert objTMFP;
        // get opportunity
        Opportunity opportunity = TestFactory.getOpportunity();
        // get standard price book
        Id pricebookId = Test.getStandardPricebookId();
        // create custom pricebook
        PriceBook2 pbk = new PriceBook2(Name = 'testBook',isActive =true);
        insert pbk; 
        // create product record
        Product2 prod = new Product2(Name = 'TestP',productcode='test');
        insert prod;
        // adding product to Standard Price Book entry
        PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId,Product2Id=prod.ID,isActive=true,unitPrice=34);
        insert standardPbe;
        // adding product to Custom Price Book entry
        PriceBookEntry pbe=new PriceBookEntry(PriceBook2Id=pbk.Id,isActive=true,Product2Id=prod.ID,unitPrice=20.0,useStandardPrice=false);
        insert pbe;
        // create opportunity line item record
        OpportunityLineItem oli= new OpportunityLineItem(OpportunityId = opportunity.Id,Quantity =2, unitPrice = 20,PriceBookEntryId = pbe.ID,Required_Active_LF_Membership__c=true,Projects__c=project.id);    
        insert oli;
        // create AccountTeamMember record
        AccountTeamMember objATM= new AccountTeamMember();
        objATM.UserId = standard.id;
        objATM.AccountId =acc.id;
        objATM.TeamMemberRole ='HL- POC';
        insert objATM;
        
        Update objATM;
        
        delete objATM;
    }
}