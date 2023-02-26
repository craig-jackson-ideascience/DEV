public class LeadConversionController {
    //THIS METHOD RETURNS EXISTING CONTACT AND ACCOUNT BY SEARCHING ALTERNATE EMAILS
    @AuraEnabled
    public static Map<String,String> findDuplicates(Lead lead){
        List<Alternate_Email__c> alternateEmails = [SELECT ID,Contact_Name__c,Contact_Name__r.Name,Contact_Name__r.AccountId,Alternate_Email_Address__c,Lead_Name__c,
                                                    Lead_Name__r.FirstName,Lead_Name__r.LastName 
                                                    FROM Alternate_Email__c 
                                                    WHERE Alternate_Email_Address__c =:lead.Email 
                                                    AND Lead_Name__c != :lead.Id];
        System.debug('alternateEmails :'+alternateEmails);
        List<Alternate_Email__c> alternateEmailWithDuplicateContact = new List<Alternate_Email__c>();
        List<Lead> duplicateLeads = new List<Lead>();
        for(Alternate_Email__c alternateEmail :  alternateEmails){
            if(alternateEmail.Contact_Name__c != null){
                alternateEmailWithDuplicateContact.add(alternateEmail);
            }else if(alternateEmail.Lead_Name__c != null){
                duplicateLeads.add(new Lead(Id=alternateEmail.Lead_Name__c,FirstName = alternateEmail.Lead_Name__r.FirstName, 
                                                LastName = alternateEmail.Lead_Name__r.LastName));
            }
        }
        System.debug('alternateEmailWithDuplicateContact :'+alternateEmailWithDuplicateContact);
        System.debug('duplicateLeads :'+duplicateLeads);
        Map<String,String> responseMap = new Map<String,String>();
        if(!alternateEmailWithDuplicateContact.isEmpty()){
            responseMap.put('alternateEmail', JSON.serialize(alternateEmailWithDuplicateContact[0]));
        }
        if(!duplicateLeads.isEmpty()){
            responseMap.put('duplicateLeads',JSON.serialize(duplicateLeads));
        }
        return responseMap;
    }
    
    //THIS METHODS CONVERTS LEAD
    @AuraEnabled 
    public static String convertLeadRecord(String accountId,String contactId,String leadId,String ownerId){
        System.debug('ownerId : '+ownerId);
        List<User> users = [SELECT Id,Name From User Where Id =:ownerId];
        System.debug('users :'+users);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        leadConvert.setLeadId(leadId);
        leadConvert.setDoNotCreateOpportunity(true);
        leadConvert.setOwnerId(!users.isEmpty() ? ownerId : UserInfo.getUserId());
        leadConvert.setConvertedStatus(convertStatus.MasterLabel);
        leadConvert.setAccountId(accountId);
        leadConvert.setContactId(contactId);
        Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
        if(leadConvertResult.isSuccess()){
            return leadConvertResult.getContactId();
        }else{
            return null;
        }
    }
    
    //THIS METHOD MERGES LEAD
    @AuraEnabled
    public static String mergeLeadRecords(Lead masterLead,String duplicateLeadString){
        List<Lead> duplicateLeads =   (List<Lead>)System.JSON.deserialize(duplicateLeadString, List<Lead>.class);
        System.debug('duplicateLeads :'+duplicateLeads);
        System.debug('masterLead :'+masterLead);
        Database.MergeResult[] mergeResults = Database.merge(masterLead, duplicateLeads);
        System.debug('mergeResults :'+mergeResults);
        return mergeResults[0].getId();
    }
}