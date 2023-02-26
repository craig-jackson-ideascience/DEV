/**
AccountProjectBenchmarkItem trigger handler Test Coverage
@author (c) Idea Science  2023
*
* History
* *******
* Date       By             Ticket      Change
* *********  *************  **********  **************************************
* 21FEB2023  Craig Jackson  LF240-271   Initial Version
*/
@isTest
public class AccountProjBenchmarkItmTrigger_Test {

    //
    // Test Happy Path for Insert
    // Expect Name to be changed and Benchmark Input Records to be created
    //
    @isTest
    static void insertHappyPath() {
        String projectName  = 'PBI Project Test';
        String accountName  = 'PBI Account Test';
        Project__c prj      = TestDataFactory.getProject(projectName, true);
        Account    acnt     = TestDataFactory.getCompanyAccount(accountName, true);
        AccountProjectBenchmark__c apb         = TestDataFactory.getAccountProjectBenchmark(prj, acnt, true);
        Schema.DescribeFieldResult fieldResult = ProjectBenchmarkInput__c.BenchmarkInputType__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        String itemType     = ple[0].getValue();
        String expectedName = projectName + ' - ' + accountName + ' - ' + itemType;

        // Setup AccountProjectBenchmarkItem__c
        AccountProjectBenchmarkItem__c apbi = TestDataFactory.getAccountProjectBenchmarkItem(apb, itemType, false);

        // Insert AccountProjectBenchmarkItem__c
        Test.startTest();
        insert apbi;
        Test.stopTest();

        // Assert Record created and Name changed
        List<AccountProjectBenchmarkItem__c> actualLst = [SELECT Id, Name FROM AccountProjectBenchmarkItem__c];
        Assert.isTrue(actualLst.size() == 1, 'Expected 1 AccountProjectBenchmarkItem__c record to be found');
        Assert.areEqual(expectedName, actualLst[0].name, 'Expected Name to be ' + expectedName + ', actual ' + actualLst[0].name);
    }

    //
    // Test Happy Path for Update
    // Expect Name to be changed and no extra Benchmark Input Records to be created
    //
    @isTest
    static void updateHappyPath() {
        String projectName  = 'PBI Project Test';
        String accountName  = 'PBI Account Test';
        Project__c prj      = TestDataFactory.getProject(projectName, true);
        Account    acnt     = TestDataFactory.getCompanyAccount(accountName, true);
        AccountProjectBenchmark__c apb         = TestDataFactory.getAccountProjectBenchmark(prj, acnt, true);
        Schema.DescribeFieldResult fieldResult = ProjectBenchmarkInput__c.BenchmarkInputType__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        String itemType     = ple[0].getValue();
        String expectedName = projectName + ' - ' + accountName + ' - ' + itemType;

        // Setup AccountProjectBenchmarkItem__c
        AccountProjectBenchmarkItem__c apbi = TestDataFactory.getAccountProjectBenchmarkItem(apb, itemType, true);

        // Assert Record created and Name changed
        List<AccountProjectBenchmarkItem__c> actualLst = [SELECT Id, Name FROM AccountProjectBenchmarkItem__c];
        Assert.isTrue(actualLst.size() == 1, 'Expected 1 AccountProjectBenchmarkItem__c record to be found');
        Assert.areEqual(expectedName, actualLst[0].name);

        // Update Name
        apbi.Name = 'Changed';

        // Update AccountProjectBenchmarkItem__c
        Test.startTest();
        update apbi;
        Test.stopTest();

        // Assert Record Name updated
        List<AccountProjectBenchmarkItem__c> actualLst2 = [SELECT Id, Name FROM AccountProjectBenchmarkItem__c];
        Assert.isTrue(actualLst2.size() == 1, 'Expected 1 AccountProjectBenchmarkItem__c record to be found');
        Assert.areEqual(expectedName, actualLst2[0].name);
    }

    //
    // Test Happy Path for Delete
    // No extra coding exists for delete and undelete so just for code coverage
    //
    @isTest
    static void deleteHappyPath() {
        String projectName  = 'PBI Project Test';
        String accountName  = 'PBI Account Test';
        Project__c prj      = TestDataFactory.getProject(projectName, true);
        Account    acnt     = TestDataFactory.getCompanyAccount(accountName, true);
        AccountProjectBenchmark__c apb         = TestDataFactory.getAccountProjectBenchmark(prj, acnt, true);
        Schema.DescribeFieldResult fieldResult = ProjectBenchmarkInput__c.BenchmarkInputType__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        String itemType     = ple[0].getValue();

        // Setup AccountProjectBenchmarkItem__c
        AccountProjectBenchmarkItem__c apbi = TestDataFactory.getAccountProjectBenchmarkItem(apb, itemType, true);

        // Assert Record created and Name changed
        List<AccountProjectBenchmarkItem__c> actualLst = [SELECT Id, Name FROM AccountProjectBenchmarkItem__c];
        Assert.isTrue(actualLst.size() == 1, 'Expected 1 AccountProjectBenchmarkItem__c record to be found');

        // Delete AccountProjectBenchmarkItem__c
        Test.startTest();
        delete apbi;

        // Assert Record Deleted
        List<AccountProjectBenchmarkItem__c> actualLst2 = [SELECT Id, Name FROM AccountProjectBenchmarkItem__c];
        Assert.isTrue(actualLst2.size()==0, 'Expected 0 AccountProjectBenchmarkItem__c record to be found');

        // Undelete AccountProjectBenchmarkItem__c
        undelete apbi;
        Test.stopTest();

        // Assert Record Undeleted
        List<AccountProjectBenchmarkItem__c> actualLst3 = [SELECT Id, Name FROM AccountProjectBenchmarkItem__c];
        Assert.isTrue(actualLst3.size() == 1, 'Expected 1 AccountProjectBenchmarkItem__c record to be found');
    }

    //
    // Should not be able to create multiple records with the same Project/Membership combination
    // Expect Exception to be thrown
    //
    @isTest
    static void insertDuplicateCheck() {
        String projectName  = 'PBI Project Test';
        String accountName  = 'PBI Account Test';
        Project__c prj      = TestDataFactory.getProject(projectName, true);
        Account    acnt     = TestDataFactory.getCompanyAccount(accountName, true);
        AccountProjectBenchmark__c apb         = TestDataFactory.getAccountProjectBenchmark(prj, acnt, true);
        Schema.DescribeFieldResult fieldResult = ProjectBenchmarkInput__c.BenchmarkInputType__c.getDescribe();
        List<Schema.PicklistEntry> ple         = fieldResult.getPicklistValues();
        String itemType     = ple[0].getValue();

        // Setup AccountProjectBenchmarkItem__c
        AccountProjectBenchmarkItem__c apbi     = TestDataFactory.getAccountProjectBenchmarkItem(apb, itemType, true);
        AccountProjectBenchmarkItem__c apbiDupe = TestDataFactory.getAccountProjectBenchmarkItem(apb, itemType, false);

        // Attempt to insert duplicate AccountProjectBenchmarkItem__c
        Test.startTest();
        try {
            insert apbiDupe;
            Assert.fail('Expected Duplicate Reocrd to thrown an Exception');
        } catch (Exception ex) {
            Assert.areEqual(ex.getTypeName(), 'System.DmlException', 'Expected DmlException to be thrown');
        }
        Test.stopTest();
    }
}