@IsTest
public class ConvertAccountTypeControllerTest {
    static testMethod void mergeAccount_Test(){
        Account testAccount = new Account();
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        testAccount.LastName='Test Account record' ;
        insert testAccount;
        
        Test.StartTest(); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        ConvertAccountTypeController convertAccount = new ConvertAccountTypeController(sc);
        ConvertAccount.account = testAccount;
        convertAccount.mergeAccount();
        Test.StopTest();
    }
    
    static testMethod void mergeAccountwithOpp_Test(){
        
        Account bussinessAccount = new Account();
        bussinessAccount.Name='Test Account record' ;
        insert bussinessAccount;
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        testAccount.LastName='Test Account record' ;
        insert testAccount;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = system.today();
        opp.AccountId = testAccount.id;
        opp.StageName = '2. Discovery';
        insert opp;
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        ConvertAccountTypeController convertAccount = new ConvertAccountTypeController(sc);
        convertAccount.bussinessAccountID = bussinessAccount.Id;
        ConvertAccount.account = testAccount;
        convertAccount.mergeAccount();
        Test.StopTest();
        
    }
    static testMethod void mergeAccounttoExistingAccount_Test(){
        
        Account bussinessAccount = new Account();
        bussinessAccount.Name='Test Account record' ;
        insert bussinessAccount;
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        testAccount.LastName='Test Account record' ;
        insert testAccount;
        
        Account account = [Select ID, IsPersonAccount, RecordTypeId, PersonContactId From Account WHERE Id = : testAccount.Id];
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        ConvertAccountTypeController convertAccount = new ConvertAccountTypeController(sc);
        convertAccount.bussinessAccountID = bussinessAccount.Id;
        ConvertAccount.account = account;
        convertAccount.mergeAccount();
        Test.StopTest();
        
    }
    
    static testMethod void closeVf_Test(){
        Account testAccount = new Account();
        testAccount.Name='Test Account record' ;
        insert testAccount;
        
        Test.StartTest(); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        ConvertAccountTypeController convertAccount = new ConvertAccountTypeController(sc);
        convertAccount.closeVf();
        Test.StopTest();
    }
}