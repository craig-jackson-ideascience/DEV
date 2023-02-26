/**
 * Test class for ReportSettingCtrl
 */
@istest
public class ReportSettingCtrl_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@testSetup
	static void testSetup(){
		Report_Settings__c setting = new Report_Settings__c();
		setting.Name = 'Kubecone Event';
		String startDate = String.valueOf(System.today().addDays(-180));
		String endDate = String.valueOf(System.today().addDays(180));
		setting.Filter__c = '{"Events":{"EventName":"KubeCon","' + startDate + '":"' + endDate + '","EventEndDate":"2021-12-31","ProductName":["Platinum Sponsorship","Diamond Sponsorship","Silver Sponsorship","Gold Sponsorship"]}}';
		setting.Project_Filter__c = '{"Projects":{"EventName":["KubeCon + CloudNativeCon + Open Source Summit China 2020","FoundationDB Summit 2018"],"ProjectName":["Cloud Native Computing Foundation"]}}';
		insert setting;

		Project__c project = new Project__c(Name = 'The Linux Foundation',                                                                                                                                             // Project Name
		Status__c = 'Planned',                                                                                                                                                        // Status
		Category__c = 'Directed Fund',                                                                                                                                                // Category
		ProjectSector__c = 'Platforms',                                                                                                                                              // Project Sector
		Membership_Autorenew__c = 'Yes',                                                                                                                                             // Membership Autorenew
		Start_Date__c = system.today()-10,                                                                                                                                   // Start Date
		Renewal_Type__c = 'Prorate',                                                                                                                                                 // Renewal Type
		Payment_Frequency__c = 'Annually',                                                                                                                                           // Auto Renew Membership
		Bill_From_Name__c = 'The Linux Foundation',                                                                                                                                  // Bill From Name
		Email_From_Name__c = 'Accounts Receivable',                                                                                                                                  // Email From Name
		Bill_From_Address__c = '1 Letterman Drive, Suite D4700',                                                                                                                     // Bill From Address
		Email_From_Address__c = 'accountsreceivable@linuxfoundation.org',                                                                                                    // Email From Address
		Bill_From_City__c = 'San Francisco',                                                                                                                                         // Bill From City
		Bill_From_Phone__c = '+1 415-723-9709',                                                                                                                                      // Bill From Phone
		Bill_From_State__c = 'CA',                                                                                                                                                   // Bill From State
		Bill_From_Website__c = 'www.linuxfoundation.org',                                                                                                                            // Bill From Website
		Bill_From_Zip__c = '94129',                                                                                                                                                  // Bill From Zip
		Image_File_for_PDF__c = 'the_linux_foundation_pdf_logo.jpg',                                                                                                                 // Image File for PDF
		Bill_From_Country__c = 'United States',                                                                                                                                      // Bill From Country
		Include_W9__c = true,                                                                                                                                                        // Include W9
		Project_Code__c = 'LF',                                                                                                                                                      // Project Code
		Type__c = 'Membership',                                                                                                                                                 // Record Type
		Billfrom_ID__c = 'bf98299e-6a68-0f85-236b-52a0a366caba',                                                                                                                     // Billfrom ID
		Manual_Status_Check__c = true, Slug__c = 'testing', Model__c = 'Alternate Funding'                                                                                                                                             // Manual Status Check
		);
		insert project;
		project.Status__c = 'Active';
		project.Funding__c = 'Funded';
		update project;


		Event__c event = new Event__c(Event_Name__c = 'FoundationDB Summit 2018', Name = 'FoundationDB Summit 2018',      // Event Name
		Status__c = 'Complete',                                                                                                                                                    // Event Status
		Category__c = 'LF Event',                                                                                                                                                  // Category
		BillFromProject__c = project.id,   //ID                                                                                                                                  // Bill From Project
		Start_Date__c = system.today()-20,                                                                                                                                 // Event Start Date
		Capacity__c = 0,                                                                                                                                            // Event Start Time
		End_Date__c = system.today()-10,                                                                                                                                   // Event End Date
		Registration_Source__c = 'RegOnline',                                                                                                                                             // Event End Time
		Event_Location_Name__c = 'Twitter HQ One 10th Street Expansion',                                                                                                           // Event Location Name
		Event_Published__c = false,                                                                                                                                                // Event Published
		Event_Location_Address__c = 'One 10th Street',                                                                                                                             // Event Location Address
		Event_Location_City__c = 'San Francisco',                                                                                                                                  // Event Location City
		Event_Location_State__c = 'California',                                                                                                                                    // Event Location State
		Event_Location_Country__c = 'United States',                                                                                                                               // Event Location Country
		Event_Location_Zip__c = '94103',                                                                                                                                           // Event Location Zip
		Embassy__c = 'US',                                                                                                                                                         // Embassy
		Cvent_Event_Is_Sandbox__c = false,                                                                                                                                               // NS Department
		//Type__c = 'Email',                                                                                                                                                       // Type
		Netsuite_Sync__c = false                                                                                                                                                // Netsuite Sync
		);
		insert event;

		Account account = TestDataUtils.createAccount(true, 'Test Account');

		//Product
		Product2 product2obj = TestDataUtils.createProduct(true, 'Platinum Sponsorship', 'Platinum Sponsorship', true, 'Event');
		//PriceBookEntry
		PricebookEntry standardPrice = TestDataUtils.createPriceBookEntryID(true, product2obj.Id);

		Asset assetObj = new Asset(Name = 'Intel Corporation - Academy Software Foundation - Premier Membership - 2019',           // Purchase History Name
		Status = 'Active',                                                                             // Status
		AccountId = account.id,                                                                    // Account
		Annual_Full_Price__c = 50000,                                                                     // Annual/Full Price
		Price = 50000,                                                                                    // Price
		Agreement_Date__c = system.today()-6,                                                    // Agreement Date
		Product2Id = product2obj.id,                                                                   // Product
		PurchaseDate = system.today()-6,                                                         // Purchase Date
		InstallDate = system.today()-16,                                                           // Install Date
		UsageEndDate = system.today()-26,                                                         // Usage End Date
		Quantity = 1.00,                                                                                // Quantity
		Number_of_Years_Required__c = 2,                                                                // Number of Years Required
		Year__c = '2019',                                                                                 // Year
		Description = '2018 Motion Picture Software Foundation Fund Premier Membership',                  // Description
		Press_Release_Announcement__c = false,                                                            // No Press Release Announcement
		Display_Logo_On_Website__c = false,                                                               // Don't Display Logo On Website
		Renewal_Type__c = 'Prorate',                                                                      // Renewal Type
		PaymentFrequency__c = 'Annually',                                                                 // Payment Frequency
		Auto_Renew__c = true,                                                                             // Auto-Renew
		PaymentTerms__c = 'Net 30',                                                                       // Payment Terms
		Renewal_Opportunity_Created__c = false,                                                           // Renewal Opportunity Created?
		SalesOrderNumber__c = 'SO8959',                                                                   // Sales Order Number
		PAL_INVOICE__c = false,                                                                           // LFAPAC Invoice
		SalesOrderStatus__c = 'Closed',                                                                   // Sales Order Status
		Skip_NetSuite_Sync__c = false,                                                                    // Skip NetSuite Sync
		NetSuite_Class__c = '792',                                                                        // NetSuite Class
		NetSuite_Department__c = 'Sales',                                                                 // NetSuite Department
		Bill_From__c = 'The Linux Foundation',                                                            // Bill From
		NetSuite_Income_GL_Account__c = '4310 Directed Funds : Directed Fund Revenue',                    // NetSuite Income GL Account
		NetSuite_ID__c = '1631719',                                                                       // NetSuite ID
		NetSuite_Deferred_Revenue_Account__c = 'Deferred Revenue : Deferred Revenue - Directed Funds',    // NetSuite Deferred Revenue Account
		NetSuite_Revenue_Schedule__c = 'Directed Fund',                                                   // NetSuite Revenue Schedule
		Tax_Class__c = 'T1', Order__c = 2, Event__c = event.id,   // Order
		Projects__c = project.id, Bill_From_ID__c = project.id);
		insert assetObj;

		Opportunity Opp = new Opportunity();
		Opp.name = 'Alcide_KubeCon EU & NA 2020 silver';
		Opp.CloseDate = system.today()+10;
		opp.Description = 'testing description';
		opp.Type = 'Existing Business';
		Opp.TotalOpportunityQuantity = 5;
		opp.AccountID = account.id;
		opp.StageName = '2. Discovery';
		opp.Loss_Reason__c = 'Non payment';
		opp.Pricebook2Id = Test.getStandardPricebookId();
		insert opp;

		OpportunityLineItem oppLine = new OpportunityLineItem();
		oppLine.OpportunityID = opp.Id;
		oppLine.Quantity = 3;
		oppLine.UnitPrice = 1800.00;
		oppLine.Event__c = event.Id;
		OppLine.Product2id = product2obj.Id;
		insert OppLine;
	}

	/**
	 * testScenario : Test Method for all methods of ReportSettingCtrl
	 */
	@istest
	static void testScenario(){
		ReportSettingCtrl ctrl = new ReportSettingCtrl();
		List<SelectOption> prodNamesList = ctrl.getProductName();

		//Asserts
		System.assertEquals(1, prodNamesList.size(), 'List must have 1 element');

		//Before Asserts
		System.assertEquals(null, ctrl.eventReportCsv, 'eventReportCsv must be null');
		ctrl.createCsv();
		//After Asserts
		System.assertNotEquals(null, ctrl.eventReportCsv, 'eventReportCsv must not be null');

		ctrl.LoadEventsfromProjects();
		//Asserts
		System.assertNotEquals(null, ctrl.eventsWrapper, 'eventsWrapper must not be null');

		List<SelectOption> projectNamesList = ctrl.getProjectName();
		//Asserts
		System.assertEquals(1, projectNamesList.size(), 'List must have 1 element');
	}
}