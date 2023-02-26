trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CaseTriggerHandler handler = new CaseTriggerHandler();
    TriggerDispatcher.run(handler);
}