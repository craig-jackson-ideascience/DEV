global Class ScheduleRenewalOpportunityCreationBatch implements Schedulable{

    global void execute(SchedulableContext sc){
        
        RenewalOpportunityCreationBatch obj = new RenewalOpportunityCreationBatch(null);
        DataBase.executeBatch(obj,1); 
    }
}