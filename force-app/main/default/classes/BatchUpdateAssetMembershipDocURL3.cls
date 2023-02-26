global class BatchUpdateAssetMembershipDocURL3 implements Database.Batchable<sObject>,Database.Stateful{
    //This Batch class finds old membership documents that have been added to SF outside of the docusign process
    //and creates a contentversion and contentdistribution record in order to populate the opportunity with the contentdownload URL
    //TEST CLASS is BatchUpdateAssetMembershipDocURLTest
    
    global String query='';
    
    global BatchUpdateAssetMembershipDocURL3 (String st){
      system.debug('query '+st);
        if(st != null && st != ''){
           
        system.debug('query '+st);
       
         query = st;
        }
        else{
            query='select id, name, Membership_Doc_Download_URL__c, type, Parent_Asset__r.Membership_Doc_Download_URL__c, Parent_Asset__r.opportunity__c,Parent_Asset__r.opportunity__r.Parent_Asset__r.Membership_Doc_Download_URL__c,Parent_Asset__r.opportunity__r.Parent_Asset__r.opportunity__c ' +  
                                           	' from opportunity ' +
                                           	' where Membership_Doc_Download_URL__c = null ' +
                                           	' and recordtype.name = \'Membership\' and isWon = true ' +
                							' and (NOT opportunity.name like \'%Individual%\') ' +
											' order by createddate'; 
            
            
        }  
    }
      
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('________query_____'+Query);
        system.debug('____date_____'+String.Valueof(Date.today()));
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Opportunity> scope ){
        set<string> setMembershipOpps = new set<string>();
        set<string> setOppwithoutAttachments = new set<string>();
        map<id,id> cvIDtoOppId = new map<id,id>();
        map<id,ContentDistribution> contentDistributions = new map<id,ContentDistribution>();
        
        for(Opportunity opp : scope){ 
            setMembershipOpps.add(string.valueOf(opp.id));
        }
        
        //Find attachements that were not created via the Docusign Process-best/fuzzy guess
        Map<id,attachment> mapMembAttachments = new Map<ID,Attachment>([select id, parentid, name, Body, ContentType,CreatedById,LastModifiedById,CreatedDate
                                                                        from attachment 
                                                                        where parentid in :setMembershipOpps
                                                                        and (NOT name like '%Individual%')]);
        
        
        //loop through opps that don't have attachments so we can check if they have agreement files without ContentDistribution records.
        for(Opportunity opp : scope){
            if(!mapMembAttachments.containsKey(opp.id)) {
                setOppwithoutAttachments.add(opp.id);
            }  
        }
        
        //Find ContentVersions representing Opps with Agreements attached as FILES
        Map<id,contentVersion> mapMembContentVersions = new Map<id,contentVersion>([Select Id, title, firstpublishlocationid from contentversion where firstpublishlocationid in :setOppwithoutAttachments] );
        
        if(!mapMembContentVersions.isEmpty()){
            
            for(ContentVersion contVersion : mapMembContentVersions.values()){
                ContentDistribution cd = new ContentDistribution();
                cd.Name =  contVersion.Title.length() > 100 ? (contVersion.Title).substring(0,100)
                           : contVersion.Title;
                cd.ContentVersionId = contVersion.Id;
                cd.PreferencesAllowOriginalDownload = true;
                cd.PreferencesAllowPDFDownload = true;
                cd.PreferencesAllowViewInBrowser = true;
                cd.PreferencesNotifyOnVisit = false;
                contentDistributions.put(contVersion.FirstPublishLocationId, cd);
                cvIDtoOppId.put(contVersion.id,contVersion.FirstPublishLocationId);
                system.debug('ContentVersions (aka FILES Found) Loop: ' + contVersion.FirstPublishLocationId );
            }            
        }
        
        //Back to Agreements as ATTACHMENTS
        List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
        Set<Id> oppIds = new Set<Id>();
        for(Attachment attach :mapMembAttachments.values()){            
            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = attach.Name+'.pdf';
            contentVersion.Title = attach.Name+'.pdf';
            contentVersion.VersionData = attach.Body;
            contentVersion.FirstPublishLocationId = attach.ParentId;
            contentVersion.CreatedById = attach.CreatedById;
            contentVersion.LastModifiedById = attach.LastModifiedById;
            contentVersion.CreatedDate = attach.CreatedDate;
            contentVersionToInsert.add(contentVersion);
            
        }
        system.debug('contentVersionToInsert Size: '+contentVersionToInsert.size());
        
        
        //list<opportunity> oppMemberURLtoUpdate = new list<opportunity>();
        map<id,opportunity> oppMemberURLtoUpdate = new map<id,Opportunity>();
        if(!contentVersionToInsert.isEmpty()){
            insert contentVersionToInsert;
            
            for(ContentVersion contVersion : contentVersionToInsert){
                ContentDistribution cd = new ContentDistribution();
                cd.Name =  contVersion.Title.length() > 100 ? (contVersion.Title).substring(0,100)
                           : contVersion.Title;
                cd.ContentVersionId = contVersion.Id;
                cd.PreferencesAllowOriginalDownload = true;
                cd.PreferencesAllowPDFDownload = true;
                cd.PreferencesAllowViewInBrowser = true;
                cd.PreferencesNotifyOnVisit = false;
                contentDistributions.put(contVersion.FirstPublishLocationId ,cd);
                //Store OppID/FirstPublishLocationId 
                cvIDtoOppId.put(contVersion.id,contVersion.FirstPublishLocationId);
            }
            
            System.debug(cvIDtoOppId + '====> cvIDtoOppId');
            if(!contentDistributions.isEmpty()){
                insert contentDistributions.values();
                
                //query contentDistribtuion object-this is only way to get the contentdownloadURL
                list<contentdistribution> ContDistributions = [SELECT ID,ContentVersionId,DistributionPublicUrl, ContentDownloadURL 
                                                               FROM ContentDistribution 
                                                               WHERE contentversionID in :cvIDtoOppId.keyset()];
                integer loopCount = 0;
                for(ContentDistribution contDist : ContDistributions){
                    opportunity opp = new opportunity();
                    system.debug('contentversionID: ' + contDist.ContentVersionId);                    
                    if(cvIDtoOppId.containsKey(contDist.ContentVersionId)){
                        loopCount ++;
                        system.debug(string.valueOf(loopCount) + '.  Opp ID: ' + cvIDtoOppId.get(contDist.ContentVersionId) + ' | Membership_Doc_Download_URL__c: ' + contDist.ContentDownloadUrl);
                        opp.Id = cvIDtoOppId.get(contDist.ContentVersionId);
                        opp.Membership_Doc_Download_URL__c = contDist.ContentDownloadUrl;
                        //oppMemberURLtoUpdate.add(opp);	
                        oppMemberURLtoUpdate.put(opp.id,opp);	
                    }
                }
                
                system.debug('ContDistributions download url' + ContDistributions[0].ContentDownloadUrl );
            }
            
        }
        
        //Update Opportunity with membership download URL
        if(!oppMemberURLtoUpdate.isempty()){
            try{
                update oppMemberURLtoUpdate.values();
            } catch (exception e) {
                system.debug('BatchUpdateAssetMembershipDocURL3-Update Opp Membership Document URL error: ' + e.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext info){
       
     }
    

}