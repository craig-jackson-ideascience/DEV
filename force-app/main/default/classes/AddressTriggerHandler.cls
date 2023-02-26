/********************************************************
* Created by: Pratik D 
* Created Date: 28 - APR - 2020.
* Description: AddressTriggerHandler
* JIRA - SFDC-1230 - validateAddressBeforeDelete() - Restrict User from deleting address if any associated Opportunity is Closed Won
********************************************************/

public class AddressTriggerHandler implements ITriggerHandler{
    public static void BeforeInsert(List<SObject> triggerNew){
        
    }
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        
    }   
    public static void BeforeDelete(Map<Id, Sobject> oldMap){
        validateAddressBeforeDelete((Map<Id, Address__c>)oldMap);
    } 
    
    public static void AfterInsert(Map<Id, SObject> newMap){
        
    }   
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){
        
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap){
    }
    
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap){
        
    } 
    
    public Boolean IsDisabled(){
        return false;
    }
    
    public static void validateAddressBeforeDelete(Map<Id,Address__c> oldMap){
        
        Set<Id> setAddressId = oldMap.keySet();
        Set<Id> setAddressForClosedWonOpp = new Set<Id>();
        
        for(Opportunity objOpportunity : [ SELECT ID, Bill_To_Address__c
                                        FROM Opportunity 
                                        WHERE Bill_To_Address__c IN: setAddressId 
                                        AND IsWon = TRUE 
                                        ] ){
            setAddressForClosedWonOpp.add(objOpportunity.Bill_To_Address__c);
        }
        
        if(setAddressForClosedWonOpp.size() > 0){
            for(Address__c objAddress : oldMap.values()){
                if(setAddressForClosedWonOpp.contains(objAddress.Id))
                    objAddress.addError('You can not delete this Address, it is associated with one or more Closed Won Opportunities.');
            }
        }
    }
    
}