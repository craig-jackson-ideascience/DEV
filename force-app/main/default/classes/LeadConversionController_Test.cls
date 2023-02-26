/**
 * Test class for LeadConversionController
 */
@IsTest
private class LeadConversionController_Test{
	/* testSetup: for creating data required for testing */
	@TestSetup
	static void testSetup(){
		/* account */
		Account acc = TestFactory.getAccount();

		/* contact */
		Contact cont = new Contact(LastName = 'test', AccountId = Acc.Id, Email = 'Test@yahoo.mail.com');
		insert cont;

		/* lead */
		List<Lead> listOfLead = new List<Lead>();

		Lead convertedLead = new Lead(LastName = 'Test Convert Lead No. 1', Email = 'test@noreply.com', Company = 'Test');
		listOfLead.add(convertedLead);

		Lead lead = new Lead(LastName = 'Test Lead', Email = 'testing@noreply.com', Company = 'Test');
		listOfLead.add(lead);

		Lead masterlead = new Lead(LastName = 'Masterlead', Email = 'test1@noreply1.com');
		listOfLead.add(masterlead);

		Lead duplicateLeadNo1 = new Lead(LastName = 'Test Merge Lead #1', Email = 'test4@noreply12.com');
		listOfLead.add(duplicateLeadNo1);

		Lead duplicateLeadNo2 = new Lead(LastName = 'Test Merge Lead #2', Email = 'test5@noreply13.com');
		listOfLead.add(duplicateLeadNo2);

		insert listOfLead;

		LeadStatus convertStatus = [SELECT Id, MasterLabel
		                            FROM LeadStatus
		                            WHERE IsConverted = true
		                            LIMIT 1];
		Database.LeadConvert leadConvert = new Database.LeadConvert();
		leadConvert.setLeadId(convertedLead.Id);
		leadConvert.setDoNotCreateOpportunity(true);
		leadConvert.setConvertedStatus(convertStatus.MasterLabel);
		Database.convertLead(leadConvert);
		Lead leadNew = new Lead(LastName = 'Test Convert Lead No. 2', Email = 'test223@noreply.com');
		if (convertedLead.Email != leadNew.Email){
			insert leadNew;
		}

		/* alternate email */
		Alternate_Email__c alternateEmail = new Alternate_Email__c(Alternate_Email_Address__c = 'abcdpratikst@gmail.com', Contact_Name__c = cont.Id, Active__c = true, Lead_name__c = lead.id);
		insert alternateEmail;
	}

	/**
	 * findDuplicates_test test method for findDuplicates
	 */
	@IsTest
	static void findDuplicates_test(){
		Lead lead = [SELECT ID, Name, Email
		             FROM Lead
		             LIMIT 1];
		System.assert(LeadConversionController.findDuplicates(lead) != null, 'Duplicates should not be there');
	}

	/**
	 * convertLeadRecord_test test method for convertLeadRecord
	 */
	@IsTest
	static void convertLeadRecord_test(){
		Account acc = [SELECT Id, Name
		               FROM Account
		               LIMIT 1];
		Contact cont = [SELECT Id, Name
		                FROM Contact
		                LIMIT 1];
		Lead lead = [SELECT Id, Name, OwnerId
		             FROM Lead
		             WHERE LastName = 'Test Lead'];
		Alternate_Email__c alternateEmail = [SELECT Id, Contact_Name__c
		                                     FROM Alternate_Email__c
		                                     LIMIT 1];
		String accountid = acc.id;
		String contactid = alternateEmail.Contact_Name__c;
		String leadid = lead.Id;
		String ownerId = lead.OwnerId;
		String result = LeadConversionController.convertLeadRecord(accountid, contactid, leadid, ownerId);
		System.assertNotEquals(result, null, 'Return value should not be null');
	}

	/**
	 * mergeLeadRecords_test test method for mergeLeadRecords
	 */
	@IsTest
	static void mergeLeadRecords_test(){
		List<Lead> listOfLead = [SELECT Id, Email
		                         FROM Lead
		                         WHERE LastName = 'Masterlead' OR LastName LIKE '%Test Merge Lead%'
		                         ORDER BY LastName];
		List<Lead> duplicateLeads = new List<Lead>{listOfLead[1], listOfLead[2]};
		String duplicateleadstring = JSON.serialize(duplicateLeads);
		String result = LeadConversionController.mergeLeadRecords(listOfLead[0], duplicateleadstring);
		System.assertNotEquals(result, null, 'Return value should not be null');
	}
}