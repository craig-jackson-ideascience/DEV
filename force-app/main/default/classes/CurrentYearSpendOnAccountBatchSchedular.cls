global class CurrentYearSpendOnAccountBatchSchedular implements Schedulable {
   global void execute(SchedulableContext sc)

    {
  //  0 40 22 ? * * *
    CurrentYearSpendOnAccountBatch b = new CurrentYearSpendOnAccountBatch ();
    database.executebatch(b,200);

    }

 
}