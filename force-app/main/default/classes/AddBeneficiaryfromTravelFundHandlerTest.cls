@isTest
public class AddBeneficiaryfromTravelFundHandlerTest {
@isTest
    static void expensifyRecReqCon_Test1() {
        
        Test.setMock(HttpCalloutMock.class, new ExpensifyCalloutMockTest());
        
        Contact conRecord = new Contact();
        conRecord.LastName = 'sunil ';
        conRecord.Email = 'sunil.chaudhary@webuters.com';
        insert conRecord;
        
         Project__c project = new Project__c(Name = 'The Linux Foundation',Category__c = 'Incorporated Entity', Slug__c ='tlf');
        insert project;
        
        Event__c evtRecord = new Event__c();
        evtRecord.Name = 'My New Event';
        evtRecord.Registration_Source__c ='Cvent';

        evtRecord.Expensify_Policy_ID__c = '554237F4AB23B96D';
        insert evtRecord;
        list<Travel_Fund_Request__c> trvlFundList = new list<Travel_Fund_Request__c>();
        Travel_Fund_Request__c newTravelFund = new Travel_Fund_Request__c();
        newTravelFund.Name = 'New Travel Fund';
        newTravelFund.Status__c = 'Request Approved - Waiting For Expense Report';
        newTravelFund.Event__c = evtRecord.Id;
        newTravelFund.Contact__c = conRecord.Id;
        newTravelFund.Amount_Approved__c  = 100;
        trvlFundList.add(newTravelFund);
        insert trvlFundList;
 
        Expensify_Attachment__c expenAttach = new Expensify_Attachment__c();
        expenAttach.Report_Id__c = '53845065';
        expenAttach.URL__c = 'https://s3.amazonaws.com/receipts.expensify.com/w_b7e63c97f448ea5e8f2b1d12e42d3dd3eab42370.pdf';
        expenAttach.Travel_Fund_Request__c = newTravelFund.Id;
        insert expenAttach;
        
        Test.startTest();
          RecursiveTriggerHandler.isFirstTime=false;
        AddBeneficiaryfromTravelFundHandler.addBeneficiary(trvlFundList);
        Test.stopTest();
    }
}