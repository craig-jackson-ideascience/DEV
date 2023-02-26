/*
 Created by Cloudroute on 02-02-2021
 Common class to be called from MemberRolUpBatch & trigger
 */
public with sharing class MemberRolUpExecuteMethod{
	public static List<CampaignMember> getPreparedListOfCampMemberToInsert(List<CampaignMember> campaignMemberList, Map<Id, Id> projectVSCampaignIdMap){
		List<CampaignMember> campMemberToInsert = new List<CampaignMember>();
		for (CampaignMember campaignMember : campaignMemberList){
			if (projectVSCampaignIdMap.containsKey(campaignMember.campaign.Project__c)){
				CampaignMember campMember = new CampaignMember();
				campMember.CampaignId = projectVSCampaignIdMap.get(campaignMember.campaign.Project__c);
				Id leadContactId;
				if (campaignMember.contactId != null){
					leadContactId = campaignMember.contactId;
					campMember.contactId = campaignMember.contactId;
				} else{
					leadContactId = campaignMember.LeadId;
					campMember.LeadId = campaignMember.LeadId;
				}
				campMemberToInsert.add(campMember);
			}
		}
		return campMemberToInsert;
	}
}