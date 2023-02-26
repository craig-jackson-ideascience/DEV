trigger EMSTrigger on EMS__c (before insert, before update,before delete,after delete, after insert,after update, after undelete) {

    EMSTriggerHandler handler = new EMSTriggerHandler();
	TriggerDispatcher.Run(handler);
}