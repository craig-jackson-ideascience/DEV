/**
Used to Genreate Test Data
@author (c) Idea Science  2023
*
* History
* *******
* Date       By             Ticket      Change
* *********  *************  **********  **************************************
* 20FEB2023  Craig Jackson  LF240-271   Initial Version
*/
@isTest
public class TestDataFactory {
    // Create a single Company Account
    public static Account getCompanyAccount(String name, Boolean doInsert) {
        System.debug('CTJ: ' + Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName());
        Account acnt =  new Account (
                Name = name
                , RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId()
                , Type            = 'Customer'
                , Company_Type__c = 'private'
                , Sector__c       = 'Information Technology'
                , Website         = 'www.' + name.replace(' ', '-') + '.com');

        // Insert Record if asked to
        if (doInsert) {
            insert acnt;
        }
        return acnt;
    }

    // Create a multiple Company Accounts
    public static List<Account> getCompanyAccounts(Integer noAccounts, String name, Boolean doInsert) {
        List<Account> acntLst = new List<Account>();
        for (integer i = 1; i<=noAccounts; ++i) {
            Account acnt = getCompanyAccount(name + ' ' + i, false);
            acntLst.add(acnt);
        }

        // Insert Record if asked to
        if (doInsert) {
            insert acntLst;
        }
        return acntLst;
    }

    // Create a single Project
    public static Project__c getProject(String name, Boolean doInsert) {
        Project__c prj =  new Project__c (
                Name = name
                , Category__c   = 'Incorporated Entity'
                , Industry__c   = 'Automotive'
                , Model__c      = 'Membership'
                , Status__c     = 'Planned'
                , Slug__c       = name.replaceAll(' ', '').toLowerCase()
                , Start_Date__c = Date.Today().addMonths(-1));

        // Insert Record if asked to
        if (doInsert) {
            insert prj;
        }
        return prj;
    }

    // Create a multiple Projects
    public static List<Project__c> getProjects(Integer noProjects, String name, Boolean doInsert) {
        List<Project__c> prjLst = new List<Project__c>();
        for (integer i = 1; i<=noProjects; ++i) {
            Project__c prj = getProject(name + ' ' + i, false);
            prjLst.add(prj);
        }

        // Insert Record if asked to
        if (doInsert) {
            insert prjLst;
        }
        return prjLst;
    }

    // Create a single ProjectBenchmarkInput__c
    public static ProjectBenchmarkInput__c getProjectBenchmarkInput(Project__c prj, String inputType, Boolean doInsert) {
        ProjectBenchmarkInput__c prjBMInput = new ProjectBenchmarkInput__c (
            Name                      = 'Dummy'
            , Project__c              = prj.Id
            , BenchmarkInputType__c   = inputType
            , ScoreMultiplier__c      = 1
            , UseInEvntBenchmark__c   = false
            , UseInMemberBenchmark__c = false
            , UseInTandCBenchmark__c  = false
        );

        // Insert Record if asked to
        if (doInsert) {
            insert prjBMInput;
        }
        return prjBMInput;
    }

    // Create a single ProjectMembershipBenchmark__c
    public static ProjectMembershipBenchmark__c getProjectMembershipBenchmark(Project__c prj, String membershipLvl, Boolean doInsert) {
        ProjectMembershipBenchmark__c prjMemBM = new ProjectMembershipBenchmark__c (
            Name                     = 'Dummy'
            , Project__c             = prj.Id
            , MembershipLevel__c     = membershipLvl
            , EventBenchmark__c      = 1
            , EventMaxValue__c       = 2
            , MembershipBenchmark__c = 3
            , MembershipMaxValue__c  = 4
            , TandCBenchmark__c      = 5
            , TandCMaxValue__c       = 6
        );

        // Insert Record if asked to
        if (doInsert) {
            insert prjMemBM;
        }
        return prjMemBM;
    }

    // Create a single AccountProjectBenchmark__c
    public static AccountProjectBenchmark__c getAccountProjectBenchmark(Project__c prj, Account acnt, Boolean doInsert) {
        AccountProjectBenchmark__c acntPrjBM = new AccountProjectBenchmark__c (
            Name                     = 'Dummy'
            , Account__c             = acnt.Id
            , Project__c             = prj.Id
            , MembershipLevel__c     = 'Non Member'
            , EvntBenchmarkScore__c  = 1
            , MemBenchmarkScore__c   = 3
            , TandCBenchmarkScore__c = 5
        );

        // Insert Record if asked to
        if (doInsert) {
            insert acntPrjBM;
        }
        return acntPrjBM;
    }

    // Create a single AccountProjectBenchmarkItem__c
    public static AccountProjectBenchmarkItem__c getAccountProjectBenchmarkItem(AccountProjectBenchmark__c acntPrjBM, String itemType, Boolean doInsert) {
        AccountProjectBenchmarkItem__c acntPrjBMI = new AccountProjectBenchmarkItem__c (
            Name                     = 'Dummy'
            , AccountProjectBenchmark__c = acntPrjBM.Id
            , BenchmarkType__c           = itemType
            , BenchmarkValue__c          = 1
        );

        // Insert Record if asked to
        if (doInsert) {
            insert acntPrjBMI;
        }
        return acntPrjBMI;
    }
}