@isTest
public class IndividualEmailCountSchedulerTest {

    static testmethod  void testDataSetup(){
        String schTime = '0 0 12 * * ?';
        IndividualEmailCountOnParentScheduler schJob = new IndividualEmailCountOnParentScheduler();
        system.schedule('IndividualEmailCountOnParentScheduler', schTime, schJob);
    }
}