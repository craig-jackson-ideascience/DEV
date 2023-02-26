trigger MeetingAttendeeTrigger on Meeting_Attendees__c (before insert, before update,before delete,after delete, after insert,after update, after undelete) {
   // EventTriggerHandler handler = new EventTriggerHandler();
    MeetingAttendeeTriggerHandler handler = new MeetingAttendeeTriggerHandler();
    TriggerDispatcher.Run(handler);
}