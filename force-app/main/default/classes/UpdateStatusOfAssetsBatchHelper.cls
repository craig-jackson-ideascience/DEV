public with sharing class UpdateStatusOfAssetsBatchHelper {  


    public static void updateAssets(List<Asset> assetList, Date closeDateForZeroPriceAssets) {
        Map<Id, Asset> updateAssets = new Map<Id, Asset>();
        for(Asset assetRec : assetList) {
            Integer month = assetRec.PurchaseDate.month();
            Integer day = assetRec.PurchaseDate.day();
            Date dateObj = NULL;
            if(assetRec.Opportunity__r.Amount > 0) {
                dateObj = assetRec.PurchaseDate.addYears(1).addDays(-1);
            }
            else if((day != 1 || month != 1) && (day != 31 || month != 12)){ 
                if(closeDateForZeroPriceAssets != NULL) {
                    dateObj = closeDateForZeroPriceAssets;
                }
                else {
                    dateObj = Date.newInstance(assetRec.PurchaseDate.year(), 12, 31);
                }
            }  

            if(dateObj != NULL && (dateObj == system.Today() || dateObj == closeDateForZeroPriceAssets) ) {
                assetRec.Status = 'Expired';
                updateAssets.put(assetRec.Id, assetRec);
            }  
        }
        
        if(!updateAssets.isEmpty()) {
            update updateAssets.values();
        }
    }
}