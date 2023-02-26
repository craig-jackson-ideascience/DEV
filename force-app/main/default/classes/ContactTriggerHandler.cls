/*
 LastModified By             ModifiedDate            Methods                                                 Against
 ========================================================================================================================
 Pratik D                    29-May-2020             addCommunityMemberContactORLead                         SFDC-1223
 - Converting this method to batch rather than trigger

 */
public class ContactTriggerHandler implements ITriggerHandler{
    public static ContactTriggerHandlerAction action = new ContactTriggerHandlerAction();
    public static Set<Id> deleteAlternateEmails = new Set<Id>();
	public static Set<Id> accountChangeContactIdSet = new Set<Id>();

    public static void BeforeInsert(List<SObject> triggerNew){
        //call before insert actions
        updateAccountContact(triggerNew);
        Hubspot_Utility.updateHubspotField(triggerNew);
        if (checkConvertFromLeadContact(triggerNew).size() > 0)
            checkValidationOfEmail(null, (List<Contact>)triggerNew);
        updateSocialId(triggerNew, null);
        updateContactOfTIUser((List<Contact>)triggerNew);
        updateCreateMixMaxCampaignCheckbox(null, triggerNew);
    }

    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap){
        if (checkConvertFromLeadContact(newMap.values()).size() > 0)
            checkValidationOfEmail((Map<Id, Contact>)oldMap, (List<Contact>)newMap.values());
        updateAccountContact((List<Contact>)newMap.values(), (Map<Id, Contact>)oldMap);
        //call before update actions
        updateSocialId((List<Contact>)newMap.values(), (Map<Id, Contact>)oldMap);
        //updateLeadSource((Map<Id, Contact>)oldMap, (Map<Id, Contact>)newMap);
        updateCreateMixMaxCampaignCheckbox((Map<Id, Contact>)oldMap, (List<Contact>)newMap.values());
       
    }

    public static void BeforeDelete(Map<Id, Sobject> oldMap){
        //call before delete actions
        getAlternateEmailsToBeDeleted((List<Contact>)oldMap.values());
    }

    public static void AfterInsert(Map<Id, SObject> newMap){
        //After Insert Trigger
        if (checkConvertFromLeadContact((List<Contact>)newMap.values()).size() > 0)
            createOrUpdateAlternateEmail(null, (Map<Id, Contact>)newMap);
        action.checkCventEmail((Map<Id, Contact>)newMap, null);
        updateHubspotOptOut(null, (Map<Id, Contact>)newMap);
    }

    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){
        createOrUpdateAlternateEmail((Map<Id, Contact>)oldMap, (Map<Id, Contact>)newMap);
        updateStatusOnCampaignMember((Map<Id, Contact>)oldMap, (Map<Id, Contact>)newMap);
        action.checkCventEmail((Map<Id, Contact>)newMap, (Map<Id, Contact>)oldMap);
        updateMembershipRolesCorporateEmail((Map<Id, Contact>)newMap, (Map<Id, Contact>)oldMap);
        if(!accountChangeContactIdSet.isEmpty()){
			sendEmailToOppOwnerOnAccountChange();
		}
        //checkForOptOutChange((Map<Id, Contact>)oldMap, (Map<Id, Contact>)newMap);
        //CampaignLeadContact.addCommunityMemberContactORLead(oldMap, newMap);
        updateHubspotOptOut((Map<Id, Contact>)oldMap, (Map<Id, Contact>)newMap);
    }

    public static void AfterDelete(Map<Id, Sobject> oldMap){
        //call after delete actions
        action.deleteAlternateEmail((List<Contact>)oldMap.values(), deleteAlternateEmails);
        action.getMasterRecordIdsToBeProcessed((Map<Id, Contact>)oldMap);
    }

    public static void AfterUnDelete(Map<Id, Sobject> newMap){
        //call after undelete actions
    }

    public Boolean IsDisabled(){
        return false;
    }

    /*
     public static void onAfterUnDelete(Map<Id, Contact> newMap) {
    //call after undelete actions
     }  */
    public static void getAlternateEmailsToBeDeleted(List<Contact> contacts){
        deleteAlternateEmails.clear();
        for (Alternate_Email__c alternateEmail : [SELECT Id
                                                  FROM Alternate_Email__c
                                                  WHERE contact_name__c IN :contacts]){
            deleteAlternateEmails.add(alternateEmail.Id);
        }
    }

    private static Map<String, Id> getAccountByDomain(Set<String> domain){
        Map<String, Id> accountIdByDomain = new Map<string, Id>();
		System.debug('domains=>'+ domain);
        String accountQuery = 'SELECT name,website,id,IsPersonAccount FROM Account WHERE IsPersonAccount != TRUE AND' + 
                              ' website LIKE:domain ORDER By Website ';
        for (Account account : Database.query(AccountQuery)){
            if (!String.isBlank(account.website)){
                String accDomain = account.website.replace('www.', '');
                String accDomain2 = accDomain.replace('http://', '');
                String accDomain3 = accDomain2.replace('https://', '');
                String accDomain4 = accDomain3.replace('http://www.', '');
                accDomain4 = accDomain4.replace('/', '');
                if (!accountIdByDomain.containskey(accDomain4)){
                    accountIdByDomain.put(accDomain4.tolowercase(), account.id);
                }
            }
        }
        return accountIdByDomain;
    }

    private static Map<String, Id> getAccountByName(Set<String> name){
        Map<String, Id> accountIdByName = new Map<string, Id>();

        String accountQuery = 'SELECT Id,Name FROM Account WHERE IsPersonAccount != TRUE AND' + 
                              ' Name LIKE:name ORDER By Name';
        for (Account account : Database.query(AccountQuery)){
            if (!accountIdByName.containskey(account.name.toLowercase())){
                accountIdByName.put(account.name.tolowercase(), account.id);
            }
        }
        return accountIdByName;
    }

    public static void updateAccountContact(List<Contact> Contactlist){
        Map<String, Id> accountIdByDomain = new Map<string, Id>();
        Map<String, Id> accountIdByName = new Map<string, Id>();
        Set<String> setOfDomains = new Set<String>();
        Set<String> cventCompanyNames = new Set<String>();
        List<Account> listofAccount = new List<Account>();

        try{
            // Loop is used to get the Domains from the Contact Email and stored in the Set.
            for (Contact contact : Contactlist){
                if (contact.AccountId == null && contact.Email != null){
                    String contactDomain = contact.Email.substringAfter('@');
                    setOfDomains.add('%' + contactDomain + '%');
                    if (contact.Cvent_Company__c != null && contact.Cvent_Company__c != '.'){
                        cventCompanyNames.add(contact.Cvent_Company__c);
                    }
                    if (String.isNotBlank(contact.Cvent_Company_URL__c)  && contact.Cvent_Company_Domain__c != '.'){
                        setOfDomains.add('%' + contact.Cvent_Company_Domain__c + '%');
                    }
                }
            }


            if (setOfDomains.size() > 0){
                String anonymousAccountName = Label.Lead_Conversion_Account;
                List<Account> anonymousAccount = [SELECT ID
                                                  from Account
                                                  WHERE Name = :anonymousAccountName
                                                  LIMIT 1];
                accountIdByDomain = getAccountByDomain(setOfDomains);
                if (!cventCompanyNames.IsEmpty()){
                    accountIdByName = getAccountByName(cventCompanyNames);
                }
                system.debug('----->mapOfDomains' + accountIdByDomain);
                Map<Contact, Account> mapOfContactVsAccount = new Map<Contact, Account>();
                Set<Id> convertAccount = new set<Id>();

                //Assigning Account Id to Contact
                //if email is empty or the email is not found in the account domain,then it will get conerted into person account
                for (Contact cont : Contactlist){
                    if (cont.AccountId == null){
                        if (String.isNotBlank(cont.Cvent_Company_URL__c) && !accountIdByDomain.isEmpty()){
                            if (String.IsNotBlank(cont.Cvent_Company_Domain__c) && accountIdByDomain.containsKey(cont.Cvent_Company_Domain__c.toLowercase())){
                                cont.AccountId = accountIdByDomain.get(cont.Cvent_Company_Domain__c.toLowercase());
                            }
                        }

                        //check if email domain matches
                        else if (cont.AccountId == null && !accountIdByDomain.isEmpty()){
                            String emailDomain = cont.Email.substringAfter('@').toLowercase();
                            if (accountIdByDomain.containsKey(emailDomain)){
                                cont.AccountId = accountIdByDomain.get(emailDomain);
                            }
                        }
                        //check if exact account exists
                        if (String.isNotBlank(cont.Cvent_Company__c) && !accountIdByName.IsEmpty()){
                            if (accountIdByName.containskey(cont.Cvent_Company__c.toLowercase())){
                                cont.AccountId = accountIdByName.get(cont.Cvent_Company__c.toLowercase());
                            }
                        }
                        //if no account match is found,create account
                        if (cont.AccountId == null){
                            cont.AccountId = anonymousAccount[0].Id; // associate with blank account
                            /*if(String.isNotBlank( cont.Cvent_Company__c)){
                             cont.AccountId = anonymousAccount[0].Id; // associate with blank account
                             }else{
                            //create a Account to assign new created contact, so that we can update the record type of the Account to person Account.
                             Account acc = new Account();
                             acc.Name =  cont.LastName;
                             acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company Account').getRecordTypeId();
                             mapOfContactVsAccount.put(cont, acc);
                             System.debug(' mapOfContactVsAccount.put(cont,acc)' + mapOfContactVsAccount.put(cont, acc));
                             }*/
                        }
                    }
                }
                /*if (mapOfContactVsAccount.values().size() > 0) {
                //Add Accounts to be updated as Person Account.
                 insert mapOfContactVsAccount.values();
                 for (Contact contact : mapOfContactVsAccount.keyset()) {
                 contact.AccountId = mapOfContactVsAccount.get(contact).id;
                //if company name is blank,then only convert it to person account
                 if(String.isBlank(contact.Cvent_Company__c)){
                 convertAccount.add(contact.AccountId);
                 System.debug('convertAccount' + convertAccount);
                 }
                 }
                 }
                 convertToPersonAccount(convertAccount);*/
            }

        } catch (Exception e){
            System.debug(e.getMessage()+' ' + e.getLineNumber());
        }
    }

    //This is used to update Corporate Email on all the Membership Roles for the Contact
    public static void updateMembershipRolesCorporateEmail(Map<Id, Contact> newContactMap, Map<Id, Contact> oldContactMap){
        Map<Id, Id> contactIdByAlternateEmail = new Map<Id, Id>();
        List<Project_Role__c> lstProjectRoles = new List<Project_Role__c>();
        for (Contact cont : newContactMap.values()){
            if ((cont.Corporate_Email__c != null && (oldContactMap != null && oldContactMap.get(cont.id).Corporate_Email__c != cont.Corporate_Email__c))){
                contactIdByAlternateEmail.put(cont.Id,cont.Corporate_Email__c);
            }
        }
        
        for(Project_Role__c projectRole:[Select Id,Alternate_Email__c,Contact__c From Project_Role__c 
                                         Where Contact__c IN: contactIdByAlternateEmail.keySet() 
                                         AND Status__c ='Active' 
                                         AND ( Asset__r.Status IN ('Active','Purchased') OR Asset__c = null )]){
                                             if(contactIdByAlternateEmail.containsKey(projectRole.Contact__c)){
                                                 if(projectRole.Alternate_Email__c != contactIdByAlternateEmail.get(projectRole.Contact__c)){
                                                     projectRole.Alternate_Email__c = contactIdByAlternateEmail.get(projectRole.Contact__c);
                                                     lstProjectRoles.add(projectRole);
                                                 }
                                             }
                                         }
        if(!lstProjectRoles.isEmpty()){
            system.debug('Project Roles Lits==>'+lstProjectRoles);
            update lstProjectRoles;
        }
    }
    
    public static void updateAccountContact(List<Contact> contactList, Map<Id, Contact> oldContactMap){
        Set<String> setOfDomains = new Set<String>();
        Map<String, Id> accountIdByDomain = new Map<string, Id>();
        List<Contact> contacts = new List<Contact>();
        for (Contact contact : contactList){
            system.debug('contact '+contact);
            if (String.isNotBlank(contact.Cvent_Company_URL__c) && contact.Cvent_Company_URL__c != oldContactMap.get(contact.Id).Cvent_Company_URL__c && contact.Cvent_Company_URL__c != '.'){
                System.debug('contact.Cvent_Company_Domain__c' + contact.Cvent_Company_Domain__c+'---'+contact.Cvent_Company_URL__c);
                setOfDomains.add('%' + contact.Cvent_Company_Domain__c + '%');
                contacts.add(contact);
            }
        }
        System.debug('#--setOfDomains--#' + setOfDomains.size());
        if (setOfDomains.size() > 0){
            accountIdByDomain = getAccountByDomain(setOfDomains);
            if (!accountIdByDomain.IsEmpty()){
                for (Contact contact : contacts){
                    if (String.isNotBlank(contact.Cvent_Company_Domain__c) && accountIdByDomain.containsKey(contact.Cvent_Company_Domain__c.toLowercase()) && contact.AccountId != accountIdByDomain.get(contact.Cvent_Company_Domain__c.toLowercase())){
                        contact.AccountId = accountIdByDomain.get(contact.Cvent_Company_Domain__c.toLowercase());
						accountChangeContactIdSet.add(contact.Id);

                    }
                }
            }
        }
    }

    //This is used to create a Alternate email related Contacts
    public static void createOrUpdateAlternateEmail(Map<Id, Contact> oldlContactMap, Map<Id, Contact> newContactMap){

        Set<String> emailIDString = new Set<String>();
        Set<String> additionalEmailString = new Set<String>();
        list<Contact> listofContactwithEmails = new list<Contact>();
        List<Contact> listofContactwithAdditionalEmail = new list<Contact>();
        for (Contact cont : newContactMap.values()){
            if ((cont.email != null && (oldlContactMap == null || (oldlContactMap != null && oldlContactMap.get(cont.id).email != cont.email)))){
                listofContactwithEmails.add(cont);
                emailIDString.add(cont.email);
                //emailIDString.add(cont.Additional_Email__c);

            }

            if ((oldlContactMap != null && cont.email != cont.Additional_Email__c && oldlContactMap.get(cont.id).Additional_Email__c != cont.Additional_Email__c)){

                listofContactwithAdditionalEmail.add(cont);
                additionalEmailString.add(cont.Additional_Email__c);
            }
        }

        //Call ContactTriggerHandler action of Alternate Email.
        if (!listofContactwithEmails.isEmpty()){
            action.insertAleternateEmail(listofContactwithEmails, emailIDString);
        }

        System.debug('#######listofContactwithAdditionalEmail' + listofContactwithAdditionalEmail);
        if (!listofContactwithAdditionalEmail.isEmpty()){
            action.contactWithAdditionalEmail(listofContactwithAdditionalEmail, additionalEmailString);
        }
    }

    //For "Validation Error of Aleternate Email - Alternate Email Address Already Exists"
    public static void checkValidationOfEmail(Map<Id, Contact> oldContactMap, List<Contact> newContactList){
        Set<String> emailIDs = new Set<String>();
        List<Contact> contacts = new List<Contact>();
        for (Contact contact : newContactList){
            if (contact.email != null && (oldContactMap == null || (oldContactMap != null && oldContactMap.get(contact.id).email != contact.email))){
                if (!emailIDs.contains(contact.Email)){
                    emailIDs.add(contact.Email);
                    contacts.add(contact);
                } else{
                    contact.addError('Duplicate record found');
                }
            }
        }
        if (emailIDs.size() > 0){
            action.addvalidationError(emailIDs, contacts);
        }
    }

    //For Bypassing Duplicate rule
    public static List<Contact> checkConvertFromLeadContact(List<contact> contactList){
        List<Contact> contactDuplicateRuleList = new List<Contact>();
        for (Contact cont : contactList){
            if (!cont.Marked_as_Lead_Converted__c){
                contactDuplicateRuleList.add(cont);
                break;
            }
        }
        return contactDuplicateRuleList;
    }

    //Update Account recordtype to Person Account record type.
   /* @future
    public static void convertToPersonAccount(Set<Id> AccountIds){
        List<Account> accountList = [SELECT Id
                                     FROM Account
                                     WHERE Id IN :AccountIds];

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        for (Account acc : accountList){
            acc.RecordTypeId = devRecordTypeId;
        }
        update accountList;
    }*/

    public static void updateSocialId(List<Contact> triggerNew, Map<Id, Contact> oldContactMap){
        for (Contact contact : triggerNew){
            if (contact.GitHub_ID__c != null && (oldContactMap == null || (oldContactMap != null && oldContactMap.get(contact.id).GitHub_ID__c != contact.GitHub_ID__c))){
                String githubId = contact.GitHub_ID__c;
                if (!githubId.contains('github.com')){
                    contact.GitHub_ID__c = 'https://github.com/' + githubId;
                }
            }

            if (contact.LinkedIn_ID__c != null && (oldContactMap == null || (oldContactMap != null && oldContactMap.get(contact.id).LinkedIn_ID__c != contact.LinkedIn_ID__c))){
                String linkedInId = contact.LinkedIn_ID__c;
                if (!LinkedInId.contains('linkedin.com/in')){
                    contact.LinkedIn_ID__c = 'https://www.linkedin.com/in/' + LinkedInId;
                }
            }

            if (contact.Twitter_ID__c != null && (oldContactMap == null || (oldContactMap != null && oldContactMap.get(contact.id).Twitter_ID__c != contact.Twitter_ID__c))){
                String twitterId = contact.Twitter_ID__c;
                if (!twitterId.contains('twitter.com')){
                    contact.Twitter_ID__c = 'https://twitter.com/' + twitterId;
                }
            }
        }
    }

    /*public static void checkForOptOutChange(Map<Id, Contact> oldMap, Map<Id, Contact> newMap){
     Map<Id, Boolean> idVsSubscribe = new Map<Id, Boolean>();

     for(Contact con : newMap.values()){
     if (con.HasOptedOutOfEmail != oldMap.get(con.Id).HasOptedOutOfEmail) {
     idVsSubscribe.put(con.Id, !con.HasOptedOutOfEmail);
     }
     }

     if (!idVsSubscribe.isEmpty()) {
     CampaignMemberSubscriptions.updateCampaignMemberSubscriptionStatus('Contact', idVsSubscribe);
     }
     }

     private static void updateLeadSource(Map<Id, Contact> oldMap, Map<Id, Contact> newMap){
     for(Contact contact:newMap.values()){
     if(contact.LeadSource != null && contact.Lead_Source_Integration__c == null && contact.LeadSource != oldMap.get(contact.Id).LeadSource){
     contact.Lead_Source_Detail__c = contact.LeadSource;
     contact.LeadSource = 'Join Us Form';
     contact.Lead_Source_Detail1__c = 'other';
     }
     }
     }*/
    public static void updateContactOfTIUser(List<Contact> newMap){
        if (UserInfo.getName() != null && UserInfo.getName() == 'TI User'){
            for (Contact con : newMap){
                con.LeadSource = 'Training';
                con.Lead_Source_Detail1__c = 'TI Portal';
            }
        }
    }

    //Check if Mixmax_Campaign_Name__c changed or added if new Lead
    //And set Create_MixMax_Campaign__c checkbox to true
    private static void updateCreateMixMaxCampaignCheckbox(Map<Id, Contact> oldMap, List<Contact> contactList){

        for (contact con : contactList){
            if ((oldMap == null && con.Mixmax_Campaign_Name__c != NULL) || (oldMap != null && con.Mixmax_Campaign_Name__c != oldMap.get(con.Id).Mixmax_Campaign_Name__c)){
                con.MixMax_Create_Campaign__c = true;
            }
        }
    }

    public static void updateStatusOnCampaignMember(Map<Id, Contact> oldlMap, Map<Id, Contact> newMap){
        if (RecursiveTriggerHandler.isFirstTime){
            RecursiveTriggerHandler.isFirstTime = false;
            set<Id> contactIds = new set<Id>();
            map<Id, CampaignMember> mapCampaignMember = new map<Id, CampaignMember>();
            for (Contact objConatct : newMap.values()){
                if (oldlMap.get(objConatct.id).HasOptedOutOfEmail != objConatct.HasOptedOutOfEmail && objConatct.HasOptedOutOfEmail == true)
                    contactIds.add(objConatct.id);
            }
            if (!contactIds.isEmpty()){
                for (CampaignMember objCampaignMember : [SELECT Status
                                                         FROM CampaignMember
                                                         WHERE ContactID IN :contactIds AND Status != 'Unsubscribed' AND Campaign.type = 'Subscription Center' AND Campaign.IsActive = True AND Campaign.Add_to_Subscription_Center__c = True
                                                         FOR  UPDATE ]){
                    objCampaignMember.Status = 'Unsubscribed';
                    mapCampaignMember.put(objCampaignMember.Id, objCampaignMember);
                }
            }
            if (!mapCampaignMember.isEmpty()){
                update mapCampaignMember.Values();
            }
        }
    }
    
    public static void updateHubspotOptOut(Map<Id, Contact> oldlMap, Map<Id, Contact> newMap){
    
        Set<String> hubspotUnsubscribeList = new Set<String>();
        for(Contact c : newMap.values()){
        
            if(c.Email != null && c.HasOptedOutOfEmail && c.Hubspot__c 
                   && (oldlMap == null || (oldlMap != null && oldlMap.get(c.id).HasOptedOutOfEmail != c.HasOptedOutOfEmail)) ){
                hubspotUnsubscribeList.add(c.Email);
            }
        }
        
        if(!hubspotUnsubscribeList.isEmpty() && !(system.isBatch() || system.isFuture() || system.isQueueable())){
          Hubspot_Utility.unsubscribeFromHubspot(hubspotUnsubscribeList);
      }  
    }

    public static void sendEmailToOppOwnerOnAccountChange(){
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        List<Project_Role__c> projectRoleList = [SELECT Name, Contact__c, Contact__r.firstname,
                                                 Contact__r.lastname, Opportunity__r.Owner.Email, Opportunity__r.Owner.name
                                                 FROM Project_Role__c
                                                 WHERE Opportunity__c != null AND Contact__c IN: accountChangeContactIdSet AND 
                                                 Status__c = 'Active' AND Opportunity__r.IsClosed = false];
        System.debug('#--projectRoleList--#' + projectRoleList.size());
        if(!projectRoleList.isEmpty()){
            Map<String, List<Contact>> ownerInfoVsContactList = new Map<String, List<Contact>>();
            for (Project_Role__c pr : projectRoleList){
                String key = pr.Opportunity__r.Owner.Email + ';' + pr.Opportunity__r.Owner.name;
                if (!ownerInfoVsContactList.containskey(key)){
                    ownerInfoVsContactList.put(key, new List<Contact>());
                }
                ownerInfoVsContactList.get(key).add(new Contact(Id = pr.Contact__c, FirstName = pr.Contact__r.firstname, lastname = pr.Contact__r.lastname));
            }
            
            Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
            System.debug('#--ownerInfoVsContactList--#' + ownerInfoVsContactList.size());
            for (String key : ownerInfoVsContactList.keyset()){
                Set<Id> contactIdSet = new Set<Id>();
                List<String> oppIdAndName = key.Split(';');
                
                String emailBody = 'Hi ' + oppIdAndName[1]+',';
                emailBody += '<p>Account is updated on the following contact(s) :<br/> ';
                Integer count = 1;
                                
                for (Contact contact : ownerInfoVsContactList.get(key)){
                    if(!contactIdSet.contains(contact.Id)){
                    emailBody += count + '. <a href="' + URL.getSalesforceBaseUrl().toExternalForm()+'/' + contact.Id + '"> ' + contact.FirstName + ' ' + contact.LastName + '</a> <br/>';
                    count++;
                    contactIdSet.add(contact.Id);
                    }
                }
                emailBody += ' <br/><br/>Thank You, <br/><br/>The Linux Foundation';
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(orgWideEmailAddress);
                email.setHtmlBody(emailBody);
                email.setSubject('Account is Updated on contact');
                email.setToAddresses(new List<String>{oppIdAndName[0]});
                email.setSaveAsActivity(false);
                sendEmailList.add(email);
            }
            
            if(!sendEmailList.isEmpty()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailList);
            }
        }
    }
}