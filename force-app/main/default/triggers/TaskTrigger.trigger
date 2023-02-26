trigger TaskTrigger on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   TaskTriggerHandler handler = new TaskTriggerHandler();
    TriggerDispatcher.Run(handler);
}