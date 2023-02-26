/********************************************************
 *
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 09-10-2019.
 * Description: Test class for EmailValidator
 ********************************************************/
@IsTest
private class EmailValidator_Test{
	/**
	 * testSetup: creating required data for testing
	 */
	@TestSetup
	static void testSetup(){
		/* alternate email */
		List<Alternate_Email__c> aeList = new List<Alternate_Email__c>();
		for (integer i = 0; i <= 5; i++){
			aeList.add(new Alternate_Email__c(Alternate_Email_Address__c = 'test' + i + '@test.com'));
		}
		insert aeList;
	}

	/**
	 * emailValidator_test : test method for validating email
	 */
	@IsTest
	static void emailValidator_test(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new EmailValidatorHttpMock(false));
		Alternate_Email__c ae = [SELECT ID, Email_Verified__c
		                         FROM Alternate_Email__c
		                         WHERE Alternate_Email_Address__c = 'test1@test.com'];
		EmailValidator.runValidatorBatch(new List<Id>{ae.ID});
		Alternate_Email__c ae1 = [SELECT ID, Email_Verified__c
		                          FROM Alternate_Email__c
		                          WHERE Alternate_Email_Address__c = 'test2@test.com'];
		EmailValidator.runValidatorBatch(new List<Id>{ae1.ID});
		Test.stopTest();
		ae = [SELECT ID, Email_Verified__c
		      FROM Alternate_Email__c
		      WHERE Alternate_Email_Address__c = 'test1@test.com'];
		System.assertEquals(false, ae.Email_Verified__c, 'Email Verified should be false');
		ae1 = [SELECT ID, Email_Verified__c
		       FROM Alternate_Email__c
		       WHERE Alternate_Email_Address__c = 'test2@test.com'];
		System.assertEquals(false, ae1.Email_Verified__c, 'Email Verified should be false');
	}

	/**
	 * validateMethod_test: test method for validating
	 */
	@IsTest
	static void validateMethod_test(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new EmailValidatorHttpMock(false));
		Boolean result1 = EmailValidator.validate('test1@test.com').smtp_check;
		Boolean result2 = EmailValidator.validate('test2@test.com').smtp_check;
		Test.stopTest();
		System.assertEquals(true, result1, 'Smpt Check should be true');
		System.assertEquals(true, result2, 'Smpt Check should be true');
	}

	/**
	 * validateError_test: test method for validating error
	 */
	@IsTest
	static void validateError_test(){

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new EmailValidatorHttpMock(true));
		Boolean result1 = EmailValidator.validate('test1@test.com').smtp_check;
		MailBoxWrapper.Error result2 = EmailValidator.validate('test2@test.com').Error;
		Test.stopTest();
		System.assertEquals(null, result1, 'Smpt Check should be null');
		System.assertNotEquals(400, result2.code, 'Error code should be 400');
	}
}