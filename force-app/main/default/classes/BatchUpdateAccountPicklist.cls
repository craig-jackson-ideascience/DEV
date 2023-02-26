public class BatchUpdateAccountPicklist implements Database.Batchable<sObject>,Schedulable, Database.AllowsCallouts {
    
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new BatchUpdateAccountPicklist());
    } 
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        //Query those Project which are active and Project Processing is true
        return Database.getQueryLocator('Select id, Name,Status__c,Project_Processing__c From Project__c WHERE Project_Processing__c = True');
    }
    
    public void execute(Database.BatchableContext bc,List<Project__c> scope ){
        
        //Add Project name against Id in a Map for updating Account Picklist value.
		Map<Id,String> projectIdVSName= new Map<Id,String>();   
        for(Project__c proj :scope){
            proj.Project_Processing__c = false;
            projectIdVSName.put(proj.Id,proj.Name);
        }
        
        //Call MetaData Api for inserting Project Name in Account.Project_Memberships__c Picklist field.
        if(!projectIdVSName.isEmpty()){
            System.debug('projectIdVSName' +projectIdVSName);
            MetadataUpdatePicklist.updatePicklistField(projectIdVSName);
        }
        
        update scope;
    }
    
    public void finish(Database.BatchableContext bc){
        
    } 
    
}