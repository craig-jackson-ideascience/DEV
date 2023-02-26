/**
 * FindEmailController Class - Controller class for FindEmail_LC Component
 * Created by: @ CloudRoute Solutions
 * Created Date: May 2021
 * Test Class - FindEmailController_Test
 */
public with sharing class FindEmailController{
	/**
	 * findContactFromEmail : Method to find the contactId based on email
	 * If AlternateEmail is associated with the contact or lead then we convert the lead
	 * @param  email : emailAddress
	 */
	@AuraEnabled
	public static String findContactFromEmail(String email){

		String contactId = '';
		try{
			//Retrieve the alternateEmail Record
			List<Alternate_Email__c> alternateEmailList = [SELECT Id, Contact_Name__c, Lead_Name__c
			                                               FROM Alternate_Email__c
			                                               WHERE Alternate_Email_Address__c = :email
			                                               WITH SECURITY_ENFORCED
			                                               LIMIT 1];

			//If the alternate Email exist
			if (!alternateEmailList.isEmpty()){
				Alternate_Email__c altEmail = alternateEmailList[0];

				if (altEmail.Contact_Name__c != null){
					contactId = altEmail.Contact_Name__c;
				} else if (altEmail.Lead_Name__c != null){
					Lead leadInstance = new Lead(Id = altEmail.Lead_Name__c, Convert_Lead__c = true);
					//update
					Database.update(leadInstance);
					contactId = [SELECT Id, ConvertedContactId
					             FROM Lead
					             WHERE Id = :altEmail.Lead_Name__c].ConvertedContactId;
					if (contactId == null){
						contactId = 'Error';
					}
				}

			}
		} catch (Exception e){
			System.debug('Exception: ' + e + ', Message: ' + e.getMessage()+', Line Number: ' + e.getLineNumber()+'\n' + e.getStackTraceString());
			contactId = 'Error';
		}
		return contactId;
	}
}