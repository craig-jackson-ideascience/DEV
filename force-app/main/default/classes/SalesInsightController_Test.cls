/**
SalesInsightController Test Coverage
@author (c) Idea Science  2023
*
* History
* *******
* Date       By             Ticket      Change
* *********  *************  **********  **************************************
* 23FEB2023  Craig Jackson  LF240-271   Initial Version
*/
@isTest
public class SalesInsightController_Test {

    private static final String BASE_PRJ_NAME = 'SI Test';

    //
    // hasConfig Expect True
    // Call function with project that has ProjectMemberBenchmark__c records
    //
    @isTest
    static void hasConfig_True() {
        String memberLvl = getMembershipLevels()[0].getValue();
        Boolean expected = true;

        // Setup Data
        Project__c prj                    = TestDataFactory.getProject(BASE_PRJ_NAME, true);
        ProjectMembershipBenchmark__c pmb = TestDataFactory.getProjectMembershipBenchmark(prj, memberLvl, true);

        // Insert ProjectMembershipBenchmark__c
        Test.startTest();
        Boolean actual = SalesInsightController.hasConfig(prj.Id);
        Test.stopTest();

        // Assert Record created and Name changed
        Assert.areEqual(expected, actual);
    }

    //
    // hasConfig Expect False
    // Call function with project that has no ProjectMemberBenchmark__c records
    //
    @isTest
    static void hasConfig_False() {
        String memberLvl = getMembershipLevels()[0].getValue();
        Boolean expected = false;

        // Setup Data
        Project__c prjWithConfig          = TestDataFactory.getProject(BASE_PRJ_NAME + '1', true);
        Project__c prjNoConfig            = TestDataFactory.getProject(BASE_PRJ_NAME + '2', true);
        ProjectMembershipBenchmark__c pmb = TestDataFactory.getProjectMembershipBenchmark(prjWithConfig, memberLvl, true);

        // Insert ProjectMembershipBenchmark__c
        Test.startTest();
        Boolean actual = SalesInsightController.hasConfig(prjNoConfig.Id);
        Test.stopTest();

        // Assert Record created and Name changed
        Assert.areEqual(expected, actual);
    }

    //
    // hasConfig Expect False
    // Call function with invalid project
    //
    @isTest
    static void hasConfig_InvalidProject() {
        Boolean expected   = false;

        // Insert ProjectMembershipBenchmark__c
        Test.startTest();
        Boolean actual = SalesInsightController.hasConfig('a0919000008rwo6AAA');
        Test.stopTest();

        // Assert Record created and Name changed
        Assert.areEqual(expected, actual);
    }

    //
    // hasConfig Expect False
    // Call function with null project
    //
    @isTest
    static void hasConfig_NullProject() {
        Boolean expected   = false;

        // Insert ProjectMembershipBenchmark__c
        Test.startTest();
        Boolean actual = SalesInsightController.hasConfig(NULL);
        Test.stopTest();

        // Assert Record created and Name changed
        Assert.areEqual(expected, actual);
    }

    //
    // getConfiguredProjectLst Expect 1 Row returned
    // Call function with no ProjectMemberBenchmark__c records
    //
    @isTest
    static void getConfiguredProjectLst_NoProjects() {
        // Expected Values
        List<Project__c> expected = new List<Project__c>();
        expected.add(new Project__c(id=null, Name='--None--'));

        // Insert ProjectMembershipBenchmark__c
        Test.startTest();
        List<Project__c> actual = SalesInsightController.getConfiguredProjectLst();
        Test.stopTest();

        // Assert Record created and Name changed
        Assert.isTrue(actual.size() == 1);
        Assert.areEqual(expected, actual);
    }

    //
    // getConfiguredProjectLst Expect 1 Row returned
    // Call function with no ProjectMemberBenchmark__c records
    //
    @isTest
    static void getConfiguredProjectLst_WithProject() {
        // Initialise
        List<Schema.PicklistEntry> ple = getMembershipLevels();
        String memberLvl1              = ple[0].getValue();
        String memberLvl2              = ple[1].getValue();

        // Setup Data
        Project__c prj                     = TestDataFactory.getProject(BASE_PRJ_NAME, true);
        ProjectMembershipBenchmark__c pmb1 = TestDataFactory.getProjectMembershipBenchmark(prj, memberLvl1, true);
        ProjectMembershipBenchmark__c pmb2 = TestDataFactory.getProjectMembershipBenchmark(prj, memberLvl2, true);

        // Expected Values
        List<Project__c> expected = new List<Project__c>();
        expected.add(new Project__c(id=null, Name='--None--'));
        expected.add(new Project__c(id=prj.Id, Name=prj.Name));

        // Insert ProjectMembershipBenchmark__c
        Test.startTest();
        List<Project__c> actual = SalesInsightController.getConfiguredProjectLst();
        Test.stopTest();

        // Assert Record created and Name changed
        Assert.isTrue(actual.size() == 2);
        Assert.areEqual(expected, actual);
    }

    //
    // createSalesInsigtConfigForProject Invalid project - Expect Error
    // Call function with Invalid Project
    //
    @isTest
    static void createSalesInsigtConfigForProject_InvalidProject() {

        // Insert ProjectMembershipBenchmark__c
        try {
            Test.startTest();
            SalesInsightController.createSalesInsigtConfigForProject('a0919000008rwo6AAA', false, null);
            Test.stopTest();

            Assert.fail('Expected Exception to be thrown');
        } catch (Exception ex) {
            Assert.areEqual(ex.getTypeName(), 'SalesInsightException', 'Expected SalesInsightException to be thrown');
        }
    }

    //
    // createSalesInsigtConfigForProject  - Expect ProjectMembershipBenchmark__c and ProjectBenchmarkInput__c created
    // Call function with Valid Project and no existing ProjectMembershipBenchmark__c and ProjectBenchmarkInput__c records
    //
    @isTest
    static void createSalesInsigtConfigForProject_CreateBase() {
        // Initialise Vars
        Integer expectedBenchIpCnt = getBenchmarkInputTypes().size();
        Integer expectedMemLvlCnt  = getMembershipLevels().size();

        // Setup Data
        Project__c prj = TestDataFactory.getProject(BASE_PRJ_NAME, true);

        // Insert ProjectMembershipBenchmark__c and ProjectBenchmarkInput__c
        Test.startTest();
        SalesInsightController.createSalesInsigtConfigForProject(prj.Id, false, null);
        Test.stopTest();

        // Check Result
        List<ProjectMembershipBenchmark__c> pmbLst = [SELECT Id FROM ProjectMembershipBenchmark__c WHERE Project__c = :prj.Id];
        List<ProjectBenchmarkInput__c>      pbiLst = [SELECT Id FROM ProjectBenchmarkInput__c WHERE Project__c = :prj.Id];

        Assert.areEqual(expectedMemLvlCnt,  pmbLst.size(), 'Expected ' + expectedMemLvlCnt +  ' ProjectMembershipBenchmark__c records created, Actual ' + pmbLst.size());
        Assert.areEqual(expectedBenchIpCnt, pbiLst.size(), 'Expected ' + expectedBenchIpCnt + ' ProjectBenchmarkInput__c records created, Actual ' + pbiLst.size());
    }

    //
    // createSalesInsigtConfigForProject  - Expect ProjectMembershipBenchmark__c and ProjectBenchmarkInput__c created
    // Call function with Valid Project and no existing ProjectMembershipBenchmark__c and ProjectBenchmarkInput__c records and Project to clone
    //
    @isTest
    static void createSalesInsigtConfigForProject_CloneBase() {
        // Initialise Vars
        Integer expectedBenchIpCnt     = 1;
        Integer expectedMemLvlCnt      = 2;
        String inputType               = getBenchmarkInputTypes()[0].getValue();
        List<Schema.PicklistEntry> ple = getMembershipLevels();
        String memberLvl1              = ple[0].getValue();
        String memberLvl2              = ple[1].getValue();

        // Setup Data
        Project__c prj      = TestDataFactory.getProject(BASE_PRJ_NAME, true);
        Project__c prjClone = TestDataFactory.getProject(BASE_PRJ_NAME + ' Clone', true);
        ProjectBenchmarkInput__c pbi = TestDataFactory.getProjectBenchmarkInput(prjClone, inputType, true);
        ProjectMembershipBenchmark__c pmb1 = TestDataFactory.getProjectMembershipBenchmark(prjClone, memberLvl1, true);
        ProjectMembershipBenchmark__c pmb2 = TestDataFactory.getProjectMembershipBenchmark(prjClone, memberLvl2, true);

        // Check Project to be Cloned
        List<ProjectMembershipBenchmark__c> pmbLstC = [SELECT Id FROM ProjectMembershipBenchmark__c WHERE Project__c = :prjClone.Id];
        List<ProjectBenchmarkInput__c>      pbiLstC = [SELECT Id FROM ProjectBenchmarkInput__c WHERE Project__c = :prjClone.Id];

        Assert.areEqual(expectedMemLvlCnt,  pmbLstC.size(), 'Expected ' + expectedMemLvlCnt +  ' ProjectMembershipBenchmark__c records for project to be Cloned, Actual ' + pmbLstC.size());
        Assert.areEqual(expectedBenchIpCnt, pbiLstC.size(), 'Expected ' + expectedBenchIpCnt + ' ProjectBenchmarkInput__c records for project to be Cloned, Actual ' + pbiLstC.size());

        // Insert ProjectMembershipBenchmark__c and ProjectBenchmarkInput__c
        Test.startTest();
        SalesInsightController.createSalesInsigtConfigForProject(prj.Id, false, prjClone.Id);
        Test.stopTest();

        // Check Result
        List<ProjectMembershipBenchmark__c> pmbLst = [SELECT Id FROM ProjectMembershipBenchmark__c WHERE Project__c = :prj.Id];
        List<ProjectBenchmarkInput__c>      pbiLst = [SELECT Id FROM ProjectBenchmarkInput__c WHERE Project__c = :prj.Id];

        Assert.areEqual(expectedMemLvlCnt,  pmbLst.size(), 'Expected ' + expectedMemLvlCnt +  ' ProjectMembershipBenchmark__c records created, Actual ' + pmbLst.size());
        Assert.areEqual(expectedBenchIpCnt, pbiLst.size(), 'Expected ' + expectedBenchIpCnt + ' ProjectBenchmarkInput__c records created, Actual ' + pbiLst.size());
    }

    //
    // createSalesInsigtConfigForProject Cloned project has not config - Expect Error
    // Call function with Cloned Project with no config defined
    //
    @isTest
    static void createSalesInsigtConfigForProject_ClonProjectNoConfig() {

        // Data Setup
        Project__c prj      = TestDataFactory.getProject(BASE_PRJ_NAME, true);
        Project__c prjClone = TestDataFactory.getProject(BASE_PRJ_NAME + ' Clone', true);

        // Insert ProjectMembershipBenchmark__c
        try {
            Test.startTest();
            SalesInsightController.createSalesInsigtConfigForProject(prj.Id, false, prjClone.Id);
            Test.stopTest();

            Assert.fail('Expected Exception to be thrown');
        } catch (Exception ex) {
            Assert.areEqual(ex.getTypeName(), 'SalesInsightException', 'Expected SalesInsightException to be thrown');
        }
    }

    //
    // createSalesInsigtConfigForProject - Error on creation due to existing config
    // Call function with Valid Project That has existing configuration
    //
    @isTest
    static void createSalesInsigtConfigForProject_OverwriteError1() {
        // Initialise Vars
        String inputType = getBenchmarkInputTypes()[0].getValue();

        // Setup Data
        Project__c prj               = TestDataFactory.getProject(BASE_PRJ_NAME, true);
        ProjectBenchmarkInput__c pbi = TestDataFactory.getProjectBenchmarkInput(prj, inputType, true);

        // Check Project to be Cloned
        List<ProjectBenchmarkInput__c> pbiLst = [SELECT Id FROM ProjectBenchmarkInput__c WHERE Project__c = :prj.Id];
        Assert.isTrue(pbiLst.size() > 0, 'Expected Test Data to have at least 1 ProjectBenchmarkInput__c');

        // Insert ProjectMembershipBenchmark__c and ProjectBenchmarkInput__c
        try {
            Test.startTest();
            SalesInsightController.createSalesInsigtConfigForProject(prj.Id, false, null);
            Test.stopTest();

            Assert.fail('Expected Exception to be thrown');
        } catch (Exception ex) {
            Assert.areEqual(ex.getTypeName(), 'SalesInsightException', 'Expected SalesInsightException to be thrown');
        }
    }

    //
    // createSalesInsigtConfigForProject - Error on creation due to existing config
    // Call function with Valid Project That has existing configuration
    //
    @isTest
    static void createSalesInsigtConfigForProject_OverwriteError2() {
        // Initialise Vars
        String memberLvl = getMembershipLevels()[0].getValue();

        // Setup Data
        Project__c prj                    = TestDataFactory.getProject(BASE_PRJ_NAME, true);
        ProjectMembershipBenchmark__c pmb = TestDataFactory.getProjectMembershipBenchmark(prj, memberLvl, true);

        // Delete any Input Records Created
        List<ProjectBenchmarkInput__c> pbiLst = [SELECT Id FROM ProjectBenchmarkInput__c WHERE Project__c = :prj.Id];
        delete pbiLst;

        // Check Project to be Cloned
        List<ProjectMembershipBenchmark__c> pmbLst = [SELECT Id FROM ProjectMembershipBenchmark__c WHERE Project__c = :prj.Id];
        Assert.isTrue(pmbLst.size() > 0, 'Expected Test Data to have at least 1 ProjectMembershipBenchmark__c');

        // Insert ProjectMembershipBenchmark__c and ProjectBenchmarkInput__c
        try {
            Test.startTest();
            SalesInsightController.createSalesInsigtConfigForProject(prj.Id, false, null);
            Test.stopTest();

            Assert.fail('Expected Exception to be thrown');
        } catch (Exception ex) {
            Assert.areEqual(ex.getTypeName(), 'SalesInsightException', 'Expected SalesInsightException to be thrown');
        }
    }

    //
    // createSalesInsigtConfigForProject  - Expect ProjectMembershipBenchmark__c and ProjectBenchmarkInput__c created
    // Call function with Valid Project with existing ProjectMembershipBenchmark__c and ProjectBenchmarkInput__c records and Project to clone and overwtite true
    //
    @isTest
    static void createSalesInsigtConfigForProject_CloneWithOverwrite() {
        // Initialise Vars
        Integer expectedBenchIpCnt     = 1;
        Integer expectedMemLvlCnt      = 2;
        String inputType               = getBenchmarkInputTypes()[0].getValue();
        List<Schema.PicklistEntry> ple = getMembershipLevels();
        String memberLvl1              = ple[0].getValue();
        String memberLvl2              = ple[1].getValue();

        // Setup Data
        Project__c prj      = TestDataFactory.getProject(BASE_PRJ_NAME, true);
        Project__c prjClone = TestDataFactory.getProject(BASE_PRJ_NAME + ' Clone', true);
        ProjectMembershipBenchmark__c pmb1  = TestDataFactory.getProjectMembershipBenchmark(prj, memberLvl1, true);
        ProjectBenchmarkInput__c pbiC       = TestDataFactory.getProjectBenchmarkInput(prjClone, inputType, true);
        ProjectMembershipBenchmark__c pmb1C = TestDataFactory.getProjectMembershipBenchmark(prjClone, memberLvl1, true);
        ProjectMembershipBenchmark__c pmb2C = TestDataFactory.getProjectMembershipBenchmark(prjClone, memberLvl2, true);

        // Check Project to be Cloned
        List<ProjectMembershipBenchmark__c> pmbLstC = [SELECT Id FROM ProjectMembershipBenchmark__c WHERE Project__c = :prjClone.Id];
        List<ProjectBenchmarkInput__c>      pbiLstC = [SELECT Id FROM ProjectBenchmarkInput__c WHERE Project__c = :prjClone.Id];

        Assert.areEqual(expectedMemLvlCnt,  pmbLstC.size(), 'Expected ' + expectedMemLvlCnt +  ' ProjectMembershipBenchmark__c records for project to be Cloned, Actual ' + pmbLstC.size());
        Assert.areEqual(expectedBenchIpCnt, pbiLstC.size(), 'Expected ' + expectedBenchIpCnt + ' ProjectBenchmarkInput__c records for project to be Cloned, Actual ' + pbiLstC.size());

        // Insert ProjectMembershipBenchmark__c and ProjectBenchmarkInput__c
        Test.startTest();
        SalesInsightController.createSalesInsigtConfigForProject(prj.Id, true, prjClone.Id);
        Test.stopTest();

        // Check Result
        List<ProjectMembershipBenchmark__c> pmbLst = [SELECT Id FROM ProjectMembershipBenchmark__c WHERE Project__c = :prj.Id];
        List<ProjectBenchmarkInput__c>      pbiLst = [SELECT Id FROM ProjectBenchmarkInput__c WHERE Project__c = :prj.Id];

        Assert.areEqual(expectedMemLvlCnt,  pmbLst.size(), 'Expected ' + expectedMemLvlCnt +  ' ProjectMembershipBenchmark__c records created, Actual ' + pmbLst.size());
        Assert.areEqual(expectedBenchIpCnt, pbiLst.size(), 'Expected ' + expectedBenchIpCnt + ' ProjectBenchmarkInput__c records created, Actual ' + pbiLst.size());
    }

    //
    // Helper Classes
    //
    //
    // Get the Membershiup Level Picklist Options
    //
    static List<Schema.PicklistEntry> getMembershipLevels() {
        Schema.DescribeFieldResult fieldResult = ProjectMembershipBenchmark__c.MembershipLevel__c.getDescribe();
        return(fieldResult.getPicklistValues());
    }
    //
    // Get the Benchmark Input Type Picklist Options
    //
    static List<Schema.PicklistEntry> getBenchmarkInputTypes() {
        Schema.DescribeFieldResult fieldResult = ProjectBenchmarkInput__c.BenchmarkInputType__c.getDescribe();
        return(fieldResult.getPicklistValues());
    }
}