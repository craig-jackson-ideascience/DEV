// After three years of no eligible purchases, the customer is un-enrolled and the points are reset to zero.
public class TuxRewardsExpirationHandler implements Database.Batchable<sObject>{
    String query;
    public TuxRewardsExpirationHandler(String query){
        this.query = query;
    }
    public TuxRewardsExpirationHandler(){
        DateTime three_years_ago = System.now().Date().addYears(-3);
        String three_years_ago_str = three_years_ago.format('yyyy-MM-dd');
        this.query = 'SELECT Id, '
            + 'TuxMember__c, '
            + 'TuxRewards__c '
            + 'FROM Contact '
            + 'WHERE tux_rewards_most_recent_coupon_gen_date__c <= ' + three_years_ago_str + 'T00:00:00.000+0000 '
            + 'AND (TuxMember__c = True OR TuxRewards__c > 0)';
        System.debug(this.query);
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> contact_list) {
        update_contacts(contact_list);

        Set<Id> contact_id_list = new Set<Id>();
        for(Contact contact : contact_list) {
            contact_id_list.add(contact.Id);
        }
        remove_contacts_from_campaign(contact_id_list);
    }
    private void update_contacts(List<Contact> contact_list) {
        if (!contact_list.isEmpty()){
            for(Contact contact : contact_list) {
                contact.TuxMember__c = False;
                contact.TuxRewards__c = 0;
            }
            update contact_list;
        }
    }
    private void remove_contacts_from_campaign(Set<Id> contact_id_list) {

        TuxRewardsCampaignData__c setting = TuxRewardsCampaignData__c.getInstance('campaign_name');
        Id campaign_id = setting.Campaign_ID__c;
        // TODO Verify that Campaign ID exists and is valid

        List<CampaignMember> campaign_member_list = [SELECT Id, Status
            FROM CampaignMember
            WHERE CampaignId = :campaign_id
            AND ContactId IN :contact_id_list];
        for (CampaignMember campaign_member : campaign_member_list) {
            campaign_member.status = 'Unenrolled';
        }
        if (!campaign_member_list.isEmpty()){
            update campaign_member_list;
        }
    }
    public void finish(Database.BatchableContext bc){}
}