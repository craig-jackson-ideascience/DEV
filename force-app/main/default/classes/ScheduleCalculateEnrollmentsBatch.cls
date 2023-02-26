global Class ScheduleCalculateEnrollmentsBatch implements Schedulable{

    global void execute(SchedulableContext sc){
        CalculateEnrollmentsBatch obj = new CalculateEnrollmentsBatch();
        DataBase.executeBatch(obj,100); 
    }
}