@isTest
public class EnrollmentTriggerHandlerTest {
    @TestSetup
    public static void makeData(){
        Account account = new Account (Name = 'Acme, Inc.');
        insert account;
        Contact contact = new Contact(
            FirstName = 'Robin',
            LastName = 'Koehler',
            AccountId = account.Id
        );
        insert contact;
    }
    @isTest
    public static void createPurchaseHistoryForPaidEnrollment_Test(){
        
        Map<id,Enrollment__c> oldmap = new Map<id,Enrollment__c>();
        Map<id,Enrollment__c> newmap = new Map<id,Enrollment__c>();
        Map<id,Decimal> productVsPrice = new Map<id,Decimal>();
        Set<Id> enrollmentIds = new Set<Id>();
        Product2 product = new Product2(Name = 'Laptop X400', Family = 'Training', ProductCode = 'LX400', IsActive = true);
        insert product;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = product.Id,
            UnitPrice = 1020,
            IsActive = true
        ); 
        Insert pbe2; 
        productVsPrice.put(pbe2.Product2Id ,pbe2.UnitPrice);
        
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test Contact';
        contact.Email = 'testcontact@noreply.com';
        insert contact;
        
        Training__c edxtraining = new Training__c();
        edxtraining.Name = 'Edx Training';
        insert edxtraining;
        
        Training__c instructortraining = new Training__c();
        instructortraining.Name = 'Instructor Led';
        insert instructortraining;
        
        Training__c certificationtraining = new Training__c();
        certificationtraining.Name = 'Certification';
        insert certificationtraining;
        
        Training__c eLearningtraining = new Training__c();
        eLearningtraining.Name = 'E-Learning';
        insert eLearningtraining;
        
        List<Asset> assetList =  new List<Asset>();
        Asset asset =  TestFactory.getAsset();
        asset.Name = 'TEST';
        Id indRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Asset ast = new Asset();
        ast.Name='Test Asset';
        ast.price= 75;
        ast.Product2Id = product.Id;
        ast.RecordTypeId = indRecordTypeId;
        
        Id edxRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('EdxTraining').getRecordTypeId();
        Asset ast1 = new Asset();
        ast1.Name='Test Data Asset';
        ast1.RecordTypeId =edxRecordTypeId;
        ast1.price= 75;
        ast1.Product2Id = product.Id;
        assetList.add(ast);
        assetList.add(ast1);
        insert assetList;
        
        test.startTest();
        Lead lead =  TestFactory.getLead();
        
        Enrollment__c enrollment = new Enrollment__c();
        enrollment.Name = 'Test enrollment';
        enrollment.Contact_Name__c = contact.Id;
        enrollment.Lead_Name__c =null;
        enrollment.Product_Name__c =null; 
        enrollment.Ext_Product_Id__c ='Training+LX400+2021';
        enrollment.Purchase_history__c =asset.id;
        enrollment.Source__c ='Edx';
        insert enrollment;
        
		enrollment.Id = null;
        enrollment.Name = null;
        enrollment.Contact_Name__c = null;
		enrollment.Lead_Name__c = lead.id;
		insert enrollment;
        
        Enrollment__c enrollment1 = new Enrollment__c();
        enrollment1.Name = 'Test enrollment';
        enrollment1.Contact_Name__c = contact.Id;
        enrollment1.Lead_Name__c =lead.id;
        enrollment1.Product_Name__c = product.Id;
        enrollment1.Purchase_history__c =asset.id;
        enrollment.Is_free__c = false;
        enrollment1.Source__c ='SugarCRM';
        enrollment.Amount__c  = 100;
        insert enrollment1;
        
        
        oldmap.put(enrollment.id, enrollment);
        enrollmentIds.add(enrollment.id);
        enrollment.Name = 'Test enrollment1';
        update enrollment;
        newmap.put(enrollment.id, enrollment);
        
        oldmap.put(enrollment1.id, enrollment1);
        enrollmentIds.add(enrollment1.id);
        enrollment1.Name = 'Test enrollment1';
        update enrollment1;
        test.stopTest();
        newmap.put(enrollment1.id, enrollment1);
        
        List<Enrollment__c> lst =[Select id,Name,Product_Name__c,Ext_Product_Id__c,Lead_Name__c,Contact_Name__c from Enrollment__c where Name='Test enrollment' OR Name='Test enrollment1'];
        EnrollmentTriggerHandler obj = new EnrollmentTriggerHandler();
        EnrollmentTriggerHandler.BeforeInsert(lst);
        EnrollmentTriggerHandler.AfterUpdate(newmap, oldmap);
        EnrollmentTriggerHandler.afterInsert(newMap);
        
        EnrollmentTriggerHandler.createPurchaseHistory(enrollmentIds, productVsPrice);
        
        List<Enrollment__c> enrList = [Select ID from Enrollment__c where Purchase_History__c=: asset.ID];
        System.debug('enrList ===>'+enrList.size());
        System.assertEquals(1,enrList.size());
    }
    
    @isTest
    public static void upsertCampaignMember(){
        Contact contact =[SELECT ID FROM Contact LIMIT 1];
        Lead lead = new Lead();
        lead.LastName = 'Test Lead';
        lead.Email = 'testEmail@test.com';
        insert lead;
        
        Product2 parentProduct = new Product2(Name = 'Cloud Engineer Boot Camp', productcode = 'parent', 
                                              isActive = true,Type__c='Bundle');
        insert parentProduct;
        
        Product2 product = new Product2(Name = 'TestP', productcode = 'campaign', isActive = true,TI_Id__c='TestTiid');
        insert product;
        
        Bundle_Product__c bundleProduct = new Bundle_Product__c(Bundle__c=parentProduct.Id,Product__c=product.Id);
        insert bundleProduct;
        
        Campaign parentCampaign = new Campaign(
            Name = 'LF Training Bootcamp June 2020',
            IsActive = TRUE,
            startDate=System.today()-1,
            endDate=System.today()+30,
            Product__c='Cloud Engineer Boot Camp'
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
        
        List<Campaign> campaigns = [SELECT Id,Name FROM Campaign WHERE Parent.Name='LF Training Bootcamp June 2020' ];
        System.debug('campaigns'+campaigns);
        CampaignMember member = new CampaignMember(
            ContactId = contact.Id,LeadId = lead.Id,
            Status = 'testsent',
            CampaignId = campaign.Id
        ); 
        insert member;
        
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
        
        
        /*CampaignMemberStatus newStatus = new CampaignMemberStatus(
            CampaignID=campaign.id,
            Label='Sent',
            IsDefault=false,
            HasResponded=false,
            SortOrder=3
        );
        
        insert newStatus;*/
        
        System.assertEquals('Sent', [SELECT id,Status FROM CampaignMember WHERE CampaignId =: campaign.Id][0].Status);
    }
    
    @isTest
    public static void updateStatusofNotStartedEnrollment(){
        Contact contact =[SELECT ID FROM Contact LIMIT 1];
        Product2 product = new Product2(Name = 'TestP', productcode = 'campaign', isActive = true);
        insert product;
        
        Enrollment__c enrollment = new Enrollment__c();
        enrollment.Contact_Name__c = contact.Id;
        enrollment.Product_Name__c = product.Id;
        enrollment.Is_free__c = true;
        enrollment.Source__c ='SugarCRM';
        enrollment.Enrollment_Date__c = System.today()-1;
        insert enrollment;
        
        Enrollment__c enrollment2 = new Enrollment__c();
        enrollment2.Contact_Name__c = contact.Id;
        enrollment2.Product_Name__c = product.Id;
        enrollment2.Is_free__c = true;
        enrollment2.Source__c ='SugarCRM';
        enrollment2.Enrollment_Date__c = System.today()-1;
        enrollment2.Status__c = 'Not Started';
        insert enrollment2;
        
        enrollment.Status__c = 'Completed';
        update enrollment;
        
    }
    
    @isTest
    public static void updateEnrollmentName_test(){
        
      
        Contact contact =[SELECT ID FROM Contact LIMIT 1];
        Product2 product = new Product2(Name = 'TestProduct', productcode = 'campaign', isActive = true);
        insert product;
        
        Enrollment__c enrollment = new Enrollment__c();
        enrollment.Contact_Name__c = contact.Id;
        enrollment.Product_Name__c = product.Id;
        enrollment.Is_free__c = true;
        enrollment.Source__c ='SugarCRM';
        insert enrollment;
        
        System.assertEquals('Robin Koehler TestProduct', [SElECT Id,Name from Enrollment__c WHERE Contact_Name__c =: contact.Id].Name);
    }
    @isTest
    public static void addToTechnologyCampaignTest(){
        Lead lead = new Lead();
        lead.LastName = 'Test Lead';
        lead.Email = 'testEmail@test.com';
        insert lead;
        
       Contact contact =[SELECT ID FROM Contact LIMIT 1];
        Product2 product = new Product2(Name = 'TestP', productcode = 'campaign', isActive = true,Technology__c='Blockchain');
        insert product;
        
        Campaign campaign = new Campaign(
            Name = 'Test campaign',
            IsActive = TRUE,
            Training_Technology_List__c=true,
            LF_Training__c=true,
            Type = 'Training',
            Technology__c='Blockchain'
        );            
        insert campaign;
        List<Enrollment__c> enrollmentList = new List<Enrollment__c>();
        Enrollment__c enrollment = new Enrollment__c();
        enrollment.Name = 'Test enrollment';
        enrollment.Contact_Name__c = contact.Id;
        enrollment.Product_Name__c = product.Id;
        enrollment.Source__c ='SugarCRM';
        enrollment.Completion_Date__c = System.today()-1;
        enrollmentList.add(enrollment);

        Enrollment__c enrollment1 = new Enrollment__c();
        enrollment1.Name = 'Test enrollment1';
        enrollment1.Lead_Name__c = lead.Id;
        enrollment1.Product_Name__c = product.Id;
        enrollment1.Source__c ='SugarCRM';
        enrollment1.Completion_Date__c = System.today()-1;
        enrollmentList.add(enrollment1);

        Test.startTest();
        insert enrollmentList;
              Test.stopTest();
        System.assertNotEquals(null,[SELECT Id from CampaignMember where campaignid=:campaign.Id].size());
    }
    
}