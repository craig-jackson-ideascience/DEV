public class BootCampHelper {
    
    
    public static Map<String,Campaign> getCampaigns(Set<String> productCodes){
        System.debug('productCodes'+productCodes);
        Map<String,Campaign> productCodeVsCampaign = new Map<String,Campaign>();
        for(Campaign campaign : [SELECT Id,Name FROM Campaign WHERE Parent.Name='LF Training Bootcamp June 2020' 
                                 AND Name LIKE : productCodes]){
                                     for(String productCode : productCodes){
                                         productCode = productCode.replace('%', '');           
                                         //Create map of ProductcodeVsCampaign
                                         if(campaign.Name.Contains(productCode)){
                                             productCodeVsCampaign.put(productCode,campaign);
                                             break;
                                         }
                                     }
                                 }
        return productCodeVsCampaign;
    }
    
    public static Map<Id,Map<Id,CampaignMember>> getExistingCampaignMembers(Set<Id> campaignIds){
        Map<Id,Map<Id,CampaignMember>> campaignMembersById = new Map<Id,Map<Id,CampaignMember>>();
        for(CampaignMember member : [SELECT Id,CampaignId,Email,ContactId,LeadId,Status FROM CampaignMember WHERE CampaignId IN : campaignIds]){
            if(!campaignMembersById.containsKey(member.CampaignId)){
                campaignMembersById.put(member.CampaignId,new Map<Id,CampaignMember>()); 
            }
            Id leadContactId = member.ContactId != null ? member.ContactId : member.LeadId;
            campaignMembersById.get(member.CampaignId).put(leadContactId,member);
        }
        return campaignMembersById;
    }
    
    
    public static void upsertCampaignMember(Map<String,List<Enrollment__c>> productCodeVsEnrollment , Set<String> productCodes){
        //get campaigns
        Map<String,Campaign> productCodeVsCampaign = getCampaigns(productCodes);
        if(!productCodeVsCampaign.IsEmpty()){
            Set<Id> campaignIds = new Set<Id>();
            for(Campaign campaign : productCodeVsCampaign.values()){
                campaignIds.add(campaign.Id);
            }
            
            //get existing campaign Members for the campaign
            Map<Id,Map<Id,CampaignMember>> existingMembersByCampaignId = getExistingCampaignMembers(campaignIds);
            List<CampaignMember> campaignMemberList = new List<CampaignMember>();
            //update campaign members
            for(String productCode : productCodeVsEnrollment.keySet()){
                if(productCodeVsCampaign.containsKey(productCode)){
                    Campaign campaign = productCodeVsCampaign.get(productCode);
                    //get existing members
                    Map<Id,CampaignMember> existingMembersById = new Map<Id,CampaignMember>();
                    if(existingMembersByCampaignId.containsKey(campaign.Id)){
                        existingMembersById =existingMembersByCampaignId.get(campaign.Id);
                    }
                    //for each enrollment process
                    for(Enrollment__c enrollment : productCodeVsEnrollment.get(productCode)){
                        CampaignMember member = new CampaignMember();
                        Id enrollmentLeadContactId;
                        if(String.isNotBlank(enrollment.Contact_Name__c)){
                            member.ContactId  =enrollment.Contact_Name__c;
                            enrollmentLeadContactId =	enrollment.Contact_Name__c;
                        }else{
                            member.LeadId = enrollment.Lead_Name__c;
                            enrollmentLeadContactId = enrollment.Lead_Name__c;
                        }
                        
                        member.CampaignId = campaign.Id;
                        if(enrollment.Certification_ExpirationDate__c < Date.TODAY() || enrollment.ExpirationDate__c < Date.TODAY()){
                            member.Status = 'Expired';
                        }
                        if(existingMembersById.containsKey(enrollmentLeadContactId)){
                            member.Id = existingMembersById.get(enrollmentLeadContactId).Id;
                        }
                        campaignMemberList.add(member);
                    }
                }
            }
            System.debug('campaignMemberList'+campaignMemberList);
            if(!campaignMemberList.isEmpty()){
                //insert campaignmembers
                upsert campaignMemberList;
            }
        }
    }
}