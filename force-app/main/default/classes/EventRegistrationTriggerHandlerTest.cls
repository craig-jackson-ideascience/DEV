@isTest
public class EventRegistrationTriggerHandlerTest {
	@isTest
    public static void populateUnknownContactName_test(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = 'unknown';
        contact.LastName = 'unknown';
        contact.Email = 'testUnknown@noreply.com';
        insert contact;

        Project__c parentProject = new Project__c();
        parentProject.Name = 'Parent Project';
        parentProject.Slug__c = 'test_parent_slug';
        insert parentProject;

        Project__c prj = new Project__c(
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
        insert prj;
        Event__c event  = new Event__c(Name = 'Test Event', Category__c = 'Project Event', BillFromProject__c = prj.Id);
        insert event;
        
        Event_Registrations__c eventReg = new Event_Registrations__c();
        eventReg.Name = 'Test eventReg';
        eventReg.Contact__c = contact.Id;
        eventReg.Event__c = event.Id;
        eventReg.Cvent_Registration_FirstName__c = 'test FirstName';
        eventReg.Cvent_Registration_LastName__c = 'test LastName';
        eventReg.Data_Source__c = 'Manual Entry';
        insert eventReg;
        
    } 
    
    @isTest
    public static void populateUnknownContactName_testAfterUpdate(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = 'unknown';
        contact.LastName = 'LastName';
        contact.Email = 'testUnknown@noreply.com';
        insert contact;

        Project__c parentProject = new Project__c();
        parentProject.Name = 'Parent Project';
        parentProject.Slug__c = 'test_parent_slug';
        insert parentProject;

        Project__c prj = new Project__c(
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
        insert prj;
        Event__c event  = new Event__c(Name = 'Test Event', Category__c = 'Project Event', BillFromProject__c = prj.Id);
        insert event;
        
        Event_Registrations__c eventReg = new Event_Registrations__c();
        eventReg.Name = 'Test eventReg';
        eventReg.Contact__c = contact.Id;
        eventReg.Event__c = event.Id;
        eventReg.Cvent_Registration_LastName__c = 'test LastName';
        eventReg.Data_Source__c = 'Manual Entry';
        insert eventReg;
        
        eventReg.Cvent_Registration_FirstName__c = 'test FirstName';
        update eventReg;
         
    }

    @isTest
    public static void updateInterestOnContactTechnology_test(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        contact.Email = 'testUnknown@noreply.com';
        insert contact;

        Project__c parentProject = new Project__c();
        parentProject.Name = 'Parent Project';
        parentProject.Slug__c = 'test_parent_slug';
        insert parentProject;

        Project__c prj = new Project__c(
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
        insert prj;
        Event__c event  = new Event__c(Name = 'Test Event', Category__c = 'Project Event', BillFromProject__c = prj.Id);
        insert event;

        List<Event_Registrations__c> evtList = new List<Event_Registrations__c>();
        Event_Registrations__c eventReg = new Event_Registrations__c();
        eventReg.Name = 'Test eventReg';
        eventReg.Contact__c = contact.Id;
        eventReg.Event__c = event.Id;
        eventReg.Cvent_Registration_FirstName__c = 'test FirstName';
        eventReg.Cvent_Registration_LastName__c = 'test LastName';
        eventReg.Cvent_Registration_AreasOfInterest__c='Blockchain, Cloud, Containers & Virtualization,System Administration,DevOps, CI/CD & Site Reliability,AI, ML, Data & Analytics';
        eventReg.Data_Source__c = 'Cvent';
        evtList.add(eventReg);

        Event_Registrations__c eventReg1 = new Event_Registrations__c();
        eventReg1.Name = 'Test eventReg1';
        eventReg1.Contact__c = contact.Id;
        eventReg1.Event__c = event.Id;
        eventReg1.Cvent_Registration_FirstName__c = 'test FirstName';
        eventReg1.Cvent_Registration_LastName__c = 'test LastName';
        eventReg1.Cvent_Registration_AreasOfInterest__c='Blockchain, Cloud, Containers & Virtualization,System Administration,DevOps, CI/CD & Site Reliability,AI, ML, Data & Analytics';
        eventReg1.Data_Source__c = 'Cvent';
        evtList.add(eventReg1);
        Test.startTest();
        insert evtList;
        Test.stopTest();
        Id contactId=contact.Id;
        system.debug('kkk '+[SELECT Id,Technology__C from contact where Id=:contactId].Technology__c);
        System.assertNotEquals(null,[SELECT Id,Technology__C from contact where Id=:contactId].Technology__c);
        
    } 
}