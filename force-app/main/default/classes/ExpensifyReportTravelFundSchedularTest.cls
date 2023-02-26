@isTest
public class ExpensifyReportTravelFundSchedularTest{
	@isTest
	static void expensifyRecReqCon_Test1(){

		Test.setMock(HttpCalloutMock.class, new ExpensifyCalloutMockTest());

		Contact conRecord = new Contact();
		conRecord.LastName = 'Linux';
		conRecord.Email = 'test@linuxfoundation.org';
		insert conRecord;

		Project__c project = new Project__c(Name = 'The Linux Foundation', Category__c = 'Directed Fund', Slug__c = 'testing', Model__c = 'Membership');
		insert project;

        project.Status__c = 'Active';
		project.Funding__c = 'Funded';
		update project;

		Event__c evtRecord = new Event__c();
		evtRecord.Name = 'My New Event';
		evtRecord.Expensify_Policy_ID__c = '554237F4AB23B96D';
		evtRecord.Accept_Travel_Fund__c = 'Yes';
        evtRecord.BillFromProject__c = project.Id;
		insert evtRecord;

		Travel_Fund_Request__c newTravelFund = new Travel_Fund_Request__c();
		newTravelFund.Name = 'New Travel Fund';
		newTravelFund.Status__c = 'Expense Report Approved';
		newTravelFund.Event__c = evtRecord.Id;
		newTravelFund.Contact__c = conRecord.Id;
		newTravelFund.Expensify_Report_Name__c = '56456';
		newTravelFund.TFREmail__c = 'test@linuxfoundation.org';
		newTravelFund.Expensify_Approved_Amount__c = 35456;
		insert newTravelFund;

		Expensify_Attachment__c expenAttach = new Expensify_Attachment__c();
		expenAttach.Report_Id__c = '53845065';
		expenAttach.URL__c = 'https://s3.amazonaws.com/receipts.expensify.com/w_b7e63c97f448ea5e8f2b1d12e42d3dd3eab42370.pdf';
		expenAttach.Travel_Fund_Request__c = newTravelFund.Id;
		insert expenAttach;

		Test.startTest();

		//ExpensifyReportTravelFundSchedular.fetchReportNames();
		ExpensifyReportTravelFundSchedular.ExpenseReceipt wrapperExpenseReceipt = new ExpensifyReportTravelFundSchedular.ExpenseReceipt();
		RecursiveTriggerHandler.isFirstTime = false;

		ExpensifyReportSchedular trvlFundScheduleBatch = new ExpensifyReportSchedular();
		String sch = '0 0 23 * * ?';
		system.schedule('Test TravelFund Request', sch, trvlFundScheduleBatch);

		Test.stopTest();
	}
}