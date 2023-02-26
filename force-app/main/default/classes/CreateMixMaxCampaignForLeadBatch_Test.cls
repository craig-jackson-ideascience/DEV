/**
 * Test class for CreateMixMaxCampaignForLeadBatch
 */
@isTest
public class CreateMixMaxCampaignForLeadBatch_Test{
    
	/**
	 * TestSetup inserting required data for test class
	 */
	@TestSetup
	static void createTestData(){
		Lead objLead = new Lead(lastname = 'Test Contact', Email = 'test@lead.com',
                                Mixmax_Campaign_Name__c = 'My Campaign 001', MixMax_Create_Campaign__c = true);
		insert objLead;
		EmailIdforbatch__c objEmail = new EmailIdforbatch__c();
		objEmail.Name = 'Pratik';
		objEmail.Email__c = 'pratikd@proximabiz.com';
		insert objEmail;
	}

	/**
	 * executeBatch_Test : Test Method for batch class
	 */
	@isTest
	static void executeBatch_Test(){
		Lead lead = [SELECT Id
		             FROM Lead
		             LIMIT 1];
        
        //Test
		Test.startTest();
		CreateMixMaxCampaignForLeadBatch c = new CreateMixMaxCampaignForLeadBatch();
		Database.executeBatch(c);
		Test.stopTest();
        
        //Asserts
		System.assertEquals(true, ![SELECT Id
		                            FROM CampaignMember
		                            WHERE LeadId = :lead.Id].isEmpty(),'List must not be empty');
	}
}