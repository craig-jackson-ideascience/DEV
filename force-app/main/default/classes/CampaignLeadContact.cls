/*
LastModified By             ModifiedDate            Methods                                                 Against 
========================================================================================================================
Kalyani Chiluveri           18-May-2020             addCommunityMemberContactORLead                         SFDC-1284

Pratik D                    22-May-2020             addCommunityMemberContactORLead                         SFDC-1223
- Updated to handle insert scenario of Lead for creating MixMax Campaign and Campaign Member

Pratik D                    29-May-2020             addCommunityMemberContactORLead                         SFDC-1223
- Converting this method to batch rather than trigger

*/

public class CampaignLeadContact {
    
    public static void addCommunityMemberContactORLead(List<sObject> lstSobjects){
        
        List<sObject> lstsObject = new List<sObject>();
        List<Campaign> lstCampaign = new List<Campaign>();
        Map<String,Id> CampaignNameVsCamapaignId = new Map<String,Id>();
        Set<String> CampaignNames = new Set<String>();
        string strMixmaxCampaignNameMap;
        String strEmailBody='';
        
        
        for(sObject Objects : lstSobjects){ 
            Id id=(Id)Objects.get('Id');
            string strMixmaxCampaignName =(String)Objects.get('Mixmax_Campaign_Name__c');
                if(strMixmaxCampaignName.length() > 60){
                    string strCampaignName =strMixmaxCampaignName.substring(0, 60);
                    CampaignNames.add(strCampaignName);
                }
            else{
                CampaignNames.add(strMixmaxCampaignName);  
            }
            lstsObject.add(Objects);
             
        } 
        List<Campaign> lstCampaigns = new List<Campaign>();
        //Even if CampaignNames is empty SOQL was firing - to avaoid that added condition - against - SFDC -1284 
        if(!CampaignNames.isEmpty()) {
            lstCampaigns = new List<Campaign>([Select ID,Name From Campaign Where Name IN:CampaignNames]);
        }
        for(Campaign C:lstCampaigns){
            CampaignNameVsCamapaignId.put(C.Name,C.Id);
        }
        for(String campaignName : CampaignNames){
            if(!CampaignNameVsCamapaignId.containsKey(campaignName)){
                Campaign newCampaign = new Campaign(Name=campaignName,
                                                    Type='MixMax',
                                                    StartDate = system.today()
                                                    );
                lstCampaign.add(newCampaign);
            }
        }
        
        system.debug('List of campaign to be added'+lstCampaign);
        
        Database.SaveResult[] lstSRCampaign = Database.insert(lstCampaign, false); 
        Integer j = 0;
            
        for(Database.SaveResult sr : lstSRCampaign){
            if (sr.isSuccess()){
                CampaignNameVsCamapaignId.put(lstCampaign[j].Name, lstCampaign[j].Id);
            }else{
                for(Database.Error err : sr.getErrors()) {
                    
                    strEmailBody += String.format('\n\n #1 Time: {0}\nMessage: {1}\nStacktrace: {2}\nLine: {3}', 
                            new List<String>{ String.valueOf(System.now()), err.getMessage(), 'Class.CampaignLeadContact.addCommunityMemberContactORLead', 'Insert Campaign' });

                    System.debug('The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage() + ' : '+ err.getFields());
                }
            }
            j++;
        }
        
        for(Campaign objCampaign : lstCampaign){
            CampaignNameVsCamapaignId.put(objCampaign.Name,objCampaign.Id);
        }
        List<CampaignMember> lstCampaignMembers = new List<CampaignMember>();
        for(sObject Objects:lstsObject){
             string strCampaignName='';
            string strMixMCampaignName='';
            string strMixmaxCampaignName = (String)Objects.get('Mixmax_Campaign_Name__c'); 
            if(strMixmaxCampaignName.length() > 60){
                    strCampaignName =strMixmaxCampaignName.substring(0, 60);
                    strMixmaxCampaignName ='';
            }else{
                strMixMCampaignName = strMixmaxCampaignName;
            }
            string strObjectName = Objects.getSObjectType().getDescribe().getName();
            string LeadID = (String)Objects.get('Id'); 
            string ContactID = (String)Objects.get('Id');
            if(CampaignNameVsCamapaignId.containsKey(strMixMCampaignName) || CampaignNameVsCamapaignId.containsKey(strCampaignName)){
                CampaignMember newCM = new CampaignMember();
                if(strMixMCampaignName != '' ){
                newCM.CampaignId = CampaignNameVsCamapaignId.get(strMixMCampaignName);
                }else{
                  newCM.CampaignId = CampaignNameVsCamapaignId.get(strCampaignName);  
                }
                if(strObjectName == 'Lead'){
                    newCM.LeadId = LeadID; 
                }else{
                    newCM.ContactId = ContactID;
                }
                lstCampaignMembers.add(newCM);
            }
        }
        if(lstCampaignMembers.size() > 0){
            system.debug('lstCampaignMembers----->'+lstCampaignMembers);
            
            Database.SaveResult[] srList = Database.insert(lstCampaignMembers, false); 
            
            system.debug('srList----->'+srList);
            
            Integer i = 0;
            List<Lead> lstLeadUpdate = new List<Lead>();
            List<Contact> lstContactUpdate = new List<Contact>();
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted ID: ' + sr.getId());
                    
                    if( lstCampaignMembers[i].leadId != null ){
                    
                        lstLeadUpdate.add(
                            new Lead(
                                    Id = lstCampaignMembers[i].LeadId,
                                    MixMax_Create_Campaign__c = false
                                )
                            );                    
                    }else{
                        lstContactUpdate.add(
                            new Contact(
                                    Id = lstCampaignMembers[i].ContactId,
                                    MixMax_Create_Campaign__c = false
                                )
                            ); 
                    }        
                }
                else {
                    
                    System.debug('---1--- The following error has occurred.' + sr.getErrors());
                    
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        
                        strEmailBody += String.format('\n\n #2 Time: {0}\nMessage: {1}\nStacktrace: {2}\nLine: {3}', 
                            new List<String>{ String.valueOf(System.now()), err.getMessage(), 'Class.CampaignLeadContact.addCommunityMemberContactORLead', 'Insert Campaign Member' });
                        
                        System.debug('The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage() + ' : '+ err.getFields());
                    }
                }
                i++;
            }
            
            try{
                update lstContactUpdate;
                update lstLeadUpdate;
            }catch(exception e){
                
                strEmailBody += String.format('\n\n #3 Time: {0}\nMessage: {1}\nStacktrace: {2}\nLine: {3}', 
                            new List<String>{ String.valueOf(System.now()), e.getMessage(), e.getStackTraceString(), String.valueOf(e.getLineNumber()) });
            }
                
            
            if(strEmailBody != '' & strEmailBody != null ){
                
                Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId(orgWideEmailAddress);
                mail.setSubject('Errors occurred during batch - CreateMixMaxCampaignForLeadBatch');
                mail.setTargetObjectId(UserInfo.getUserId());
                mail.setSaveAsActivity(false);
                mail.setPlainTextBody(strEmailBody);
                Messaging.sendEmail(new Messaging.Email[] { mail });
                
            }
            
        }
    }
}