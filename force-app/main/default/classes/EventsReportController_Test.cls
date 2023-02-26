@isTest
private class EventsReportController_Test
{
    //Initial Test Data
    //Add Logic to Create data required
    @testSetup
    static void SetUp(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        List<Contact> contacts = new List<Contact>();
        Contact contact1 = new Contact();
        contact1.AccountId = account.Id;
        contact1.FirstName = 'Test';
        contact1.LastName = 'Contact1';
        contact1.Email = 'testcontact1@noreply.com';
        contacts.add(contact1);

        Contact contact2 = new Contact();
        contact2.AccountId = account.Id;
        contact2.FirstName = 'Test';
        contact2.LastName = 'Contact2';
        contact2.Email = 'testcontact2@noreply.com';
        contacts.add(contact2);

        Contact contact3 = new Contact();
        contact3.AccountId = account.Id;
        contact3.FirstName = 'Test';
        contact3.LastName = 'Contact3';
        contact3.Email = 'testcontact3@noreply.com';
        contacts.add(contact3);
        insert contacts;

        Project__c parentProject = new Project__c();
        parentProject.Name = 'Parent Project';
        parentProject.Slug__c = 'test_parent_slug';
        insert parentProject;

        Project__c project = new Project__c(
                Name = 'The Linux Foundation',
                Category__c = 'Directed Fund',
                Status__c = 'Active',
                Funding__c = 'Funded',
                Slug__c = 'test_slug',
                Project_Entity_Name__c = 'test formal name',
                Start_Date__c = Date.today(),
                Industry__c = 'Automotive',
                Parent_Entity_Relationship__c = parentProject.Id,
                Parent_Project__c = parentProject.Id,
                Model__c = 'Membership',
                Technology__c = 'Storage',
                Technical_Activity_Type__c = 'Open Data'
        );
        insert project;

        List<Event__c> events = new List<Event__c>();
        Event__c event1  = new Event__c(Name = 'Test Event 2019', Category__c = 'Project Event', BillFromProject__c = project.Id);
        events.add(event1);
        Event__c event2  = new Event__c(Name = 'Test Event 2020', Category__c = 'Project Event', BillFromProject__c = project.Id);
        events.add(event2);
        insert events;

        List<Event_Registrations__c> eventRegistrations = new List<Event_Registrations__c>();
        Event_Registrations__c eventReg1 = new Event_Registrations__c();
        eventReg1.Name = 'Test eventReg 1';
        eventReg1.Contact__c = contact1.Id;
        eventReg1.Event__c = event1.Id;
        eventReg1.Cvent_Registration_FirstName__c = 'test FirstName 1';
        eventReg1.Cvent_Registration_LastName__c = 'test LastName 1';
        eventReg1.Data_Source__c = 'Manual Entry';
        eventRegistrations.add(eventReg1);


        Event_Registrations__c eventReg2 = new Event_Registrations__c();
        eventReg2.Name = 'Test eventReg 2';
        eventReg2.Contact__c = contact1.Id;
        eventReg2.Event__c = event2.Id;
        eventReg2.Cvent_Registration_FirstName__c = 'test FirstName 2';
        eventReg2.Cvent_Registration_LastName__c = 'test LastName 2';
        eventReg2.Data_Source__c = 'Manual Entry';
        eventRegistrations.add(eventReg2);

        Event_Registrations__c eventReg3 = new Event_Registrations__c();
        eventReg3.Name = 'Test eventReg 3';
        eventReg3.Contact__c = contact2.Id;
        eventReg3.Event__c = event2.Id;
        eventReg3.Cvent_Registration_FirstName__c = 'test FirstName 3';
        eventReg3.Cvent_Registration_LastName__c = 'test LastName 3';
        eventReg3.Data_Source__c = 'Manual Entry';
        eventRegistrations.add(eventReg3);

        Event_Registrations__c eventReg4 = new Event_Registrations__c();
        eventReg4.Name = 'Test eventReg 4';
        eventReg4.Contact__c = contact3.Id;
        eventReg4.Event__c = event2.Id;
        eventReg4.Cvent_Registration_FirstName__c = 'test FirstName 4';
        eventReg4.Cvent_Registration_LastName__c = 'test LastName 4';
        eventReg4.Data_Source__c = 'Manual Entry';
        eventRegistrations.add(eventReg4);
        insert eventRegistrations;
    }


    // Test Method: getAllEvents
    public static testmethod void Test_getAllEvents(){
        System.Assert(EventsReportController.getAllEvents() != null);
    }

    // Test Method: getRegistrationDetails
    public static testmethod void Test_getRegistrationDetails(){
        Id eventId = [SELECT Id FROM Event__c WHERE Name = 'Test Event 2020' LIMIT 1].Id;
        System.Assert(EventsReportController.getRegistrationDetails(eventId) != null);
    }
}