global Class SchedulePopulateAccountOnLeadBatch implements Schedulable{

    global void execute(SchedulableContext sc){
        PopulateAccountOnLeadBatch obj = new PopulateAccountOnLeadBatch();
        DataBase.executeBatch(obj,100); 
    }
}