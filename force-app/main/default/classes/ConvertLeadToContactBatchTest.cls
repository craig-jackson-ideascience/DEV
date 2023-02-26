@IsTest
private class ConvertLeadToContactBatchTest {
    static testMethod void testBehavior() {
        Account account =  new Account(Name= 'Test Account');
        insert account;
        Contact con1 = new Contact(AccountId=account.id,LastName = 'testCon1', email = 'test@lead.com' , Additional_Email__c = 'test123@yahoo.com1');
        insert con1;
        Alternate_Email__c ae1 = [SELECT id from Alternate_Email__c Where Alternate_Email_Address__c='test@lead.com'];
        System.debug(ae1);

        delete ae1;
        Lead lead = new Lead();
        lead.LastName = 'Lead source test';
        lead.Email = 'test@lead1.com';
        insert  lead;
        Alternate_Email__c ae2 = new Alternate_Email__c(Alternate_Email_Address__c = 'test@lead.com',Lead_Name__c=lead.Id);
        insert  ae2;
        Test.startTest();
        Database.executeBatch(new ConvertLeadToContactBatch(),10);
        Test.stopTest();
    }
    @IsTest
    public static void mergeConTactTest() {
        Account account =  new Account(Name= 'Test Account');
        insert account;
        Contact con1 = new Contact(AccountId=account.id,LastName = 'testCon1', email = 'test@con.com' );
        insert con1;
       
        Alternate_Email__c ae = [SELECT id,Lead_Name__c from Alternate_Email__c Where Alternate_Email_Address__c='test@con.com'];
        System.debug(ae);
        delete ae;
        Contact con2 = new Contact(AccountId=account.id,LastName = 'testCon2', email = 'test@con1.com' );
        insert con2;
        Alternate_Email__c ae1 = new Alternate_Email__c(Alternate_Email_Address__c = 'test@con.com',Contact_Name__c=con2.Id);
        insert  ae1;
        Test.startTest();
        Database.executeBatch(new ConvertLeadToContactBatch(),10);
        Test.stopTest();


    }
}