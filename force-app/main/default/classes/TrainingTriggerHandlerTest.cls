@IsTest
public class TrainingTriggerHandlerTest {

    static testMethod void testBundle(){
        Training__c training = new Training__c(Name='Test Bundle',Category__c = 'Bundle');
        insert training;
        System.assertEquals(2,[SELECT count() FROm Product_Details__c WHERE Training__c=: training.Id]);
    }
    
     static testMethod void testSubscription(){
        Training__c training = new Training__c(Name='Test Bundle',Category__c = 'Subscription');
        insert training;
        System.assertEquals(2,[SELECT count() FROm Product_Details__c WHERE Training__c=: training.Id]);
    }
    
     static testMethod void testCertification(){
        Training__c training = new Training__c(Name='Test Bundle',Category__c = 'Certification');
        insert training;
        System.assertEquals(0,[SELECT count() FROm Product_Details__c WHERE Training__c=: training.Id]);
    }
    @isTest
    static void test_deleteProductDetails(){
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'LF Event',productcode='test',Type__c = 'Certification',Family='Training');
        insert prod;
        PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId,Product2Id=prod.ID,isActive=true,unitPrice=34);
        insert standardPbe;
        Training__c training = new Training__c(Name='Test Bundle',Category__c = 'Certification');
        insert training;
        Product_Details__c prodDetail = new Product_Details__c(Training__c = training.Id,Products__c=prod.Id, Description__c = 'Test Description');
        insert prodDetail;
        Test.startTest();
        delete training;
        Test.stopTest();
        System.assertEquals(0,[SELECT Id FROM Product_Details__c WHERE Id =:prodDetail.Id].size());
    }
}