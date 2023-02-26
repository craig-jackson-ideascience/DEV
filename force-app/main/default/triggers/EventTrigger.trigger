trigger EventTrigger on Event__c (before insert, before update,after delete, after insert,after update, after undelete) {
    EventTriggerHandler handler = new EventTriggerHandler();
    TriggerDispatcher.Run(handler);
}