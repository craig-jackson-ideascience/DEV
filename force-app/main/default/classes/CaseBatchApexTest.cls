/*
 * Test CLass For-CaseBatchApex Class
 */ 
@isTest
public class CaseBatchApexTest{
    
    // test setup method
    @testSetup static void setup() {
        Case objCase = new Case(Status ='New',
        Priority = 'Medium', 
        Origin = 'Email',
        Jira_Key__c ='ST-61',
        Jira_Assignee__c ='harshadk');
        insert objCase;
        JIRA_Authentication__c objJiraAuth = new JIRA_Authentication__c(Name='Test',Username__c ='testuser',Password__c='Password@1');
        insert objJiraAuth;
    }
    
    // test try block of CaseBatchApex
    @isTest 
    static void successTestMethod(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(true));
            CaseBatchApex obj = new CaseBatchApex();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
       }
    
    // test catch block of CaseBatchApex
    @isTest 
    static void failedTestMethod(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false));
            CaseBatchApex obj = new CaseBatchApex();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
       }
}