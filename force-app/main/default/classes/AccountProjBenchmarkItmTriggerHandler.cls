/**
AccountProjectBenchmarkItem trigger handler
@author (c) Idea Science  2023
*
* History
* *******
* Date       By             Ticket      Change
* *********  *************  **********  **************************************
* 21FEB2023	 Craig Jackson	LF240-271   Initial Version
*/
public with sharing class AccountProjBenchmarkItmTriggerHandler implements ITriggerHandler {

    public void beforeDelete(Map<Id, SObject> oldMap) {
        return;
    }

    //This method will handle before insert method
    public void beforeInsert(List<SObject> newItems) {
        createName((List<AccountProjectBenchmarkItem__c>) newItems);
    }

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        List<AccountProjectBenchmarkItem__c> recLst = new List<AccountProjectBenchmarkItem__c>();

        // Check if Project and/or Membership Level has changed
        for (Id recId : newMap.keySet()) {
            AccountProjectBenchmarkItem__c newRec = (AccountProjectBenchmarkItem__c) newMap.get(recId);
            AccountProjectBenchmarkItem__c oldRec = (AccountProjectBenchmarkItem__c) oldMap.get(recId);
            if ((newRec.AccountProjectBenchmark__c != oldRec.AccountProjectBenchmark__c) || 
                (newRec.BenchmarkType__c           != oldRec.BenchmarkType__c)  || 
                (newRec.Name                       != oldRec.Name)) {
                recLst.add(newRec);
            }

            // Update Name if Needed
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
    ** createName - Update the name as AccountProjectBenchmark__c Name - Benchmark Type
    */
    private static void createName(List<AccountProjectBenchmarkItem__c> newItems){
        List<Id> apbIds = new List<Id>();

        // Get List of Projects
        for(AccountProjectBenchmarkItem__c prgMemBMark : newItems){
            if (!apbIds.contains(prgMemBMark.AccountProjectBenchmark__c)) {
                apbIds.add(prgMemBMark.AccountProjectBenchmark__c);
            }
        }

        // Select Projects
        Map<Id, AccountProjectBenchmark__c> apbIdMap = new Map<Id, AccountProjectBenchmark__c>([SELECT Id, Name FROM AccountProjectBenchmark__c WHERE Id IN :apbIds]);

        // Build Name field
        for(AccountProjectBenchmarkItem__c acntPrjBMItem : newItems) {
            acntPrjBMItem.Name = apbIdMap.get(acntPrjBMItem.AccountProjectBenchmark__c).Name + ' - ' + acntPrjBMItem.BenchmarkType__c;
        }
    }
}