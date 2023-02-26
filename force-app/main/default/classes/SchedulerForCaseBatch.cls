global class SchedulerForCaseBatch implements Schedulable {
   global void execute(SchedulableContext sc) {
      CaseBatchApex b = new CaseBatchApex(); 
      database.executebatch(b);
   }
}