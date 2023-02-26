@isTest
public class TuxRewardsPurchaseHandlerTest{

    static Campaign campaign = new Campaign(Name = 'Tux Rewards');
    static Contact scooby = new Contact(
        FirstName = 'Scooby',
        LastName = 'Doo',
        Email = 'scooby.doo@mysteries-inc.com'
    );
    static Contact scrappy = new Contact(
        FirstName = 'Scrappy',
        LastName = 'Doo',
        Email = 'scrappy.doo@mysteries-inc.com'
    );
    static Contact shaggy = new Contact(
        FirstName = 'Shaggy',
        LastName = 'Rogers',
        Email = 'shaggy.doo@mysteries-inc.com'
    );

    private static List<Id> build_contact_id_list(){
        List<String> contact_email_list = new List<String>{
            TuxRewardsPurchaseHandlerTest.scooby.Email,
            TuxRewardsPurchaseHandlerTest.scrappy.Email,
            TuxRewardsPurchaseHandlerTest.shaggy.Email
        };
        System.assertEquals(3, contact_email_list.size());

        List<Contact> contact_list = [SELECT Id, FirstName
            FROM Contact
            WHERE Email IN :contact_email_list
            ORDER BY FirstName];
        TuxRewardsPurchaseHandler.logHelper('contact_list: ' + contact_list);
        System.assertEquals(3, contact_list.size());

        List<Id> contact_id_list = new List<Id>();
        for(Contact contact : contact_list) {
            contact_id_list.add(contact.Id);
        }
        System.assertEquals(3, contact_id_list.size());

        return contact_id_list;
    }

    @testSetup
    static void setup(){
        insert TuxRewardsPurchaseHandlerTest.campaign;
        insert TuxRewardsPurchaseHandlerTest.scooby;
        insert TuxRewardsPurchaseHandlerTest.scrappy;
        insert TuxRewardsPurchaseHandlerTest.shaggy;
        insert new CampaignMember(
            CampaignId = TuxRewardsPurchaseHandlerTest.campaign.Id,
            ContactId = TuxRewardsPurchaseHandlerTest.scooby.Id,
            Status = 'Enrolled'
        );
        insert new CampaignMember(
            CampaignId = TuxRewardsPurchaseHandlerTest.campaign.Id,
            ContactId = TuxRewardsPurchaseHandlerTest.scrappy.Id,
            Status = 'Unenrolled'
        );
        insert new TuxRewardsCampaignData__c(
            Name='campaign_name',
            Campaign_ID__c=TuxRewardsPurchaseHandlerTest.campaign.Id
        );
    }

    @isTest
    static void add_contacts_to_tux_campaign_test() {

        List<Id> contact_id_list = TuxRewardsPurchaseHandlerTest.build_contact_id_list();
        System.assertEquals(3, contact_id_list.size());
        Set<Id> contact_id_set = new Set<Id>(contact_id_list);
        System.assertEquals(3, contact_id_set.size());

        Id campaign_id = TuxRewardsPurchaseHandler.get_tux_rewards_campaign_id();
        System.assert(!String.isBlank(campaign_id));
        TuxRewardsPurchaseHandler.logHelper('campaign_id: ' + campaign_id);

        List<Campaign> campaign_list = [SELECT Id, Name FROM Campaign WHERE Id = :campaign_id];
        System.assertEquals(1, campaign_list.size());

        System.assertEquals(3, contact_id_set.size());
        Test.startTest();
        TuxRewardsPurchaseHandler.add_contacts_to_tux_campaign(contact_id_set);
        Test.stopTest();
        System.assertEquals(3, contact_id_set.size());

        List<CampaignMember> campaign_member_list = TuxRewardsPurchaseHandler.get_tux_rewards_campaign_members(campaign_id, contact_id_set);
        String cm_log = '';
        for(CampaignMember member : campaign_member_list) {
            cm_log += 'ContactId ='+member.ContactId+', Status ='+member.Status+',\n';
        }
        TuxRewardsPurchaseHandler.logHelper(cm_log);

        System.assertEquals(3, campaign_member_list.size());

        Set<String> member_status = new Set<String>{'Enrolled', 'Sent'};
        String member_status_str = String.join((Iterable<String>)member_status, ',');
        for(CampaignMember member : campaign_member_list) {
            String status = member.Status;
            System.assert(member_status.contains(status),
                'Member Status not in ' + member_status_str);
        }

    }
}