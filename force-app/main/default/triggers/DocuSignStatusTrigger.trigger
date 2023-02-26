trigger DocuSignStatusTrigger on dsfs__DocuSign_Status__c (before insert, before update,after delete, after insert,after update, after undelete) {
    DocuSignStatusTriggerHandler handler = new DocuSignStatusTriggerHandler();
    TriggerDispatcher.Run(handler);
}