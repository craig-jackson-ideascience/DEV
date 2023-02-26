@isTest
public class SchedulerForCaseBatchTest {

    public static testMethod void testschedule() {
        Test.StartTest();
        SchedulerForCaseBatch sh1 = new SchedulerForCaseBatch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('SchedulerForCaseBatch', sch, sh1);
        Test.stopTest(); 
    }
}