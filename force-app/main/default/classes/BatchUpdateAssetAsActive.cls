/*
* This class updates the 'Status' field of Membership Asset to Purchased,Active or Expired 
  based on Install and Usage End date
* Test class : BatchReplaceAssetStatusTest
*/
public class BatchUpdateAssetAsActive implements Database.Batchable<sObject>,Schedulable{

    public String query;
    
	public BatchUpdateAssetAsActive(){}
    public BatchUpdateAssetAsActive (String query){
    
        if(query != null){
            this.query = query;
        }
	}  
	
	 //Schedule's Execute method to call batch
    public void execute(SchedulableContext sc){
        Database.executeBatch(new BatchUpdateAssetAsActive());
    }
      
    public Database.QueryLocator start(Database.BatchableContext BC){
		system.debug('________query_____'+Query);
		if(String.isBlank(query)){
            query='SELECT id,status,InstallDate, UsageEndDate, Product2.Family FROM Asset where Product2.Family = \'Membership\' AND status NOT IN'+
                '(\'Invoice Cancelled\',\'Associate Cancelled\',\'Expired\')'; 
        }
        //return
        return Database.getQueryLocator(query);
         
    }
        
    public void execute(Database.BatchableContext BC,List<Asset> scope ){
   
        system.debug(scope);
        List<Asset> updateAsset = new List<Asset>();
        for (Asset a : scope){
            if (a.UsageEndDate > System.Today() && a.InstallDate > System.Today() && a.status != 'Purchased'){
                a.status = 'Purchased';
                updateAsset.add(a);
            } else if (a.UsageEndDate > System.Today() && a.InstallDate <= System.Today() && a.status != 'Active'){
                a.status = 'Active';
                updateAsset.add(a);
            } else if (a.UsageEndDate < System.Today() && a.InstallDate < System.Today()){
                a.status = 'Expired';
                updateAsset.add(a);
            }
        }

        if (!updateAsset.isEmpty()){
            update updateAsset;
        }
    }
    
     public void finish(Database.BatchableContext info){
      
     }       

}