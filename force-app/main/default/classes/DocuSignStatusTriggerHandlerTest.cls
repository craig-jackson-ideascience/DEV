/**
 * Created by CloudRoute on 27-05-2020.
 *Test Class of DocuSignStatusTriggerHandler Class
 */
@IsTest
private class DocuSignStatusTriggerHandlerTest{
	/**
	 * TestSetup inserting required data for test class
	 */
	@TestSetup
	static void createTestData(){
		List<Endpoints__c> endPoinList = new List<Endpoints__c>();
		Endpoints__c endPoint = new Endpoints__c();
		endPoint.name = 'For Membership Asset';
		endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=90&deploy=4';
		endPoinList.add(endPoint);

		Endpoints__c endPoint2 = new Endpoints__c();
		endPoint2.name = 'For Product Details';
		endPoint2.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=11';
		endPoinList.add(endPoint2);
		insert endPoinList;

		//Account
		Account account = TestDataUtils.createAccount(false, 'Test Account');
		account.billingCountry = 'brasil';
		account.billingStreet = 'new';
		insert account;

		//Contact
		Contact contact = new Contact(lastname = 'testContact', email = 'testcontactno@gmail.com', accountid = account.id);
		insert contact;

		//Product
		Product2 prod = TestDataUtils.createProduct(true, 'Laptop X2001', 'Test Product', true, 'Membership');
		//PriceBookEntry
		PricebookEntry standardPrice = TestDataUtils.createPriceBookEntryID(true, prod.Id);
	}

	@isTest
	public static void testBehaviour(){
		Account account = [SELECT Id
		                   FROM Account
		                   LIMIT 1];

		Contact contact = [SELECT Id, Name
		                   FROM COntact
		                   LIMIT 1];
		Product2 product = [SELECT Id
		                    FROM Product2
		                    WHERE Family = 'Membership'
		                    LIMIT 1];

		PricebookEntry standardPrice = [SELECT Id
		                                FROM PricebookEntry
		                                WHERE Product2Id = :product.Id];


		Project__c prj = new Project__c(Name = 'testing11', Notifications_Group__c = 'test@test.com', Status__c = 'Planned', Category__c = 'Directed Fund', Subsidiary_ID__c = 8, Project_code__c = 'LF', Slug__c = 'testing');
		insert prj;

		Opportunity opportunity = new Opportunity();
		OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
		opportunity.AccountId = account.Id;
		opportunity.Name = 'test';
		opportunity.StageName = '2. Discovery';
		opportunity.Type = 'New Business';
		opportunity.CloseDate = date.today();
		opportunity.Bill_To_Account__c = account.Id;
		opportunity.Project_Name__c = prj.ID;
		opportunity.Billing_Contact__c = contact.ID;
		insert opportunity;

		OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = opportunity.id, contactid = contact.id, role = 'Membership Decision Maker', IsPrimary = True);
		insert ocr;

		opportunity.StageName = '3. Joint Opportunity Development';
		update opportunity;
		opportunity.StageName = '4. Solution Development';
		update opportunity;
		opportunity.StageName = '5. Decision Commitment';
		update opportunity;


		Product_Details__c prodDetail = new Product_Details__c();
		prodDetail.Price__c = 56;
		prodDetail.NS_Income_GL_Account__c = '290';
		prodDetail.NS_Deferred_Revenue_Account__c = '284';
		prodDetail.NS_Department__c = '10';
		prodDetail.NS_Revenue_Schedule__c = '29';
		prodDetail.Netsuite_Sync__c = false;
		prodDetail.Duration__c = '45';
		prodDetail.Description__c = 'Description_Test';
		prodDetail.Tier__c = 'Test';
		prodDetail.Netsuite_ID__c = '889955';
		prodDetail.Project__c = prj.id;
		prodDetail.Products__c = product.id;
		insert prodDetail;

		opportunityLineItem.OpportunityId = opportunity.Id;
		opportunityLineItem.Quantity = 1;
		opportunityLineItem.UnitPrice = 2.00;
		opportunityLineItem.PricebookEntryId = standardPrice.Id;
		opportunityLineItem.start_date__c = Date.newInstance(2016, 8, 1);
		opportunityLineItem.end_date__c = date.today().addDays(2);
		opportunityLineItem.Projects__c = prj.Id;
		opportunityLineItem.Product_Details__c = prodDetail.id;
		opportunityLineItem.Membership_Voting_Contact_Roles__c = 'True';
		opportunityLineItem.PO_Number__c = '8899774455';
		insert opportunityLineItem;

		//Project Roles
		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c billingRole = TestDataUtils.createProjectRole(false, contact.id, 'Billing Contact', opportunity.Id, opportunitylineitem.Id, null, true);
		projectRoles.add(billingRole);

		Project_Role__c votingRole = TestDataUtils.createProjectRole(false, contact.id, 'Representative/Voting Contact', opportunity.Id, opportunitylineitem.Id, null, true);
		projectRoles.add(votingRole);

		Project_Role__c marketingRole = TestDataUtils.createProjectRole(false, contact.id, 'Marketing Contact', opportunity.Id, opportunitylineitem.Id, null, true);
		projectRoles.add(marketingRole);
		insert projectRoles;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
		dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Sent', dsfs__Opportunity__c = opportunity.id);
		insert ds;

		system.debug('Docusign Signatory Status: ' + ds.Signatory_Status__c);
		Opportunity testOpp1 = [Select id, ApplicationStatus__c
		                        from Opportunity
		                        where id = :opportunity.id];
		system.assertEquals('Waiting for Customer Signature', testOpp1.ApplicationStatus__c, 'Application status must be \'Waiting for Customer Signature \'');

		ds.Signatory_Status__c = 'John Signed';
		update ds;

		Opportunity testOpp2 = [Select id, ApplicationStatus__c
		                        from Opportunity
		                        where id = :opportunity.id];
		system.assertEquals('Waiting for Customer Signature', testOpp2.ApplicationStatus__c, 'Application status must be \'Waiting for Customer Signature\'');

		ds.Signatory_Status__c = 'Joseph Signed';
		update ds;

		Opportunity testOpp3 = [Select id, ApplicationStatus__c
		                        from Opportunity
		                        where id = :opportunity.id];
		system.assertEquals('Waiting for Linux Foundation Signature', testOpp3.ApplicationStatus__c, 'Application status must be \'Waiting for Linux Foundation Signature \'');

		ds.dsfs__Envelope_Status__c = 'Voided';
		update ds;

		Opportunity testOpp4 = [Select id, ApplicationStatus__c
		                        from Opportunity
		                        where id = :opportunity.id];
		system.assertEquals('Application Received', testOpp4.ApplicationStatus__c, 'Application status must be \'Application Received \'');


		ds.dsfs__Envelope_Status__c = 'Completed';
		update ds;

		DocuSignStatusTriggerHandler.getClassicEmail('Test', 'Test', new List<String>{'Test@Test.com'}, Utility.getOrgWideEmailAddress());

		Test.stopTest();
		System.assertEquals('Closed Won', [Select Id, StageName
		                                   From Opportunity
		                                   Where Id = :ds.dsfs__Opportunity__c][0].Stagename, 'Stage must be CLosed Won');
	}

	@isTest
	public static void testBehaviour1(){
		Account account = [SELECT Id
		                   FROM Account
		                   LIMIT 1];

		Contact contact = [SELECT Id, Name
		                   FROM COntact
		                   LIMIT 1];
		Product2 product = [SELECT Id
		                    FROM Product2
		                    WHERE Family = 'Membership'
		                    LIMIT 1];

		PricebookEntry standardPrice = [SELECT Id
		                                FROM PricebookEntry
		                                WHERE Product2Id = :product.Id];


		Project__c prj = new Project__c(Name = 'testing11', Notifications_Group__c = 'test@test.com', Status__c = 'Planned', Category__c = 'Directed Fund', Subsidiary_ID__c = 8, Project_code__c = 'LF', Slug__c = 'testing');
		insert prj;

		Opportunity opportunity = new Opportunity();
		OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
		opportunity.AccountId = account.Id;
		opportunity.Name = 'test';
		opportunity.StageName = '2. Discovery';
		opportunity.Type = 'New Business';
		opportunity.CloseDate = date.today();
		opportunity.Bill_To_Account__c = account.Id;
		opportunity.Project_Name__c = prj.ID;
		opportunity.Billing_Contact__c = contact.ID;
		insert opportunity;

		OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = opportunity.id, contactid = contact.id, role = 'Membership Decision Maker', IsPrimary = True);
		insert ocr;

		opportunity.StageName = '3. Joint Opportunity Development';
		update opportunity;
		opportunity.StageName = '4. Solution Development';
		update opportunity;
		opportunity.StageName = '5. Decision Commitment';
		update opportunity;


		Product_Details__c prodDetail = new Product_Details__c();
		prodDetail.Price__c = 56;
		prodDetail.NS_Income_GL_Account__c = '290';
		prodDetail.NS_Deferred_Revenue_Account__c = '284';
		prodDetail.NS_Department__c = '10';
		prodDetail.NS_Revenue_Schedule__c = '29';
		prodDetail.Netsuite_Sync__c = false;
		prodDetail.Duration__c = '45';
		prodDetail.Description__c = 'Description_Test';
		prodDetail.Tier__c = 'Test';
		prodDetail.Netsuite_ID__c = '889955';
		prodDetail.Project__c = prj.id;
		prodDetail.Products__c = product.id;
		insert prodDetail;

		opportunityLineItem.OpportunityId = opportunity.Id;
		opportunityLineItem.Quantity = 1;
		opportunityLineItem.UnitPrice = 2.00;
		opportunityLineItem.PricebookEntryId = standardPrice.Id;
		opportunityLineItem.start_date__c = Date.newInstance(2016, 8, 1);
		opportunityLineItem.end_date__c = date.today().addDays(2);
		opportunityLineItem.Projects__c = prj.Id;
		opportunityLineItem.Product_Details__c = prodDetail.id;
		opportunityLineItem.Membership_Voting_Contact_Roles__c = 'True';
		opportunityLineItem.PO_Number__c = '8899774455';
		insert opportunityLineItem;

		//Project Roles
		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c billingRole = TestDataUtils.createProjectRole(false, contact.id, 'Billing Contact', opportunity.Id, opportunitylineitem.Id, null, true);
		projectRoles.add(billingRole);

		Project_Role__c votingRole = TestDataUtils.createProjectRole(false, contact.id, 'Representative/Voting Contact', opportunity.Id, opportunitylineitem.Id, null, true);
		projectRoles.add(votingRole);

		Project_Role__c marketingRole = TestDataUtils.createProjectRole(false, contact.id, 'Marketing Contact', opportunity.Id, opportunitylineitem.Id, null, true);
		projectRoles.add(marketingRole);
		insert projectRoles;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
		dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Sent', dsfs__Opportunity__c = opportunity.id);
		insert ds;

		system.debug('Docusign Signatory Status: ' + ds.Signatory_Status__c);
		Opportunity testOpp1 = [Select id, ApplicationStatus__c
		                        from Opportunity
		                        where id = :opportunity.id];
		system.assertEquals('Waiting for Customer Signature', testOpp1.ApplicationStatus__c, 'Application status must be \'Waiting for Customer Signature\'');

		ds.Signatory_Status__c = 'John Signed';
		update ds;

		Opportunity testOpp2 = [Select id, ApplicationStatus__c
		                        from Opportunity
		                        where id = :opportunity.id];
		system.assertEquals('Waiting for Customer Signature', testOpp2.ApplicationStatus__c, 'Application status must be \'Waiting for Customer Signature\'');

		ds.Signatory_Status__c = 'Joseph Signed';
		update ds;

		Opportunity testOpp3 = [Select id, ApplicationStatus__c
		                        from Opportunity
		                        where id = :opportunity.id];
		system.assertEquals('Waiting for Linux Foundation Signature', testOpp3.ApplicationStatus__c, 'Application status must be \'Waiting for Linux Foundation Signature \'');

		ds.dsfs__Envelope_Status__c = 'Voided';
		update ds;

		Opportunity testOpp4 = [Select id, ApplicationStatus__c
		                        from Opportunity
		                        where id = :opportunity.id];
		system.assertEquals('Application Received', testOpp4.ApplicationStatus__c, 'Application status must be \'Application Received \'');


		ds.dsfs__Declined_Reason__c = 'Test Declined';
		ds.Signatory_Status__c = contact.Name;
		ds.dsfs__Envelope_Status__c = 'Declined';
		update ds;

		Opportunity testOpp5 = [Select id, ApplicationStatus__c
		                        from Opportunity
		                        where id = :opportunity.id];
		system.assertEquals('Application Received', testOpp5.ApplicationStatus__c, 'Application status must be \'Application Received \'');

		Test.stopTest();
	}

	@isTest
	//Test Case for Individual Membership
	public static void testBehaviour2(){

		Account account = [SELECT Id
		                   FROM Account
		                   LIMIT 1];

		Contact contact = [SELECT Id
		                   FROM COntact
		                   LIMIT 1];
		Product2 product = [SELECT Id
		                    FROM Product2
		                    WHERE Family = 'Membership'
		                    LIMIT 1];

		PricebookEntry standardPrice = [SELECT Id
		                                FROM PricebookEntry
		                                WHERE Product2Id = :product.Id];


		Project__c prj = new Project__c(Name = 'testing11', Notifications_Group__c = 'test@test.com', Status__c = 'Planned', Category__c = 'Directed Fund', Subsidiary_ID__c = 8, Project_code__c = 'LF', Internal_Docusign_Complete_Individual__c = 'Internal_Docusign_Complete_Individual__c', Internal_Docusign_Voided_Notification__c = 'Internal_Docusign_Voided_Notification__c', Slug__c = 'testing');
		insert prj;

		Opportunity opportunity = new Opportunity();
		OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
		opportunity.AccountId = account.Id;
		opportunity.Name = 'test Individual Membership';
		opportunity.StageName = '2. Discovery';
		opportunity.Type = 'New Business';
		opportunity.CloseDate = date.today();
		opportunity.Bill_To_Account__c = account.Id;
		opportunity.Project_Name__c = prj.ID;
		opportunity.Billing_Contact__c = contact.ID;
		insert opportunity;

		OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = opportunity.id, contactid = contact.id, role = 'Membership Decision Maker', IsPrimary = True);
		insert ocr;

		opportunity.StageName = '3. Joint Opportunity Development';
		update opportunity;
		opportunity.StageName = '4. Solution Development';
		update opportunity;
		opportunity.StageName = '5. Decision Commitment';
		update opportunity;


		Product_Details__c prodDetail = new Product_Details__c();
		prodDetail.Price__c = 56;
		//prodDetail.Subsidiary__c='The Linux Foundation';
		prodDetail.NS_Income_GL_Account__c = '290';
		prodDetail.NS_Deferred_Revenue_Account__c = '284';
		prodDetail.NS_Department__c = '10';
		prodDetail.NS_Revenue_Schedule__c = '29';
		prodDetail.Netsuite_Sync__c = false;
		prodDetail.Duration__c = '45';
		prodDetail.Description__c = 'Description_Test';
		prodDetail.Tier__c = 'Test';
		prodDetail.Netsuite_ID__c = '889955';
		prodDetail.Project__c = prj.id;
		prodDetail.Products__c = product.id;
		insert prodDetail;
		opportunityLineItem.OpportunityId = opportunity.Id;
		opportunityLineItem.Quantity = 1;
		opportunityLineItem.UnitPrice = 2.00;
		opportunityLineItem.PricebookEntryId = standardPrice.Id;
		opportunityLineItem.start_date__c = Date.newInstance(2016, 8, 1);
		opportunityLineItem.end_date__c = date.today().addDays(2);
		opportunityLineItem.Technical_Contact__c = contact.Id;
		opportunityLineItem.Representative_Voting_Contact__c = contact.Id;
		opportunityLineItem.Marketing_Contact__c = contact.Id;
		opportunityLineItem.Authorized_Signatory__c = contact.Id;
		opportunityLineItem.Press_Contact__c = contact.Id;
		opportunityLineItem.Legal_Contact__c = contact.Id;
		opportunityLineItem.Sponsorship_Contact__c = contact.Id;
		opportunityLineItem.Billing_Contact__c = contact.Id;
		opportunityLineItem.billing_contact2__c = contact.Id;
		opportunityLineItem.billing_contact3__c = contact.Id;
		opportunityLineItem.Projects__c = prj.Id;
		opportunityLineItem.Product_Details__c = prodDetail.id;
		opportunityLineItem.Membership_Voting_Contact_Roles__c = 'True';
		opportunityLineItem.PO_Number__c = '8899774455';
		insert opportunityLineItem;

		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c objProjectRole = new Project_Role__c();
		objProjectRole.status__c = 'Active';
		objProjectRole.Contact__c = contact.id;
		objProjectRole.Role__c = 'Representative/Voting Contact';
		objProjectRole.PrimaryContact__c = true;
		objProjectRole.Opportunity__c = opportunity.Id;
		objProjectRole.Opportunity_Line_Item__c = opportunityLineItem.Id;
		projectRoles.add(objProjectRole);

		Project_Role__c objProjectRole1 = new Project_Role__c();
		objProjectRole1.status__c = 'Active';
		objProjectRole1.Contact__c = contact.id;
		objProjectRole1.Role__c = 'Billing Contact';
		objProjectRole1.PrimaryContact__c = true;
		objProjectRole1.Opportunity__c = opportunity.Id;
		objProjectRole1.Opportunity_Line_Item__c = opportunityLineItem.Id;
		projectRoles.add(objProjectRole1);

		Project_Role__c objProjectRole2 = new Project_Role__c();
		objProjectRole2.status__c = 'Active';
		objProjectRole2.Contact__c = contact.id;
		objProjectRole2.Role__c = 'Marketing Contact 5';
		objProjectRole2.Opportunity__c = opportunity.Id;
		objProjectRole2.Opportunity_Line_Item__c = opportunityLineItem.Id;
		projectRoles.add(objProjectRole2);

		insert projectRoles;


		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
		dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Sent', dsfs__Opportunity__c = opportunity.id);
		insert ds;

		ds.Signatory_Status__c = 'John Signed';
		update ds;

		ds.dsfs__Envelope_Status__c = 'Voided';
		update ds;

        ds.dsfs__Declined_Reason__c = 'Test Declined';
        ds.Signatory_Status__c = 'contact.Name';
        ds.dsfs__Envelope_Status__c = 'Declined';
        update ds;        
        

		ds.dsfs__Envelope_Status__c = 'Completed';
		update ds;

		Test.stopTest();
		System.assertEquals('Closed Won', [Select Id, StageName
		                                   From Opportunity
		                                   Where Id = :ds.dsfs__Opportunity__c][0].Stagename, 'Stage must be CLosed Won');
	}
}