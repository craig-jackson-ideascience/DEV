@isTest
public class MixmaxEmailsSentCountSchedulerTest {
    static testmethod  void testDataSetup(){
        String schTime = '0 0 12 * * ?';
        MixmaxEmailsSentCountOnParentScheduler schJob = new MixmaxEmailsSentCountOnParentScheduler();
        system.schedule('MixmaxEmailsSentCountOnParentScheduler', schTime, schJob);
    }
}