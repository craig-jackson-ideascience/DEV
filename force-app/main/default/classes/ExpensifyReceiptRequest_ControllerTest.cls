@isTest
public class ExpensifyReceiptRequest_ControllerTest{
	@isTest
	static void expensifyRecReqCon_Test1(){
		Test.setMock(HttpCalloutMock.class, new ExpensifyCalloutMockTest());
		Contact conRecord = new Contact();
		conRecord.LastName = 'test';
		conRecord.Email = 'test@linuxfoundation.org';
		insert conRecord;

		//Creating Project Record Id
		//Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Subproject'].Id;
		testFactory.getAccount();
		Project__c testProjObj = new Project__c();
		testProjObj.Name = 'The Linux Foundation';
		//testProjObj.RecordTypeId = directedProjectId;
		testProjObj.Status__c = 'Planned';
		testProjObj.Type__c = 'Membership';
		testProjObj.Category__c = 'Subproject';
		testProjObj.Manual_Status_Check__c = false;
		testProjObj.Slug__c = 'testing';
		testProjObj.Model__c = 'Membership';
		insert testProjObj;

		testProjObj.Status__c = 'Active';
		testProjObj.Funding__c = 'Funded';
		update testProjObj;

		Event__c evtRecord = new Event__c();
		evtRecord.Name = 'My New Event';
		evtRecord.Expensify_Policy_ID__c = '554237F4AB23B96D';
		evtRecord.Accept_Travel_Fund__c = 'Yes';
		evtRecord.Expensify_Policy_ID__c = '3657';
		evtRecord.BillFromProject__c = testProjObj.Id;
		insert evtRecord;


		EMS__c ems = new EMS__c();
		ems.Name = ' - Event Management Service';
		ems.Event__c = evtRecord.Id;
		ems.StartDate__c = evtRecord.Start_Date__c;
		ems.Bill_From__c = testProjObj.id;
		ems.EMS_Number__c = evtRecord.name + ' ' + String.valueOf(Date.today().year()).substring(2, 4)+String.valueOf(Date.today().month());
		ems.Product__c = '22';
		ems.EMS_Status__c = 'Not Started';
		ems.NS_Department__c = '2';
		ems.NS_Income_GL_Account__c = evtRecord.NS_Income_GL_Account__c;
		ems.NS_Deferred_Revenue_Account__c = evtRecord.NS_Deferred_Revenue_Account__c;
		ems.NS_Revenue_Schedule__c = evtRecord.NS_Revenue_Schedule__c;
		insert ems;

		Travel_Fund_Request__c newTravelFund = new Travel_Fund_Request__c();
		newTravelFund.Name = 'New Travel Fund';
		newTravelFund.Status__c = 'Waiting Approval';
		newTravelFund.Event__c = evtRecord.Id;
		newTravelFund.Contact__c = conRecord.Id;
		newTravelFund.Expensify_Report_Name__c = '56456';
		newTravelFund.TFREmail__c = 'test@linuxfoundation.org';
		insert newTravelFund;

		Expensify_Attachment__c expenAttach = new Expensify_Attachment__c();
		expenAttach.Report_Id__c = '54160232';
		expenAttach.URL__c = 'https://s3.amazonaws.com/receipts.expensify.com/w_45c7f11b2a8e505d79b434102b3d13acaeed090a.jpg';
		expenAttach.Travel_Fund_Request__c = newTravelFund.Id;
		insert expenAttach;

		Test.startTest();
		expensifyReceiptRequest_Controller.fileName(newTravelFund.Id, false);
		//expensifyReceiptRequest_Controller.notifyExpensifyRequestor_Apex(newTravelFund.Id);
		//expensifyReceiptRequest_Controller.updateStatusFromApprovedToReimbursed(newTravelFund.Id);
		Test.stopTest();
	}

	//@isTest
	/*static void expensifyRecReqCon_Test2() {

	 Test.setMock(HttpCalloutMock.class, new ExpensifyCalloutMockTest());
	 Contact conRecord = new Contact();
	 conRecord.LastName = 'test';
	 conRecord.Email = 'test@webuters.com';
	 insert conRecord;
	//Creating Project Record Id
	//Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Subproject'].Id;
	 testFactory.getAccount();
	 Project__c testProjObj = new Project__c ();
	 testProjObj.Name = 'The Linux Foundation';
	//testProjObj.RecordTypeId = directedProjectId;
	 testProjObj.Status__c = 'Planned';
	 testProjObj.Type__c = 'Membership';
	 testProjObj.Category__c = 'Subproject';
	 testProjObj.Manual_Status_Check__c = false;
	 insert testProjObj;

	 Event__c evtRecord = new Event__c();
	 evtRecord.Name = 'My New Event';
	 evtRecord.Expensify_Policy_ID__c = '554237F4AB23B96D';
	 insert evtRecord;


	 EMS__c ems = new EMS__c();
	 ems.Name = ' - Event Management Service';
	 ems.Event__c = evtRecord.Id;
	 ems.StartDate__c = evtRecord.Start_Date__c;
	 ems.Bill_From__c = testProjObj.id;
	 ems.EMS_Number__c = evtRecord.name + ' ' + String.valueOf(Date.today().year()).substring(2, 4) + String.valueOf(Date.today().month());
	 ems.Product__c = '22';
	 ems.EMS_Status__c = 'Not Started';
	 ems.NS_Department__c = '2';
	 ems.NS_Income_GL_Account__c = evtRecord.NS_Income_GL_Account__c;
	 ems.NS_Deferred_Revenue_Account__c = evtRecord.NS_Deferred_Revenue_Account__c;
	 ems.NS_Revenue_Schedule__c = evtRecord.NS_Revenue_Schedule__c;
	 insert ems;

	 Travel_Fund_Request__c newTravelFund = new Travel_Fund_Request__c();
	 newTravelFund.Name = 'TestCreateTravelFundTest';
	 newTravelFund.Status__c = 'Request Approved - Waiting For Expense Report';
	 newTravelFund.Event__c = evtRecord.Id;
	 newTravelFund.Contact__c = conRecord.Id;
	 newTravelFund.Expensify_Report_Name__c = '56456';
	 insert newTravelFund;

	 ContentVersion conVer = new ContentVersion();
	 conVer.ContentLocation = 'S';
	 conVer.Title = 'My Data';
	 Blob blobValue = Blob.valueOf('My data for blob.');
	 conVer.VersionData = blobValue;
	 conVer.PathOnClient = 'My path on client';
	 insert conVer;

	 Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;
	 system.debug('conDoc::: ' + conDoc);

	 ContentDocumentLink cDe = new ContentDocumentLink();
	 cDe.ContentDocumentId = conDoc;
	 cDe.LinkedEntityId = newTravelFund.Id;
	 cDe.ShareType = 'I';
	 insert cDe;

	 Test.startTest();
	 RecursiveTriggerHandler.isFirstTime = false;
	 expensifyReceiptRequest_Controller.requestorNotification(newTravelFund.Id);
	 Test.stopTest();
	 }*/
	@isTest
	static void expensifyRecReqCon_Test3(){

		Test.setMock(HttpCalloutMock.class, new ExpensifyCalloutMockTest());
		Contact conRecord = new Contact();
		conRecord.LastName = 'test';
		conRecord.Email = 'test@webuters.com';
		insert conRecord;

		//Creating Project Record Id
		//Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Subproject'].Id;
		testFactory.getAccount();
		Project__c testProjObj = new Project__c();
		testProjObj.Name = 'The Linux Foundation';
		//testProjObj.RecordTypeId = directedProjectId;
		testProjObj.Status__c = 'Planned';
		testProjObj.Type__c = 'Membership';
		testProjObj.Category__c = 'Subproject';
		testProjObj.Manual_Status_Check__c = false;
		testProjObj.Slug__c = 'testing1';
		testProjObj.Model__c = 'Membership';
		insert testProjObj;

		testProjObj.Status__c = 'Active';
		testProjObj.Funding__c = 'Funded';
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
		ems.Bill_From__c = testProjObj.id;
		ems.EMS_Number__c = evtRecord.name + ' ' + String.valueOf(Date.today().year()).substring(2, 4)+String.valueOf(Date.today().month());
		ems.Product__c = '22';
		ems.EMS_Status__c = 'Not Started';
		ems.NS_Department__c = '2';
		ems.NS_Income_GL_Account__c = evtRecord.NS_Income_GL_Account__c;
		ems.NS_Deferred_Revenue_Account__c = evtRecord.NS_Deferred_Revenue_Account__c;
		ems.NS_Revenue_Schedule__c = evtRecord.NS_Revenue_Schedule__c;
		insert ems;

		Travel_Fund_Request__c newTravelFund = new Travel_Fund_Request__c();
		newTravelFund.Name = 'TestCreateTravelFundTest';
		newTravelFund.Status__c = 'Request Approved - Waiting For Expense Report';
		newTravelFund.Amount_Approved__c = 100;
		newTravelFund.Event__c = evtRecord.Id;
		newTravelFund.Contact__c = conRecord.Id;
		newTravelFund.Expensify_Report_Name__c = '56456';
		insert newTravelFund;

		Test.startTest();
		RecursiveTriggerHandler.isFirstTime = false;
		expensifyReceiptRequest_Controller.notifyExpensifyRequestor_Apex(newTravelFund.Id);
		Test.stopTest();
	}

	@isTest
	static void expensifyRecReqCon_Test4(){

		Test.setMock(HttpCalloutMock.class, new ExpensifyCalloutMockTest());

		Contact conRecord = new Contact();
		conRecord.LastName = 'test';
		conRecord.Email = 'test@webuters.com';
		insert conRecord;

		//Creating Project Record Id
		//Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Subproject'].Id;
		testFactory.getAccount();
		Project__c testProjObj = new Project__c();
		testProjObj.Name = 'The Linux Foundation';
		//testProjObj.RecordTypeId = directedProjectId;
		testProjObj.Status__c = 'Planned';
		testProjObj.Type__c = 'Membership';
		testProjObj.Category__c = 'Subproject';
		testProjObj.Manual_Status_Check__c = false;
		testProjObj.Slug__c = 'testing2';
		testProjObj.Model__c = 'Membership';
		insert testProjObj;

		testProjObj.Status__c = 'Active';
		testProjObj.Funding__c = 'Funded';
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
		ems.Bill_From__c = testProjObj.id;
		ems.EMS_Number__c = evtRecord.name + ' ' + String.valueOf(Date.today().year()).substring(2, 4)+String.valueOf(Date.today().month());
		ems.Product__c = '22';
		ems.EMS_Status__c = 'Not Started';
		ems.NS_Department__c = '2';
		ems.NS_Income_GL_Account__c = evtRecord.NS_Income_GL_Account__c;
		ems.NS_Deferred_Revenue_Account__c = evtRecord.NS_Deferred_Revenue_Account__c;
		ems.NS_Revenue_Schedule__c = evtRecord.NS_Revenue_Schedule__c;
		insert ems;

		Travel_Fund_Request__c newTravelFund = new Travel_Fund_Request__c();
		newTravelFund.Name = 'TestCreateTravelFundTest';
		newTravelFund.Status__c = 'Paid';
		newTravelFund.Event__c = evtRecord.Id;
		newTravelFund.Contact__c = conRecord.Id;
		newTravelFund.Expensify_Report_Name__c = '56456';
		insert newTravelFund;

		Expensify_Attachment__c expenAttach = new Expensify_Attachment__c();
		expenAttach.Report_Id__c = '54160232';
		expenAttach.URL__c = 'https://s3.amazonaws.com/receipts.expensify.com/w_45c7f11b2a8e505d79b434102b3d13acaeed090a.jpg';
		expenAttach.Travel_Fund_Request__c = newTravelFund.Id;
		insert expenAttach;

		Test.startTest();
		expensifyReceiptRequest_Controller.updateStatusFromApprovedToReimbursed(newTravelFund.Id);
		Test.stopTest();
	}
}