global class IndividualEmailCountOnParentScheduler implements schedulable{
global void execute (SchedulableContext st){
        
       UpdateIndividualEmailCountOnParent objUIECOP = new UpdateIndividualEmailCountOnParent();
        Database.executeBatch(objUIECOP);
     }
}