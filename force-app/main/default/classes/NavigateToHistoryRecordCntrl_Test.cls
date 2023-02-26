@istest
public class NavigateToHistoryRecordCntrl_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@TestSetup
	static void createTestData(){
		Report_Settings__c setting = new Report_Settings__c();
		setting.Name = 'Kubecone Event';
		setting.Filter__c = '{ "Events": { "EventName":"KubeCon", "EventStartDate":"2018-01-01", "EventEndDate":"2018-01-01", "ProductName":["Platinum Sponsorship","Diamond Sponsorship"] } }';
		insert setting;
		Project__c project = new Project__c(Name = 'The Linux Foundation',                                                                                                                                            // Project Name
		Status__c = 'Planned',                                                                                                                                                       // Status
		Category__c = 'Directed Fund',                                                                                                                                               // Category
		ProjectSector__c = 'Platforms',                                                                                                                                             // Project Sector
		Membership_Autorenew__c = 'Yes',                                                                                                                                            // Membership Autorenew
		Start_Date__c = system.today()-10,                                                                                                                                  // Start Date
		Renewal_Type__c = 'Prorate',                                                                                                                                                // Renewal Type
		Payment_Frequency__c = 'Annually',                                                                                                                                          // Auto Renew Membership
		Bill_From_Name__c = 'The Linux Foundation',                                                                                                                                 // Bill From Name
		Email_From_Name__c = 'Accounts Receivable',                                                                                                                                 // Email From Name
		Bill_From_Address__c = '1 Letterman Drive, Suite D4700',                                                                                                                    // Bill From Address
		Email_From_Address__c = 'accountsreceivable@linuxfoundation.org',                                                                                                   // Email From Address
		Bill_From_City__c = 'San Francisco',                                                                                                                                        // Bill From City
		Bill_From_Phone__c = '+1 415-723-9709',                                                                                                                                     // Bill From Phone
		Bill_From_State__c = 'CA',                                                                                                                                                  // Bill From State
		Bill_From_Website__c = 'www.linuxfoundation.org',                                                                                                                           // Bill From Website
		Bill_From_Zip__c = '94129',                                                                                                                                                 // Bill From Zip
		Image_File_for_PDF__c = 'the_linux_foundation_pdf_logo.jpg',                                                                                                                // Image File for PDF
		Bill_From_Country__c = 'United States',                                                                                                                                     // Bill From Country
		Include_W9__c = true,                                                                                                                                                       // Include W9
		Project_Code__c = 'LF',                                                                                                                                                     // Project Code
		Type__c = 'Membership',                                                                                                                                                // Record Type
		Billfrom_ID__c = 'bf98299e-6a68-0f85-236b-52a0a366caba',                                                                                                                    // Billfrom ID
		Manual_Status_Check__c = true,
		Model__c = 'Membership',
		Slug__c = 'testing'                                                                                                                                             // Manual Status Check
		);
		insert project;

		project.Status__c = 'Active';
		project.Funding__c = 'Funded';
		update project;

		Event__c event = new Event__c(Event_Name__c = 'KubeCon', Name = 'KubeCon',     // Event Name
		Status__c = 'Complete',                                                                                                                                                   // Event Status
		Category__c = 'LF Event',                                                                                                                                                 // Category
		BillFromProject__c = project.id,  //ID                                                                                                                                  // Bill From Project
		Start_Date__c = system.today()-20,                                                                                                                                // Event Start Date
		Capacity__c = 0,                                                                                                                                           // Event Start Time
		End_Date__c = system.today()-10,                                                                                                                                  // Event End Date
		Registration_Source__c = 'RegOnline',                                                                                                                                            // Event End Time
		Event_Location_Name__c = 'Twitter HQ One 10th Street Expansion',                                                                                                          // Event Location Name
		Event_Published__c = false,                                                                                                                                               // Event Published
		Event_Location_Address__c = 'One 10th Street',                                                                                                                            // Event Location Address
		Event_Location_City__c = 'San Francisco',                                                                                                                                 // Event Location City
		Event_Location_State__c = 'California',                                                                                                                                   // Event Location State
		Event_Location_Country__c = 'United States',                                                                                                                              // Event Location Country
		Event_Location_Zip__c = '94103',                                                                                                                                          // Event Location Zip
		Embassy__c = 'US',                                                                                                                                                        // Embassy
		Cvent_Event_Is_Sandbox__c = false,                                                                                                                                              // NS Department
		//Type__c = 'Email',                                                                                                                                                       // Type
		Netsuite_Sync__c = false                                                                                                                                                // Netsuite Sync
		);
		insert event;

		Account acc = new Account();
		acc.Name = 'TEST ACC';
		insert acc;

		Product2 product2obj = new Product2(Name = 'Platinum Sponsorship', // Product Name
		IsActive = true,              // Active
		Family = 'Event',        // Product Family
		Tax_Class__c = 'T1'         // Tax Class
		);
		insert product2obj;

		Asset assetObj = new Asset(Name = 'Intel Corporation - Academy Software Foundation - Premier Membership - 2019',          // Purchase History Name
		Status = 'Purchased',                                                                            // Status
		AccountId = acc.id,                                                                   // Account
		Annual_Full_Price__c = 50000,                                                                    // Annual/Full Price
		Price = 50000,                                                                                   // Price
		Agreement_Date__c = system.today()-6,                                                   // Agreement Date
		Product2Id = product2obj.id,                                                                  // Product
		PurchaseDate = system.today()-6,                                                        // Purchase Date
		InstallDate = system.today()-16,                                                          // Install Date
		UsageEndDate = system.today()-26,                                                        // Usage End Date
		Quantity = 1.00,                                                                               // Quantity
		Number_of_Years_Required__c = 2,                                                               // Number of Years Required
		Year__c = '2019',                                                                                // Year
		Description = '2018 Motion Picture Software Foundation Fund Premier Membership',                 // Description
		Press_Release_Announcement__c = false,                                                           // No Press Release Announcement
		Display_Logo_On_Website__c = false,                                                              // Don't Display Logo On Website
		Renewal_Type__c = 'Prorate',                                                                     // Renewal Type
		PaymentFrequency__c = 'Annually',                                                                // Payment Frequency
		Auto_Renew__c = true,                                                                            // Auto-Renew
		PaymentTerms__c = 'Net 30',                                                                      // Payment Terms
		Renewal_Opportunity_Created__c = false,                                                          // Renewal Opportunity Created?
		SalesOrderNumber__c = 'SO8959',                                                                  // Sales Order Number
		PAL_INVOICE__c = false,                                                                          // LFAPAC Invoice
		SalesOrderStatus__c = 'Closed',                                                                  // Sales Order Status
		Skip_NetSuite_Sync__c = false,                                                                   // Skip NetSuite Sync
		NetSuite_Class__c = '792',                                                                       // NetSuite Class
		NetSuite_Department__c = 'Sales',                                                                // NetSuite Department
		Bill_From__c = 'The Linux Foundation',                                                           // Bill From
		NetSuite_Income_GL_Account__c = '4310 Directed Funds : Directed Fund Revenue',                   // NetSuite Income GL Account
		NetSuite_ID__c = '1631719',                                                                      // NetSuite ID
		NetSuite_Deferred_Revenue_Account__c = 'Deferred Revenue : Deferred Revenue - Directed Funds',   // NetSuite Deferred Revenue Account
		NetSuite_Revenue_Schedule__c = 'Directed Fund',                                                  // NetSuite Revenue Schedule
		Tax_Class__c = 'T1', Order__c = 2, Event__c = event.id,  // Order
		Projects__c = project.id                                                                      // Project
		);
		insert assetObj;
	}

	/**
	 * TestMethod to cover the NavigateToHistoryRecordCntrl Class Methods
	 */
	@istest
	static void testScenario(){

		Test.setCurrentPage(Page.NavigateToHistoryRecord);
		ApexPages.currentPage().getParameters().put('HistoryValue', 'TEST ACC-KubeCon-Platinum Sponsorship');
		Test.setCurrentPage(Page.NavigateToHistoryRecord);
		ApexPages.currentPage().getParameters().put('HistoryValue', 'TEST ACC-KubeCon-Platinum Sponsorship');
		String id = ApexPages.currentPage().getParameters().get('HistoryValue');

		NavigateToHistoryRecordCntrl ctrl = new NavigateToHistoryRecordCntrl();
		PageReference pageReference = ctrl.RedirectToHistoryRecord();

		//Asserts
		System.assertNotEquals(null, pageReference,'PageRefernece must not be null');
	}
}