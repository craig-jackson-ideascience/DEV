@istest
public class TrainingSubscriptionCalcControllerTest {
    static testMethod void testSubscription(){
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'LF Certification',productcode='test',Type__c = 'Certification',Family='Training');
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'LF E-Learning',productcode='test',Type__c = 'E-Learning',Family='Training');
        insert prod2;
        
        PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId,Product2Id=prod.ID,isActive=true,unitPrice=34);
        insert standardPbe;
        
        PriceBookEntry standardPbe2 = new PriceBookEntry(PriceBook2Id = pricebookId,Product2Id=prod2.ID,isActive=true,unitPrice=34);
        insert standardPbe2;
        
        Training__c training = new Training__c(Name='Test Bundle',Category__c = 'Subscription');
        insert training;
        Product_Details__c prodDetail = new Product_Details__c(Training__c = training.Id,Products__c=prod.Id, Description__c = 'Test Description');
        insert prodDetail;
        Product_Details__c prodDetailelearning = new Product_Details__c(Training__c = training.Id,Products__c=prod2.Id, Description__c = 'Test Description 2');
        insert prodDetailelearning;
        
        TrainingSubscriptionCalcController.subscriptionCalculation(training.id);
        
        //Assert for Cerfication type Product
        List<Product_Details__c> prodCertification = [SELECT Subscription_Calculation__c  FROM Product_Details__c WHERE Id =: prodDetail.id AND  Products__r.Type__c  = : 'Certification' LIMIT 1];
        System.assertEquals(100, prodCertification[0].Subscription_Calculation__c);
        
        //Assert for eLearning type Product
        List<Product_Details__c> prodeLearning = [SELECT Subscription_Calculation__c  FROM Product_Details__c WHERE Id =: prodDetailelearning.id AND  Products__r.Type__c  = : 'E-Learning' LIMIT 1];
        System.assertEquals(100, prodeLearning[0].Subscription_Calculation__c);
        
        
        
    }
}