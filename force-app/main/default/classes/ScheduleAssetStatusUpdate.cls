global Class ScheduleAssetStatusUpdate implements Schedulable{

    global void execute(SchedulableContext sc){
        
        BatchReplaceAssetStatus aoc = new BatchReplaceAssetStatus(null);
        Database.executeBatch(aoc);
    }
}