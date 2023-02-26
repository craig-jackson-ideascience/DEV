trigger CampaignMemberRecordLogTrigger on Campaign_Member_Record_Log__c (before insert, before update,before delete,after delete, after insert,after update, after undelete) {
    TriggerDispatcher.run(new CampaignMemberRecordLogTriggerHandler());
}