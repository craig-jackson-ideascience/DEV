@isTest
public class RelateEmailMessageWithTheirParentTest 
{
    @isTest public static void UpdateEmailMessagesTestMethod1()
    {
        
        Account acc=new Account();
        acc.Name='Peter';
        acc.Sugar_Account_ID__c='TestId2';
        insert acc;
        
        Contact con=new Contact();
        con.LastName='Parker';
        con.AccountId=acc.id;
        con.SugarContactID__c='TestId2';
        Insert con;
        
        EmailMessage em=new EmailMessage();
        em.Original_Sugar_ID__c='TestId1';
        em.Parent_Id__c ='TestId2';
        em.Sugar_EmailMessage_Id__c='TestId2';
        insert em;
        
        
        
        
    }
   
    
}