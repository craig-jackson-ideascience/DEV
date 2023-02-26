public with sharing class MyProjectsReportEmailHandler implements IEmail{
    

    public List<SendEmailWrapper.SendEmailContactWrapper> getRecipients(){
        //get the recipients
        Map<Id,Set<ID>> recipients = new  Map<Id,Set<ID>>();
        
        List<AggregateResult> results = [Select count(ID),Opportunity__r.OwnerId from Asset WHERE UsageEndDate = NEXT_N_DAYS:60 AND
                                    Product2.Family='Membership' AND Auto_Renew__c = true group by Opportunity__r.OwnerId];
        system.debug('----'+results);
        for(AggregateResult ar : results){
            recipients.put((Id)ar.get('OwnerId'),new Set<Id>{(ID)ar.get('OwnerId')});
        }
        //create list to loop on

        List<SendEmailWrapper.SendEmailContactWrapper> contactWrapper = new list<SendEmailWrapper.SendEmailContactWrapper>();
            for(Id id : recipients.keySet()){
                Map<String, Object> params = new  Map<String, Object>();
                params.put('id',id);
                contactWrapper.add(new SendEmailWrapper.SendEmailContactWrapper(id,recipients.get(id), params));
            }

        return contactWrapper;
    }

    public string getBody(){
       
        list<EmailTemplate> emailTemplate = [select id from EmailTemplate where id =:label.Project_Email_Template];
        return emailTemplate.size()> 0 ? emailTemplate[0].id : '';
    }

    /*
    * This generates the attachments
    * */
    public List<Messaging.EmailFileAttachment>  getAttachments(Map<String, Object> parameters){
        List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();

        String ownerId = (String) parameters.get('id');
      MyProjectsReportController projectReportController = new MyProjectsReportController((String) parameters.get('id'));
        
        list<Asset> asset = projectReportController.getAssetDetails();
        Blob csvBlob;
        if(asset != null){
             csvBlob = projectReportController.csvGenerate(asset);
        }
        fileAttachment.setBody(csvBlob);
        fileAttachment.setFileName('My Renewals.csv');
        fileAttachment.setContentType('text/csv');  
        emailFileAttachments.add(fileAttachment);
        return emailFileAttachments;
    }
}