public class TaskTriggerHandler implements ITriggerHandler{
public static void BeforeInsert(List<SObject> triggerNew){
                CheckboxCheckIfTypeContactOrLead((List<Task>) triggerNew);
    }
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        updateCheckboxCheckIfTypeContactOrLead((Map<Id, task>) newMap);
    }    
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    } 
    
    public static void AfterInsert(Map<Id, SObject> newMap){
    }   
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){ 
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) {
    }
    
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after undelete actions
    } 
    
    public Boolean IsDisabled(){
        return false;
    }
    Public static void updateCheckboxCheckIfTypeContactOrLead(Map<Id, task> newMap){
        for(Task objTask : newMap.values()){
            if(objTask.Description != null && objTask.WhoId != null){
            if(objTask.Check_if_type_Contact_or_Lead__c == False && objTask.Description.contains('Insight provided by Mixmax') && (((String)objTask.WhoId).startsWith('003') || ((String)objTask.WhoId).startsWith('00Q'))){
                objTask.Check_if_type_Contact_or_Lead__c =true;
            }
        } 
        }
    }
    Public static void CheckboxCheckIfTypeContactOrLead(List<Task> lstTask){
        system.debug('lstTask-->'+lstTask);
        for(Task objTask : lstTask){
            if(objTask.Description != null && objTask.WhoId != null){
            if(objTask.Check_if_type_Contact_or_Lead__c == False && objTask.Description.contains('Insight provided by Mixmax') && (((String)objTask.WhoId).startsWith('003') || ((String)objTask.WhoId).startsWith('00Q'))){
                objTask.Check_if_type_Contact_or_Lead__c =true;
            }
            }
        } 
    }
}