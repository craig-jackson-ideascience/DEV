/*
 Test Class of BatchUpdateContactAccount
 */
@isTest
public class BatchUpdateContact_Test{
	/**
	 * TestSetup inserting required data for test class
	 */
	@testSetup
	static void createTestData(){
		//Account
		Account account1 = new Account(Name = 'Test account', website = 'testing1.com');
		Account account2 = new Account(Name = 'LF Anonymous', website = 'test@testing.com');
		insert new List<Account>{account1, account2};

		//Contact
		Contact contact1 = new Contact(LastName = 'testCon', email = 'test@testing1.com');
		Contact contact2 = new Contact(LastName = 'testCon1', email = 'test@gmail.com');
		insert new List<Contact>{contact1, contact2};

		//update contact's account to null
		contact1.AccountId = null;
		contact2.AccountId = null;
		update new List<Contact>{contact1, contact2};
	}

	/**
	 * createContactwithDomain_Test : Test Usecase - For Updating Contact with the account that matches with the domain of account
	 */
	@isTest
	static void createContactwithDomain_Test(){
		//Asserts before test
		System.assertEquals(2, [Select Count()
		                        From Contact 
		                        WHERE AccountID = null],'There must be 2 Contacts with No Account Populated on them');

		//Test
		Test.startTest();
		Database.executeBatch(new BatchUpdateContactAccount());
		Test.stopTest();

		//Asserts after test
		System.assertEquals(2, [Select Count()
		                        From Contact 
		                        WHERE AccountID != null],'There must be 2 Contacts with Account Populated on them');
	}
}