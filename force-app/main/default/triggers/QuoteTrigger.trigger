trigger QuoteTrigger on Quote (before insert, before update,after delete, after insert,after update, after undelete) {
    QuoteTriggerHandler handler = new QuoteTriggerHandler();
    TriggerDispatcher.Run(handler);
}