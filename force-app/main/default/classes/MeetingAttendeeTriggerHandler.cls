/********************************************************
* Created by: Pratik D
* Created Date: 18/MAY/2020.
* Description: Create campaign member based on meeting attendee
********************************************************/

public class MeetingAttendeeTriggerHandler implements ITriggerHandler{
    public static void BeforeInsert(List<SObject> triggerNew){
        
    }
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        
    }    
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    } 
    
    public static void AfterInsert(Map<Id, SObject> newMap){
        createCampaignmember((Map<Id, Meeting_Attendees__c>) newMap);
        makeAlternateEmailPrimary((Map<Id, Meeting_Attendees__c>) newMap);
    }   
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){ 
        updateCampaignmember((Map<Id, Meeting_Attendees__c>) newMap, (Map<Id, Meeting_Attendees__c>) oldMap);
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) {
    }
    
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after undelete actions
    } 
    
    public Boolean IsDisabled(){
        return false;
    }
    Public static void makeAlternateEmailPrimary(Map<Id, Meeting_Attendees__c> newMap){
        set<Id> setAlternateEmailId = new set<Id>();
        List<Alternate_Email__c> lstAlternateEmail = new List<Alternate_Email__c>();
        map<ID,Alternate_Email__c> mapAlternateEmailUpdate = new map<Id,Alternate_Email__c>();
        List<Meeting_Attendees__c> lstMeetingAttendees = new List<Meeting_Attendees__c>();
        lstMeetingAttendees =[Select id,Meeting__r.type__c,Alternate_Email__c from Meeting_Attendees__c where id IN :newMap.keyset() AND Meeting__r.type__c ='Webinar'];
        for(Meeting_Attendees__c objMeetingAttendees : lstMeetingAttendees){
                setAlternateEmailId.add(objMeetingAttendees.Alternate_Email__c);
        }
        if(setAlternateEmailId !=null){
            lstAlternateEmail = [Select id,Primary_Email__c from Alternate_Email__c where id IN:setAlternateEmailId AND Primary_Email__c != true];
            for(Alternate_Email__c objAlternateEmail : lstAlternateEmail){
                    objAlternateEmail.Primary_Email__c = true;
                    mapAlternateEmailUpdate.put(objAlternateEmail.id, objAlternateEmail);
            }
            update mapAlternateEmailUpdate.values();
        }
    }
   public static void createCampaignmember(Map<Id, Meeting_Attendees__c> newMap){
    
        //Variable Decaration
        set<Id> setMeetingId = new set<Id>();
        List<Meeting__c> lstMeeting = new List<Meeting__c>();
       	List<Meeting__c> lstMeetingWoCampaign = new List<Meeting__c>();
        List<Campaign> lstCampaign = new List<Campaign>();
        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
        set<String> setCampaignName = new set<String>();
        map<String, Id> mapCampaignName_Id = new map<String, Id>(); 
        Map<Id, Id> mapMeetingId_CampaignId = new Map<Id, Id>();
        List<Meeting_Attendees__c> lstMeetingAttendeeUpdate = new List<Meeting_Attendees__c>();
        Integer i=0;
        
        //For loop for storing ids of meeting
        for(Meeting_Attendees__c objMeetingAttendees : newMap.Values()){
            setMeetingId.add(objMeetingAttendees.Meeting__c);     
        }
        
        lstMeetingWoCampaign = [SELECT Id,Name,Descritpion__c,Type__c,StartDate__c,EndDate__c,Status__c,Project__c,Campaign__c FROM Meeting__c WHERE id IN:setMeetingId AND Type__c = 'Webinar' AND Campaign__c= Null];
        
        if(!lstMeetingWoCampaign.isEmpty()){
            MeetingTriggerHandler.createCampaign(lstMeetingWoCampaign);
        }
        
        lstMeeting = [SELECT Id, Campaign__c FROM Meeting__c WHERE id IN:setMeetingId AND Type__c = 'Webinar'];
        
        for(Meeting__c objMeeting : lstMeeting){
            mapMeetingId_CampaignId.put(objMeeting.id, objMeeting.Campaign__c);
        }
        
        if(!mapMeetingId_CampaignId.isEmpty())
        {
            for(Meeting_Attendees__c objMeetingAttendees :[SELECT Meeting__c,Email_Opt_In__c,
                                                          Status__c,Contact__c,Lead__c,Lead__r.isConverted,Lead__r.ConvertedContactId,Meeting__r.EndDate__c,Meeting__r.EndTime__c
                                                          FROM Meeting_Attendees__c WHERE Id IN: newMap.keyset()] ){
                                                              //datetime dt = objMeetingAttendees.Meeting__r.EndDate__c;
                                                              //time dt1 = objMeetingAttendees.Meeting__r.EndTime__c;
                                                              //string EndDateTime = dt.formatGMT('yyyy-MM-dd') +' '+ string.valueOf(dt1);
                //system.debug('DateTime.valueOfGmt(EndDateTime)-->'+DateTime.valueOfGmt(EndDateTime));
                //system.debug('system.now()-->'+system.now());
                datetime EndDateTime = DateTime.newInstance(objMeetingAttendees.Meeting__r.EndDate__c, objMeetingAttendees.Meeting__r.EndTime__c);
                                                             
                if(EndDateTime > system.now()){
                lstCampaignMember.add(
                    new CampaignMember(
                        CampaignId = mapMeetingId_CampaignId.get(objMeetingAttendees.Meeting__c),
                        Email_Opt_In__c = objMeetingAttendees.Email_Opt_In__c,
                        Status = objMeetingAttendees.Status__c,
                        ContactId = ( objMeetingAttendees.Contact__c != null 
                                        ? objMeetingAttendees.Contact__c 
                                        : ( (objMeetingAttendees.Lead__r.isConverted  
                                            ? objMeetingAttendees.Lead__r.ConvertedContactId  
                                            : null 
                                            ) ) ),
                        //Modified by Pratik D - 1-Dec-2020
                        LeadId = ( (objMeetingAttendees.Lead__c == null || objMeetingAttendees.Lead__r.isConverted)
                                        ? null
                                        : objMeetingAttendees.Lead__c ))
                    
                );
                }else{
                    system.debug('Inside else');
                   lstCampaignMember.add(
                    new CampaignMember(
                        CampaignId = mapMeetingId_CampaignId.get(objMeetingAttendees.Meeting__c),
                        Email_Opt_In__c = objMeetingAttendees.Email_Opt_In__c,
                        Status = 'On-Demand',
                        ContactId = ( objMeetingAttendees.Contact__c != null 
                                        ? objMeetingAttendees.Contact__c 
                                        : ( (objMeetingAttendees.Lead__r.isConverted  
                                            ? objMeetingAttendees.Lead__r.ConvertedContactId  
                                            : null 
                                            ) ) ),
                        //Modified by Pratik D - 1-Dec-2020
                        LeadId = ( (objMeetingAttendees.Lead__c == null || objMeetingAttendees.Lead__r.isConverted)
                                        ? null
                                        : objMeetingAttendees.Lead__c ))
                    
                ); 
                }
            }  
            
            Database.SaveResult[] srList = Database.insert(lstCampaignMember, false); 
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted ID: ' + sr.getId());
                    lstMeetingAttendeeUpdate.add( 
                        new Meeting_Attendees__c(
                                Id = newMap.values()[i].Id,
                                Campaign_Member_Id__c = sr.getId()
                            )
                        );
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage() + ' : '+ err.getFields());
                    }
                }
                i++;
            }
            
            update lstMeetingAttendeeUpdate;
        }
        
    }
    
    //update campaign member status if meeting attendee status changed
    public static void updateCampaignmember(Map<Id, Meeting_Attendees__c> newMap, Map<Id, Meeting_Attendees__c> oldMap){
        
        List<CampaignMember> lstCampaignMemberUpdate = new List<CampaignMember>();
        
        for(Meeting_Attendees__c objMeetingAttendees : newMap.values()){
            //check if Meeting_Attendees status changed
            if( (objMeetingAttendees.Status__c != oldMap.get(objMeetingAttendees.Id).Status__c 
                 ||
                objMeetingAttendees.Email_Opt_In__c != oldMap.get(objMeetingAttendees.Id).Email_Opt_In__c 
                )
            && objMeetingAttendees.Campaign_Member_Id__c != null){
                lstCampaignMemberUpdate.add(
                    new CampaignMember(
                        id=objMeetingAttendees.Campaign_Member_Id__c,
                        Status = objMeetingAttendees.Status__c,
                        Email_Opt_In__c = objMeetingAttendees.Email_Opt_In__c
                    )
                );
            }
        }
        update lstCampaignMemberUpdate;
    }
}