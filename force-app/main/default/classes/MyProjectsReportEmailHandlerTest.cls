@istest
public class MyProjectsReportEmailHandlerTest {
    
   @testSetup static void setup(){

        User standard = TestFactory.getUser();

        Opportunity oppt= TestFactory.getOpportunity();
        oppt.OwnerId = standard.id;
        update oppt;
        
        Asset ass =  TestFactory.getAsset();
       	ass.UsageEndDate = ass.UsageEndDate.addDays(2);
        ass.OwnerId = standard.Id;
        update ass;
    }
    
    static testMethod void RecipientsDetail(){
        Opportunity opp = [Select ID, Name From Opportunity Where Name = 'Opportunity testing 1'];
        
        User userdetail = [Select ID, email From User Where email ='standarduser123@testorg.com'];
        System.debug('userdetail' +userdetail);

        
        List<Asset> listofasset = [Select ID,Name,InstallDate,UsageEndDate,Price,Opportunity__c,Opportunity__r.Name,Product2Id,Product2.ID,Product2.Name,Projects__r.Name,
                                   Projects__c,OpportunityLineItem__c, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState,
                                   Account.BillingPostalCode, Account.BillingCountry,Contact.Name,Contact.Email,Auto_Renew__c,Projects__r.OwnerId,Product2.Family
                                   from Asset WHERE Opportunity__c =: opp.ID];
        
        System.debug('Project Family' +listofasset[0].Product2.Family);
        system.debug('----'+listofasset[0].Product2Id);
        MyProjectsReportEmailHandler myproj = new MyProjectsReportEmailHandler();
        //MyProjectsReportEmailHandler.temporaryOwnerID = new set<id>{userdetail.Id};
            list<SendEmailWrapper.SendEmailContactWrapper> emailWrapper =  myproj.getRecipients();
        myproj.getBody();
        myproj.getAttachments(emailWrapper[0].params);
        
        
    }
    
    
}