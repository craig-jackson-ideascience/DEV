trigger HotelCommissionsTrigger on Hotel_Commissions__c (before insert, before update,after delete, after insert,after update, after undelete) {
    HotelCommissionsTriggerHandler handler = new HotelCommissionsTriggerHandler();
    TriggerDispatcher.Run(handler);
}