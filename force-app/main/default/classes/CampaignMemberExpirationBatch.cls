public class CampaignMemberExpirationBatch implements Database.Batchable<sObject>,Schedulable {
	String query ='';
    public CampaignMemberExpirationBatch(String query){
        this.query = query;
    }
    
    public void execute(SchedulableContext sc){
        Database.executeBatch(new CampaignMemberExpirationBatch());
    }
    
    public CampaignMemberExpirationBatch(){
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        if(String.isBlank(query)){
            this.query = 'SELECT ID,Certification_ExpirationDate__c,ExpirationDate__c,Product_Code__c,Contact_Name__c,Lead_Name__c FROM Enrollment__c WHERE '+
                '(Certification_ExpirationDate__c = yesterday OR ExpirationDate__c = yesterday) AND Product_Code__c != null AND'+
                '(isBootcampbundle__c = True OR Parent_Product_Name__c = \'Cloud Engineer Boot Camp\')';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Enrollment__c> enrollments){
        Map<String,List<Enrollment__c>> productCodeVsEnrollment = new Map<String,List<Enrollment__c>>();
        Set<String> productCodes = new Set<String>();
        for(Enrollment__c enrollment :enrollments){
            productCodes.add('%' + enrollment.Product_Code__c+'%');
            //create a map of ProductIdVsEnrollmentList
            if(!productCodeVsEnrollment.containsKey(enrollment.Product_Code__c)){
                productCodeVsEnrollment.put(enrollment.Product_Code__c,new List<Enrollment__c>());
            }productCodeVsEnrollment.get(enrollment.Product_Code__c).add(enrollment);
        }
        
        if(!productCodeVsEnrollment.isEmpty()){
            BootCampHelper.upsertCampaignMember(productCodeVsEnrollment,productCodes);
        }
    }
    
     public void finish(Database.BatchableContext bc){
        
    }
}