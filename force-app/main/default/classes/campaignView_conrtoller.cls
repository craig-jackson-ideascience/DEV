/*
LastModified By             ModifiedDate            Methods                                                 Against 
========================================================================================================================
Kalyani Chiluveri             18-May-2020`         getCampaignDetails, getSelectedCamapignDetails           SFDC - 1284
*/

public class campaignView_conrtoller {
    
    @AuraEnabled
    public static list<CampaignListWrapper> getCampaignDetails(String foundationId, String sortField, boolean isAsc) {
        system.debug('foundationId :::: => ' + foundationId + ', sortField :::: => ' + sortField);
        
        list<CampaignListWrapper> campaignListWrapper = new list<CampaignListWrapper>();
        list<Campaign> campaignList = new list<Campaign>();
        set<Id> opportunityIds = new set<Id>();
        Integer closedOpportunity;
        String sSoql;
        Date startDateActual;
        String startDate;
        Date endDateActual;
        String endDate;
        String columns = 'Id, Name, Status, Type, StartDate, EndDate, NumberOfLeads, NumberOfConvertedLeads, NumberOfContacts, NumberOfOpportunities, AmountAllOpportunities, NumberOfWonOpportunities, AmountWonOpportunities ';
        sSoql = 'SELECT ' + columns + 'FROM Campaign WHERE Project__c =:foundationId ';
        system.debug('sSoql 13::  ' + sSoql);
        
        integer intCampareVal=0;
        if(sortField != '') {
            sSoql += 'order by ' + sortField;            
            //if isAsc is equal to ture then set 'asc' order otherwise set 'desc' order.
            if(isAsc) {
                sSoql += ' asc';
                intCampareVal=0;
            } else {
                sSoql += ' desc';
                intCampareVal=campaignList.size()-1;
            }
        }
        system.debug('sSoql 27::  ' + sSoql);
        try {
            campaignList = Database.query(sSoql);
            system.debug('campaignList::: ' + campaignList);
            if(isAsc) {
                intCampareVal=0;
            } else {
                intCampareVal=campaignList.size()-1;
            }
            Set<ID> campIds = new Set<ID>();
            for(Campaign cam : campaignList) {
                campIds.add(cam.ID);
            }

            List<Opportunity> oppList = new List<Opportunity>();
            Map<ID,Set<ID>> CampVsOpp = new Map<ID,Set<ID>>();
            oppList = [SELECT Id, CampaignID FROM Opportunity WHERE isClosed=true AND CampaignID IN : campIds];

            for(Opportunity obj : oppList) {
              if(CampVsOpp.containsKey(obj.CampaignID)) {
                CampVsOpp.get(obj.CampaignID).add(obj.ID);
              }else {
                CampVsOpp.put(obj.CampaignID, new Set<ID>{obj.ID});
              }
            }
            
            for(integer i=0;i<=campaignList.size()-1;i++){  
                //Code is not bulkified firing soql in for - so made code changes against - SFDC - 1284
                /*for(Opportunity opp: [SELECT Id FROM Opportunity WHERE isClosed=true AND campaignId=:campaignList[i].Id]) {
                    opportunityIds.add(opp.Id);
                }*/
                
                if(CampVsOpp.containsKey(campaignList[i].id)) {
                    opportunityIds = CampVsOpp.get(campaignList[i].id);
                    if(opportunityIds.size() > 0) {
                        system.debug('opportunityIds.size()::: ' + opportunityIds.size());
                        closedOpportunity = opportunityIds.size();
                    } else { closedOpportunity = 0; }
                }
                
                system.debug('closedOpportunity::: ' + closedOpportunity);
                if(campaignList[i].StartDate != null) {
                    startDateActual = campaignList[i].StartDate;
                    startDate = DateTime.newInstance(startDateActual.year(),startDateActual.month(),startDateActual.day()).format('MM/dd/yyyy');
                }
                if(campaignList[i].EndDate != null) {
                    endDateActual = campaignList[i].EndDate;
                    endDate = DateTime.newInstance(endDateActual.year(),endDateActual.month(),endDateActual.day()).format('MM/dd/yyyy');
                }
                if(i==intCampareVal) {
                    campaignListWrapper.add(new CampaignListWrapper(campaignList[i], true, startDate, endDate, closedOpportunity));
                    opportunityIds.clear();
                } else {
                    campaignListWrapper.add(new CampaignListWrapper(campaignList[i], false, startDate, endDate, closedOpportunity));
                    opportunityIds.clear();
                }
                system.debug('closedOpportunity::: ' + closedOpportunity);
            }
            system.debug(campaignListWrapper.size()+' :::: '+Json.serialize(campaignListWrapper)+'<===campaignListWrapper:::@SK::::======>' + campaignListWrapper.size());
            if(campaignListWrapper.size() > 0) {
                return campaignListWrapper;
            }
        } catch(Exception ex) {
            system.Debug('!ExceptionLine ::: ' + ex.getLineNumber() + ', Exception :::: ' + ex.getMessage());
            return null;
        }
        return null;
    }
    
    @AuraEnabled
    public static list<CampaignListWrapper> getSelectedCampaignDetails(String foundationId, String campaignId) {
        system.debug('foundationId :::: => ' + foundationId + ', campaignId :::: => ' + campaignId);
        
        list<CampaignListWrapper> campaignListWrapper = new list<CampaignListWrapper>();
        list<Campaign> campaignList = new list<Campaign>();
        set<Id> opportunityIds = new set<Id>();
        Integer closedOpportunity;
        String sSoql;
        Date startDateActual;
        String startDate;
        Date endDateActual;
        String endDate;
        
        String columns = 'Id, Name, Status, StartDate, EndDate, NumberOfLeads, NumberOfContacts, NumberOfOpportunities, AmountAllOpportunities, NumberOfWonOpportunities, AmountWonOpportunities ';
        sSoql = 'SELECT ' + columns + 'FROM Campaign WHERE Id =:campaignId AND Project__c =:foundationId';
        system.debug('sSoql ::  ' + sSoql);
        try {
            campaignList = Database.query(sSoql);
            Set<ID> campIds = new Set<ID>();
            for(Campaign cam : campaignList) {
              campIds.add(cam.ID);
            }
            List<Opportunity> oppList = new List<Opportunity>();
            Map<ID,Set<ID>> CampVsOpp = new Map<ID,Set<ID>>();
            oppList = [SELECT Id, CampaignID FROM Opportunity WHERE isClosed=true AND CampaignID IN : campIds];
           
            for(Opportunity obj : oppList) {
                if(CampVsOpp.containsKey(obj.CampaignID)) {
                  CampVsOpp.get(obj.CampaignID).add(obj.ID);
                }else {
                  CampVsOpp.put(obj.CampaignID, new Set<ID>{obj.ID});
                }
            }

            system.debug('campaignList::: ' + campaignList);
            for(integer i=0;i<=campaignList.size()-1;i++) {
                //Code is not bulkified firing soql in for - so made code changes against - SFDC - 1284
                /*for(Opportunity opp: [SELECT Id FROM Opportunity WHERE isClosed=true AND campaignId=:campaignList[i].Id]) {
                    opportunityIds.add(opp.Id);
                }*/
                if(CampVsOpp.containsKey(campaignList[i].id)) {
                    opportunityIds = CampVsOpp.get(campaignList[i].id);
                    if(opportunityIds.size() > 0) {
                        system.debug('opportunityIds.size()::: ' + opportunityIds.size());
                        closedOpportunity = opportunityIds.size();
                    } else { closedOpportunity = 0; }
                }
                system.debug('closedOpportunity::: ' + closedOpportunity);
                if(campaignList[i].StartDate != null) {
                    startDateActual = campaignList[i].StartDate;
                    startDate = DateTime.newInstance(startDateActual.year(),startDateActual.month(),startDateActual.day()).format('MM/dd/yyyy');
                }
                if(campaignList[i].EndDate != null) {
                    endDateActual = campaignList[i].EndDate;
                    endDate = DateTime.newInstance(endDateActual.year(),endDateActual.month(),endDateActual.day()).format('MM/dd/yyyy');
                }
                campaignListWrapper.add(new CampaignListWrapper(campaignList[i], false, startDate, endDate, closedOpportunity));
                opportunityIds.clear();
            }
            system.debug(campaignListWrapper.size()+' :::: '+Json.serialize(campaignListWrapper)+'<===campaignListWrapper:::@SK::::======>' + campaignListWrapper.size());
            if(campaignListWrapper.size() > 0) {
                return campaignListWrapper;
            } 
        } catch(Exception ex) {
            system.Debug('!ExceptionLine ::: ' + ex.getLineNumber() + 'Exception :::: ' + ex.getMessage());
            return null;
        }
        return null;
    }
    
    /* wrapper class */  
    public class CampaignListWrapper {
        @AuraEnabled public  Campaign objCampaign { get; set; }
        @AuraEnabled public boolean isChecked { get; set; }
        @AuraEnabled public  String startDate { get; set; }
        @AuraEnabled public  String endDate { get; set; }
        @AuraEnabled public  Integer closedOpportunity { get; set; }
        public CampaignListWrapper(Campaign objCampaign, boolean isChecked, String startDate,String endDate, Integer closedOpportunity){
            this.objCampaign = objCampaign;
            this.isChecked = isChecked;
            this.startDate = startDate;
            this.endDate = endDate;
            this.closedOpportunity = closedOpportunity;
        }
    }    
}