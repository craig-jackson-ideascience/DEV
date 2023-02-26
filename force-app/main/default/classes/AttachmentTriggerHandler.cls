public class AttachmentTriggerHandler implements ITriggerHandler {

    //This will handle before delete event
    public void beforeDelete(Map<Id, SObject> oldMap) {

    }

    //This method will handle before insert method
    public void beforeInsert(List<SObject> newItems) {
        updateDocusignContractFileName((List<Attachment>) newItems);
    }

    //This method will handle before update event
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {

    }

    public void afterInsert(Map<Id, SObject> newMap) {
        insertContentVersion((Map<Id, Attachment>) newMap);
    }

    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
    }

    public void afterDelete(Map<Id, SObject> oldMap) {

    }

    public void afterUndelete(Map<Id, SObject> newMap) {

    }

    public void insertContentVersion(Map<Id, Attachment> newMap){
        String keyPrefix = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getKeyPrefix();
        List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
        Set<Id> oppIds = new Set<Id>();
        for(Attachment attach :newMap.values()){
            if(String.valueOf(attach.ParentId).startswith(keyPrefix) && 
               (attach.Name.tolowercase().contains('executed') || attach.Name.tolowercase().contains('complete'))){
                
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
                contentVersion.PathOnClient = attach.Name+'.pdf';
                contentVersion.Title = attach.Name+'.pdf';
                contentVersion.VersionData = attach.Body;
                contentVersion.FirstPublishLocationId = attach.ParentId; 
                contentVersionToInsert.add(contentVersion);
            }
        }
        system.debug('contentVersionToInsert '+contentVersionToInsert.size());
        map<id,id> cvIDtoOppId = new map<id,id>();
        list<opportunity> oppMemberURLtoUpdate = new list<opportunity>();
        if(!contentVersionToInsert.isEmpty()){
            insert contentVersionToInsert;
            List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
            for(ContentVersion contVersion : contentVersionToInsert){
                ContentDistribution cd = new ContentDistribution();
                cd.Name =  contVersion.Title.length() > 100 ? (contVersion.Title).substring(0,100)
                           : contVersion.Title;
                cd.ContentVersionId = contVersion.Id;
                cd.PreferencesAllowOriginalDownload = true;
                cd.PreferencesAllowPDFDownload = true;
                cd.PreferencesAllowViewInBrowser = true;
                cd.PreferencesNotifyOnVisit = false;
                contentDistributions.add(cd);
                //Store OppID/FirstPublishLocationId 
                cvIDtoOppId.put(contVersion.id,contVersion.FirstPublishLocationId);
            }
            System.debug(cvIDtoOppId + '====> cvIDtoOppId');
            if(!contentDistributions.isEmpty()){
                insert contentDistributions;
                //query contentDistribtuion object-this is only way to get the contentdownloadURL
                list<contentdistribution> ContDistributions = [SELECT ID,ContentVersionId,DistributionPublicUrl, ContentDownloadURL 
                                                               FROM ContentDistribution 
                                                               WHERE contentversionID in :cvIDtoOppId.keyset()];
                
                for(ContentDistribution contDist : ContDistributions){
                    opportunity opp = new opportunity();
                    system.debug('contentversionID: ' + contDist.ContentVersionId);
                    system.debug('cvIDtoOppId.containsKey(contDist.ContentVersionId): ' + cvIDtoOppId.containsKey(contDist.ContentVersionId));
                    if(cvIDtoOppId.containsKey(contDist.ContentVersionId)){
                        system.debug('Membership_Doc_Download_URL__c: ' + contDist.ContentDownloadUrl);
                        opp.Id = cvIDtoOppId.get(contDist.ContentVersionId);
                        opp.Membership_Doc_Download_URL__c = contDist.ContentDownloadUrl;
                        oppMemberURLtoUpdate.add(opp);					                        
                    }
                }
                
                //list<contentdistribution> ContDistributions = [SELECT ID,ContentVersionId,DistributionPublicUrl, ContentDownloadURL FROM ContentDistribution WHERE contentversionID in :cvIDtoOppId.keyset() ];
                
                system.debug('ContDistributions download url' + ContDistributions[0].ContentDownloadUrl );
            }            
        }
        //Update Opportunity with membership download URL
        if(!oppMemberURLtoUpdate.isempty()){
            try{
                update oppMemberURLtoUpdate;
            } catch (exception e) {
                system.debug('Attachement Trigger Handler-InsertContentVersion error: ' + e.getMessage());
            }
        }
    }
    
    
    public void updateDocusignContractFileName(List<Attachment> newList) {
        System.debug(newList + '====> newList');
        String keyPrefix = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getKeyPrefix();
        List<Attachment> attachmentsList = new List<Attachment>();
        Set<Id> oppIds = new Set<Id>();
        for(Attachment att :newList){
            if(String.valueOf(att.ParentId).startswith(keyPrefix) && (att.Name.contains('OpportunityNameContract') || att.Name.containsIgnorecase('Completed'))){
                oppIds.add(att.ParentId);
                attachmentsList.add(att);
            }
        }
        
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id, Name FROM Opportunity WHERE Id IN :oppIds]);
        System.debug(opportunityMap + '====> opportunityMap');
        System.debug(attachmentsList + '====> attachmentsList');
        for(Attachment att: attachmentsList){
            att.Name = opportunityMap.get(att.ParentId).Name+'-FullyExecuted';
        }
    }

    public Boolean IsDisabled() {
        return false;
    }

}