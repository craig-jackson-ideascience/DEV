global class UpdateCampaignBatchScheduler implements schedulable{
global void execute (SchedulableContext st){
        MixmaxContactLeadUpdateCampaignBatch MCLUCB = new MixmaxContactLeadUpdateCampaignBatch();
        Database.executeBatch(MCLUCB);
     }

}