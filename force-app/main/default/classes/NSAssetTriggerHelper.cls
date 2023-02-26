/*-********************************************************************************************************
* Name         : NSAssetTriggerHelper
* @Author      : Akshaye Sharma(Akshaye@wiserspread.com)
* @Date        : 15-November-2017
* @Description : This apex class is a helper class for CreateAssetOnClosedWon Trigger.  
* UPDATES
* Version          Developer                    Date                        Description
*-------------------------------------------------------------------------------------------
*     1.0           Akshaye                 15-November-2017                 Initial Creation 
****************************************************************************************************************/

public with sharing class NSAssetTriggerHelper {

        public static void checkRecordTypeAndCallNS(Set<Id> assetNew , String opportunityId , map<id , Opportunity>  triggerNewMap) {
            // check if the NS Sync should be skipped, signaled by Skip_NetSuite_Sync__c checkbox being ticked
            /*list<Asset> assetListForNsSkipCheck = [select id, Skip_NetSuite_Sync__c from Asset where Id IN:assetNew];
            for(Asset asset : assetListForNsSkipCheck) {
                if(asset.Skip_NetSuite_Sync__c == TRUE) {
                    // if ticked, return early before we do the NS Sync
                    return;
                }
            }*/
            Boolean checkAssetRecord = False;
            
            Set<String> assetIdSetOfMembership = new Set<String>();

            // load the Asset record for NS Sync, but only if the Skip_NetSuite_Sync__c checkbox is not ticked
            for(Asset ass : [SELECT id , opportunity__r.recordtype.name FROM Asset WHERE Skip_NetSuite_Sync__c = FALSE AND ID IN: assetNew]) {
                system.debug('**assId'+ass.id);
                if(ass != null && ass.opportunity__c  != null && ass.opportunity__r.recordTypeId != null 
                && (ass.opportunity__r.recordtype.name.equalsIgnoreCase('Membership') || 
                ass.opportunity__r.recordtype.name.equalsIgnoreCase('Alternate Funding'))) {                    
                    assetIdSetOfMembership.add(ass.id);
                    checkAssetRecord = True;
                }
            }
            
            if(checkAssetRecord == True){
                system.debug('**i am in True');
                
                // load the NS endpoint
                list<Endpoints__c> endPointObj = new list<Endpoints__c>([select name, endpoint__c from Endpoints__c where name = 'For Membership Asset']);
                String endPoint = '';
                if(!endPointObj.IsEmpty())
                    endPoint = endPointObj[0].endpoint__c;
    
                // format and send data to NetSuite
                String jsonBody = AssetToSalesOrderHelper.createJSONFromMemeberShipAsset(assetIdSetOfMembership ,opportunityId,  triggerNewMap);
                system.debug('**assetNew'+assetNew);
                system.debug('**assetIdSetOfMembership'+assetIdSetOfMembership);
                if(System.isBatch()){
                     CallOutToNetSuiteForAsset.callOutToNetForMemberAsset(endPoint, 'POST', jsonBody, assetIdSetOfMembership);                    
                }else{
                    CallOutToNetSuiteForAsset.callingCallOutToNet(jsonBody, endPoint , assetIdSetOfMembership);
                    
                }
            }
        }

        public static void checkRecordTypeAndCallNS1(String assetId , String opportunityId , map<id , Opportunity>  triggerNewMap) {

            // check if the NS Sync should be skipped, signaled by Skip_NetSuite_Sync__c checkbox being ticked
            /*list<Asset> assetListForNsSkipCheck = [select id, Skip_NetSuite_Sync__c from Asset where Id =:assetId];
            for(Asset asset : assetListForNsSkipCheck) {
                if(asset.Skip_NetSuite_Sync__c == TRUE) {
                    // if ticked, return early before we do the NS Sync
                    return;
                }
            }*/
            
            Boolean checkAssetRecord = False;

            // we did not exit early, so load the NS API Endpoint and send the data to NS
            list<Endpoints__c> endPointObj = new list<Endpoints__c>([select name, endpoint__c from Endpoints__c where name = 'For Other than Membership Asset']);
            String endPoint = '';
            if(!endPointObj.IsEmpty())
                endPoint = endPointObj[0].endpoint__c;
            system.debug('**assetID1'+ assetId);
            String jsonBody = AssetToSalesOrderHelper.createJSONFromOtherThanMemeberShipAsset(assetId , opportunityId, triggerNewMap);
            list<Asset> assetList = [select id, Skip_NetSuite_Sync__c from Asset where Opportunity__c =:opportunityId AND Skip_NetSuite_Sync__c = FALSE ];
            system.debug('**assetList'+assetList);
            set<id> assetIds = new set <id>();
            for(Asset assetObj : assetList) {
                    if(assetObj != null){
                        assetIds.add(assetObj.id);
                        checkAssetRecord =  True;
                    }
            }
            system.debug('**assetIds'+assetIds);
            if(checkAssetRecord == True){
                if(!Test.isRunningTest()){
                   CallOutToNetSuiteForAsset.callOutToNet( endPoint , 'POST' ,jsonBody  , assetId, assetIds); 
                }
                
            }
        }

}