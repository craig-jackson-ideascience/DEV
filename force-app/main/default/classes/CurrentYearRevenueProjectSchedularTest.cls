@isTest
public class CurrentYearRevenueProjectSchedularTest {
	@isTest
	public static void  testschedule() {
        Test.StartTest();
        CurrentYearRevenueProjectBatchSchedular sh1 = new CurrentYearRevenueProjectBatchSchedular();      
        String sch = '0 0 23 * * ?';
        String jobId = system.schedule('Test check', sch, sh1);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals('0 0 23 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
        
    }
}