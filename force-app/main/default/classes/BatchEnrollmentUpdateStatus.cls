public class BatchEnrollmentUpdateStatus implements Database.Batchable<sObject>,Schedulable {
    String query;
    public void execute(SchedulableContext sc){
        Database.executeBatch(new BatchEnrollmentUpdateStatus());
    }
    
    public BatchEnrollmentUpdateStatus(){
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        this.query ='SELECT Id,Status__c,Completion_Date__c,Start_Date__c,Exam_Expiration_Date__c,ExpirationDate__c,Certification_ExpirationDate__c FROM Enrollment__c WHERE (Status__c=\'Enrolled\' AND Start_Date__c !=null AND Start_Date__c <= Today)'+
            ' OR (Status__c=\'Started\' AND Completion_Date__c != null AND Completion_Date__c <= Today) OR'+
            ' ((Exam_Expiration_Date__c!= null OR ExpirationDate__c != null OR Certification_ExpirationDate__c !=null) AND (Exam_Expiration_Date__c <=Today OR ExpirationDate__c =Today OR Certification_ExpirationDate__c<=Today)'+
            ' AND Completion_Date__c = null AND Status__c NOT IN(\'Revoked\',\'Expired\',\'Not Certified\'))';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Enrollment__c> enrollments){
        List<Enrollment__c> enrollmentToBeUpdated = new List<Enrollment__c>();
        for(Enrollment__c enrollment : enrollments){
            if(enrollment.Status__c == 'Enrolled'&& enrollment.Start_Date__c !=null && enrollment.Start_Date__c <= Date.today()){
                enrollment.Status__c = 'Started';
            }            
            if(enrollment.Status__c =='Started' && enrollment.Completion_Date__c != null && enrollment.Completion_Date__c <=  Date.today()){
                 enrollment.Status__c = 'Completed';
            }
            if(enrollment.Status__c !='Revoked' && enrollment.Status__c != 'Not Started' && enrollment.Completion_Date__c == null &&
               ((enrollment.Certification_ExpirationDate__c== null && (enrollment.Exam_Expiration_Date__c <=Date.today() || enrollment.ExpirationDate__c <= date.today()))
               || enrollment.Certification_ExpirationDate__c <= Date.today())){
                   enrollment.Status__c = 'Expired';
               }
            enrollmentToBeUpdated.add(enrollment);
        }
        
        if(!enrollmentToBeUpdated.IsEmpty()){
            update enrollmentToBeUpdated;
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}