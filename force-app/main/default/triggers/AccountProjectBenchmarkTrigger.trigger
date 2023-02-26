trigger AccountProjectBenchmarkTrigger on AccountProjectBenchmark__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    AccountProjBenchmarkTriggerHandler handler = new AccountProjBenchmarkTriggerHandler();
    TriggerDispatcher.run(handler);
}