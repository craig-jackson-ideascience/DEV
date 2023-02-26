trigger AccountTeamMemberTrigger on AccountTeamMember (before insert, before update,before delete,after delete, after insert,after update, after undelete) {
     AccountTeamMemberTriggerHandler handler = new AccountTeamMemberTriggerHandler();
    TriggerDispatcher.run(handler);
}