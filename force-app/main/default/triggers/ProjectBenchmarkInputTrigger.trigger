trigger ProjectBenchmarkInputTrigger on ProjectBenchmarkInput__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    ProjectBenchmarkInputTriggerHandler handler = new ProjectBenchmarkInputTriggerHandler();
    TriggerDispatcher.run(handler);
}