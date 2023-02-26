global class BatchUpdatingAccountType implements Database.Batchable<sObject>{
    
    global String query='';
    
    global BatchUpdatingAccountType(String st){
    
        if(st != null){
            query = st;
        }
        else{
            //query='select id, Type, (select Id,status,AccountId from Assets ) from Account  where Type!=\'Former Customer\' ';
            query = 'SELECT Id, Type from Account  WHERE Type != \'Former Customer\' ';
        }  
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('________query_____'+Query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Account> scope){ 
        
        /*List<Account> accToBeUpdated=new List<Account>();      
        string accId = scope[0].Id;
        list<Asset> assetList = new List<Asset>([Select Id, Status, AccountId  from Asset Where AccountId =:accId]);
        list<Asset> expiredAssetList = new List<Asset>([Select Id from Asset Where AccountId =:accId And Status='Expired']);
        
        if(assetList.size() == expiredAssetList.size()){
            Account acc = new Account(Id=scope[0].Id, Type='Former Customer');
            accToBeUpdated.add(acc);
        }
        
        if(accToBeUpdated!=null && accToBeUpdated.size()>0){
            update accToBeUpdated;
        }*/
        
        if(!scope.isEmpty()) {
            BatchUpdatingAccountTypeHelper.updateAccounts(scope);
        }
        
    }
    
    global void finish(Database.BatchableContext dbc){} 
}