public class AssetSyncToNetSuiteController {
    @AuraEnabled
    public static String validateAndSyncToNetSuite(Id recordId) {
        String assetId = recordId;
        AssetSyncWrapper wrapper = new AssetSyncWrapper();
        wrapper.isSuccess = false;
        Asset assetObject = [SELECT id ,  memo__c , AccountId ,Bill_To_Account__c,
                             Bill_To_Account__r.Name, installdate , usageenddate ,Opportunity__c,Opportunity__r.recordtype.name,OpportunityLineItem__c,Bill_To_Account__r.billingstate,Bill_To_Account__r.billingcity,Bill_To_Account__r.billingcountry,Bill_To_Account__r.billingpostalcode,Bill_To_Account__r.billingstreet,
                             netsuite_class__c ,Account.name,Account.billingstate,Account.billingcity,Account.billingcountry,Account.billingpostalcode,Account.billingstreet , NetSuite_Location__c,
                             Bill_To_Address__c,Bill_To_Address__r.Name,Bill_To_Address__r.Street__c,Bill_To_Address__r.City__c,Bill_To_Address__r.State__c,Bill_To_Address__r.Zip_Postal_Code__c,Bill_To_Address__r.Country__c FROM Asset WHERE ID = :recordId AND Skip_NetSuite_Sync__c = FALSE];
        
        String billToAddress = AssetToSalesOrderHelper.getBillingAddress(assetObject);
        
        OpportunityLineItem oli = [SELECT id , name , Product_Details__c,Product_Details__r.project__c,
                                   Product_Details__r.project__r.Subsidiary_ID__c,
                                   description__c,Product_Details__r.Netsuite_ID__c,Start_Date__c,
                                   Product_Details__r.Subsidiary_ID__c FROM OpportunityLineItem 
                                   WHERE id=:assetObject.OpportunityLineItem__c AND Skip_NetSuite_Sync__c = FALSE];
        
        if (assetObject.memo__c != null && assetObject.memo__c.length() > 999) {
            wrapper.message = 'memo cant be more than 999 chars ';
        }
        else if (billToAddress == '') {
            wrapper.message = 'Account Billing Address incomplete';
        }
        else if (oli.Start_Date__c == null) {
            wrapper.message = 'The Start Date is not populated.';
        }
        else if (oli.Product_Details__c != null && oli.Product_Details__r.Netsuite_ID__c == null) {
            wrapper.message = 'Product Detail netsuiteId cannot be blank ';
        }
        else if (oli.Product_Details__c != null && oli.Product_Details__r.Subsidiary_ID__c == null) {
            wrapper.message = 'Product Detail subsidiary cannot be blank ';
        }
        else if (oli.description__c != null && oli.description__c.length() > 4000) {
            wrapper.message = 'Opportunity product description cannot be more than 4000 chars ';
        }
        else if(oli.Product_Details__c != null && oli.Product_Details__r.project__c != null && oli.Product_Details__r.project__r.Subsidiary_ID__c == null){
            wrapper.message = 'Projects Subsidiary ID cannot be null';
        }
        else if (assetObject.installdate == null) {
            wrapper.message = 'Start Date cannot be null';
        }
        else if (assetObject.usageenddate == null) {
            wrapper.message = 'End Date cannot be null';
        }
        
        
        Map<String, Schema.SObjectField> mapOfOppFields = Opportunity.getSobjectType().getDescribe().fields.getMap();
        String query = 'SELECT ';
        for(Schema.SObjectField s : mapOfOppFields.values()){
            query += s + ',';
        }
        String query1 = query.removeEnd(',');
        query1 += ' FROM Opportunity WHERE Id = \''+assetObject.Opportunity__c+'\'';
        List<Opportunity> oppList = Database.query(query1);
        Map<Id,Opportunity> mapOfOpportunity = new Map<Id,Opportunity>(oppList);
        
        if(String.isBlank(wrapper.message) ){
            if(assetObject.Opportunity__c != null && (assetObject.Opportunity__r.recordtype.name.equalsIgnoreCase('Membership') 
            || assetObject.Opportunity__r.recordtype.name.equalsIgnoreCase('Alternate Funding'))){
                NSAssetTriggerHelper.checkRecordTypeAndCallNS(new Set<Id>{recordId},assetObject.Opportunity__c,mapOfOpportunity);
                
            }else{
                NSAssetTriggerHelper.checkRecordTypeAndCallNS1(assetId,assetObject.Opportunity__c,mapOfOpportunity);
            }
        }
        return JSON.serialize(wrapper);
    }
    
    public class AssetSyncWrapper{
        @auraEnabled
        public Boolean isSuccess {get;set;}
        @auraEnabled
        public String message {get; set;}
    }
    
    
}