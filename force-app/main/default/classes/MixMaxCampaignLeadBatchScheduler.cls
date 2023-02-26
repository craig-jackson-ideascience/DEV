global class MixMaxCampaignLeadBatchScheduler implements schedulable{
global void execute (SchedulableContext st){
        
       CreateMixMaxCampaignForLeadBatch objMMCLB = new CreateMixMaxCampaignForLeadBatch();
        Database.executeBatch(objMMCLB);
     }
}