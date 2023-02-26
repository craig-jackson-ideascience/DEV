global Class SchedulePopulateAccountOnContactBatch implements Schedulable{

    global void execute(SchedulableContext sc){
        PopulateAccountOnContactBatch obj = new PopulateAccountOnContactBatch();
        DataBase.executeBatch(obj,100); 
    }
}