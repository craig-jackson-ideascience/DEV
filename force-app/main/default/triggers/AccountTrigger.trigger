trigger AccountTrigger on Account (before insert, before update,before delete,after delete, after insert,after update, after undelete) {

    AccountTriggerHandler handler = new AccountTriggerHandler();
	TriggerDispatcher.Run(handler);
    
    /*if(Trigger.isUpdate && Trigger.isbefore && !LinuxTriggerUtilityClass.LeadTriggerActionOnceMore){
        handler.beforeUpdate(Trigger.newMap,Trigger.oldMap);
        LinuxTriggerUtilityClass.LeadTriggerActionOnceMore = true;
    }*/
}