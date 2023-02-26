@Istest
private class ViewMoreControllerTest{
	@TestSetup
	static void testSetup(){
		Project__c parentProject = new Project__c();
		parentProject.Name = 'Parent Project';
		parentProject.Slug__c = 'test_parent_slug';
		insert parentProject;

		Project__c proj = new Project__c(Name = 'testProject1', Project_Status__c = 'Active', Category__c = 'Subproject', Slug__c = 'testing', Project_Entity_Name__c = 'The Linux Foundation', Start_Date__c = System.today(), Funding__c = 'Funded', Model__c = 'Membership', Industry__c = 'Non-profit Organizations', Parent_Entity_Relationship__c = parentProject.Id, Parent_Project__c = parentProject.Id, Technology__c = 'Blockchain', Technical_Activity_Type__c = 'Open Data');
		insert proj;
	}

	@Istest
	static void getAccountReceivableTableDetailsTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c
		                   WHERE Name = 'testProject1'];
		List<Asset> listOfAsset = ViewMoreController.getAccountReceivableTableDetails(proj.Id, '[120]', false, 'equal', false);
		System.assertEquals(null, listOfAsset);
	}

	@IsTest
	static void getLeadTableDetailsTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c
		                   WHERE Name = 'testProject1'];
		List<String> selectedSource = new List<String>{'Event'};
		List<String> selectedDates = new List<String>();
		Chart_LeadSubmissionController.ReturnLeadWrapper result = ViewMoreController.getLeadTableDetails(proj.id, selectedSource, null, 'between', selectedDates, null, '', 'equal', false, false);
		System.assertEquals(0, result.leadWrapper.size());
	}

	@IsTest
	static void getSelectedProjectDetailsTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c
		                   WHERE Name = 'testProject1'];
		Project__c result = ViewMoreController.getSelectedProjectDetails(proj.Id);
		System.assertEquals(result.Id, proj.Id);
	}

	@IsTest
	static void getLeadDetailsTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c
		                   WHERE Name = 'testProject1'];
		List<String> selectedDates = new List<String>();
		List<String> selectedSource = new List<String>{'Event'};
		String result = ViewMoreController.getLeadDetails(proj.Id, selectedSource, '', 'between', selectedDates);
		System.assertNotEquals(null, result);
	}

	@IsTest
	static void getFilteredTableDataTest(){
		Project__c proj = [SELECT Id
		                   FROM Project__c
		                   WHERE Name = 'testProject1'];
		List<String> selectedDates = new List<String>();
		Chart_RevenueController.ReturnAssetWrapper result = ViewMoreController.getFilteredTableData(proj.Id, '', selectedDates, '', '', '', true, false);
		System.assertNotEquals(null, result);
	}

	@IsTest
	static void getPurchaseTypesTest(){
		List<String> result = ViewMoreController.getPurchaseTypes();
		System.assertEquals(5, result.size());
	}
}