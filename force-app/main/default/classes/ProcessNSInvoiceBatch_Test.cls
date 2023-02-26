/*
 Test Class of ProcessNSInvoiceBatch Class
 */
@isTest
public class ProcessNSInvoiceBatch_Test{
	//Create Test Data
	@testsetup
	public static void setupData(){

		Endpoints__c endPoint2 = new Endpoints__c();
		endPoint2.Name = 'For Invoice';
		endPoint2.Endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=70&deploy=2';
		endPoint2.Password__c = 'jYdpn8sp22F8C45b';
		endPoint2.User_Id__c = 'nsapi@linuxfoundation.org';
		endPoint2.Nlauth_Account__c = '4010327_SB1';
		insert endPoint2;


		Account a = new Account();
		a.Name = 'TestAccount';
		a.billingstreet = 'Test';
		a.billingcity = 'Testcity';
		a.billingstate = 'TX';
		a.billingPostalCode = '123';
		a.billingCountry = 'US';
		a.P_O_Required__c = true;
		a.Event_PO_required__c = true;
		insert a;

		System.debug(a + '====> a');

		Contact con = new Contact(lastname = 'testCreateAsset', email = 'AssetonClosedWon@gmail.com', accountid = a.id);
		insert con;

		Product2 prod = new Product2(Name = 'Product', Family = 'Membership', Tax_Class__c = 'test');
		insert prod;

		PricebookEntry pbe2 = new PricebookEntry(unitprice = 0.01, Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(), isActive = true, UseStandardPrice = false);
		insert pbe2;

		PricebookEntry pbID = [select Id
		                       from PricebookEntry
		                       where isactive = true
		                       limit 1];
		Opportunity o = new Opportunity();
		OpportunityLineItem ol = new OpportunityLineItem();


		o.AccountId = a.Id;
		o.Name = 'test';
		o.StageName = '2. Discovery';
		o.Type = 'Renewal';
		o.CloseDate = date.today();
		o.Bill_To_Account__c = a.Id;
		insert o;
		system.debug('o----->' + o.Id);
		OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = o.id, contactid = con.id, role = 'Membership Decision Maker', IsPrimary = True);
		insert ocr;

		User pmUser = TestFactory.getUser();
		pmUser.IsActive = true;
		update pmUser;

		Contact con1 = new Contact();
		con1.LastName = 'testContact';
		con1.Email = 'standarduser123@testorg.com';
		Insert con1;

		Project__c prj = new Project__c(Name = 'testing11', Status__c = 'Planned', Category__c = 'Subproject', Subsidiary_ID__c = 8, Program_Manager_U__c = pmUser.Id, Program_Manager__c = con1.id, Slug__c = 'testing');
		insert prj;

		Product_Details__c Pd = new Product_Details__c();
		Pd.Price__c = 56;
		pd.Project__c = prj.Id;
		Pd.NS_Income_GL_Account__c = '290';
		pd.NS_Deferred_Revenue_Account__c = '284';
		pd.NS_Department__c = '10';
		pd.NS_Revenue_Schedule__c = '29';
		Pd.Netsuite_Sync__c = false;
		pd.Products__c = prod.id;
		Pd.Duration__c = '45';
		Pd.Description__c = 'Description_Test';
		Pd.Tier__c = 'Test';
		pd.Netsuite_ID__c = '889955';
		insert Pd;

		ol.OpportunityId = o.Id;
		ol.Quantity = 1;
		ol.UnitPrice = 2.00;
		ol.PricebookEntryId = pbId.Id;
		ol.start_date__c = Date.newInstance(2016, 8, 1);
		ol.end_date__c = date.today().addDays(2);
		ol.Technical_Contact__c = con.Id;
		ol.Technical_Contact_2__c = con.Id;
		ol.Technical_Contact_3__c = con.Id;
		ol.PO_Contact__c = con.Id;
		ol.Authorized_Signatory__c = con.Id;
		ol.Representative_Voting_Contact__c = con.Id;
		ol.Marketing_Contact__c = con.Id;
		ol.Press_Contact__c = con.Id;
		ol.Legal_Contact__c = con.Id;
		ol.Billing_Contact__c = con.Id;
		ol.billing_contact2__c = con.Id;
		ol.billing_contact3__c = con.Id;
		ol.Marketing_Contact_2__c = con.Id;
		ol.Marketing_Contact_3__c = con.Id;
		ol.Projects__c = prj.Id;
		ol.Product_Details__c = pd.id;
		ol.AgreementDate__c = Date.today().addDays(4);
		insert ol;

		o.StageName = '3.Quote';
		update o;
		o.StageName = '4.Contract';
		update o;
		o.StageName = '5.Decision Commitment';
		update o;

		Asset asst = new Asset(Name = 'TEstcreateasset', AccountId = a.ID, Projects__c = prj.ID, Status = 'Active', UsageEndDate = system.today(), Number_of_Years_Required__c = 1, Opportunity__c = o.ID, OpportunityLineItem__c = ol.id, Auto_Renew__c = TRUE, Product2Id = prod.ID);
		asst.NetSuite_ID__c = '145670';
		insert asst;


        Id membershipRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();

		Opportunity opp = new Opportunity();
		opp.AccountId = a.Id;
		opp.Name = 'test Renewal Opp';
		opp.StageName = '2. Discovery';
		opp.Type = 'Renewal';
		opp.CloseDate = date.today();
		opp.Bill_To_Account__c = a.Id;
		opp.Parent_Asset__c = asst.Id;
        opp.RecordTypeId = membershipRTId;
		insert opp;
	}

	@isTest
	public static void testData(){

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
		Database.BatchableContext bc;
		ProcessNSInvoiceBatch processNsBatch = new ProcessNSInvoiceBatch();
		List<InvoiceWrapperNS> iterableObj = (List<InvoiceWrapperNS>)processNsBatch.start(bc);
		processNsBatch.execute(bc, iterableObj);
		//Database.executebatch(new ProcessNSInvoiceBatch());
		Test.stopTest();
		System.assertEquals('Stage 1', [SELECT Id, StageName
		                                from Opportunity
		                                LIMIT 1].StageName);
		Opportunity opp = [select id, stagename
		                   from opportunity
		                   where name = 'test Renewal Opp'];
		System.debug(opp + ' ' + opp.StageName);
	}
}