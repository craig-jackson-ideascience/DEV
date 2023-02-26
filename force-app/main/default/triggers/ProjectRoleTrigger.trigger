trigger ProjectRoleTrigger on Project_Role__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    ProjectRoleTriggerHandler handler = new ProjectRoleTriggerHandler();
    TriggerDispatcher.Run(handler);
}