/**
AccountProjBenchmark trigger handler Test Coverage
@author (c) Idea Science  2023
*
* History
* *******
* Date       By             Ticket      Change
* *********  *************  **********  **************************************
* 21FEB2023  Craig Jackson  LF240-271   Initial Version
*/
@isTest
public class AccountProjBenchmarkTriggerHandler_Test {

    //
    // Test Happy Path for Insert
    // Expect Name to be changed and Benchmark Input Records to be created
    //
    @isTest
    static void insertHappyPath() {
        String projectName  = 'PBI Project Test';
        String accountName  = 'PBI Account Test';
        String expectedName = projectName + ' - ' + accountName;
        Project__c prj      = TestDataFactory.getProject(projectName, true);
        Account    acnt     = TestDataFactory.getCompanyAccount(accountName, true);

        // Setup AccountProjectBenchmark__c
        AccountProjectBenchmark__c apb = TestDataFactory.getAccountProjectBenchmark(prj, acnt, false);

        // Insert AccountProjectBenchmark__c
        Test.startTest();
        insert apb;
        Test.stopTest();

        // Assert Record created and Name changed
        List<AccountProjectBenchmark__c> actualLst = [SELECT Id, Name FROM AccountProjectBenchmark__c];
        Assert.isTrue(actualLst.size() == 1, 'Expected 1 ProjectMembershipBenchmark__c record to be found');
        Assert.areEqual(expectedName, actualLst[0].name);
    }

    //
    // Test Happy Path for Update
    // Expect Name to be changed and no extra Benchmark Input Records to be created
    //
    @isTest
    static void updateHappyPath() {
        String projectName  = 'PBI Project Test';
        String accountName  = 'PBI Account Test';
        String expectedName = projectName + ' - ' + accountName;
        Project__c prj      = TestDataFactory.getProject(projectName, true);
        Account    acnt     = TestDataFactory.getCompanyAccount(accountName, true);

        // Setup AccountProjectBenchmark__c
        AccountProjectBenchmark__c apb = TestDataFactory.getAccountProjectBenchmark(prj, acnt, true);

        // Assert Record created and Name changed
        List<AccountProjectBenchmark__c> actualLst = [SELECT Id, Name FROM AccountProjectBenchmark__c];
        Assert.isTrue(actualLst.size() == 1, 'Expected 1 AccountProjectBenchmark__c record to be found');
        Assert.areEqual(expectedName, actualLst[0].name);

        // Update Name
        apb.Name = 'Changed';

        // Update AccountProjectBenchmark__c
        Test.startTest();
        update apb;
        Test.stopTest();

        // Assert Record Name updated
        List<AccountProjectBenchmark__c> actualLst2 = [SELECT Id, Name FROM AccountProjectBenchmark__c];
        Assert.isTrue(actualLst2.size() == 1, 'Expected 1 AccountProjectBenchmark__c record to be found');
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

        // Setup AccountProjectBenchmark__c
        AccountProjectBenchmark__c apb = TestDataFactory.getAccountProjectBenchmark(prj, acnt, true);

        // Assert Record created and Name changed
        List<AccountProjectBenchmark__c> actualLst = [SELECT Id, Name FROM AccountProjectBenchmark__c];
        Assert.isTrue(actualLst.size() == 1, 'Expected 1 AccountProjectBenchmark__c record to be found');

        // Delete AccountProjectBenchmark__c
        Test.startTest();
        delete apb;

        // Assert Record Deleted
        List<AccountProjectBenchmark__c> actualLst2 = [SELECT Id, Name FROM AccountProjectBenchmark__c];
        Assert.isTrue(actualLst2.size()==0, 'Expected 0 AccountProjectBenchmark__c record to be found');

        // Undelete AccountProjectBenchmark__c
        undelete apb;
        Test.stopTest();

        // Assert Record Undeleted
        List<AccountProjectBenchmark__c> actualLst3 = [SELECT Id, Name FROM AccountProjectBenchmark__c];
        Assert.isTrue(actualLst3.size() == 1, 'Expected 1 AccountProjectBenchmark__c record to be found');
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

        // Setup AccountProjectBenchmark__c
        AccountProjectBenchmark__c apb     = TestDataFactory.getAccountProjectBenchmark(prj, acnt, true);
        AccountProjectBenchmark__c apbDupe = TestDataFactory.getAccountProjectBenchmark(prj, acnt, false);

        // Attempt to insert duplicate AccountProjectBenchmark__c
        Test.startTest();
        try {
            insert apbDupe;
            Assert.fail('Expected Duplicate Reocrd to thrown an Exception');
        } catch (Exception ex) {
            Assert.areEqual(ex.getTypeName(), 'System.DmlException', 'Expected DmlException to be thrown');
        }
        Test.stopTest();
    }
}