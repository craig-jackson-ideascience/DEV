/* 
* DATE : 05/04/2020
* Developer Name  :  Kalyani Chiluveri    
* Description : Helper Class for PopulateRollUpSummaryDetailsBatch. 
*/

public with sharing class CalculateEnrollmentsBatchHelper {

    public static Map<String,List<CampaignMember>> campIDVSCampMembers;
    
    public static Map<String,Integer> getCampMemberEnrolls(List<CampaignMember> memberList){
        Map<String,Integer> campMembersVsEnrollments = new Map<String,Integer>();
        Integer countOfEnrollments = 0;

        Map<String,List<Enrollment__C>> campMemberVsEnrolls = getEnrollments(memberList);
        
        for(String ID : campIDVSCampMembers.keySet()) {
            for(CampaignMember campMember : campIDVSCampMembers.get(ID)) {
                if(campMemberVsEnrolls.containsKey(campMember.LeadOrContactId)) {
                    for (Enrollment__c obj : campMemberVsEnrolls.get(campMember.LeadOrContactId)) {
                        if(obj.CreatedDate > campMember.CreatedDate) {
                            if(checkTechnologyAvailaibility(obj.Product_Name__r.Technology__c, campMember.Campaign.Technology__c)) {
                                countOfEnrollments += 1;
                            }
                        }
                    }
                    campMembersVsEnrollments.put(campMember.ID,countOfEnrollments);
                    countOfEnrollments = 0;
                }
            }
        }
        return campMembersVsEnrollments;
    }

    public static Map<String,List<Enrollment__C>> getEnrollments(List<CampaignMember> memberList) {
        Set<ID> campaignMembers = getCampaignMember(memberList);
       
        Map<String,List<Enrollment__C>> campMemberVsEnrolls = new Map<String,List<Enrollment__C>>();
        List<Enrollment__c> enrollList = [SELECT Contact_Name__c, Id, Lead_Name__c, Name, CreatedDate, Product_Name__r.Technology__c, Product_Name__c
                                            FROM Enrollment__c
                                            WHERE (Contact_Name__c IN :campaignMembers OR Lead_Name__c IN :campaignMembers)
                                            AND (Contact_Name__c != NULL OR Lead_Name__c!= NULL) AND Product_Name__c != NULL AND Product_Name__r.Technology__c != NULL];
        

        for(Enrollment__c rec : enrollList) {
            String ID = rec.Contact_Name__c != NULL ? rec.Contact_Name__c : rec.Lead_Name__c;
            if(campMemberVsEnrolls.containsKey(ID)) {
                campMemberVsEnrolls.get(ID).add(rec);
            }
            else {
                campMemberVsEnrolls.put(ID,new List<Enrollment__c>{rec});
            }
        }
        return campMemberVsEnrolls;     
    }

    public static Set<ID> getCampaignMember(List<CampaignMember> campaignMember) {
        Set<ID> campMembers = new Set<ID>();
        campIDVSCampMembers = new Map<String, List<CampaignMember>>();
        for(CampaignMember campMem :  campaignMember) {
            campMembers.add(campMem.LeadOrContactId);
            if(campIDVSCampMembers.containsKey(campMem.CampaignId)) {
                campIDVSCampMembers.get(campMem.CampaignId).add(campMem);
            }else {
                campIDVSCampMembers.put(campMem.CampaignId, new List<CampaignMember>{campMem});
            }
        }
        return campMembers;
    }

    public static Boolean checkTechnologyAvailaibility(String prodTech, String campTech) {
        List<String> prodTechList = prodTech.split(';');
        List<String> campTechList = campTech.split(';');
        Boolean courseAvailable = FALSE;
        for(String tech : campTechList) {
            if(prodTechList.contains(tech)) {
                courseAvailable = TRUE;
                break;
            }
        }
        return courseAvailable;
    }

    public static void updateCampaignMembers(Map<String,Integer> campMembersVsEnrollments) {
        
        List<CampaignMember> campMemberList = new List<CampaignMember>();
        for (String id : campMembersVsEnrollments.keySet()) {
            CampaignMember campMemRec = new CampaignMember();
            campMemRec.ID = ID;
            campMemRec.CountOfEnrollments__c = campMembersVsEnrollments.get(id);
            campMemberList.add(campMemRec);
        }
        update campMemberList;
    }
}