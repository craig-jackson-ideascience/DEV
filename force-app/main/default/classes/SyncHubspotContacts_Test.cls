/********************************************************
 * Created by: CloudRoute @ CloudRoute Solutions
 * Created Date: 22/07/21.
 * Description: SyncHubspotContacts_Test
 ********************************************************/

@IsTest
public class SyncHubspotContacts_Test {

    @IsTest
    public static void testSync() {
        Lead l = new Lead();
        l.FirstName = 'Test Hubspot Lead';
        l.LastName = 'Test LastName';
        l.Email = 'test@lflead.com';
        insert l;

        Account a = new Account();
        a.Name = 'Test Hubspot Account';
        insert a;

        Contact c = new Contact();
        c.FirstName = 'Test Hubspot Contact';
        c.LastName = 'Test Contact LastName';
        c.Email = 'test@lfcontact.com';
        c.AccountId = a.Id;
        insert c;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SyncHubspotContactsMockTest());
        SyncHubspotContacts shc = new SyncHubspotContacts();
        shc.execute(null);
        Test.stopTest();
    }
}