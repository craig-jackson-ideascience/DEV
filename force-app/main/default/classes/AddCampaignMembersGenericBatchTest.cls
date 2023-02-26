/*
 * Test Class for - AddCampaignMembersGenericBatchScheduler and AddCampaignMembersGenericBatch Class
 */

@isTest
public class AddCampaignMembersGenericBatchTest {
    //Cretae Data
    @TestSetup
    static void testSetup(){
        List<Campaign> listOfCampaign = new List<Campaign>();
        Project__c testProject = TestFactory.getProject();
        Account testAccount = TestFactory.getAccount();
        for (Integer i = 0; i <  = 2; i++){
            Campaign campaign = new Campaign(Name = 'Test Campaign', IsActive = true, Status = 'In Progress',
                                             Description = 'TestCampaign', Do_Not_Include_in_Master_Subscriber_List__c = false, Project__c = testProject.Id);
            
            listOfCampaign.add(campaign);
        }
        Campaign campaign = new Campaign(Name = 'Test Master Campaign', IsActive = true, Status = 'In Progress', 
                                         Description = 'TestMasterCampaign', Project__c = testProject.Id);
        listOfCampaign.add(campaign);
        insert listOfCampaign;
        
        List<CampaignMember> listOfCampaignMember = new List<CampaignMember>();
        List<Contact> listOfContact = new List<Contact>();
        for (Integer i = 0; i <= 2; i++) {
            Contact contact = new Contact();
            contact.AccountId = testAccount.Id;
            contact.LastName = 'Test ' + i;
            contact.Lead_Source_Detail1__c='Edx';
            listOfContact.add(contact);
        }
        insert listOfContact;
        for (Integer i = 0; i <  = 2; i++){
            CampaignMember campaignMember = new CampaignMember();
            campaignMember.CampaignId = listOfCampaign[i].Id;
            campaignMember.ContactId = listOfContact[i].Id;
            
            listOfCampaignMember.add(campaignMember);
        }
        
        List<Lead> listOfLead = new List<Lead>();
        for (Integer i = 0; i <= 2; i++) {
            Lead lead = new Lead();
            lead.LastName = 'Test ' + i;
            lead.email='test@'+i+'email.com';
            lead.Lead_Source_Detail_p__c='Edx';
            listOfLead.add(lead);
        }
        insert listOfLead;
        for (Integer i = 0; i <  = 2; i++){
            CampaignMember campaignMember = new CampaignMember();
            campaignMember.CampaignId = listOfCampaign[i].Id;
            campaignMember.LeadId = listOfLead[i].Id;
            listOfCampaignMember.add(campaignMember);
        }
        insert listOfCampaignMember;
    }
    
    //test method for batch class
    @istest
    public static void testBatchdata(){
        Id ProjectId = [SELECT Id from Project__c LIMIT 1].Id;
        String query ='Select Id, ContactId, LeadId From CampaignMember Where HasOptedOutOfEmail = False AND '+
            'Campaign.Project__c = \''+ProjectId+'\' ';
        string contact ='contactid';
        string lead ='leadid';
        string campaignid=[SELECT ID FROM Campaign WHERE Name ='Test Master Campaign' LIMIT 1].ID;
        Test.startTest();
        Database.executebatch(new AddCampaignMembersGenericBatch(query,contact,lead,campaignid));
        Test.stopTest();
        System.assertNotEquals(null,[select id from campaignmember where campaignid=:campaignid].size());
    }

     //test method for error
     @istest
     public static void testBatchErrordata(){
         Id ProjectId = [SELECT Id from Project__c LIMIT 1].Id;
         String query ='Select Id, ContactId, LeadId From CampaignMember Where HasOptedOutOfEmail = False AND '+
             'Campaign.Project__c = \''+ProjectId+'\' ';
         string contact ='contact';
         string lead ='leadid';
         string campaignid=[SELECT ID FROM Campaign WHERE Name ='Test Master Campaign' LIMIT 1].ID;
         Test.startTest();
         Database.executebatch(new AddCampaignMembersGenericBatch(query,contact,lead,campaignid));
         Test.stopTest();       
     }
    
    //test method for scheduler
    @istest
    public static void testSchedulerdata(){
        
        Test.startTest();
        String query = 'SELECT Id FROM Lead WHERE Lead_Source_Detail_p__c=\'Edx\' and HasOptedOutOfEmail=false AND CreatedDate>=Yesterday';
        string contactApiname = null ;
        string leadApiname = 'Id';
        string campaignid=[SELECT ID FROM Campaign WHERE Name ='Test Master Campaign' LIMIT 1].ID;
        
        AddCampaignMembersGenericBatchScheduler ascd = new AddCampaignMembersGenericBatchScheduler(query,contactApiname,leadApiname,campaignid);
        ascd.execute(null);
        Test.stopTest();
    }
}