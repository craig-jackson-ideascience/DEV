public class QuoteTriggerHandler implements ITriggerHandler {
    public static void BeforeInsert(List<SObject> triggerNew) {
        //validateEngagementPeriodForSubscriptionProducts((List<Quote>) triggerNew);
    }
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        
    }
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    }
    
    public static void AfterInsert(Map<Id, SObject> newMap) {
        //call method to get values from opportunity to Quote
        quoteSyncmethod((Map<Id, Quote>) newMap, null);
   
        //quoteSynq((Map<Id, Quote>) newMap,null);
    }
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap) {
         //call method to sync opportunity and  Quote if quote is syncing
        quoteSyncmethod((Map<Id, Quote>) newMap, (Map<Id, Quote>) oldMap);
    
        //quoteSynq((Map<Id, Quote>) newMap,(Map<Id, Quote>) oldMap);
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) {
        
    }
    
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after undelete actions
    }
    
    public Boolean IsDisabled() {
        System.debug(TriggerStopper.stopQuote + '====> TriggerStopper.stopQuote');
        return TriggerStopper.stopQuote;
    }
    
     private static void quoteSyncmethod(Map<Id, Quote> newMap, Map<Id, Quote> oldMap){
        
        Map<Id, Id> startSyncQuoteMap = new Map<Id, Id>();
        for (Quote quote : newMap.values()) {
            //if insert or(update and issyncing) then add to map
            if (oldMap == null ||(quote.isSyncing && oldMap!= null)) {
                startSyncQuoteMap.put(quote.OpportunityId,quote.Id);
            }
        }
        
        //if map is not empty
        if(!startSyncQuoteMap.isEmpty()){
            TriggerStopper.stopQuote = true;    
            //get custom fields of quotes to map
            Set<String> quoteFields = QuoteSyncUtil.getQuoteFields();
            String opp_fields = QuoteSyncUtil.getOppFieldsString();
            //get ids of opportunity to query
            Set<Id> opportunityIdList = startSyncQuoteMap.keyset();
            //query
            String oppQuery = 'select Id, HasOpportunityLineItem' + opp_fields + ' from Opportunity where Id IN:opportunityIdList';
            
            List<Opportunity> opps = Database.query(oppQuery);
            List<Opportunity> updateOpps = new List<Opportunity>();
            List<Quote> updateQuotes = new List<Quote>(); 
            
            //iterate through opportunities
            for (Opportunity opp : opps) {
                
                //Get quote id
                Id quoteId = startSyncQuoteMap.get(opp.Id);
                //trigger instance
                Quote quote = newMap.get(quoteId);
                //instance of quote that can be updated
                Quote updatequote = new Quote(Id=quoteId);
                boolean hasChange = false;
                
                //Iterate through each custom field
                for (String quoteField : quoteFields) {
                    //get corresponding opportunity fields
                    String oppField = QuoteSyncUtil.getQuoteFieldMapTo(quoteField);
                    Object oppValue = opp.get(oppField);
                    Object quoteValue = quote.get(quoteField);
                    
                    //if value is change
                    if (oppValue != quoteValue) {    
                        //if insert then update quote
                        if (oldMap== null && (quoteValue == null || (quoteValue instanceof Boolean && !Boolean.valueOf(quoteValue)))) {
                            updatequote.put(quoteField, oppValue);
                            hasChange = true;                          
                        } 
                        //if update trigger then update opportunity
                        else if (oldMap != null) {
                            opp.put(oppField, quoteValue);
                            /*if (quoteValue == null) opp.put(oppField, null);
                            else opp.put(oppField, quoteValue);*/
                            hasChange = true;                          
                        }                    
                    }                     
                }    
                
                if (hasChange) {
                    //add to list
                    if (oldMap == null) { 
                        updateQuotes.add(updatequote);
                    } else if (oldMap != null) {
                        updateOpps.add(opp);                
                    }               
                }                                  
            }
            
            if (oldMap == null && !updateQuotes.isEmpty()) {
                //update
                Database.update(updateQuotes);
            } else if (oldMap != null && !updateOpps.isEmpty()) {
                TriggerStopper.stopOpp = true;   
                //update
                Database.update(updateOpps);
                TriggerStopper.stopOpp = false;              
            }    
            TriggerStopper.stopQuote = false; 
        }
    }
  
    /*private static void validateEngagementPeriodForSubscriptionProducts(List<Quote> triggerNew){
        Set<Id> opportunityIDs = new Set<Id>();
        for(Quote quote:triggerNew){
            opportunityIDs.add(quote.OpportunityId);
        }
        if(!opportunityIDs.isEmpty()){
            Set<Id> subscriptionOpportunity = new Set<Id>();
            List<OpportunityLineItem> subscriptionLineItems = [SELECT Id,OpportunityId,Training__r.Category__c,Opportunity.Engagement_Period__c 
                                                               FROM OpportunityLineItem 
                                                               WHERE OpportunityId IN : opportunityIDs AND 
                                                               Training__r.Category__c IN ('Subscription', 'Certification') AND 
                                                               Opportunity.Subscription_Expiration_Date__c = null];
            if(!subscriptionLineItems.isEmpty()){
                for(OpportunityLineItem oli :subscriptionLineItems){
                    subscriptionOpportunity.add(oli.OpportunityId);
                }
                for(Quote quote:triggerNew){
                    if(subscriptionOpportunity.contains(quote.OpportunityId)){
                        quote.addError('Subscription/Certification Expiration Date field on Opportunity is required for subscription & certification products');
                    }
                }
            }
        }
    }*/
    
}