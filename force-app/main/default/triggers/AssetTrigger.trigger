trigger AssetTrigger on Asset (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
     if (trigger.isBefore){
     	if(trigger.isInsert){
            AssetTriggerHandler.BeforeInsert(Trigger.new);
     	}else if(trigger.isUpdate){
            AssetTriggerHandler.BeforeUpdate(Trigger.newMap,Trigger.OldMap);
        }

//}else if(trigger.isDelete){
  
     }else if(trigger.isAfter){
        if(trigger.isInsert){
            AssetTriggerHandler.AfterInsert(Trigger.newMap);
        }else if(trigger.isUpdate){
            AssetTriggerHandler.AfterUpdate(Trigger.newMap,Trigger.OldMap);
        }else if(trigger.isDelete){
             AssetTriggerHandler.AfterDelete(Trigger.OldMap);
        }else if(trigger.isUndelete){
            
        }
    }

}