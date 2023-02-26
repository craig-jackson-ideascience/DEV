public with sharing class DisplayAssets {
    
    public String strID;
    public boolean mainpage{ get; set; }
    public List<Asset> assetsList {get;set;}
    public List<Asset> allAssetsList {get;set;}
    Set<id> accountIdSet= new Set<Id>();
    
    public String  query ;  
        
    public DisplayAssets (ApexPages.StandardController controller) {
        
        assetsList = new List<Asset>();
        allAssetsList = new List<Asset>();
        strID = String.valueOf(ApexPages.currentPage().getParameters().get('Id')); 
        
    }
    
    public void assetsListMethod() {
        
        System.debug('$$$$$$$$$$$'+strID);
        
        /**
        Fetch all Asset with current project  
            * */

        if(strID.startsWith(System.Label.ProjectsStartingID)){
            
            query='Select  Id, Name, AccountId, Account.Name, Tier__c, UsageEndDate, Product2Id,Product2.name, Price,PurchaseDate, InstallDate, Description, Year__c, OpportunityLineItem__c, Projects__c, Training__c, Event__c from Asset where Projects__c=:strID AND InstallDate < = TODAY AND UsageEndDate >= TODAY  AND STATUS = \'Active\'';
            system.debug('query'+query);
            assetsList=assetsRecords(query);
            system.debug('assetsList'+assetsList);
            allAssetsList=allassetsRecords(query);
            
        }
        
        /**
        Fetch all Asset with current Event  
        * */
        else if(strID.startsWith(System.Label.EventsStartingID)){
            query='Select  Id, Name, AccountId, Account.Name, Tier__c, UsageEndDate, Product2Id, Product2.name, Price, PurchaseDate,InstallDate, Description, Year__c, OpportunityLineItem__c, Projects__c, Training__c, Event__c from Asset where Event__c =:strID AND InstallDate < = TODAY AND UsageEndDate >= TODAY AND STATUS = \'Active\' ';
            system.debug('assetsList'+assetsList);
            assetsList=assetsRecords(query);
            allAssetsList=allassetsRecords(query);
            
        }
        /**
        Fetch all Asset with current Training  
        * */
        else if(strID.startsWith(System.Label.TrainingStartingID)){
            
            query='Select Id, Name, AccountId, Account.Name, Tier__c, UsageEndDate, Product2Id, Product2.name, Price, PurchaseDate, Description, Year__c, OpportunityLineItem__c, Projects__c, Training__c, Event__c from Asset where Training__c=:strID AND InstallDate < = TODAY AND UsageEndDate >= TODAY  AND STATUS = \'Active\'';
            assetsList=assetsRecords(query);
            system.debug('assetsList'+assetsList);

            allAssetsList=allassetsRecords(query);
            
        }
        
    }
    
    /**
    return Asset fields corresponding Asset
    * */
    public List<Asset> assetsRecords(String query1) {
        
        if(!ApexPages.currentPage().getParameters().containsKey('main')){ 
            
            query1 += ' limit 10';
            
        } 
        
        System.debug('@@@@@'+query1);
        List<Asset> assetRecords =database.query(query1);
        System.debug('==='+assetRecords.size());
        return assetRecords;
        
    }
    Public List<Asset> allassetsRecords(String query1){
        
        System.debug('@@@@@'+query1);
        mainpage=true;
        
        if(!ApexPages.currentPage().getParameters().containsKey('main')){ 
            
            mainpage=false;
            
        }
        
        List<Asset> assetRecords =database.query(query1);
        System.debug('==='+assetRecords.size());
        return assetRecords;
    }
    
    
}