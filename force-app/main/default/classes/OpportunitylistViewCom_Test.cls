/**
 * Test class for OpportunitylistViewCom
 */
@isTest
public class OpportunitylistViewCom_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@testSetup
	static void createTestData(){
		Account account = TestDataUtils.createAccount(false, 'Test Account');
		account.website = 'testaccount.com';
		insert account;

		Project__c project = TestDataUtils.createProject(true, 'Test Project', 'Membership', 'Directed Fund', 'Planned');

		Opportunity opportunity = TestDataUtils.createOpenOpportunity(true, account.id, 'Opportunity testing 1', '2. Discovery');

		//Product
		Product2 product = TestDataUtils.createProduct(true, 'Laptop X2001', 'Test Product', true, 'Membership');

		//PricebookEntry
		PricebookEntry standardPbe = TestDataUtils.createPriceBookEntryID(true, product.id);

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opportunity.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = standardPbe.ID, Required_Active_LF_Membership__c = true, Projects__c = project.id);
		insert oli;

		attachment attachment = new attachment();
		attachment.ParentId = opportunity.Id;
		attachment.Name = 'testattach';
		attachment.Body = EncodingUtil.base64Decode('AA==');
		insert attachment;

		//OpportunityLineItem
		OpportunityLineItem oppLineItem = TestDataUtils.createOpportunityProduct(false, opportunity.id, standardPbe.id);
		oppLineItem.Projects__c = project.Id;


		//Create Document
		ContentVersion contVersion = new ContentVersion();
		contVersion.Title = 'Test Document';
		contVersion.PathOnClient = 'TestDocument.pdf';
		contVersion.VersionData = Blob.valueOf('Test Content');
		contVersion.IsMajorVersion = true;
		insert contVersion;

		//Get Content Documents
		Id contentDocumentId = [SELECT ContentDocumentId
		                        FROM ContentVersion
		                        WHERE Id = :contVersion.Id].ContentDocumentId;

		//Create ContentDocumentLink
		ContentDocumentLink contentDocument = New ContentDocumentLink();
		contentDocument.LinkedEntityId = opportunity.Id;
		contentDocument.ContentDocumentId = contentDocumentId;
		contentDocument.shareType = 'V';
		insert contentDocument;
	}

	/**
	 * getOpportunityLineItem_Test : Test Method for getOpportunityLineItem to Retro=ieve LineItem Of a particular Account
	 */
	@isTest
	static void getOpportunityLineItem_Test(){
		Account account = [SELECT Id
		                   FROM Account
		                   LIMIT 1];
		Test.startTest();
		List<OpportunityLineItem> oppLineItemList = OpportunitylistViewCom.getOpportunityLineItem(account.Id, 'Name', true);

		//Asserts
		System.assertEquals(1, oppLineItemList.size(),'1 opportunity record must be returned');
		Test.stopTest();
	}

	/**
	 * fetchopportunity_Test : Test Method for fetchopportunity for one opportunity
	 */
	@isTest
	static void fetchopportunityDocumentForSameOpp_Test(){
		Account account = [SELECT Id
		                   FROM Account
		                   LIMIT 1];
		Test.startTest();
		List<OpportunitylistViewCom.AttachmentWrapper> attachmentWrapperList = OpportunitylistViewCom.fetchopportunity(account.Id, 'Membership');

		//Asserts
		System.assertEquals(true, !attachmentWrapperList.isEmpty(),'List must not be empty');
		Test.stopTest();
	}

	/**
	 * fetchopportunity_Test : Test Method for fetchopportunity for different opportunity
	 */
	@isTest
	static void fetchopportunityDocumentForDiffOpp_Test(){
		Account account = [SELECT Id
		                   FROM Account
		                   LIMIT 1];
		Test.startTest();

		Opportunity opportunity = TestDataUtils.createOpenOpportunity(true, account.id, 'Opportunity testing 2', '2. Discovery');
		//Create Document
		ContentVersion contVersion = new ContentVersion();
		contVersion.Title = 'Test Document';
		contVersion.PathOnClient = 'TestDocument.pdf';
		contVersion.VersionData = Blob.valueOf('Test Content');
		contVersion.IsMajorVersion = true;
		insert contVersion;

		//Get Content Documents
		Id contentDocumentId = [SELECT ContentDocumentId
		                        FROM ContentVersion
		                        WHERE Id = :contVersion.Id].ContentDocumentId;

		//Create ContentDocumentLink
		ContentDocumentLink contentDocument = New ContentDocumentLink();
		contentDocument.LinkedEntityId = opportunity.Id;
		contentDocument.ContentDocumentId = contentDocumentId;
		contentDocument.shareType = 'V';
		insert contentDocument;


		List<OpportunitylistViewCom.AttachmentWrapper> attachmentWrapperList = OpportunitylistViewCom.fetchopportunity(account.Id, 'Membership');

		//Asserts
		System.assertEquals(true, !attachmentWrapperList.isEmpty(),'List must not be empty');
		Test.stopTest();
	}

	/**
	 * fetchopportunity_Test : Test Method for fetchopportunity for one join now opportunity
	 */
	@isTest
	static void fetchopportunityDocumentForJoinNowOpp_Test(){
		Account account = [SELECT Id
		                   FROM Account
		                   LIMIT 1];
		Opportunity opportunity = [SELECT Id
		                           FROM Opportunity
		                           LIMIT 1];
		opportunity.JoinNow_Update__c = system.today();
		update opportunity;
		Test.startTest();
		List<OpportunitylistViewCom.AttachmentWrapper> attachmentWrapperList = OpportunitylistViewCom.fetchopportunity(account.Id, 'Membership');

		//Asserts
		System.assertEquals(true, !attachmentWrapperList.isEmpty(),'List must not be empty');
		Test.stopTest();
	}

	/**
	 * fetchopportunity_Test : Test Method for fetchopportunity for different join now opportunity
	 */
	@isTest
	static void fetchopportunityDocumentForDiffJoinNowOpp_Test(){
		Account account = [SELECT Id
		                   FROM Account
		                   LIMIT 1];
		Test.startTest();

		Opportunity opportunity = TestDataUtils.createOpenOpportunity(true, account.id, 'Opportunity testing 2', '2. Discovery');
		opportunity.JoinNow_Update__c = system.today();
		update opportunity;
		//Create Document
		ContentVersion contVersion = new ContentVersion();
		contVersion.Title = 'Test Document';
		contVersion.PathOnClient = 'TestDocument.pdf';
		contVersion.VersionData = Blob.valueOf('Test Content');
		contVersion.IsMajorVersion = true;
		insert contVersion;

		//Get Content Documents
		Id contentDocumentId = [SELECT ContentDocumentId
		                        FROM ContentVersion
		                        WHERE Id = :contVersion.Id].ContentDocumentId;

		//Create ContentDocumentLink
		ContentDocumentLink contentDocument = New ContentDocumentLink();
		contentDocument.LinkedEntityId = opportunity.Id;
		contentDocument.ContentDocumentId = contentDocumentId;
		contentDocument.shareType = 'V';
		insert contentDocument;


		List<OpportunitylistViewCom.AttachmentWrapper> attachmentWrapperList = OpportunitylistViewCom.fetchopportunity(account.Id, 'Membership');

		//Asserts
		System.assertEquals(true, !attachmentWrapperList.isEmpty(),'List must not be empty');
		Test.stopTest();
	}

	/**
	 * getRecordTypeList_Test : Test Method for getRecordTypeList - FOr retrieving recordtypes of opportunity
	 */
	@isTest
	static void getRecordTypeList_Test(){
		Test.startTest();
		List<RecordType> recordtypeList = OpportunitylistViewCom.getRecordTypeList();

		//Asserts
		System.assertEquals(true, !recordtypeList.isEmpty(),'List must not be empty');
		Test.stopTest();
	}
}