/**
 * FindEmailController_Test Class - CTest class for FindEmailController class
 * Created by: @ CloudRoute Solutions
 * Created Date: May 2021
 */
@isTest
public with sharing class FindEmailController_Test{

    /**
     * findContactFromEmailLeadTest :Test Method for finding the contactId for the email which is associated with lead
     */
	@IsTest
	static void findContactFromEmailLeadTest(){
        
		String email = 'test@noreply123.com';
		Lead lead = TestDataUtils.createLead(true, 'Test', 'New Lead', 'Test Company', null, email);
		Test.startTest();
		String contactId = FindEmailController.findContactFromEmail(email);
		
		System.assertNotEquals(null, contactId, 'ContactID must not be null');
        Test.stopTest();
	}

     /**
     * findContactFromEmailContactTest :Test Method for finding the contactId for the email which is associated with contact
     */
	@IsTest
	static void findContactFromEmailContactTest(){
		String email = 'test@noreply123.com';
		Contact contact = TestFactory.getContact();
		Test.startTest();
		String contactId = FindEmailController.findContactFromEmail(contact.Email);
		Test.stopTest();
		System.assertEquals(contactId, contact.Id, 'ContactID must match');
	}
}