@isTest
public class BatchEnrollmentUpdateStatusTest {
    
    @testsetup
    private static void setup(){
        
        Product2 product = new Product2(Name = 'Laptop X400', Family = 'Training');
        insert product;
        
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test Contact';
        contact.Email = 'testcontact@noreply.com';
        
        List<Enrollment__c> enrollments = new List<Enrollment__c>();
        
        Enrollment__c enrollment = new Enrollment__c();
        enrollment.Name = 'Test enrollment';
        enrollment.Contact_Name__c = contact.Id;        
        enrollment.Product_Name__c = product.Id;        
        enrollment.Source__c ='TI Other';
        enrollment.Status__c = 'Enrolled';
        enrollment.Start_Date__c = Date.today();
        enrollments.add(enrollment);
        insert enrollments;
    }
    
    @isTest
    static void enrollment_batch(){
        Test.startTest();
        Database.executeBatch(new BatchEnrollmentUpdateStatus());
        Test.stopTest();
        System.assertEquals('Started', [SELECT ID,Status__c FROM Enrollment__c LIMIT 1].Status__c);
    }
    
    @isTest
    static void schedule_test(){
        Test.startTest();
        String sch = '0 0 23 * * ?';
		String jobId = system.schedule('ScheduledApexTest', sch, new BatchEnrollmentUpdateStatus() );        
        Test.stopTest(); 
        System.assert(String.isNotBlank(jobId));
    }

}