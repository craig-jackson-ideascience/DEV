/* Batch Class to Rollup campaign members to Subscription Center Campaign
 * Scheduled at:5 AM and 6PM
 * Test Class - MembersRolUpToSubsCampBatchTest
*/
public class MembersRollUpToSubscriptionCampaignBatch implements Database.Batchable<SObject>,Schedulable{
    Map<Id,Id> projectVSCampaignIdMap = new Map<Id,Id>();
    DateTime lastFifteenHours;
    
    //Schedule 's Execute method to call batch
    public void execute(SchedulableContext sc){
        Database.executeBatch(new MembersRollUpToSubscriptionCampaignBatch());
    }
    
    public MembersRollUpToSubscriptionCampaignBatch() {
        this.lastFifteenHours = System.Now().addHours(-15);
        List<Campaign> subscriptionCampaign =[select  Id,name,project__c from campaign 
        where type = 'Subscription Center' and LF_Events__c=false and LF_Training__c=false];
        for(Campaign camp :subscriptionCampaign){
            projectVSCampaignIdMap.put(camp.project__c,camp.Id);
        }
        
    }
    //Start of the batch
    public  Database.QueryLocator start(Database.BatchableContext BC){
        String query = Label.MembersRollUpSubscription_batch_Query;
        System.debug('query '+query);
        
        return Database.getQueryLocator(query);
    }
    
    //Execute of Batch
    public void execute(Database.BatchableContext BC,List<CampaignMember> campaignMemberList ){
        system.debug('campaignMemberList '+campaignMemberList.size());
        List<CampaignMember> listOfCampMemberToInsert = MemberRolUpExecuteMethod.getPreparedListOfCampMemberToInsert(campaignMemberList, projectVSCampaignIdMap);
        if (!listOfCampMemberToInsert.isEmpty()){
            Database.SaveResult[] insertResults = Database.insert(listOfCampMemberToInsert, false);
            for (Database.SaveResult sr : insertResults){
                System.debug('success '+sr);
                if (!sr.isSuccess() && sr.getErrors() != null){
                    system.debug('sr ' + sr);
                }
            }
            
        }
    }
    
    
    //Finish of batch
    public void finish(Database.BatchableContext info){
    }
    
}