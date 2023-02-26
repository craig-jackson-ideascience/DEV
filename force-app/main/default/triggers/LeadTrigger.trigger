//Test Class for trigger is--- TestLeadTrigger

trigger LeadTrigger on Lead (after insert, after update,before insert,before update,before delete, after delete) {

    LeadTriggerHandler handler=new LeadTriggerHandler();
    if(trigger.isBefore){
         if(trigger.isInsert){
             handler.beforeInsert(trigger.new);
             
         }
         if(trigger.isUpdate && !LinuxTriggerUtilityClass.LeadTriggerActionOnceMore){
             handler.beforeUpdate(trigger.oldmap,trigger.newmap);
           
         }
        if(trigger.isDelete){
            handler.beforeDelete(trigger.old);
        }
    }
    else{ 
    	if(trigger.isInsert && !LinuxTriggerUtilityClass.LeadTriggerActionOnceMore){
           handler.afterInsert(trigger.newMap);
          //  LinuxTriggerUtilityClass.LeadTriggerActionOnceMore = true;
           
        }
		system.Debug('-------LD1'+LinuxTriggerUtilityClass.LeadTriggerActionOnceMore);
        if(trigger.isUpdate && !LinuxTriggerUtilityClass.LeadTriggerActionOnceMore){
          handler.afterUpdate(trigger.oldmap,trigger.newmap);
            // LinuxTriggerUtilityClass.LeadTriggerActionOnceMore = true;
        }
        if(trigger.isDelete){
            handler.afterDelete(trigger.oldMap);
        }
    }

}