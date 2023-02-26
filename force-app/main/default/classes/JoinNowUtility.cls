/*
 LastModified By             ModifiedDate            Methods                                                 Against
 ========================================================================================================================
 Kalyani Chiluveri             24-Jun-2020         from 117 - 301                                           SFDC - 1344
 */
public class JoinNowUtility{
    public static Map<String, String> labelVsValues = new Map<String, String>();
    public static List<String> contactLeadSource = new List<String>();
    public static Map<String, List<String>> leadSourceVsDetail = new Map<String, List<String>>();
    public static Map<String, Contact> contactIdVsAccountID = new Map<String, Contact>();
    public static Map<String, Alternate_Email__c> emailVsAltEmail = new Map<String, Alternate_Email__c>();
    public static Map<String, String> emailOrConIdVsEmailOrConid = new Map<String, String>();
    public static Map<String, Contact> emailVsContact = new Map<String, Contact>();
    public static Map<String, Lead> emailVsLead = new Map<String, Lead>();
    public static Map<String, ConvertLeadDetails> convertLeadDetails = new Map<String, ConvertLeadDetails>();
    public static Map<String, JoinNowUtility.ContactLeadAndLeadDetailsWrapper> cotactPicklistDetails = new Map<String, JoinNowUtility.ContactLeadAndLeadDetailsWrapper>();
    static{
        getConfigValues();
        populateLeadvsLeadDetails();
    }
    public static void upsertAccountAndProject(Id accId, Id projectId, String categoryString){

        if (String.isNotBlank(categoryString)){

            Map<String, String> categoryPicklistMap = new Map<String, String>();
            Schema.DescribeFieldResult categoryFiledResult = Account_And_Project__c.Category__c.getDescribe();
            List<Schema.PicklistEntry> categoryValues = categoryFiledResult.getPicklistValues();

            for (Schema.PicklistEntry v : categoryValues){
                categoryPicklistMap.put(v.getValue(), v.getLabel());
            }

            if (categoryPicklistMap.containsKey(categoryString)){
                Account_And_Project__c account_and_project = new Account_And_Project__c();
                if (!String.isBlank(accId) && !String.isBlank(projectId)){
                    List<Account_And_Project__c> accountAndProjectList = [SELECT Id, Category__c, Project__c, Account__c
                                                                          FROM Account_And_Project__c
                                                                          WHERE Project__c = :projectId AND Account__c = :accId];
                    if (accountAndProjectList.size() > 0){
                        account_and_project = accountAndProjectList[0];
                        JoinNowFormSubmission.beforeUpsertAccountAndProject = accountAndProjectList[0];
                    } else{
                        account_and_project.Account__c = accId;
                        account_and_project.Project__c = projectId;
                    }
                    account_and_project.Category__c = categoryString;

                    upsert account_and_project;
                    JoinNowFormSubmission.afterUpsertAccountAndProject = account_and_project;
                    System.debug(account_and_project + '====> account_and_project');
                }
            }
        }
    }

    public static boolean checkIdValidity(List<String> recordIds, System.Type t){
        boolean validIds = True;
        for (String recordId : recordIds){
            if (!isValidSalesforceId(recordId, t)){
                validIds = False;
                break;
            }
        }

        if (validIds){
            String queryString = 'Select Count(Id) foundIds From ' + t + ' Where Id in :recordIds';
            System.debug('queryString: ' + queryString);
            SObject resultObject = Database.query(queryString);
            System.debug(resultObject);
            System.debug(resultObject.get('foundIds'));

            if (resultObject.get('foundIds') != recordIds.size()){
                validIds = false;
            }
        }

        return validIds;
    }

    public static Boolean isValidSalesforceId(String Ids, System.Type t){
        try{
            if (Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(Ids).matches()){
                Id id = Ids;
                sObject sObj = (sObject) t.newInstance();
                sObj.Id = id;
                return true;
            }
        } catch (Exception e){
            system.debug(e);
        }
        return false;
    }

    public static Map<String, Boolean> checkForPersonAccount(Set<Id> ContIds, Id AccountId){
        Boolean remapContact = True;
        Map<String, Boolean> conIDVsRemap = new Map<String, Boolean>();
        Map<String, Account> personConIDVsAccID = new Map<String, Account>();
        List<Account> updateAccs = new List<Account>();
        Account[] accs = [SELECT Id, Name, PersonContactId, (SELECT Id
                                                             FROM Opportunities)
                          FROM Account 
                          Where PersonContactId IN:ContIds];
        ID RecordTypeId = [Select Id, DeveloperName
                           From RecordType
                           Where sObjectType = 'Account' AND DeveloperName = 'Company_Account'
                           LIMIT 1].Id;

        for (Account accRec : accs){
            personConIDVsAccID.put(accRec.PersonContactId, accRec);
        }

        System.debug('accs: ' + accs);
        for (Id conID : ContIds){

            if (!personConIDVsAccID.isEmpty() && personConIDVsAccID.containsKey(conID) && personConIDVsAccID.get(conID).Opportunities.size() > 0){
                conIDVsRemap.put(conID, False);

            } else if (!personConIDVsAccID.isEmpty() && personConIDVsAccID.containsKey(conID)){
                conIDVsRemap.put(conID, TRUE);
                Account acc = new Account();
                acc.id = personConIDVsAccID.get(conID).Id;
                acc.RecordTypeId = RecordTypeId;
                updateAccs.add(acc);
            }

        }

        if (!updateAccs.isEmpty()){
            update updateAccs;
            delete updateAccs;
        }

        return conIDVsRemap;
    }

    public static Boolean checkForPersonAccount(Id ContId, Boolean deleteAccount, Id AccountId){
        Boolean remapContact = True;
        Account[] accs = [SELECT Id, Name, PersonContactId, (SELECT Id
                                                             FROM Opportunities)
                          FROM Account 
                          Where PersonContactId = :contId
                          LIMIT 1];

        System.debug('accs: ' + accs);

        if (!accs.isEmpty() && accs[0].Opportunities.size() > 0){
            remapContact = False;
        } else if (!accs.isEmpty()){
            Account acc = new Account();
            acc.id = accs[0].Id;
            acc.RecordTypeId = [Select Id, DeveloperName
                                From RecordType
                                Where sObjectType = 'Account' AND DeveloperName = 'Company_Account'
                                LIMIT 1].Id;
            update acc;
            if (deleteAccount){
                Contact con = new Contact();
                con.Id = ContId;
                con.AccountId = AccountId;
                update con;

                delete acc;
            }
        }

        System.debug('remapContact: ' + remapContact);
        return remapContact;
    }

    public static Map<String, String> getConfigValues(){
        List<Linux_Config__mdt> configList;
        if (labelVsValues.isEmpty()){
            configList = [Select Label, Value__c
                          from Linux_Config__mdt
                          where Label = 'ContactLeadSourceDetail' OR Label = 'ContactLeadSource'];
        }
        for (Linux_Config__mdt obj : configList){
            labelVsValues.put(obj.Label, obj.Value__c);
        }
        return labelVsValues;
    }

    public static List<String> splitValue(String splitString, String delimeter){
        List<String> splitStringValues = new List<String>();
        if (splitString != NULL && splitString != ''){
            splitStringValues = splitString.split(delimeter);
        }
        return splitStringValues;
    }

    public static void populateLeadvsLeadDetails(){
        List<String> contactLeadSourceDetail = JoinNowUtility.splitValue(labelVsValues.get('ContactLeadSourceDetail'), ';');
        contactLeadSource = JoinNowUtility.splitValue(labelVsValues.get('ContactLeadSource'), ';');
        for (String conLeadDt : contactLeadSourceDetail){
            List<String> newList = JoinNowUtility.splitValue(conLeadDt, '=>');
            leadSourceVsDetail.put(newList[0].trim(), JoinNowUtility.splitValue(newList[1], ','));
        }
    }

    public static Map<String, ContactLeadAndLeadDetailsWrapper> checkForLeadSouceAndDetails(Map<String, String> emailVsLeadId, Map<String, Alternate_Email__c> emailVsAltEmail){
        Map<String, ContactLeadAndLeadDetailsWrapper> leadIdVsLeadDetails = new Map<String, ContactLeadAndLeadDetailsWrapper>();
        for (String leadEmail : emailVsLeadId.keySet()){
            Alternate_Email__c altEmail = emailVsAltEmail.get(leadEmail);
            if (altEmail.Lead_Name__r.LeadSource != NULL && altEmail.Lead_Name__r.Lead_Source_Detail_p__c != NULL){
                if ((!(contactLeadSource.contains(altEmail.Lead_Name__r.LeadSource.trim()))) || (!((leadSourceVsDetail.get(altEmail.Lead_Name__r.LeadSource.trim()).contains(altEmail.Lead_Name__r.Lead_Source_Detail_p__c.trim()))))){
                    leadIdVsLeadDetails.put(emailVsLeadId.get(leadEmail), new ContactLeadAndLeadDetailsWrapper(leadEmail, altEmail.Lead_Name__r.LeadSource, altEmail.Lead_Name__r.Lead_Source_Detail_p__c));
                }
            } else{
                leadIdVsLeadDetails.put(emailVsLeadId.get(leadEmail), new ContactLeadAndLeadDetailsWrapper(leadEmail, altEmail.Lead_Name__r.LeadSource, altEmail.Lead_Name__r.Lead_Source_Detail_p__c));
            }
        }
        if (!leadIdVsLeadDetails.isEmpty())
            JoinNowUtility.updateLeadDetails(leadIdVsLeadDetails);
        return leadIdVsLeadDetails;
    }

    public static Map<String, ContactLeadAndLeadDetailsWrapper> checkForLeadDetails(List<Lead> leadList){
        Map<String, ContactLeadAndLeadDetailsWrapper> leadIdVsLeadDetails = new Map<String, ContactLeadAndLeadDetailsWrapper>();
        for (Lead leadRec : leadList){
            if (leadRec.LeadSource != NULL && leadRec.Lead_Source_Detail_p__c != NULL){
                if ((!(contactLeadSource.contains(leadRec.LeadSource.trim()))) || (!((leadSourceVsDetail.get(leadRec.LeadSource.trim()).contains(leadRec.Lead_Source_Detail_p__c.trim()))))){
                    leadIdVsLeadDetails.put(leadRec.ID, new ContactLeadAndLeadDetailsWrapper(leadRec.Email, leadRec.LeadSource, leadRec.Lead_Source_Detail_p__c));
                }
            } else{
                leadIdVsLeadDetails.put(leadRec.ID, new ContactLeadAndLeadDetailsWrapper(leadRec.Email, leadRec.LeadSource, leadRec.Lead_Source_Detail_p__c));
            }
        }
        if (!leadIdVsLeadDetails.isEmpty())
            JoinNowUtility.updateLeadDetails(leadIdVsLeadDetails);
        return leadIdVsLeadDetails;
    }

    public static void updateLeadDetails(Map<String, ContactLeadAndLeadDetailsWrapper> leadIdVsLeadDetails){
        List<lead> updateLeadList = new List<Lead>();
        for (String leadID : leadIdVsLeadDetails.keySet()){
            Lead leadObj = new Lead();
            leadObj.Id = leadID;
            leadObj.LeadSource = '';
            leadObj.Lead_Source_Detail_p__c = '';
            updateLeadList.add(leadObj);
        }

        if (!updateLeadList.isEmpty()){
            update updateLeadList;
        }
    }

    public static void populateContactDetails(Map<String, ContactLeadAndLeadDetailsWrapper> leadIdVsLeadDetails, Map<String, String> emailVsContactId, Map<String, Contact> emailVsContact){

        for (String leadID : leadIdVsLeadDetails.keySet()){
            Contact conObj = new Contact();
            conObj.Id = emailVsContactId.get(leadIdVsLeadDetails.get(leadID).emailAddress);
            conObj.LeadSource = 'Join Us Form';
            conObj.Lead_Source_Detail1__c = 'Other';
            conObj.Lead_Source_Detail__c = leadIdVsLeadDetails.get(leadID).leadSource + ',' + leadIdVsLeadDetails.get(leadID).leadSourceDetail;
            emailVsContact.put(leadIdVsLeadDetails.get(leadID).emailAddress, conObj);
        }
    }

    public static List<Messaging.SingleEmailMessage> getAllEmailTemps(String requestBody, String errorMessage, List<Opportunity> opps, ID orgWideEmailID, JoinNowRequestWrapper fd, Project__c prj, Boolean oppExist, Boolean informOppOwnerForWebsite, Boolean brandNewAccount, String mergeWebsite, Boolean isEmployeeSizeUpdated){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        //Email Submission or Failure
        mailList.add(JoinNowUtility.getSumissionMail(requestBody, errorMessage, opps, orgWideEmailID));

        //Email to authorzed signatory
        if ((String.isNotBlank(fd.pm_authSig_emailParam) || String.isNotBlank(fd.pm_authSig_id)) && oppExist){
            Messaging.SingleEmailMessage mail = JoinNowUtility.getAuthSignatoryMail(fd, prj, orgWideEmailID, opps[0].Id);
            if (mail != NULL){
                mailList.add(mail);
            }
        }
        //Email to Opportunity Owner
        if (oppExist){

            if (informOppOwnerForWebsite){
                Messaging.SingleEmailMessage emailTemp = JoinNowUtility.getMergeAccountEmail(opps[0], orgWideEmailID, mergeWebsite);
                if (emailTemp != NULL)
                    mailList.add(emailTemp);
            }

            mailList.add(JoinNowUtility.getOppOwnerMail(fd, prj, opps[0], orgWideEmailID, informOppOwnerForWebsite, brandNewAccount, isEmployeeSizeUpdated, false, opps[0].Owner.Email));
            Set<String> groupIds = new Set<String>();
            for (OpportunityLineItem oli : opps[0].OpportunityLineItems){
                if (String.isNotBlank(oli.Projects__r.Notifications_Group__c)){
                    groupIds.add(oli.Projects__r.Notifications_Group__c);
                }
            }

            for (String emailID : groupIds){
                mailList.add(JoinNowUtility.getOppOwnerMail(fd, prj, opps[0], orgWideEmailID, informOppOwnerForWebsite, brandNewAccount, isEmployeeSizeUpdated, true, emailID));
            }
        }

        return mailList;
    }

    public static Messaging.SingleEmailMessage getMergeAccountEmail(Opportunity oppt, ID orgWideEmailID, String mergeWebsite){
        String subject = 'New Duplicate Account Submission by Joinnow';
        String htmlBody = 'Hi,<br/>New Account <b>' + oppt.Account.Name + '</b> is been submitted by Join now.<br/>';
        htmlBody += '<br/>There is existing account with same Website. Joinnow created account with <b>' + mergeWebsite + '</b>.<br/>';
        htmlBody += '<br/>Please verify and Merge the accounts.<br/><br/>Thank You,<Br/> The Linux Foundation';

        List<Group> pp = [SELECT (select userOrGroupId
                                  from groupMembers)
                          FROM group
                          WHERE name = 'Salesops'];
        Set<ID> idSet = new Set<ID>();
        List<String> emailList = new List<String>();
        Messaging.SingleEmailMessage emailTemp = new Messaging.SingleEmailMessage();
        if (!pp.isEmpty() && pp[0].groupMembers != NULL){
            for (GroupMember grpMem : pp[0].groupMembers){
                idSet.add(grpMem.UserOrGroupID);
            }
        }
        for (User u : [Select Id, Email
                       from User
                       where Id In:idSet]){
            emailList.add(u.Email);
        }

        if (!emailList.isEmpty())
            emailTemp = createEmailTemplate(emailList, orgWideEmailID, subject, htmlBody, null);
        return emailTemp;
    }

    public static Messaging.SingleEmailMessage getSumissionMail(String requestBody, String errorMessage, List<Opportunity> opps, ID orgWideEmailID){
        string Body = 'Hi there, <br/> <br/> We have a new submission from Join Now form. <br/> Please find below details of the submission<br/><br/>';
        requestBody = requestBody.replaceAll('":"', ' : ');
        requestBody = requestBody.replaceAll('","', '<br>');
        requestBody = requestBody.replaceAll('":false,"', ': false <br>');
        requestBody = requestBody.replaceAll('":true,"', ': true <br>');
        requestBody = requestBody.replace('{"', '<br>');
        requestBody = requestBody.replace('"}', '<br>');
        Body += requestBody;

        String[] toAddresses = label.JoinNow_Form_Submission_Recipients.split(';');
        String subject = 'Join Now Form Submission';
        if (errorMessage != null && errorMessage != ''){
            Body += '<br/> <br/> ' + errorMessage;
            if (!opps.IsEmpty()){
                toAddresses.add(opps[0].Owner.Email);
            }
            subject = 'Join Now Form Submission [Failed]';
        }
        return createEmailTemplate(toAddresses, orgWideEmailID, subject, Body, NULL);
    }

    public static Messaging.SingleEmailMessage getAuthSignatoryMail(JoinNowRequestWrapper fd, Project__c prj, ID orgWideEmailID, ID oppID){
        Messaging.SingleEmailMessage mail;
        if (String.isNotBlank(fd.pm_authSig_id)){
            Contact[] cons = [Select Id, FirstName, Name, Email
                              From Contact
                              WHERE ID = :fd.pm_authSig_id];
            if (cons.size() > 0){
                fd.pm_authSig_emailParam = cons[0].Email;
                fd.pm_authSig_fname = cons[0].FirstName;
            }
        }

        if (String.isNotBlank(fd.pm_authSig_emailParam)){
            String subject = 'New Membership Application: ' + prj.Name;

            String htmlBody = '';// = Label.Join_Now_Form_Submission_Mail;

            if (prj.External_Submission_Notification__c != NULL && prj.External_Submission_Notification__c != ''){
                htmlBody = prj.External_Submission_Notification__c;
            } else{
                htmlBody = Label.Join_Now_Form_Submission_Mail;
            }
            htmlBody = htmlBody.replace('[UserFirstName]', fd.pm_authSig_fname).replace('[ProjectName]', prj.Name);
            htmlBody = htmlBody.replace('[ProjectURL]', '<ul><li>' + prj.Website__c + '</li></ul>');
            mail = createEmailTemplate(new List<String>{ fd.pm_authSig_emailParam }, orgWideEmailID, subject, htmlBody, oppID);
        }
        return mail;
    }

    public static Messaging.SingleEmailMessage getOppOwnerMail(JoinNowRequestWrapper fd, Project__c prj, Opportunity oppt, ID orgWideEmailID, Boolean informOppOwnerForWebsite, Boolean brandNewAccount, Boolean isEmployeeSizeUpdated, Boolean forNotificationGroup, String emailId){
        //emailId = 'meenakshi.j@cloudroute.in';
        if (String.isNotBlank(fd.pm_authSig_id)){
            Contact[] cons = [Select Id, FirstName, LastName
                              From Contact
                              WHERE ID = :fd.pm_authSig_id];
            if (cons.size() > 0){
                fd.pm_authSig_fname = cons[0].FirstName;
                fd.pm_authSig_lname = cons[0].LastName;
            }
        }
        String AuthorisedContactFullName = fd.pm_authSig_fname + ' ' + fd.pm_authSig_lname;
        String subject = 'New Membership Application from ' + oppt.Account.Name + ': ' + prj.Name;
        String htmlBody = '';// = Label.JoinNow_OpportunityOwnerEmail;
        String OpprunityLink = '<a href="' + oppt.Opportunity_Link__c + '">' + oppt.Name + '</a>';
        if (prj.Internal_New_Opportuntiy_Notification__c != NULL && prj.Internal_New_Opportuntiy_Notification__c != ''){
            htmlBody = prj.Internal_New_Opportuntiy_Notification__c;
        } else{
            htmlBody = Label.JoinNow_OpportunityOwnerEmail;
        }

        String brandNewAcc = '<b>New Account is created with this submission, Review Account Name, Website and Address before sending contract.</b><br><br>';
        if (!forNotificationGroup){
            htmlBody = htmlBody.replace('[OpportunityOwnerFirstName]', oppt.Owner.FirstName).replace('[OpportunityName]', oppt.Name);
        } else{
            htmlBody = htmlBody.replace('[OpportunityOwnerFirstName]', 'The Project Team').replace('[OpportunityName]', oppt.Name);
        }
        String productDetails = '';

        if (!(oppt.OpportunityLineItems).isEmpty()){
            for (OpportunityLineItem oli : oppt.OpportunityLineItems){
                productDetails += oli.Project__c + ' - ' + oli.Membership__c + ' - ' + oli.Membership_Tier__c + ' Tier - ' + oli.CurrencyisoCode +' ' + oli.UnitPrice + '.<br>';
            }
            productDetails += '<br>';
        }
        htmlBody = htmlBody.replace('[ProductDetails]', productDetails).replace('[PrimaryContactFullName]', AuthorisedContactFullName).replace('[OpportunityAccount]', oppt.Account.Name).replace('[OpportunityLink]', OpprunityLink);

        if (brandNewAccount){
            htmlBody = htmlBody.replace('[BrandNewAccountMessage]', brandNewAcc);
        } else{
            htmlBody = htmlBody.replace('[BrandNewAccountMessage]', '');
        }


        if (isEmployeeSizeUpdated){
            htmlBody = htmlBody.replace('[EmployeeSizeUpdated]', '<br>Employee Size is been updated through the submission. please verify<br>');
        } else{
            htmlBody = htmlBody.replace('[EmployeeSizeUpdated]', '');
        }

        return createEmailTemplate(new List<String>{ emailId }, orgWideEmailID, subject, htmlBody, oppt.Id);
    }

    public static Messaging.SingleEmailMessage createEmailTemplate(List<String> toAddress, ID orgWideID, String subject, String body, ID whatID){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        mail.setOrgWideEmailAddressId(orgWideID);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        if (whatID != NULL){
            mail.setWhatId(whatID);
        }
        return mail;
    }

    public static void getContacts(Set<String> emailsAndCons, String AccountID){
        List<EmailAndContactDetails> emailAndContactDetails = new List<EmailAndContactDetails>();
        Map<String, Alternate_Email__c> alternateEmailList = new Map<String, Alternate_Email__c>();

        Set<Alternate_Email__c> updateAltEmails = new Set<Alternate_Email__c>();
        List<Contact> updateContacts = new List<Contact>();
        try{
            List<Alternate_Email__c> altEmails = [SELECT Id, Alternate_Email_Address__c, Active__c, Primary_Email__c, Contact_Name__c, Contact_Name__r.ID, Contact_Name__r.FirstName, Contact_Name__r.LastName, Contact_Name__r.Title, Contact_Name__r.Phone, Contact_Name__r.Twitter_ID__c, Contact_Name__r.GitHub_ID__c, Contact_Name__r.LinkedIn_ID__c, Contact_Name__r.MailingStreet, Contact_Name__r.MailingCity, Contact_Name__r.MailingState, Contact_Name__r.MailingCountry, Contact_Name__r.MailingPostalCode, Contact_Name__r.Username__c, Contact_Name__r.Additional_Email__c, Lead_Name__r.LeadSource, Lead_Name__r.Lead_Source_Detail_p__c, Contact_Name__r.AccountId, Contact_Name__r.Account.Name, Contact_Name__r.Account.IsPersonAccount, Lead_Name__c, Lead_Name__r.Company, Lead_Name__r.OwnerId, Lead_Name__r.Owner.IsActive, Lead_Name__r.ConvertedContactId, Lead_Name__r.IsConverted, Contact_Name__r.Email
                                                  FROM Alternate_Email__c
                                                  WHERE (Alternate_Email_Address__c IN:emailsAndCons OR Contact_Name__c IN:emailsAndCons) AND (Contact_Name__c != Null OR Lead_Name__c != Null)];
            System.debug('#--altEmails--#' + altEmails.size());
            List<Contact> conList = [SELECT ID, FirstName, LastName, Title, Phone, Twitter_ID__c, GitHub_ID__c, LinkedIn_ID__c, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Username__c, Additional_Email__c, AccountId, Account.Name, Account.IsPersonAccount, Email, LeadSource, Lead_Source_Detail1__c, Lead_Source_Detail__c
                                     from Contact
                                     WHERE EMAIL IN:emailsAndCons OR ID IN:emailsAndCons];
            for (Contact con : conList){
                emailVsContact.put(con.Email, con);
                emailVsContact.put(con.ID, con);
            }

            List<Lead> leadList = [SELECT ID, Name, Email, LeadSource, Lead_Source_Detail_p__c, Company, OwnerId, Owner.IsActive, ConvertedContactId, IsConverted
                                   FROM Lead Lead
                                   WHERE Email IN:emailsAndCons AND IsConverted = False];

            for (Lead leadRec : leadList){
                emailVsLead.put(leadRec.Email, leadRec);
            }
            System.debug('#--emailVsLead--#' + emailVsLead.size());
            for (Alternate_Email__c altEmail : altEmails){
                String ConID = '';
                Boolean updateAltEmail = false;
                Boolean skipAlternateEmail = false;
                if (altEmail.Contact_Name__c != NULL){
                    ConID = (ID) altEmail.Contact_Name__c;
                    if (!emailVsContact.isEmpty() && emailVsContact.containsKey(altEmail.Alternate_Email_Address__c) && altEmail.Contact_Name__c != emailVsContact.get(altEmail.Alternate_Email_Address__c).ID){
                        ConID = (ID) emailVsContact.get(altEmail.Alternate_Email_Address__c).ID;
                        SObject masterContact = prepareContact(emailVsContact.get(altEmail.Alternate_Email_Address__c));
                        SObject duplicateContact = prepareContact(altEmail);
                        emailAndContactDetails.add(new EmailAndContactDetails(altEmail.Alternate_Email_Address__c, emailVsContact.get(altEmail.Alternate_Email_Address__c).ID, masterContact, altEmail.Contact_Name__r.Email, altEmail.Contact_Name__c, duplicateContact, NULL));
                        skipAlternateEmail = true;
                        alternateEmailList.put(altEmail.Alternate_Email_Address__c, altEmail);
                    } else if (!emailVsLead.isEmpty() && emailVsLead.containsKey(altEmail.Alternate_Email_Address__c) && (!emailVsLead.get(altEmail.Alternate_Email_Address__c).IsConverted)){
                        if (altEmail.Contact_Name__r.AccountID != AccountID){
                            Contact con = new Contact();
                            con.ID = altEmail.Contact_Name__c;
                            con.AccountID = AccountID;
                            altEmail.Contact_Name__r.AccountID = AccountID;
                            updateContacts.add(con);
                        }
                        updateAltEmail = true;
                        altEmail.Primary_Email__c = TRUE;
                        ConID = (ID) altEmail.Contact_Name__c;
                        Lead leadRec = emailVsLead.get(altEmail.Alternate_Email_Address__c);
                        convertLeadDetails.put(leadRec.ID, new ConvertLeadDetails(leadRec.Email, leadRec.OwnerId, leadRec.Owner.IsActive, leadRec.ID, leadRec.LeadSource, leadRec.Lead_Source_Detail_p__c, altEmail.Contact_Name__r.ID, NULL));
                    } else if (!altEmail.Primary_Email__c){
                        altEmail.Primary_Email__c = TRUE;
                        updateAltEmail = true;
                    }
                    emailOrConIdVsEmailOrConid.put(altEmail.Alternate_Email_Address__c, ConID);
                    emailOrConIdVsEmailOrConid.put(ConID, altEmail.Alternate_Email_Address__c);
                    emailVsAltEmail.put(ConID, altEmail);
                } else if (altEmail.Lead_Name__c != NULL && (!altEmail.Lead_Name__r.IsConverted)){
                    if (!emailVsContact.isEmpty() && emailVsContact.containsKey(altEmail.Alternate_Email_Address__c)){
                        Contact con = emailVsContact.get(altEmail.Alternate_Email_Address__c);
                        if (con.AccountID != AccountID){
                            con.AccountID = AccountID;
                            altEmail.Contact_Name__r.AccountID = AccountID;
                            updateContacts.add(con);
                        }
                        altEmail.Primary_Email__c = TRUE;
                        updateAltEmail = true;
                        emailVsContact.put(altEmail.Alternate_Email_Address__c, con);
                        convertLeadDetails.put(altEmail.Lead_Name__c, new ConvertLeadDetails(altEmail.Alternate_Email_Address__c, altEmail.Lead_Name__r.OwnerId, altEmail.Lead_Name__r.Owner.IsActive, altEmail.Lead_Name__c, altEmail.Lead_Name__r.LeadSource, altEmail.Lead_Name__r.Lead_Source_Detail_p__c, emailVsContact.get(altEmail.Alternate_Email_Address__c).ID, emailVsContact.get(altEmail.Alternate_Email_Address__c).AccountId));
                    } else if (!emailVsLead.isEmpty() && emailVsLead.containsKey(altEmail.Alternate_Email_Address__c)){
                        convertLeadDetails.put(altEmail.Lead_Name__c, new ConvertLeadDetails(altEmail.Alternate_Email_Address__c, altEmail.Lead_Name__r.OwnerId, altEmail.Lead_Name__r.Owner.IsActive, altEmail.Lead_Name__c, altEmail.Lead_Name__r.LeadSource, altEmail.Lead_Name__r.Lead_Source_Detail_p__c, NULL, NULL));
                    }
                }

                if (!skipAlternateEmail){
                    emailVsAltEmail.put(altEmail.Alternate_Email_Address__c, altEmail);
                }

                if (!skipAlternateEmail && (updateAltEmail || !altEmail.Active__c)){
                    altEmail.Active__c = true;
                    updateAltEmails.add(altEmail);
                }
            }

            if (!alternateEmailList.isEmpty()){
                delete alternateEmailList.values();
            }

            if (!updateContacts.isEmpty()){
                update updateContacts;
            }

            System.debug('emailVsContact' + emailVsContact);
            emailVsContact = getConsOrConvertedLeads(emailVsAltEmail, emailsAndCons, AccountId);
            if (!updateAltEmails.isEMpty()){
                List<Alternate_Email__c> altList = new List<Alternate_Email__c>();
                altList.addAll(updateAltEmails);
                update altList;
            }

            if (!emailAndContactDetails.isEmpty()){
                mergeRecords(emailAndContactDetails);
                for (EmailAndContactDetails rec : emailAndContactDetails){
                    emailVsAltEmail.remove(rec.masterEmail);
                    emailVsAltEmail.remove(rec.masterContactID);
                }
            }


        } catch (Exception ex){
            System.debug('ex===>' + ex);
        }
    }

    public static Map<String, Contact> getConsOrConvertedLeads(Map<String, Alternate_Email__c> emailVsAltEmail, Set<String> emailsAndCons, String AccountID){

        List<String> lstEmailWithoutAltEmail = new List<String>();
        Map<String, String> createALternateMail = new Map<String, String>();
        Map<String, String> leadEmailVsLeadID = new Map<String, String>();
        Map<Id, Alternate_Email__c> updateAltEmails = new Map<Id, Alternate_Email__c>();
        List<Contact> conList = new List<Contact>();
        Id leadID = NULL;
        for (String str : emailsAndCons){
            if (!emailVsAltEmail.containsKey(str)){
                lstEmailWithoutAltEmail.add(str);
            }
        }

        if (!lstEmailWithoutAltEmail.isEmpty()){

            for (String str : lstEmailWithoutAltEmail){
                if (emailVsLead.containsKey(str)){
                    Lead leadRec = emailVsLead.get(str);
                    convertLeadDetails.put(leadRec.Email, new ConvertLeadDetails(leadRec.Email, leadRec.OwnerId, leadRec.Owner.IsActive, leadRec.ID, leadRec.LeadSource, leadRec.Lead_Source_Detail_p__c, NULL, NULL));
                }
            }
        }

        System.debug('#--convertLeadDetails--#' + convertLeadDetails.size());
        if (!convertLeadDetails.isEmpty()){
            leadEmailVsLeadID = getConvertedLeads(convertLeadDetails, AccountID);
        }

        System.debug('leadEmailVsLeadID' + leadEmailVsLeadID);
        for (String emailStr : lstEmailWithoutAltEmail){
            if (emailVsContact.containsKey(emailStr)){
                Contact conRec = emailVsContact.get(emailStr);
                if (!createALternateMail.containsKey(conRec.Email) && !leadEmailVsLeadID.containsKey(conRec.Email)){
                    createALternateMail.put(conRec.Email, conRec.ID);
                }
            }
        }
        if (!leadEmailVsLeadID.isEmpty()){
            for (Contact conRec : [SELECT ID, FirstName, LastName, Title, Phone, Twitter_ID__c, GitHub_ID__c, LinkedIn_ID__c, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Username__c, Additional_Email__c, AccountId, Account.Name, Account.IsPersonAccount, Email, LeadSource, Lead_Source_Detail1__c, Lead_Source_Detail__c
                                   FROM Contact
                                   WHERE Email IN:leadEmailVsLeadID.keySet()]){

                if (!cotactPicklistDetails.isEmpty() && cotactPicklistDetails.containsKey(leadEmailVsLeadID.get(conRec.Email))){
                    conRec.LeadSource = 'Join Us Form';
                    conRec.Lead_Source_Detail1__c = 'Other';
                    conRec.Lead_Source_Detail__c = cotactPicklistDetails.get(leadEmailVsLeadID.get(conRec.Email)).leadSource + ',' + cotactPicklistDetails.get(leadEmailVsLeadID.get(conRec.Email)).leadSourceDetail;
                    conList.add(conRec);
                }
                emailVsContact.put(conRec.Email, conRec);
                emailVsContact.put(conRec.ID, conRec);
            }

            for (Alternate_Email__c altObj : [SELECT ID, Lead_Name__c
                                              FROM Alternate_Email__c
                                              WHERE Alternate_Email_Address__c IN:leadEmailVsLeadID.keySet()]){

                altObj.Lead_Name__c = leadID;
                updateAltEmails.put(altObj.ID, altObj);
            }
        }
        if (!createALternateMail.isEmpty()){
            List<Alternate_Email__c> altEmails = new List<Alternate_Email__c>();
            for (String email : createALternateMail.keySet()){
                Alternate_Email__c altEmail = new Alternate_Email__c();
                altEmail.Active__c = true;
                altEmail.Primary_Email__c = true;
                altEmail.Alternate_Email_Address__c = email;
                altEmail.Contact_Name__c = createALternateMail.get(email);
                altEmails.add(altEmail);
            }
            insert altEmails;
        }
        if (!updateAltEmails.isEmpty()){
            update updateAltEmails.values();
        }
        if (!conList.isEmpty()){
            update conList;
        }
        return emailVsContact;
    }

    public static Map<String, String> getConvertedLeads(Map<String, ConvertLeadDetails> convertLeadDetails, String AccountID){
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        Map<String, Contact> leadEmailVsContact = new Map<String, Contact>();
        Map<String, String> emailvsLeadID = new Map<String, String>();
        Map<String, Alternate_Email__c> emailVsAltEmail = new Map<String, Alternate_Email__c>();
        Map<String, String> leadIDEmail = new Map<String, String>();
        List<Lead> updateLeads = new List<Lead>();
        List<Lead> leads = new List<Lead>();
        for (String leadID : convertLeadDetails.keySet()){
            ConvertLeadDetails leadToBeConverted = convertLeadDetails.get(leadID);
            Lead leadRec = new Lead();
            leadRec.ID = leadToBeConverted.leadId;
            leadRec.LeadSource = leadToBeConverted.leadSource;
            leadRec.Lead_Source_Detail_p__c = leadToBeConverted.leadSourceDetail;
            leadIDEmail.put(leadToBeConverted.leadId, leadToBeConverted.email);
            leads.add(leadRec);
        }
        cotactPicklistDetails = JoinNowUtility.checkForLeadDetails(leads);

        for (String leadID : convertLeadDetails.keySet()){
            ConvertLeadDetails leadRec = convertLeadDetails.get(leadID);
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadRec.leadId);
            lc.setConvertedStatus(Label.Lead_Converted_Status);
            lc.setDoNotCreateOpportunity(true);
            lc.setAccountId(AccountID);
            if (leadRec.contactID != NULL){
                lc.setContactId(leadRec.contactID);
            }

            if (string.valueOf(leadRec.ownerID).startsWith('00G') || !leadRec.ownerStatus){
                lc.setOwnerId(UserInfo.getUserId());
            } else{
                lc.setOwnerId(leadRec.ownerID);
            }
            leadsToConvert.add(lc);

            Lead newLead = new Lead();
            newLead.ID = leadID;
            newLead.Convert_Lead__c = TRUE;
            newLead.Account__c = AccountID;
            emailvsLeadID.put(leadRec.Email, leadID);
            updateLeads.add(newLead);
        }

        System.debug('#--updateLeads--#' + updateLeads.size());
        if (!updateLeads.isEmpty()){
            update updateLeads;
        }


        /*List<Contact> conList = new List<Contact>();
         if (!leadsToConvert.isEmpty()) {
         Database.LeadConvertResult[] lcrs = Database.convertLead(leadsToConvert);
         for (Database.LeadConvertResult lcr : lcrs) {
         if (lcr.isSuccess()) {
         String email = leadIDEmail.get(lcr.getLeadId());
         Contact con = new Contact();
         con.id = lcr.getContactId();
         System.debug('email===>'+email);
         con.Email = email;
         if(leadIdVsLeadDetails.containsKey(lcr.getLeadId())) {
         con.LeadSource = 'Join Us Form';
         con.Lead_Source_Detail1__c = 'Other';
         con.Lead_Source_Detail__c = leadIdVsLeadDetails.get(lcr.getLeadId()).leadSource+','+leadIdVsLeadDetails.get(lcr.getLeadId()).leadSourceDetail;
         conList.add(con);
         }
         leadEmailVsContact.put(email, con);
         }
         }
         }

         if(!conList.isEmpty()) {
         update conList;
         }*/
        return emailvsLeadID;
    }

    public static void mergeDuplicateContacts(List<EmailAndContactDetails> emailParamAndValues){
        List<EmailAndContactDetails> mergeEmailAndContactDetails = checkIfMergeNeeded(emailParamAndValues);
        if (!mergeEmailAndContactDetails.isEmpty()){
            populateContactEmail(mergeEmailAndContactDetails);
            mergeRecords(mergeEmailAndContactDetails);
        }
    }

    public static List<EmailAndContactDetails> checkIfMergeNeeded(List<EmailAndContactDetails> emailParamAndValues){
        List<EmailAndContactDetails> mergeEmailAndContactDetails = new List<EmailAndContactDetails>();
        for (EmailAndContactDetails rec : emailParamAndValues){
            if (emailOrConIdvsEmailOrConid.containsKey(rec.masterEmail)){
                if (emailOrConIdvsEmailOrConid.get(rec.masterEmail) != rec.duplicateConId){
                    mergeEmailAndContactDetails.add(rec);
                }
            } else if (emailVsContact.containsKey(rec.masterEmail)){
                if (emailVsContact.get(rec.masterEmail).ID != rec.duplicateConId){
                    mergeEmailAndContactDetails.add(rec);
                }
            }
        }
        return mergeEmailAndContactDetails;
    }

    public static void populateContactEmail(List<EmailAndContactDetails> mergeEmailAndContactDetails){

        for (EmailAndContactDetails emailParams : mergeEmailAndContactDetails){
            //Populating Master Con Details.
            if (emailVsAltEmail.containsKey(emailParams.masterEmail)){
                Alternate_Email__c altEmail = emailVsAltEmail.get(emailParams.masterEmail);
                // Email with Contact
                if (altEmail.Contact_Name__c != Null){
                    emailParams.masterContactID = altEmail.Contact_Name__c;
                    emailParams.masterContact = prepareContact(altEmail);
                } else if (altEmail.Lead_Name__c != Null){
                    emailParams.masterContact = prepareContact(emailVsContact.get(emailParams.masterEmail));
                }
            } else{
                if (emailVsContact.containsKey(emailParams.masterEmail)){
                    emailParams.masterContact = prepareContact(emailVsContact.get(emailParams.masterEmail));
                }
            }
            if (emailOrConIdvsEmailOrConid.containsKey(emailParams.duplicateConId)){
                Alternate_Email__c altEmail = emailVsAltEmail.get(emailOrConIdvsEmailOrConid.get(emailParams.duplicateConId));
                emailParams.duplicateEmail = emailOrConIdvsEmailOrConid.get(emailParams.duplicateConId);
                emailParams.duplicateContact = prepareContact(altEmail);
            } else{
                if (emailVsContact.containsKey(emailParams.duplicateConId)){
                    emailParams.duplicateContact = prepareContact(emailVsContact.get(emailParams.duplicateConId));
                }
            }
        }
    }

    public static Contact prepareContact(Alternate_Email__c altRecord){
        Contact con = new Contact();
        con.ID = altRecord.Contact_Name__c;
        con.FirstName = altRecord.Contact_Name__r.FirstName;
        con.LastName = altRecord.Contact_Name__r.LastName;
        con.Title = altRecord.Contact_Name__r.Title;
        con.Phone = altRecord.Contact_Name__r.Phone;
        con.Twitter_ID__c = altRecord.Contact_Name__r.Twitter_ID__c;
        con.GitHub_ID__c = altRecord.Contact_Name__r.GitHub_ID__c;
        con.LinkedIn_ID__c = altRecord.Contact_Name__r.LinkedIn_ID__c;
        con.MailingStreet = altRecord.Contact_Name__r.MailingStreet;
        con.MailingCity = altRecord.Contact_Name__r.MailingCity;
        con.MailingState = altRecord.Contact_Name__r.MailingState;
        con.MailingCountry = altRecord.Contact_Name__r.MailingCountry;
        con.MailingPostalCode = altRecord.Contact_Name__r.MailingPostalCode;
        con.Username__c = altRecord.Contact_Name__r.Username__c;
        con.AccountID = altRecord.Contact_Name__r.AccountID;
        con.Email = altRecord.Contact_Name__r.Email;
        if (String.valueOf(altRecord.Contact_Name__r.Account.IsPersonAccount).equalsIgnoreCase('true')){
            contactIdVsAccountID.put(altRecord.Contact_Name__c, con);
        }
        return con;
    }

    public static Contact prepareContact(Contact conRec){
        Contact con = new Contact();
        con.ID = conRec.ID;
        con.FirstName = conRec.FirstName;
        con.LastName = conRec.LastName;
        con.Title = conRec.Title;
        con.Phone = conRec.Phone;
        con.Twitter_ID__c = conRec.Twitter_ID__c;
        con.GitHub_ID__c = conRec.GitHub_ID__c;
        con.LinkedIn_ID__c = conRec.LinkedIn_ID__c;
        con.MailingStreet = conRec.MailingStreet;
        con.MailingCity = conRec.MailingCity;
        con.MailingState = conRec.MailingState;
        con.MailingCountry = conRec.MailingCountry;
        con.MailingPostalCode = conRec.MailingPostalCode;
        con.Username__c = conRec.Username__c;
        con.AccountID = conRec.AccountID;
        con.Email = conRec.Email;
        if (String.valueOf(conRec.Account.IsPersonAccount).equalsIgnoreCase('true')){
            contactIdVsAccountID.put(conRec.ID, con);
        }

        return con;
    }

    public static void mergeRecords(List<EmailAndContactDetails> mergeEmailAndCon){
        Map<String, Contact> updatedAccs = new Map<String, Contact>();
        List<MergeContactsDetails> masterVsDuplicate = new List<MergeContactsDetails>();
        Map<ID, Contact> updateContact = new Map<ID, Contact>();
        if (!contactIdVsAccountID.isEmpty()){
            Map<String, Contact> personAccounts = new Map<String, Contact>();
            for (String conID : contactIdVsAccountID.keySet()){
                Account acc = new Account();
                acc.ID = contactIdVsAccountID.get(conID).AccountID;
                personAccounts.put(acc.ID, contactIdVsAccountID.get(conID));
            }
            if (!personAccounts.isEmpty()){
                updatedAccs = updatePersonAccountsIfZeroOpps(personAccounts);
            }
        }

        for (EmailAndContactDetails con : mergeEmailAndCon){
            Contact masterCon = (Contact) con.masterContact;
            Contact duplicateContact = (Contact) con.duplicateContact;

            if (!contactIdVsAccountID.isEmpty()){

                if (contactIdVsAccountID.containsKey(masterCon.ID)){
                    if (!updatedAccs.isEmpty() && !updatedAccs.containsKey(masterCon.ID)){
                        con.masterContact = NULL;
                    } else if ((!updatedAccs.isEmpty()) && updatedAccs.containsKey(masterCon.ID)){
                        masterCon = updatedAccs.get(masterCon.ID);
                    }
                }

                if (contactIdVsAccountID.containsKey(duplicateContact.ID)){
                    if (!updatedAccs.isEmpty() && !updatedAccs.containsKey(duplicateContact.ID)){
                        con.duplicateContact = NULL;
                    } else{
                        duplicateContact = updatedAccs.get(duplicateContact.ID);
                    }
                }
            }
            if (con.masterContact != NULL && con.duplicateContact != NULL && duplicateContact != NULL && masterCon != NULL){
                if (masterCon.FirstName == NULL && duplicateContact.FirstName != NULL){
                    masterCon.FirstName = duplicateContact.FirstName;
                }

                if (masterCon.LastName == NULL && duplicateContact.LastName != NULL){
                    masterCon.LastName = duplicateContact.LastName;
                }

                if (masterCon.Title == NULL && duplicateContact.Title != NULL){
                    masterCon.Title = duplicateContact.Title;
                }

                if (masterCon.Phone == NULL && duplicateContact.Phone != NULL){
                    masterCon.Phone = duplicateContact.Phone;
                }

                if (masterCon.Twitter_ID__c == NULL && duplicateContact.Twitter_ID__c != NULL){
                    masterCon.Twitter_ID__c = duplicateContact.Twitter_ID__c;
                }

                if (masterCon.GitHub_ID__c == NULL && duplicateContact.GitHub_ID__c != NULL){
                    masterCon.GitHub_ID__c = duplicateContact.GitHub_ID__c;
                }
                if (masterCon.LinkedIn_ID__c == NULL && duplicateContact.LinkedIn_ID__c != NULL){
                    masterCon.LinkedIn_ID__c = duplicateContact.LinkedIn_ID__c;
                }
                if (masterCon.MailingStreet == NULL && duplicateContact.MailingStreet != NULL){
                    masterCon.MailingStreet = duplicateContact.MailingStreet;
                }
                if (masterCon.MailingCity == NULL && duplicateContact.MailingCity != NULL){
                    masterCon.MailingCity = duplicateContact.MailingCity;
                }
                if (masterCon.MailingState == NULL && duplicateContact.MailingState != NULL){
                    masterCon.MailingState = duplicateContact.MailingState;
                }

                if (masterCon.MailingCountry == NULL && duplicateContact.MailingCountry != NULL){
                    masterCon.MailingCountry = duplicateContact.MailingCountry;
                }
                if (masterCon.MailingPostalCode == NULL && duplicateContact.MailingPostalCode != NULL){
                    masterCon.MailingPostalCode = duplicateContact.MailingPostalCode;
                }

                if (masterCon.Username__c == NULL && duplicateContact.Username__c != NULL){
                    masterCon.Username__c = duplicateContact.Username__c;
                }

                masterCon.Additional_Email__c = duplicateContact.Email;


                if (masterCon.AccountID != duplicateContact.AccountID){
                    duplicateContact.AccountID = masterCon.AccountID;
                    updateContact.put(duplicateContact.AccountID, duplicateContact);
                }
                masterVsDuplicate.add(new MergeContactsDetails(masterCon, duplicateContact, con.duplicateConId, con.duplicateEmail));
            }

        }
        if (!updateContact.isEmpty()){
            update updateContact.values();
        }

        for (MergeContactsDetails conRec : masterVsDuplicate){
            try{
                Database.MergeResult result = Database.merge (conRec.masterContact, conRec.duplicateContact);
                emailVsAltEmail.remove(conRec.dupId);
                emailVsAltEmail.remove(conRec.dupEmail);
                emailVsAltEmail.remove(conRec.dupEmail);

            } catch (Exception ex){
                System.debug('Exception ex ==>' + ex.getMessage());
            }
        }
    }

    public static Map<String, Contact> updatePersonAccountsIfZeroOpps(Map<String, Contact> personAccounts){
        List<Account> accList = [SELECT Id, Name, PersonContactId, (SELECT Id
                                                                    FROM Opportunities)
                                 FROM Account 
                                 Where ID = :personAccounts.keySet()];
        Map<String, Contact> updatedAccounts = new Map<String, Contact>();
        List<Account> updateAccs = new List<Account>();

        ID recType = [Select Id, DeveloperName
                      From RecordType
                      Where sObjectType = 'Account' AND DeveloperName = 'Company_Account'
                      LIMIT 1].Id;
        List<Contact> contactsList = new List<Contact>();
        for (Account personAccount : accList){
            if (personAccount.Opportunities.isEmpty()){
                Account accs = new Account();
                accs.id = personAccount.ID;
                accs.RecordTypeID = recType;
                Contact con = personAccounts.get(personAccount.Id);
                con.AccountID = Label.JoinNowIndividual_DefaultAccount;
                contactsList.add(con);
                updatedAccounts.put(con.ID, con);
                updateAccs.add(accs);
            }
        }

        if (!updatedAccounts.isEmpty() && !contactsList.isEmpty()){
            update updateAccs;
            update contactsList;
            delete updateAccs;
        }
        return updatedAccounts;
    }

    @future
    public static void addMembersToCampaign(String listOfCampaignMembers){
        List<CampaignMember> campMembers = (List<CampaignMember>)JSON.deserialize(listOfCampaignMembers, List<CampaignMember>.class);
        upsert campMembers;
    }

    public class EmailAndContactDetails{
        String masterEmail;
        String masterContactID;
        SObject masterContact;
        String duplicateEmail;
        String duplicateConId;
        SObject duplicateContact;
        String isPersonAccount;
        public EmailAndContactDetails(String masterEmail, String masterContactID, SObject masterContact, String duplicateEmail, String duplicateConId, SObject duplicateContact, String isPersonAccount){
            this.masterEmail = masterEmail;
            this.masterContactID = masterContactID;
            this.masterContact = masterContact;

            this.duplicateEmail = duplicateEmail;
            this.duplicateConId = duplicateConId;
            this.duplicateContact = duplicateContact;
        }

    }

    public class MergeContactsDetails{
        public Contact masterContact;
        public Contact duplicateContact;
        public String dupId;
        public string dupEmail;
        public MergeContactsDetails(Contact masterContact, Contact duplicateContact, String dupId, String dupEmail){
            this.masterContact = masterContact;
            this.duplicateContact = duplicateContact;
            this.dupId = dupId;
            this.dupEmail = dupEmail;
        }

    }

    public class ConvertLeadDetails{
        public String email;
        public String ownerID;
        public boolean ownerStatus;
        public string leadId;
        public string leadSource;
        public String leadSourceDetail;
        public String contactID;
        public String accounID;
        public ConvertLeadDetails(String email, String ownerID, boolean ownerStatus, string leadId, string leadSource, string leadSourceDetail, String contactID, String accounID){

            this.email = email;
            this.ownerID = ownerID;
            this.ownerStatus = ownerStatus;
            this.leadId = leadId;
            this.leadSource = leadSource;
            this.leadSourceDetail = leadSourceDetail;
            this.contactID = contactID;
            this.accounID = accounID;
        }

    }

    public class ContactLeadAndLeadDetailsWrapper{
        public String emailAddress;
        public String leadSource;
        public String leadSourceDetail;
        public ContactLeadAndLeadDetailsWrapper(String emailAddress, String leadSource, String leadSourceDetail){
            this.emailAddress = emailAddress;
            this.leadSource = leadSource;
            this.leadSourceDetail = leadSourceDetail;
        }

    }

}