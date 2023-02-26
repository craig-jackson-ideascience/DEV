@isTest
public class TuxRewardsExpirationHandlerTest{

    static String contact_email = 'BugsBunny@gmail.com';

    @TestSetup
    static void setup() {
        Campaign campaign_tux_rewards = new Campaign(Name='Tux Rewards');
        insert campaign_tux_rewards;
        insert new TuxRewardsCampaignData__c(
            Name='campaign_name',
            Campaign_ID__c=campaign_tux_rewards.Id
        );
        Contact contact = new Contact(
            FirstName = 'Bugs',
            LastName = 'Bunny',
            Email = TuxRewardsExpirationHandlerTest.contact_email,
            TuxMember__c = True,
            TuxRewards__c = 501,
            tux_rewards_most_recent_coupon_gen_date__c = System.DateTime.now().addYears(-4)
        );
        insert contact;
        insert new CampaignMember(
            CampaignId = campaign_tux_rewards.Id,
            ContactId = contact.Id,
            Status = 'Enrolled'
        );
    }

    static void helper_validate() {

        List<Contact> contact_list = [SELECT Id, TuxMember__c, TuxRewards__c
            FROM Contact
            WHERE Email = :TuxRewardsExpirationHandlerTest.contact_email];
        System.assertEquals(1, contact_list.size());
        Contact contact = contact_list[0];
        System.assertEquals(False, contact.TuxMember__c);
        System.assertEquals(0, contact.TuxRewards__c);
        
        TuxRewardsCampaignData__c setting = TuxRewardsCampaignData__c.getInstance('campaign_name');
        Id campaign_id = setting.Campaign_ID__c;

        List<CampaignMember> campaign_member_list = [SELECT Id, Status
            FROM CampaignMember
            WHERE CampaignId = :campaign_id];
        System.assertEquals(1, campaign_member_list.size());

    }

    @isTest
    static void unspecified_query_test() {
        Test.startTest();
        Database.executeBatch(new TuxRewardsExpirationHandler());
        Test.stopTest();
        TuxRewardsExpirationHandlerTest.helper_validate();
    }

    @isTest
    static void specified_query_test() {
        DateTime three_years_ago = System.now().Date().addYears(-3);
        String three_years_ago_str = three_years_ago.format('yyyy-MM-dd');
        String query = 'SELECT Id, '
            + 'TuxMember__c, '
            + 'TuxRewards__c '
            + 'FROM Contact '
            + 'WHERE tux_rewards_most_recent_coupon_gen_date__c <= ' + three_years_ago_str + 'T00:00:00.000+0000 '
            + 'AND (TuxMember__c = True OR TuxRewards__c > 0)';
        Test.startTest();
        Database.executeBatch(new TuxRewardsExpirationHandler(query));
        Test.stopTest();
        TuxRewardsExpirationHandlerTest.helper_validate();
    }

    @isTest
    static void specified_query_no_records_test() {
        DateTime five_years_ago = System.now().Date().addYears(-5);
        String five_years_ago_str = five_years_ago.format('yyyy-MM-dd');
        String query = 'SELECT Id, '
            + 'TuxMember__c, '
            + 'TuxRewards__c '
            + 'FROM Contact '
            + 'WHERE tux_rewards_most_recent_coupon_gen_date__c <= ' + five_years_ago_str + 'T00:00:00.000+0000 '
            + 'AND (TuxMember__c = True OR TuxRewards__c > 0)';

        List<Contact> contact_list = Database.query(query);
        System.assertEquals(0, contact_list.size());

        Test.startTest();
        Database.executeBatch(new TuxRewardsExpirationHandler(query));
        Test.stopTest();

        List<Contact> contact_list_post = [SELECT Id, TuxMember__c, TuxRewards__c
            FROM Contact
            WHERE Email = :TuxRewardsExpirationHandlerTest.contact_email];
        System.assertEquals(1, contact_list_post.size());
        Contact contact_post = contact_list_post[0];
        System.assertEquals(True, contact_post.TuxMember__c);
        System.assertEquals(501, contact_post.TuxRewards__c);

    }

}