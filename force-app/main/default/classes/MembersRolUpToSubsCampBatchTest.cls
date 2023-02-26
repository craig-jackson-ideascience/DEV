@IsTest
private class MembersRolUpToSubsCampBatchTest{
	@TestSetup
	static void testSetup(){
		List<Campaign> listOfCampaign = new List<Campaign>();
		Project__c testProject = TestFactory.getProject();
        Account testAccount = TestFactory.getAccount();
		for (Integer i = 0; i <  = 5; i++){
			Campaign campaign = new Campaign(Name = 'Test Campaign', IsActive = true, Status = 'In Progress', Description = 'TestCampaign', Do_Not_Include_in_Master_Subscriber_List__c = false, Project__c = testProject.Id);
			if (i == 0){
				campaign.Type = 'Subscription Center';
			} else{
				campaign.Type = 'MixMax';
			}
			listOfCampaign.add(campaign);
		}
		insert listOfCampaign;
		List<CampaignMember> listOfCampaignMember = new List<CampaignMember>();
        List<Contact> listOfContact = new List<Contact>();
		for (Integer i = 0; i <= 5; i++) {
            Contact contact = new Contact();
            contact.AccountId = testAccount.Id;
            contact.LastName = 'Test ' + i;
            listOfContact.add(contact);
        }
        insert listOfContact;
		for (Integer i = 0; i <  = 5; i++){
			CampaignMember campaignMember = new CampaignMember();
			campaignMember.CampaignId = listOfCampaign[i].Id;
			campaignMember.ContactId = listOfContact[i].Id;
			listOfCampaignMember.add(campaignMember);
		}
		insert listOfCampaignMember;
	}

	@IsTest
	static void execeuteBatchTest(){
		Test.startTest();
        MembersRollUpToSubscriptionCampaignBatch schedule = new MembersRollUpToSubscriptionCampaignBatch();
		schedule.execute(null);
		Test.stopTest();
		System.assertEquals(6, [SELECT count()
		                        FROM CampaignMember
		                        WHERE Campaign.Type = 'Subscription Center']);
	}
}