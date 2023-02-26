/* 
* DATE : 05/04/2020
* Developer Name  :  Kalyani Chiluveri    
* Description : This batch class calculate the number of enrollments for specific camapign member. 
*/

global class CalculateEnrollmentsBatch implements Database.Batchable<sObject>  {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
       return Database.getQueryLocator(
            'Select ID, Name, CreatedDate, LeadOrContactId, CampaignId, Campaign.Technology__c '+
            'from CampaignMember where Campaign.LF_Training__c = TRUE AND Campaign.Technology__c != NULL'
        );
    }
    global void execute(Database.BatchableContext bc, List<CampaignMember> scope){

      Map<String,Integer> campMembersVsEnrollments = CalculateEnrollmentsBatchHelper.getCampMemberEnrolls(scope);
        if(!campMembersVsEnrollments.isEmpty()) {
            CalculateEnrollmentsBatchHelper.updateCampaignMembers(campMembersVsEnrollments);
        }

    }       
    global void finish(Database.BatchableContext bc){
    }    
}