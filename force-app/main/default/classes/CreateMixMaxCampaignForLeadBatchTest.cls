@isTest
public class CreateMixMaxCampaignForLeadBatchTest{
	static testmethod void testDataSetup(){

		Lead objLead = new Lead(lastname = 'Test Contact', Mixmax_Campaign_Name__c = 'My Campaign 001', MixMax_Create_Campaign__c = true, Email = 'test@test.com');
		insert objLead;
		EmailIdforbatch__c objEmail = new EmailIdforbatch__c();
		objEmail.Name = 'Pratik';
		objEmail.Email__c = 'pratikd@proximabiz.com';
		insert objEmail;

		Test.startTest();

		CreateMixMaxCampaignForLeadBatch c = new CreateMixMaxCampaignForLeadBatch();
		Database.executeBatch(c);

		Test.stopTest();
	}
}