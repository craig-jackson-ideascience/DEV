/*Scheduler For APAC Emnail List - to add members to Campaign
* Test Class - AddCampaignMembersGenericBatchTest
*/
public class AddCampaignMembersGenericBatchScheduler implements Schedulable{
    public String query;
    public String contactField;
    public String leadField;
    public String campaignId;
    
    //Constructor
    public AddCampaignMembersGenericBatchScheduler(){}
    public AddCampaignMembersGenericBatchScheduler(String query,String contactField,String leadField,String campaignId){
        this.query = query;
        this.contactField = contactField;
        this.leadField = leadField;
        this.campaignId = campaignId;
    }
    
    //Execute of Scheduler
    public void execute(SchedulableContext sc){
        //Calling the batch Class to execute
        system.debug('query '+query);
        system.debug('contactField '+contactField);
        system.debug('leadField '+leadField);
        system.debug('campaignId '+campaignId);
        Database.executeBatch(new AddCampaignMembersGenericBatch(query, contactField, leadField, campaignId));
        
    }
}