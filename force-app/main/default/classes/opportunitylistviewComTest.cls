@isTest
public class opportunitylistviewComTest {
    @isTest
    public static void test1(){
        
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                          Product2Id = prod.Id, 
                                                          UnitPrice = 10000, 
                                                          IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, 
                                                        Product2Id = prod.Id, 
                                                        UnitPrice = 12000, 
                                                        IsActive = true);
        insert customPrice;
        Account acc = new Account(name='Test Account');
        insert acc;
        opportunity opp = new opportunity(name='Test Opportunity', 
                                          AccountId=acc.id,
                                          CloseDate =Date.newInstance(2016, 12, 9),
                                          stageName='Closed Lost',
                                          ForecastCategoryName='Pipeline',
                                          PaymentTerms__c='Net 30',
                                          type='New Business',
                                          Amount=5676,
                                          Pricebook2Id=customPB.Id,
                                          Loss_Reason__c ='Other'
                                         );
        insert opp;
        opportunity opp1 = new opportunity(name='Test Opportunity', 
                                           AccountId=acc.id,
                                           CloseDate =Date.newInstance(2016, 12, 9),
                                           stageName='Closed Lost',
                                           ForecastCategoryName='Pipeline',
                                           PaymentTerms__c='Net 30',
                                           type='New Business',
                                           Amount=5676,
                                           Pricebook2Id=customPB.Id,
                                           JoinNow_Update__c=Date.newInstance(2016, 12, 9),
                                           Loss_Reason__c ='Other'
                                          );
        insert opp1;
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId=opp.id,
                                                                  TotalPrice =664557,
                                                                  End_Date__c=Date.newInstance(2016, 12, 9),
                                                                  Quantity =56,
                                                                  PricebookEntryId = customPrice.Id);
        insert oppLineItem;
        blob attBlob;
        attBlob = EncodingUtil.base64Decode('AA==');
        attachment  at = new attachment();
        at.ParentId = opp1.Id;  
        at.Name ='testattach';
        at.Body = attblob;
        insert at;
        
        
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = Opp.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        id AccountId=acc.id;
        string sortField ='ASC';
        boolean isAsc =true;
        OpportunitylistViewCom objclass = new OpportunitylistViewCom();
        OpportunitylistViewCom.getOpportunityLineItem(AccountId, sortField, isAsc);
        OpportunitylistViewCom.fetchopportunity(AccountId,'Membership');
        
    }
     @isTest
    public static void test2(){
       Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                          Product2Id = prod.Id, 
                                                          UnitPrice = 10000, 
                                                          IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, 
                                                        Product2Id = prod.Id, 
                                                        UnitPrice = 12000, 
                                                        IsActive = true);
        insert customPrice;
        Account acc = new Account(name='Test Account');
        insert acc;
        opportunity opp = new opportunity(name='Test Opportunity', 
                                          AccountId=acc.id,
                                          CloseDate =Date.newInstance(2016, 12, 9),
                                          stageName='Closed Lost',
                                          ForecastCategoryName='Pipeline',
                                          PaymentTerms__c='Net 30',
                                          type='New Business',
                                          Amount=5676,
                                          Pricebook2Id=customPB.Id,
                                          Loss_Reason__c ='Other'
                                         );
        insert opp;
        
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId=opp.id,
                                                                  TotalPrice =664557,
                                                                  End_Date__c=Date.newInstance(2016, 12, 9),
                                                                  Quantity =56,
                                                                  PricebookEntryId = customPrice.Id);
        insert oppLineItem;
        
        blob attBlob;
        
         attBlob = EncodingUtil.base64Decode('AA==');
        attachment  at1 = new attachment();
        at1.ParentId = opp.Id;  
        at1.Name ='testattach';
        at1.Body = attblob;
        insert at1;
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = Opp.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        id AccountId=acc.id;
        string sortField ='ASC';
        boolean isAsc =true;
        OpportunitylistViewCom objclass = new OpportunitylistViewCom();
        OpportunitylistViewCom.getOpportunityLineItem(AccountId, sortField, isAsc);
        OpportunitylistViewCom.fetchopportunity(AccountId,''); 
        OpportunitylistViewCom.getRecordTypeList();
    }
}