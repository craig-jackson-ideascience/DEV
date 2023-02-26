/**
ProjectBenchmarkInput trigger handler
@author (c) Idea Science  2023
*
* History
* *******
* Date       By             Ticket      Change
* *********  *************  **********  **************************************
* 17FEB2023	 Craig Jackson	LF240-271   Initial Version
*/
public with sharing class ProjectBenchmarkInputTriggerHandler implements ITriggerHandler {

    public void beforeDelete(Map<Id, SObject> oldMap) {
        return;
    }

    //This method will handle before insert method
    public void beforeInsert(List<SObject> newItems) {
        createName((List<ProjectBenchmarkInput__c>) newItems);
    }

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        List<ProjectBenchmarkInput__c> recLst = new List<ProjectBenchmarkInput__c>();

        // Check if Project and/or Membership Level has changed
        for (Id recId : newMap.keySet()) {
            ProjectBenchmarkInput__c newRec = (ProjectBenchmarkInput__c) newMap.get(recId);
            ProjectBenchmarkInput__c oldRec = (ProjectBenchmarkInput__c) oldMap.get(recId);
            if ((newRec.Project__c            != oldRec.Project__c) || 
                (newRec.BenchmarkInputType__c != oldRec.BenchmarkInputType__c)|| 
                (newRec.Name                  != oldRec.Name)) {
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
    private static void createName(List<ProjectBenchmarkInput__c> newItems){
        List<Id> projectIds = new List<Id>();

        // Get List of Projects
        for(ProjectBenchmarkInput__c prgMemBMark : newItems){
            if (!projectIds.contains(prgMemBMark.Project__c)) {
                projectIds.add(prgMemBMark.Project__c);
            }
        }

        // Select Projects
        Map<Id, Project__c> prjIdMap = new Map<Id, Project__c>([SELECT Id, Name FROM Project__c WHERE Id IN :projectIds]);

        // Build Name field
        for(ProjectBenchmarkInput__c prgMemBMark : newItems) {
            prgMemBMark.Name = prjIdMap.get(prgMemBMark.Project__c).Name + ' - ' + prgMemBMark.BenchmarkInputType__c;
        }
    }
}