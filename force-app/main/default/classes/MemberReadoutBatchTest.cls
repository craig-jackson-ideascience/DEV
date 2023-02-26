@IsTest
public inherited sharing class MemberReadoutBatchTest{
    @TestSetup
    static void testSetup(){
        Account acc1 = new Account(Name = 'Test account', website = 'testing123.com1');
        insert acc1;

        List<COntact> listOfContact = new List<Contact>();
        for (Integer i = 0; i <= 2; i++){
            Contact contact = new Contact();
            contact.AccountId = acc1.Id;
            contact.LastName = 'Test ' + i;
            listOfContact.add(contact);
        }
        insert listOfContact;

        List<Member_Readout_Campaign__mdt> mdtg = [SELECT Id, Project_Id__c
                                                   FROM Member_Readout_Campaign__mdt];
        Asset asset = new Asset();
        asset.Name = 'Test Asset';
        asset.Number_of_Years_Required__c = 2;
        asset.AccountId = acc1.Id;
        asset.projects__c = mdtg[0].Project_Id__c;
        asset.status = 'Active';
        insert asset;

        List<Project_Role__c> listOfProjRoles = new List<Project_Role__c>();
        Project_Role__c projectrole = New Project_Role__c();
        projectrole.Contact__c = listOfContact[0].Id;
        projectrole.Asset__c = asset.Id;
        projectrole.Role__c = 'Technical Contact';
        projectrole.Status__c = 'Active';
        listOfProjRoles.add(projectrole);

        Project_Role__c projectrole1 = New Project_Role__c();
        projectrole1.Contact__c = listOfContact[1].Id;
        projectrole1.Asset__c = asset.Id;
        projectrole1.Role__c = 'Press Contact';
        projectrole1.Status__c = 'Active';
        listOfProjRoles.add(projectrole1);

        Project_Role__c projectrole2 = New Project_Role__c();
        projectrole2.Contact__c = listOfContact[2].Id;
        projectrole2.Asset__c = asset.Id;
        projectrole2.Role__c = 'Event Sponsorship';
        projectrole2.Status__c = 'Active';
        listOfProjRoles.add(projectrole2);

        insert listOfProjRoles;
    }

    @Istest
    static void testdata(){
        Test.startTest();
        Database.executeBatch(new MemberReadoutBatch());
        Test.stopTest();
        List<Member_Readout_Campaign__mdt> mdtg = [SELECT Id, Campaign_Id__c
                                                   FROM Member_Readout_Campaign__mdt];
        Id campaignId = mdtg[0].Campaign_Id__c;
        List<CampaignMember> cmList = [SELECT ID
                                       FROM CampaignMember
                                       WHERE CampaignId = :campaignId];
        System.assertEquals(3, cmList.size());
    }
}