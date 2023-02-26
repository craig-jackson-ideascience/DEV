global with sharing class OpportunitylistViewCom {
    @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityLineItem(Id accountId,String sortField, boolean isAsc){
        String query = 'Select id,Opportunity.Name,Opportunity.Account.name,Opportunity.RecordType.Name,Opportunity.type,Opportunity.Amount,Opportunity.StageName,Opportunity.Parent_Asset__r.InstallDate,Product_Name__c,UnitPrice,TotalPrice,ListPrice,End_Date__c,Related_To__c ';
            query += 'From OpportunityLineItem where Opportunity.AccountId =:accountId';
        if (sortField != '') {
            query += ' order by ' + sortField;
            if (isAsc) {
                query += ' asc';
            } else {
                query += ' desc';
            }
        }
        list <OpportunityLineItem> oppList1;
        try {
            oppList1 = Database.query(query);
            List < OpportunityLineItem > oppList = new List < OpportunityLineItem > ();
            for (OpportunityLineItem c: oppList1) {
                oppList.add(c);
            }
            return oppList;
        } 
        catch (Exception ex) {
            // for handle Exception
            return null;
        }
    }
   
    @AuraEnabled
    public static list < AttachmentWrapper > fetchopportunity(Id accountId,String RecordTypeName) {
        set<ID> oppIDs = new set<ID>();
        set<ID> joinoppIDs = new set<ID>();
        map<id,Opportunity> mapOpportunity = new map<Id,Opportunity>();
        System.debug('accountId-->'+accountId);
        system.debug('RecordTypeName-->'+RecordTypeName);
       
        List<Opportunity> lstOpp = new List<Opportunity>();
        List < ContentDocumentLink > lstCDL = new List < ContentDocumentLink >();
            if(RecordTypeName =='' || RecordTypeName == null ||  RecordTypeName == '---All---'){
                lstOpp=[Select id,JoinNow_Update__c from opportunity where AccountId=:accountId order by CreatedDate desc];
            }else{
                lstOpp=[Select id,JoinNow_Update__c from opportunity where AccountId=:accountId and recordtype.name =:RecordTypeName order by CreatedDate desc];
            }
        for(Opportunity opp :lstOpp){
            oppIDs.add(opp.id);
            mapOpportunity.put(opp.id, opp);
        }
        system.debug('oppIDs-->'+oppIDs);
        //List<Attachment> lstAttachment = new List<Attachment>();
        List<AttachmentWrapper> AttachmentWrapperList = new List<AttachmentWrapper>();
        set<Id> usedIds = new set<Id>();
        if(!oppIDs.isEmpty() ){
            
            For(Attachment objAtt : [select id,ParentId,name,LastModifiedDate,CreatedBy.name,Parent.Name, Owner.Name, BodyLength from Attachment where ParentId IN:oppIDs order by LastModifiedDate desc]){
                if(mapOpportunity.get(objAtt.ParentId).JoinNow_Update__c != null){
                    usedIds.add(objAtt.ParentId);
                    AttachmentWrapper obj = new AttachmentWrapper();
                    obj.Attid = objAtt.id;
                    obj.OppId = objAtt.ParentId;
                    obj.Title = objAtt.name;
                    obj.CreatedBy =objAtt.CreatedBy.name;
                    obj.LastModified = objAtt.LastModifiedDate;
                    obj.Parent = objAtt.Parent.Name;
                    AttachmentWrapperList.add(obj);
                }else{
                    usedIds.add(objAtt.ParentId);
                    AttachmentWrapper obj = new AttachmentWrapper();
                    obj.Attid = objAtt.id;
                    obj.OppId = objAtt.ParentId;
                    obj.Title = objAtt.name;
                    obj.CreatedBy =objAtt.CreatedBy.name;
                    obj.LastModified = objAtt.LastModifiedDate;
                    obj.Parent = objAtt.Parent.Name;
                    AttachmentWrapperList.add(obj);
                }
            }
            for(ContentDocumentLink c: [SELECT ContentDocumentId,LinkedEntityID,ContentDocument.owner.Name, LinkedEntity.Name,ContentDocument.Title,ContentDocument.LastModifiedDate FROM ContentDocumentLink where LinkedEntityId IN:oppIDs]){
                if(!usedIds.contains(c.LinkedEntityID)){
                    if(mapOpportunity.get(c.LinkedEntityID).JoinNow_Update__c != null){
                        AttachmentWrapper obj = new AttachmentWrapper();
                        obj.Attid = c.ContentDocumentId;
                        obj.OppId = c.LinkedEntityID;
                        obj.Title = c.ContentDocument.Title;
                        obj.CreatedBy = c.ContentDocument.owner.Name;
                        obj.LastModified = c.ContentDocument.LastModifiedDate;
                        obj.Parent = c.LinkedEntity.Name;
                        AttachmentWrapperList.add(obj);
                    }else{
                        AttachmentWrapper obj = new AttachmentWrapper();
                        obj.Attid = c.ContentDocumentId;
                        obj.OppId = c.LinkedEntityID;
                        obj.Title = c.ContentDocument.Title;
                        obj.CreatedBy = c.ContentDocument.owner.Name;
                        obj.LastModified = c.ContentDocument.LastModifiedDate;
                        obj.Parent = c.LinkedEntity.Name;
                        AttachmentWrapperList.add(obj);
                    }
                }
            }
        }
            system.debug('AttachmentWrapperList-->'+AttachmentWrapperList.size());
           return AttachmentWrapperList;
    }
    
    @AuraEnabled 
    public static RecordType[] getRecordTypeList() {
        return [select Name from RecordType where sObjectType='Opportunity' AND name IN('Membership','Event','Corporate Training')];
    }
    global class AttachmentWrapper implements Comparable{
        @AuraEnabled
        public String Title {get;set;}
        @AuraEnabled
        public String Attid {get;set;}
        @AuraEnabled
        public String Parent {get;set;}
        @AuraEnabled
        public DateTime LastModified {get;set;}
        @AuraEnabled
        public String CreatedBy {get;set;}
        @AuraEnabled
        public String OppId {get;set;}
        public Integer compareTo(Object instance)
        {
            AttachmentWrapper that = (AttachmentWrapper)instance;
            if (this.LastModified > that.LastModified) return 1;
            if (this.LastModified < that.LastModified) return -1;
            return 0;
        }
        
    }
    
    
}