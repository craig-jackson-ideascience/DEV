public class HotelCommissionSyncToNetSuiteController {
	@AuraEnabled
    public static String validateAndSyncToNetSuite(Id recordId) {
		HotelCommissionSyncWrapper wrapper = new HotelCommissionSyncWrapper();
        List<ContentDocumentLink> files = [SELECT Id,LinkedEntityId From ContentDocumentLink WHERE LinkedEntityId =: recordId];
        wrapper.isSuccess = false;
        Hotel_Commissions__c hotelCommissions = [
                SELECT Id,Bill_to_Contact__c, Bill_To_Account__c,Start_Date__c,End_Date__c, Product_Description__c, Amount__c, Sync_to_Netsuite__c
                FROM Hotel_Commissions__c
                WHERE Id = :recordId
        ];
        if(!files.isEmpty()){
            if (hotelCommissions.Bill_to_Contact__c == null) {
                wrapper.message = 'The Bill To Contact field is not populated.';
            }
            else if (hotelCommissions.Bill_To_Account__c == null) {
                wrapper.message = 'The Bill To Account field is not populated.';
            }
            else if (hotelCommissions.Start_Date__c == null) {
                wrapper.message = 'The Start Date is not populated.';
            }
            else if (hotelCommissions.End_Date__c == null) {
                wrapper.message = 'The End Date is not populated.';
            }
            else if (hotelCommissions.Product_Description__c == null || hotelCommissions.Product_Description__c == '') {
                wrapper.message = 'The Description is not populated.';
            }
            else if (hotelCommissions.Amount__c == null) {
                wrapper.message = 'The Amount is not populated.';
            }
            else if (hotelCommissions.Sync_to_Netsuite__c) {
                wrapper.message = 'This record is already synced.';
            }
        }
        else{
           wrapper.message = 'No files attached. Please upload the file.'; 
        }
		
        if(String.isBlank(wrapper.message)){
            HotelCommissionSalesOrderHelper hotelCommissionHelper = new HotelCommissionSalesOrderHelper();
            Boolean success = hotelCommissionHelper.createHotelCommissionSalesOrder(recordId);
            if (success) {
                wrapper.message = 'Hotel Commission Record Synced to NetSuite';
                wrapper.isSuccess = true;
            } else {
                wrapper.message = 'Some Error Occurred';
            }
        }
        return JSON.serialize(wrapper);
    }
    
    public class HotelCommissionSyncWrapper{
        @auraEnabled
        public Boolean isSuccess {get;set;}
        @auraEnabled
        public String message {get; set;}
    }
}