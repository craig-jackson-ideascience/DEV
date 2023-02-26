@isTest
public class TravelFundExpensifyHandlerTest {
    @isTest
    static void travelFundExpensifyHandler_Test1() {
        
        Test.setMock(HttpCalloutMock.class, new ExpensifyCalloutMockTest());
        
        Contact conRecord = new Contact();
        conRecord.LastName = 'Kumar';
        conRecord.Email = 'sachin.kumar@webuters.com';
        insert conRecord;
        
        //Creating Project Record Id
       //Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Subproject'].Id;
        testFactory.getAccount();
        Project__c testProjObj = new Project__c ();
        testProjObj.Name = 'The Linux Foundation';
        testProjObj.Category__c = 'Subproject';
        testProjObj.Status__c = 'Planned';
        testProjObj.Type__c = 'Membership';
        testProjObj.Slug__c = 'test_slug';
        testProjObj.Manual_Status_Check__c = false;
        testProjObj.Funding__c = 'Funded';
        testProjObj.Model__c = 'Membership';
        insert testProjObj;

        testProjObj.Status__c = 'Active';
        update testProjObj;

        Event__c evtRecord = new Event__c();
        evtRecord.Name = 'My New Event';
        evtRecord.Expensify_Policy_ID__c = '554237F4AB23B96D';
        evtRecord.BillFromProject__c = testProjObj.Id;
        insert evtRecord;
        
        EMS__c ems = new EMS__c();
        ems.Name = ' - Event Management Service';
        ems.Event__c = evtRecord.Id;
        ems.StartDate__c = evtRecord.Start_Date__c;
        ems.Bill_From__c =testProjObj.id;
        ems.EMS_Number__c=evtRecord.name+' '+String.valueOf(Date.today().year()).substring(2,4)+String.valueOf(Date.today().month());
        ems.Product__c = '22';
        ems.EMS_Status__c = 'Not Started';
        ems.NS_Department__c = '2';
        ems.NS_Income_GL_Account__c = evtRecord.NS_Income_GL_Account__c;
        ems.NS_Deferred_Revenue_Account__c = evtRecord.NS_Deferred_Revenue_Account__c;
        ems.NS_Revenue_Schedule__c = evtRecord.NS_Revenue_Schedule__c;
        insert ems;   
        
        List<Travel_Fund_Request__c> my_list = new List<Travel_Fund_Request__c>();
        Travel_Fund_Request__c newTravelFund = new Travel_Fund_Request__c();
        newTravelFund.Name = 'TestCreateTravelFundTest';
        newTravelFund.Status__c = 'Waiting Approval';
        newTravelFund.Event__c = evtRecord.Id;
        newTravelFund.Contact__c = conRecord.Id;
        my_list.add(newTravelFund);
        insert newTravelFund;
        
        Test.startTest();
        TravelFundExpensifyHandler.CreateExpensifyReport(my_list); 
        //TravelFundExpensifyHandler.CreateExpensifyReport(''); 
        Test.stopTest();
    }
    @isTest
    static void travelFundExpensifyHandler_Test2() {
        
        Test.setMock(HttpCalloutMock.class, new ExpensifyCalloutMockTest());
        
        Contact conRecord = new Contact();
        conRecord.LastName = 'Kumar';
        conRecord.Email = 'sachin.kumar@webuters.com';
        insert conRecord;
        
        //Creating Project Record Id
        //Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Subproject'].Id;
        testFactory.getAccount();
        Project__c testProjObj = new Project__c ();
        testProjObj.Name = 'The Linux Foundation';
        testProjObj.Category__c = 'Subproject';
        testProjObj.Status__c = 'Planned';
        testProjObj.Type__c = 'Membership';
        testProjObj.Manual_Status_Check__c = false;
        testProjObj.Slug__c = 'test_slug';
        testProjObj.Funding__c = 'Funded';
        testProjObj.Model__c = 'Membership';
        insert testProjObj;

        testProjObj.Status__c = 'Active';
        update testProjObj;
        
        Event__c evtRecord = new Event__c();
        evtRecord.Name = 'My New Event';
        evtRecord.Expensify_Policy_ID__c = '554237F4AB23B96D';
        evtRecord.BillFromProject__c = testProjObj.Id;
        insert evtRecord;
        
        EMS__c ems = new EMS__c();
        ems.Name = ' - Event Management Service';
        ems.Event__c = evtRecord.Id;
        ems.StartDate__c = evtRecord.Start_Date__c;
        ems.Bill_From__c =testProjObj.id;
        ems.EMS_Number__c=evtRecord.name+' '+String.valueOf(Date.today().year()).substring(2,4)+String.valueOf(Date.today().month());
        ems.Product__c = '22';
        ems.EMS_Status__c = 'Not Started';
        ems.NS_Department__c = '2';
        ems.NS_Income_GL_Account__c = evtRecord.NS_Income_GL_Account__c;
        ems.NS_Deferred_Revenue_Account__c = evtRecord.NS_Deferred_Revenue_Account__c;
        ems.NS_Revenue_Schedule__c = evtRecord.NS_Revenue_Schedule__c;
        insert ems;   
        
        List<Travel_Fund_Request__c> my_list = new List<Travel_Fund_Request__c>();
        Travel_Fund_Request__c newTravelFund = new Travel_Fund_Request__c();
        newTravelFund.Name = 'New Travel Fund';
        newTravelFund.Status__c = 'Request Approved - Waiting For Expense Report';
        newTravelFund.Event__c = evtRecord.Id;
        newTravelFund.Contact__c = conRecord.Id;
        newTravelFund.Amount_Approved__c = 100;
        my_list.add(newTravelFund);
        insert newTravelFund;
        
        Test.startTest();
        RecursiveTriggerHandler.isFirstTime=false;
        TravelFundExpensifyHandler.notifyExpensifyRequestor(my_list); 
        //TravelFundExpensifyHandler.notifyExpensifyRequestor_Apex(''); 
        Test.stopTest();
    }
    @isTest
    static void travelFundExpensifyHandler_Test3() {
        
        Test.setMock(HttpCalloutMock.class, new ExpensifyCalloutMockTest());
        
        Contact conRecord = new Contact();
        conRecord.LastName = 'Kumar';
        conRecord.Email = 'sachin.kumar@webuters.com';
        insert conRecord;
        
        //Creating Project Record Id
        //Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Subproject'].Id;
        testFactory.getAccount();
        Project__c testProjObj = new Project__c ();
        testProjObj.Name = 'The Linux Foundation';
        testProjObj.Category__c = 'Subproject';
        testProjObj.Status__c = 'Planned';
        testProjObj.Type__c = 'Membership';
        testProjObj.Manual_Status_Check__c = false;
        testProjObj.Slug__c = 'test_slug';
        testProjObj.Funding__c = 'Funded';
        testProjObj.Model__c = 'Membership';
        insert testProjObj;

        testProjObj.Status__c = 'Active';
        update testProjObj;
        
        Event__c evtRecord = new Event__c();
        evtRecord.Name = 'My New Event';
        evtRecord.Expensify_Policy_ID__c = '554237F4AB23B96D';
        evtRecord.BillFromProject__c = testProjObj.Id;
        insert evtRecord;
        
        EMS__c ems = new EMS__c();
        ems.Name = ' - Event Management Service';
        ems.Event__c = evtRecord.Id;
        ems.StartDate__c = evtRecord.Start_Date__c;
        ems.Bill_From__c =testProjObj.id;
        ems.EMS_Number__c=evtRecord.name+' '+String.valueOf(Date.today().year()).substring(2,4)+String.valueOf(Date.today().month());
        ems.Product__c = '22';
        ems.EMS_Status__c = 'Not Started';
        ems.NS_Department__c = '2';
        ems.NS_Income_GL_Account__c = evtRecord.NS_Income_GL_Account__c;
        ems.NS_Deferred_Revenue_Account__c = evtRecord.NS_Deferred_Revenue_Account__c;
        ems.NS_Revenue_Schedule__c = evtRecord.NS_Revenue_Schedule__c;
        insert ems;   
        
        List<Travel_Fund_Request__c> my_list = new List<Travel_Fund_Request__c>();
        Travel_Fund_Request__c newTravelFund = new Travel_Fund_Request__c();
        newTravelFund.Name = 'TestCreateTravelFundTest';
        newTravelFund.Status__c = 'Paid';
        newTravelFund.Event__c = evtRecord.Id;
        newTravelFund.Contact__c = conRecord.Id;
        my_list.add(newTravelFund);
        insert newTravelFund;
        
        Expensify_Attachment__c expenAttach = new Expensify_Attachment__c();
        expenAttach.Report_Id__c = '54160232';
        expenAttach.URL__c = 'https://s3.amazonaws.com/receipts.expensify.com/w_45c7f11b2a8e505d79b434102b3d13acaeed090a.jpg';
        expenAttach.Travel_Fund_Request__c = newTravelFund.Id;
        insert expenAttach;
        
        Test.startTest();
        TravelFundExpensifyHandler.updateStatusFromApprovedToReimbursed(newTravelFund.Id); 
        //TravelFundExpensifyHandler.updateStatusFromApprovedToReimbursed(''); 
        Test.stopTest();
    }
}