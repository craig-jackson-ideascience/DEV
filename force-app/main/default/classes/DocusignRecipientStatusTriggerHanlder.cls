/********************************************************
* Created by: Martand Atrey @ CloudRoute Solutions
* Created Date: 30-10-2019.
* Description: DocusignRecipientStatusTriggerHanlder
********************************************************/
public class DocusignRecipientStatusTriggerHanlder implements ITriggerHandler {
    //This will handle before delete event
    public void beforeDelete(Map<Id, SObject> oldMap) {
        
    }
    
    //This method will handle before insert method
    public void beforeInsert(List<SObject> newItems) {
        
    }
    
    //This method will handle before update event
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        
    }
    
    public void afterInsert(Map<Id, SObject> newMap) {
    }
    
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        sendEmailaboutReview((Map<Id, dsfs__DocuSign_Recipient_Status__c>) newMap, (Map<Id, dsfs__DocuSign_Recipient_Status__c>) oldMap);
    }
    
    public void afterDelete(Map<Id, SObject> oldMap) {
        
    }
    
    public void afterUndelete(Map<Id, SObject> newMap) {
        
    }
    
    public void sendEmailaboutReview(Map<Id, dsfs__DocuSign_Recipient_Status__c> newMap, Map<Id, dsfs__DocuSign_Recipient_Status__c> oldMap) {
        System.debug('SendEmailAboutReview');
        Set<Id> docuSignReciIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        for (dsfs__DocuSign_Recipient_Status__c status : newMap.values()) {
            system.debug('status'+ status);
            if (status.dsfs__Recipient_Status__c != oldMap.get(status.Id).dsfs__Recipient_Status__c &&
                status.dsfs__Recipient_Status__c == 'Completed' && 
                status.dsfs__DocuSign_Routing_Order__c == 1 &&
                status.dsfs__Parent_Status_Record__c != null) {
                    docuSignReciIds.add(status.Id);
                }
        }
        
        for (dsfs__DocuSign_Recipient_Status__c status : [
            SELECT Id,dsfs__Parent_Status_Record__c,dsfs__DocuSign_Recipient_Email__c,dsfs__Parent_Status_Record__r.dsfs__Opportunity__c, dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Name,
            dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Project_Name__c, dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Project_Name__r.External_Individual_Contract_Signed__c,dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Authorized_Signatory__c, Name,
            dsfs__Recipient_Status__c,dsfs__DocuSign_Routing_Order__c, dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Project_Name__r.Name, dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Authorized_Signatory__r.FirstName, 
            dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Project_Name__r.External_Contract_Signed_Notification__c,dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Individual__c
            FROM dsfs__DocuSign_Recipient_Status__c
            WHERE Id IN :docuSignReciIds 
            AND dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Authorized_Signatory__c != null
        ]) {
            sendEmail(status);
        }
    }
    
    private void sendEmail(dsfs__DocuSign_Recipient_Status__c status) {
        EmailTemplate et;

        System.debug(status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Authorized_Signatory__c + '====> Auth Signatory ');
        
        Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(orgWideEmailAddress);
        mail.setToAddresses(new List<String>{status.dsfs__DocuSign_Recipient_Email__c});
        
        String body = '';
        String subject = '';
        Boolean buildProjectEmail = False;
        if(status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Name.contains('Individual Membership') || status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Individual__c) {
            System.debug('Individual');
            if(status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Project_Name__r.External_Individual_Contract_Signed__c != NULL && status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Project_Name__r.External_Individual_Contract_Signed__c != ''){
                body = status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Project_Name__r.External_Individual_Contract_Signed__c;
                buildProjectEmail = TRUE;
            }
            else {
                System.debug('insie Else*** ');
                et  = [SELECT ID FROM EmailTemplate WHERE DeveloperName = :Label.EmailTemplateForIndividualMembershipContractReview];
            }

        }else {
            if(status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Project_Name__r.External_Contract_Signed_Notification__c != null && status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Project_Name__r.External_Contract_Signed_Notification__c != '') {
                body = status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Project_Name__r.External_Contract_Signed_Notification__c;
                buildProjectEmail = TRUE;
            }
            else {
                et  = [SELECT ID FROM EmailTemplate WHERE DeveloperName = :Label.EmailTemplateForContractReview];
            }
        }

        if(buildProjectEmail){
            String prjName = status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Project_Name__r.Name;
            body = body.replace('[ProjectName]', prjName).replace('[UserFirstName]', status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Authorized_Signatory__r.FirstName);
            subject = prjName + ' Membership - In Review';
                 
            mail.setSubject(subject);
            mail.setHtmlBody(body);
        }
        else{
            System.debug('Inside ELse part ');
            mail.setTemplateId(et.Id);
            mail.setWhatId(status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__c);
            mail.setTargetObjectId(status.dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Authorized_Signatory__c);
        }

        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        for (Messaging.SendEmailResult res : results) {
            if (!res.success) {
                System.debug(res + '====> res');
            }
        }
    }
    
    
    public Boolean IsDisabled() {
        return false;
    }

}