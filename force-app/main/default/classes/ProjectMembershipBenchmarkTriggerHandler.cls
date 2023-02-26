/**
ProjectMembershipBenchmark trigger handler
@author (c) Idea Science  2023
*
* History
* *******
* Date       By             Ticket      Change
* *********  *************  **********  **************************************
* 17FEB2023  Craig Jackson  LF240-271   Initial Version
*/
public with sharing class ProjectMembershipBenchmarkTriggerHandler implements ITriggerHandler {

    public void beforeDelete(Map<Id, SObject> oldMap) {
        return;
    }

    //This method will handle before insert method
    public void beforeInsert(List<SObject> newItems) {
        createName((List<ProjectMembershipBenchmark__c>) newItems);
    }

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        List<ProjectMembershipBenchmark__c> recLst = new List<ProjectMembershipBenchmark__c>();

        // Check if Project and/or Membership Level has changed
        for (Id recId : newMap.keySet()) {
            ProjectMembershipBenchmark__c newRec = (ProjectMembershipBenchmark__c) newMap.get(recId);
            ProjectMembershipBenchmark__c oldRec = (ProjectMembershipBenchmark__c) oldMap.get(recId);
            if ((newRec.Project__c         != oldRec.Project__c) || 
                (newRec.MembershipLevel__c != oldRec.MembershipLevel__c) || 
                (newRec.Name               != oldRec.Name)) {
                recLst.add(newRec);
            }

            if (recLst.size() > 0) {
                createName(recLst);
            }
        }
        return;
    }

    public void afterInsert(Map<Id, SObject> newMap) {
        // Create default Project Benchmark Inputs Records
        createDefaultBenchmarkInputs((List<ProjectMembershipBenchmark__c>) newMap.values());
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
    private static void createName(List<ProjectMembershipBenchmark__c> newItems){
        List<Id> projectIds = new List<Id>();

        // Get List of Projects
        for(ProjectMembershipBenchmark__c prgMemBMark : newItems){
            if (!projectIds.contains(prgMemBMark.Project__c)) {
                projectIds.add(prgMemBMark.Project__c);
            }
        }

        // Select Projects
        Map<Id, Project__c> prjIdMap = new Map<Id, Project__c>([SELECT Id, Name FROM Project__c WHERE Id IN :projectIds]);

        // Build Name field
        for(ProjectMembershipBenchmark__c prgMemBMark : newItems) {
            prgMemBMark.Name = prjIdMap.get(prgMemBMark.Project__c).Name + ' - ' + prgMemBMark.MembershipLevel__c;
        }
    }

    /*
    ** createName - Update the name as Project Name - Membership Level
    */
    private static void createDefaultBenchmarkInputs(List<ProjectMembershipBenchmark__c> newItems){
        // Initialise Vars
        List<ProjectBenchmarkInput__c> prjBMInputs = new List<ProjectBenchmarkInput__c>();
        List<Id> pmbPrjIds = new List<Id>();
        List<Id> pbiPrjIds = new List<Id>();

        // Get List of Projects
        for(ProjectMembershipBenchmark__c prgMemBMark : newItems){
            if (!pmbPrjIds.contains(prgMemBMark.Project__c)) {
                pmbPrjIds.add(prgMemBMark.Project__c);
            }
        }

        // Select any Existing ProjectBenchmarkInput__c records
        for (ProjectBenchmarkInput__c pbi : [SELECT Project__c FROM ProjectBenchmarkInput__c WHERE Project__c IN :pmbPrjIds]) {
            if (!pbiPrjIds.contains(pbi.Project__c)) {
                pbiPrjIds.add(pbi.Project__c);
            }
        }

        // Get List of BenchmarkInputType Picklists
        Schema.DescribeFieldResult fieldResult = ProjectBenchmarkInput__c.BenchmarkInputType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        // Loop through new ProjectMembershipBenchmark__c records
        for (ProjectMembershipBenchmark__c prgMemBMark : newItems) {
            // Check if there are already records for the project
            if (!pbiPrjIds.contains(prgMemBMark.Project__c)) {
                pbiPrjIds.add(prgMemBMark.Project__c);
                // Add an entry for each BenchmarkInputType picklist
                for (Schema.PicklistEntry pickListVal : ple) {
                    ProjectBenchmarkInput__c prjBMInput = new ProjectBenchmarkInput__c(
                        Name = 'overwriten'
                        , Project__c              = prgMemBMark.Project__c
                        , BenchmarkInputType__c   = pickListVal.getValue()
                        , ScoreMultiplier__c      = 1
                        , UseInEvntBenchmark__c   = false
                        , UseInMemberBenchmark__c = false
                        , UseInTandCBenchmark__c  = false
                    );
                    prjBMInputs.add(prjBMInput);
                }
            }
        }

        // Add Project Benchmark Inputs
        if (prjBMInputs.size() > 0) {
            insert prjBMInputs;
        }
    }
}