global with sharing class CreateRenewal{
   @AuraEnabled
    WebService static String executeBatchForAutoRenewal(Id asstId){
        Map<ID,Asset> updateAssets = new Map<ID,Asset>();
        
            List<Asset> assetDetail = [SELECT id,OpportunityLineItem__c,UsageEndDate,Renewal_Opportunity_Created__c,order__c,NS_Entity_ID__c,NetSuite_ID__c,
                                       Display_Logo_On_Website__c, Press_Release_Announcement__c,Bill_To_Address__c,Bill_To_Account__c,CNCF_Level__c, Opportunity__c, AccountID ,
                                       Projects__r.Days_to_Deduct__c FROM Asset WHERE id=: asstId AND Opportunity__c !=null];
            
            Map<id,Opportunity> updateOpportunityStages = new Map<id,Opportunity>();
            
            RenewalClassForOpps ren = new RenewalClassForOpps();
            
            List<Opportunity> renewalOpps = new List<Opportunity>();
        
            
            system.debug('____assetDetail___size___'+assetDetail.size());
            
            updateAssets = ren.setCheckboxOnAsset(assetDetail);
            
            renewalOpps = ren.createRenewalOpps(assetDetail);
            
        	Map<Id,String> parentAssetIdVsRenewalOppName = new Map<Id,String>();
            if(renewalOpps!=null && renewalOpps.size()>0){
                updateOpportunityStages = ren.updateOppStageForRenewalOpps(renewalOpps);
                parentAssetIdVsRenewalOppName=ren.getParentAssetVsRenewalNameMap(renewalOpps);
                //ren.createTasksForRenewalOpps(renewalOpps);     
            }
            if(updateOpportunityStages!=null && updateOpportunityStages.size()>0)
                update updateOpportunityStages.values();
            
            if(updateAssets!=null && updateAssets.size()>0){
                    updateAssets.values()[0].Renewal_Opportunity_Created__c = true;
                    updateAssets.values()[0].Marked_for_Renewal_Processing__c = false;
                 	updateAssets.values()[0].Renewal_Opportunity_Name__c = parentAssetIdVsRenewalOppName.containsKey(updateAssets.values()[0].Id)?
                    		parentAssetIdVsRenewalOppName.get(updateAssets.values()[0].Id):'';
                    update updateAssets.values();
                }
        	return null;
        
    }
}