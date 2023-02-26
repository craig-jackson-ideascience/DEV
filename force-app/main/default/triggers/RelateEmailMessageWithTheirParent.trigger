trigger RelateEmailMessageWithTheirParent on EmailMessage (before insert) {
    
       set <string> parentIds = new set <string>();
       list <Account> accList = new list <Account>();
       list <Contact> conList = new list <Contact>();
       list <EmailMessage> emailMessagesListToUpdate = new list <EmailMessage>();
       
       for (EmailMessage emails : Trigger.New){
           if(emails.Parent_Id__c != null)
            	parentIds.add(emails.Parent_Id__c);
       }
       
       map <string, string> sugarIdVSaccId = new map <string, string>();
       map <string, string> sugarIdVSconId = new map <string, string>();
       if(parentIds != null){
           accList = [select id, name, Sugar_Account_ID__c from account where Sugar_Account_ID__c in : parentIds]; 
           conList = [select id, name, SugarContactID__c from contact where SugarContactID__c in : parentIds];
       
       }
       if(!accList.isEmpty()){
           for (Account accObj : accList){
           
               sugarIdVSaccId.put(accObj.Sugar_Account_ID__c, accObj.id);
           }
       }
       if(!conList.isEmpty()){
           for(Contact conObj : conList){
               sugarIdVSconId.put(conObj.SugarContactID__c ,conObj.id);
           
           
           }
       
       }
       
       for (emailmessage emailsToUpdate: Trigger.New){
           if(sugarIdVSaccId != null && sugarIdVSaccId.containsKey(emailsToUpdate.Parent_Id__c)){
               emailsToUpdate.RelatedToId = sugarIdVSaccId.get(emailsToUpdate.Parent_Id__c);
               
           }
           else if(sugarIdVSconId != null && sugarIdVSconId.containsKey(emailsToUpdate.Parent_Id__c)){
           
               emailsToUpdate.Contact__c = sugarIdVSconId.get(emailsToUpdate.Parent_Id__c);
           }
       }
       
        
       
}