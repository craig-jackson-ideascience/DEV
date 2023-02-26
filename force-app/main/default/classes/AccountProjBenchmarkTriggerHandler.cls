/**
AccountProjectBenchmark trigger handler
@author (c) Idea Science  2023
*
* History
* *******
* Date       By             Ticket      Change
* *********  *************  **********  **************************************
* 21FEB2023	 Craig Jackson	LF240-271   Initial Version
*/
public with sharing class AccountProjBenchmarkTriggerHandler implements ITriggerHandler {

    public void beforeDelete(Map<Id, SObject> oldMap) {
        return;
    }

    //This method will handle before insert method
    public void beforeInsert(List<SObject> newItems) {
        createName((List<AccountProjectBenchmark__c>) newItems);
    }

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        List<AccountProjectBenchmark__c> recLst = new List<AccountProjectBenchmark__c>();

        // Check if Project and/or Membership Level has changed
        for (Id recId : newMap.keySet()) {
            AccountProjectBenchmark__c newRec = (AccountProjectBenchmark__c) newMap.get(recId);
            AccountProjectBenchmark__c oldRec = (AccountProjectBenchmark__c) oldMap.get(recId);
            if ((newRec.Account__c != oldRec.Account__c) || 
                (newRec.Project__c != oldRec.Project__c) || 
                (newRec.Name       != oldRec.Name)) {
                recLst.add(newRec);
            }

            if (recLst.size() > 0) {
                createName(recLst);
            }
        }
        return;
    }

    public void afterInsert(Map<Id, SObject> newMap) {
        return;
    }

    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        return;
    }

    public void afterDelete(Map<Id, SObject> oldMap) {
        return;
    }

    public void afterUndelete(Map<Id, SObject> newMap) {
        return;
    }

    public Boolean isDisabled() {
        return false;
    }

    /*
    ** createName - Update the name as Project Name - Membership Level
    */
    private static void createName(List<AccountProjectBenchmark__c> newItems){
        List<Id> acntIds = new List<Id>();
        List<Id> prjIds  = new List<Id>();

        // Get List of Accounts and Projects Used
        for(AccountProjectBenchmark__c apBMark : newItems){
            if (!acntIds.contains(apBMark.Account__c)) {
                acntIds.add(apBMark.Account__c);
            }
            if (!prjIds.contains(apBMark.Project__c)) {
                prjIds.add(apBMark.Project__c);
            }
        }

        // Get Names
        Map<Id, Account> acntIdMap    = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :acntIds]);
        Map<Id, Project__c> projIdMap = new Map<Id, Project__c>([SELECT Id, Name FROM Project__c WHERE Id IN :prjIds]);

        // Build Name field
        for(AccountProjectBenchmark__c acntPrjBMark : newItems) {
            acntPrjBMark.Name = projIdMap.get(acntPrjBMark.Project__c).Name + ' - ' + acntIdMap.get(acntPrjBMark.Account__c).Name;
        }
    }
}