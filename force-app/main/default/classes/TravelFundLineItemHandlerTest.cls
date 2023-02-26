/**
 * Test class for TravelFundLineItemHandler
 */
@istest
public class TravelFundLineItemHandlerTest {
    /**
	 *testSetup: create the required data for testing
	 */
    @testSetup static void setup() {
        // create project
        Project__c project = new Project__c(
                Name = 'The Linux Foundation',
                Status__c = 'Planned',
                Funding__c = 'Funded',
                Category__c = 'Incorporated Entity',
                ProjectSector__c = 'Platforms',
                Membership_Autorenew__c = 'Yes',
                Start_Date__c = system.today() - 10,
                Renewal_Type__c = 'Prorate',
                Payment_Frequency__c = 'Annually',
                Bill_From_Name__c = 'The Linux Foundation',
                Email_From_Name__c = 'Accounts Receivable',
                Bill_From_Address__c = '1 Letterman Drive, Suite D4700',
                Email_From_Address__c = 'accountsreceivable@linuxfoundation.org',
                Bill_From_City__c = 'San Francisco',
                Bill_From_Phone__c = '+1 415-723-9709',
                Bill_From_State__c = 'CA',
                Bill_From_Website__c = 'www.linuxfoundation.org',
                Bill_From_Zip__c = '94129',
                Image_File_for_PDF__c = 'the_linux_foundation_pdf_logo.jpg',
                Bill_From_Country__c = 'United States',
                Include_W9__c = true,
                Project_Code__c = 'LF',
                Type__c = 'Membership',
                Billfrom_ID__c = 'bf98299e-6a68-0f85-236b-52a0a366caba',
                Manual_Status_Check__c = true,
                Slug__c = 'test_slug',
                Model__c = 'Membership'
        );
        insert project;

        // updating Project Status to Active
        project.Manual_Status_Check__c = false;
        project.Status__c = 'Active';
        update project;

        // Create event
        Event__c event = new Event__c(Event_Name__c = 'KubeCon',
                Name = 'KubeCon',
                Status__c = 'Complete',
                Category__c = 'LF Event',
                BillFromProject__c = project.id,
                Start_Date__c = system.today() - 20,
                Capacity__c = 0,
                End_Date__c = system.today() - 10,
                Registration_Source__c = 'RegOnline',
                Event_Location_Name__c = 'Twitter HQ One 10th Street Expansion',
                Event_Published__c = false,
                Event_Location_Address__c = 'One 10th Street',
                Event_Location_City__c = 'San Francisco',
                Event_Location_State__c = 'California',
                Event_Location_Country__c = 'United States',
                Event_Location_Zip__c = '94103',
                Embassy__c = 'US',
                Cvent_Event_Is_Sandbox__c = false,
                //Type__c = 'Email',
                Netsuite_Sync__c = false);
        insert event;
        System.assert(event.Id != null, 'The Test Event did not insert properly');

        // create contact
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        insert con;
        System.assert(con.Id != null, 'The Test Contact did not insert properly');

        // create alternate email
        Alternate_Email__c alt = new Alternate_Email__c(
                Alternate_Email_Address__c = 'abc@gmail.com',
                Contact_Name__c = con.Id,
                Active__c = true
        );
        insert alt;
        System.assert(alt.Id != null, 'The Alternate Email did not insert properly');
    }

    /**
	 * test1: test method for TravelFundLineItemHandler
	 */
    @isTest public static void test1() {

        Event__c event = [Select Id from Event__c Where Name = 'KubeCon'];

        // create travel fund request
        Travel_Fund_Request__c tfr = new Travel_Fund_Request__c();
        tfr.Name = 'TFR Test';
        tfr.Event__c = event.Id;
        tfr.FirstName__c = 'test firstName';
        tfr.LastName__c = 'test LastName';
        tfr.TFREmail__c = 'abc@gmail.com';
        insert tfr;
        System.assert(tfr.Id != null, 'The Test tfr did not insert properly');

        // create travel fund request lines
        Travel_Fund_Request_Line_Item__c tlineItems = new Travel_Fund_Request_Line_Item__c(
                Travel_Fund_Request__c = tfr.id,
                Cost__c = 150.00,
                Approved__c = false,
                Type__c = 'Hotel',
                Line_Description__c = 'Some Hotel'
        );

        insert tlineItems;

        tlineItems.Line_Status__c = 'Rejected';
       // update tlineItems;

        Travel_Fund_Request_Line_Item__c tlineItems2 = new Travel_Fund_Request_Line_Item__c(
                Travel_Fund_Request__c = tfr.id,
                Cost__c = 150.00,
                Approved__c = false,
                Type__c = 'Hotel',
                Line_Status__c = 'Approved',
                Line_Description__c = 'Some Hotel'
        );
        test.startTest();
        insert tlineItems2;
        Delete tlineItems;
        test.stopTest();
    }
}