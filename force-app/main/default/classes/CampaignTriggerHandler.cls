public with sharing class CampaignTriggerHandler implements ITriggerHandler {
    public static void BeforeInsert(List<Sobject> triggerNew) {}
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {}
    public static void AfterDelete(Map<Id, Sobject> oldMap) {}
    public static void AfterInsert(Map<Id, SObject> newMap) {}
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {}

    public Boolean IsDisabled() {
        return false;
    }

    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap) {
        isHubSpotOrFinosHubspotChecked((Map<Id, Campaign>) newMap,(Map<Id, Campaign>) oldMap);
    }

    public static void BeforeDelete(Map<Id, Sobject> campaign_map) {
        List<Campaign> campaign_list = campaign_map.values();
        prevent_delete_if_tux_rewards(campaign_list);
    }

    // Prevents deletion of the Tux Rewards campaign, as specified by the ID in
    // the custom setting
    private static void prevent_delete_if_tux_rewards(List<Campaign> campaign_list){
        TuxRewardsCampaignData__c setting = TuxRewardsCampaignData__c.getInstance('campaign_name');
        Id tux_rewards_campaign_id = setting.Campaign_ID__c;
        for(Campaign campaign : campaign_list) {
            if(campaign.Id == tux_rewards_campaign_id) {
                campaign.addError('The Tux Rewards campaign must not be removed');
            }
        }
    }

    // Checks the Campaign to see if it is part of the Hubspot integrations
    // (either LF or FINOS). If it is, triggers additional logic
    public static void isHubSpotOrFinosHubspotChecked(Map<Id, Campaign> newMap, Map<Id, Campaign> oldMap){
        Set<Id> campaignIdSet = new Set<Id>();
        for(Campaign campaign : newMap.values()) {
            Campaign oldCampaign = oldMap.get(campaign.Id);
            if(
                (campaign.Hubspot__c && !oldCampaign.Hubspot__c)
                || (campaign.Finos_Hubspot__c && !oldCampaign.Finos_Hubspot__c)
            ){
                campaignIdSet.add(campaign.Id);
            }
        }
        if(!campaignIdSet.isEmpty()){
            Database.executeBatch(new UpdateContactLeadForHubSpotCampaignBatch(campaignIdSet));
        }
    }

}