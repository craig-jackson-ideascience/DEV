@isTest
public class EnrollmentToCampaignMemberBatchTest {
    @testsetup
    public static void createData(){
        Account account = new Account (Name = 'Acme, Inc.');
        insert account;
        Contact contact = new Contact(
            FirstName = 'Robin',
            LastName = 'Koehler',
            AccountId = account.Id
        );
        insert contact;
        Lead lead = new Lead();
        lead.LastName = 'Test Lead';
        lead.Email = 'testEmail@test.com';
        insert lead;
        
        Product2 parentProduct = new Product2(Name = 'Test Training Parent Product', productcode = 'parent', 
                                              isActive = true,Type__c='Bundle');
        insert parentProduct;
        
        Product2 product = new Product2(Name = 'TestP', productcode = 'campaign', isActive = true,TI_Id__c='TestTiid');
        insert product;
        
        Bundle_Product__c bundleProduct = new Bundle_Product__c(Bundle__c=parentProduct.Id,Product__c=product.Id);
        insert bundleProduct;
        
        Campaign parentCampaign = new Campaign(
            Name = 'Training Bootcamp 2020',
            IsActive = TRUE,
            startDate=System.today()-1,
            endDate=System.today()+30,
            Product__c='Test Training Parent Product'
        );            
        insert parentCampaign;
        System.debug('parentCampaign '+parentCampaign);
        
        Campaign campaign = new Campaign(
            Name = 'Test campaign',
            IsActive = TRUE,
            ParentId = parentCampaign.id,
            Type = 'Training'
        );            
        insert campaign;
        
        Enrollment__c enrollment = new Enrollment__c();
        enrollment.Name = 'Test enrollment';
        enrollment.Contact_Name__c = contact.Id;
        enrollment.Product_Name__c = product.Id;
        enrollment.Parent_Product__c=parentProduct.Id;
        enrollment.Is_free__c = true;
        enrollment.Source__c ='SugarCRM';
        enrollment.Completion_Date__c = System.today()-1;
        enrollment.isBootcampbundle__c = true;
        enrollment.Enrollment_Date__c = System.today();
        insert enrollment;
        
        parentProduct.Bootcamp_Campaign__c = true;
        update parentProduct;
        
    }
    @isTest
    public static void testData(){
        Campaign campaign=[SELECT Id,Name FROM Campaign WHERE Parent.Name='Training Bootcamp 2020' ];
        Test.startTest();
        Database.executeBatch(new EnrollmentToCampaignMemberBatch('Test Training Parent Product'));
        Test.stopTest();
        System.assertEquals('Sent', [SELECT id,Status FROM CampaignMember WHERE CampaignId =: campaign.Id][0].Status);
    }
}