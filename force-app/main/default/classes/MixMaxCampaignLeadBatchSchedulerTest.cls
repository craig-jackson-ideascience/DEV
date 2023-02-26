@isTest
public class MixMaxCampaignLeadBatchSchedulerTest {
    static testmethod  void testDataSetup(){
        String schTime = '0 0 12 * * ?';
        MixMaxCampaignLeadBatchScheduler schJob = new MixMaxCampaignLeadBatchScheduler();
        MixMaxCampaignContactBatchScheduler schjob1 = new MixMaxCampaignContactBatchScheduler();
        system.schedule('MixMaxCampaignLeadBatchScheduler', schTime, schJob);
        system.schedule('MixMaxCampaignContactBatchScheduler', schTime, schJob1);
    }
}