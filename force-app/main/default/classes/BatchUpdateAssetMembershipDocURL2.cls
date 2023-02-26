global class BatchUpdateAssetMembershipDocURL2 implements Database.Batchable<sObject>,Database.Stateful{

    global String query='';
    
    global BatchUpdateAssetMembershipDocURL2 (String st){
      system.debug('query '+st);
        if(st != null && st != ''){
           
        system.debug('query '+st);
       
         query = st;
        }
        else{
            query='select id, name, Membership_Doc_Download_URL__c, type, Parent_Asset__r.Membership_Doc_Download_URL__c, Parent_Asset__r.opportunity__c,Parent_Asset__r.opportunity__r.Parent_Asset__r.Membership_Doc_Download_URL__c,Parent_Asset__r.opportunity__r.Parent_Asset__r.opportunity__c ' +  
                                           ' from opportunity ' +
                                           ' where Membership_Doc_Download_URL__c = null ' +
                                           ' and recordtype.name = \'Membership\' and type like \'Renewal%\' order by createddate';
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
        
        Map<id,Opportunity> mapUpdateOpps = new Map<id,Opportunity>();
        
        set<string> setMembershipOpps = new set<string>();
        
        for(Opportunity opp : scope){            
            //setMembershipOpps.add(string.valueOf(opp.id));
            Opportunity firstlevelupOPP = new Opportunity();
            Opportunity secondlevelupOPP = new Opportunity();
            if(opp.Parent_Asset__r.Membership_Doc_Download_URL__c != null  ){
                system.debug('ph Opp parent asset memb url: ' + opp.Parent_Asset__r.Membership_Doc_Download_URL__c);
                system.debug('ph current Opp vs old opp: ' + opp.id + ' vs ' + opp.Parent_Asset__r.opportunity__c);
                firstlevelupOPP.id = opp.id;
                firstlevelupOPP.Membership_Doc_Download_URL__c = opp.Parent_Asset__r.Membership_Doc_Download_URL__c;
                //updateOpps.add(firstlevelupOPP);
                mapUpdateOpps.put(firstlevelupOPP.id,firstlevelupOpp);
            } else {
                if(opp.Parent_Asset__r.opportunity__r.Parent_Asset__r.Membership_Doc_Download_URL__c != null){
                    
                    system.debug('Lets go up another level: ' + opp.Parent_Asset__r.opportunity__r.Parent_Asset__r.opportunity__c + ' url ' +  opp.Parent_Asset__r.opportunity__r.Parent_Asset__r.Membership_Doc_Download_URL__c);
                    firstlevelupOPP.id = opp.id;
                    firstlevelupOPP.Membership_Doc_Download_URL__c = opp.Parent_Asset__r.opportunity__r.Parent_Asset__r.Membership_Doc_Download_URL__c;
                    secondlevelupOPP.Id = opp.Parent_Asset__r.opportunity__c;
                    secondlevelupOPP.Membership_Doc_Download_URL__c = opp.Parent_Asset__r.opportunity__r.Parent_Asset__r.Membership_Doc_Download_URL__c;
                    //updateOpps.add(firstlevelupOPP);
                    //updateOpps.add(secondlevelupOPP);
                    mapUpdateOpps.put(firstlevelupOPP.id,firstlevelupOpp);
                    mapUpdateOpps.put(secondlevelupOPP.id,secondlevelupOPP);
                }
            }
        }
        
        //find contentdistribution record of membership document using opportunity id
        //Note: fully executed membership documents are the only documents that have a contentdistribution record
        /*list<contentdistribution> cds = [select id, name, ContentDocumentId, ContentVersionId, ContentDownloadUrl, contentversion.firstpublishlocationid 
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
                
       */
        
        system.debug('mapUpdateOpps: ' + mapUpdateOpps.values());
        if(!mapUpdateOpps.values().isEmpty()){ 
            Database.SaveResult[] srList = Database.update(mapUpdateOpps.values(), false);
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