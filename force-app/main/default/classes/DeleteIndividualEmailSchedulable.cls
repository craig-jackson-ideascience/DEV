global class DeleteIndividualEmailSchedulable implements schedulable {
    global void execute (SchedulableContext st){
        
       DeleteIndividualEmail die = new DeleteIndividualEmail();
        Database.executeBatch(die);
     }
}