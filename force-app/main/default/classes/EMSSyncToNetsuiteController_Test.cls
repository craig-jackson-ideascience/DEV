/**
 * Test class for EMSSyncToNetSuiteController
 *
 */
@IsTest
public class EMSSyncToNetsuiteController_Test{
	@TestSetup
	static void testSetup(){

		/* endpoint */
		List<Endpoints__c> listOfEndPoints = new List<Endpoints__c>();
		Endpoints__c endPoint = new Endpoints__c();
		endPoint.Name = 'For Other than Membership Asset';
		endPoint.Endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=40&deploy=1';
		endPoint.Password__c = 'jYdpn8sp22F8C45b';
		endPoint.User_Id__c = 'nsapi@linuxfoundation.org';
		endPoint.Nlauth_Account__c = '4010327_SB1';
		listOfEndPoints.add(endPoint);

		Endpoints__c endPoint2 = new Endpoints__c();
		endPoint2.Name = 'For Product Details';
		endPoint2.Endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=41&deploy=1';
		endPoint2.Password__c = 'jYdpn8sp22F8C45b';
		endPoint2.User_Id__c = 'nsapi@linuxfoundation.org';
		endPoint2.Nlauth_Account__c = '4010327_SB1';
		listOfEndPoints.add(endPoint2);

		insert listOfEndPoints;

		/* account */
		Account account = new Account();
		account.Name = 'Test Account';
		insert account;

		/* contact */
		Contact contact = new Contact();
		contact.AccountId = account.Id;
		contact.LastName = 'Test Contact';
		contact.Email = 'testContact@noReply.com';
		insert contact;

		/* project */
		Project__c parentProject = new Project__c();
		parentProject.Name = 'Parent Project';
		parentProject.Slug__c = 'test_parent_slug';
		insert parentProject;

		Project__c project = new Project__c();
		project.Name = 'The Linux Foundation';
		project.Category__c = 'Separately Incorporated';
		project.Project_Status__c = 'Active';
		project.Status__c = 'Active';
		project.Funding__c = 'Funded';
		project.Slug__c = 'test_slug';
		project.Project_Entity_Name__c = 'test formal name';
		project.Start_Date__c = Date.today();
		project.Industry__c = 'Automotive';
		project.Parent_Entity_Relationship__c = parentProject.Id;
		project.Parent_Project__c = parentProject.Id;
		project.Model__c = 'Membership';
		project.Technology__c = 'Storage';
		project.Technical_Activity_Type__c = 'Open Data';
		insert project;

		/* event */
		Event__c event = new Event__c();
		event.Name = 'Test event';
		event.BillFromProject__c = project.Id;
		event.Category__c = 'LF Event';
		insert event;

		/* ems */
		EMS__c ems = new EMS__c();
		ems.Name = 'Test Hotel Commissions';
		ems.Amount__c = 123;
		ems.Bill_To_Account__c = account.Id;
		ems.Contact__c = contact.Id;
		ems.Description__c = 'Test Description';
		ems.StartDate__c = System.today();
		ems.Event__c = event.Id;
		ems.Bill_From__c = project.Id;
		insert ems;

		/* content version */
		ContentVersion objCV = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.pdf', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
		insert objCV;

		/* content document link */
		ContentVersion objContentVer = [SELECT id, ContentDocumentId
		                                FROM ContentVersion
		                                where Id = :objCV.Id];
		ContentDocumentLink newFileShare = new ContentDocumentLink();
		newFileShare.contentdocumentid = objContentVer.contentDocumentid;
		newFileShare.LinkedEntityId = ems.Id;
		newFileShare.ShareType = 'V';
		insert newFileShare;
	}

	/**
	 * validateAccount_Test: this method is to validateAndSyncToNetSuite based on Bill To Account Id
	 */
	@IsTest
	static void validateAccount_Test(){
		EMS__c ems = [SELECT Id
		              FROM EMS__c
		              LIMIT 1];
		ems.Bill_To_Account__c = null;
		ems.Contact__c = null;
		update ems;

		String jsonWrapper = EMSSyncToNetSuiteController.validateAndSyncToNetSuite(ems.Id);
		Map<String, Object> emsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonWrapper);
		System.assertEquals(emsMap.get('message'), 'The Bill To Account field is not populated.', 'Message should be bill to account field is not populated');
	}

	/**
	 * validateDescription_Test: this method is to validateAndSyncToNetSuite for Description
	 */
	@IsTest
	static void validateDescription_Test(){
		EMS__c ems = [SELECT Id
		              FROM EMS__c
		              LIMIT 1];
		ems.Description__c = '';
		update ems;

		String jsonWrapper = EMSSyncToNetSuiteController.validateAndSyncToNetSuite(ems.Id);
		Map<String, Object> emsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonWrapper);
		System.assertEquals(emsMap.get('message'), 'The Description is not populated.', 'Message should be description field is not populated');
	}

	/**
	 * validateStartDate_Test: this method is to validateAndSyncToNetSuite for Start Date
	 */
	@IsTest
	static void validateStartDate_Test(){
		EMS__c ems = [SELECT Id
		              FROM EMS__c
		              LIMIT 1];
		ems.StartDate__c = null;
		update ems;
		String jsonWrapper = EMSSyncToNetSuiteController.validateAndSyncToNetSuite(ems.Id);
		Map<String, Object> emsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonWrapper);
		System.assertEquals(emsMap.get('message'), 'The Start Date is not populated.', 'Message should be start date is not populated');
	}

	/**
	 * validateFile_Test: this method is to validateAndSyncToNetSuite for Files
	 */
	@IsTest
	static void validateFile_Test(){
		Account account = [SELECT Id
		                   FROM Account
		                   LIMIT 1];
		Contact contact = [SELECT Id
		                   FROM Contact
		                   LIMIT 1];
		Event__c event = [SELECT Id
		                  FROM Event__c
		                  LIMIT 1];
		Project__c project = [SELECT Id
		                      FROM Project__c
		                      LIMIT 1];
		/* to check for null files */
		EMS__c ems = new EMS__c();
		ems.Name = 'Test Hotel Commissions';
		ems.Amount__c = 123;
		ems.Bill_To_Account__c = account.Id;
		ems.Contact__c = contact.Id;
		ems.Description__c = 'Test Description';
		ems.StartDate__c = System.today();
		ems.Event__c = event.Id;
		ems.Bill_From__c = project.Id;
		insert ems;

		Test.setMock(HttpCalloutMock.class, new NetSuiteToSalesforce_Mock());
		Test.startTest();
		String jsonWrapper = EMSSyncToNetSuiteController.validateAndSyncToNetSuite(ems.Id);
		Test.stopTest();
		Map<String, Object> emsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonWrapper);
		System.assertEquals(emsMap.get('message'), 'No files attached. Please upload the file.', 'Message should files are not attached');
	}

	/**
	 * validateAmount_Test: this method is to validateAndSyncToNetSuite for Amount
	 */
	@IsTest
	static void validateAmount_Test(){
		EMS__c ems = [SELECT Id
		              FROM EMS__c
		              LIMIT 1];
		ems.Amount__c = null;
		update ems;
		String jsonWrapper = EMSSyncToNetSuiteController.validateAndSyncToNetSuite(ems.Id);
		Map<String, Object> emsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonWrapper);
		System.assertEquals(emsMap.get('message'), 'The Amount is not populated.', 'Message should be amount is not populated');
	}

	/**
	 * validateSuccess_Test: this method is to validateAndSyncToNetSuite returns success
	 */
	@IsTest
	static void validateSuccess_Test(){
		EMS__c ems = [SELECT Id
		              FROM EMS__c
		              LIMIT 1];

		Test.setMock(HttpCalloutMock.class, new NetSuiteToSalesforce_Mock());
		Test.startTest();
		String jsonWrapper = EMSSyncToNetSuiteController.validateAndSyncToNetSuite(ems.Id);
		Test.stopTest();
		Map<String, Object> emsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonWrapper);
		System.assertEquals(true, emsMap.get('isSuccess'), 'It should be successful');
	}

	/**
	 * validateAlreadySynced_Test: this method is to validateAndSyncToNetSuite returns record already synced if sync to netsuite is true
	 */
	@IsTest
	static void validateAlreadySynced_Test(){
		EMS__c ems = [SELECT Id
		              FROM EMS__c
		              LIMIT 1];
		ems.Sync_to_Netsuite__c = true;
		update ems;
		Test.setMock(HttpCalloutMock.class, new NetSuiteToSalesforce_Mock());
		Test.startTest();
		String jsonWrapper = EMSSyncToNetSuiteController.validateAndSyncToNetSuite(ems.Id);
		Test.stopTest();
		Map<String, Object> emsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonWrapper);
		System.assertEquals(emsMap.get('message'), 'This record is already synced.', 'Message should be record is already synced');
	}
}