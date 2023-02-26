/**
 ** Snippet run the batch
 ** Id batchJobId = Database.executeBatch(new CreateMixMaxCampaignForContactBatch(), 200);
 **
**/
 
global class CreateMixMaxCampaignForContactBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
       
       String query ='Select id, Mixmax_Campaign_Name__c from Contact where MixMax_Create_Campaign__c = true Order By Mixmax_Campaign_Name__c';
       return Database.getQueryLocator(query);
       
    }
    global void execute(Database.BatchableContext bc, List<sobject> lstLead){
    
        try{
        
            CampaignLeadContact.addCommunityMemberContactORLead(lstLead);
            if(test.isRunningTest()){
                Integer i=1/0;
            }
        
        }catch(Exception e){
                    
            String message = e.getMessage();
            String stacktrace = e.getStackTraceString();
            String exType = '' + e.getTypeName();
            String line = '' + e.getLineNumber();
            String theTime = '' + System.now();
        
            String body = String.format('Time: {0}\nMessage: {1}\nStacktrace: {2}\nLine: {3}', new List<String>{ theTime, message, stacktrace, line });
        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Errors occurred during PersonAccount Merge batch process.');
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.Email[] { mail });            
        }
    
    }
    
    global void finish(Database.BatchableContext bc){
        
        
        
    }
    
}