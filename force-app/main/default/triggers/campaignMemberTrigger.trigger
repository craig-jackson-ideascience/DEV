trigger campaignMemberTrigger on CampaignMember (before insert, before update,before delete,after delete, after insert,after update, after undelete) {

    if(Recursion.allowRecursion)
        return;
    Recursion.allowRecursion = false;
    campaignMemberTriggerHandler handler = new campaignMemberTriggerHandler();
        TriggerDispatcher.run(handler);

}