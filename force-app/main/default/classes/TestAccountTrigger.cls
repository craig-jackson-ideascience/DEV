@isTest
public class TestAccountTrigger{

    static testmethod void testTrigger(){
        
        Account acc = new Account(Name = 'Test account' , billingStreet = 'street');
        insert acc;
                
        User u = insertStandardUser(UserInfo.getProfileId());
            
        acc.OwnerId=u.Id;
        update acc;
        Contact contact = new Contact(LastName='Test',Email='personaccount@noreply.com',AccountId= acc.Id);
        insert contact;
        System.assertEquals(1,[Select count() FROM Alternate_Email__c WHERE Alternate_Email_Address__c ='personaccount@noreply.com']);
        delete acc;
        System.assertEquals(0,[Select count() FROM Alternate_Email__c WHERE Alternate_Email_Address__c ='personaccount@noreply.com']);
    }
    
    static String getUserNamePrefix(){

        return UserInfo.getOrganizationId() + System.now().millisecond();

    }
    
    static User insertStandardUser(Id standardProfileId){

        // assert standardProfileId valid

        User standardUser = new User(
            Username = getUserNamePrefix() + 'standarduser@testorg.com',
            Alias = 'standt',
            email = 'standarduser@testorg.com',
            emailencodingkey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardProfileId,
            TimeZoneSidKey = 'America/Los_Angeles'
        );

        insert standardUser;

        return standardUser;
    }
  
    @isTest
    public static void updateAddressObjForAccount_Test(){
        Account objAcc = new Account();
        objAcc.Name='Test Account';
        objAcc.BillingStreet ='Test street';
        objAcc.BillingCity ='Test city';
        objAcc.BillingState='Test state';
                objAcc.BillingPostalCode ='147852';
                objAcc.BillingCountry='Test';
        insert objAcc;

        Address__c objAddress = new Address__c();
        objAddress.Account__c =objAcc.id;
        objAddress.Street__c =objAcc.billingstreet;
                objAddress.City__c=objAcc.billingcity;
                objAddress.State__c=objAcc.billingstate;
                objAddress.Country__c=objAcc.billingcountry;
                objAddress.Zip_Postal_Code__c=objAcc.billingpostalcode;
        insert objAddress;
        System.debug(objAddress.Address__c);
        Test.startTest();
        objAcc.BillingStreet = 'VIP Store';
        update objAcc;
        Test.stopTest();
        System.assertEquals('VIP Store',[SELECT Id,Street__c from Address__c Where Id=:objAddress.id].street__c);
    }
    
    @isTest
    static void testUpdateSector(){
        Account acc = new Account(Name = 'Test account' , billingStreet = 'street');
        insert acc;
        Contact con = new Contact(LastName = 'testCon', email = 'test333@testing123.com1',AccountId=acc.id);
        insert con;
        acc.No_Of_Employess__c ='100';
         acc.Industry = 'Professional Services';
        acc.Sector__c='Industrials';
        update acc;
        System.assertEquals('Professional Services',[SELECT Id,Sector__c from Account Where Id=:acc.id].Sector__c);
  
    }
}