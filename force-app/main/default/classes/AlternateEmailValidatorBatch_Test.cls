/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 09-10-2019.
 * Description: AlternateEmailValidatorBatch_Test
 ********************************************************/
@IsTest
private class AlternateEmailValidatorBatch_Test {
    @testSetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new EmailValidatorHttpMock(false));

        List<Alternate_Email__c> aeList = new List<Alternate_Email__c>();
        for (integer i = 0; i <= 99; i++) {
            aeList.add(new Alternate_Email__c(Alternate_Email_Address__c = 'test' + i + '@test.com'));
        }
        insert aeList;
    }

    @isTest
    static void runBatchtest() {
        Test.setMock(HttpCalloutMock.class, new EmailValidatorHttpMock(false));
        Test.startTest();
        Database.executeBatch(new AlternateEmailValidatorBatch(), 100);
        Test.stopTest();
    }

    @isTest
    static void runBatch1test() {
        Test.setMock(HttpCalloutMock.class, new EmailValidatorHttpMock(false));

        Map<Id, Alternate_Email__c> aeMap = new Map<Id, Alternate_Email__c>([SELECT Id FROM Alternate_Email__c LIMIT 10]);
        List<Id> aeIdsList = new List<Id>();
        aeIdsList.addAll(aeMap.keySet());
        Test.startTest();

        Database.executeBatch(new AlternateEmailValidatorBatch(aeIdsList), 100);
        Test.stopTest();
    }
    @isTest
    static void runBatch2test() {
        Test.setMock(HttpCalloutMock.class, new EmailValidatorHttpMock(false));

        Test.startTest();
        Database.executeBatch(new AlternateEmailValidatorBatch(' LIMIT 1 '), 100);
        Test.stopTest();
    }

    @isTest
    static void runBatchErrortest() {
        Test.setMock(HttpCalloutMock.class, new EmailValidatorHttpMock(true));

        Test.startTest();
        Database.executeBatch(new AlternateEmailValidatorBatch(' LIMIT 1 '), 100);
        Test.stopTest();
    }
}