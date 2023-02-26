@isTest
public class CventSyncTest {
     @testSetup
    public static void testCreateData(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = 'unknown';
        contact.LastName = 'unknown';
        contact.Email = 'testUnknown@noreply.com';
        insert contact;
        
        Project__c project = new Project__c(Name = 'The Linux Foundation',Category__c = 'Incorporated Entity');
        insert project;
        Event__c event  = new Event__c(Name = 'Test Event', Category__c = 'Project Event', BillFromProject__c = project.Id,
                                       Cvent_Event_Id__c='TestCventId123444');
        insert event;
        
        Event_Registrations__c eventReg = new Event_Registrations__c();
        eventReg.Name = 'Test eventReg';
        eventReg.Contact__c = contact.Id;
        eventReg.Event__c = event.Id;
        eventReg.Cvent_Registration_Id__c = 'testventregistraion56789';
        eventReg.Cvent_Registration_FirstName__c = 'test FirstName';
        eventReg.Cvent_Registration_LastName__c = 'test LastName';
        eventReg.Data_Source__c = 'Manual Entry';
        insert eventReg;
    }
    
    @isTest
    public static void getFileName_test(){
        Test.startTest();
        Event__c event = [SELECT Id FROM Event__c LIMIT 1];
        String returnedResponse = CventSync.getFileName(event.Id);
        System.assertEquals('Test Event Missing Event Registrations File', returnedResponse);
        Test.stopTest();
    }
   
    @isTest
    public static void getEventRegistrationIds_test(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CventSyncMock());
        Event__c event = [SELECT Id FROM Event__c LIMIT 1];
        String returnedString = CventSync.getCventData(event.Id);
        Test.stopTest();
        System.assertEquals('cGhwIC1mIGNsaS1yZWdpc3RyYXRpb25zLXJlcXVldWUucGhwIFRlc3RTZWFyY2hJZDQ1NzY4ICYmIFwK',returnedString);
        
    }
}