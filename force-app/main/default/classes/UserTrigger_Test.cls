@isTest
public class UserTrigger_Test {
   @isTest  
    static void createTestMethod(){
        Account acc = new Account();
        acc.name = 'The Linux Foundation';
        //acclist.add(acc);
        insert acc;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1];
        //Creating User Record
        User u = new user();
        u.FirstName = 'Sunil';
        u.LastName = 'Chaudhary';
        u.Email = 'test@test.com';
        u.Alias = 'abcW';
        u.Username = 'abc@webuters.com';
        u.CommunityNickname = 'test12';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;  
      }
}