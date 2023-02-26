global class CurrentYearRevenueProjectBatchSchedular implements Schedulable {
   global void execute(SchedulableContext sc)

    {
  //  0 40 22 ? * * *
    CurrentYearRevenueProjectBatch b = new CurrentYearRevenueProjectBatch ();
    database.executebatch(b,50);

    }

 
}