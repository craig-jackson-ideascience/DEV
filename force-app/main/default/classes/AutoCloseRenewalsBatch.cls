/*
 * Call this batch with size of 1,since netsuite sync is not bulikfied*/
//Test Class - AutoCloseRenewalsBatch_Test Class
public class AutoCloseRenewalsBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
    String query;
    Date opportunityClosedDate;
    
    public Set<Id> opportunityIds = new Set<Id>();
    
     public void execute(SchedulableContext sc){
        Database.executeBatch(new AutoCloseRenewalsBatch(),1);
    }
    
    public AutoCloseRenewalsBatch(){
        this.query = 'SELECT Id,StageName,CloseDate,Auto_Close_Error__c,Hold__c,Type,'+
        '(select id,dsfs__Envelope_Status__c from R00N80000002fD9vEAE__r where dsfs__Envelope_Status__c=\'Completed\')'+
        ' FROM Opportunity WHERE RecordType.Name =\'Membership\' AND'+
            ' Type LIKE \'Renewal%\' AND IsClosed = false AND Hold__c=false AND StageName != \'Stage 1\' AND CloseDate<=today';
    }
    
    public AutoCloseRenewalsBatch(String query){
        if(query != null){
            this.query = query;
        }
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
     public void execute(Database.BatchableContext bc, List<Opportunity> opportunities){
         List<String> renewalTypeList = new List<String>{'Renewal','Renewal - Downgrade'};
         List<Opportunity> opportunityToUpdate = new List<Opportunity>();
         for(Opportunity opportunity : opportunities){
             if((opportunity.Type == 'Renewal - Upgrade' && opportunity.R00N80000002fD9vEAE__r.size() > 0) || 
             (renewalTypeList.contains(opportunity.Type)) && 
             !opportunity.Hold__c){
                opportunityToUpdate.add(new Opportunity(Id=opportunity.Id,StageName = 'Closed Won'));
             }  
             }
             if(!opportunityToUpdate.isEmpty()){
                List<Database.SaveResult> results = Database.update(opportunityToUpdate,false);//Auto_Close_Error__c              
                Integer index =0; 
                List<Opportunity> errorOpps = new List<Opportunity>();
                for(Database.SaveResult result : results){                
                    if(!result.isSuccess()){
                        String errorMessage ='';
                        for(Database.Error err : result.getErrors()) {
                            errorMessage+= err.getMessage();
                        }                     
                        errorOpps.add(new Opportunity(Id= opportunities[index].Id,Auto_Close_Error__c = errorMessage));
                    }
                    else{
                        //for all successful opps get assets and sync it with netsuite
                        opportunityIds.add(result.getId());
                    }
                    index++;
                }            
                if(!errorOpps.isEmpty()){
                    Database.update(errorOpps,false);
                }
             }
             
         }
    
    
    public void finish(Database.BatchableContext bc){
        if(!opportunityIds.IsEmpty() && !Test.isRunningTest()){
            SyncRenewalAssetsToNetSuite sync = new SyncRenewalAssetsToNetSuite(OpportunityIds);
            Database.executeBatch(sync,1);
        }
    }

}