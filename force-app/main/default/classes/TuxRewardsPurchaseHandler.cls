public class TuxRewardsPurchaseHandler {

    public static void logHelper(String message) {
        String padding = '\n    TuxRewardsPurchaseHandler --------------------------------\n';
        System.debug(padding + '    ' + message + padding);
    }

    public static Contact load_contact(Id contact_id) {
        return [SELECT Id,
            FirstName,
            tux_rewards_first_coupon_gen_date__c,
            tux_rewards_most_recent_coupon_gen_date__c,
            TuxMember__c,
            TuxRewards__c
            FROM Contact
            WHERE Contact.Id = :contact_id];
    }

    public static Id get_tux_rewards_campaign_id(){
        TuxRewardsCampaignData__c setting = TuxRewardsCampaignData__c.getInstance('campaign_name');
        Id campaign_id = setting.Campaign_ID__c;
        if(String.isBlank(campaign_id)) {
            TuxRewardsPurchaseHandler.logHelper('could not find the Tux Campaign ID');
            throw new NoDataFoundException();
        }
        TuxRewardsPurchaseHandler.logHelper('campaign_id: ' + campaign_id);
        return campaign_id;
    }

    public static List<CampaignMember> get_tux_rewards_campaign_members(
        Id campaign_id, Set<Id> contact_id_set
    ){
        TuxRewardsPurchaseHandler.logHelper(
            'get_tux_rewards_campaign_members' + '\n' +
            'campaign_id: ' + campaign_id + '\n' +
            'contact_id_set: ' + String.join((Iterable<Id>)contact_id_set, ',')
        );
        List<CampaignMember> campaign_member_list = [SELECT Id,
            ContactId, Status
            FROM CampaignMember
            WHERE CampaignId = :campaign_id
            AND ContactId IN :contact_id_set];
        return campaign_member_list;
    }

    public static void add_contacts_to_tux_campaign(Set<Id> contact_id_set) {

        Set<id> contact_id_set_needing_insert = contact_id_set.clone();

        Id campaign_id = TuxRewardsPurchaseHandler.get_tux_rewards_campaign_id();

        Campaign campaign = [SELECT Id, Name FROM Campaign WHERE Id = :campaign_id];
        if(String.isBlank(campaign.Id)) {
            TuxRewardsPurchaseHandler.logHelper('could not find the Campaign with the corresponding Id of ' + campaign_id);
            throw new NoDataFoundException();
        }

        TuxRewardsPurchaseHandler.logHelper('campaign name: ' + campaign.Name);

        List<CampaignMember> campaign_member_list = TuxRewardsPurchaseHandler.get_tux_rewards_campaign_members(campaign_id, contact_id_set);

        List<CampaignMember> campaign_members_to_update = new List<CampaignMember>();
        for(CampaignMember campaign_member : campaign_member_list) {
            TuxRewardsPurchaseHandler.logHelper('campaign_member.ContactId ' + campaign_member.ContactId + ' exists so will be updated');
            contact_id_set_needing_insert.remove(campaign_member.ContactId);
            if(campaign_member.Status != 'Enrolled') {
                campaign_member.Status = 'Enrolled';
                campaign_members_to_update.add(campaign_member);
            }
        }

        TuxRewardsPurchaseHandler.logHelper('campaign_members_to_update: ' + campaign_members_to_update.size());
        if(!campaign_members_to_update.isEmpty()) {
            update campaign_members_to_update;
        }

        List<CampaignMember> campaign_members_to_insert = new List<CampaignMember>();
        for(Id contact_id : contact_id_set_needing_insert) {
            TuxRewardsPurchaseHandler.logHelper('will create CampaignMember for contact_id ' + contact_id);
            campaign_members_to_insert.add(new CampaignMember(
                CampaignId = campaign_id,
                ContactId = contact_id,
                Status = 'Enrolled'
            ));
        }

        TuxRewardsPurchaseHandler.logHelper('campaign_members_to_insert: ' + campaign_members_to_insert.size());
        if(!campaign_members_to_insert.isEmpty()) {
            insert campaign_members_to_insert;
        }

    }

}