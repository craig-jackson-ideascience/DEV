/*
*Batch Class -To Update Hubspot/Finos_HubSpot checkbox on lead/contact of campaignmembers of campaign
*Called by CampaignTrigger When Hubspot/Finos_HubSpot checkbox is checked on Campaign
*Test Class-CampaignTriggerTest
*Test Method-checkHubSpot_Test
*/
public class UpdateContactLeadForHubSpotCampaignBatch implements Database.Batchable<SObject>{
    Set<Id> campaignIdSet = new Set<Id>();
    public UpdateContactLeadForHubSpotCampaignBatch(Set<Id> campaignIdSet) {
        this.campaignIdSet = campaignIdSet;
    }

    //Start of the batch
    public  Database.QueryLocator start(Database.BatchableContext BC){
        //Query on CampaignMember
        String query='SELECT Id,Campaign.HubSpot__c,Campaign.Finos_Hubspot__c,CampaignId,Name,LeadId,Lead.HubSpot__c,Lead.Finos_Hubspot__c,'+
            'Contact.Finos_Hubspot__c,Contact.HubSpot__c,ContactId FROM CampaignMember '+
            'WHERE CampaignId IN:campaignIdSet AND '+
            '((LeadId != NULL AND  (Lead.HubSpot__c = false OR Lead.Finos_Hubspot__c = false)) OR '+
            '(ContactId != NULL AND  (Contact.HubSpot__c = false OR Contact.Finos_Hubspot__c = false))) ';
        return Database.getQueryLocator(query);
    }
    
    //Execute of Batch
    public void execute(Database.BatchableContext BC,List<CampaignMember> scope ){
        List<Lead> leadListTopdate = new List<Lead>();
        List<Contact> contactListToUpdate = new List<Contact>();
        //Iterate
        for(CampaignMember campMember : scope){
            //If Contact is present
            if(campMember.ContactId != null){
                
                Contact contact = new Contact(Id=campMember.ContactId);
                //If Hubspot is checked on Campaign then check hubspot on contact
                if(campMember.Campaign.HubSpot__c && !campMember.Contact.HubSpot__c){
                    contact.HubSpot__c = campMember.Campaign.HubSpot__c;
                }
                //If Finos_Hubspot__c is checked on Campaign then check Finos_Hubspot__c on contact
                if(campMember.Campaign.Finos_Hubspot__c && !campMember.Contact.Finos_Hubspot__c){
                    contact.Finos_Hubspot__c = campMember.Campaign.Finos_Hubspot__c;
                }
                contactListToUpdate.add(contact);
            }else{
                //If Contact is present
                Lead lead = new Lead(Id=campMember.LeadId);
                //If Hubspot is checked on Campaign then check hubspot on lead
                if(campMember.Campaign.HubSpot__c && !campMember.Lead.HubSpot__c){
                    lead.HubSpot__c = campMember.Campaign.HubSpot__c;
                }
                //If Finos_Hubspot__c is checked on Campaign then check Finos_Hubspot__c on lead
                if(campMember.Campaign.Finos_Hubspot__c && !campMember.Lead.Finos_Hubspot__c){
                    lead.Finos_Hubspot__c = campMember.Campaign.Finos_Hubspot__c;
                } 
                leadListTopdate.add(lead);
            }
        }
        //update lead
        if(!leadListTopdate.isEmpty()){
            
            System.debug(leadListTopdate.size()+' '+leadListTopdate);
            update leadListTopdate;
        }
        //update contact
        if(!contactListToUpdate.isEmpty()){
            
            System.debug(contactListToUpdate.size()+' '+contactListToUpdate);
            update contactListToUpdate;
        }
    }
    
    //Finish of batch
    public void finish(Database.BatchableContext info){
        
    }
    
}