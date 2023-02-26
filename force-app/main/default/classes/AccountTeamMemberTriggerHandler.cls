public class AccountTeamMemberTriggerHandler implements ITriggerHandler {


    //This will handle before delete event
    public void beforeDelete(Map<Id, SObject> oldMap) {

    }

    //This method will handle before insert method
    public void beforeInsert(List<SObject> newItems) {        
        
    }

    //This method will handle before update event
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {

    }

    public void afterInsert(Map<Id, SObject> newMap) {
        UpdateTeamMemberOnOLI((Map<Id, AccountTeamMember>) newMap, null);
    }

    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
		UpdateTeamMemberOnOLI((Map<Id, AccountTeamMember>) newMap, (Map<Id, AccountTeamMember>) oldMap);
    }

    public void afterDelete(Map<Id, SObject> oldMap) {
    }

    public void afterUndelete(Map<Id, SObject> newMap) {

    }

    public Boolean IsDisabled() {
        return false;
    }
    public static void UpdateTeamMemberOnOLI(Map<Id, AccountTeamMember> newMap, Map<Id, AccountTeamMember> oldMap){
        set<Id> AccountIds = new set<Id>();
        List<OpportunityLineItem> lstOLI = new List<OpportunityLineItem>();
        Map<id,AccountTeamMember> mapATM = new map<id,AccountTeamMember>();
        map<string,Team_Member_for_Project__c> mapTROLI = new map<string,Team_Member_for_Project__c>();
        List<AccountTeamMember> lstATM = [Select id,AccountId,User.Name,TeamMemberRole From AccountTeamMember Where Id IN:newMap.keySet()];
        for(AccountTeamMember objATM : lstATM){
            AccountIds.add(objATM.AccountId);
            mapATM.put(objATM.AccountId,objATM);
        }
        for(Team_Member_for_Project__c objTROLI : [Select id,Name,Role__c from Team_Member_for_Project__c]){
            mapTROLI.put(objTROLI.Name,objTROLI);
        }
        for(OpportunityLineItem objOLI:[Select id,Projects__r.id,Opportunity.AccountId,Account_Team_Member__c,Opportunity.Type from OpportunityLineItem Where Opportunity.AccountId IN:AccountIds AND Opportunity.Type ='New Business' AND Opportunity.isClosed =false]){
            Team_Member_for_Project__c objTROLI = mapTROLI.get(objOLI.Projects__r.id);
            AccountTeamMember objATM = mapATM.get(objOLI.Opportunity.AccountId);
            if(objTROLI != null && objATM !=Null){
               if(objOLI.Projects__r.id == objTROLI.Name && objATM.TeamMemberRole.contains(objTROLI.role__c)){
                        system.debug('Inside');
                        objOLI.Account_Team_Member__c = objATM.User.Name; 
                        lstOLI.add(objOLI);
                    }
            }
        }
        if(!lstOLI.isEmpty()){
         system.debug('lstOLI-->'+lstOLI);
        update lstOLI;
        }
    }
}