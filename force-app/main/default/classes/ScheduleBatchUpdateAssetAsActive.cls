global Class ScheduleBatchUpdateAssetAsActive implements Schedulable{

    global void execute(SchedulableContext sc){
        
        BatchUpdateAssetAsActive obj = new BatchUpdateAssetAsActive(null);
        DataBase.executeBatch(obj); 
    }
}