trigger Project_Trigger on Project__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if(Recursion.allowRecursion)
        return;
    Recursion.allowRecursion = false;
    
    Project_Handler handler = new Project_Handler();
    TriggerDispatcher.Run(handler);
    
   
   /* 
    if(trigger.isBefore && trigger.isUpdate){
        handler.beforeUpdate(trigger.oldMap , trigger.newMap);     
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        handler.afterUpdate(trigger.oldMap , trigger.newMap);
    }*/
        
    

}