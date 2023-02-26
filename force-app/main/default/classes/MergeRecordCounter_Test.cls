/**
 * Test class for MergedRecordCounter
 */
@IsTest
private class MergeRecordCounter_Test{
	/**
	 * testSetup: to create required data for testing
	 */
	@TestSetup
	static void testSetup(){
		/* account */
		List<Account> accs = new List<Account>();
		for (Integer i = 0; i < 3; i++){
			Account acc = new Account();
			acc.Name = 'Acme';
			acc.Website = 'acme.com';
			accs.add(acc);
		}
		insert accs;

		Database.merge(accs[0], accs[1], false);
		Database.merge(accs[0], accs[2], false);

		Account accToReset = new Account();
		accToReset.Name = 'Account merged 19 months ago';
		accToReset.Website = 'google.com';
		accToReset.Merged_Accounts__c = 5;
		insert accToReset;

		/* lead */
		List<Lead> leads = new List<Lead>();
		for (Integer i = 0; i < 3; i++){
			Lead ld = new Lead();
			ld.LastName = 'Smith';
			ld.Email = 'test' + i + '@test.com';
			leads.add(ld);
		}
		insert leads;

		Database.merge(leads[0], leads[1], false);
		Database.merge(leads[0], leads[2], false);

		Lead leadToReset = new Lead();
		leadToReset.LastName = 'Lead merged 19 months ago';
		leadToReset.Merged_Leads__c = 5;
		leadToReset.Email = 'testing@test.com';
		insert leadToReset;

		/* contact */
		List<Contact> cons = new List<Contact>();
		for (Integer i = 0; i < 3; i++){
			Contact con = new Contact();
			con.LastName = 'Smith';
			cons.add(con);
		}
		insert cons;

		Database.merge(cons[0], cons[1], false);
		Database.merge(cons[0], cons[2], false);

		Contact conToReset = new Contact();
		conToReset.LastName = 'Contact merged 19 months ago';
		conToReset.Merged_Contacts__c = 5;
		insert conToReset;
	}

	/**
	 * updateMergedAccountCount_test: test method for testing account merge
	 */
	@IsTest
	static void updateMergedAccountCount_test(){
		//stage data
		Account accToReset = [SELECT Id, Name
		                      FROM Account
		                      WHERE Name = 'Account merged 19 months ago'];

		//run method
		MergedRecordCounter.updateMergedAccountCount();

		//get updated Accounts to verify results
		List<Account> updatedAccs = new List<Account>();
		updatedAccs = [SELECT Merged_Accounts__c
		               FROM Account];

		//should only be 2 Accounts left after merges
		System.assertEquals(2, updatedAccs.size());

		for (Account acc : updatedAccs){
			//# Merged Accounts for the accToReset should be 0
			if (acc.Id == accToReset.Id){
				System.assertEquals(0, acc.Merged_Accounts__c);
				//# Merged Accounts for the other Account (Acme) should be 2
			} else{
				System.assertEquals(2, acc.Merged_Accounts__c);
			}
		}
	}

	/**
	 * updateMergedLeadCount_test: test method for testing lead merge
	 */
	@IsTest
	static void updateMergedLeadCount_test(){
		//stage data
		List<Lead> leads = [SELECT Id, LastName
		                    FROM Lead
		                    WHERE LastName = 'Smith'];

		Lead leadToReset = [SELECT Id, LastName
		                    FROM Lead
		                    WHERE LastName = 'Lead merged 19 months ago'];

		//run method
		MergedRecordCounter.updateMergedLeadCount();

		//get updated Leads to verify results
		List<Lead> updatedLeads = new List<Lead>();
		updatedLeads = [SELECT Merged_Leads__c
		                FROM Lead];

		//should only be 2 Leads left after merges
		System.assertEquals(2, updatedLeads.size());

		for (Lead ld : updatedLeads){
			//# Merged Leads for the leadToReset should be 0
			if (ld.Id == leadToReset.Id){
				System.assertEquals(0, ld.Merged_Leads__c);
				//# Merged Leads for the other Lead (Smith) should be 2
			} else{
				System.assertEquals(2, ld.Merged_Leads__c);
			}
		}
	}

	/**
	 * updateMergedContactCount_test: test method for testing contact merge
	 */
	@IsTest
	static void updateMergedContactCount_test(){
		//stage data
		List<Contact> cons = [SELECT Id, LastName
		                      FROM Contact
		                      WHERE LastName = 'Smith'];

		Contact conToReset = [SELECT Id, LastName
		                      FROM Contact
		                      WHERE LastName = 'Contact merged 19 months ago'];

		//run method
		MergedRecordCounter.updateMergedContactCount();

		//get updated Contacts to verify results
		List<Contact> updatedContacts = new List<Contact>();
		updatedContacts = [SELECT Merged_Contacts__c
		                   FROM Contact];

		//should only be 2 Contacts left after merges
		System.assertEquals(2, updatedContacts.size());

		for (Contact con : updatedContacts){
			//# Merged Contacts for the conToReset should be 0
			if (con.Id == conToReset.Id){
				System.assertEquals(0, con.Merged_Contacts__c);
				//# Merged Contacts for the other Contact (Smith) should be 2
			} else{
				System.assertEquals(2, con.Merged_Contacts__c);
			}
		}
	}

	/**
	 * scheduledJob_test: test method for scheduling
	 */
	@IsTest
	static void scheduledJob_test(){
		String CRON_EXP = '0 0 0 15 3 ? *';
		Test.startTest();
		String jobID = System.schedule('ScheduledApexTest', CRON_EXP, new MergedRecordCounter());
		Test.stopTest();
	}
}