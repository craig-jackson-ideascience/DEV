/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 29-08-2019.
 * Description: EventAndProjectRolesReportCtrlTest
 ********************************************************/
@isTest
public class EventAndProjectRolesReportCtrlTest {

    @TestSetup
    public static void setup() {
        Account acc = new Account(Name = 'testName');
        insert acc;

        Contact cnt = new Contact(LastName = 'testLast Name');
        Contact cnt1 = new Contact(LastName = 'testLast Name');
        Contact cnt2 = new Contact(LastName = 'testLast Name');
        insert new List<Contact>{
                cnt, cnt1, cnt2
        };

        /*Event__c evt = new Event__c(
                Name = 'Test Event Name',
                Category__c = 'Project Event'
        );*/
            Project__c testProject =TestFactory.getProject();

        Project__c parentProject = new Project__c();
        parentProject.Name = 'Parent Project';
        parentProject.Slug__c = 'test_parent_slug';
        insert parentProject;

        Project__c project = new Project__c(
                Name = 'The Linux Foundation',
                //Category__c = 'Incorporated Entity',
                Slug__c = 'test_slug',
                Funding__c = 'Funded',
                Status__c = 'Active',
                Project_Entity_Name__c = 'test formal name',
                Start_Date__c = Date.today(),
                Industry__c = 'Automotive',
                Parent_Entity_Relationship__c = parentProject.Id,
                Parent_Project__c = parentProject.Id,
                Model__c = 'Membership',
                Technology__c = 'Storage',
                Technical_Activity_Type__c = 'Open Data'
        );
        Insert project;

        project.Category__c = 'Incorporated Entity';
        update project;

        Event__c evt = new Event__c(
                Event_Name__c = 'KubeCon',
                Name = 'KubeCon',    // Event Name
                Status__c = 'Complete',                                                                                                                                                  // Event Status
                Category__c = 'LF Event',                                                                                                                                                // Category
                BillFromProject__c = project.id, //ID                                                                                                                                  // Bill From Project
                Start_Date__c = system.today() - 20,                                                                                                                               // Event Start Date
                Capacity__c = 0,                                                                                                                                          // Event Start Time
                End_Date__c = system.today() - 10,                                                                                                                                 // Event End Date
                Registration_Source__c = 'RegOnline',                                                                                                                                           // Event End Time
                Event_Location_Name__c = 'Twitter HQ One 10th Street Expansion',                                                                                                         // Event Location Name
                Event_Published__c = false,                                                                                                                                              // Event Published
                Event_Location_Address__c = 'One 10th Street',                                                                                                                           // Event Location Address
                Event_Location_City__c = 'San Francisco',                                                                                                                                // Event Location City
                Event_Location_State__c = 'California',                                                                                                                                  // Event Location State
                Event_Location_Country__c = 'United States',                                                                                                                             // Event Location Country
                Event_Location_Zip__c = '94103',                                                                                                                                         // Event Location Zip
                Embassy__c = 'US',                                                                                                                                                       // Embassy
                Cvent_Event_Is_Sandbox__c = false,                                                                                                                                             // NS Department
                //Type__c = 'Email',                                                                                                                                                       // Type
                Netsuite_Sync__c = false                                                                                                                                                // Netsuite Sync
        );
        /*Event__c evt1 = new Event__c(
                Name = 'Test Event Name1',
                Category__c = 'Non LF Events'
        );
        Event__c evt2 = new Event__c(
                Name = 'Test Event Name2',
                Category__c = 'Non LF Events'
        );*/

        insert evt;


        Project__c proj = new Project__c(
                Name = 'Test Event Name',
                Category__c = 'Incorporated Entity',
                Slug__c = 'proj_slug'
        );
        Project__c proj1 = new Project__c(
                Name = 'Test Event Name1',
                Category__c = 'Incorporated Entity',
                Slug__c = 'proj1_slug'
        );
        Project__c proj2 = new Project__c(
                Name = 'Test Event Name2',
                Category__c = 'Incorporated Entity',
                Slug__c = 'proj2_slug'
        );
        insert new List<Project__c>{
                proj, proj1, proj2
        };


        Event_Registrations__c event_registration = new Event_Registrations__c(
                Name = 'Event Registraion 1 ',
                Event__c = evt.Id,
                Contact__c = cnt.Id,
                Data_Source__c = 'Cvent'
        );
        Event_Registrations__c event_registration1 = new Event_Registrations__c(
                Name = 'Event Registraion 2',
                Event__c = evt.Id,
                Contact__c = cnt1.Id,
                Data_Source__c = 'Cvent'
        );
        Event_Registrations__c event_registration2 = new Event_Registrations__c(
                Name = 'Event Registraion 3',
                Event__c = evt.Id,
                Contact__c = cnt2.Id,
                Data_Source__c = 'Cvent'
        );
        insert new List<Event_Registrations__c>{
                event_registration, event_registration1, event_registration2
        };

        Asset a = new Asset(Name = 'Asset', Number_of_Years_Required__c = 2, Projects__c = proj.Id, AccountId = acc.Id);
        Asset a1 = new Asset(Name = 'Asset1', Number_of_Years_Required__c = 3, Projects__c = proj1.Id, AccountId = acc.Id);
        Asset a2 = new Asset(Name = 'Asset2', Number_of_Years_Required__c = 4, Projects__c = proj2.Id, AccountId = acc.Id);
        insert new List<Asset>{
                a, a1, a2
        };

        Project_Role__c pr = new Project_Role__c(Asset__c = a.Id, Contact__c = cnt.Id, Role__c = 'Marketing Contact');
        Project_Role__c pr1 = new Project_Role__c(Asset__c = a1.Id, Contact__c = cnt1.Id, Role__c = 'Marketing Contact');
        Project_Role__c pr2 = new Project_Role__c(Asset__c = a2.Id, Contact__c = cnt2.Id, Role__c = 'Marketing Contact');
        insert new List<Project_Role__c>{
                pr, pr1, pr2
        };

        Campaign campaign = new Campaign(Name = 'etst Campaign', Description = 'test Desc');
        insert campaign;
    }

    @isTest
    static void eventsReportTest() {
        Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
        EventAndProjectRolesReportCtrl ctrl = new EventAndProjectRolesReportCtrl();

        ctrl.filterType = 'events';
        ctrl.EventID = evt.Id;
        Test.startTest();
        boolean n = ctrl.hasNext;
        boolean p = ctrl.hasPrevious;
        ctrl.emailOptOut = 'false';
        ctrl.sortExpression = 'DESC';
        ctrl.eventSelectedMethod();
        ctrl.projectSelectedMethod();
        ctrl.callReport();
        ctrl.clearFilter();
        ctrl.getSortDirection();
        ctrl.sortWrapperList();
        ctrl.setCon.setPageSize = 1;
        ctrl.next();
        ctrl.next();
        ctrl.previous();
        Test.stopTest();
        System.debug(ctrl.reportWrapperList + '====> ctrl.reportWrapperList');
        System.debug(ctrl.reportWrapperList.size() + '====> ctrl.reportWrapperList');
        System.assertEquals(ctrl.reportWrapperList.size() , 3);
    }


    @isTest
    static void eventsReportTest1() {
        Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
        Project__c proj = [SELECT Id FROM Project__c LIMIT 1];

        EventAndProjectRolesReportCtrl ctrl = new EventAndProjectRolesReportCtrl();
        ctrl.filterType = 'events';
        ctrl.EventID = evt.Id;
        ctrl.ProjectID = proj.Id;
        Test.startTest();
        boolean n = ctrl.hasNext;
        boolean p = ctrl.hasPrevious;
        ctrl.sortExpression = 'DESC';
        ctrl.eventSelectedMethod();
        ctrl.projectSelectedMethod();
        ctrl.callReport();
        ctrl.clearFilter();
        ctrl.getSortDirection();
        ctrl.sortWrapperList();
        Test.stopTest();
        System.debug(ctrl.reportWrapperList + '====> ctrl.reportWrapperList');
        System.debug(ctrl.reportWrapperList.size() + '====> ctrl.reportWrapperList');
        System.assertEquals(ctrl.reportWrapperList.size() , 0);
    }

    @isTest
    static void eventsReportTest2() {
        Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
        Project__c proj = [SELECT Id FROM Project__c LIMIT 1];

        EventAndProjectRolesReportCtrl ctrl = new EventAndProjectRolesReportCtrl();
        ctrl.filterType = 'events';
        ctrl.EventID = evt.Id;
        ctrl.ProjectID = proj.Id;
        Test.startTest();
        boolean n = ctrl.hasNext;
        boolean p = ctrl.hasPrevious;
        ctrl.emailOptOut = 'true';

        ctrl.sortExpression = 'DESC';
        ctrl.eventSelectedMethod();
        ctrl.projectSelectedMethod();
        ctrl.callReport();
        ctrl.clearFilter();
        ctrl.getSortDirection();
        ctrl.sortWrapperList();
        Test.stopTest();
        System.debug(ctrl.reportWrapperList + '====> ctrl.reportWrapperList');
        System.debug(ctrl.reportWrapperList.size() + '====> ctrl.reportWrapperList');
        System.assertEquals(ctrl.reportWrapperList.size() , 0);
    }
    
    
    @isTest
    static void sortReportTest() {
         Event__c evt = [SELECT Id FROM Event__c LIMIT 1];
        EventAndProjectRolesReportCtrl ctrl = new EventAndProjectRolesReportCtrl();

        ctrl.filterType = 'events';
        ctrl.EventID = evt.Id;
        Test.startTest();
        boolean n = ctrl.hasNext;
        boolean p = ctrl.hasPrevious;
        ctrl.emailOptOut = 'false';
        ctrl.sortExpression = 'DESC';
        ctrl.eventSelectedMethod();
        ctrl.projectSelectedMethod();
        ctrl.callReport();
        ctrl.clearFilter();
        ctrl.getSortDirection();
        ctrl.sortWrapperList();
        ctrl.sortExpression = 'cnt.Name';
        ctrl.sortWrapperList();
        ctrl.sortExpression = 'cnt.FirstName';
        ctrl.sortWrapperList();
        ctrl.sortExpression = 'cnt.LastName';
        ctrl.sortWrapperList();
        ctrl.sortExpression = 'cnt.MailingCountry';
        ctrl.sortWrapperList();
        ctrl.sortExpression = 'cnt.Email';
        ctrl.sortWrapperList();
        ctrl.sortExpression = 'cnt.HasOptedOutOfEmail';
        ctrl.sortWrapperList();
        ctrl.sortExpression = 'projRole.Asset__r.Projects__r.Name';
        ctrl.sortWrapperList();
        ctrl.sortExpression = 'projRole.Role__c';
        ctrl.sortWrapperList();
        ctrl.sortExpression = 'projRole.PrimaryContact__c';
        ctrl.sortWrapperList();
        ctrl.sortExpression = 'event.Name';
        ctrl.sortWrapperList();
        ctrl.sortExpression = 'event.Start_Date__c';
        ctrl.sortWrapperList();
        ctrl.sortExpression = 'event.Event_Location_Country__c';
        ctrl.sortWrapperList();
        Test.stopTest();
        System.debug(ctrl.reportWrapperList + '====> ctrl.reportWrapperList');
        System.debug(ctrl.reportWrapperList.size() + '====> ctrl.reportWrapperList');
        System.assertEquals(ctrl.reportWrapperList.size() , 3);
    }

    @isTest
    static void projectReportTest() {
        Project__c proj = [SELECT Id FROM Project__c LIMIT 1];
        EventAndProjectRolesReportCtrl ctrl = new EventAndProjectRolesReportCtrl();
        ctrl.filterType = 'projects';
        ctrl.ProjectID = proj.Id;
        Test.startTest();
        ctrl.sortExpression = 'DESC';
        ctrl.projectSelectedMethod();
        ctrl.callReport();
        ctrl.clearFilter();
        ctrl.getSortDirection();
        ctrl.sortWrapperList();
        Test.stopTest();
        System.debug(ctrl.reportWrapperList + '====> ctrl.reportWrapperList');
        System.debug(ctrl.reportWrapperList.size() + '====> ctrl.reportWrapperList');
        System.assertEquals(ctrl.reportWrapperList.size() , 0);

    }

    @isTest
    static void addtoCampaign() {
        Project__c proj = [SELECT Id FROM Project__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        EventAndProjectRolesReportCtrl ctrl = new EventAndProjectRolesReportCtrl();
        ctrl.filterType = 'projects';
        ctrl.ProjectID = proj.Id;
        ctrl.campaignId = camp.Id;
        Test.startTest();
        ctrl.sortExpression = 'DESC';
        ctrl.projectSelectedMethod();
        ctrl.callReport();
        ctrl.addToCampaign();
        ctrl.addSelectedToCampaign();
        ctrl.cancelAddtoCampaign();
        Test.stopTest();
        System.debug(ctrl.reportWrapperList + '====> ctrl.reportWrapperList');
        System.debug(ctrl.reportWrapperList.size() + '====> ctrl.reportWrapperList');
        Integer count = [SELECT count() FROM CampaignMember];
        System.assertEquals(count, 0);
    }
}