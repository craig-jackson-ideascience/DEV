@IsTest
public class ConvertExistingPersonAccountTest {
    
    @TestSetup
    static void setup(){
        Account account =  new Account(Name= 'Individual - No Account');
        insert account;
    }
    
    static testMethod void mergeAccount_Test(){
        Account testAccount = new Account();
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        testAccount.LastName='Test Account record' ;
        insert testAccount;
        
        Test.StartTest();         
      	Database.executeBatch(new ConvertExistingPersonAccount());
        Test.StopTest();
        
        System.assertEquals('Individual - No Account',[Select Account.name from Contact WHERE Name ='Test Account record' LIMIT 1].Account.name);
    }
    
      static testMethod void mergeAccountwithOpp_Test(){
        
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
      	Database.executeBatch(new ConvertExistingPersonAccount());
        Test.StopTest();
        
        System.assertEquals(true,[Select IsPersonAccount from Account WHERE Name ='Test Account record' LIMIT 1].IsPersonAccount);
      }
}