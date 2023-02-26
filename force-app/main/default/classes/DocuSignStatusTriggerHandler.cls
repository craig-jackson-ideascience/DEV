/*
 LastModified By             ModifiedDate            Methods                                                 Against
 ========================================================================================================================
 Kalyani Chiluveri           17-Jun-2020`           Coporate Email Changes                                  SFDC-1451

 */
public with sharing class DocuSignStatusTriggerHandler implements ITriggerHandler{
    public static void BeforeInsert(List<SObject> triggerNew){
    }

    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap){
    }

    public static void BeforeDelete(Map<Id, Sobject> oldMap){
        //call before delete actions
    }

    public static void AfterInsert(Map<Id, SObject> newMap){
        sendEmailIfDocuSignStatusCompleted((Map<Id, dsfs__DocuSign_Status__c>)newMap, null);
        updateOppApplicationStatus((Map<Id, dsfs__DocuSign_Status__c>)newMap, null);
    }

    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){
        sendEmailIfDocuSignStatusCompleted((Map<Id, dsfs__DocuSign_Status__c>)newMap, (Map<Id, dsfs__DocuSign_Status__c>)oldMap);

        sendEmailIfDocuSignStatusDeclined((Map<Id, dsfs__DocuSign_Status__c>)newMap, (Map<Id, dsfs__DocuSign_Status__c>)oldMap);
        updateOppApplicationStatus((Map<Id, dsfs__DocuSign_Status__c>)newMap, (Map<Id, dsfs__DocuSign_Status__c>)oldMap);
    }

    public static void AfterDelete(Map<Id, Sobject> oldMap){
    }

    public static void AfterUnDelete(Map<Id, Sobject> newMap){
        //call after undelete actions
    }

    public Boolean IsDisabled(){
        return false;
    }

    private static void sendEmailIfDocuSignStatusDeclined(Map<Id, dsfs__DocuSign_Status__c> newMap, Map<Id, dsfs__DocuSign_Status__c> oldMap){
        Map<Id, dsfs__DocuSign_Status__c> OppIdVsDeclinedDocuSign = new Map<Id, dsfs__DocuSign_Status__c>();
        //Iterate through each docusignStatus
        for (dsfs__DocuSign_Status__c docuSign : newMap.values()){
            //if status is completed then add the opportunity to set
            if (docuSign.dsfs__Envelope_Status__c == 'Declined' && docuSign.dsfs__Opportunity__c != null && (oldMap == null || (oldMap != null && docuSign.dsfs__Envelope_Status__c != oldMap.get(docuSign.Id).dsfs__Envelope_Status__c))){
                OppIdVsDeclinedDocuSign.put(docuSign.dsfs__Opportunity__c, docuSign);
            }
        }
        if (!OppIdVsDeclinedDocuSign.values().isEmpty()){
            sendDeclinedEmail(OppIdVsDeclinedDocuSign);
        }
    }

    public static void sendDeclinedEmail(Map<Id, dsfs__DocuSign_Status__c> declinedDocuSign){
        if (!declinedDocuSign.values().isEmpty()){
            List<Opportunity> opportunities = [SELECT Id, Name, Account.Name, Owner.Email,Opportunity_Link__c, Billing_Contact_URL__c, Billing_Contact__r.Name, Owner.FirstName, Project_Name__r.Name, Project_Name__r.Internal_Docusign_Voided_Notification__c, Amount,Signed_MSA__c, (SELECT Id, Projects__r.Notifications_Group__c
                                                                                                                                                                                                                                                              FROM OpportunityLineItems)
                                               FROM Opportunity 
                                               WHERE Id IN:declinedDocuSign.keySet()
                                               WITH SECURITY_ENFORCED];
            if (!opportunities.isEmpty()){
                Map<String, Set<String>> oppIdVsGroupIds = new Map<String, Set<String>>();
                for (Opportunity opp : opportunities){
                    if (opp.OpportunityLineItems != NULL){
                        for (OpportunityLineItem oli : opp.OpportunityLineItems){
                            if (String.isNotBlank(oli.Projects__r.Notifications_Group__c)){
                                if (!oppIdVsGroupIds.containsKey(opp.ID)){
                                    oppIdVsGroupIds.put(opp.ID, new Set<String>());
                                }
                                oppIdVsGroupIds.get(opp.ID).add(oli.Projects__r.Notifications_Group__c);
                            }
                        }
                    }
                }

                Map<String, EmailTemplate> emailTemplateNameById = getEmailTemplateId();
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

                Map<Id, String> oppIdVsTemlateId = new Map<Id, String>();
                Set<Id> corporateClosedDocIds = new Set<ID>();
                Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
                for (Opportunity opp : opportunities){
                    EmailTemplate emailTemplate = emailTemplateNameById.get('DocuSign_Declined_Notification');
                    if (emailTemplate.ID == emailTemplateNameById.get('DocuSign_Declined_Notification').ID){
                        if (!oppIdVsGroupIds.isEmpty() || opp.OwnerId != null){
                            List<String> toaddress = new List<String>();
                            String toName = opp.Owner.FirstName;
                            if (!oppIdVsGroupIds.isEmpty()){
                                toaddress.addAll(oppIdVsGroupIds.get(opp.ID));
                                toName = 'The Project Team';
                            }
                            toaddress.add(opp.OwnerId);
                            if (opp.Project_Name__r.Internal_Docusign_Voided_Notification__c != NULL && opp.Project_Name__r.Internal_Docusign_Voided_Notification__c != ''){
                                String subject = 'DocuSign Agreement Declined';
                                String body = replaceKeywords(opp.Project_Name__r.Internal_Docusign_Voided_Notification__c, opp, toName, declinedDocuSign);
                                mails.add(getClassicEmail(subject, body, toaddress, orgWideEmailAddress));
                            } else{

                                dsfs__DocuSign_Status__c recObj = declinedDocuSign.get(opp.Id);

                                if (recObj != NULL){
                                    Messaging.SingleEmailMessage groupEmail = formatEmail(emailTemplate, toName, opp.Project_Name__r.Name, recObj.Signatory_Status__c, recObj.dsfs__Declined_Reason__c, toaddress, opp, orgWideEmailAddress);

                                    mails.add(groupEmail);
                                }
                            }
                        }
                    } else{
                        Messaging.SingleEmailMessage mail = getEmailBody(emailTemplate.ID, orgWideEmailAddress, opp, null);
                        mails.add(mail);
                    }
                }

                if (!mails.isEmpty()){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                    for (Messaging.SendEmailResult res : results){
                        if (!res.success){
                            System.debug(res + '====> res');
                        } else{
                            System.debug('succes ' + res);
                        }
                    }
                }
            }
        }
    }

    private static void sendEmailIfDocuSignStatusCompleted(Map<Id, dsfs__DocuSign_Status__c> newMap, Map<Id, dsfs__DocuSign_Status__c> oldMap){
        Map<Id, Opportunity> opportunitiesToUpdate = new Map<Id, Opportunity>();
        //Iterate through each docusignStatus
        for (dsfs__DocuSign_Status__c docuSign : newMap.values()){

            //if status is completed then add the opportunity to set
            if (docuSign.dsfs__Envelope_Status__c == 'Completed' && docuSign.dsfs__Opportunity__c != null && (oldMap == null || (oldMap != null && docuSign.dsfs__Envelope_Status__c != oldMap.get(docuSign.Id).dsfs__Envelope_Status__c))){
                opportunitiesToUpdate.put(docuSign.dsfs__Opportunity__c, new Opportunity(Id = docuSign.dsfs__Opportunity__c, StageName = 'Closed Won'));

            }
        }

        //if map is not empty
        if (!opportunitiesToUpdate.IsEmpty()){
            //update opportunities
            Database.update (opportunitiesToUpdate.values(), false);
            sendOpportunityEmail(opportunitiesToUpdate.keyset());
        }
    }

    //Method to send Mail
    public static void sendOpportunityEmail(Set<Id> opportunityIds){
        List<Opportunity> opportunities = [SELECT Id, Name, Account_URL__c,Signed_MSA__c,Opportunity_PO_Required__c, Account.Name, Opportunity_Link__c, OwnerId, Owner.FirstName,Owner.Email, StageName, Billing_Contact_URL__c, Project_Name__r.Internal_Docusign_Complete_Corporate__c, Project_Name__r.Internal_Docusign_Complete_Individual__c, Billing_Contact__r.Name, Individual__c, Project_Name__r.Internal_Opportunity_Cannot_Close__c, Amount, (SELECT Id, Projects__r.Notifications_Group__c
                                                                                                                                                                                                                                                                                                                                                                                                                                  FROM OpportunityLineItems)
                                           FROM Opportunity 
                                           WHERE Id IN:opportunityIds];

        Map<String, Set<String>> oppIdVsGroupIds = new Map<String, Set<String>>();
        for (Opportunity opp : opportunities){
            if (opp.OpportunityLineItems != NULL){
                for (OpportunityLineItem oli : opp.OpportunityLineItems){
                    if (String.isNotBlank(oli.Projects__r.Notifications_Group__c)){
                        if (oppIdVsGroupIds.containsKey(opp.ID)){
                            oppIdVsGroupIds.get(opp.ID).add(oli.Projects__r.Notifications_Group__c);
                        } else{
                            oppIdVsGroupIds.put(opp.ID, new Set<String>{ oli.Projects__r.Notifications_Group__c });
                        }
                    }
                }
            }
        }

        if (!opportunities.isEmpty()){
            Map<String, EmailTemplate> emailTemplateNameById = getEmailTemplateId();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

            Map<Id, String> oppIdVsTemlateId = new Map<Id, String>();
            Set<Id> corporateClosedDocIds = new Set<ID>();
            Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();


            for (Opportunity opp : opportunities){
                List<String> toAddressList = new List<String>();
                if (opp.Signed_MSA__c){
                    toAddressList.addAll(Label.TrainingMSATeam.split(';'));
                }
                toAddressList.add(Opp.Owner.Email);
                EmailTemplate emailTemplate = opp.StageName == 'Closed Won' ? ((opp.Name.contains('Individual Membership') || opp.Individual__c) ? emailTemplateNameById.get('Opp_closed_docusign_complete_for_Individual_Membership') : emailTemplateNameById.get('Opp_Closed_Docusign_Complete')) : emailTemplateNameById.get('Opportunity_Cannot_Close');
                String subject = 'Opportunity ' + opp.Name + ' Closed/Won';
                String OpprunityLink = '<a href="' + opp.Opportunity_Link__c + '">' + opp.Name + '</a>';
                String accountlink = '<a href="' + opp.Account_URL__c + '">' + opp.Account.Name + '</a>';
                String oppAmount = String.ValueOf(opp.Amount);
                String body = '';
                if (emailTemplate.ID == emailTemplateNameById.get('Opp_Closed_Docusign_Complete').ID){
                    Boolean buildProjectMessage = False;
                    if (opp.Project_Name__r.Internal_Docusign_Complete_Corporate__c != NULL && opp.Project_Name__r.Internal_Docusign_Complete_Corporate__c != ''){
                        body = opp.Project_Name__r.Internal_Docusign_Complete_Corporate__c;
                        body = body.replace('[OpportunityOwnerFirstName]', opp.Owner.FirstName).replace('[AccountLink]', accountlink).replace('[OpportunityLink]', OpprunityLink).replace('[OpportunityName]', opp.Name).replace('[OpportunityAmount]', oppAmount);
                        mails.add(getClassicEmail(subject, body, toAddressList, orgWideEmailAddress));
                        buildProjectMessage = TRUE;
                    } else{
                        Messaging.SingleEmailMessage mail = getEmailBody(emailTemplate.ID, orgWideEmailAddress, opp, null);
                        mails.add(mail);
                    }

                    if (!oppIdVsGroupIds.isEmpty()){
                        List<String> toaddress = new List<String>();
                        toaddress.addAll(oppIdVsGroupIds.get(opp.ID));
                        if (buildProjectMessage){
                            mails.add(getClassicEmail(subject, body, toaddress, orgWideEmailAddress));
                        } else{

                            Messaging.SingleEmailMessage groupEmail = getEmailBody(emailTemplate.ID, orgWideEmailAddress, opp, toaddress);
                            mails.add(groupEmail);
                        }
                    }
                } else{
                    if (emailTemplate.ID == emailTemplateNameById.get('Opp_closed_docusign_complete_for_Individual_Membership').ID && opp.Project_Name__r.Internal_Docusign_Complete_Individual__c != NULL){
                        body = opp.Project_Name__r.Internal_Docusign_Complete_Individual__c;
                        String billinConLink = '<a href="' + opp.Billing_Contact_URL__c + '">' + opp.Billing_Contact__r.Name + '</a>';
                        body = body.replace('[OpportunityOwnerFirstName]', opp.Owner.FirstName).replace('[OpportunityName]', opp.Name).replace('[OpportunityLink]', OpprunityLink).replace('[BillingContactLink]', billinConLink);
                        mails.add(getClassicEmail(subject, body, toAddressList, orgWideEmailAddress));
                    } else if (emailTemplate.ID == emailTemplateNameById.get('Opportunity_Cannot_Close').ID && opp.Project_Name__r.Internal_Opportunity_Cannot_Close__c != NULL){
                        subject = 'Opportunity ' + opp.Name + ' Cannot Close';
                        body = opp.Project_Name__r.Internal_Opportunity_Cannot_Close__c;
                        body = body.replace('[OpportunityOwnerFirstName]', opp.Owner.FirstName).replace('[OpportunityLink]', OpprunityLink);
                        mails.add(getClassicEmail(subject, body, toAddressList, orgWideEmailAddress));
                    } else{
                        Messaging.SingleEmailMessage mail = getEmailBody(emailTemplate.ID, orgWideEmailAddress, opp, null);
                        mails.add(mail);
                    }
                }
            }

            if (!mails.isEmpty()){

                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                for (Messaging.SendEmailResult res : results){
                    if (!res.success){
                        System.debug(res + '====> res');
                    } else{
                        System.debug('succes ' + res);
                    }
                }
            }
        }
    }

    public static Messaging.Singleemailmessage getClassicEmail(String subject, String Body, List<String> toAddress, String orgWideEmailAddress){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        mail.setOrgWideEmailAddressId(orgWideEmailAddress);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        return mail;
    }

    public static Messaging.Singleemailmessage formatEmail(EmailTemplate emailTemplate, String userFirstName, String projectName, String declinedByUser, String reason, List<String> toAddress, Opportunity opp, Id orgWideEmailAddress){

        String subject = emailTemplate.Subject;
        subject = subject.replace('{!Opportunity.Name}', opp.Name);

        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.contains('{!User.FirstName}') ? htmlBody.replace('{!User.FirstName}', userFirstName) : htmlBody;
        htmlBody = htmlBody.contains('{!Opportunity.Name}') ? htmlBody.replace('{!Opportunity.Name}', opp.Name) : htmlBody;
        htmlBody = htmlBody.contains('{!Opportunity.Account_URL__c}') ? htmlBody.replace('{!Opportunity.Account_URL__c}', opp.Account_URL__c) : htmlBody;
        htmlBody = htmlBody.contains('{!Opportunity.Account}') ? htmlBody.replace('{!Opportunity.Account}', opp.Account.Name) : htmlBody;
        htmlBody = htmlBody.contains('{!Opportunity.Link}') ? htmlBody.replace('{!Opportunity.Link}', opp.Opportunity_Link__c) : htmlBody;

        htmlBody = htmlBody.contains('{!DeclinedByUser}') ? htmlBody.replace('{!DeclinedByUser}', String.isNotBlank(declinedByUser) ? declinedByUser : '') : htmlBody;
        htmlBody = htmlBody.contains('{!Opportunity.ProjectName}') ? htmlBody.replace('{!Opportunity.ProjectName}', projectName) : htmlBody;
        htmlBody = htmlBody.contains('{!Reason}') ? htmlBody.replace('{!Reason}', String.isNotBlank(reason) ? reason : '') : htmlBody;
        htmlBody = htmlBody.contains('{!Opportunity.Amount}') ? htmlBody.replace('{!Opportunity.Amount}', String.ValueOf(opp.Amount)) : htmlBody;


        String plainBody = emailTemplate.Body;
        plainBody = plainBody.contains('{!User.FirstName}') ? plainBody.replace('{!User.FirstName}', userFirstName) : plainBody;
        plainBody = plainBody.contains('{!Opportunity.Account}') ? plainBody.replace('{!Opportunity.Account}', opp.Account.Name) : plainBody;
        plainBody = plainBody.contains('{!Opportunity.Name}') ? plainBody.replace('{!Opportunity.Name}', opp.Name) : plainBody;
        plainBody = plainBody.contains('{!Opportunity.Amount}') ? plainBody.replace('{!Opportunity.Amount}', String.ValueOf(opp.Amount)) : plainBody;

        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();

        email.setOrgWideEmailAddressId(orgWideEmailAddress);
        email.setToAddresses(toAddress);
        email.setSaveAsActivity(false);
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        email.setPlainTextBody(plainBody);
        return email;
    }

    public static Messaging.SingleEmailMessage getEmailBody(Id emailTemplteId, Id orgWideEmailAddress, Opportunity opp, List<String> toAddresses){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage msg = Messaging.renderStoredEmailTemplate(emailTemplteId, null, opp.ID);//Messaging.renderStoredEmailTemplate(emailTemplate.ID, opp.OwnerId, opp.Id);
        mail.setOrgWideEmailAddressId(orgWideEmailAddress);
        mail.setHtmlBody(msg.getHtmlBody());
        mail.setSubject(msg.getSubject());
        if (toAddresses == null){
            //mail.setTargetObjectId(opp.OwnerId);
            toAddresses = new List<string>();
        }
        toAddresses.add(opp.Owner.Email);
        if (opp.Signed_MSA__c){
            toAddresses.addAll(Label.TrainingMSATeam.split(';'));
        }
       
            mail.setToAddresses(toAddresses);
       
        mail.setSaveAsActivity(false);
        return mail;
    }

    //Method to get TemplatesIds
    private static Map<String, EmailTemplate> getEmailTemplateId(){
        List<String> templateName = new List<String>{ 'Opp_closed_docusign_complete_for_Individual_Membership', 'Opp_Closed_Docusign_Complete', 'Opportunity_Cannot_Close', 'DocuSign_Declined_Notification' };
        Map<String, EmailTemplate> emailTemplateNameById = new Map<String, EmailTemplate>();
        for (EmailTemplate template : [SELECT Id, DeveloperName, Subject, HtmlValue, Body
                                       FROM EmailTemplate
                                       WHERE DeveloperName IN:templateName
                                       WITH SECURITY_ENFORCED]){
            emailTemplateNameById.put(template.DeveloperName, template);
        }
        return emailTemplateNameById;
    }

    public static String replaceKeywords(String body, Opportunity opp, String toName, Map<Id, dsfs__DocuSign_Status__c> declinedDocuSign){
        String OpprunityLink = '<a href="' + opp.Opportunity_Link__c + '">' + opp.Name + '</a>';
        String billinConLink = '<a href="' + opp.Billing_Contact_URL__c + '">' + opp.Billing_Contact__r.Name + '</a>';
        body = body.replace('[OpportunityOwnerFirstName]', toName);
        body = body.replace('[OpportunityName]', opp.Name);

        body = body.replace('[UserName]', declinedDocuSign.get(opp.Id).Signatory_Status__c);

        body = body.replace('[DeclinedReason]', declinedDocuSign.get(opp.Id).dsfs__Declined_Reason__c);

        body = body.replace('[OpportunityLink]', OpprunityLink);

        body = body.replace('[AccountName]', opp.Account.name);

        body = body.replace('[ProjectName]', opp.Project_Name__r.Name);
        body = body.replace('[BillingContactLink]', billinConLink);
        body = body.replace('[OpportunityAmount]', String.ValueOf(opp.Amount));
        return body;
    }

    private static void updateOppApplicationStatus(Map<Id, dsfs__DocuSign_Status__c> newMap, Map<Id, dsfs__DocuSign_Status__c> oldMap){
        Map<Id, Opportunity> opportunitiesToUpdate = new Map<Id, Opportunity>();
        Set<Id> setOppsWithCompletedDocSign = new Set<Id>();
        Map<Id, Opportunity> newBusinessOpps = new Map<Id, Opportunity>(getNewBusinessOpps(newMap));


        //Iterate through each docusignStatus
        for (dsfs__DocuSign_Status__c docuSign : newMap.values()){
            //if status is completed then add the opportunity to set
            if ((oldMap == null || (oldMap != null && docuSign.dsfs__Envelope_Status__c != oldMap.get(docuSign.Id).dsfs__Envelope_Status__c) || docuSign.Signatory_Status__c != oldMap.get(docuSign.Id).Signatory_Status__c) && docuSign.dsfs__Opportunity__c != null && newBusinessOpps.containsKey(docuSign.dsfs__Opportunity__c)){

                switch  on docuSign.dsfs__Envelope_Status__c{
                    when 'Voided'{
                        opportunitiesToUpdate.put(docuSign.dsfs__Opportunity__c, new Opportunity(Id = docuSign.dsfs__Opportunity__c, ApplicationStatus__c = 'Application Received'));
                    }
                    when 'Sent'{
                        if (oldMap == null || docuSign.Signatory_Status__c == null || (oldMap != null && docuSign.Signatory_Status__c != oldMap.get(docuSign.Id).Signatory_Status__c && oldMap.get(docuSign.Id).Signatory_Status__c == null)){

                            opportunitiesToUpdate.put(docuSign.dsfs__Opportunity__c, new Opportunity(Id = docuSign.dsfs__Opportunity__c, ApplicationStatus__c = 'Waiting for Customer Signature'));

                        } else if (docuSign.Signatory_Status__c != oldMap.get(docuSign.Id).Signatory_Status__c && docuSign.Signatory_Status__c != 'Completed' && docuSign.Signatory_Status__c != null){
                            opportunitiesToUpdate.put(docuSign.dsfs__Opportunity__c, new Opportunity(Id = docuSign.dsfs__Opportunity__c, ApplicationStatus__c = 'Waiting for Linux Foundation Signature'));

                        }
                    }
                    when 'Completed'{
                        opportunitiesToUpdate.put(docuSign.dsfs__Opportunity__c, new Opportunity(Id = docuSign.dsfs__Opportunity__c, ApplicationStatus__c = 'Waiting to Close by PM'));
                    }

                    when 'Declined'{
                        opportunitiesToUpdate.put(docuSign.dsfs__Opportunity__c, new Opportunity(Id = docuSign.dsfs__Opportunity__c, ApplicationStatus__c = 'Application Received'));
                    }
                }
            }
        }


        if (!opportunitiesToUpdate.isEmpty()){
            Database.update (opportunitiesToUpdate.values(), false);
        }
    }

    public static list<Opportunity> getNewBusinessOpps(Map<Id, dsfs__DocuSign_Status__c> newMap){
        list<Opportunity> listOpps = new list<Opportunity>();
        Set<Id> setOppIds = new Set<ID>();

        //Iterate through each docusignStatus
        for (dsfs__DocuSign_Status__c docuSign : newMap.values()){
            setOppIds.add(docuSign.dsfs__Opportunity__c);
        }

        if (!setOppIds.isEmpty()){
            listOpps = new list<Opportunity>([Select id, isWon, type
                                              from Opportunity 
                                              where id in:setOppIds and iswon = false and type = 'New Business']);
        }

        return listOpps;
    }

}