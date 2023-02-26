public class EnrollmentToCampaignMemberBatch implements Database.Batchable<SObject> {
    String query;
    public EnrollmentToCampaignMemberBatch(String parentProductName){
        if(parentProductName != null){
            query='SELECT Id,Parent_Product_Name__c,Product_Code__c,Contact_Name__c,Enrollment_Date__c,Is_Parent_Product_Bootcamp_Campaign__c,'+
                'Lead_Name__c,Certification_AchievementDate__c,Completion_Date__c,Status__c FROM Enrollment__c '+
                'WHERE Parent_Product_Name__c=\'' + parentProductName + '\''+
                ' AND Product_Code__c != null AND '+
                'Enrollment_Date__c != null AND (Contact_Name__c != null OR Lead_Name__c != null)';
        }
    }
    //Start of the batch
    public  Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    //Execute of Batch
    public void execute(Database.BatchableContext BC,List<Enrollment__c> enrollmentList){
        System.debug('enrollmentList '+enrollmentList.size());
        addEnrollmentsAsCampaignMember(enrollmentList);
    }
    
    //Finish of batch
    public void finish(Database.BatchableContext info){
    }
    public static void addEnrollmentsAsCampaignMember(List<Enrollment__c> enrollmentList){
        
        Map<String,Set<String>> parentCampaignVSProductCodes = new Map<String,Set<String>>();
        Set<String> productCodes = new Set<String>();
        Map<Enrollment__c,String> enrollmentVsProductCode = new Map<Enrollment__c,String>();
        Set<Id> leadContactIdSet = new Set<Id>();
        
        for(Enrollment__c enrollment:enrollmentList){
            String parentCampaignName = enrollment.Parent_Product_Name__c == 'Cloud Engineer Boot Camp' || enrollment.Parent_Product_Name__c == null?
                'Cloud Engineer Boot Camp':
            (enrollment.Parent_Product_Name__c != null && enrollment.Is_Parent_Product_Bootcamp_Campaign__c?
            enrollment.Parent_Product_Name__c : '');
                if(String.isNotBlank(parentCampaignName)){
                    if(!parentCampaignVSProductCodes.containsKey(parentCampaignName)){
                        parentCampaignVSProductCodes.put(parentCampaignName,new Set<String>());
                    }parentCampaignVSProductCodes.get(parentCampaignName).add(enrollment.Product_Code__c);
                    
                    productCodes.add('%' + enrollment.Product_Code__c+'%');
                    String status = enrollment.Status__c == 'Completed'? 'Completed' : 'Enrolled';

                    enrollmentVsProductCode.put( enrollment,parentCampaignName+' '+ enrollment.Product_Code__c+ ' ' + status);
                    
                    if(enrollment.Contact_Name__c != null)
                        leadContactIdSet.add(enrollment.Contact_Name__c);
                    else if(enrollment.Lead_Name__c != null)
                        leadContactIdSet.add(enrollment.Lead_Name__c);
                    
                }
        }
        if(!parentCampaignVSProductCodes.isEmpty()){
            Map<String,CampaignMember> campaignMemberList =
                Utility.addCampaignMember(parentCampaignVSProductCodes,productCodes,enrollmentVsProductCode,leadContactIdSet);
            if(!campaignMemberList.isEmpty()){
                //upsert campaignmembers
                upsert campaignMemberList.values();
            }
        }
    }
}