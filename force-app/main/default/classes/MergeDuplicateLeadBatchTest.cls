/**
 * Test class for MergeDuplicateLeadBatch
 * @author Cloudroute Solutions
 */
@IsTest
private class MergeDuplicateLeadBatchTest {
    
    /**
	 * TestSetup inserting required data for test class
	 */
    @TestSetup
    static void createData(){
        //Lead
        Lead lead = new Lead();
        lead.FirstName = 'Test Lead';
        lead.LastName = 'source 1';
        lead.Email = 'test@lead.com';
        insert  lead;
    }
    
    /**
	 * test method for convertLeadToContact
	 */
    @IsTest
    public static void convertLeadToContact_Test() {

        //Account
       	Account account = TestDataUtils.createAccount(true,'Test Account');
        
        //Contact
        Contact contact = new Contact(AccountId=account.id,LastName = 'testCon1', email = 'test@contact.com' , Additional_Email__c = 'test123@yahoo.com1');
        insert contact;

        //AlternateEmail
        Alternate_Email__c alteranteEmail = [SELECT id FROM Alternate_Email__c 
                                             WHERE Alternate_Email_Address__c='test@lead.com'];
        alteranteEmail.Primary_Email__c=false;
        alteranteEmail.lead_name__c = null;
        alteranteEmail.contact_Name__c = contact.Id;
        update alteranteEmail;

        //Test
        Test.startTest();
        Database.executeBatch(new MergeDuplicateLeadBatch(),10);
        Test.stopTest();
        Lead lead = [SELECT Id,isConverted,ConvertedContactId FROM Lead WHERE Email='test@lead.com'];
        
        //Asserts
        System.assertEquals(true,lead.isConverted,'Lead should be converted to contact');
        System.assertEquals(contact.Id,lead.ConvertedContactId,'Contact Id should match');
    }

    /**
	 * test method for mergeLeads
	 */
    @IsTest
    public static void mergeLeads_Test() {

        //Lead
        Lead lead = new Lead();
        lead.LastName = 'Lead source test1';
        lead.Email = 'test@lead1.com';
        insert  lead;
        
        //Alternate Email
        Alternate_Email__c alternateEmail = [SELECT id,Lead_Name__c FROM Alternate_Email__c 
                                             WHERE Alternate_Email_Address__c='test@lead.com'];
        alternateEmail.Lead_Name__c = lead.id;
        alternateEmail.Primary_Email__c=false;
        update alternateEmail;

        //Test
        Test.startTest();
        Database.executeBatch(new MergeDuplicateLeadBatch(),10);
        Test.stopTest();
        List<Lead> deletedLead = [SELECT Id FROM Lead WHERE Id=:lead.Id];
        //Asserts
        System.assertEquals(true,deletedLead.isEmpty(),'Lead must not be exist');
        
    }

    /**
	 * test method for convertLeadToContact
	 */
    @IsTest
    public static void callBatchWithSpecifiedQuery_Test() {

        //Account
       	Account account = TestDataUtils.createAccount(true,'Test Account');
        
        //Contact
        Contact contact = new Contact(AccountId=account.id,LastName = 'testCon1', email = 'test@contact.com' , Additional_Email__c = 'test123@yahoo.com1');
        insert contact;

        //AlternateEmail
        Alternate_Email__c alteranteEmail = [SELECT id,lead_name__c FROM Alternate_Email__c 
                                             WHERE Alternate_Email_Address__c='test@lead.com'];
        alteranteEmail.Primary_Email__c=false;
        Id leadId = alteranteEmail.lead_name__c;
        alteranteEmail.lead_name__c = null;
        alteranteEmail.contact_Name__c = contact.Id;
        update alteranteEmail;

        //Test
        Test.startTest();
        MergeDuplicateLeadBatch mergeBatch = new MergeDuplicateLeadBatch();
        String query = mergeBatch.leadFieldNames +
        ',(SELECT Id,Alternate_Email_Address__c FROM Alternate_Emails__r) FROM Lead'+
        ' WHERE Id = \''+leadId+'\'';
        Database.executeBatch(new MergeDuplicateLeadBatch(query),10);
        Test.stopTest();
        Lead lead = [SELECT Id,isConverted,ConvertedContactId FROM Lead WHERE Email='test@lead.com'];
        
        //Asserts
        System.assertEquals(true,lead.isConverted,'Lead should be converted to contact');
        System.assertEquals(contact.Id,lead.ConvertedContactId,'Contact Id should match');
   }
}