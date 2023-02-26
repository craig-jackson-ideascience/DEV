trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    TriggerDispatcher.run(new ContactTriggerHandler());
    /*if (trigger.isBefore){
        system.debug('#-BeforeDebug-#');
        if(trigger.isInsert && !LinuxTriggerUtilityClass.LeadTriggerActionOnceMore){
            ContactTriggerHandler.onBeforeInsert(Trigger.new);
            system.debug('#-ISBEFOREINSERT-#');
            LinuxTriggerUtilityClass.LeadTriggerActionOnceMore = true;
        }
        else if(trigger.isUpdate){
            system.debug('#-ISBEFOREUPDATE-#');
            ContactTriggerHandler.onBeforeUpdate(Trigger.newMap,Trigger.oldMap);
        }
        else if(trigger.isDelete){
            system.debug('#-ISBEFOREDELETE-#');
            ContactTriggerHandler.onBeforeDelete(trigger.old);
        }
    }else if(trigger.isAfter){
        if(trigger.isInsert){
            system.debug('#-ISAfterINSERT-#');
            ContactTriggerHandler.onAfterInsert(Trigger.newMap);

        }else if(trigger.isUpdate){
            system.debug('#-ISAfterUPDATE-#');
            ContactTriggerHandler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
            //ContactTriggerHandler.updateCampaign(Trigger.oldMap, Trigger.newMap);	
			            

        }else if(trigger.isDelete){
            ContactTriggerHandler.onAfterDelete(Trigger.oldMap);

        }else if(trigger.isUndelete){

        }
    }*/
}