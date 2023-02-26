/*
* This class updates the 'IS Member' field to true if Account has atleast 1 active membership for any project.
* Test class : AccountIsMemberBatchTest
*/

public class AccountIsMemberBatch implements Database.Batchable<Sobject>,Schedulable{
    //variable
    public String query;
    
    //constrctor
    public AccountIsMemberBatch(){}
    public AccountIsMemberBatch(String query){
        if(query != null){
            this.query = query;
        }
    }
    
    //Schedule 's Execute method to call batch
    public void execute(SchedulableContext sc){
        Database.executeBatch(new AccountIsMemberBatch());
    }
    
    //Start of Batch
    public Database.QueryLocator start(Database.BatchableContext BC){
        //Get Individual-No AccountId to exclude it from query
        String individualNoAccountId = Label.Individual_No_Account;
        
        if(String.isBlank(query)){
            query ='SELECT ID,AccountID FROM ASSET WHERE LastModifiedDate =TODAY AND AccountId != null AND '+
                'AccountId !=: individualNoAccountId AND Product_Family__c = \'Membership\'';
        }
        //return
        return Database.getQueryLocator(query);
    }
    
    //Execute of Batch
    public void execute(Database.BatchableContext BC, List<Asset> assets){
        system.debug('assets '+assets.size());
        Set<Id> accountIds = new Set<Id>();
        List<Account> accounts = new List<Account>();
        //Iterate
        for(Asset asset: assets){
            accountIds.add(asset.AccountId);
        }
        if(!accountIDs.isEmpty()){
            //query accounts
            for(Account account : [SELECT ID,IsMember__c,(SELECT ID FROM Assets 
                                                          WHERE Status ='Active' AND 
                                                          Product_Family__c = 'Membership' LIMIT 1) 
                                   FROM Account WHERE ID IN: accountIds]
               ){
                   if(account.Assets.size() == 1 ){ 
                       if(!account.IsMember__c){
                           accounts.add(new Account(Id= Account.Id,IsMember__c = true));
                       }
                   }else if(account.IsMember__c){
                       accounts.add(new Account(Id= Account.Id,IsMember__c = false));
                   }
               }
        }
        
        if(!accounts.isEmpty()){
            system.debug('account '+accounts.size());
            update accounts;
        }
    }
    
    //Finish
    public void finish(Database.BatchableContext info){
    }
}