/**
ProjectBenchmarkInput trigger handler Test Coverage
@author (c) Idea Science  2023
*
* History
* *******
* Date       By             Ticket      Change
* *********  *************  **********  **************************************
* 21FEB2023  Craig Jackson  LF240-271   Initial Version
*/
@isTest
public class ProjectBenchmarkInputTriggerHandler_Test {

    //
    // Test Happy Path for Insert
    // Expect Name to be changed and Benchmark Input Records to be created
    //
    @isTest
    static void insertHappyPath() {
        Schema.DescribeFieldResult fieldResult = ProjectBenchmarkInput__c.BenchmarkInputType__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        String projectName  = 'PBI Test';
        String inputType    = ple[0].getValue();
        String expectedName = projectName + ' - ' + inputType;
        Project__c prj      = TestDataFactory.getProject(projectName, true);

        // Setup ProjectMembershipBenchmark__c
        ProjectBenchmarkInput__c pbi = TestDataFactory.getProjectBenchmarkInput(prj, inputType, false);

        // Insert ProjectMembershipBenchmark__c
        Test.startTest();
        insert pbi;
        Test.stopTest();

        // Assert Record created and Name changed
        List<ProjectBenchmarkInput__c> actualLst = [SELECT Id, Name FROM ProjectBenchmarkInput__c];
        Assert.isTrue(actualLst.size() == 1, 'Expected 1 ProjectMembershipBenchmark__c record to be found');
        Assert.areEqual(expectedName, actualLst[0].name);
    }

    //
    // Test Happy Path for Update
    // Expect Name to be changed and no extra Benchmark Input Records to be created
    //
    @isTest
    static void updateHappyPath() {
        Schema.DescribeFieldResult fieldResult = ProjectBenchmarkInput__c.BenchmarkInputType__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        String projectName  = 'PBI Test';
        String inputType    = ple[0].getValue();
        String expectedName = projectName + ' - ' + inputType;
        Project__c prj      = TestDataFactory.getProject(projectName, true);

        // Setup ProjectBenchmarkInput__c
        ProjectBenchmarkInput__c pbi = TestDataFactory.getProjectBenchmarkInput(prj, inputType, false);
        insert pbi;

        // Assert Record created and Name changed
        List<ProjectBenchmarkInput__c> actualLst = [SELECT Id, Name FROM ProjectBenchmarkInput__c];
        Assert.isTrue(actualLst.size()==1, 'Expected 1 ProjectBenchmarkInput__c record to be found');
        Assert.areEqual(expectedName, actualLst[0].name);

        // Update Name
        pbi.Name = 'Changed';

        // Update ProjectMembershipBenchmark__c
        Test.startTest();
        update pbi;
        Test.stopTest();

        // Assert Record Name updated
        List<ProjectBenchmarkInput__c> actualLst2 = [SELECT Id, Name FROM ProjectBenchmarkInput__c];
        Assert.isTrue(actualLst2.size() == 1, 'Expected 1 ProjectBenchmarkInput__c record to be found');
        Assert.areEqual(expectedName, actualLst2[0].name);
    }

    //
    // Test Happy Path for Delete
    // No extra coding exists for delete and undelete so just for code coverage
    //
    @isTest
    static void deleteHappyPath() {
        Schema.DescribeFieldResult fieldResult = ProjectBenchmarkInput__c.BenchmarkInputType__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        String projectName  = 'PBI Test';
        String inputType    = ple[0].getValue();
        Project__c prj      = TestDataFactory.getProject(projectName, true);

        // Setup ProjectBenchmarkInput__c
        ProjectBenchmarkInput__c pbi = TestDataFactory.getProjectBenchmarkInput(prj, inputType, true);

        // Assert Record created and Name changed
        List<ProjectBenchmarkInput__c> actualLst = [SELECT Id, Name FROM ProjectBenchmarkInput__c];
        Assert.isTrue(actualLst.size()==1, 'Expected 1 ProjectBenchmarkInput__c record to be found');

        // Delete ProjectBenchmarkInput__c
        Test.startTest();
        delete pbi;

        // Assert Record Deleted
        List<ProjectBenchmarkInput__c> actualLst2 = [SELECT Id, Name FROM ProjectBenchmarkInput__c];
        Assert.isTrue(actualLst2.size()==0, 'Expected 0 ProjectBenchmarkInput__c record to be found');

        // Undelete ProjectBenchmarkInput__c
        undelete pbi;
        Test.stopTest();

        // Assert Record Undeleted
        List<ProjectBenchmarkInput__c> actualLst3 = [SELECT Id, Name FROM ProjectBenchmarkInput__c];
        Assert.isTrue(actualLst3.size() == 1, 'Expected 1 ProjectBenchmarkInput__c record to be found');
    }

    //
    // Should not be able to create multiple records with the same Project/Membership combination
    // Expect Exception to be thrown
    //
    @isTest
    static void insertDuplicateCheck() {
        Schema.DescribeFieldResult fieldResult = ProjectBenchmarkInput__c.BenchmarkInputType__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        String projectName  = 'PBI Test';
        String inputType    = ple[0].getValue();
        Project__c prj      = TestDataFactory.getProject(projectName, true);

        // Setup ProjectBenchmarkInput__c
        ProjectBenchmarkInput__c pbi     = TestDataFactory.getProjectBenchmarkInput(prj, inputType, false);
        ProjectBenchmarkInput__c pbiDupe = TestDataFactory.getProjectBenchmarkInput(prj, inputType, false);
        insert pbi;

        // Attempt to insert duplicate ProjectMembershipBenchmark__c
        Test.startTest();
        try {
            insert pbiDupe;
            Assert.fail('Expected Duplicate Reocrd to thrown an Exception');
        } catch (Exception ex) {
            Assert.areEqual(ex.getTypeName(), 'System.DmlException', 'Expected DmlException to be thrown');
        }
        Test.stopTest();

    }
}