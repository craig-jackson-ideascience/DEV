@isTest
public class QuoteTriggerHandlerTest {
	@isTest
    public static void validateEngagementPeriodForSubscriptionProducts_test(){
        Account acc = new Account(Name = 'Test account' );
        insert acc;
        
        Contact contact = new Contact();
        contact.AccountId = acc.Id;
        contact.LastName = 'Test Contact';
        insert contact;
        
        Training__c training= new Training__c(Name='test Training',Category__c = 'Subscription');
        insert training;
        Id trainingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();
        Opportunity oppt= new Opportunity(RecordTypeId =trainingRecordTypeId ,Name='Opportunity testing for Contactrole' , accountId=acc.Id , Billing_Contact__c = contact.Id,
                                          StageName='2. Discovery' ,Type='Renewal', CloseDate=Date.today().addDays(4),
                                          Renewal_Opportunity_Closed__c='True' );
        insert oppt;
        
        Id pricebookId = Test.getStandardPricebookId();
        PriceBook2 pbk = new PriceBook2(Name = 'testBook',isActive =true);
        insert pbk; 
        
        List<Product2> productList = new List<Product2>();
        
        Product2 prod = new Product2(Name = 'Certification',productcode='test',Type__c = 'Certification');
        Product2 prod2 = new Product2(Name = 'E-Learning',productcode='test2',Type__c = 'E-Learning');
        
        productList.add(prod);
        productList.add(prod2);
        insert productList;
        
        List<PriceBookEntry> priceBookEntryList =new List<PriceBookEntry>();
        PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId,Product2Id=prod.ID,isActive=true,unitPrice=34);
        priceBookEntryList.add(standardPbe);
        
        PriceBookEntry standardPbe2 = new PriceBookEntry(PriceBook2Id = pricebookId,Product2Id=prod2.ID,isActive=true,unitPrice=34);
        priceBookEntryList.add(standardPbe2);
        
        PriceBookEntry pbe=new PriceBookEntry(PriceBook2Id=pbk.Id,isActive=true,Product2Id=prod.ID,unitPrice=20.0,useStandardPrice=false);
        priceBookEntryList.add(pbe);
        
        PriceBookEntry pbe2=new PriceBookEntry(PriceBook2Id=pbk.Id,isActive=true,Product2Id=prod2.ID,unitPrice=20.0,useStandardPrice=false);
        priceBookEntryList.add(pbe2);
        
        insert priceBookEntryList;
        Project__c project1= new Project__c(Name='test Project',Type__c='Membership',Category__c='Subproject',Status__c='Planned', Slug__c = 'testing');
        insert project1;
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        OpportunityLineItem oli= new OpportunityLineItem(OpportunityId = oppt.Id,Quantity =2, unitPrice = 20,
                                                         PriceBookEntryId = pbe.ID,Product2Id = prod.Id,Required_Active_LF_Membership__c=true,
                                                         training__c = training.Id,Bill_From__c = 'The Linux Foundation'); 
        OpportunityLineItem oli2= new OpportunityLineItem(OpportunityId = oppt.Id,Quantity =2, unitPrice = 20,
                                                          PriceBookEntryId = pbe2.ID,Product2Id = prod2.Id,Required_Active_LF_Membership__c=true,
                                                          training__c = training.Id,parent_product__c = prod.Id);
        oliList.add(oli);
        oliList.add(oli2);
        insert oliList;
        
        
        Quote quote = new Quote();
        quote.Name = 'Test Quote';
        quote.OpportunityId = oppt.Id;
        try{
            insert quote;
        }
        catch(Exception ex){
            
        }
    }
}