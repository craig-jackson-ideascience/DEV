global Class ScheduleUpdateStatusOfAssetsBatch implements Schedulable{

    global void execute(SchedulableContext sc){
        UpdateStatusOfAssetsBatch obj = new UpdateStatusOfAssetsBatch ();
        DataBase.executeBatch(obj,100); 
    }
}