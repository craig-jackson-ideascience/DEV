@istest
class CurrentYrSpdOnAccountBatchSchedularTest{
    public static testMethod void testscheduleMethod() {
        Test.StartTest();
        CurrentYearSpendOnAccountBatchSchedular testsche = new CurrentYearSpendOnAccountBatchSchedular();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}