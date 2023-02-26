public class ContentVersionTriggerHandler implements ITriggerHandler{
    public static void BeforeInsert(List<Sobject> triggerNew) {
        updateStatusFieldsForMembershipOpp((List<ContentVersion>) triggerNew);
    }
    
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        
    }
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    }
    
    public static void AfterInsert(Map<Id, SObject> newMap) {
        existingContentVersionUpdaetion((Map<Id, ContentVersion>) newMap);
        updateOppMembDocURLonManualUpload((Map<Id, ContentVersion>) newMap);
    }
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap) {
        
        
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) {
        
    }
    
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after undelete actions
    }
    
    public Boolean IsDisabled() {
        return false;
    }
    
    //Update existing version of account and project to expired
    public static void existingContentVersionUpdaetion(Map<Id, ContentVersion> newMap){
        Set<Id> oppIdSet = new Set<Id>();
        String keyPrefix = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getKeyPrefix();
        Set<id> currentContDocIdSet = new Set<id>();
        
        //Iterate
        for(ContentVersion conVersion : newMap.values()){
            //If it is published from opportunity and contains executed in it title
            if(conVersion.FirstPublishLocationId != null && 
               String.valueOf(conVersion.FirstPublishLocationId).startswith(keyPrefix) &&
              conVersion.Title.tolowercase().contains('executed')){
                   oppIdSet.add(conVersion.FirstPublishLocationId);
                   currentContDocIdSet.add(conVersion.contentdocumentid);
               }
        }
        
        if(!oppIdSet.isEmpty()){
            Map<Id,Id> accountProjectMap = new Map<Id,Id>();
            set<String> accountprojectset = new set<string>();
            //Retrieve opportunity 
            Map<Id,Opportunity> opportunitymap = new Map<Id,Opportunity>
                ([SELECT Id,AccountId,Project_Name__c  FROM Opportunity 
                  WHERE ID IN:oppIdSet AND RecordType.Name='Membership' AND Project_Name__c  != null AND 
                  AccountId !=: Label.Individual_No_Account]);
            
            system.debug('opportunitymap '+opportunitymap);
            //Iterate and store accounts and projects of opportunity
            for(Opportunity opp : opportunitymap.values()){
                accountProjectMap.put(opp.AccountId,opp.Project_Name__c );
                accountprojectset.add(opp.AccountId+'-'+opp.Project_Name__c );
            }
            
            if(!accountProjectMap.isEmpty()){
                //Get all opportunity of account and project
                List<Opportunity> oppList = [SELECT Id,AccountId,Project_Name__c ,
                                             (SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLinks) 
                                             FROM Opportunity WHERE Accountid IN: accountProjectMap.keyset() 
                                             and Project_Name__c in:accountProjectMap.values()];
                
                Set<Id> contentDocumentIdSet = new Set<id>();
                //Iterate and get all content documnetids
                for(Opportunity opp : oppList){
                    string key = opp.accountid+'-'+opp.Project_Name__c ;
                    if(accountprojectset.contains(key)){
                        if(!opp.ContentDocumentLinks.isEmpty()){
                            for(ContentDocumentLink contentDocument: opp.ContentDocumentLinks){
                                contentDocumentIdSet.add(contentDocument.ContentDocumentId);
                            }
                        }
                        
                    }
                    
                }
                
                if(!contentDocumentIdSet.isEmpty()){
                    //Retrieve versions and marked as expired
                    List<ContentVersion> contentVersionList = [SELECT Id FROM ContentVersion 
                                                               WHERE ContentDocumentId IN:contentDocumentIdSet
                                                               and Status__c !='Expired' AND ID NOT IN: newMap.keySet() 
                                                               AND Title Like '%Executed%'];
                    
                    if(!contentVersionList.isempty()){
                        for(ContentVersion conVersion : contentVersionList){
                            conVersion.Status__c ='Expired';
                        }
                        update contentVersionList;
                    }
                }
            }
        }
    }
    
    //update status as Active and show in joinnow to true on insertion of contentversion attached to membership opportunity
    public static void updateStatusFieldsForMembershipOpp(List<ContentVersion> triggerNew){
        
        Map<Id,ContentVersion> oppIdVSContentVersion = new Map<Id,ContentVersion>();
        String keyPrefix = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getKeyPrefix();
        
        //Iterate
        for(ContentVersion conVersion : triggerNew){
            //If attached to opportunity
            if(conVersion.FirstPublishLocationId != null &&
               String.valueOf(conVersion.FirstPublishLocationId).startswith(keyPrefix) &&
               conVersion.Title.tolowercase().contains('executed')){
                   oppIdVSContentVersion.put(conVersion.FirstPublishLocationId,conVersion);
               }
        }
        
        if(!oppIdVSContentVersion.isEmpty()){
            
            //Retrieve membership opportunity
            Map<Id,Opportunity> opportunitymap = new Map<Id,Opportunity>
                ([SELECT Id FROM Opportunity WHERE ID IN:oppIdVSContentVersion.keySet() AND RecordType.Name='Membership' 
                 AND AccountId !=: Label.Individual_No_Account]);
            
            
            //Iterate on membership opp
            for(Id oppid : opportunitymap.keySet()){
                //if this opp is in map
                if(oppIdVSContentVersion.containsKey(oppid)){
                    
                    //populate fields
                    ContentVersion conVersion = oppIdVSContentVersion.get(oppid);
                    conVersion.Show_in_Joinnow__c=True;
                    conVersion.Status__c ='Active';
                    
                }
            }
        }
    }
    
    public static void updateOppMembDocURLonManualUpload(Map<Id, ContentVersion> newMap){
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id,ContentVersion> oppIdVSContentVersion = new Map<Id,ContentVersion>();
        Set<ID> oppWithCompletedDocusignRec = new Set<ID>();
        map<id,ContentDistribution> contentDistributions = new map<id,ContentDistribution>();
        list<opportunity> oppstoUpdate = new list<opportunity>();
        
        String keyPrefix = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getKeyPrefix();
        
        for(ContentVersion conVersion : newMap.values()){
            //If it is published from opportunity and contains executed in it title
            if(conVersion.FirstPublishLocationId != null && 
               String.valueOf(conVersion.FirstPublishLocationId).startswith(keyPrefix) &&
              conVersion.Title.tolowercase().contains('executed')){
                   oppIdSet.add(conVersion.FirstPublishLocationId);
                   oppIdVSContentVersion.put(conVersion.FirstPublishLocationId,conVersion);
               }
        }
        
        if (!oppIdVSContentVersion.isEmpty()) {
            for (dsfs__DocuSign_Status__c d : [
                SELECT Id, Name, dsfs__Contact__c, dsfs__Envelope_Status__c, dsfs__Opportunity__c
                FROM dsfs__DocuSign_Status__c
                WHERE dsfs__Opportunity__c in :oppIdVSContentVersion.keyset()
                AND dsfs__Envelope_Status__c = 'Completed'
            ]) {
                oppWithCompletedDocusignRec.add(d.dsfs__Opportunity__c);
            }
            
            for(ContentVersion cv : oppIdVSContentVersion.values()){
                //If it is published from opportunity and contains executed in it title
                if(!oppWithCompletedDocusignRec.contains(cv.FirstPublishLocationId)){
                    
                    ContentDistribution cd = new ContentDistribution();
                    cd.Name =  cv.Title.length() > 100 ? (cv.Title).substring(0,100)
                        : cv.Title;
                    cd.ContentVersionId = cv.Id;
                    cd.PreferencesAllowOriginalDownload = true;
                    cd.PreferencesAllowPDFDownload = true;
                    cd.PreferencesAllowViewInBrowser = true;
                    cd.PreferencesNotifyOnVisit = false;
                    contentDistributions.put(cv.FirstPublishLocationId, cd);
                }
            }
            
            if(!contentDistributions.isempty()){
                map<id,ContentDistribution> OppIdsVsCDs = new map<id,ContentDistribution>();
                insert ContentDistributions.values();
                
                //Query the values you just inserted in order to retrieve ContentDownloadURL that is generated.
                list<ContentDistribution> lstCD = [SELECT ID,ContentVersionId,contentversion.status__c,contentversion.FirstPublishLocationId,DistributionPublicUrl, ContentDownloadURL,contentversion.title 
                                                   FROM ContentDistribution 
                                                   WHERE contentversion.FirstPublishLocationId in :contentDistributions.keyset()
                                                   and contentversion.status__c = 'Active'
                                                   and contentversion.Title like '%executed%'
                                                   order by createddate desc limit 1];
                
                for(contentDistribution cd: lstCD){
                    OppIdsVsCDs.put(cd.contentversion.FirstPublishLocationId,cd);
                }
                
                for (Opportunity opp : [select id, name,Membership_Doc_Download_URL__c 
                                        from opportunity 
                                        where id in :contentDistributions.keyset()
                                        AND RecordType.Name='Membership' 
                                        AND AccountId !=: Label.Individual_No_Account]) {
                                            if(OppIdsVsCDs.containskey(opp.id)){
                                                opp.Membership_Doc_Download_URL__c = OppIdsVsCDs.get(opp.id).ContentDownloadURL;
                                                oppstoUpdate.add(opp);
                                            }
                                        }
            }
            
            //Update Membership Opp(s) with ContentDownloadURL
            if(!oppstoUpdate.isempty()) {
                update oppstoUpdate;
            }
        }
    }
    
}