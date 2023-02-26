global class UpdateSobjectRecordsBatch implements Database.Batchable<sObject>,  Database.Stateful {

    global Map<String, String> websiteVsAccountID = new Map<String, String>();
    global Map<String, String> domainAliasVsDomain = new Map<String, String>();
    global Set<String> domainAlias = new Set<String>();
    global Boolean batchCalledFromWeekendSchedular = FALSE;
    global String objectName;
    
    global UpdateSobjectRecordsBatch(Map<String, String> domainAliasVsDomain, String objectName, Boolean batchCalledFromWeekendSchedular){
        this.objectName = objectName;
        this.domainAliasVsDomain = domainAliasVsDomain;
        this.batchCalledFromWeekendSchedular = batchCalledFromWeekendSchedular;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        domainAlias.addAll(domainAliasVsDomain.Values());
        String query = 'Select ID, Website FROM Account WHERE Website != NULL AND Website IN: domainAlias';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){
        for(Account accRec : scope){
            websiteVsAccountID.put(accRec.website.trim(), accRec.ID);
        }
    }       
    global void finish(Database.BatchableContext bc){
    }    
}