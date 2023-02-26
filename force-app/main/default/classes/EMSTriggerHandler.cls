public Class EMSTriggerHandler implements ITriggerHandler{
    
    public static void BeforeInsert(List<SObject> triggerNew){
        
    }

    public void beforeUpdate(Map<id,SObject> newAccount,Map<id,SObject> oldAccount){

    }
    
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {

    } 
    
    public static void afterInsert(Map<Id, SObject> newMap){
        for (EMS__c ems : (List<EMS__c>)newMap.values()) {
            if (ems.EMS_Number__c != null) {
                System.enqueueJob(new EMSCodeHelper(ems.Id));
            }
        }
    }

    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){
        Map<Id, EMS__c> oldEMSMap = (Map<Id, EMS__c>)oldMap;
        for (EMS__c ems : (List<EMS__c>)newMap.values()) {
            if (oldMap.get(ems.Id) != null && ems.EMS_Number__c != null && oldEMSMap.get(ems.Id).EMS_Number__c == null) {
                System.enqueueJob(new EMSCodeHelper(ems.Id));
             }
        }
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) {

    }
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after undelete actions
    } 
    
    public Boolean IsDisabled(){
        return false;
    }
    
   
    
}