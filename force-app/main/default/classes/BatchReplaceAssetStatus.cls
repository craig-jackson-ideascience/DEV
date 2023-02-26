/*
* This class updates the 'Status' field of Asset to Expired or Completed based on Usage End Date for Membership, Alternate Funding
, Event and Training Related Assets.
* Test class : BatchReplaceAssetStatusTest
*/
public class BatchReplaceAssetStatus implements Database.Batchable<sObject>,Schedulable{

    public String query;
    
	public BatchReplaceAssetStatus(){}
    public BatchReplaceAssetStatus (String query){
    
        if(query != null){
            this.query = query;
        }
	}  
	
	 //Schedule's Execute method to call batch
    public void execute(SchedulableContext sc){
        Database.executeBatch(new BatchReplaceAssetStatus());
    }
      
    public Database.QueryLocator start(Database.BatchableContext BC){
		system.debug('________query_____'+Query);
        system.debug('____date_____'+String.Valueof(Date.today()));
		if(String.isBlank(query)){
            query='SELECT id,status,UsageEndDate,Product2.Family FROM Asset WHERE status NOT IN (\'Completed\',\'Invoice Cancelled\', \'Expired\', \'Associate Cancelled\') '+
                'AND UsageEndDate <' +String.Valueof(Date.today()); 
        }
        //return
        return Database.getQueryLocator(query);
         
    }
        
    public void execute(Database.BatchableContext BC,List<Asset> scope ){
   
        system.debug(scope);
        List<Asset> updateAsset =new List<Asset>();
        
        for(Asset a:scope){
            if(a.UsageEndDate < system.Today() && (a.Product2.Family == 'Membership' || a.Product2.Family == 'Alternate Funding')){
                a.status ='Expired';
                updateAsset.add(a);
            }else if(a.UsageEndDate < system.Today() && ( a.Product2.Family == 'Event' ||  a.Product2.Family == 'Training')){
                a.status ='Completed';
                updateAsset.add(a);    
            
            }
        }
        
        if(!updateAsset.isEmpty()){    
            update updateAsset; 
        }
    }
    
     public void finish(Database.BatchableContext info){
         if(!Test.isRunningTest()){
             BatchUpdatingAccountType batchObj = new BatchUpdatingAccountType(null);
        	 Database.executeBatch(batchObj,1);
         }
     }       

}