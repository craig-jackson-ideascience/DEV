@isTest
public class QuoteSyncUtil_Test {
    
    @testSetup
    static void setup(){
        QuoteSyncField__c quoteSyncField = new QuoteSyncField__c(Name = 'PaymentTerms__c', OppSyncField__c = 'PaymentTerms__c');
        insert quoteSyncField;
        
        /* quote line sync field */
        QuoteLineSyncField__c quoteLineSyncField = new QuoteLineSyncField__c(Name = 'Agreement_Date__c', OppLineSyncField__c = 'AgreementDate__c');
        insert quoteLineSyncField;
        
    }
    
    @isTest
    static void getQuoteLineFieldsTest(){
        
        QuoteSyncUtil.getQuoteFields();
        QuoteSyncUtil.addQuoteField('TotalInitialPriceOf_QuoteLineItem__c','TotalInitialPriceOf_QuoteLineItem__c');
        System.assertEquals('TotalInitialPriceOf_QuoteLineItem__c', QuoteSyncUtil.getQuoteFieldMapTo('TotalInitialPriceOf_QuoteLineItem__c'));
        System.assert(!QuoteSyncUtil.getOppFields().isEmpty());
        
        QuoteSyncUtil.removeQuoteField('TotalInitialPriceOf_QuoteLineItem__c');
        System.assert(!QuoteSyncUtil.getQuoteFields().contains('TotalInitialPriceOf_QuoteLineItem__c'));
        
        QuoteSyncUtil.addQuoteLineField('TotalInitialPriceOf_QuoteLineItem__c','TotalInitialPriceOf_QuoteLineItem__c');
        System.assert(!QuoteSyncUtil.getOppLineFields().isEmpty());
        System.assertEquals('TotalInitialPriceOf_QuoteLineItem__c', QuoteSyncUtil.getQuoteLineFieldMapTo('TotalInitialPriceOf_QuoteLineItem__c'));
        
        QuoteSyncUtil.removeQuoteLineField('TotalInitialPriceOf_QuoteLineItem__c');
        System.assert(!QuoteSyncUtil.getQuoteLineFields().contains('TotalInitialPriceOf_QuoteLineItem__c'));
        
        System.assert(QuoteSyncUtil.getQuoteFieldsString().contains('PaymentTerms__c') );  
        System.assert(QuoteSyncUtil.getQuoteLineFieldsString().contains('Agreement_Date__c') );
        System.assert(QuoteSyncUtil.getOppFieldsString().contains('PaymentTerms__c') );
        QuoteSyncUtil.getOppLineFieldsString(); 
        
        //check add/remove quoteIDs
        QuoteSyncUtil.addNewQuoteId(userInfo.getUserId());
        System.assert(!QuoteSyncUtil.getNewQuoteIds().IsEmpty());
        QuoteSyncUtil.clearNewQuoteIds();
        System.assert(QuoteSyncUtil.getNewQuoteIds().IsEmpty());
        QuoteSyncUtil.addNewQuoteId(userInfo.getUserId());
        QuoteSyncUtil.removeNewQuoteId(userInfo.getUserId());
        QuoteSyncUtil.removeAllNewQuoteIds(new Set<Id>{userInfo.getUserId()});
        QuoteSyncUtil.isNewQuote(userInfo.getUserId()); 
        
        QuoteSyncUtil.getField('Quote','PaymentTerms__c');
        QuoteSyncUtil.getField('Opportunity','PaymentTerms__c');
		QuoteSyncUtil.getField('QuoteLineItem','Agreement_Date__c');
		QuoteSyncUtil.getField('OpportunityLineItem','UnitPrice');

    }
    
    @isTest
    static void syncFields_Test(){
        Opportunity memberShipOpp = TestFactory.getOpportunity();
        Product2 prodId = TestDataUtils.createProduct('Platinumm Membership', 'description', 6, 'Membership');
        prodId.IsActive = true;
        update prodId;
        
        PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = Test.getStandardPricebookId(), Product2Id = prodId.ID, isActive = true, unitPrice = 34);
        insert pbe;
        
        Project__c project = TestFactory.getProject();
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = memberShipOpp.Id, Quantity = 2, UnitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project.Id);
        insert oli;
        List<OpportunityLineItem> oliList = [SELECT Id,PriceBookEntryId,Product2Id,OpportunityId,Projects__c
                                             FROM OpportunityLineItem
                                             Where Projects__c != null];
        Quote quote = new Quote();
        quote.Name = 'Test Quote';
        quote.OpportunityId = memberShipOpp.Id;
        insert quote;
        QuoteLineItem qli = new QuoteLineItem(QuoteId = quote.Id, OpportunityLineItemId = oli.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = oli.PriceBookEntryId, Projects__c = oli.Projects__c);
        insert qli;
        
        QuoteSyncUtil.getOppLineItemVsQuoteLineItemMap(new List<QuoteLineItem>{qli});
        QuoteSyncutil.populateRequiredFields(memberShipOpp);
        QuoteSyncutil.populateRequiredFields(oli);
        QuoteSyncutil.populateRequiredFields(quote);
        QuoteSyncutil.populateRequiredFields(qli);
        
        
        Schema.DescribeFieldResult result = QuoteSyncUtil.getField('OpportunityLineItem', 'Quantity');
        QuoteSyncUtil.createValue(oli, 'OpportunityLineItem', 'Quantity', result, false);
		
        result = QuoteSyncUtil.getField('OpportunityLineItem', 'unitPrice');
        QuoteSyncUtil.createValue(oli, 'OpportunityLineItem', 'unitPrice', result, false);

		result = QuoteSyncUtil.getField('OpportunityLineItem', 'Description');
        QuoteSyncUtil.createValue(oli, 'OpportunityLineItem', 'Description', result, false);
        
        
    }
    
    
    
}