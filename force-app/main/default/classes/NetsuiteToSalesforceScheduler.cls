/*Test class : NetSuiteToSalesforce_Test
*/
global class NetsuiteToSalesforceScheduler implements schedulable
{
    global void execute(SchedulableContext sc)
    {
        
        NetSuiteToSalesforce batchSchedule = new NetSuiteToSalesforce(); 
        database.executebatch(batchSchedule);
    }
}