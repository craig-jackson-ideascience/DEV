public class TrainingTriggerHandler implements ITriggerHandler {
public static void BeforeInsert(List<Sobject> triggerNew) {
              
    }
    
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
                
        
    }    
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
        deleteProductDetails((Map<Id, Training__c>) oldMap);
    } 
    
    public static void AfterInsert(Map<Id, SObject> newMap){
        //call onAfterInsert
        //create product details
        addProductDetails((List<Training__c>) newMap.values());
    }   
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){      
       
        
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) {
    }
    
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after undelete actions
    } 
    
    public Boolean IsDisabled(){
        return false;
    }
    
    public static void addProductDetails(List<Training__c> trainings){
        Id recordTypeId = Schema.SObjectType.Product_Details__c.getRecordTypeInfosByName().get('Training').getRecordTypeId();
        Map<String,Training_NS_Code__mdt> trainingSettingMap = getTrainingSettings();
        Training_NS_Code__mdt eLearningSetting  = trainingSettingMap.get('E-Learning');
        Training_NS_Code__mdt certificationSetting = trainingSettingMap.get('Certification');        
        List<Product_Details__c> details = new List<Product_Details__c>();
        for(Training__c training : trainings){
            if(training.Category__c == 'Bundle' || training.Category__c == 'Subscription'){
                details.add(createProductDetailHelper(training.Id,recordTypeId,eLearningSetting));
                details.add(createProductDetailHelper(training.Id,recordTypeId,certificationSetting));
            }
        }
        if(!details.IsEmpty()){
            insert details;
        }
        
    }
    
    private static Product_Details__c createProductDetailHelper(Id trainingId,Id recordTypeId,Training_NS_Code__mdt trainingMDT){
        Product_Details__c detail = new Product_Details__c();
        detail.Status__c ='Inactive';
        detail.Products__c = trainingMDT.SF_Id__c;
        detail.Training__c =trainingId;
        detail.RecordTypeId = recordTypeId;
        detail.Skip_60_Char_Limit__c = true;
        detail.NetSuite_Class__c = trainingMDT.NS_Class__c;
        detail.NS_Department__c =trainingMDT.NS_Department__c;
        detail.NS_Income_GL_Account__c =trainingMDT.NS_Income_GL_Account__c;
        detail.NS_Deferred_Revenue_Account__c = trainingMDT.NS_Deferred_Revenue_Account__c;
        detail.NS_Revenue_Schedule__c =trainingMDT.NS_Revenue_Schedule__c;
        detail.Netsuite_ID__c = trainingMDT.NetSuite_ID__c;
        detail.Price__c = 0;
        return detail;
    }
    
    private static  Map<String,Training_NS_Code__mdt> getTrainingSettings(){
        Map<String,Training_NS_Code__mdt> trainingMap = new Map<String,Training_NS_Code__mdt>();
        List<Training_NS_Code__mdt> trainingMDT = [SELECT MasterLabel,SF_Id__c,NS_Class__c,NS_Deferred_Revenue_Account__c,NS_Department__c,NS_Income_GL_Account__c,NS_Revenue_Schedule__c,NetSuite_ID__c
                                            FROM Training_NS_Code__mdt WHERE MasterLabel !='Instructor Led'];
        for(Training_NS_Code__mdt training : trainingMDT){
            trainingMap.put(training.MasterLabel,training);
        }
        return trainingMap;
    }
    
     public static void deleteProductDetails(Map<Id, Training__c> oldMap){
        List<Product_Details__c> productDetailsList = [SELECT Id FROM Product_Details__c WHERE Training__c IN: oldMap.keySet()];
        System.debug('oldMap.keySet() '+oldMap.keySet());

        System.debug('productDetailsList '+productDetailsList);
        if(!productDetailsList.isEmpty()){
            delete productDetailsList;
        }
    }
}