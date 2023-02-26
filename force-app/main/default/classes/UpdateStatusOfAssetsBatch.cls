global class UpdateStatusOfAssetsBatch implements Database.Batchable<sObject>,Database.Stateful {

    public Date closeDateForZeroPriceAssets;
     
    public UpdateStatusOfAssetsBatch(Date closeDateForZeroPriceAssets) {
        this.closeDateForZeroPriceAssets = closeDateForZeroPriceAssets;   
    }
   
    public UpdateStatusOfAssetsBatch() {
        this.closeDateForZeroPriceAssets = NULL;   
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Related_To__c, Training__c, Training__r.Category__c, RecordTypeId, RecordType.Name, Opportunity__c, Price, UsageEndDate, PurchaseDate, Opportunity__r.Amount '+
             'FROM Asset WHERE Training__c != NULL AND RecordType.Name = \'Corporate\' AND Training__r.Category__c = \'Subscription\' AND '+
             'Status != \'Expired\' AND Opportunity__c != NULL AND Price != NULL AND PurchaseDate != NULL AND Opportunity__r.Amount != NULL' 
        );
        
    }
    global void execute(Database.BatchableContext bc, List<Asset> scope){
        if(!scope.isEmpty()){
            UpdateStatusOfAssetsBatchHelper.updateAssets(scope, closeDateForZeroPriceAssets);
        }
      
    }       
    global void finish(Database.BatchableContext bc){
    }    
}