/*Generic batch which gets Query From the scheduler and add members to campaign
 * Test Class - AddCampaignMembersGenericBatchTest
 */

public class AddCampaignMembersGenericBatch implements Database.Batchable<Sobject> , Database.Stateful{
    Public String query;
    Public String contactField;
    Public String leadField;
    Public String campaignId;
    Public Set<String> setOfCountry;
    public  Boolean hasError = false;
    public String emailBody = 'Hi,<br/>'+
     '<p>Error Occured While Executing AddCampaignMembersGenericBatch Class for the campaignId is ';
    
    //Constructor
    
    public AddCampaignMembersGenericBatch(string query, string contactField, string leadField, string campaignId){
        this.query = query;
        this.contactField = contactField;
        this.leadField = leadField;
        this.campaignId = campaignId;
        this.setOfCountry = new Set<String>(Label.APAC_Country.split(';'));
        emailBody+=campaignId +'.'+'<br/>Error Meassage - :';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        //Query
         system.debug('query '+query);
        system.debug('contactField '+contactField);
        system.debug('leadField '+leadField);
        system.debug('campaignId '+campaignId);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Sobject> scope){
        
        try{
        //Initialize variables
        List<CampaignMember> listOfCampMemberToInsert = new List<CampaignMember>();
        set<id> contactLeadIdSet = new Set<id>();
        List<CampaignMember> campaignMembersToInsert = new List<CampaignMember>();
        system.debug('scope ' + scope.size());
        system.debug('contactField ' + contactField);
        system.debug('leadField ' + leadField);
        //Iterate
        for (Sobject sobjectInstance : scope){
            
            //Assign Lead OR ContactID
            Id leadContactId;
            //If Contact and Lead API Name are not Empty
            if(String.isNotEmpty(leadField) && String.isNotEmpty(contactField)){
                leadContactId = sobjectInstance.get(contactField) != null ? (Id)sobjectInstance.get(contactField) : 
                sobjectInstance.get(leadField) != null ? (Id)sobjectInstance.get(leadField) : null; 
            }else if (String.isNotEmpty(contactField)){
                leadContactId = sobjectInstance.get(contactField) != null ? (Id)sobjectInstance.get(contactField) : null;
            }
            else if (String.isNotEmpty(leadField)){
                    leadContactId = sobjectInstance.get(leadField) != null ? (Id)sobjectInstance.get(leadField) : null;
                }
            
            
            
            
            //If leadContactId exist then create campaignmember instance
            if (leadContactId != null && !contactLeadIdSet.contains(leadContactId)){
                CampaignMember campaignMember = new CampaignMember();
                if (String.isNotEmpty(contactField) && sobjectInstance.get(contactField) != null){
                    campaignMember.ContactId = leadContactId;
                } else{
                    campaignMember.LeadId = leadContactId;
                }
                
                campaignMember.CampaignId = campaignId;
                contactLeadIdSet.add(leadContactId);
                listOfCampMemberToInsert.add(campaignMember);
            }
            
            
        }
        if (!listOfCampMemberToInsert.isEmpty()){
            List<Database.SaveResult> saveResults = Database.insert(listOfCampMemberToInsert, false);
            for (Database.SaveResult svr : saveResults){
                if (!svr.issuccess()){
                    system.debug('sv ' + svr.getErrors());
                }
            }
            
        }
    }catch(Exception err){
        system.debug('--catch-'+err.getMessage()+'----'+err.getLineNumber());
        emailBody +=  '<br/>' + err.getMessage()+' at Line Number '+err.getLineNumber()+'. <br/>' ;
        hasError = true;
}
    }
    
    public void finish(Database.BatchableContext info){
        /*Sending Error Message to given Label: RenewalOpportunityBatchClassErrorSendingEmail*/
        Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>();
        /*Sending Email Start*/
        if(hasError){
            system.debug('hasError '+hasError);
            Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(orgWideEmailAddress);
            mail.setToAddresses(new List<String>{label.SFDC_Email});
            mail.setSubject('AddCampaignMembersGenericBatch Error');
            mail.setHtmlBody(emailBody);
            emails.add(mail);
            system.debug('------'+emails);
            if(emails.size() > 0){
                Messaging.sendEmail(emails);
            }
    }
}
}