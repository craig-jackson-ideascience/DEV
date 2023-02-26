public class QuoteLineItemTriggerHandler implements ITriggerHandler {
    public static void BeforeInsert(List<SObject> triggerNew) {
        //validateEngagementPeriodForSubscriptionProducts((List<QuoteLineItem>) triggerNew);
        syncQuoteFields((List<QuoteLineItem>)triggerNew);
    }
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        recalculateSalesPrice((Map<Id, QuoteLineItem>) newMap, (Map<Id, QuoteLineItem>) oldMap);
    }
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    }
    
    public static void AfterInsert(Map<Id, SObject> newMap) {
         //call method to sync oppLineItem and QuoteLineItem
       quoteLineSyncMethod((Map<Id, QuoteLineItem>) newMap,null);
    
        prePopulateInitialPrice((List<QuoteLineItem>) newMap.values());
        updateRollupOnQuote((List<QuoteLineItem>) newMap.values(),null);
        updateParentProductonSubproducts((Map<Id, QuoteLineItem>) newMap);
        updateRollupFieldsOnParentProduct((Map<Id, QuoteLineItem>) newMap, null);
        
    }
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap) {
        prepopulateQuantityAndDiscountOnChildProduct((Map<Id, QuoteLineItem>) newMap, (Map<Id, QuoteLineItem>) oldMap);        
        updateRollupOnQuote((List<QuoteLineItem>) newMap.values(),(Map<Id, QuoteLineItem>) oldMap);     
        updateRollupFieldsOnParentProduct((Map<Id, QuoteLineItem>) newMap, (Map<Id, QuoteLineItem>) oldMap);
         //call method to sync oppLineItem and QuoteLineItem
         quoteLineSyncMethod((Map<Id, QuoteLineItem>) newMap, (Map<Id, QuoteLineItem>) oldMap);
        
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) {
    }
    
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after undelete actions
    }
    
    public Boolean IsDisabled() {
        System.debug(TriggerStopper.stopQuoteLine + '====> TriggerStopper.stopQuoteLine');
        return TriggerStopper.stopQuoteLine;
    }

    
    private static void syncQuoteFields(List<QuoteLineItem> newQliItems){
        if (QuoteSyncUtil.isRunningTest){
            for (QuoteLineItem qli : newQliItems) {
                QuoteSyncUtil.populateRequiredFields(qli);
            }
        }   
    }
    
    //method to sync oppLineItem and QuoteLineItem
    private static void quoteLineSyncMethod(Map<Id, QuoteLineItem> newMap,Map<Id, QuoteLineItem> oldMap) {
        List<QuoteLineItem> quoteLineItemList;
        //if insert then query quotelineitem to get its quote issyncing
        if(oldMap == null){
            quoteLineItemList=[SELECT Id,OpportunityLineItemId,Quote.isSyncing FROM QuoteLineItem 
                               WHERE ID IN: newMap.keySet()];
        }
        //if update then get only quotelineitem whose quote issyncing
        else if(oldMap != null){
            quoteLineItemList=[SELECT Id,OpportunityLineItemId,Quote.isSyncing FROM QuoteLineItem 
                               WHERE ID IN: newMap.keySet() AND Quote.isSyncing = true];
        }
        //if list is not empty
        if(!quoteLineItemList.isEmpty())   {
            List<OpportunityLineItem> updateOlis = new List<OpportunityLineItem>();
            List<QuoteLineItem> updateQlis = new List<QuoteLineItem>();
            
            //map of oppLineItem vs its quotelineitem object
            Map<Id,QuoteLineItem> oppLineItemIDVSQuoteLineItemMap=QuoteSyncUtil.getOppLineItemVsQuoteLineItemMap(quoteLineItemList);
            
            //get custom field to map of quotelineitem and opplineitem
            Set<String> quoteLineFields = QuoteSyncUtil.getQuoteLineFields();
            String oliFields = QuoteSyncUtil.getOppLineFieldsString();
            Set<Id> oppLineItemIdSet = oppLineItemIDVSQuoteLineItemMap.keySet();
            
            //query on opplineitem
            String oliQuery = 'select Id, OpportunityId, PricebookEntryId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' + oliFields +
                ' from OpportunityLineItem where Id IN:oppLineItemIdSet order by OpportunityId, SortOrder ASC';   
            List<OpportunityLineItem> olis = Database.query(oliQuery); 
            
            //iterate through each record
            for(OpportunityLineItem oli:olis){

                //if map contains 
                if(oppLineItemIDVSQuoteLineItemMap.containsKey(oli.Id)){
                    
                    boolean updateOli = false;
                    //get corresponding quotelineitem
                    QuoteLineItem qli = oppLineItemIDVSQuoteLineItemMap.get(oli.Id);
                    //trigger instance
                    QuoteLineItem completeQli = newMap.get(qli.Id);
                    QuoteLineItem oldQli = null;
                    //if all the specified fields matches between quotelineitem and oppLineItem       
                    if (oli.pricebookentryid == completeQli.pricebookentryId  
                        && oli.UnitPrice == completeQli.UnitPrice
                        // && oli.Quantity == qli.Quantity
                        && oli.Discount == completeQli.Discount
                        && oli.ServiceDate == completeQli.ServiceDate
                        && oli.SortOrder == completeQli.SortOrder
                       ) {
                           //if update trigger
                           if (oldMap != null) {
                               oldQli = oldMap.get(qli.Id);
                               
                               //if condition is true then we will update Quotelineitem
                               if (completeQli.UnitPrice == oldQli.UnitPrice
                                   && completeQli.Quantity == oldQli.Quantity
                                   && completeQli.Discount == oldQli.Discount
                                   && completeQli.ServiceDate == oldQli.ServiceDate
                                   && completeQli.SortOrder == oldQli.SortOrder 
                                  ){
                                      updateOli = true;                       
                                  }             
                           }
                           boolean hasChange = false;
                           
                           //iterate through each record
                           for (String qliField : quoteLineFields) {
                               //get corresponding opportunityLineItem field
                               String oliField = QuoteSyncUtil.getQuoteLineFieldMapTo(qliField);
                               Object oliValue = oli.get(oliField);
                               Object qliValue = completeQli.get(qliField);
                               
                               //if value is change
                               if (oliValue != qliValue) { 
                                   //if insert then update quotelineitem
                                   if (oldMap == null && (qliValue == null || (qliValue instanceof Boolean && !Boolean.valueOf(qliValue)))){ 
                                       
                                       // If it's a newly created Quote, don't sync the "Description" field value, 
                                       // because it's already copied from Opportunity Line Item on create. 
                                       if (qli.quote.isSyncing || (!qliField.equalsIgnoreCase('description'))) {                                     
                                           qli.put(qliField, oliValue);
                                           hasChange = true; 
                                       }    
                                   }
                                   //if update and flag updateOli is false then update quotelineitem
                                   else if (oldMap != null && !updateOli ) {
                                       qli.put(qliField, oliValue);
                                       /*if (oliValue == null) qli.put(qliField, null);
                                       else qli.put(qliField, oliValue);*/
                                       hasChange = true;
                                   }
                                   //if update and flag updateOli is true then update opplineitem
                                   else if (oldMap != null && updateOli) {
                                       oli.put(oliField, qliValue);
                                       /*if (qliValue == null) oli.put(oliField, null);
                                       else oli.put(oliField, qliValue);*/
                                       hasChange = true;
                                   }
                               }    
                           }
                           
                           if (hasChange) {
                               //add to list
                               if (oldMap == null || (oldMap != null && !updateOli)) { 
                                   updateQlis.add(qli);
                               } else if (oldMap != null && updateOli) {                               
                                   updateOlis.add(oli);
                               }                    
                           } 
                       }
                }
            }
            TriggerStopper.stopOpp = true;
            TriggerStopper.stopQuote = true;             
            TriggerStopper.stopOppLine = true;
            TriggerStopper.stopQuoteLine = true;   
            
            if (!updateOlis.isEmpty()) { 
                //update
                Database.update(updateOlis);              
            }
            if (!updateQlis.isEmpty()) {
                //update
                Database.update(updateQlis);            
            }
            
            TriggerStopper.stopOpp = false;
            TriggerStopper.stopQuote = false;                
            TriggerStopper.stopOppLine = false;          
            TriggerStopper.stopQuoteLine = false;   
        }
    }
    
    
    /*private static void validateEngagementPeriodForSubscriptionProducts(List<QuoteLineItem> triggerNew){
        Set<Id> opportunityLineItemIDs = new Set<Id>();
        for(QuoteLineItem qli:triggerNew){
            opportunityLineItemIDs.add(qli.OpportunityLineItemId);
        }
        if(!opportunityLineItemIDs.isEmpty()){
            Map<Id,OpportunityLineItem> subscriptionLineItems = new Map<Id,OpportunityLineItem>([SELECT Id,OpportunityId,Training__r.Category__c,
                                                                                                 Opportunity.Engagement_Period__c 
                                                                                                 FROM OpportunityLineItem 
                                                                                                 WHERE Id IN : opportunityLineItemIDs AND 
                                                                                                 Training__r.Category__c IN ('Subscription','Certification') AND 
                                                                                                 Opportunity.Subscription_Expiration_Date__c = null]);
            if(!subscriptionLineItems.isEmpty()){
                for(QuoteLineItem qli:triggerNew){
                    if(subscriptionLineItems.containsKey(qli.OpportunityLineItemId)){
                        qli.addError('Subscription/Certification Expiration Date field on Opportunity is required for subscription & certification products');
                    }
                }
            }
        }
    }*/
      
    public static void updateParentProductonSubproducts(Map<Id, QuoteLineItem>newMap) {
        List<QuoteLineItem> qliList = [SELECT Id,OpportunityLineItem.Parent_product__c,OpportunityLineItem.Parent_OppLineItem__c 
        FROM QuoteLineItem WHERE Id IN:newMap.keySet() AND OpportunityLineItem.Parent_product__c != null];
        List<QuoteLineItem> quoteLines = new List<QuoteLineItem>();
        if (!qliList.isEmpty()) {
            for (QuoteLineItem qli : qliList) {
                system.debug('qlik '+qli);
                qli.Parent_Product__c = qli.OpportunityLineItem.Parent_product__c;
                qli.Parent_OppLineItem__c = qli.OpportunityLineItem.Parent_OppLineItem__c;
                quoteLines.add(qli);
                System.debug('olik'+qli.parent_opplineitem__c);
            }
            
            if (!quoteLines.isEmpty()) {
                update quoteLines;
            }
        }
    }
    
    public static void updateRollupFieldsOnParentProduct(Map<Id, QuoteLineItem>newMap, Map<Id, QuoteLineItem>oldMap) {
        System.debug('1called2' + limits.getQueries());
        List<QuoteLineItem> quoteLineItems = [
            SELECT Id,Parent_Product__c,opportunitylineitem.Training_Category__c,Product2Id,Quantity,Parent_OppLineItem__c,
            UnitPrice,Discount_Amount__c,Net_Price__c,TotalPrice,QuoteId,Initial_Price__c
            FROM QuoteLineItem
            WHERE ID IN:newMap.keySet() AND Quote.Opportunity_RecordType__c = 'Corporate Training' 
            AND Parent_OppLineItem__c != null AND Parent_Product__c != null
        ];
        Map<Id, Set<Id>> quoteIdVsParentProductList = new Map<Id, Set<Id>>();
        Set<Id> parentProducts = new Set<Id>();
        List<QuoteLineItem> parentProductQliList = new List<QuoteLineItem>();
        Map<Id, Set<QuoteLineItem>> subProductVsQliListMap = new Map<Id, Set<QuoteLineItem>>();
        System.debug('1called');
        System.debug('1called2' + limits.getQueries());
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        if(!quoteLineItems.isEmpty()){
        for (QuoteLineItem qli : quoteLineItems) {
            if (oldMap == null || (oldMap != null && (qli.Initial_Price__c != oldMap.get(qli.Id).Initial_Price__c || 
                                                      qli.Quantity != oldMap.get(qli.Id).Quantity || qli.UnitPrice != oldMap.get(qli.Id).UnitPrice ||
                                                      qli.Discount_Amount__c != oldMap.get(qli.Id).Discount_Amount__c || qli.Net_Price__c != oldMap.get(qli.Id).Net_Price__c
                                                      || qli.TotalPrice != oldMap.get(qli.Id).TotalPrice) && qli.Parent_Product__c != null)) {
                                                          if (!quoteIdVsParentProductList.containsKey(qli.QuoteId)) {
                                                              quoteIdVsParentProductList.put(qli.QuoteId, new Set<Id>());
                                                          }
                                                          
                                                          quoteIdVsParentProductList.get(qli.QuoteId).add(qli.Parent_OppLineItem__c);
                                                          parentProducts.add(qli.Parent_OppLineItem__c);
                                                      }
        }
        if(!quoteIdVsParentProductList.isEmpty()){
        List<QuoteLineItem> quoteLines = [
            SELECT Id,Parent_Product__c,Product2Id,QuoteId,Quantity,UnitPrice,Discount_Amount__c,Net_Price__c,Discount,
            TotalPrice,Subtotal,Initial_Price__c,Discount_in_amount__c,Parent_OppLineItem__c,OpportunityLineItemId
            FROM QuoteLineItem
            WHERE QuoteId IN:quoteIdVsParentProductList.keySet() AND
            (OpportunityLineItemId IN:parentProducts OR Parent_OppLineItem__c IN:parentProducts)
        ];
        
        if (!quoteLines.isEmpty()) {
            for (QuoteLineItem qli : quoteLines) {
                if (qli.Parent_OppLineItem__c == null) {
                    parentProductQliList.add(qli);
                } else {
                    if (quoteIdVsParentProductList.containsKey(qli.QuoteId) && quoteIdVsParentProductList.get(qli.QuoteId).contains(qli.Parent_OppLineItem__c)) {
                        if (!subProductVsQliListMap.containsKey(qli.Parent_OppLineItem__c)) {
                            subProductVsQliListMap.put(qli.Parent_OppLineItem__c, new Set<QuoteLineItem>());
                        }
                        subProductVsQliListMap.get(qli.Parent_OppLineItem__c).add(qli);
                    }
                }
            }
        }
        if (!parentProductQliList.isEmpty()) {
            updateRollupFields(parentProductQliList, subProductVsQliListMap);
        }
    }
    }
}
    
    private static void updateRollupFields(List<QuoteLineItem> parentProductQliList, Map<Id, Set<QuoteLineItem>> subProductVsQliListMap) {
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        for (QuoteLineItem qli : parentProductQliList) {
            QuoteLineItem quoteLine = new QuoteLineItem();
            quoteLine.Id = qli.Id;
            Decimal unitPrice = 0;
            Decimal discount = 0;
            Decimal totalPrice = 0;
            if (!subProductVsQliListMap.IsEmpty() && subProductVsQliListMap.containskey(qli.OpportunityLineItemId)) {
                for (QuoteLineItem subQli : subProductVsQliListMap.get(qli.OpportunityLineItemId)) {
                    
                    unitPrice += subQli.Discount_in_amount__c != null && subQli.Discount_in_amount__c != 0?
                         subQli.Initial_Price__c * subQli.Quantity:
                        subQli.Subtotal ;
                    discount += subQli.Discount != null ?
                        (subQli.Discount_Amount__c * subQli.Quantity)
                        :(subQli.Discount_in_amount__c != null ? subQli.Discount_in_amount__c : 0);
                            totalPrice += subQli.TotalPrice;
                }
               
                quoteLine.RollUp_UnitPrice__c = unitPrice;
                quoteLine.RollUp_Discount__c = discount;
                quoteLine.RollUp_Netprice__c = totalPrice;
                quoteLine.RollUp_TotalPrice__c = totalPrice;
                qliList.add(quoteLine);
            }
        }
        if (!qliList.isEmpty()) {
            update qliList;
        }
    }
    
    //Method to Recalculate Sales Price of QuoteLineItem When Discount(In amount) is applied
    public static void recalculateSalesPrice(Map<Id, QuoteLineItem> newMap, Map<Id, QuoteLineItem> oldMap) {
        for (QuoteLineItem quolineItem : newMap.values()) {
            
            if ((quolineItem.Discount_in_amount__c != oldMap.get(quolineItem.Id).Discount_in_amount__c ||
                 quolineItem.Quantity != oldMap.get(quolineItem.Id).Quantity ||
                 quolineItem.Initial_Price__c != oldMap.get(quolineItem.Id).Initial_Price__c)&&
                quolineItem.Initial_Price__c != 0 
               ){
                   
                   Decimal discountAmount =  quolineItem.Discount_in_amount__c ;

                   //if Discount-In-Amount field is null then need to update the unitprice with initial price
                   if(discountAmount == null){
                       quolineItem.UnitPrice = quolineItem.Initial_Price__c;
                   }else{
                   if(discountAmount != null && discountAmount != 0 && quolineItem.Initial_Price__c == null){
                     quolineItem.addError('Initial Price can \'t be blank if you are applying Discount Amount');  
                   }else if(quolineItem.Initial_Price__c >= (discountAmount/quolineItem.Quantity) && discountAmount >= 0){
                       quolineItem.UnitPrice = quolineItem.Initial_Price__c - (discountAmount/quolineItem.Quantity);
                   }else if(discountAmount < 0){
                       quolineItem.addError('Discount Amount can\'t be negative');
                   }else if(quolineItem.Initial_Price__c != null){
                       quolineItem.addError('Discount Amount must be less than or equal to Total Price');
                   }
               }
               }
        }
        
    }
    
    //Method to update the totalInitialprice field on quote
    public static void updateRollupOnQuote(List<QuoteLineItem> triggerNew,Map<Id, QuoteLineItem> oldMap) {
        List<Quote> quoteToUpdate = new List<Quote>();
        Map<Id,Decimal> quoteIdVSTotalInitialPrice = new Map<Id,Decimal>();
        Set<Id> quoteIdSet = new Set<Id>();
        for(QuoteLineItem qulineItem : triggerNew){
            
            if(oldmap == null || 
                (oldMap != null && 
                 (oldMap.get(qulineItem.Id).Quantity != qulineItem.Quantity ||
                  oldMap.get(qulineItem.Id).Initial_Price__c != qulineItem.Initial_Price__c))){
                   System.debug('if uda');
                   quoteIdSet.add(qulineItem.QuoteId);
               }
        }
        
        if(!quoteIdSet.isEmpty()){
            List<QuoteLineItem> quoteLineItemsList =[SELECT Id,Initial_Price__c,Quantity,QuoteId FROM QuoteLineItem WHERE QuoteId IN: quoteIdSet];
            for(QuoteLineItem qulineItem : quoteLineItemsList){
                if(qulineItem.Initial_Price__c != null && qulineItem.Quantity != null){
                Decimal subTotal = qulineItem.Initial_Price__c * qulineItem.Quantity ;
                if(!quoteIdVSTotalInitialPrice.containsKey(qulineItem.QuoteId)){
                    quoteIdVSTotalInitialPrice.put(qulineItem.QuoteId,0);
                }
                quoteIdVSTotalInitialPrice.put(qulineItem.QuoteId,
                                               quoteIdVSTotalInitialPrice.get(qulineItem.QuoteId)+subTotal);
            }
            }
            
            for(Id quoteId : quoteIdSet){
                Quote quoteObj = new Quote(Id=quoteId);
                quoteObj.TotalInitialPriceOf_QuoteLineItem__c = quoteIdVSTotalInitialPrice.containsKey(quoteId) ? quoteIdVSTotalInitialPrice.get(quoteId) : null;
                quoteToUpdate.add(quoteObj);
            }
            System.debug('quoteToUpdate '+quoteToUpdate);
            if(!quoteToUpdate.isEmpty()){
                update quoteToUpdate;
            }
        }
    }
    
    //Method to prepopulate initial price of QuoteLineItem as salesPrice of OpportunityLineItem
    public static void prePopulateInitialPrice(List<QuoteLineItem> triggerNew) {
        
        List<QuoteLineItem> quoteLineItemsToUpdate = new List<QuoteLineItem>();
        List<QuoteLineItem> quoteLineItems = [
            SELECT ID,Quote.Opportunity_RecordType__c,Initial_Price__c,OpportunityLineItem.UnitPrice
            FROM QuoteLineItem
            WHERE id = :triggerNew AND
            Quote.Opportunity_RecordType__c = 'Corporate Training'            
        ];
        for (QuoteLineItem quotelineItem : quoteLineItems) {
            
            if (quotelineItem.OpportunityLineItem.UnitPrice != null) {
                
                QuoteLineItem quotelineItemObj = new QuoteLineItem(Id = quotelineItem.Id);
                quotelineItemObj.Initial_Price__c = quotelineItem.OpportunityLineItem.UnitPrice ;
                quoteLineItemsToUpdate.add(quotelineItemObj);
            }
        }
        if (!quoteLineItemsToUpdate.isEmpty()) {
            update quoteLineItemsToUpdate;
        }
    }
    public static void prepopulateQuantityAndDiscountOnChildProduct(Map<Id, QuoteLineItem>newMap, Map<Id, QuoteLineItem>oldMap) {
        //Initialize variable
        Map<Id,Map<Id,QuoteLineItem>> quoteIdVsoliIdVsQuoteLineItem = new Map<Id,Map<Id,QuoteLineItem>>();
        Set<Id> parentOli = new Set<Id>();
        List<QuoteLineItem> qliList = [SELECT Id,Discount,Quantity,Discount_in_amount__c,Product2Id,QuoteId,
                                       OpportunityLineItem.Training__r.category__c ,OpportunityLineItemId
                                       FROM QuoteLineItem WHERE Id IN:newMap.keySet() AND 
                                       Parent_product__c = null AND Parent_OppLineItem__c = null AND
                                      OpportunityLineItem.Training__r.category__c = 'Bundle'];
        System.debug('qliList '+qliList);
        //Iterate through QuoteLineitem
        for(QuoteLineItem quoteLineItem :qliList){
                QuoteLineItem oldQuoteLineItem = oldmap.get(quoteLineItem.Id);
                
                //Quantity or discount is changed
                if(quoteLineItem.Quantity != oldQuoteLineItem.Quantity ||
                   quoteLineItem.Discount != oldQuoteLineItem.Discount ||
                  quoteLineItem.Discount_in_amount__c != oldQuoteLineItem.Discount_in_amount__c){
                      
                       Map<Id,QuoteLineItem> oliIdIdVsquoteLineItem = new Map<Id,QuoteLineItem>();
                       oliIdIdVsquoteLineItem.put(quoteLineItem.OpportunityLineItemId,quoteLineItem);
                       
                       //Store Quoteid Vs ProductId Vs QuoteLineItem to a map
                       quoteIdVsoliIdVsQuoteLineItem.put(quoteLineItem.QuoteId,oliIdIdVsquoteLineItem);
                       parentOli.add(quoteLineItem.OpportunityLineItemId);
            }
        }
        system.debug('quoteIdVsoliIdVsQuoteLineItem '+quoteIdVsoliIdVsQuoteLineItem);
        system.debug('parentOli '+parentOli);
        if(!quoteIdVsoliIdVsQuoteLineItem.isEmpty()){
            //Retrieve sub product of parent bundle product
            List<QuoteLineItem> quoteLines = [SELECT Id,QuoteId,Parent_OppLineItem__c
                                              FROM QuoteLineItem
                                              WHERE QuoteId IN: quoteIdVsoliIdVsQuoteLineItem.keySet() AND
                                              Parent_OppLineItem__c IN:parentOli];
            system.debug('quoteLines '+quoteLines);
            if(!quoteLines.isEmpty()){
                //Iterate through lineitems
                for(QuoteLineItem quoteLine : quoteLines){
                    if(quoteIdVsoliIdVsQuoteLineItem.containsKey(quoteLine.QuoteId) && 
                       quoteIdVsoliIdVsQuoteLineItem.get(quoteLine.QuoteId).containsKey(quoteLine.Parent_OppLineItem__c) 
                      ){
                          //Populate discount and quantity
                          QuoteLineItem parentQuoteLineItem = quoteIdVsoliIdVsQuoteLineItem.get(quoteLine.QuoteId).
                              get(quoteLine.Parent_OppLineItem__c);
                          quoteLine.Discount = parentQuoteLineItem.Discount;
                          quoteLine.Quantity = parentQuoteLineItem.Quantity;
                          quoteLine.Discount_in_amount__c = parentQuoteLineItem.Discount_in_amount__c;
                      }
                }
                //update quotelineitems
                update quoteLines;
            }
        }
    }
}