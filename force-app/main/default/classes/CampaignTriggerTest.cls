@isTest
public with sharing class CampaignTriggerTest {
   
    @testSetup static void setup() {
 	
        Account acc1 = new Account(Name = 'Test account' , website = 'testing123.com');
        insert acc1;
            
        Project__c project= new Project__c(Name='TestProject', Category__c = 'Directed fund', Slug__c = 'testproject');
        insert project;
            
        Campaign C1 = new Campaign();
            C1.Name ='Test Subscription Center';
            C1.Description ='Test for Email Opt Out';
            C1.Project__c = project.Id;
            C1.Type ='Subscription Center';
            C1.Status ='In Progress';
            C1.StartDate = Date.today();
            C1.IsActive = true;
            C1.Add_to_Subscription_Center__c = true;
            C1.Technology__c ='System Administration';
            insert C1;
            
            CampaignMemberStatus ms1= new CampaignMemberStatus();
            ms1.CampaignId = C1.Id;
            ms1.Label = 'Subscribed';
            ms1.SortOrder = 3;
            insert ms1;
            
            CampaignMemberStatus ms2 = new CampaignMemberStatus();
            ms2.CampaignId = C1.Id;
            ms2.Label = 'Unsubscribed';
            ms2.SortOrder = 4;
            insert ms2;
                
            List<Lead> leadListToInsert = new List<Lead>();
             Lead lead1 = new Lead();
             lead1.LastName = 'Lead Opt Out Check';
             lead1.Email = 'testOptOut@lead1.com';
             lead1.Country= 'India';
             leadListToInsert.add(lead1);
            
             Lead lead2 = new Lead();
             lead2.LastName = 'Lead Opt Out Check2';
             lead2.Email = 'testOptOut@lead2.com';
             lead2.Country= 'India';
             leadListToInsert.add(lead2);

             insert leadListToInsert;

             List<contact> contactListToInsert = new List<contact>();
             Contact contact1 = new Contact();
             contact1.LastName ='Contact Opt Out Check';
             contact1.Email ='testOptOut@contact1.com';
             contact1.AccountId = acc1.Id;
             contactListToInsert.add(contact1);  
            
             Contact contact2 = new Contact();
             contact2.LastName ='Contact Opt Out Check2';
             contact2.Email ='testOptOut@contact2.com';
             contact2.AccountId = acc1.Id;
             contactListToInsert.add(contact2);
             
             insert contactListToInsert;
            
            List<campaignMember> lstCM = new List<CampaignMember>();
            CampaignMember CM1 = new CampaignMember();
            CM1.CampaignID = C1.Id;
            CM1.LeadId = lead1.Id;
            CM1.Status = 'Subscribed';
            lstCm.add(CM1);
            
            CampaignMember CM2 = new CampaignMember();
            CM2.CampaignID = C1.Id;
            CM2.ContactId = contact1.Id;
            CM2.Status = 'Subscribed';
            lstCM.add(CM2);

            CampaignMember CM5 = new CampaignMember();
            CM5.CampaignID = C1.Id;
            CM5.LeadId = lead2.Id;
            CM5.Status = 'Unsubscribed';
            lstCm.add(CM5);
            
            CampaignMember CM6 = new CampaignMember();
            CM6.CampaignID = C1.Id;
            CM6.ContactId = contact2.Id;
            CM6.Status = 'Unsubscribed';
            lstCM.add(CM6);
            
            insert lstCM;
            
         }

    @isTest
    public static void checkHubSpot_Test(){
       Test.startTest();
        Campaign campaign =[SELECT Id FROM Campaign LIMIT 1];
        campaign.Hubspot__c = true;
        Campaign.Finos_Hubspot__c = true;
        update campaign;
        List<Campaignmember> cmMmberList = [SELECT Id FROM CampaignMember WHERE CampaignId=: campaign.Id 
        AND campaign.Hubspot__c = true AND campaign.Finos_Hubspot__c = true];
        system.assertequals(4,cmMmberList.size());
        Test.stopTest();
    }
}