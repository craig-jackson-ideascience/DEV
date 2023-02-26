trigger UserTrigger on User (after insert) {
    
    // check if Trigger is after and Insert only
    if(trigger.isAfter&&trigger.isInsert){
      List<String> userIds=new List<String>();
        for(user usrRecord :trigger.new){
         userIds.add(usrRecord.id);
           
          
        }
         Utils.createContact(userIds);
    }
}