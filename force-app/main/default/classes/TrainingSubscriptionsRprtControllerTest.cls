@isTest
public class TrainingSubscriptionsRprtControllerTest {
    @testsetup
    public static void setupData(){
        Account acc = new Account(Name = 'Test account' );
        insert acc;
        
        Contact contact = new Contact();
        contact.AccountId = acc.Id;
        contact.LastName = 'Test Contact';
        insert contact;
        
        List<Product2> prod= new List<Product2> ();
        prod.add(new Product2(Name = 'Laptop X200', Family = 'Training' ,Type__c='E-Learning' ));
        prod.add(new Product2(Name = 'Laptop X300', Family = 'Training',Type__c='E-Learning'));
        prod.add(new Product2(Name = 'Laptop X400', Family = 'Training',Type__c='Certification'));
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> pbe= new List<PricebookEntry>();
        pbe.add(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod[0].Id, UnitPrice = 2000, IsActive = true));
        pbe.add(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod[1].Id, UnitPrice = 2000, IsActive = true));
        pbe.add(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod[2].Id, UnitPrice = 3000, IsActive = true));
        insert pbe;
        
        Training__c trng = new Training__c(Name = 'test training' , Category__c = 'Subscription');
        insert trng;
        
        Id trainingProdDetailRecordTypeId = Schema.SObjectType.Product_Details__c.getRecordTypeInfosByName().get('Training').getRecordTypeId();
        List<Product_Details__c> proDetail = new List<Product_Details__c>();
        for(Integer i=0 ; i < prod.size() ; i++){
            proDetail.add(new Product_Details__c(RecordTypeId = trainingProdDetailRecordTypeId ,Subscription_Calculation__c =4, Products__c = prod[i].Id , Training__c = trng.Id,Price__c=100 ));
        }
        insert proDetail;
        
        Id trainingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();        
        Opportunity oppt= new Opportunity(RecordTypeId =trainingRecordTypeId ,Name='Opportunity testing for Contactrole' , accountId=acc.Id , Billing_Contact__c = contact.Id,
                                          StageName='2. Discovery' ,Type='Renewal', CloseDate=Date.today().addDays(4),
                                          Renewal_Opportunity_Closed__c='True' );
        insert oppt; 
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        OpportunityLineItem oli= new OpportunityLineItem(OpportunityId = oppt.Id,Quantity =2, unitPrice = 20,
                                                         PriceBookEntryId = pbe[0].Id,Product2Id = prod[0].Id,Required_Active_LF_Membership__c=true,
                                                         training__c = trng.Id,Bill_From__c = 'The Linux Foundation');
        
        OpportunityLineItem oli2= new OpportunityLineItem(OpportunityId = oppt.Id,Quantity =2, unitPrice = 20,
                                                          PriceBookEntryId = pbe[1].ID,Product2Id = prod[1].Id,Required_Active_LF_Membership__c=true,
                                                          training__c = trng.Id,parent_product__c = prod[0].Id);
        
        OpportunityLineItem oli3= new OpportunityLineItem(OpportunityId = oppt.Id,Quantity =2, unitPrice = 20,
                                                          PriceBookEntryId = pbe[2].ID,Product2Id = prod[2].Id,Required_Active_LF_Membership__c=true,
                                                          training__c = trng.Id,parent_product__c = prod[0].Id);
        
        oliList.add(oli);
        oliList.add(oli2);
        oliList.add(oli3);
        insert oliList;
        
        Asset asst1 = new Asset(Name = 'Test asset',AccountId = acc.ID,
                                Training__c = trng.ID , Status = 'Active',
                                OpportunityLineItem__c=oli.Id,Product2Id=prod[0].Id,
                                Opportunity__c = oppt.Id,InstallDate=date.newinstance(2020, 5, 1)
                               );
        Insert asst1;
    }
    public static testmethod void fetchRecords_Test(){
        Test.startTest();
        Date fromDate =  date.newinstance(2020, 4, 30);
        Date toDate =  date.newinstance(2020, 5, 15);
        List<TrainingSubscriptionsReportController.AssetProductDetail> asstProdDetailList = TrainingSubscriptionsReportController.fetchRecords(fromDate,toDate);
        System.debug('asstProdDetailList '+asstProdDetailList);
        System.assertEquals(1,asstProdDetailList.size());
        String result=TrainingSubscriptionsReportController.generateCsv(JSON.serialize(asstProdDetailList));
        System.assertNotEquals(null,result);
        Test.stopTest();
         
    }
}