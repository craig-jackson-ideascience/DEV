public class SalesOrderStatusController {
    
    @AuraEnabled
    public static String getSalesOrderStatus(Id assetId){
        String message = '';
        String netsuiteId = [Select Id,NetSuite_ID__c FROM Asset WHERE ID =: assetId].NetSuite_ID__c;
        List<Endpoints__c> endPointObj = new List<Endpoints__c>([select name, endpoint__c, Password__c, User_Id__c, Nlauth_Account__c from Endpoints__c where 
                                                                 name = 'To Get Sales Order Status From NS']);         
        if(!endPointObj.IsEmpty()){
            Map<String,String> bodyMap = new Map<String,String>();
            bodyMap.put('recordtype','salesorder');
            bodyMap.put('id',netsuiteId);
            String body = JSON.serialize(bodyMap);
            HttpResponse response = CallOutToNetSuiteForAsset.calloutToNetSuite(endPointObj[0], 'POST', body);
            if(response.getStatusCode() == 200) {
                System.debug('Body ' + response.getBody() );
                WrapperToGetSalesOrderDataForExisting insertAssetWrapper = (WrapperToGetSalesOrderDataForExisting)JSON.deserialize(response.getBody() , WrapperToGetSalesOrderDataForExisting.class);
                  System.debug('wrapper +' + insertAssetWrapper );
                List<Asset> assets = WrapperToGetSalesOrderDataForExisting.fillingInfo(new List<WrapperToGetSalesOrderDataForExisting> {insertAssetWrapper});
                update assets;                
            }else{
                message = response.getBody();
            }
        }
        return message;
    }

}