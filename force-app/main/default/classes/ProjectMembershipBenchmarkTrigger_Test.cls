/**
ProjectMembershipBenchmark trigger handler Test Coverage
@author (c) Idea Science  2023
*
* History
* *******
* Date       By             Ticket      Change
* *********  *************  **********  **************************************
* 21FEB2023  Craig Jackson  LF240-271   Initial Version
*/
@isTest
public class ProjectMembershipBenchmarkTrigger_Test {

    //
    // Test Happy Path for Insert
    // Expect Name to be changed and Benchmark Input Records to be created
    //
    @isTest
    static void insertHappyPath() {
        Schema.DescribeFieldResult fieldResult = ProjectBenchmarkInput__c.BenchmarkInputType__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        fieldResult                            = ProjectMembershipBenchmark__c.MembershipLevel__c.getDescribe();
        List<Schema.PicklistEntry> ple2        = fieldResult.getPicklistValues();
        String projectName  = 'PMB Test';
        String memberLvl    = ple2[0].getValue();
        String expectedName = projectName + ' - ' + memberLvl;
        Project__c prj      = TestDataFactory.getProject(projectName, true);

        // Setup ProjectMembershipBenchmark__c
        ProjectMembershipBenchmark__c pmb = TestDataFactory.getProjectMembershipBenchmark(prj, memberLvl, false);

        // Insert ProjectMembershipBenchmark__c
        Test.startTest();
        insert pmb;
        Test.stopTest();

        // Assert Record created and Name changed
        List<ProjectMembershipBenchmark__c> actualLst = [SELECT Id, Name FROM ProjectMembershipBenchmark__c];
        Assert.isTrue(actualLst.size() == 1, 'Expected 1 ProjectMembershipBenchmark__c record to be found');
        Assert.areEqual(expectedName, actualLst[0].name);

        // Expect one ProjectMembershipBenchmark__c per Benchmark Input 
        List<ProjectBenchmarkInput__c> pbiLst = [SELECT Id, Name FROM ProjectBenchmarkInput__c];
        Assert.isTrue(pbiLst.size() == ple.size(), 'Expected ' + ple.size() + ' ProjectBenchmarkInput__c records to be found, actual ' + pbiLst.size());
    }

    //
    // Test Happy Path for Update
    // Expect Name to be changed and no extra Benchmark Input Records to be created
    //
    @isTest
    static void updateHappyPath() {
        Schema.DescribeFieldResult fieldResult = ProjectBenchmarkInput__c.BenchmarkInputType__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        fieldResult                            = ProjectMembershipBenchmark__c.MembershipLevel__c.getDescribe();
        List<Schema.PicklistEntry> ple2        = fieldResult.getPicklistValues();
        String projectName  = 'PMB Test';
        String memberLvl    = ple2[0].getValue();
        String expectedName = projectName + ' - ' + memberLvl;
        Project__c prj      = TestDataFactory.getProject(projectName, true);

        // Setup ProjectMembershipBenchmark__c
        ProjectMembershipBenchmark__c pmb = TestDataFactory.getProjectMembershipBenchmark(prj, memberLvl, true);

        // Assert Record created and Name changed
        List<ProjectMembershipBenchmark__c> actualLst = [SELECT Id, Name FROM ProjectMembershipBenchmark__c];
        Assert.isTrue(actualLst.size() == 1, 'Expected 1 ProjectMembershipBenchmark__c record to be found');
        Assert.areEqual(expectedName, actualLst[0].name);

        // Expect one ProjectMembershipBenchmark__c per Benchmark Input 
        List<ProjectBenchmarkInput__c> pbiLst = [SELECT Id, Name FROM ProjectBenchmarkInput__c];
        Assert.isTrue(pbiLst.size() == ple.size(), 'Expected ' + ple.size() + ' ProjectBenchmarkInput__c records to be found, actual ' + pbiLst.size());

        // Modify Record
        pmb.Name = 'Changed';

        // Update ProjectMembershipBenchmark__c
        Test.startTest();
        update pmb;
        Test.stopTest();

        // Assert Record Name changed
        List<ProjectMembershipBenchmark__c> actualLst2 = [SELECT Id, Name FROM ProjectMembershipBenchmark__c];
        Assert.isTrue(actualLst2.size() == 1, 'Expected 1 ProjectMembershipBenchmark__c record to be found');
        Assert.areEqual(expectedName, actualLst2[0].name);

        // Expect still to have one ProjectMembershipBenchmark__c per Benchmark Input 
        List<ProjectBenchmarkInput__c> pbiLst2 = [SELECT Id, Name FROM ProjectBenchmarkInput__c];
        Assert.isTrue(pbiLst2.size() == ple.size(), 'Expected ' + ple.size() + ' ProjectBenchmarkInput__c records to be found, actual ' + pbiLst.size());
    }

    //
    // Test Happy Path for Delete
    // No extra coding exists for delete and undelete so just for code coverage
    //
    @isTest
    static void deleteHappyPath() {
        Schema.DescribeFieldResult fieldResult = ProjectMembershipBenchmark__c.MembershipLevel__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        String projectName = 'PMB Test';
        String memberLvl   = ple[0].getValue();
        Project__c prj     = TestDataFactory.getProject(projectName, true);

        // Setup ProjectMembershipBenchmark__c
        ProjectMembershipBenchmark__c pmb = TestDataFactory.getProjectMembershipBenchmark(prj, memberLvl, true);

        // Assert Record created and Name changed
        List<ProjectMembershipBenchmark__c> actualLst = [SELECT Id, Name FROM ProjectMembershipBenchmark__c];
        Assert.isTrue(actualLst.size() == 1, 'Expected 1 ProjectMembershipBenchmark__c record to be found');

        Test.startTest();
        // Delete ProjectMembershipBenchmark__c
        delete pmb;

        // Assert Record Deleted
        List<ProjectMembershipBenchmark__c> actualLst2 = [SELECT Id, Name FROM ProjectMembershipBenchmark__c];
        Assert.isTrue(actualLst2.size() == 0, 'Expected 0 ProjectMembershipBenchmark__c record to be found');

        // UnDelete ProjectMembershipBenchmark__c
        undelete pmb;
        Test.stopTest();

        // Assert Record Undeleted
        List<ProjectMembershipBenchmark__c> actualLst3 = [SELECT Id, Name FROM ProjectMembershipBenchmark__c];
        Assert.isTrue(actualLst3.size() == 1, 'Expected 1 ProjectMembershipBenchmark__c record to be found');
    }

    //
    // Make sure no new Benchmark Items are created if already exist for the project
    // Expect Benchmark Items count to not change
    //
    @isTest
    static void insertDoNotCreateBMItems() {
        Schema.DescribeFieldResult fieldResult = ProjectMembershipBenchmark__c.MembershipLevel__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        String projectName = 'PMB Test';
        String memberLvl   = ple[0].getValue();
        Project__c prj     = TestDataFactory.getProject(projectName, true);
        ProjectBenchmarkInput__c pbi = TestDataFactory.getProjectBenchmarkInput(prj, 'CodeCommitCnt', true);

        // Setup ProjectMembershipBenchmark__c
        ProjectMembershipBenchmark__c pmb = TestDataFactory.getProjectMembershipBenchmark(prj, memberLvl, false);

        // Insert ProjectMembershipBenchmark__c
        Test.startTest();
        insert pmb;
        Test.stopTest();

        // Assert Record created
        List<ProjectMembershipBenchmark__c> actualLst = [SELECT Id, Name FROM ProjectMembershipBenchmark__c];
        Assert.isTrue(actualLst.size() == 1, 'Expected 1 ProjectMembershipBenchmark__c record to be found');

        // Expect only one ProjectMembershipBenchmark__c
        List<ProjectBenchmarkInput__c> pbiLst = [SELECT Id, Name FROM ProjectBenchmarkInput__c];
        Assert.isTrue(pbiLst.size() == 1, 'Expected 1 ProjectBenchmarkInput__c record to be found, actual ' + pbiLst.size());
    }

    //
    // Should not be able to create multiple records with the same Project/Membership combination
    // Expect Exception to be thrown
    //
    @isTest
    static void insertDuplicateCheck() {
        Schema.DescribeFieldResult fieldResult = ProjectMembershipBenchmark__c.MembershipLevel__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        String projectName = 'PMB Test';
        String memberLvl   = ple[0].getValue();
        Project__c prj     = TestDataFactory.getProject(projectName, true);

        // Setup ProjectMembershipBenchmark__c
        ProjectMembershipBenchmark__c pmb     = TestDataFactory.getProjectMembershipBenchmark(prj, memberLvl, true);
        ProjectMembershipBenchmark__c pmbDupe = TestDataFactory.getProjectMembershipBenchmark(prj, memberLvl, false);

        // Attempt to insert duplicate ProjectMembershipBenchmark__c
        Test.startTest();
        try {
            insert pmbDupe;
            Assert.fail('Expected Duplicate Reocrd to thrown an Exception');
        } catch (Exception ex) {
            Assert.areEqual(ex.getTypeName(), 'System.DmlException', 'Expected DmlException to be thrown');
        }
        Test.stopTest();

    }
}