@isTest
public class Test_CampaignLeadContact {
    static testmethod  void testCampaignLeadContact(){
        Map<Id,sObject> oldmap = new Map<Id,sObject>();
        Map<Id,sObject> newmap = new Map<Id,sObject>();
        List<Contact> lstContact = new List<Contact>();
        Set<Id> setLeadId = new Set<Id>();
        Contact con = new Contact(lastname = 'Test Contact',Mixmax_Campaign_Name__c ='Test Campaign 003');
        insert con;
        
        Lead sampleLead = new Lead(lastname = 'Test Lead',Email ='test@test.com',Mixmax_Campaign_Name__c ='Test Campaign 001');
        insert sampleLead;
        setLeadId.add(sampleLead.Id);
        
        Lead sampleLead2 = new Lead(lastname = 'Test Lead',Email ='test1@test.com',Mixmax_Campaign_Name__c ='Last Opportunity for Hyperledger Closed Lost Opptys to connect w/ Kevlin for LF Training');
        insert sampleLead2;
        setLeadId.add(sampleLead2.Id);
        
        Lead sampleLead3 = new Lead(lastname = 'Test Lead',Email ='test2@test.com');
        insert sampleLead3;
        setLeadId.add(sampleLead3.Id);
        
        sampleLead2.Mixmax_Campaign_Name__c ='Last Opportunity for Hyperledger Closed Lost Opptys to connect w/ Kevlin for LF Training';
        update sampleLead2;
        
        
        Campaign camp = new Campaign(
            Name = 'Test Campaign 3',
            IsActive = true,                                                   
            Status = 'In Progress',                                         
            Description = 'TestCampaign',
            type='MixMAx'       
        );
        insert camp;
        
        //con.Mixmax_Campaign_Name__c = camp.Name;
        sampleLead.Mixmax_Campaign_Name__c = camp.Name;
        
        Test.startTest();
        
        update con;
        update sampleLead;
        lstContact =[Select id,Mixmax_Campaign_Name__c from Contact where id =:con.id];
        
        List<Lead> lstLead =[Select id,Mixmax_Campaign_Name__c from Lead where id IN: setLeadId];
        
        
        CampaignLeadContact objClass = new CampaignLeadContact();
        CampaignLeadContact.addCommunityMemberContactORLead(lstContact);
        
        CampaignLeadContact.addCommunityMemberContactORLead(lstContact);
        
        
        
        Test.stopTest();
    }
}