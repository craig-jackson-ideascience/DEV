trigger QuoteLineItemTrigger on QuoteLineItem (before insert, before update,after delete, after insert,after update, after undelete) {
    QuoteLineItemTriggerHandler handler = new QuoteLineItemTriggerHandler();
    TriggerDispatcher.Run(handler);
}