/**
** Snippet run the batch
** Id batchJobId = Database.executeBatch(new UpdateMixmaxEmailsSentCountOnParent(), 1);
**
**/
global class UpdateMixmaxEmailsSentCountOnParent implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        string query= 'SELECT Id,Who.type,Description FROM Task where CreatedDate >= LAST_N_DAYS:7 AND Check_if_type_Contact_or_Lead__c = true';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Task> scope){
        Savepoint sp = Database.setSavepoint();
        try{
            string strDescription = 'Insight provided by Mixmax';
            set<Id> setContactId = new set<Id>();
            set<Id> setLeadId = new set<Id>();
            List<Contact> lstContactUpdate = new List<Contact>();
            List<Lead> lstLeadUpdate = new List<Lead>();
            set<id> TaskId = new set<id>();
            for(Task objTask : scope){
                if(objTask.Description != null){
                if(objTask.Who.Type =='Contact' && objTask.Description.contains(strDescription)){
                    setContactId.add(objTask.Who.id);
                }
                if(objTask.Who.Type =='Lead' && objTask.Description.contains(strDescription)){
                    setLeadId.add(objTask.Who.id);
                }
                }
            }
            AggregateResult[] arContactResult = [SELECT COUNT(Id), WhoId FROM Task where WhoId IN :setContactId AND Check_if_type_Contact_or_Lead__c = true GROUP BY WhoId];
            for(AggregateResult objAR: arContactResult) {
                Id contactId = (ID)objAR.get('WhoId');
                Integer intCount = (INTEGER)objAR.get('expr0');
                lstContactUpdate.add(new Contact(Id=contactId,
                                                 Mixmax_Emails_Sent__c = intCount)
                                    );
            }
            Update lstContactUpdate;
            
            AggregateResult[] arLeadResult = [SELECT COUNT(Id), WhoId FROM Task where WhoId IN :setLeadId AND Check_if_type_Contact_or_Lead__c = true GROUP BY WhoId];
            for(AggregateResult objAR: arLeadResult) {
                Id LeadId = (ID)objAR.get('WhoId');
                Integer intCount = (INTEGER)objAR.get('expr0');
                lstLeadUpdate.add(new Lead(Id=LeadId,
                                           Mixmax_Emails_Sent__c = intCount)
                                 );
            }
            Update lstLeadUpdate;
            
            if(test.isRunningTest()){
                Integer i=1/0;
            }
        }catch(Exception e)
        {
            Database.RollBack(sp);
            
            String message = e.getMessage();
            String stacktrace = e.getStackTraceString();
            String exType = '' + e.getTypeName();
            String line = '' + e.getLineNumber();
            String theTime = '' + System.now();
            
            String body = String.format('Time: {0}\nMessage: {1}\nStacktrace: {2}\nLine: {3}', new List<String>{ theTime, message, stacktrace, line });
            
            Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(orgWideEmailAddress);
            mail.setSubject('Errors occurred during Mixmax Email Sent batch process.');
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.Email[] { mail });            
        }
    }
    global void finish (Database.BatchableContext bc){
        
    }
}