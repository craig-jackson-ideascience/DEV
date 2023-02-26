global class RecycleLeadContactAndCloseTask{

    webService static void recycleAndClose(Id taskId , Id leadOrContactId){
        
        String str_LeadOrContactId = leadOrContactId;
        String str_taskId = taskId;
        
        // If task is associated to a contact then status of contact is set as Recycled and task is closed
        if(str_LeadOrContactId.startsWith('003')){
            Contact contactToRecycle = new Contact(Id=Id.valueOf(str_LeadOrContactId) , Status__c='Recycled');
            update contactToRecycle;
                        
            Task taskToClose = new Task(Id=Id.valueOf(str_taskId), Status='Completed');
            update taskToClose;
            
        }// If task is associated to a lead then status of lead is set as Recycled and task is closed
        else if(str_LeadOrContactId.startsWith('00Q')){
            Lead leadToRecycle = new Lead(Id=Id.valueOf(str_LeadOrContactId) , Status='Recycled');
            update leadToRecycle;
            
            Task taskToClose = new Task(Id=Id.valueOf(str_taskId), Status='Completed');
            update taskToClose;

        }
    }

}