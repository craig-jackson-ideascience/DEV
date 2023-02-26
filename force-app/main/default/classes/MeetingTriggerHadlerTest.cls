@isTest
public class MeetingTriggerHadlerTest {
    public static testmethod void TestDataSetup(){
        Meeting__c objMeeting = new Meeting__c(
            Name='Test Meeting 1',
            Subject__c='Test Subject',
            Meeting_Detail__c='Discussion',
            StartDate__c=Date.today(),
            EndDate__c=Date.today(),
            Type__c ='Webinar',
            StartTime__c=Time.newInstance(18, 30, 2, 00),
            EndTime__c=Time.newInstance(19, 30, 2, 00));
        insert objMeeting;
        System.assertEquals(1, [SELECT count() FROM Campaign]);
        objMeeting.Descritpion__c = 'This is test';
        update objMeeting;
        System.assertEquals('This is test', [SELECT Description FROM Campaign LIMIT 1].Description);
        delete objMeeting;
    }
}