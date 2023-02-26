global class BatchUpdateAssetMembershipDocURL implements Database.Batchable<sObject>,Database.Stateful{

    global String query='';
    
    global BatchUpdateAssetMembershipDocURL (String st){
      system.debug('query '+st);
        if(st != null && st != ''){
           
        system.debug('query '+st);
       
         query = st;
        }
        else{
            query='select id, name, Membership_Doc_Download_URL__c, AccountId, Project_Name__c   from opportunity where recordtype.name = \'Membership\' and isWon = true and Membership_Doc_Download_URL__c = null order by createddate';
        }  
    }
      
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('________query_____'+Query);
        system.debug('____date_____'+String.Valueof(Date.today()));
        return Database.getQueryLocator(query);
    }
        
    global void execute(Database.BatchableContext BC,List<Opportunity> scope ){
        
                
        system.debug('Scope--->'+scope);
        List<Opportunity> updateOpps =new List<Opportunity>();
        set<string> setMembershipOpps = new set<string>();
        
        for(opportunity opp : scope){            
            setMembershipOpps.add(string.valueOf(opp.id));
        }
        
        //find contentdistribution record of membership document using opportunity id
        //Note: fully executed membership documents are the only documents that have a contentdistribution record
        list<contentdistribution> cds = [select id, name, ContentDocumentId, ContentVersionId, ContentDownloadUrl, contentversion.firstpublishlocationid 
                                        from contentdistribution 
                                        where contentversion.firstpublishlocationid in :setMembershipOpps] ;
        
        map<string,string> oppvsDLURL = new map<string,string>();
    
        if(!cds.isEmpty()){
            for(contentdistribution cd : cds ) {
                if(cd.ContentDownloadUrl != null ){                    
                    oppvsDLURL.put(string.valueOf(cd.contentversion.firstpublishlocationid), cd.ContentDownloadUrl);
                }                
            }            
        }
        
        //populate Opp.membershipdocURL 
        for(opportunity opp : scope){
            if(oppvsDLURL.containsKey(string.valueOf(opp.id))){
                opp.Membership_Doc_Download_URL__c = oppvsDLURL.get(string.valueOf(opp.id));
                updateOpps.add(opp);
            }  
        }
        
        
       
        system.debug('updateOpps: ' + updateOpps);
        if(!updateOpps.isEmpty()){ 
            Database.SaveResult[] srList = Database.update(updateOpps, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Opportunity fields that affected this error: ' + err.getFields());
                    }
                }
            }   
        }
    
    }
    
     global void finish(Database.BatchableContext info){
       
     }       

}