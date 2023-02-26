trigger ProjectMembershipBenchmarkTrigger on ProjectMembershipBenchmark__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    ProjectMembershipBenchmarkTriggerHandler handler = new ProjectMembershipBenchmarkTriggerHandler();
    TriggerDispatcher.run(handler);
}