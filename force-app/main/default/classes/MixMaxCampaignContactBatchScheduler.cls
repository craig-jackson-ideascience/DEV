global class MixMaxCampaignContactBatchScheduler implements schedulable{
global void execute (SchedulableContext st){
        
       CreateMixMaxCampaignForContactBatch objMMCCB = new CreateMixMaxCampaignForContactBatch();
        Database.executeBatch(objMMCCB);
     }
}