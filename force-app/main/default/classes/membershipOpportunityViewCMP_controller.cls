public class membershipOpportunityViewCMP_controller {
    
    @AuraEnabled
    public static Project__c getFoundationName(String foundationId) {
        system.debug('Foundation Id:::'+foundationId);
        return [SELECT Name FROM Project__c WHERE Id =: foundationId];
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
        list<Account_And_Project__c> projectAcntList = new list<Account_And_Project__c>([select Account__c from Account_And_Project__c where Project__r.Id =: foundationId]);
        list<id> acntIds=new list<id>();
        for(Account_And_Project__c acntPrj:projectAcntList){
            acntIds.add(acntPrj.Account__c);
        }
        list<OpportunityLineItem> oppLineItemLst= [select id,OpportunityId from OpportunityLineItem where Projects__c=:foundationId and Opportunity.isClosed=false and Opportunity.RecordTypeId =: membershipRecordTypeId];
        set<id> oppIds=new set<id>();
        for(OpportunityLineItem oliRec:oppLineItemLst){oppIds.add(oliRec.OpportunityId);}      
        //Opportunity Filter by Project Name End        
        String columns = 'Id, Name, Amount, StageName, CloseDate, Probability, CreatedDate, AccountId, Account.Name,(select id from OpportunityLineItems where Projects__c=:foundationId) ';
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
            system.debug('oppList:::@SK::::=>' + oppList);
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
            system.debug('opportunityListWrapper:::@SK::::=>' + opportunityListWrapper);
            if(opportunityListWrapper.size() > 0) {return opportunityListWrapper;} 
        } catch(Exception ex) {return null;}
        return null;
    }
    
    @AuraEnabled
    public static list<MembershipListWrapper> getMembershipDetails(String foundationId, Integer installDateMonth) {
        system.debug('<=:::::getMembershipDetails:::@SK::::=>');
        system.debug('foundationId:::@SK::::=>' + foundationId + ' installDateMonth:::@SK::::=>' + installDateMonth);
        list<MembershipListWrapper> membershipListWrapper = new list<MembershipListWrapper>();
        list<Asset> mdList = new list<Asset>();
        
        //Opportunity Filter by Project Name End        
        String columns = 'Id, Name, AccountId, Account.Name, Status, PurchaseDate, Price, Product2.Name, Product2.Family, Projects__r.Name ';
        String sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId and Opportunity__r.Type = \'New Business\' and InstallDate = THIS_FISCAL_YEAR and Status != \'Invoice Cancelled\' Status != \'Associate Cancelled\' and Product2.Family = \'Membership\' and CALENDAR_MONTH(InstallDate) =: installDateMonth';
        //Where Clause Condition - 'Status != 'Invoice Cancelled' AND Projects__r.Id =: 'a09410000182dD2AAI' AND Product2.Family = 'Membership' AND CALENDAR_MONTH(PurchaseDate) =: purchaseDateMonth'
        /*if(sortField != '') {
        sSoql += ' order by ' + sortField ;            
        //if isAsc is equal to ture then set 'asc' order otherwise set 'desc' order.
        if(isAsc) {
        sSoql += ' asc LIMIT 10000';
        } else {
        sSoql += ' desc LIMIT 10000';
        }
        }*/
        try {
            system.debug('The query is => sSoql:::@SK::::=>' + sSoql);
            mdList = Database.query(sSoql);
            system.debug('mdList:::@SK::::=>' + mdList);
            for(Asset a: mdList){membershipListWrapper.add(new MembershipListWrapper(a));
                                }
            system.debug('membershipListWrapper:::@SK::::=>' + membershipListWrapper);
            if(membershipListWrapper.size() > 0) {return membershipListWrapper;
                                                 } 
        } catch(Exception ex) { return null;}
        return null;
    }
    
    @AuraEnabled
    public static list<MembershipListWrapper> getAccountReceivableDetails(String foundationId, Integer daysFromPurchaseDate) {
        system.debug('<=:::::getARDetails:::@SK::::=>');
        system.debug('foundationId:::@SK::::=> ' + foundationId + ' daysFromPurchaseDate:::@SK::::=> ' + daysFromPurchaseDate );
        list<MembershipListWrapper> accRecListWrapper = new list<MembershipListWrapper>();
        list<Asset> arList = new list<Asset>();
        String sSoql;
        //Opportunity Filter by Project Name End        
        String columns = 'Id, Name, AccountId, Account.Name, Status, PurchaseDate, Product2.Name, Product2.Family, Price, Days__c, Projects__c, Projects__r.Name ';
        
        sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId AND SalesOrderStatus__c = \'Open\' AND Days_String__c = \'' + daysFromPurchaseDate + '\' AND (Status = \'Active\' OR Status = \'Purchased\') ';

        /*if(daysFromPurchaseDate == 1) {
            sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId and SalesOrderStatus__c != \'Closed\' and Days_String__c  = \'1\'';
        } else if(daysFromPurchaseDate == 2) {
            sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId and SalesOrderStatus__c != \'Closed\' and Days_String__c = \'2\'';
        } else if(daysFromPurchaseDate == 3) {
            sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId and SalesOrderStatus__c != \'Closed\' and Days_String__c = \'3\'';
        } else if(daysFromPurchaseDate == 4) {
            sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId and SalesOrderStatus__c != \'Closed\' and Days_String__c = \'4\'';
        }*/
        
        //String sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId and SalesOrderStatus__c = \'Open\' ';
        //Where Clause Condition - 'Status != 'Invoice Cancelled' AND Projects__r.Id =: 'a09410000182dD2AAI' AND Product2.Family = 'Membership' AND CALENDAR_MONTH(PurchaseDate) =: purchaseDateMonth'
        /*if(sortField != '') {
        sSoql += ' order by ' + sortField ;            
        //if isAsc is equal to ture then set 'asc' order otherwise set 'desc' order.
        if(isAsc) {
        sSoql += ' asc LIMIT 10000';
        } else {
        sSoql += ' desc LIMIT 10000';
        }
        }*/
        try {
            system.debug('The query is => sSoql:::@SK::::=>' + sSoql);
            arList = Database.query(sSoql);
            system.debug('arList:::@SK::::=>' + arList);
            
            for(Asset a: arList) {   
                accRecListWrapper.add(new MembershipListWrapper(a));
            }
            system.debug('accRecListWrapper:::@SK::::=>' + accRecListWrapper);
            if(accRecListWrapper.size() > 0) {
                return accRecListWrapper;
            } 
        } catch(Exception ex) { return null;}
        return null;
    }
    @AuraEnabled
    public static list<MembershipListWrapper> getAccountReceivableReportViewData(String foundationId, String sortField, boolean isAsc) {
        system.debug('<=:::::getAccountReceivableReportViewData:::@SK::::=>');
        system.debug('foundationId:::@SK::::=> ' + foundationId + 'sortField:: ' + sortField);
        list<MembershipListWrapper> accRecListWrapper = new list<MembershipListWrapper>();
        list<Asset> arList = new list<Asset>();
        String sSoql;
        //Opportunity Filter by Project Name End        
        String columns = 'Id, Name, AccountId, Account.Name, Status, PurchaseDate, Product2.Name, Product2.Family, Price, Days__c, Projects__c, Projects__r.Name ';
        
        sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId AND SalesOrderStatus__c = \'Open\' AND (Status = \'Active\' OR Status = \'Purchased\') ';

        /*if(daysFromPurchaseDate == 1) {
            sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId and SalesOrderStatus__c != \'Closed\' and Days_String__c  = \'1\'';
        } else if(daysFromPurchaseDate == 2) {
            sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId and SalesOrderStatus__c != \'Closed\' and Days_String__c = \'2\'';
        } else if(daysFromPurchaseDate == 3) {
            sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId and SalesOrderStatus__c != \'Closed\' and Days_String__c = \'3\'';
        } else if(daysFromPurchaseDate == 4) {
            sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId and SalesOrderStatus__c != \'Closed\' and Days_String__c = \'4\'';
        }*/
        
        //String sSoql = 'SELECT ' + columns + 'FROM Asset WHERE Projects__r.Id =: foundationId and SalesOrderStatus__c = \'Open\' ';
        //Where Clause Condition - 'Status != 'Invoice Cancelled' AND Projects__r.Id =: 'a09410000182dD2AAI' AND Product2.Family = 'Membership' AND CALENDAR_MONTH(PurchaseDate) =: purchaseDateMonth'
        if(sortField != '') {
        sSoql += ' order by ' + sortField ;            
        //if isAsc is equal to ture then set 'asc' order otherwise set 'desc' order.
        if(isAsc) {
        sSoql += ' asc';
        } else {
        sSoql += ' desc';
        }
        }
        try {
            system.debug('The query is => sSoql:::@SK::::=>' + sSoql);
            arList = Database.query(sSoql);
            system.debug('arList Size:::@SK::::=>' + arList.size() + 'arList:::@SK::::=>' + arList);
            
            for(Asset a: arList) {   
                accRecListWrapper.add(new MembershipListWrapper(a));
            }
            system.debug('accRecListWrapper:::@SK::::=>' + accRecListWrapper);
            if(accRecListWrapper.size() > 0) {
                return accRecListWrapper;
            } 
        } catch(Exception ex) { return null;}
        return null;
    }
    /* wrapper classes */  
    public class OpportunityListWrapper {
        @AuraEnabled public boolean isChecked { get; set; }
        @AuraEnabled public  Opportunity objOpportunity { get; set; }
        @AuraEnabled public  Integer age { get; set; }
        @AuraEnabled public  String createdDate { get; set; }
        @AuraEnabled public  String closeDate { get; set; }
        public OpportunityListWrapper(boolean isChecked, Opportunity objOpportunity, Integer age, String createdDate, String closeDate){
            this.isChecked = isChecked;
            this.objOpportunity = objOpportunity;
            this.age = age;
            this.createdDate = createdDate;
            this.closeDate = closeDate;
        }
    }    
    public class MembershipListWrapper {
        @AuraEnabled public Asset objAsset { get; set; }
        public MembershipListWrapper(Asset objAsset){
            this.objAsset = objAsset;
        }
    } 
    
}