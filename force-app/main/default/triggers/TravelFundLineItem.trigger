trigger TravelFundLineItem on Travel_Fund_Request_Line_Item__c (before insert,after insert,after update,before delete) {
	TravelFundLineItemHandler handler = new TravelFundLineItemHandler();
    if(trigger.isafter){
        if(trigger.isinsert){
            handler.afterInsert(null,trigger.newMap);
        }
        if(trigger.isupdate){
            handler.afterUpdate(trigger.oldMap,trigger.newMap);
        }
    }
    
    if(trigger.isbefore){
         if(trigger.isdelete){
              handler.onAfterDelete(trigger.Oldmap);
             //handler.travelLineItemUpdate(trigger.old);
         }
    }
}