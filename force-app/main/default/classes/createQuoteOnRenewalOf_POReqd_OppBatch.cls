public class createQuoteOnRenewalOf_POReqd_OppBatch implements Database.Batchable<sObject>{
    
    public Map<Id, Quote> oppIdVSquoteMap = new Map<Id, Quote>();
    
    public Database.QueryLocator start(database.batchablecontext BC){
        String query = 'SELECT Id, Name, Opportunity_PO_Required__c,Days_to_Close__c,Pricebook2Id  FROM Opportunity WHERE Type = \'Renewal\' AND' + 
                       ' isClosed = false AND Opportunity_PO_Required__c = true AND RecordType.Name = \'Membership\' AND SyncedQuoteId = null';
        return Database.getQueryLocator(query);
        
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        System.debug('scope '+scope.size());
        Map<Id, Id> oppIdVsQuoteId = new Map<Id, Id>();
        for (Opportunity opp : scope){
            if (opp.Opportunity_PO_Required__c){
                Quote quote = new Quote(Name = opp.Name, OpportunityId = opp.Id, Pricebook2Id = opp.Pricebook2Id);
                oppIdVSquoteMap.put(opp.Id, quote);
            }
        }
        if (!oppIdVSquoteMap.isEmpty()){
            insert oppIdVSquoteMap.values();
            List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId, UnitPrice, Quantity, PricebookEntryId, Product2Id,
                                                 Discount, ServiceDate, SortOrder FROM OpportunityLineItem
                                                 WHERE OpportunityId IN:oppIdVSquoteMap.keySet()];

            List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            //Iterate on oppLineItem
            for (OpportunityLineItem oli : oliList){
                if (oppIdVSquoteMap.containsKey(oli.OpportunityId)){
                    //create instance of quotelineitem
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.quoteId = oppIdVSquoteMap.get(oli.OpportunityId).Id;
                    qli.UnitPrice = oli.UnitPrice;
                    qli.Product2Id = oli.Product2Id;
                    qli.Quantity = oli.Quantity;
                    qli.PriceBookentryid = oli.PriceBookentryId;
                    qli.OpportunityLineItemId = oli.Id;
                    qli.Discount = oli.Discount;
                    qli.ServiceDate = oli.ServiceDate;
                    qliList.add(qli);
                    oppIdVsQuoteId.put(oli.opportunityId, qli.quoteId);
                }
            }
            if (!qliList.isEmpty())
                insert qliList;
            List<Opportunity> updateOpp = new List<Opportunity>();
            //query opp again incase opp is not created
            if (!oppIdVsQuoteId.isEmpty()){
                for (Opportunity opp : [SELECT Id, SyncedQuoteId
                                        FROM Opportunity
                                        WHERE Id IN:oppIdVsQuoteId.keySet()]){
                    opp.SyncedQuoteId = oppIdVsQuoteId.get(opp.Id);
                    updateOpp.add(opp);
                }

                if (!updateOpp.isEmpty())
                    update updateOpp;
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        
    }
}