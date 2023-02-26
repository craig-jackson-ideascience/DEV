trigger MeetingTrigger on Meeting__c (before insert, before update,before delete,after delete, after insert,after update, after undelete) {
    
    MeetingTriggerHandler handler = new MeetingTriggerHandler();
    TriggerDispatcher.Run(handler);

}