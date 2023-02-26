global class MixmaxEmailsSentCountOnParentScheduler implements schedulable {

    global void execute (SchedulableContext st){
        
       UpdateMixmaxEmailsSentCountOnParent objUMMESC = new UpdateMixmaxEmailsSentCountOnParent();
        Database.executeBatch(objUMMESC);
     }
}