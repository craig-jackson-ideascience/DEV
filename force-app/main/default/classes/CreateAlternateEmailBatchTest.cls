@IsTest
public class CreateAlternateEmailBatchTest {
    @isTest public static void testInsertContact() 
    {
        List<Contact> lstContact= new List<Contact>();
        for(Integer i=0 ;i <200;i++)
        {
            Contact contact = new Contact();
            contact.lastName ='Name'+i;
            lstContact.add(contact);
        }
        
        insert lstContact;
        
        List<Alternate_Email__c> alternateEmails = [SELECT Id FROM ALternate_Email__c WHERE Contact_Name__c IN: lstContact];
        delete alternateEmails;
        Test.startTest();
        
        CreateAlternateEmailBatch jobObject = new CreateAlternateEmailBatch('Contact');
        DataBase.executeBatch(jobObject); 
        
        Test.stopTest();
    }
    
    @isTest 
    public static void testInsertlead() 
    {
        
        Lead lead = new lead();
        lead.lastName ='Name';
        lead.Email = 'testlead@noreply.com';
        insert lead;
        
        Test.startTest();
        
        List<Alternate_Email__c> alternateEmails = [SELECT Id FROM ALternate_Email__c WHERE Lead_Name__c =: lead.Id];
        delete alternateEmails;
        
        CreateAlternateEmailBatch jobObject = new CreateAlternateEmailBatch('Lead');
        DataBase.executeBatch(jobObject); 
        
        Test.stopTest();
    }
}