trigger TravelFundRequestTrigger on Travel_Fund_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TravelFundRequestTriggerHandler c = new TravelFundRequestTriggerHandler();
    system.debug(c);
    TriggerDispatcher.Run(c);
    
}