public class EmailUtility implements Database.Batchable<SendEmailWrapper.SendEmailContactWrapper>,Schedulable{
    public IEmail emailHandler;
    public SendEmailWrapper wrapper;
    public List<SendEmailWrapper.SendEmailContactWrapper> contactWrapper;
    
    public EmailUtility (SendEmailWrapper emailWrapper, List<SendEmailWrapper.SendEmailContactWrapper> contactWrapper, string className) {
        
        this.wrapper = emailWrapper;
        System.debug('Contact wrapper ' + contactWrapper);
        this.emailHandler = (IEmail) Type.forName(className).newInstance();
        this.contactWrapper =  emailHandler.getRecipients();
    }
    
    public EmailUtility (string className) {
        this.wrapper = new SendEmailWrapper();
        this.emailHandler = (IEmail) Type.forName(className).newInstance();
        this.contactWrapper =  emailHandler.getRecipients();
    }
     public EmailUtility () {
     }
    public List<SendEmailWrapper.SendEmailContactWrapper> start(Database.BatchableContext bc) {
        return contactWrapper;
    }
    
    public void execute(Database.batchableContext bc, List<SendEmailWrapper.SendEmailContactWrapper> scope) {
        List<Messaging.SingleEmailMessage> finalEmailMessage = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        Set<Id> contactIds = new Set<Id>();
        
        //to get all contact details
        for (SendEmailWrapper.SendEmailContactWrapper c : scope) {
            contactIds.addAll(c.contactIds);
        }
        
        try {
            Map<ID,list<string>> mapOFEmails = new Map<Id,list<String>>();
            list<UserEmailBatch__mdt> userEmailBatchs = [select id,User_ID__c,Email_Address__c from UserEmailBatch__mdt where User_ID__c in: contactIds and User_ID__c != null];
            system.debug('--userEmailBatchs--'+userEmailBatchs);
            if(userEmailBatchs.size() > 0){
                for(UserEmailBatch__mdt userEmail : userEmailBatchs){
                    if(String.isNotBlank(userEmail.Email_Address__c)){
                        system.debug('--userEmail.Email_Address__c--'+userEmail.Email_Address__c);
                        mapOFEmails.put(userEmail.User_ID__c,userEmail.Email_Address__c.split(';')); 
                        
                    }
                }
            }
            system.debug('===='+mapOFEmails);
            Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
            for (SendEmailWrapper.SendEmailContactWrapper c : scope) {
                System.debug('##recordIdSet :' + c.recordIdSet);
                System.debug('##params :' + c.params);
                System.debug('##c.contactIds :' + c.contactIds);
                c.contactIds.remove(null);
                System.debug('##c.contactIdsAfter :' + c.contactIds);
                List<Messaging.EmailFileAttachment> dynamicAttachments = emailHandler.getAttachments(c.params);
                wrapper.templateId = emailHandler.getBody();
                for (Id contactId : c.contactIds) {
                    System.debug('contactId :' + contactId);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
                    email.setOrgWideEmailAddressId(orgWideEmailAddress);
                    if (wrapper.templateID != null && wrapper.templateID != '') {
                        system.debug('---'+contactId);
                        email = Messaging.renderStoredEmailTemplate(wrapper.templateId, contactId, contactId);
                        system.debug('---'+email);
                    }
                    email.setSaveAsActivity(false);
                    system.debug('---'+mapOFEmails.get(contactId));
                    if(mapOFEmails.containskey(c.recordIdSet)){
                        email.setCcAddresses(mapOFEmails.get(contactId));
                    }
                    
                    email.setTargetObjectId(contactId);
                    // this attaches attachment to an email
                    if (dynamicAttachments.size() > 0) email.setFileAttachments(dynamicAttachments);
                    System.debug('##Final Email Message :' + email);
                    finalEmailMessage.add(email);
                }
            }
            
        } catch (Exception e) {
            System.debug('ErrorMessage : ' + e.getMessage() + '. Cause: ' + e.getCause() + 'Error Line No: ' + e.getTypeName() + ':' + e.getLineNumber() + ' Stacktrace: ' + e.getStackTraceString());
        }
        System.debug('finalEmailMessageSize :' + finalEmailMessage.size());
        if (!finalEmailMessage.isEmpty()) {
            Messaging.SendEmailResult [] r = Messaging.sendEmail(finalEmailMessage, false);
            System.debug('results :' + r);
        }
        
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
    
    /* Schedulable Execute */
      public void execute(SchedulableContext sc) {
      Database.executeBatch(new EmailUtility('MyProjectsReportEmailHandler'));
   }
    
}