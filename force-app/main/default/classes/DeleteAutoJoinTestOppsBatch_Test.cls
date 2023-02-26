/*
 Test Class of AutoCloseRenewalsBatch Class
 */
@isTest
public class DeleteAutoJoinTestOppsBatch_Test{
	@testsetup
	public static void setupData(){
		Account a = new account();
		a.name = 'Test';
		a.billingCountry = 'brasil';
		a.billingStreet = 'new';
		insert a;

		Contact con = new Contact(lastname = 'testContact', email = 'testcontactno@gmail.com', accountid = a.id);
		insert con;

		String baseUrl = string.valueof(System.URL.getSalesforceBaseUrl());
		ID priceBookID = Test.getStandardPricebookId();

		Product2 prod = new Product2();
		prod.Name = 'test';
		prod.Family = 'Membership';
		prod.IsActive = true;
		insert prod;

		PricebookEntry standardPrice = new PricebookEntry();
		standardPrice.Product2Id = prod.id;
		standardPrice.UnitPrice = 234;
		standardPrice.IsActive = true;
		standardPrice.Pricebook2Id = pricebookId;
		insert standardPrice;

		Opportunity o = new Opportunity();
		OpportunityLineItem ol = new OpportunityLineItem();

		o.AccountId = a.Id;
		o.Name = 'Test - Join Now Opportunity';
		o.Type = 'New Business';
		o.StageName = '2. Discovery';
		o.CloseDate = date.today();
		o.Bill_To_Account__c = a.Id;
		o.Hold__c = false;
		insert o;

		Project__c prj = new Project__c(Name = 'testing11', Do_not_Invoice__c = true, Status__c = 'Planned', Category__c = 'Subproject', Subsidiary_ID__c = 8, Project_code__c = 'LF', Slug__c = 'testing');
		insert prj;

		Product_Details__c Pd = new Product_Details__c();
		Pd.Price__c = 56;
		Pd.NS_Income_GL_Account__c = '290';
		pd.NS_Deferred_Revenue_Account__c = '284';
		pd.NS_Department__c = '10';
		pd.NS_Revenue_Schedule__c = '29';
		Pd.Netsuite_Sync__c = false;
		Pd.Duration__c = '45';
		Pd.Description__c = 'Description_Test';
		Pd.Tier__c = 'Test';
		pd.Netsuite_ID__c = '889955';
		pd.Project__c = prj.id;
		pd.Products__c = prod.id;
		insert Pd;


		ol.OpportunityId = o.Id;
		ol.Quantity = 1;
		ol.UnitPrice = 2.00;
		ol.PricebookEntryId = standardPrice.Id;
		ol.start_date__c = Date.newInstance(2016, 8, 1);
		ol.end_date__c = date.today().addDays(2);
		ol.Technical_Contact__c = con.Id;
		ol.Representative_Voting_Contact__c = con.Id;
		ol.Marketing_Contact__c = con.Id;
		ol.Authorized_Signatory__c = con.Id;
		ol.Press_Contact__c = con.Id;
		ol.Legal_Contact__c = con.Id;
		ol.Sponsorship_Contact__c = con.Id;
		ol.Billing_Contact__c = con.Id;
		ol.billing_contact2__c = con.Id;
		ol.billing_contact3__c = con.Id;
		ol.Projects__c = prj.Id;
		ol.Product_Details__c = pd.id;
		ol.PO_Number__c = '8899774455';
		insert ol;

		OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = o.id, contactid = con.id, role = 'Membership Decision Maker', IsPrimary = True);
		insert ocr;

		dsfs__DocuSign_Status__c ds1 = new dsfs__DocuSign_Status__c();
		ds1.dsfs__Opportunity__c = o.Id;
		insert ds1;

		Asset a1 = new Asset();
		a1.Name = 'test asset';
		a1.Status = 'Purchased';
		a1.Opportunity__c = o.Id;
		a1.AccountId = a.Id;
		insert a1;

		Project_Role__c P1 = new Project_Role__c();
		P1.Account__c = a.ID;
		P1.Contact__c = con.Id;
		P1.Role__c = 'Billing Contact';
		P1.Status__c = 'Active';
		P1.Opportunity__c = o.Id;
		P1.Opportunity_Line_Item__c = ol.Id;
		insert P1;

		Project_Role__c P2 = new Project_Role__c();
		P2.Account__c = a.ID;
		P2.Contact__c = con.Id;
		P2.Role__c = 'Technical Contact';
		P2.Status__c = 'Active';
		P2.Asset__c = a1.Id;
		insert P2;
	}

	@isTest
	public static void testBehaviour1(){
		Test.startTest();
		Database.executeBatch(new DeleteAutoJoinTestOppsBatch(), 1);
		Test.stopTest();
	}

	@isTest
	public static void testBehaviour2(){
		Test.startTest();
		String jobId = System.schedule('ScheduledApexTest', '0 0 0 15 3 ? 2022', new DeleteAutoJoinTestOppsBatch());
		Test.stopTest();
	}
}