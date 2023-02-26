global class BatchForProjectEvent implements Database.Batchable<sObject>, database.allowsCallouts , Database.stateful{
        Set<String> idSetTemp = new Set<String>();
        global BatchForProjectEvent(Set<String> idSet){
                   // Batch Constructor
            idSetTemp = idSet;               
        }
       
        // Start Method
        global Database.QueryLocator start(Database.BatchableContext BC){
         return Database.getQueryLocator('select id from product_details__c WHERE ID IN:idsetTemp');
        }
      
      // Execute Logic
       
       global void execute(Database.BatchableContext BC, List<sObject>scope){
             // NetSuiteToSalesforce.callingCallOutToNet();
             for(sObject obj : scope){      
                 NSProductDetailHelper.mappingFromSFToNSThroughBatch(obj.id );
             }
       }
     
       global void finish(Database.BatchableContext BC){
            // Logic to be Executed at finish
       }
    }