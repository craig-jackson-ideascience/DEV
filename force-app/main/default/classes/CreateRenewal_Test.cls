/**
 * Test class for CreateRenewal
 */
@isTest
public class CreateRenewal_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@TestSetup
	static void createTestData(){
		Endpoints__c endPoint = new Endpoints__c();
		endPoint.name = 'For Membership Details';
		endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=4';
		insert endPoint;

		Endpoints__c endPoint2 = new Endpoints__c();
		endPoint2.name = 'For Product Details';
		endPoint2.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=11';
		insert endPoint2;

		Id MyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Event').getRecordTypeId();

		List<Account> accList = new List<Account>();
		Account account = TestDataUtils.createAccount(false, 'Test Account1');
		account.billingCountry = 'brasil';
		account.billingStreet = 'new';
		accList.add(account);

		Account account1 = TestDataUtils.createAccount(false, 'Test Account1');
		account1.BillingCountry = 'brasil';
		account1.billingStreet = 'new';
		accList.add(account1);
		insert accList;

		Contact cont = new Contact(lastname = 'testCreateAsset1', email = 'AssetonClosedWo1n@gmail.com', accountid = account.id);
		insert cont;

		//Product
		Product2 product = TestDataUtils.createProduct(true, 'Laptop X2001', 'Test Product', true, 'Event');
		//PriceBookEntry
		PricebookEntry standardPriceEntry = TestDataUtils.createPriceBookEntryID(true, product.Id);

		Opportunity opportunity = new Opportunity();
		OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
		opportunity.recordTypeId = MyRecTypeId;
		opportunity.AccountId = account.Id;
		opportunity.Name = 'test111';
		opportunity.StageName = '2. Discovery';
		opportunity.Type = 'Existing Business';
		opportunity.CloseDate = date.today();
		opportunity.Bill_To_Account__c = account1.Id;
		insert opportunity;

		List<Project__c> projects = new List<Project__c>();
		projects.add(new Project__c(Name = 'testing111', Status__c = 'Planned', Category__c = 'Subproject', Subsidiary_ID__c = 8, Project_code__c = 'LF', Slug__c = 'testing'));
		projects.add(new Project__c(Name = 'The Linux Foundation', Status__c = 'Planned', Category__c = 'Directed Fund', Subsidiary_ID__c = 8, Slug__c = 'testing1', Model__c = 'Membership'));
		insert projects;

		projects[1].Status__c = 'Active';
		projects[1].Funding__c = 'Funded';
		update projects[1];

		Event__c event = new Event__c(Event_Name__c = 'KubeCon', Name = 'KubeCon',         // Event Name
		Status__c = 'Complete',                                                                                                                                                       // Event Status
		Category__c = 'LF Event',                                                                                                                                                     // Category
		BillFromProject__c = projects[1].id,      //ID                                                                                                                                  // Bill From Project
		Start_Date__c = system.today()-20,                                                                                                                                    // Event Start Date
		Capacity__c = 0,                                                                                                                                               // Event Start Time
		End_Date__c = system.today()-10,                                                                                                                                      // Event End Date
		Registration_Source__c = 'RegOnline',                                                                                                                                                // Event End Time
		Event_Location_Name__c = 'Twitter HQ One 10th Street Expansion',                                                                                                              // Event Location Name
		Event_Published__c = false,                                                                                                                                                   // Event Published
		Event_Location_Address__c = 'One 10th Street',                                                                                                                                // Event Location Address
		Event_Location_City__c = 'San Francisco',                                                                                                                                     // Event Location City
		Event_Location_State__c = 'California',                                                                                                                                       // Event Location State
		Event_Location_Country__c = 'United States',                                                                                                                                  // Event Location Country
		Event_Location_Zip__c = '94103',                                                                                                                                              // Event Location Zip
		Embassy__c = 'US',                                                                                                                                                            // Embassy
		Cvent_Event_Is_Sandbox__c = false,                                                                                                                                                  // NS Department
		Netsuite_Sync__c = false                                                                                                                                                // Netsuite Sync
		);
		insert event;

		Product_Details__c Pd = new Product_Details__c();
		Pd.Price__c = 56;
		//Pd.Subsidiary__c='The Linux Foundation';
		Pd.NS_Income_GL_Account__c = '290';
		pd.NS_Deferred_Revenue_Account__c = '284';
		pd.NS_Department__c = '10';
		pd.NS_Revenue_Schedule__c = '29';
		Pd.Netsuite_Sync__c = false;
		Pd.Duration__c = '45';
		Pd.Description__c = 'Description_Test';
		Pd.Tier__c = 'Test';
		pd.Netsuite_ID__c = '889955';
		//pd.Project__c=prj.id;
		pd.Event__c = event.id;
		pd.Products__c = product.id;
		insert Pd;

		opportunityLineItem.OpportunityId = opportunity.Id;
		opportunityLineItem.Quantity = 1;
		opportunityLineItem.UnitPrice = 2.00;
		opportunityLineItem.PricebookEntryId = standardPriceEntry.Id;
		opportunityLineItem.start_date__c = Date.newInstance(2016, 8, 1);
		opportunityLineItem.end_date__c = date.today().addDays(2);
		opportunityLineItem.Technical_Contact__c = cont.Id;
		opportunityLineItem.Representative_Voting_Contact__c = cont.Id;
		opportunityLineItem.Marketing_Contact__c = cont.Id;
		opportunityLineItem.Press_Contact__c = cont.Id;
		opportunityLineItem.Legal_Contact__c = cont.Id;
		opportunityLineItem.Billing_Contact__c = cont.Id;
		opportunityLineItem.billing_contact2__c = cont.Id;
		opportunityLineItem.billing_contact3__c = cont.Id;
		opportunityLineItem.Projects__c = projects[0].Id;
		opportunityLineItem.Product_Details__c = pd.id;
		opportunityLineItem.PO_Number__c = '8899774455';
		opportunityLineItem.Skip_NetSuite_Sync__c = FALSE;
		opportunityLineItem.Event__c = event.Id;
		insert opportunityLineItem;


		OpportunityContactRole ocrs = new OpportunityContactRole(opportunityid = opportunity.id, contactid = cont.id, role = 'Membership Decision Maker', IsPrimary = True);
		insert ocrs;

		dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Sent', dsfs__Opportunity__c = opportunity.id);
		insert ds;

		Account_And_Project__c accProObj = new Account_And_Project__c();
		accProObj.Account__c = account.id;
		accProObj.Project__c = projects[0].id;
		accProObj.Subsidiary_ID__c = '8';
		insert accProObj;
		Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());

		Asset asset = new Asset();
		asset.Opportunity__c = opportunity.Id;
		asset.Name = 'Test Asset';
		asset.AccountId = account.ID;
		asset.Projects__c = projects[0].id;
		asset.Status = 'Active';
		asset.UsageEndDate = date.today().addDays(30);
		asset.OpportunityLineItem__c = opportunityLineItem.Id;
		insert asset;

		//Project Roles
		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c billingRole = TestDataUtils.createProjectRole(false, cont.id, 'Billing cont', opportunity.Id, opportunitylineitem.Id, asset.Id, true);
		projectRoles.add(billingRole);

		Project_Role__c votingRole = TestDataUtils.createProjectRole(false, cont.id, 'Representative/Voting Contact', opportunity.Id, opportunitylineitem.Id, asset.Id, true);
		projectRoles.add(votingRole);
		insert projectRoles;
	}

	/**
	 * batch_Test :Test Method for  executeBatchForAutoRenewal for creation of renewal
	 */
	@isTest
	static void batch_Test(){
		Opportunity opportunity = [SELECT Id
		                           FROM Opportunity
		                           LIMIT 1];
		Asset asset = [SELECT Id
		               FROM Asset
		               LIMIT 1];
		String jsonBody = AssetToSalesOrderHelper.createJSONFromOtherThanMemeberShipAsset(asset.Id, opportunity.Id, new map<id, Opportunity>());

		//Test
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
		CreateRenewal.executeBatchForAutoRenewal(asset.id);
		Test.stopTest();
		List<Opportunity> renewalOpportunity = [SELECT Id, Parent_Asset__r.Renewal_Opportunity_Created__c
		                                        FROM Opportunity
		                                        WHERE Parent_Asset__c = :asset.Id];

		//Asserts
		System.assertNotEquals(null, renewalOpportunity[0].Id);
		System.assertEquals(true, renewalOpportunity[0].Parent_Asset__r.Renewal_Opportunity_Created__c);
	}
}