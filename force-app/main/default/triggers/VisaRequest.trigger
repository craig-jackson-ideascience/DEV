trigger VisaRequest on Visa_Request__c (before insert, before update,after delete, after insert,after update, after undelete) {
    VisaRequestTriggerHandler handler = new VisaRequestTriggerHandler();
    TriggerDispatcher.Run(handler);
    
}