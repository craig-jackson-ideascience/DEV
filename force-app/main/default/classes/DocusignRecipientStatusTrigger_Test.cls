/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 04-11-2019.
 * Description: DocusignRecipientStatusTrigger_Test
 ********************************************************/
@isTest
public class DocusignRecipientStatusTrigger_Test{
	@testSetup
	public static void createTestData(){


		Account a = new Account(Name = 'testAccount ');
		insert a;
		Contact con = new Contact(FirstName = 'Test ', lastname = 'testCreateAsset', email = 'AssetonClosedWon@gmail.com', accountid = a.id);
		insert con;
		/*
		 PricebookEntry pbID = new PricebookEntry();
		 pbID.Pricebook2Id = Test.getStandardPricebookId();
		 pbID.Product2 = [select Id from Product2 limit 1];
		 insert pbID;*/
		Opportunity o = new Opportunity();
		Id membershipRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
		o.RecordTypeId = membershipRecordId;
		o.AccountId = a.Id;
		o.Name = 'Individual Membership test';
		o.StageName = '2. Discovery';
		o.Type = 'New Business';
		o.CloseDate = date.today();
		o.Bill_To_Account__c = a.Id;
		o.Authorized_Signatory__c = con.Id;
		insert o;

		OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = o.id, contactid = con.id, role = 'Membership Decision Maker', IsPrimary = True);
		insert ocr;


		Project__c prj = new Project__c(Name = 'testing11', Status__c = 'Planned', Subsidiary_ID__c = 8, Category__c = 'LF Supported', Slug__c = 'testing', External_Individual_Contract_Signed__c = 'Test [ProjectName] [UserFirstName] ');
		insert prj;

		PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
		insert pbk;

		Product2 prod = new Product2(Name = 'TestP', productcode = 'test');
		insert prod;

		PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = Test.getStandardPricebookId(), Product2Id = prod.ID, isActive = true, unitPrice = 34);
		insert standardPbe;

		PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
		insert pbe;

		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = o.Id, Quantity = 2, unitPrice = 20, PriceBookEntryId = pbe.ID, Required_Active_LF_Membership__c = true, Projects__c = prj.id);
		insert oli;

		dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Sent', dsfs__Opportunity__c = o.id);
		insert ds;
	}
	static testMethod void testIndividualSendEmail(){
		dsfs__DocuSign_Status__c ds = [SELECT ID
		                               FROM dsfs__DocuSign_Status__c
		                               LIMIT 1];

		dsfs__DocuSign_Recipient_Status__c drs = new dsfs__DocuSign_Recipient_Status__c(dsfs__DocuSign_Recipient_Email__c = 'test@test.com', Name = 'Test Name', dsfs__Parent_Status_Record__c = ds.Id, dsfs__DocuSign_Recipient_Id__c = 'esasd', dsfs__Recipient_Status__c = 'Sent', dsfs__DocuSign_Routing_Order__c = 1);
		insert drs;
		drs.dsfs__Recipient_Status__c = 'Completed';
		update drs;
		delete drs;
	}
	static testMethod void testSendEmailForContractReview(){
		dsfs__DocuSign_Status__c ds = [SELECT ID
		                               FROM dsfs__DocuSign_Status__c
		                               LIMIT 1];

		Project__c prj = [SELECT Id
		                  FROM Project__c
		                  LIMIT 1];
		prj.External_Individual_Contract_Signed__c = '';
		update prj;
		dsfs__DocuSign_Recipient_Status__c drs = new dsfs__DocuSign_Recipient_Status__c(dsfs__DocuSign_Recipient_Email__c = 'test@test.com', Name = 'Test Name', dsfs__Parent_Status_Record__c = ds.Id, dsfs__DocuSign_Recipient_Id__c = 'esasd', dsfs__Recipient_Status__c = 'Sent', dsfs__DocuSign_Routing_Order__c = 1);
		insert drs;
		drs.dsfs__Recipient_Status__c = 'Completed';
		update drs;
		System.assertEquals(1, Limits.getEmailInvocations(), 'Email must have been sent');

		delete drs;
	}
	static testMethod void testSendEmailForNonIndividual(){
		dsfs__DocuSign_Status__c ds = [SELECT ID
		                               FROM dsfs__DocuSign_Status__c
		                               LIMIT 1];

		Opportunity opp = [SELECT Id
		                   FROM Opportunity
		                   LIMIT 1];
		opp.Name = 'Test';
		update opp;
		Project__c prj = [SELECT Id
		                  FROM Project__c
		                  LIMIT 1];
		prj.External_Individual_Contract_Signed__c = '';
		prj.External_Contract_Signed_Notification__c = 'Test [ProjectName] [UserFirstName] ';
		update prj;
		Test.startTest();
		dsfs__DocuSign_Recipient_Status__c drs = new dsfs__DocuSign_Recipient_Status__c(dsfs__DocuSign_Recipient_Email__c = 'test@test.com', Name = 'Test Name', dsfs__Parent_Status_Record__c = ds.Id, dsfs__DocuSign_Recipient_Id__c = 'esasd', dsfs__Recipient_Status__c = 'Sent', dsfs__DocuSign_Routing_Order__c = 1);
		insert drs;
		drs.dsfs__Recipient_Status__c = 'Completed';
		update drs;
		System.assertEquals(1, Limits.getEmailInvocations(), 'Email must have been sent');

		delete drs;
		Test.stopTest();
	}
}