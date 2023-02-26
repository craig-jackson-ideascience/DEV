public class TrainingSubscriptionCalcController {
    @AuraEnabled
    public static String subscriptionCalculation(string recordId){
        
        List<AggregateResult> prodDetailResult = new List<AggregateResult >();
        List<Product_Details__c> productDetailsUpdate = new List<Product_Details__c>();
        Integer certificationType = 0;
        Integer eLearningType = 0;
        try{
            Training__c training = [Select Id,Category__c, Status__c  
                                    From Training__c 
                                    WHERE Id  =:recordId];
            
            
            List<Product_Details__c> productDetails = [Select Id, Training__c,Training__r.Category__c,Products__r.Type__c,Subscription_Calculation__c
                                                       FROM Product_Details__c
                                                       WHERE Training__c =:recordId];
            
            if(training.Category__c == 'Subscription'){
                prodDetailResult = [SELECT Count(Id) productCount, Products__r.Type__c productType
                                    FROM Product_Details__c
                                    WHERE Training__c =:recordId
                                    AND Products__r.Type__c IN ('Certification','E-Learning')
                                    GRoup By Products__r.Type__c ];
                
                System.debug('prodDetailList' +prodDetailResult);
                
                for (AggregateResult aggResult :prodDetailResult ){
                    Integer productCount = (Integer)aggResult.get('productCount');
                    if((String)aggResult.get('productType') == 'Certification'){
                        certificationType = productCount;
                    }else if((String)aggResult.get('productType') == 'E-Learning'){
                        eLearningType = productCount;
                    }
                }
                System.debug('certificationType' +certificationType + 'eLearningType' +eLearningType);
                
                
                for(Product_Details__c proDetails :productDetails){
                    if(proDetails.Products__r.Type__c == 'Certification'){
                        proDetails.Subscription_Calculation__c = (certificationType -1) > 0 ? 100.0 / (certificationType - 1) : 0; 
                    }else if(proDetails.Products__r.Type__c == 'E-Learning'){
                        proDetails.Subscription_Calculation__c =(eLearningType -1) > 0 ? 100.0 / (eLearningType - 1 ) : 0;
                    }
                    productDetailsUpdate.add(proDetails);
                }
            }
            
            if(!productDetailsUpdate.isEmpty()){
                update productDetailsUpdate;
            }
            
            return '';
        } catch(Exception e){
            System.debug('Message' +e.getMessage());
            return e.getMessage();
        }
    }
    
}