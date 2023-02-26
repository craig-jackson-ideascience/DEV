@isTest
public class TravelFundExpenseReminderTest {
    @isTest
    public static void testData() {

        Contact conRecord = new Contact();
        conRecord.LastName = 'test';
        conRecord.Email = 'test@linuxfoundation.org';

        Contact conRecord2 = new Contact();
        conRecord2.LastName = 'test2';
        conRecord2.Email = 'test2@linuxfoundation.org';

        insert conRecord;
        insert conRecord2;

        Project__c parentProject = new Project__c();
        parentProject.Name = 'Parent Project';
        parentProject.Slug__c = 'test_parent_slug';
        insert parentProject;

        Project__c proj = new Project__c(
                Name = 'The Linux Foundation',
                Project_Status__c = 'Active',
                Type__c = 'Membership',
                Project_Processing__c = false,
                Project_Type__c = 'Project Group',
                Category__c = 'Incorporated Entity',
                Start_Date__c = System.Date.today().addYears(-4),
                Pipeline_Stage__c = 'Exploratory Discussions',
                Auto_Join_Enabled__c = false,
                Slug__c = 'test_slug',
                Project_Entity_Name__c = 'test formal name',
                Funding__c = 'Funded',
                Industry__c = 'Automotive',
                Model__c = 'Membership',
                Parent_Entity_Relationship__c = parentProject.Id,
                Parent_Project__c = parentProject.Id,
                Technology__c = 'Storage',
                Technical_Activity_Type__c = 'Open Data',
                Status__c = 'Planned'
        );
        insert proj;

        proj.Manual_Status_Check__c = false;
        proj.Status__c = 'Active';
        update proj;


        Event__c sobj = new Event__c(
                Name = 'Test Event',                                                   // Event Name
                Status__c = 'Active',                                                   // Event Status
                Category__c = 'LF Event',                                               // Category
                BillFromProject__c = proj.Id,                                           // bill from project
                Start_Date__c = System.Date.today().addMonths(-10),                      // Event Start Date
                End_Date__c = System.Date.today().addDays(-1),                          // Event End Date
                Response_Date__c = System.Date.today().addDays(30),                     // Event Response Date
                Total_Approved_Travel_Funds__c = 100.00,                                // Total Approved Travel Funds
                Accept_Travel_Fund__c = 'Yes',                                          // Accept Travel Fund
                TravelFund_End_Date__c = System.Date.Today().addDays(-1),               // Travel Fund End Date
                Expensify_Policy_ID__c = '0B88ECC20487677E'                             // Expensify Id
        );
        System.debug('Event obj: ' + sobj);
        insert sobj;

        Travel_Fund_Request__c tfr = new Travel_Fund_Request__c(
                Name = 'Test Travel Fund ',                                       // Name
                FirstName__c = 'Test',                                            // FirstName
                Status__c = 'Request Approved - Waiting For Expense Report',      // Status
                Amount_Approved__c = 500,                                         // Approved Amount
                LastName__c = 'testLastName',                                     // LastName
                Event__c = sobj.Id,                                               //Events
                TFREmail__c = 'test@linuxfoundation.org',                               // TFREmail
                Contact__c = conRecord.Id,                                   // Contact
                Travelling_From__c = 'India',                                     // Travelling From
                Estimated_Cost__c = 500.00,                                       // Est Cost
                Expensify_ID__c = null                                            // Expensify Id
        );
        insert tfr;
        Travel_Fund_Request__c tfr1 = new Travel_Fund_Request__c(
                Name = 'Test Travel Fund 1 ',                                     // Name
                FirstName__c = 'Test 1',                                            // FirstName
                Status__c = 'Waiting Approval',                                   // Status
                Amount_Approved__c = 500,                                         // Approved Amount
                LastName__c = 'testLastName1',                                     // LastName
                Event__c = sobj.Id,                                                //Events
                TFREmail__c = 'test2@linuxfoundation.org',                               // TFREmail
                Contact__c = conRecord2.Id,                                         // Contact
                Travelling_From__c = 'USA',                                      // Travelling From
                Estimated_Cost__c = 600.00,                                       // Est Cost
                Expensify_ID__c = null                                            // Expensify Id
        );
        insert tfr1;
        Test.startTest();
        String cronExp = '0 0 5 * * ?';
        System.schedule('tfr Expense Reminder', cronExp, new TravelFundExpenseReminderSchedular());

        tfr1.Status__c = 'Request Approved - Waiting For Expense Report';
        update tfr1;
        Test.stopTest();
    }
}