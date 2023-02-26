public class HotelCommissionsTriggerHandler implements ITriggerHandler {
    public static void BeforeInsert(List<SObject> triggerNew){
        populateDefaultNSFields((List<Hotel_Commissions__c>) triggerNew);
    }
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {}
    
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {} 
    
    public static void AfterInsert(Map<Id, SObject> newMap){}   
    
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){}
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) {}
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {} 
    
    public Boolean IsDisabled(){
        return false;
    }
    
    public static void populateDefaultNSFields(List<Hotel_Commissions__c> triggerNew){
        for(Hotel_Commissions__c hotelCommissions: triggerNew){
            if(hotelCommissions.NS_Department__c == null){
                hotelCommissions.NS_Department__c = '2';
            }
            if(hotelCommissions.NS_Deferred_Revenue_Account__c == null){
                hotelCommissions.NS_Deferred_Revenue_Account__c = '284';
            }
            if(hotelCommissions.NS_Income_GL_Account__c == null){
                hotelCommissions.NS_Income_GL_Account__c = '302';
            }
        }
    } 
}