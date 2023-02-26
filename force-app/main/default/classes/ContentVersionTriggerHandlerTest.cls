@IsTest
private class ContentVersionTriggerHandlerTest{
	@TestSetup
	static void testSetup(){
		Account acc = TestFactory.getAccount();
		List<Opportunity> listOfOpp = new List<Opportunity>();
		Project__c objProject = new Project__c();
		objProject.Name = 'New Test Project 12';
		objProject.Status__c = 'Planned';
		objProject.Type__c = 'Membership';
		objProject.Manual_Status_Check__c = false;
		objProject.Category__c = 'Incorporated Entity';
        objProject.Slug__c = 'newtest';
		insert objProject;
		for (Integer i = 0; i <= 5; i++){
			Opportunity oppty = new Opportunity();
			oppty.Name = 'Test Opportunity';
			oppty.AccountId = acc.id;
			oppty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
			oppty.StageName = '2. Discovery';
			oppty.CloseDate = System.today();
			oppty.Type = 'Renewal';
			oppty.Project_Name__c = objProject.Id;
			listOfOpp.add(oppty);
		}
		insert listOfOpp;
	}

	@IsTest
	static void insertTest(){
		List<Opportunity> listOfOpp = [SELECT Id
		                               FROM Opportunity];
		ContentVersion contVer = new Contentversion();
		contVer.title = 'TestFullyexecuted';
		contVer.PathOnClient = 'test';
		contVer.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
		contVer.FirstPublishLocationId = listOfOpp[0].Id;
		insert contVer;
		List<ContentVersion> listOfVer = new List<ContentVersion>();
		for (Integer i = 0; i <= 5; i++){
			ContentVersion cv = new Contentversion();
			cv.title = 'Testfullyexecuted'+i;
			cv.PathOnClient = 'test';
			cv.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
			cv.FirstPublishLocationId = listOfOpp[i].Id;
			cv.Status__c = 'Active';
			listOfVer.add(cv);
		}
		insert listOfVer;
		System.assertEquals(1, [SELECT count()
		                        FROM ContentVersion
		                        WHERE Status__c = 'Expired']);
	}
}