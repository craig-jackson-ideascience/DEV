@isTest
public class UpdateCampaignBatchSchedulerTest {
 static testmethod  void testDataSetup(){
        String schTime = '0 0 12 * * ?';
        UpdateCampaignBatchScheduler schJob = new UpdateCampaignBatchScheduler();
        system.schedule('UpdateCampaignBatchScheduler', schTime, schJob);
    }
}