public with sharing class AccountSponsorshipSummaryController {

    @AuraEnabled(cacheable=true)
    public static List<Asset> getSponsorships(ID accountID,ID NewRecordId){
        if(NewRecordId !=null){
        return [SELECT Name, Price, Event__r.BillFromProject__c, Event__r.BillFromProject__r.Name,
                       Product2.Name, Event__r.Name, Status, Year__c
                FROM Asset
                WHERE AccountId = :NewRecordId
                AND Event__c != ''
                AND Product2Id != ''
                AND ProductFamily = 'Event'
                ORDER BY Year__c DESC, Event__r.Name ASC, Product2.Name ASC
               ];
        }else{
             return [SELECT Name, Price, Event__r.BillFromProject__c, Event__r.BillFromProject__r.Name,
                       Product2.Name, Event__r.Name, Status, Year__c
                FROM Asset
                WHERE AccountId = :accountID
                AND Event__c != ''
                AND Product2Id != ''
                AND ProductFamily = 'Event'
                ORDER BY Year__c DESC, Event__r.Name ASC, Product2.Name ASC 
               ];
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset> getTrainingSponsorships(ID accountID,ID NewRecordId){
        system.debug('NewRecordId-->'+NewRecordId);
        if(NewRecordId !=null){
          return [SELECT Name, Price,
                       Product2.Name, Training__r.Name, Status, Year__c
                FROM Asset
                WHERE AccountId = :NewRecordId 
                AND Product2Id != ''
                AND ProductFamily = 'Training'
                AND RecordType.Name = 'Corporate Training'
                ORDER BY Year__c DESC, Training__r.Name ASC, Product2.Name ASC
               ];
        }else{
            return [SELECT Name, Price,
                       Product2.Name, Training__r.Name, Status, Year__c
                FROM Asset
                WHERE AccountId = :accountID 
                AND Product2Id != ''
                AND ProductFamily = 'Training'
                AND RecordType.Name = 'Corporate Training'  
                ORDER BY Year__c DESC, Training__r.Name ASC, Product2.Name ASC
               ];
        }
    }

}