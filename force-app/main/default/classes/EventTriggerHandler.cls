public class EventTriggerHandler implements ITriggerHandler{
    public static void BeforeInsert(List<SObject> triggerNew){
        
    }
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        
    }    
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    } 
    
    public static void AfterInsert(Map<Id, SObject> newMap){
        //call onAfterInsert  actions
        automateEMSCreation((Map<Id, Event__c>) newMap,null);
    }   
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){      
        updateEMS((Map<Id, Event__c>)newMap,(Map<Id, Event__c>) oldMap);
        automateEMSCreation((Map<Id, Event__c>) newMap,(Map<Id, Event__c>) oldMap);
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) {
    }
    
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after undelete actions
    } 
    
    public Boolean IsDisabled(){
        return false;
    }
    
    //THIS METHOD CREATES EMS RECORD AFTER INSERTION OF AN EVENT 
    public static void automateEMSCreation(Map<Id,Event__c> newMap,Map<Id,Event__c> oldMap){
        List<EMS__c> listOfEmsToBeInserted = new List<Ems__c>();
        Map<Id,Id> billFromIdByEventId = new Map<Id,Id>();
        List<EMS__c> existingEMSList = [SELECT Id,Event__c FROM EMS__c WHERE EVENT__c IN:newMap.keySet()];
        List<Event__c> events=[Select id,BillFromProject__r.name,BillFromProject__r.project_type__c,BillFromProject__r.parent_project__c from Event__c where id IN:newMap.keySet()];
        Set<Id> eventIds = new Set<Id>();
        for(EMS__c ems:existingEMSList){
            eventIds.add(ems.event__c);
        }
        String billFromAccountId = [SELECT ID,NAME FROM Project__c WHERE NAME='The Linux Foundation'][0].Id;
        Set<Id> billFromProjectIds = new Set<Id>();
        Map<Id,Id> accountIdByProjectId = new Map<Id,Id>();
        for(Event__c event:events){
            if(event.BillFromProject__c != null){                
                if(event.BillFromProject__r.project_type__c=='Project'){
                    billFromProjectIds.add(event.BillFromProject__r.parent_project__c);
                    billFromIdByEventId.put(event.Id,event.BillFromProject__r.parent_project__c);
                }else{
                     billFromProjectIds.add(event.BillFromProject__c);
                    billFromIdByEventId.put(event.Id,event.BillFromProject__c);
                }
            }
        }
        
        if(!billFromIdByEventId.IsEmpty()){
            accountIdByProjectId = getProjectIdsByName(billFromProjectIds);
        }
        for(Event__c event : newMap.values()){
            if(((event.Category__c=='Project Event'|| event.Category__c=='3rd Party Event' || event.Category__c == 'Non-LF Event' || event.Category__c == 'Webinar')  && 
            (oldMap == null || ( oldMap.get(event.id).Category__c != event.Category__c && !eventIds.contains(event.Id))))){
                String randomNumber = string.valueof(Math.abs(Crypto.getRandomLong())).substring(0, 4);
                String eventName = event.Name.length()>20 ? event.Name.substring(0,20) : event.Name;
                EMS__c ems = new EMS__c();
                ems.Name = eventName+' - Event Management Service';
                ems.Event__c = event.Id;
                ems.StartDate__c = event.Start_Date__c;
                ems.Bill_From__c = billFromAccountId;                
                ems.EMS_Number__c=eventName+' '+getDate(event)+randomNumber;
                ems.Product__c = '22';
                ems.EMS_Status__c = 'Not Started';                                                                                                                                            
                if(billFromIdByEventId.containsKey(event.Id) && accountIdByProjectId.containsKey(billFromIdByEventId.get(event.Id))){
                    ems.Bill_To_Account__c = accountIdByProjectId.get(billFromIdByEventId.get(event.Id));
                }                                               
                listOfEmsToBeInserted.add(ems);   
            }
        }
        if(!listOfEmsToBeInserted.isEmpty()){
            insert listOfEmsToBeInserted;
        }
    }
    
    private static String getDate(Event__c event){
        String dateString;
        if(event.Start_Date__c != null){
            dateString = String.valueOf(event.Start_Date__c.year()).substring(2,4)+String.valueOf(event.Start_Date__c.month());  
        }else{
            dateString =String.valueOf(Date.today().year()).substring(2,4)+String.valueOf(Date.today().month());
        }
        return dateString;
    }
    
    private static Map<Id,Id> getProjectIdsByName(Set<Id> projectIDs){
        Map<Id,Id> accountIdByProjectId = new Map<Id,Id>();
        Map<String,Id> projectNameByIds = new Map<String,Id>();
        for(Project__c project : [SELECT ID,Name FROM Project__c WHERE ID IN : projectIDs]){
            projectNameByIds.put(project.Name.toLowercase(),project.Id);
        }
        System.debug('projectNameByIds==>' + projectNameByIds);
        if(!projectNameByIds.isEmpty()){
            for(Account account : [SELECT ID,Name FROM Account WHERE RecordType.Name='Project Account' AND Name =: projectNameByIds.keyset()]){
                if(projectNameByIds.containsKey(account.Name.toLowercase()))
                    accountIdByProjectId.put(projectNameByIds.get(account.Name.toLowercase()),account.Id);
            }
        }
        System.debug('AccountId by ProjectId==>' + accountIdByProjectId);
        return accountIdByProjectId;
    }
    
    public static void updateEMS(Map<Id,Event__c> newEvents,Map<Id,Event__c> oldEventMap){
        Map<Id,Event__c> updatedEvents = new Map<Id,Event__c>();
        List<EMS__c> lstEMS = new List<EMS__c>();
        List<EMS__c> newlstEMS = new List<EMS__c>();
       	Map<Id,Id> billFromIdByEventId = new Map<Id,Id>();
        Set<Id> eventIds = new Set<Id>();
        //run only when bill from has changed
        for(Id eventId : newEvents.keyset()){
            if(newEvents.get(eventId).BillFromProject__c != null && newEvents.get(eventId).BillFromProject__c !=oldEventMap.get(eventId).BillFromProject__c){
                eventIds.add(eventId);
            }
        }
        //get All events and related EMS records
        if(!eventIds.IsEmpty()){
            List<Event__c> lstEvent=[Select id,BillFromProject__r.name,BillFromProject__r.project_type__c,BillFromProject__r.parent_project__c,
                                     (SELECT Id,Bill_To_Account__c FROM EMS__r)
                                     from Event__c where id IN:eventIds];
            Set<Id> billFromProjectIds = new Set<Id>();
            Map<Id,Id> accountIdByProjectId = new Map<Id,Id>();
            for(Event__c event:lstEvent){
                if(event.BillFromProject__c != null){                
                    if(event.BillFromProject__r.project_type__c=='Project'){
                        billFromProjectIds.add(event.BillFromProject__r.parent_project__c);
                        billFromIdByEventId.put(event.Id,event.BillFromProject__r.parent_project__c);
                    }else{
                        billFromProjectIds.add(event.BillFromProject__c);
                        billFromIdByEventId.put(event.Id,event.BillFromProject__c);
                    }
                }
            }
            
            if(!billFromIdByEventId.IsEmpty()){
                accountIdByProjectId = getProjectIdsByName(billFromProjectIds);
            }
            
            for(Event__c event: lstEvent){
                if(!event.EMS__r.IsEmpty()){
                    for(EMS__c ems :event.EMS__r){
                        if(billFromIdByEventId.containsKey(event.Id) && accountIdByProjectId.containsKey(billFromIdByEventId.get(event.Id))){
                            ems.Bill_To_Account__c = accountIdByProjectId.get(billFromIdByEventId.get(event.Id));
                            newlstEMS.add(ems);
                        } 
                        
                    }
                }
            }
            if(!newlstEMS.IsEmpty()){
                update newlstEMS;
            }        
        } 
    }
    
}