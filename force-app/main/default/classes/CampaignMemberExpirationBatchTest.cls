@isTest
public class CampaignMemberExpirationBatchTest {
    @isTest
    public static void upsertCampaignMember(){
        Account account = new Account (Name = 'Acme, Inc.');
        insert account;
        system.debug('Inserted Account, ID: ' + account.id);
        
        Contact contact = new Contact(
            FirstName = 'Robin',
            LastName = 'Koehler',
            AccountId = account.Id
        );
        insert contact;   
        
        Product2 product = new Product2(Name = 'TestP', productcode = 'campaign', isActive = true);
        insert product;
        
        Enrollment__c enrollment = new Enrollment__c();
        enrollment.Name = 'Test enrollment';
        enrollment.Contact_Name__c = contact.Id;
        enrollment.Product_Name__c = product.Id;
        enrollment.Is_free__c = true;
        enrollment.Source__c ='SugarCRM';
        enrollment.Amount__c  = 100;
        enrollment.ExpirationDate__c = System.today()-1;
        enrollment.isBootcampbundle__c = true;
        insert enrollment;
        
        Campaign parentCampaign = new Campaign(
            Name = 'LF Training Bootcamp June 2020',
            IsActive = TRUE
        );            
        insert parentCampaign;
        
        
        Campaign campaign = new Campaign(
            Name = 'Test campaign',
            IsActive = TRUE,
            ParentId = parentCampaign.id
        );            
        insert campaign;
        
        List<Campaign> campaigns = [SELECT Id,Name FROM Campaign WHERE Parent.Name='LF Training Bootcamp June 2020' ];
        System.debug('campaigns'+campaigns);
        CampaignMember member = new CampaignMember(
            ContactId = contact.Id,
            Status = 'sent',
            CampaignId = campaign.Id
        ); 
        insert member;
        CampaignMemberStatus newStatus = new CampaignMemberStatus(
            CampaignID=campaign.id,
            Label='Expired',
            IsDefault=false,
            HasResponded=false,
            SortOrder=3
        );

insert newStatus;
        Test.startTest();
        Database.executeBatch(new CampaignMemberExpirationBatch());
        Test.stopTest();
        
        System.assertEquals('Expired', [SELECT id,Status FROM CampaignMember WHERE CampaignId =: campaign.Id][0].Status);
    }
}