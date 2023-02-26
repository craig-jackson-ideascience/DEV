trigger EventRegistrationTrigger on Event_Registrations__c (before insert, before update,after delete, after insert,after update, after undelete) {
    EventRegistrationTriggerHandler handler = new EventRegistrationTriggerHandler();
    TriggerDispatcher.Run(handler);
}