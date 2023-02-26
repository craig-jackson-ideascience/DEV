/*
 * Test Class - SyncRenewalAssetsToNetSuite_Test Class
 */
public class SyncRenewalAssetsToNetSuite  implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
 public Set<Id> OpportunityIds = new Set<Id>();
    
    public SyncRenewalAssetsToNetSuite(Set<Id> OpportunityIds){
        this.OpportunityIds = OpportunityIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT ID FROM Asset WHERE Opportunity__C IN :OpportunityIds AND NetSuite_ID__c = null AND Skip_NetSuite_Sync__c= False'+
            ' AND Opportunity__r.Amount != 0 ';
        return Database.getQueryLocator(query); 
    }
    
    public void execute(Database.BatchableContext bc, List<Asset> assets){
        for(Asset asset: assets){
            AssetSyncToNetSuiteController.validateAndSyncToNetSuite(asset.Id);
        }
    }

     public void finish(Database.BatchableContext bc){
     }
    

}