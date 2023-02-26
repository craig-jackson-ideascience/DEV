public class VisaRequestTriggerHandler implements ITriggerHandler {
    public static void BeforeInsert(List<SObject> triggerNew){
        contactInsertIfEmailPresent((List<Visa_Request__c>) triggerNew);
        validateContactRegistration((List<Visa_Request__c>) triggerNew);
        updateVisaOrgpay((List<Visa_Request__c>) triggerNew, null);
    }
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        updateVisaOrgpay((List<Visa_Request__c>) newMap.values(),(Map<Id, Visa_Request__c>) oldMap);
        
    }    
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    } 
    
    public static void AfterInsert(Map<Id, SObject> newMap){
        //call onAfterInsert delete actions
        
        
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
    
    public static void validateContactRegistration(List<Visa_Request__c> triggerNew){
        List<Visa_Request__c> visaReq =  new List<Visa_Request__c>();
        Set<Id> contactSet = new Set<ID>();
        Set<Id> eventIds = new Set<Id>();
        for(Visa_Request__c vReq: triggerNew){
            visaReq.add(vReq);
            eventIds.add(vReq.Event__c);
            contactSet.add(vReq.Contact__c);
            
        }
        
        if(!contactSet.IsEmpty()){
            List<Event_Registrations__c> eventRegistrationList = [SELECT Contact__c,Event__c,Cvent_Registration_Status__c FROM Event_Registrations__c WHERE 
                                                                  Event__c IN :eventIds AND Cvent_Registration_Status__c != 'Cancelled' AND 
                                                                  Contact__c IN :contactSet];
            Map<Id,Set<Id>> eventContactSet =new  Map<Id,Set<Id>>();
            for(Event_Registrations__c er :eventRegistrationList){
                if(!eventContactSet.containsKey(er.Event__c)){
                    eventContactSet.put(er.Event__c,new Set<Id>());
                }
                eventContactSet.get(er.Event__c).add(er.Contact__c);
            }
            for(Visa_Request__c vReq:visaReq){
                if(eventContactSet.containsKey(vReq.Event__c) && eventContactSet.get(vReq.Event__c).contains(vReq.Contact__c)){
                    vReq.Registered__c = TRUE;
                }
                else{
                    vReq.Registered__c = FALSE;
                    vReq.addError('No event registration found');
                }
                
            }
            
        }
    }
    
    public static void contactInsertIfEmailPresent(List<Visa_Request__c> triggerNew){
        ContactInsertUtilityClass uc = new ContactInsertUtilityClass();
        uc.contactInsert(triggerNew);
    }
    
    public static void updateVisaOrgpay(List<Visa_Request__c> newMap,Map<Id, Visa_Request__c> oldMap){
        for(Visa_Request__c visaReq : newMap){
            System.debug('New MAps' +visaReq.Company_or_Organization__c);
            if(string.isNotBlank(visaReq.Company_or_Organization__c) && (visaReq.Accommodation_Paid_by__c == 'Delegate' || visaReq.Accommodation_Paid_by__c == 'Delegate\'s Company') && string.ISBLANK(visaReq.Org_paying_for_your_travel__c)){
                visaReq.Org_paying_for_your_travel__c = visaReq.Company_or_Organization__c;
                
            }
        }    
    }

}