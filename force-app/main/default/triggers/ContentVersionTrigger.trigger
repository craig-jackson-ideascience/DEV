trigger ContentVersionTrigger on ContentVersion (after insert, after update, before delete,before insert,before update,after delete, after undelete) {
 TriggerDispatcher.Run(new ContentVersionTriggerHandler());
}