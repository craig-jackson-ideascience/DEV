/********************************************************
* Created by: Pratik D
* Created Date: 18/MAY/2020.
* Description: Create campaign member based on meeting attendee
********************************************************/

public class MeetingTriggerHandler implements ITriggerHandler {

    public static void BeforeInsert(List<SObject> triggerNew){
        //
    }
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        //
    }    
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //
    } 
    
    public static void AfterInsert(Map<Id, SObject> newMap){
        //call onAfterInsert  actions
        createCampaign((List<Meeting__c>) (newMap.values()));
    }   
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){      
        updateCampaign( (List<Meeting__c>) (newMap.values()), (Map<Id, Meeting__c>)oldMap );
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) {
        deleteCampaignAndCampaignMember((Map<Id, Meeting__c>)oldMap);
    }
    
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after undelete actions
    } 
    
    public Boolean IsDisabled(){
        return false;
    }
    
    public static void createCampaign(List<Meeting__c> lstMeetingNew){
        
        List<Campaign> lstCampaign = new List<Campaign>();
        List<Meeting__c> lstMeetingUpdate = new List<Meeting__c>();
        List<Meeting__c> lstWebinarMeeting = new List<Meeting__c>();
        Set<String> setMeetingName = new Set<String>();
        Map<String, Id> mapCampaignName_ID = new Map<String, Id>();
        List<CampaignMemberStatus> lstCampaignMemberStatus = new List<CampaignMemberStatus>();
        
        
        //collect webinar meetings
        for( Meeting__c objMeeting : lstMeetingNew ){
            
            if(objMeeting.Type__c == 'Webinar'){
                lstWebinarMeeting.add(objMeeting);
                setMeetingName.add(objMeeting.Name);
            }
        }
        
        //proceed only if there are webinar meetings
        if( !lstWebinarMeeting.isEmpty() ){
            
            //get campaigns with meeting name
            for( Campaign objCampaign : [Select Id, Name from Campaign where Name IN:setMeetingName]){
                mapCampaignName_ID.put(objCampaign.Name,objCampaign.Id);
            }
            
            //create campaign for meetings inserted
            for( Meeting__c objMeeting : lstWebinarMeeting ){
                
                //check if capaign doesn't exists with same name
                if( !mapCampaignName_ID.containsKey(objMeeting.Name) ){
                    
                    lstCampaign.add( new Campaign(
                                        Name = objMeeting.Name,
                                        Description = objMeeting.Descritpion__c,
                                        StartDate = objMeeting.StartDate__c,
                                        EndDate = objMeeting.EndDate__c,
                                        Status = (objMeeting.Status__c == 'Planned' ? 'Planned' 
                                                                                    : (objMeeting.Status__c == 'End' ? 'Completed' 
                                                                                                                     : 'In Progress')),
                                        Type ='Zoom Webinar',
                                        Project__c = objMeeting.Project__c
                                    )
                    ); 
                }   
            }
            
            //insert campaign
            insert lstCampaign;
            
            // iterate over all Campaigns and collect them in map
            for( Campaign objCampaign : lstCampaign ){
                mapCampaignName_ID.put(objCampaign.Name,objCampaign.Id);
                
                lstCampaignMemberStatus.add( new CampaignMemberStatus(
                                                        CampaignId = objCampaign.Id, 
                                                        HasResponded=true,
                                                        Label = 'Attended',
                                                        SortOrder = 3
                                                    )
                                            );
                
                lstCampaignMemberStatus.add( new CampaignMemberStatus(
                                                        CampaignId = objCampaign.Id, 
                                                        HasResponded=true,
                                                        Label = 'Registered',
                                                        SortOrder = 4
                                                    )
                                            );
                lstCampaignMemberStatus.add( new CampaignMemberStatus(
                                                        CampaignId = objCampaign.Id, 
                                                        HasResponded=true,
                                                        Label = 'On-Demand',
                                                        SortOrder = 5
                                                    )
                                            );
            }
            
            insert lstCampaignMemberStatus;
            
            //update meeting with campaign 
            for( Meeting__c objMeeting : lstWebinarMeeting ){
                lstMeetingUpdate.add( 
                    new Meeting__c(
                            Id = objMeeting.Id,
                            campaign__c = mapCampaignName_ID.get( objMeeting.name )
                        ) 
                    );
            }
            update lstMeetingUpdate;
        }
    }
    
    public static void updateCampaign(List<Meeting__c> lstMeetingNew, Map<Id, Meeting__c> oldMap){
        
        List<Meeting__c> lstWebinarMeeting = new List<Meeting__c>();
        List<Campaign> lstCampaignUpdate = new List<Campaign>();
        
        //collect webinar meetings
        for( Meeting__c objMeeting : lstMeetingNew ){
            if(objMeeting.Type__c == 'Webinar' && objMeeting.Campaign__c != null 
            && (
                objMeeting.Name != oldMap.get(objMeeting.Id).Name
                ||
                objMeeting.status__c != oldMap.get(objMeeting.Id).status__c
                ||
                objMeeting.StartDate__c != oldMap.get(objMeeting.Id).StartDate__c
                ||
                objMeeting.EndDate__c != oldMap.get(objMeeting.Id).EndDate__c
                ||
                objMeeting.Descritpion__c != oldMap.get(objMeeting.Id).Descritpion__c
                )
            ){
                
                lstCampaignUpdate.add( new Campaign( Id = objMeeting.Campaign__c,
                                                        Name = objMeeting.Name,
                                                        StartDate = objMeeting.StartDate__c,
                                                        EndDate = objMeeting.EndDate__c,
                                                        Description = objMeeting.Descritpion__c,
                                                        Status = (objMeeting.Status__c == 'Planned' ? 'Planned' 
                                                                                                 : (objMeeting.Status__c == 'End' ? 'Completed' 
                                                                                                                                  : 'In Progress'))
                                                   ) 
                                     );
                
            }
        }
        
        update lstCampaignUpdate;
       }
    private static void deleteCampaignAndCampaignMember(Map<Id, Meeting__c> oldMap){ 
        set<Id> setCampaignIds = new set<Id>();
        for(Meeting__c objMeeting :oldMap.values()){
            if(objMeeting.Type__c =='Webinar'){
            setCampaignIds.add(objMeeting.Campaign__c);
            }
        }
        List<Campaign> lstCampaign = [Select id from Campaign Where Id IN:setCampaignIds];
        List<CampaignMember> lstCampaignMember = [Select id from CampaignMember Where CampaignId IN :setCampaignIds];
        if(!lstCampaign.isEmpty()){
            delete lstCampaignMember;
        }
        if(!lstCampaignMember.isEmpty()){
            delete lstCampaign;
        }
    }
}