/**
 * Test class for OpportunityTrigger
 */
@IsTest
public class TestOpportunityTrigger{
	static Id trainingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();
	static Id membershipRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();

	/**
     * TestSetup inserting required data for test class
     */
	@TestSetup
	static void testSetup(){

		/* quote sync field */
		QuoteSyncField__c quoteSyncField = new QuoteSyncField__c(Name = 'PaymentTerms__c', OppSyncField__c = 'PaymentTerms__c');
		insert quoteSyncField;

		/* quote line sync field */
		QuoteLineSyncField__c quoteLineSyncField = new QuoteLineSyncField__c(Name = 'Agreement_Date__c', OppLineSyncField__c = 'AgreementDate__c');
		insert quoteLineSyncField;

		/* endpoints */
		List<Endpoints__c> listOfEndpoint = new List<Endpoints__c>();

		Endpoints__c endPoint = new Endpoints__c();
		endPoint.name = 'For Membership Asset';
		endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=90&deploy=4';
		listOfEndpoint.add(endPoint);

		Endpoints__c endPoint2 = new Endpoints__c();
		endPoint2.Name = 'For Product Details';
		endPoint2.Endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=41&deploy=1';
		endPoint2.Password__c = 'jYdpn8sp22F8C45b';
		endPoint2.User_Id__c = 'nsapi@linuxfoundation.org';
		endPoint2.Nlauth_Account__c = '4010327_SB1';
		listOfEndpoint.add(endPoint2);

		insert listOfEndpoint;

		/* account */
		List<Account> listOfAccount = new List<Account>();
		Account acc = new Account(Name = 'Test account', BillingStreet = 'street');
		listOfAccount.add(acc);	
		insert listOfAccount;

		/* contact */
		Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id, Email = 'test@contact.com');
		insert con;

		/* opportunity */
		List<Opportunity> listOfOpp = new List<Opportunity>();
		Opportunity oppt = new Opportunity(Name = 'Opportunity testing 1', accountId = acc.Id, StageName = '2. Discovery', CloseDate = Date.today().addDays(4), PaymentTerms__c = 'Net 30');
		listOfOpp.add(oppt);
		Opportunity trainingOpp = new Opportunity(RecordTypeId = trainingRecordTypeId, Name = 'Opportunity testing for Training', accountId = acc.Id, Billing_Contact__c = con.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True', Preferred_Invoice_Method__c = 'Email');
		listOfOpp.add(trainingOpp);

		Opportunity joinNowOppt = new Opportunity(Name = 'Opportunity testing for Contactrole', accountId = acc.Id, Billing_Contact__c = con.Id, StageName = '2. Discovery', Type = 'Membership', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True', Preferred_Invoice_Method__c = 'Email', RecordTypeID = Label.JoinNow_Opportunity_RecordTypeId);
		listOfOpp.add(joinNowOppt);

		Opportunity memberShipOpp = new Opportunity(Name = 'Opportunity testing for Contactrole', accountId = acc.Id, Billing_Contact__c = con.Id, StageName = '2. Discovery', Type = 'Membership', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True', Preferred_Invoice_Method__c = 'Email', RecordTypeID = membershipRecordId);
		listOfOpp.add(memberShipOpp);

		insert listOfOpp;

		/* project */
		List<Project__c> listOfProj = new List<Project__c>();
		Project__c prj = new Project__c(Name = 'testing11', Slug__c = 'test', Notifications_Group__c = 'test@test.com', Status__c = 'Planned', Category__c = 'Directed Fund', Subsidiary_ID__c = 8);
		listOfProj.add(prj);

		Project__c prjLf = new Project__c(Name = 'The Linux Foundation', Slug__c = 'tlf', Notifications_Group__c = 'test@test.com', Status__c = 'Planned', Category__c = 'Directed Fund', Subsidiary_ID__c = 8);
		listOfProj.add(prjLf);

		insert listOfProj;

		prj.Status__c = 'Active';
		prj.Funding__c = 'Funded';
		prj.Model__c = 'Membership';
		update prj;

		/* event */
		Event__c evt = new Event__c(Name = 'test Event Name', Category__c = 'Non-LF Event', Start_Date__c = System.today(), End_Date__c = System.today() + 1, BillFromProject__c = prj.id);
		insert evt;

		/* pricebook */
		Id pricebookId = Test.getStandardPricebookId();
		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		/* product */
		List<Product2> listOfProd = new List<Product2>();
		Product2 prod = new Product2(Name = 'TestP', Productcode = 'test', IsActive = true, Family = 'Membership');
		listOfProd.add(prod);

		Product2 certificationProd = new Product2(Name = 'Certification', productcode = 'test', Type__c = 'Certification', Family = 'Membership');
		listOfProd.add(certificationProd);

		Product2 bulkProd = new Product2(Name = 'Bulk', productcode = 'test bulk', Type__c = 'Bundle');
		listOfProd.add(bulkProd);

		insert listOfProd;

		/* pricebook entry */
		List<PriceBookEntry> listOfPriceBookEntry = new List<PriceBookEntry>();

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
		listOfPriceBookEntry.add(standardPbe);

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		listOfPriceBookEntry.add(pbe);

		PriceBookEntry certiSbPrice = new PriceBookEntry(PriceBook2Id = PricebookId, Product2Id = certificationProd.ID, IsActive = true, UnitPrice = 34);
		listOfPriceBookEntry.add(certiSbPrice);

		insert listOfPriceBookEntry;

		/* training */
		Training__c training = new Training__c(Name = 'test Training', Category__c = 'Instructor-Led', Is_Dummy_Product__c = true);
		insert training;

		/* opportunity line item */
		List<OpportunityLineItem> listOfLineItem = new List<OpportunityLineItem>();
		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 200, PriceBookEntryId = standardPbe.ID, AgreementDate__c = System.today());
		listOfLineItem.add(oli);

		OpportunityLineItem trainingOLI = new OpportunityLineItem(OpportunityId = trainingOpp.Id, Quantity = 2, UnitPrice = 20, PriceBookEntryId = certiSbPrice.Id, Product2Id = certificationProd.Id, Billing_Contact__c = con.Id, Description__c = 'test', End_Date__c = Date.today().addDays(365), Training__c = training.Id);
		listOfLineItem.add(trainingOLI);

		OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = joinNowOppt.Id, Quantity = 2, UnitPrice = 20, PriceBookEntryId = pbe.ID, Product2Id = certificationProd.Id, Required_Active_LF_Membership__c = true, training__c = training.Id, Parent_Product__c = prod.Id);
		listOfLineItem.add(oli2);

		OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = memberShipOpp.Id, Quantity = 2, UnitPrice = 20, PriceBookEntryId = pbe.ID, Product2Id = certificationProd.Id, Required_Active_LF_Membership__c = true, Projects__c = prjLf.Id);
		listOfLineItem.add(oli3);

		insert listOfLineItem;

		/* opportunity contact role */
		OpportunityContactRole ocr = new OpportunityContactRole(Opportunityid = oppt.id, Contactid = con.id, Role = 'Membership Decision Maker', IsPrimary = true);
		insert ocr;

		/* product details */
		List<Product_Details__c> listOfProdDetail = new List<Product_Details__c>();
		Product_Details__c prodDetail = new Product_Details__c();
		prodDetail.Price__c = 56;
		prodDetail.Project__c = prj.Id;
		prodDetail.NS_Income_GL_Account__c = '290';
		prodDetail.NS_Deferred_Revenue_Account__c = '284';
		prodDetail.NS_Department__c = '10';
		prodDetail.NS_Revenue_Schedule__c = '29';
		prodDetail.Netsuite_Sync__c = false;
		prodDetail.Products__c = prod.id;
		prodDetail.Duration__c = '45';
		prodDetail.Description__c = 'Description_Test';
		prodDetail.Tier__c = 'Test';
		prodDetail.Netsuite_ID__c = '889955';
		listOfProdDetail.add(prodDetail);

		Product_Details__c prodDetail1 = prodDetail.clone();
		prodDetail1.Products__c = certificationProd.Id;
		listOfProdDetail.add(prodDetail1);

		insert listOfProdDetail;
	}
	/**
	 * Test method for opportunity sync quote
	 */
	@IsTest
	static void testOppSyncTrigger(){
		List<OpportunityLineItem> oliList = [SELECT Id,PriceBookEntryId,Product2Id,OpportunityId,Projects__c
		                                     FROM OpportunityLineItem
		                                     Where Projects__c != null];
											 Quote quote = new Quote();
		quote.Name = 'Test Quote';
		quote.OpportunityId = oliList[0].OpportunityId;
		insert quote;

		List<QuoteLineItem> qliList = new List<QuoteLineItem>();
		for(OpportunityLineItem oli : oliList){
			QuoteLineItem qli = new QuoteLineItem(QuoteId = quote.Id, OpportunityLineItemId = oli.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = oli.PriceBookEntryId, Product2Id = oli.Product2Id, Projects__c = oli.Projects__c);
			qliList.add(qli);
		}
		
		insert qliList;
		List<QuoteLineItem> qliList1 = [SELECT Id, OpportunityLineItemId
		                               FROM QuoteLineItem
		                               WHERE QuoteId = :quote.Id];
		qliList1[0].Agreement_Date__c = Date.today() + 7;
		update qliList1[0];
		Test.startTest();
		Opportunity oppt = new Opportunity(Id = oliList[0].OpportunityId);
		oppt.PaymentTerms__c = 'Payment Due Immediately';
		oppt.SyncedQuoteId = quote.id;
		update oppt;
		oppt.PaymentTerms__c = 'Net 60';
		update oppt;
		Test.stopTest();

		System.assertEquals(1, [SELECT count()
		                        FROM Opportunity 
		                        WHERE SyncedQuoteId != null], 'Opportunity should be updated');
	}
	/**
	 * Test Method for restrictOppStageUpdateWithoutOCRs Method Opportunity Action
	 */
	@IsTest
	static void closedLost_test(){
		Opportunity oppt = [SELECT Id
		                    FROM Opportunity
		                    LIMIT 1];
		oppt.StageName = 'Closed Lost';
		oppt.Loss_Reason__c = 'Lost';
		update oppt;
		System.assertEquals(1, [SELECT count()
		                        FROM Opportunity 
		                        WHERE StageName = 'Closed Lost'], 'Opportunity should be Closed Lost');
	}
	/**
	 * Test Method for updateOppCloseDateAndInstallDate Method Opportunity Action
	 */
	@IsTest
	static void testCannotUdpateClosedWon(){
		Opportunity oppt = [SELECT Id
		                    FROM Opportunity
		                    WHERE RecordTypeId = :membershipRecordId
		                    LIMIT 1];
		oppt.StageName = 'Closed Won';
		try{
			update oppt;
		} catch (Exception e){
		}
		System.assertEquals(0, [SELECT count()
		                        FROM Opportunity 
		                        WHERE StageName = 'Closed Won'], 'Opportunity should not be Closed Won');

		oppt.StageName = '2. Discovery';
		oppt.CloseDate = Date.newInstance(System.today().year(), System.today().month(), 1);
		oppt.JoinNow_Update__c = system.today();
		try{
			update oppt;
		} catch (Exception e){
		}
		oppt.CloseDate = Date.newInstance(System.today().year(), System.today().month(), 16);
		oppt.JoinNow_Update__c = System.today().addDays(1);
		try{
			update oppt;
		} catch (Exception e){
		}
		System.assertEquals(0, [SELECT count()
		                        FROM Opportunity 
		                        WHERE StageName = 'Closed Won'], 'Opportunity should not be Closed Won');
	}
	
	/**
	 * test method to add default opportunity contact roles
	 *
	 */
	@IsTest
	static void addDefaultContactRole_test(){
		Account acc = [SELECT Id
		               FROM Account
		               LIMIT 1];
		Test.startTest();
		Opportunity oppt = new Opportunity(Name = 'Opportunity testing 1', AccountId = acc.Id, StageName = '2. Discovery', Type = 'Renewal', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert oppt;
		Test.stopTest();
		System.assertEquals(1, [SELECT count()
		                        FROM OpportunityContactRole], 'Opportunity Contact Role should be inserted');
	}
	/**
	 * test method to send opportunity email
	 *
	 */
	@IsTest
	static void sendOpportunityEmail_test(){
		Opportunity oppt = [SELECT Id
		                    FROM Opportunity
		                    LIMIT 1];
		OpportunityAction.sendOpportunityEmail(new List<Id>{ oppt.id });
		System.assertEquals(1, Limits.getEmailInvocations(), 'Email should be sent');
	}
	
	/**
	 * testMethod TO Test creation of asset on  opportunity closed won
	 */
	@IsTest
	static void opportunityClosedWon_test(){
		Test.startTest();
		Account a = [SELECT Id
		             FROM Account
		             LIMIT 1];
		Project__c prj = [SELECT Id
		                  FROM Project__c
		                  LIMIT 1];
		Contact con = [SELECT Id, Email
		               FROM Contact
		               WHERE Name = 'Test Contact'
		               LIMIT 1];
		Event__c evt = [SELECT Id
		                FROM Event__c
		                LIMIT 1];
		Opportunity o = new Opportunity();
		OpportunityLineItem ol = new OpportunityLineItem();
		o.AccountId = a.Id;
		o.Name = 'test';
		o.StageName = '2. Discovery';
		o.Type = 'Existing Business';
		o.CloseDate = date.today();
		o.Bill_To_Account__c = a.Id;
		insert o;
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
		Product_Details__c pd = new Product_Details__c();
		pd.Price__c = 56;
		pd.NS_Income_GL_Account__c = '290';
		pd.NS_Deferred_Revenue_Account__c = '284';
		pd.NS_Department__c = '10';
		pd.NS_Revenue_Schedule__c = '29';
		pd.Netsuite_Sync__c = false;
		pd.Duration__c = '45';
		pd.Description__c = 'Description_Test';
		pd.Tier__c = 'Test';
		pd.Netsuite_ID__c = '889955';
		pd.Project__c = prj.id;
		pd.Products__c = prod.id;
		insert pd;
		ol.OpportunityId = o.Id;
		ol.Quantity = 1;
		ol.UnitPrice = 2.00;
		ol.PricebookEntryId = standardPrice.Id;
		ol.start_date__c = Date.newInstance(2016, 8, 1);
		ol.end_date__c = date.today().addDays(2);
		ol.Prorate__c = true;
		ol.Technical_Contact__c = con.Id;
		ol.Representative_Voting_Contact__c = con.Id;
		ol.Marketing_Contact__c = con.Id;
		ol.Authorized_Signatory__c = con.Id;
		ol.Marketing_Contact_2__c = con.Id;
		ol.Marketing_Contact_3__c = con.Id;
		ol.Technical_Contact_2__c = con.Id;
		ol.Technical_Contact_3__c = con.Id;
		ol.PO_Contact__c = con.Id;
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
		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c objProjectRole = new Project_Role__c();
		objProjectRole.status__c = 'Active';
		objProjectRole.Contact__c = con.id;
		objProjectRole.Role__c = 'Representative/Voting Contact';
		objProjectRole.PrimaryContact__c = true;
		objProjectRole.Opportunity__c = o.Id;
		objProjectRole.Opportunity_Line_Item__c = ol.Id;
		projectRoles.add(objProjectRole);
		Project_Role__c objProjectRole1 = new Project_Role__c();
		objProjectRole1.status__c = 'Active';
		objProjectRole1.Contact__c = con.id;
		objProjectRole1.Role__c = 'Billing Contact';
		objProjectRole1.PrimaryContact__c = true;
		objProjectRole1.Opportunity__c = o.Id;
		objProjectRole1.Opportunity_Line_Item__c = ol.Id;
		projectRoles.add(objProjectRole1);
		Project_Role__c objProjectRole2 = new Project_Role__c();
		objProjectRole2.status__c = 'Active';
		objProjectRole2.Contact__c = con.id;
		objProjectRole2.Role__c = 'Marketing Contact 5';
		objProjectRole2.Opportunity__c = o.Id;
		objProjectRole2.Opportunity_Line_Item__c = ol.Id;
		projectRoles.add(objProjectRole2);
		insert projectRoles;
		OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = o.id, contactid = con.id, role = 'Membership Decision Maker', IsPrimary = True);
		insert ocr;
		o.StageName = '3.Quote';
		update o;
		o.StageName = '4.Contract';
		update o;
		o.StageName = '5.Decision Commitment';
		update o;
		dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Completed', dsfs__Opportunity__c = o.id);
		insert ds;

		Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
		Test.stopTest();

		System.assertEquals(1, [SELECT count()
		                        FROM Asset], 'Asset should be created');
	}
	/**
	 * test method for updateInvoiceMemoForTrainingProduct
	 *
	 */
	@IsTest
	static void updateInvoiceMemo_test(){
		Opportunity oppt = [SELECT Id
		                    FROM Opportunity
		                    WHERE RecordTypeId = :trainingRecordTypeId
		                    LIMIT 1];
		oppt.Corporate_Training_Bundle__c = true;
		oppt.NetSuite_Invoice_Memo__c = 'Bulk';
		update oppt;
		OpportunityLineItem oli = [SELECT Id
		                           FROM OpportunityLineItem
		                           WHERE OpportunityId = :oppt.Id
		                           LIMIT 1];


		System.assertEquals('Bulk', [SELECT Id, NetSuite_Invoice_Memo__c
		                             FROM OpportunityLineItem
		                             WHERE Id = :oli.Id][0].NetSuite_Invoice_Memo__c, 'NeSuite Invoice Memo value should be Bulk');

		oppt.NetSuite_Invoice_Memo__c = 'Test NetSuite_Invoice_Memo__c Change';
		update oppt;
	}
	/**
	 * test method for addTermsToAgreement
	 *
	 */
	@IsTest
	static void addTermsToAgreement_test(){
		Opportunity opp = TestFactory.getOpportunity();
		opp.Training_Modes__c = 'Certification Subscription';
        opp.RecordTypeId = trainingRecordTypeId;
		Test.startTest();
		update opp;
		opp = [SELECT Id, Engagement_Terms__c
		       FROM Opportunity
		       WHERE Name = 'Opportunity testing 1'];
		Boolean result = opp.Engagement_Terms__c.contains('Certification Subscription');
		System.assertEquals(true, result, 'Engagement Terms must be updated');
		Test.stopTest();
	}
	/**
	 * test method for validateOpportunityProductToRestrictOppsToClosedWon
	 *
	 */
	@IsTest
	public static void validateOpportunityProductToRestrictOppsToClosedWon_test(){
		Opportunity oppt = [SELECT Id
		                    FROM Opportunity
		                    WHERE RecordTypeId = :trainingRecordTypeId];
		List<OpportunityLineItem> oliList = [SELECT Id
		                                     FROM OpportunityLineItem
		                                     Where OpportunityId = :oppt.id];
		oliList[0].description__c = '';
		update olilist[0];
		Test.startTest();
		oppt.StageName = 'Closed Won';
		try{
			update oppt;
		} catch (Exception e){
		}
		Test.stopTest();
		System.assertEquals(0, [SELECT count()
		                        FROM Opportunity 
		                        WHERE Id = :oppt.Id AND StageName = 'Closed Won'], 'Opportunity should not be Closed Won');
	}
	@IsTest
	public static void closedTrainingOpp_Test(){
		Test.startTest();

		Opportunity oppt = [SELECT Id
		                    FROM Opportunity
		                    WHERE RecordTypeId = :trainingRecordTypeId LIMIT 1];
		Attachment attach = new Attachment();
		attach.Name = 'OpportunityNameContract';
		Blob bodyBlob = Blob.valueOf('OpportunityNameContract');
		attach.body = bodyBlob;
		attach.parentId = oppt.id;
		try{
        insert attach;
            } catch (Exception e){
		}
		oppt.StageName = 'Closed Won';
		try{
			update oppt;
		} catch (Exception e){
		}
		Test.stopTest();
		System.assertEquals(0, [SELECT count()
		                        FROM Opportunity 
		                        WHERE Id = :oppt.Id AND StageName = 'Closed Won'], 'Opportunity should not be Closed Won');
	}
	@IsTest
	public static void validateTrainingOpportunity_test(){
		Opportunity oppt = [SELECT Id
		                    FROM Opportunity
		                    WHERE RecordTypeId = :trainingRecordTypeId];
		Quote quote = new Quote(OpportunityId = oppt.Id, Name = 'Test Quote', Pricebook2Id = Test.getStandardPricebookId(), Status = 'Active', PaymentTerms__c = 'Net 30');
		insert quote;


		Test.startTest();
		oppt.StageName = 'Closed Won';
		oppt.Billing_Contact__c = null;
		oppt.Corporate_Training_Bundle__c = true;
		oppt.NetSuite_Invoice_Memo__c = null;
		try{
			update oppt;
		} catch (Exception e){
		}
		Test.stopTest();
		System.assertEquals(0, [SELECT count()
		                        FROM Opportunity 
		                        WHERE Id = :oppt.Id AND StageName = 'Closed Won'], 'Opportunity should not be Closed Won');
	}
	/**
	 * test method for createAddressObjForAccount
	 *
	 */
	@IsTest
	static void createAddressObjForAccount_test(){
		Account objAcc = new Account();
		objAcc.Name = 'Test Account1';
		objAcc.BillingStreet = 'Test street';
		objAcc.BillingCity = 'Test city';
		objAcc.BillingState = 'Test state';
		objAcc.BillingPostalCode = '147852';
		objAcc.BillingCountry = 'Test';
		insert objAcc;


		Opportunity o = new Opportunity();
		o.AccountId = objAcc.Id;
		o.Name = 'test111';
		o.StageName = '2. Discovery';
		o.Type = 'Existing Business';
		o.CloseDate = date.today();
		Test.startTest();
		insert o;

		Address__c objAddress = new Address__c();
		objAddress.Account__c = objAcc.id;
		objAddress.Street__c = objAcc.BillingStreet;
		objAddress.City__c = objAcc.BillingCity;
		objAddress.State__c = objAcc.BillingState;
		objAddress.Zip_Postal_Code__c = objAcc.BillingPostalCode;
		objAddress.Country__c = objAcc.BillingCountry;

		insert objAddress;

		Opportunity o2 = new Opportunity();
		o2.AccountId = objAcc.Id;
		o2.Name = 'test222';
		o2.StageName = '2. Discovery';
		o2.Type = 'Existing Business';
		o2.CloseDate = date.today().addDays(1);
		insert o2;

		System.assertNotEquals(null, [SELECT Id
		                              from Address__c
		                              WHERE Account__c = :objAcc.Id]);
		Test.stopTest();
	}
	/**
	 * test method for updateInvoiceMemoForMembershipLineItems
	 *
	 */
	@IsTest
	static void updateInvoiceMemoForMembershipLineItems_test(){
		Opportunity oppt = [SELECT Id
		                    FROM Opportunity
		                    WHERE RecordTypeId = :Label.JoinNow_Opportunity_RecordTypeId
		                    LIMIT 1];
		OpportunityLineItem oli = [SELECT Id
		                           FROM OpportunityLineItem
		                           WHERE OpportunityId = :oppt.Id
		                           LIMIT 1];
		oppt.Corporate_Training_Bundle__c = true;
		update oppt;
		oppt.Preferred_Invoice_Method__c = 'Hard Copy';
		update oppt;
		System.assertEquals('Hard Copy', [SELECT Id, NetSuite_Invoice_Memo__c
		                                  FROM OpportunityLineItem
		                                  WHERE Id = :oli.Id][0].NetSuite_Invoice_Memo__c, 'NetSuite Invoice Memo should be updated to Hard Copy');
	}
	/**
	 * test method for sendClosedLostEmailNotification
	 *
	 */
	@IsTest
	static void sendClosedLostEmailNotification_test(){
		OpportunityLineItem oli = [SELECT Id,OpportunityId,Projects__r.Notifications_Group__c FROM OpportunityLineItem WHERE Projects__r.Name = 'The Linux Foundation'];
		Opportunity oppt = new Opportunity(Id = oli.OpportunityId);
		Test.startTest();
		oppt.StageName = 'Closed Lost';
		oppt.Loss_Reason__c = 'Other';
		update oppt;
		System.assertEquals(1, Limits.getEmailInvocations(), 'Email should be sent'); 
		Test.stopTest();
	}
	/**
	 * test method for validateOpportunityProductToRestrictOppsToClosedWon
	 *
	 */
	@IsTest
	public static void addBillingContact_test(){
		Opportunity oppt = [SELECT Id, Billing_Contact__c
		                    FROM Opportunity
		                    WHERE RecordTypeId = :trainingRecordTypeId];
		Test.startTest();
		Id billingContact = oppt.Billing_Contact__c;
		oppt.Billing_Contact__c = null;
		update oppt;
		oppt.Billing_Contact__c = billingContact;
		try{
			update oppt;
		} catch (Exception e){
		}
		Test.stopTest();
		System.assertEquals(0, [SELECT count()
		                        FROM Opportunity 
		                        WHERE Id = :oppt.Id AND StageName = 'Closed Won'], 'Opportunity should not be Closed Won');
	}
}