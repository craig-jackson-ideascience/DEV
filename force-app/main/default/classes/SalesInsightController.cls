/**
LWC Controller for SalesInsight Components
@author (c) Idea Science  2023
*
* History
* *******
* Date       By             Ticket      Change
* *********  *************  **********  **************************************
* 23FEB2023  Craig Jackson  LF240-269   Initial Version
*/
public with sharing class SalesInsightController {

    //
    // hasConfig
    // Checks if a Sales Insight Configuration exists for a project
    //
    @AuraEnabled(cacheable=false)
    public static Boolean hasConfig(Id projectId) {
        // Look for ProjectMembershipBenchmark__c records for the Project
        List<ProjectMembershipBenchmark__c> pmbLst = [SELECT Id FROM ProjectMembershipBenchmark__c WHERE project__c = :projectId];

        // Select true/false depending if records found
        return(pmbLst.size() > 0);
    }

    //
    // getConfiguredProjectLst
    // Returns Unique list  of projects that currently have a benchmark configuration
    // First Map will be None
    //
    @AuraEnabled(cacheable=false)
    public static List<Project__c> getConfiguredProjectLst() {
        // Initialise map
        List<Project__c> prjLst = new List<Project__c>();

        // Put in the No Project records
        prjLst.add(new Project__c(id=null, Name='--None--'));

        // Get unique list of Projects using Group By
        for (AggregateResult ar : [SELECT Project__c, Project__r.Name ProjectName FROM ProjectMembershipBenchmark__c GROUP BY Project__c, Project__r.Name ORDER BY Project__r.Name]) {
            prjLst.add(new Project__c(id=(Id)ar.get('Project__c'), Name=(String)ar.get('ProjectName')));
        }

        // Return Map
        return(prjLst);
    }

    //
    // createSalesInsigtConfigForProject
    // Creates a Sales Insight Configuration for a project from 
    //
    @AuraEnabled(cacheable=false)
    public static void createSalesInsigtConfigForProject(Id projectId, Boolean overwriteExistingConfig, Id cloneFromProjectId) {

        // Make sure valid Project Passed
        List<Project__c> prjLst = [SELECT Id FROM Project__c WHERE Id = :projectId];
        if (prjLst.size() == 0) {
            throw new AuraHandledException('Project Does Not Exist');
        }

        // Look for Existing ProjectBenchmarkInputs__c Entries
        List<ProjectBenchmarkInput__c> pbiLst = [SELECT Id FROM ProjectBenchmarkInput__c WHERE project__c = :projectId];
        if (pbiLst.size() > 0) {
            if (overwriteExistingConfig) {
                delete pbiLst;
            } else {
                throw new AuraHandledException('Project Benchmark Input Records Already Exist for the Project');
            }
        }

        // Look for Existing ProjectMembershipBenchmark__c Entries
        List<ProjectMembershipBenchmark__c> pmbLst = [SELECT Id FROM ProjectMembershipBenchmark__c WHERE project__c = :projectId];
        if (pmbLst.size() > 0) {
            if (overwriteExistingConfig) {
                delete pmbLst;
            } else {
                throw new AuraHandledException('Project Membership Benchmark Records Already Exist for the Project');
            }
        }

        // Create Configuration
        if (cloneFromProjectId == null) {
            // Create Configuration using Metadata
            createConfigUsingMetadata(projectId);
        } else {
            // Clone Configuration
            createConfigUsingExisting(projectId, cloneFromProjectId);
        }
    }

    //
    // Helper Functions
    //

    //
    // createConfigUsingMetadata
    // Creates a Sales Insight Configuration for a project from MEtadata
    //
    private static void createConfigUsingMetadata(Id projectId) {

        // Create the ProjectMembershipBenchmark__c records
        // and the ProjectMembershipBenchmark__c trigger will create the Inputs

        // Get List of MembershipLevel__c Picklists
        Schema.DescribeFieldResult fieldResult = ProjectMembershipBenchmark__c.MembershipLevel__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        // Add an entry for each MembershipLevel__c picklist value
        List<ProjectMembershipBenchmark__c> prjMBLst = new List<ProjectMembershipBenchmark__c>();
        for (Schema.PicklistEntry pickListVal : ple) {
            ProjectMembershipBenchmark__c prjMB = new ProjectMembershipBenchmark__c (
                Name = 'Will Be Overwriten'
                , Project__c             = projectId
                , MembershipLevel__c     = pickListVal.getValue()
                , EventBenchmark__c      = 50
                , EventMaxValue__c       = 100
                , MembershipBenchmark__c = 50
                , MembershipMaxValue__c  = 100
                , TandCBenchmark__c      = 50
                , TandCMaxValue__c       = 100
            );
            prjMBLst.add(prjMB);
        }

        // Add Project Benchmark Inputs
        if (prjMBLst.size() > 0) {
            insert prjMBLst;
        }
    }

    //
    // createConfigUsingMetadata
    // Creates a Sales Insight Configuration for a project from MEtadata
    //
    private static void createConfigUsingExisting(Id projectId, Id fromProjectId) {

        // Start with ProjectBenchmarkInputs
        List<ProjectBenchmarkInput__c> pbiLst = new List<ProjectBenchmarkInput__c>();
        for (ProjectBenchmarkInput__c pbiFrom : [SELECT Project__c
                                                        , BenchmarkInputType__c
                                                        , ScoreMultiplier__c
                                                        , UseInEvntBenchmark__c
                                                        , UseInMemberBenchmark__c
                                                        , UseInTandCBenchmark__c
                                                 FROM ProjectBenchmarkInput__c 
                                                 WHERE Project__c = :fromProjectId]) {
            ProjectBenchmarkInput__c pbiTo = new ProjectBenchmarkInput__c (
                Name                      = 'Project - ' + pbiFrom.BenchmarkInputType__c
                , Project__c              = projectId
                , BenchmarkInputType__c   = pbiFrom.BenchmarkInputType__c
                , ScoreMultiplier__c      = pbiFrom.ScoreMultiplier__c
                , UseInEvntBenchmark__c   = pbiFrom.UseInEvntBenchmark__c
                , UseInMemberBenchmark__c = pbiFrom.UseInMemberBenchmark__c
                , UseInTandCBenchmark__c  = pbiFrom.UseInTandCBenchmark__c
            );
            pbiLst.add(pbiTo);
        }

        // Add Project Benchmark Inputs
        if (pbiLst.size() > 0) {
            insert pbiLst;
        } else {
            throw new AuraHandledException('From Project does not have any Project Membership Benchmark Records');
        }

        // Add an entry for each BenchmarkInputType picklist
        List<ProjectMembershipBenchmark__c> pmbLst = new List<ProjectMembershipBenchmark__c>();
        for (ProjectMembershipBenchmark__c pmbFrom : [SELECT Project__c
                                                            , MembershipLevel__c
                                                            , EventBenchmark__c
                                                            , EventMaxValue__c
                                                            , MembershipBenchmark__c
                                                            , MembershipMaxValue__c
                                                            , TandCBenchmark__c
                                                            , TandCMaxValue__c
                                                      FROM ProjectMembershipBenchmark__c 
                                                      WHERE Project__c = :fromProjectId]) {
            ProjectMembershipBenchmark__c pmbTo = new ProjectMembershipBenchmark__c (
                Name                     = 'Project - ' + pmbFrom.MembershipLevel__c
                , Project__c             = projectId
                , MembershipLevel__c     = pmbFrom.MembershipLevel__c
                , EventBenchmark__c      = pmbFrom.EventBenchmark__c
                , EventMaxValue__c       = pmbFrom.EventMaxValue__c
                , MembershipBenchmark__c = pmbFrom.MembershipBenchmark__c
                , MembershipMaxValue__c  = pmbFrom.MembershipMaxValue__c
                , TandCBenchmark__c      = pmbFrom.TandCBenchmark__c
                , TandCMaxValue__c       = pmbFrom.TandCMaxValue__c
            );
            pmbLst.add(pmbTo);
        }

        // Add Project Benchmark Inputs
        if (pmbLst.size() > 0) {
            insert pmbLst;
        }
    }
}