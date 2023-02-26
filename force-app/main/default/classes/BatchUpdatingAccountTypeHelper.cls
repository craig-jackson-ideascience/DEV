public with sharing class BatchUpdatingAccountTypeHelper { 

    public static void updateAccounts(List<Account> accList) {
        Map<Id, Account> idVsAccount = new Map<Id, Account>(accList);
        List<Account> updateAccounts = new List<Account>();
        
        Set<Id> expiredAssetAccIDs = getAccIDsOfExpiredAsset(idVsAccount.keySet());
        Set<Id> accIdOfOpenOps = getAccIdsOfOpps(idVsAccount.keySet());
        
        System.debug('expiredAssetAccIDs--->'+expiredAssetAccIDs);
        System.debug('accIdOfOpenOps--->'+accIdOfOpenOps);
        
        for(Id accId : idVsAccount.keySet()) {
            if(expiredAssetAccIDs != NULL && accIdOfOpenOps != NULL &&!accIdOfOpenOps.contains(accId) && expiredAssetAccIDs.contains(accId)){
                Account accRec = new Account();
                accRec = idVsAccount.get(accId);
                accRec.Type = 'Former Customer';
                updateAccounts.add(accRec);
            }
        }

        if(!updateAccounts.isEmpty()) {
            update updateAccounts;
        }
        
    }

    public static Set<ID> getAccIDsOfExpiredAsset(Set<Id> accIds) {
        
        Map<String, List<Asset>> accIdVsAssets = new Map<String, List<Asset>>();
        Set<Id> expiredAccounts = new Set<ID>();
        System.debug('accIds---->'+accIds);
        List<Asset> assetList = new List<Asset>([Select Id, Status, AccountId  from Asset Where AccountId IN: accIds AND Status != NULL limit 20000]);
        
        for(Asset assetRec : assetList) {

            if(accIdVsAssets.containsKey(assetRec.AccountId)) {
                accIdVsAssets.get(assetRec.AccountId).add(assetRec);
            }
            else {
                accIdVsAssets.put(assetRec.AccountId, new List<Asset> {assetRec});
            }
        }

        if(!accIdVsAssets.isEmpty()) {
            for(Id accID : accIdVsAssets.keySet()) {
                List<Asset> assetRecs = accIdVsAssets.get(accID);
                Boolean isExpired = False;
                Boolean isOpen = False;
                for(Asset assetRec : assetRecs) {
                    System.debug('Status===>'+assetRec.status);
                    if(assetRec.status.equals('Expired')){
                       isExpired = True ;
                    }
                    else if(assetRec.status.equals('Active') || assetRec.status.equals('Purchased')) {
                        isOpen = True;
                    }
                }

                if(isExpired && !isOpen) {
                    expiredAccounts.add(accID);
                }
            }

        }
        return expiredAccounts;
    }

    public static Set<ID> getAccIdsOfOpps(Set<ID> accIds){
        Set<ID> accIdsWithOpps = new Set<ID>();
        List<Opportunity> oppList = [Select ID, AccountId from Opportunity WHERE StageName != 'Closed Won' AND AccountID IN: accIds limit 20000];

        for(Opportunity oppRec : oppList) {
            accIdsWithOpps.add(oppRec.AccountId);
        }
        return accIdsWithOpps;
    }

}