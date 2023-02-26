trigger OpportunityTrigger on Opportunity (after insert, after update, before delete,before insert,before update,after delete, after undelete) {
    
    TriggerDispatcher.Run(new OpportunityHandler());
}