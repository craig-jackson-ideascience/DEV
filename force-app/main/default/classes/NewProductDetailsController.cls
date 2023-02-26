public class NewProductDetailsController {
    @AuraEnabled
    public static String getRecordTypeId(String objectName){
        switch on objectName {
            when 'Project__c' {
                return PicklistOptionsUtility.getProductDetailsRecordTypeId('Membership');
            }
            when 'Event__c' {
                return PicklistOptionsUtility.getProductDetailsRecordTypeId('Event');
            }
            when 'Training__c'{
                return PicklistOptionsUtility.getProductDetailsRecordTypeId('Training');
            }
            when else {
                return null;
            }
        }
    }

    /**
     * Method to get RecordTypeId For ProductDetail When launched from a project record
     * that is to get an option as "Alternate Funding or Membership" before creating product detail
     * so user can select from these two which recordtype is needed for product detail
     */ 
    @AuraEnabled
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Product_Details__c.SObjectType.getDescribe().getRecordTypeInfos();
        Map<String, Id> recordtypeMap = new Map<String, Id>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Training' && rt.getName() != 'Event' && rt.getName() != 'Master')
                recordtypeMap.put(rt.getName(), rt.getRecordTypeId());
        }
        List<String> recTypeNames = new List<String>(recordtypeMap.keySet());
        return recTypeNames;
    }

    /**
     * Method to get RecordTypeId For ProductDetail Record based on RecordTypeLabel
     * @param  recordTypeLabel - value can be Membership or Alternate Funding
     * @param  recordId  - Id Of the Project Record
     */ 
    @AuraEnabled
    public static Map<String,Object> getRecTypeIdProject(String recordTypeLabel,String recordId){
        Map<String,Object> responseMap = new Map<String,Object>();

        //put recordtypeid in map
        responseMap.put('RecordTypeId',PicklistOptionsUtility.getProductDetailsRecordTypeId(recordTypeLabel));
        //If membership recordtype label then retrieve the project record
        if(recordTypeLabel == 'Membership'){
            Project__c projectInstance = [SELECT Id,LF_Membership_Required__c 
            FROM Project__c WHERE Id =: recordId];
            responseMap.put('ProjectRecord',projectInstance);
        }

        //return
        return responseMap;
    }
}