/**
 * Test class for UpdateLeadContactTechnology_Batch
 */
@isTest
public class UpdateLeadContactTechnology_Batch_Test {
    
    /* createPurchaseHistoryForPaidEnrollment_Test test method for UpdateLeadContactTechnology_Batch */
    @isTest
    public static void createPurchaseHistoryForPaidEnrollment_Test(){
        
        Map<id,Enrollment__c> oldmap = new Map<id,Enrollment__c>();
        Map<id,Enrollment__c> newmap = new Map<id,Enrollment__c>();
        Map<id,Decimal> productVsPrice = new Map<id,Decimal>();
        Set<Id> enrollmentIds = new Set<Id>();
        
        // create product
        Product2 product = new Product2(Name = 'Laptop X400', 
                                        Family = 'Training', 
                                        Technology__c='Blockchain; DevOps, CI/CD & Site Reliability');
        insert product;
        
        Product2 product2 = new Product2(Name = 'Laptop X402', 
                                        Family = 'Training', 
                                        Technology__c='DevOps, CI/CD & Site Reliability');
        insert product2;
        
        // create Account
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        // create contact
        Contact contact2 = new Contact();
        contact2.AccountId = account.Id;
        contact2.LastName = 'Test Contact';
        contact2.Email = 'testcontact@noreply.com';
        contact2.Technology__c ='System Administration';
        insert contact2;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test Contact';
        contact.Email = 'testcontact2@noreply2.com';
        contact.Technology__c ='System Administration';
        insert contact;
        
        Lead lead =  TestFactory.getLead();
        // create lead
        Lead lead2 = new Lead(
            LastName = 'testing',
            Company = 'Test',                         
            Status = 'Unqualified',                        
            Title = 'PM',                                    
            Email = 'testingabc222@test.com', 
            Technology__c='System Administration',
            Industry = 'Software'                      
        );
        insert lead2;
        
		// create enrollment
        Enrollment__c enrollment = new Enrollment__c();
        enrollment.Name = 'Test enrollment';
        enrollment.Contact_Name__c = contact.Id;
        enrollment.Product_Name__c = product.Id;
        insert enrollment;

        Enrollment__c enrollment2 = new Enrollment__c();
        enrollment2.Name = 'Test enrollment';
        enrollment2.Contact_Name__c = contact2.Id;
        enrollment2.Product_Name__c = product2.Id;
        insert enrollment2;
        
        contact2.Technology__c =null;
        update contact2;
        contact.Technology__c =null;
        update contact;
        
        Enrollment__c enrollment1 = new Enrollment__c();
        enrollment1.Name = 'Test enrollment2';
        enrollment1.Lead_Name__c =lead.id;
        enrollment1.Product_Name__c = product.Id;
        insert enrollment1;
        
        Enrollment__c enrollment3 = new Enrollment__c();
        enrollment3.Name = 'Test enrollment2';
        enrollment3.Lead_Name__c =lead2.id;
        enrollment3.Product_Name__c = product2.Id;
        insert enrollment3;
        
        lead2.Technology__c =null;
        update lead2;
        lead.Technology__c =null;
        update lead;
        
        Test.startTest();
        Id contactBatchJobId = Database.executeBatch(new UpdateLeadContactTechnology_Batch('Contact'), 50);
        Id leadBatchJobId = Database.executeBatch(new UpdateLeadContactTechnology_Batch('Lead'), 50);
        Test.stopTest();
        
        System.assertEquals('Blockchain;DevOps, CI/CD & Site Reliability', [Select Technology__c From Contact Where ID=:contact.ID][0].Technology__c, 'Technolgy not updated correctly');
        System.assertEquals('Blockchain;DevOps, CI/CD & Site Reliability', [Select Technology__c From Lead Where ID=:lead.ID][0].Technology__c, 'Technolgy not updated correctly');
        
    }
}