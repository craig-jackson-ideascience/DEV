public class OpportunitiesRelatedToProject_Controller {
    
    @AuraEnabled
    public static Project__c getFoundationName(String foundationId) {
        system.debug('Foundation Id:::'+foundationId);
        return [SELECT Name FROM Project__c WHERE id =: foundationId];
    }
    
    @AuraEnabled
    public static list<OpportunityListWrapper> getOpportunityDetails(String foundationId, String sortField, boolean isAsc) {
        system.debug('getOpportunityDetails IN:::@SK::::=>');
        system.debug('foundationId:::@SK::::=>' + foundationId);
        list<OpportunityListWrapper> opportunityListWrapper = new list<OpportunityListWrapper>();
        list<Opportunity> oppList = new list<Opportunity>();
        Integer age;
        //Get the ID of Membership RecordType of Opportunity
        Id membershipRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        system.debug('membershipRecordTypeId::::'+membershipRecordTypeId);
        //Opportunity Filter by Project Name Start
        //<a href="/a0941000002wBz9" target="_top">The Linux Foundation</a>
        list<Account_And_Project__c> projectAcntList = new list<Account_And_Project__c>([select Account__c from Account_And_Project__c where Project__r.Name =: foundationId]);
        list<id> acntIds=new list<id>();
        for(Account_And_Project__c acntPrj:projectAcntList){
            acntIds.add(acntPrj.Account__c);
        }
        list<OpportunityLineItem> oppLineItemLst= [select id,OpportunityId from OpportunityLineItem where Projects__c=:foundationId and Opportunity.RecordTypeId =: membershipRecordTypeId];
        set<id> oppIds=new set<id>();
        for(OpportunityLineItem oliRec:oppLineItemLst){oppIds.add(oliRec.OpportunityId);}      
        //Opportunity Filter by Project Name End        
        String columns = 'Id, Name, Amount, StageName, CloseDate, Type, Probability, CreatedDate, AccountId, Account.Name,(select id from OpportunityLineItems where Projects__c=:foundationId) ';
        String sSoql = 'SELECT ' + columns + 'FROM Opportunity WHERE id IN :oppIds ';//RecordTypeId =: membershipRecordTypeId and AccountId IN:acntIds and isClosed=false';
        if(sortField != '') {
            sSoql += ' order by ' + sortField ;            
            //if isAsc is equal to ture then set 'asc' order otherwise set 'desc' order.
            if(isAsc) {
                sSoql += ' asc ';
            } else {
                sSoql += ' desc ';
            }
        }
        try {
            system.debug('The query is => sSoql:::@SK::::=>' + sSoql);
            oppList = Database.query(sSoql);
            /*list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
oliList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId IN: oppList];
system.debug('oliList::::::'+oliList);*/
            system.debug('oppList:size::@SK::::=>' + oppList.size() + ', oppList:::@SK::::=>' + oppList);
            for(Opportunity opp: oppList){
                system.debug('oppList:::@SK::::=>' + opp.OpportunityLineItems);
                if(opp.OpportunityLineItems!=null&&opp.OpportunityLineItems.size()>0){
                    Datetime createdDateTime = opp.CreatedDate;
                    Date createdDateActual = createdDateTime.Date();
                    String createdDate = DateTime.newInstance(createdDateActual.year(),createdDateActual.month(),createdDateActual.day()).format('MM/dd/yyyy');
                    //String gmtFormat = createdDateTime.formatGmt('EEE, MMM d yyyy HH:mm:ss, zz');
                    Integer ageInDays = createdDateActual.daysBetween(Date.Today());
                    Date closeDateActual = opp.CloseDate;
                    String closeDate = DateTime.newInstance(closeDateActual.year(),closeDateActual.month(),closeDateActual.day()).format('MM/dd/yyyy');
                    //system.debug('createdDate:::@SK::::=>' + createdDate + 'closeDate:::@SK::::=>' + closeDate + ' gmtFormat:::::@SK:::=>' + gmtFormat + ' ageInDays:::@SK::::=>' + ageInDays);
                    opportunityListWrapper.add(new OpportunityListWrapper(false, opp, ageInDays, createdDate, closeDate));
                }
            }
            system.debug('opportunityListWrapper:size::@SK::::=>' + opportunityListWrapper.size() + ', opportunityListWrapper:::@SK::::=>' + opportunityListWrapper);
            if(opportunityListWrapper.size() > 0) {return opportunityListWrapper;} 
        } catch(Exception ex) {return null;}
        return null;
    }
    
    @AuraEnabled
    public static list<OpportunityListWrapper> getOpportunityDetailsWithOppTypeFilter(String foundationId, String sortField, boolean isAsc, String oppType) {
        
        system.debug('foundationId:::@SK::::=>' + foundationId);
        system.debug('oppvalue:::@SK::::=>' + oppType);
        list<OpportunityListWrapper> opportunityListWrapper = new list<OpportunityListWrapper>();
        list<Opportunity> oppList = new list<Opportunity>();
        Integer age;
        //Get the ID of Membership RecordType of Opportunity
        Id membershipRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        system.debug('membershipRecordTypeId::::'+membershipRecordTypeId);
        //Opportunity Filter by Project Name Start
        list<Account_And_Project__c> projectAcntList = new list<Account_And_Project__c>([select Account__c from Account_And_Project__c where Project__r.Name =: foundationId]);
        list<id> acntIds=new list<id>();
        for(Account_And_Project__c acntPrj:projectAcntList){
            acntIds.add(acntPrj.Account__c);
        }
        list<OpportunityLineItem> oppLineItemLst= [select id,OpportunityId from OpportunityLineItem where Projects__c=:foundationId and Opportunity.RecordTypeId =: membershipRecordTypeId];
        set<id> oppIds=new set<id>();
        for(OpportunityLineItem oliRec:oppLineItemLst){oppIds.add(oliRec.OpportunityId);}      
        //Opportunity Filter by Project Name End        
        String columns = 'Id, Name, Amount, StageName, CloseDate, Type, Probability, CreatedDate, AccountId, Account.Name,(select id from OpportunityLineItems where Projects__c=:foundationId) ';
        String sSoql = 'SELECT ' + columns + 'FROM Opportunity WHERE id IN :oppIds ';//RecordTypeId =: membershipRecordTypeId and AccountId IN:acntIds and isClosed=false';
        system.debug(oppType+'SOQL :::'+sSoql);
        // Filter Based on Opportunity Type Start
        if(string.isNotBlank(oppType) && oppType == 'Open'){
            sSoql= sSoql+' AND IsClosed = FALSE'; 
        } else if(string.isNotBlank(oppType) && oppType == 'Closed') {
            sSoql= sSoql+' AND IsClosed = TRUE';             
        } else {
            sSoql= sSoql;
        }
        // Filter Based on Opportunity Type End
        if(sortField != '') {
            sSoql += ' order by ' + sortField ;            
            //if isAsc is equal to ture then set 'asc' order otherwise set 'desc' order.
            if(isAsc) {
                sSoql += ' asc ';
            } else {
                sSoql += ' desc ';
            }
        }
        try {
            opportunityListWrapper.clear();
            system.debug('The query is => sSoql:::@SK::::=>' + sSoql);
            oppList = Database.query(sSoql);
            system.debug('oppList:::@SK::::=>' + oppList);
            for(Opportunity opp: oppList) {
                if(opp.OpportunityLineItems!=null&&opp.OpportunityLineItems.size()>0){
                    Datetime createdDateTime = opp.CreatedDate;
                    Date createdDateActual = createdDateTime.Date();
                    String createdDate = DateTime.newInstance(createdDateActual.year(),createdDateActual.month(),createdDateActual.day()).format('MM/dd/yyyy');
                    //String gmtFormat = createdDateTime.formatGmt('EEE, MMM d yyyy HH:mm:ss, zz');
                    Integer ageInDays = createdDateActual.daysBetween(Date.Today());
                    Date closeDateActual = opp.CloseDate;
                    String closeDate = DateTime.newInstance(closeDateActual.year(),closeDateActual.month(),closeDateActual.day()).format('MM/dd/yyyy');
                    //system.debug('createdDate:::@SK::::=>' + createdDate + 'closeDate:::@SK::::=>' + closeDate + ' gmtFormat:::::@SK:::=>' + gmtFormat + ' ageInDays:::@SK::::=>' + ageInDays);
                    opportunityListWrapper.add(new OpportunityListWrapper(false, opp, ageInDays, createdDate, closeDate));
                }
            }
            system.debug('opportunityListWrapper:size::@SK::::=>' + opportunityListWrapper.size() + ', opportunityListWrapper:::@SK::::=>' + opportunityListWrapper);
            if(opportunityListWrapper.size() > 0) {return opportunityListWrapper;} 
        } catch(Exception ex) {return null;}
        return null;
    }
    
    public class OpportunityListWrapper {
        @AuraEnabled public boolean isChecked { get; set; }
        @AuraEnabled public Opportunity objOpportunity { get; set; }
        @AuraEnabled public Integer age { get; set; }
        @AuraEnabled public String createdDate { get; set; }
        @AuraEnabled public String closeDate { get; set; }
        public OpportunityListWrapper(boolean isChecked, Opportunity objOpportunity, Integer age, String createdDate, String closeDate){
            this.isChecked = isChecked;
            this.objOpportunity = objOpportunity;
            this.age = age;
            this.createdDate = createdDate;
            this.closeDate = closeDate;
        }
    }    
}