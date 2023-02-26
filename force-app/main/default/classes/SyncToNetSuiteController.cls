public class SyncToNetSuiteController {
 @AuraEnabled
    public static String checkObjectType(Id recordId , String sObjectName){
        if(sObjectName == 'Hotel_Commissions__c' ){
            return HotelCommissionSyncToNetSuiteController.validateAndSyncToNetSuite(recordId);
        }
        else if(sObjectName == 'EMS__c'){
            return EMSSyncToNetSuiteController.validateAndSyncToNetSuite(recordId);
        }
        else{
            return AssetSyncToNetSuiteController.validateAndSyncToNetSuite(recordId);
        } 
           
    }
}