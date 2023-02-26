trigger AccountProjectBenchmarkItemTrigger on AccountProjectBenchmarkItem__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    AccountProjBenchmarkItmTriggerHandler handler = new AccountProjBenchmarkItmTriggerHandler();
    TriggerDispatcher.run(handler);
}