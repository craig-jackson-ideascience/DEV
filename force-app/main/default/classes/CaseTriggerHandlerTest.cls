/**
 * Test class for CaseTriggerHandler
 */
@istest
public class CaseTriggerHandlerTest {
    /**
	 *testSetup: create the required data for testing
	 */
    @testSetup static void setup(){
        // Account creation
        Account acc1 = new Account(Name = 'Test account' , website = 'testing123.com');
        insert acc1;
        // Contact creation
        Contact con1 = new Contact(FirstName = 'Test',LastName ='Contact',Username__c ='testcontact1',Email ='testcontact@email.com',AccountID = acc1.Id);
        insert con1;
        // Lead creation
        Lead lead1 = new Lead(FirstName = 'Test',LastName ='Lead',Username__c ='testlead1',Email ='testlead@email.com',Company = 'TestCompany');
        insert lead1;
        
        Profile prof = [select Id from profile where name ='System Admin Custom'];
        // User creation
        User user = new User(FirstName = 'Beatrix',LastName = 'Kid',ProfileId = prof.id,Username = 'BeatrixKid@test.com',
        Email = 'BeatrixKid@test.com',Alias = 'BKid',TimeZoneSidKey = 'GMT',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',
        LanguageLocaleKey = 'en_US');
        insert user;
        
    }
    
    /**
	 * TestupdateContactLeadAndOwnerOnCase: test method for updateContactLeadAndOwnerOnCase
	 */
    static testMethod void TestupdateContactLeadAndOwnerOnCase(){
        List<Case> lstCase = new List<Case>();
        Case case1 = new Case();
        case1.JIRA_Reporter__c ='testcontact1';
        case1.Jira_Assignee__c = 'BeatrixKid';
        case1.Subject ='Test Ticket';
        lstCase.add(case1);
        
        Case case2 = new Case();
        case2.JIRA_Reporter__c ='testlead1';
        case2.Jira_Assignee__c = 'BeatrixKid';
        case2.Subject ='Test Ticket2';
        lstCase.add(case2);
        
        insert lstCase;
        
        case2.JIRA_Reporter__c ='testcontact1';
        Update case2;
        
        System.assertEquals([Select ID From User Where username='BeatrixKid@test.com' Limit 1].Id, [Select OwnerID From Case Where Id=:case2.Id Limit 1].OwnerId , 'Case Owner not update correctly');
        
        System.assertEquals([Select ContactId From Case Where Id=: case2.Id Limit 1].ContactId, [Select Id From Contact Where Email='testcontact@email.com' Limit 1].Id , 'Case not assigned properly to contact');
    }

}