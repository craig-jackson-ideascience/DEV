@isTest
public class CampaignTriggerHandlerTest {

    @isTest
    static void test_prevent_delete_if_tux_rewards(){

        Campaign campaign = new Campaign(Name='Any other campaign');
        insert campaign;
        Campaign campaign_tux_rewards = new Campaign(Name='Tux Rewards');
        insert campaign_tux_rewards;

        // This custom setting controls which Campaign is protected
        insert new TuxRewardsCampaignData__c(
            Name='campaign_name',
            Campaign_ID__c=campaign_tux_rewards.Id
        );

        // Confirms we are not blocked from deleting a typical Campaign record
        try {
            delete campaign;
        } catch (DmlException e) {
            System.assert(False, 'Unexpected error when deleting a non-protected Campaign record');
        }

        // Confirms we are blocked from deleting Tux Rewards
        try {
            delete campaign_tux_rewards;
            System.assert(False);
        } catch (DmlException e) {
            String expected_string = 'The Tux Rewards campaign must not be removed';
            String actual_exception = e.getMessage();
            System.assert(actual_exception.contains(expected_string),
                'Expected error message `'+expected_string+'` was not found, actual was `'+actual_exception+'`');
        }

    }

}