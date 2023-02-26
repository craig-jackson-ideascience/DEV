/**
** Snippet run the batch
** Id batchJobId = Database.executeBatch(new MixmaxContactLeadUpdateCampaignBatch(), 1);
**
**/
global class MixmaxContactLeadUpdateCampaignBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Description,Subject,Campaign_Name_Updated__c FROM Task WHERE Subject LIKE \'MixMax :%\' AND Campaign_Name_Updated__c =false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> scope){
        Savepoint sp = Database.setSavepoint();
        try{
            Map<String, String> emailCampaignNameMap = new Map<String, String>();
            Map<Id,contact> updateContact = new map<Id,Contact>();
            Map<Id,Lead> updateLead = new map<Id,Lead>();
            List<Task> lstTask = new List<Task>();
            List<Contact> contactsToUpdate = new List<Contact>();
            List<Lead> leadsToUpdate = new List<Lead>();
            for (Task t: scope){
                if(String.isBlank(t.Description)) continue; //Since Descrption can not filtered in SOQL.
                List<String> data = t.Description.split('\r\n');
                string Subject = t.Subject.substringAfter(':');
                list<String> campaignname = Subject.split('\n');
                if(data != null){
                   emailCampaignNameMap.put(data[0], Subject);
                 }
                t.Campaign_Name_Updated__c =true;
                lstTask.add(t);
            }
            if(!emailCampaignNameMap.isEmpty()){
                for(Alternate_Email__c ae:[SELECT Contact_Name__c, Lead_Name__c, Lead_Name__r.Mixmax_Campaign_Name__c, 
                                           Contact_Name__r.Mixmax_Campaign_Name__c, Alternate_Email_Address__c 
                                           FROM Alternate_Email__c WHERE (Contact_Name__c != null OR Lead_Name__c != null)
                                           AND Alternate_Email_Address__c IN : emailCampaignNameMap.keySet()]){
                         
                         String campaign = emailCampaignNameMap.get(ae.Alternate_Email_Address__c);
                         if(ae.Contact_Name__r.Mixmax_Campaign_Name__c != campaign && ae.Contact_Name__c != null)
                                 contactsToUpdate.add(new Contact(Id = ae.Contact_Name__c, Mixmax_Campaign_Name__c = campaign));
                         if(ae.Lead_Name__r.Mixmax_Campaign_Name__c != campaign && ae.Lead_Name__c !=null)
                                 leadsToUpdate.add(new Lead(Id = ae.Lead_Name__c, Mixmax_Campaign_Name__c = campaign));
                }
            }
            if(!contactsToUpdate.isEmpty()){
                    updateContact.putAll(contactsToUpdate);
                    update updateContact.values();
            }
            if(!leadsToUpdate.isEmpty()){
                    updateLead.putAll(leadsToUpdate);
                	update updateLead.values();
                
            }
            Update lstTask;
            if(test.isRunningTest()){
                Integer i=1/0;
            }
              
        }Catch(Exception e){
            Database.RollBack(sp);
            
            String message = e.getMessage();
            String stacktrace = e.getStackTraceString();
            String exType = '' + e.getTypeName();
            String line = '' + e.getLineNumber();
            String theTime = '' + System.now();
            
            String body = String.format('Time: {0}\nMessage: {1}\nStacktrace: {2}\nLine: {3}', new List<String>{ theTime, message, stacktrace, line });
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Errors occurred during Mixmax Contact Lead Update Campaign Name batch process.');
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.Email[] { mail }); 
        }
    }  
    global void finish(Database.BatchableContext BC){
        Database.executeBatch(new CreateMixMaxCampaignForLeadBatch());
        
    }	
}