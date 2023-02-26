/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 12-11-2019.
 * Description: EMSSyncToNetSuiteController
 ********************************************************/
public class EMSSyncToNetSuiteController {
    @AuraEnabled
    public static String validateAndSyncToNetSuite(Id recordId) {
        List<ContentDocumentLink> files = [SELECT Id,LinkedEntityId From ContentDocumentLink WHERE LinkedEntityId =: recordId];
		EMSSyncWrapper wrapper = new EMSSyncWrapper();
        wrapper.isSuccess = false;
        EMS__c ems = [
                SELECT Id,Contact__c, Bill_To_Account__c,StartDate__c, Description__c, Amount__c, Sync_to_Netsuite__c
                FROM EMS__c
                WHERE Id = :recordId
        ];

        /*if (ems.Contact__c == null) {
            wrapper.message = 'The Contact field is not populated.';
        }*/
        if(!files.isEmpty()){
            if (ems.Bill_To_Account__c == null) {
                wrapper.message = 'The Bill To Account field is not populated.';
            }
            else if (ems.StartDate__c == null) {
                wrapper.message = 'The Start Date is not populated.';
            }
            else if (ems.Description__c == null || ems.Description__c == '') {
                wrapper.message = 'The Description is not populated.';
            }
            else if (ems.Amount__c == null) {
                wrapper.message = 'The Amount is not populated.';
            }
            else if (ems.Sync_to_Netsuite__c) {
                wrapper.message = 'This record is already synced.';
            } 
        }
        else{
           wrapper.message = 'No files attached. Please upload the file.'; 
        }
		
        if(String.isBlank(wrapper.message) ){
            EMSSalesOrderHelper emsHelper = new EMSSalesOrderHelper();
            Boolean success = emsHelper.createEMSSalesOrder(recordId);
            if (success) {
                wrapper.message = 'EMS Record Synced to NetSuite';
                wrapper.isSuccess = true;
            } else {
                wrapper.message = 'Some Error Occurred';
            }
        }
        return JSON.serialize(wrapper);
    }
    
    public class EMSSyncWrapper{
        @auraEnabled
        public Boolean isSuccess {get;set;}
        @auraEnabled
        public String message {get; set;}
    }
}