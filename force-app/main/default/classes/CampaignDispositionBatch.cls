public with sharing class CampaignDispositionBatch implements Database.Batchable<sObject> {

    ID projectID;
    ID campaignID;
    String campaignName;
    String userEmail;
    String query;

    //override default constructor in order to pass parameters into this class
    public CampaignDispositionBatch(ID projID, ID campID, String campName, String usrEmail, String queryString){
        projectID = projID;
        campaignID = campID;
        campaignName = campName;
        userEmail = usrEmail;
        query = queryString;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<CampaignMember> campaignMembers){
        CampaignDispositionController.processCampaignMembers(campaignMembers, projectID);
    }
    
    public void finish(Database.BatchableContext bc){
        //build Campaign URL to use inside email
        String orgDomain = String.valueof(System.Url.getSalesforceBaseURL().gethost());
        String campaignURL = 'https://' + orgDomain + '/lightning/r/Campaign/' + campaignID + '/view';

        //build body of email
        String body = 'Hi there-<br><br>';
        body += 'Auto-dispositioning is now complete for ' + campaignName + '. Click ';
        body += '<a href="' + campaignURL + '">here</a>';
        body += ' to go to that campaign.<br><br>';
        body += 'Thank you!';

        //send email to running user
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(userEmail);
        mail.setToAddresses(sendTo);
        mail.setReplyTo('salesops@linuxfoundation.org');
        mail.setSenderDisplayName('The Linux Foundation');
        mail.setSubject('Auto-dispositioning complete for ' + campaignName);
        mail.setHtmlBody(body);
        mails.add(mail);
        Messaging.sendEmail(mails);
    }
}