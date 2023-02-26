public class RollUpTriggerHandler {
    
    public static void rollupHelper(List<Travel_Fund_Request__c> travelFundRequest){
         List<RollUpSummaryUtility.fieldDefinition> fieldDefinitions = 
            new List<RollUpSummaryUtility.fieldDefinition> {                
                new RollUpSummaryUtility.fieldDefinition('SUM', 'Approved_Amount__c', 'Total_Approved_Travel_Funds__c'),
                new RollUpSummaryUtility.fieldDefinition('SUM', 'Total_Amount_Paid__c', 'Total_Paid_Travel_Funds__c')
                    };
                        
        RollUpSummaryUtility.rollUpTrigger(fieldDefinitions, travelFundRequest,'Travel_Fund_Request__c', 'Event__c', 'Event__c', '');
    }
}