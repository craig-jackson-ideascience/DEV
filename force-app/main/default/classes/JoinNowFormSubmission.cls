/********************************************************
 * Created by: CloudRoute @ CloudRoute Solutions
 * Created Date: 11/10/19.
 * Description: JoinNowFormSubmission
 ********************************************************/
/*
 LastModified By             ModifiedDate            Methods                                                 Against
 ========================================================================================================================
 Kalyani Chiluveri           18-May-2020             EmailMessaging & PoContact                              SFDC - 1284
 Kalyani Chiluveri           22-May-2020             updateAccountDetails - Added Billing Country            SFDC - 1373
 */
@RestResource(urlMapping = '/JoinNowForm/*')
global class JoinNowFormSubmission{
    global static Map<String, ContactRolesWrapper> contactRolesWrapMap = new Map<String, ContactRolesWrapper>();
    global static Map<String, ContactRolesWrapper> contactRolesLFWrapMap = new Map<String, ContactRolesWrapper>();
    global static Map<String, ContactDetails> emailVsContactDetails = new Map<String, ContactDetails>();
    global static Map<String, ContactDetails> contactIdVsContactDetails = new Map<String, ContactDetails>();
    global static Map<String, String> roleVsEmail = new Map<String, String>();
    global static Map<String, String> emailVsContactId = new Map<String, String>();
    global static Map<Id, List<String>> ContactIdVsRole = new Map<Id, List<String>>();
    global static Map<String, String> roleVsSFrole = new Map<String, String>();
    global static Id accId;
    global static Boolean informOppOwnerForWebsite = False;
    global static Boolean brandNewAccount = False;
    global static Boolean isEmployeeSizeUpdated = False;
    global static String mergeWebsite;
    global static String beforeUpdate;
    global static String afterUpdate;
    global static Account_And_Project__c beforeUpsertAccountAndProject = NULL;
    global static Account_And_Project__c afterUpsertAccountAndProject = NULL;
    @HttpPost
    global static String processForm(){

        String errorMessage;
        Opportunity opp = new Opportunity();
        Map<String, Id> productCurrencyVsPBSId = new Map<String, Id>();
        Project__c prj;

        JoinNowRequestWrapper fd;

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        Blob requestBodyBlob = request.requestBody;
        String requestBody = requestBodyBlob.toString();
        System.debug('requestBody: ' + requestBody);

        string apiId;
        apiId = APIRequestLog.createApiRequestLog(requestBody, 'Join Now Form');
        System.debug('apiId: ' + apiId);

        try{

            fd = (JoinNowRequestWrapper) JSON.deserialize(requestBody, JoinNowRequestWrapper.class);
            System.debug('fd: ' + fd);

            Boolean validIds = True;
            Map<String, List<String>> objectVsIds = getObjectVsIds(fd);

            if (objectVsIds.containsKey('Account')){
                validIds = JoinNowUtility.checkIdValidity(objectVsIds.get('Account'), Account.Class);
                if (!validIds){
                    errorMessage = 'Invalid Account Id: ' + fd.AccountId;
                }
            }

            if (validIds && objectVsIds.containsKey('Project__c')){
                validIds = JoinNowUtility.checkIdValidity(objectVsIds.get('Project__c'), Project__c.Class);
                if (!validIds){
                    errorMessage = 'One or more of the Project Ids are not valid: ' + objectVsIds.get('Project__c');
                }
            }

            if (validIds && objectVsIds.containsKey('Product_Details__c')){
                validIds = JoinNowUtility.checkIdValidity(objectVsIds.get('Product_Details__c'), Product_Details__c.Class);
                if (!validIds){
                    errorMessage = 'One or more of the Product Detail Ids are not valid: ' + objectVsIds.get('Product_Details__c');
                }
            }

            if (validIds && objectVsIds.containsKey('Contact')){
                validIds = JoinNowUtility.checkIdValidity(objectVsIds.get('Contact'), Contact.Class);
                if (!validIds){
                    errorMessage = 'One or more of the Contact Ids are not valid: ' + objectVsIds.get('Contact');
                }
            }


            if (validIds){

                Id poContId;

                Map<Id, Product_Details__c> productDetailsMap = new Map<Id, Product_Details__c>();

                Project__c[] projects = [Select Id, Name, Website__c, External_Submission_Notification__c, Internal_New_Opportuntiy_Notification__c
                                         From Project__c
                                         Where Id = :fd.pm_project];
                if (projects.isEmpty()){
                    prj = new Project__c();
                    errorMessage = 'Id value ' + fd.pm_project + ' for pm_project is not valid. No record found. ';
                } else{
                    prj = projects[0];
                }
                System.debug(prj + '====> prj');

                //Start checking form contacts one by one and add contacts with unique email Id in to map
                //Add email for each role

                List<ContactDetails> allContactDetails = new List<ContactDetails>();


                //Project Membership Contacts
                allContactDetails.add(new ContactDetails(fd.pm_primary_con_fname, fd.pm_primary_con_lname, fd.pm_primary_con_title, String.isNotBlank(fd.pm_primary_con_emailParam) ? fd.pm_primary_con_emailParam.trim() : fd.pm_primary_con_emailParam, fd.pm_primary_con_phone, fd.pm_primary_con_twitter, fd.pm_primary_con_github, fd.pm_primary_con_linkedIn, fd.pm_primary_con_subscribed, fd.pm_primary_con_id, 'pm_primary_con'));

                allContactDetails.add(new ContactDetails(fd.pm_billing_con_fname, fd.pm_billing_con_lname, fd.pm_billing_con_title, String.isNotBlank(fd.pm_billing_con_emailParam) ? fd.pm_billing_con_emailParam.trim() : fd.pm_billing_con_emailParam, fd.pm_billing_con_phone, fd.pm_billing_con_twitter, fd.pm_billing_con_github, fd.pm_billing_con_linkedIn, fd.pm_billing_con_subscribed, fd.pm_billing_con_id, 'pm_billing_con'));

                allContactDetails.add(new ContactDetails(fd.pm_authSig_fname, fd.pm_authSig_lname, fd.pm_authSig_title, String.isNotBlank(fd.pm_authSig_emailParam) ? fd.pm_authSig_emailParam.trim() : fd.pm_authSig_emailParam, fd.pm_authSig_phone, fd.pm_authSig_twitter, fd.pm_authSig_github, fd.pm_authSig_linkedIn, fd.pm_authSig_subscribed, fd.pm_authSig_id, 'pm_authSig'));

                allContactDetails.add(new ContactDetails(fd.pm_inv_con_fname, fd.pm_inv_con_lname, fd.pm_inv_con_title, String.isNotBlank(fd.pm_inv_con_emailParam) ? fd.pm_inv_con_emailParam.trim() : fd.pm_inv_con_emailParam, fd.pm_inv_con_phone, fd.pm_inv_con_twitter, fd.pm_inv_con_github, fd.pm_inv_con_linkedIn, fd.pm_inv_con_subscribed, fd.pm_inv_con_id, 'pm_inv_con'));

                allContactDetails.add(new ContactDetails(fd.pm_tech_con_1_fname, fd.pm_tech_con_1_lname, fd.pm_tech_con_1_title, String.isNotBlank(fd.pm_tech_con_1_emailParam) ? fd.pm_tech_con_1_emailParam.trim() : fd.pm_tech_con_1_emailParam, fd.pm_tech_con_1_phone, fd.pm_tech_con_1_twitter, fd.pm_tech_con_1_github, fd.pm_tech_con_1_linkedIn, fd.pm_tech_con_1_subscribed, fd.pm_tech_con_1_id, 'pm_tech_con_1'));

                allContactDetails.add(new ContactDetails(fd.pm_tech_con_2_fname, fd.pm_tech_con_2_lname, fd.pm_tech_con_2_title, String.isNotBlank(fd.pm_tech_con_2_emailParam) ? fd.pm_tech_con_2_emailParam.trim() : fd.pm_tech_con_2_emailParam, fd.pm_tech_con_2_phone, fd.pm_tech_con_2_twitter, fd.pm_tech_con_2_github, fd.pm_tech_con_2_linkedIn, fd.pm_tech_con_2_subscribed, fd.pm_tech_con_2_id, 'pm_tech_con_2'));

                allContactDetails.add(new ContactDetails(fd.pm_tech_con_3_fname, fd.pm_tech_con_3_lname, fd.pm_tech_con_3_title, String.isNotBlank(fd.pm_tech_con_3_emailParam) ? fd.pm_tech_con_3_emailParam.trim() : fd.pm_tech_con_3_emailParam, fd.pm_tech_con_3_phone, fd.pm_tech_con_3_twitter, fd.pm_tech_con_3_github, fd.pm_tech_con_3_linkedIn, fd.pm_tech_con_3_subscribed, fd.pm_tech_con_3_id, 'pm_tech_con_3'));

                allContactDetails.add(new ContactDetails(fd.pm_mkt_con_1_fname, fd.pm_mkt_con_1_lname, fd.pm_mkt_con_1_title, String.isNotBlank(fd.pm_mkt_con_1_emailParam) ? fd.pm_mkt_con_1_emailParam.trim() : fd.pm_mkt_con_1_emailParam, fd.pm_mkt_con_1_phone, fd.pm_mkt_con_1_twitter, fd.pm_mkt_con_1_github, fd.pm_mkt_con_1_linkedIn, fd.pm_mkt_con_1_subscribed, fd.pm_mkt_con_1_id, 'pm_mkt_con_1'));

                allContactDetails.add(new ContactDetails(fd.pm_mkt_con_2_fname, fd.pm_mkt_con_2_lname, fd.pm_mkt_con_2_title, String.isNotBlank(fd.pm_mkt_con_2_emailParam) ? fd.pm_mkt_con_2_emailParam.trim() : fd.pm_mkt_con_2_emailParam, fd.pm_mkt_con_2_phone, fd.pm_mkt_con_2_twitter, fd.pm_mkt_con_2_github, fd.pm_mkt_con_2_linkedIn, fd.pm_mkt_con_2_subscribed, fd.pm_mkt_con_2_id, 'pm_mkt_con_2'));

                allContactDetails.add(new ContactDetails(fd.pm_pr_con_fname, fd.pm_pr_con_lname, fd.pm_pr_con_title, String.isNotBlank(fd.pm_pr_con_emailParam) ? fd.pm_pr_con_emailParam.trim() : fd.pm_pr_con_emailParam, fd.pm_pr_con_phone, fd.pm_pr_con_twitter, fd.pm_pr_con_github, fd.pm_pr_con_linkedIn, fd.pm_pr_con_subscribed, fd.pm_pr_con_id, 'pm_pr_con'));

                allContactDetails.add(new ContactDetails(fd.pm_legal_con_fname, fd.pm_legal_con_lname, fd.pm_legal_con_title, String.isNotBlank(fd.pm_legal_con_emailParam) ? fd.pm_legal_con_emailParam.trim() : fd.pm_legal_con_emailParam, fd.pm_legal_con_phone, fd.pm_legal_con_twitter, fd.pm_legal_con_github, fd.pm_legal_con_linkedIn, fd.pm_legal_con_subscribed, fd.pm_legal_con_id, 'pm_legal_con'));

                allContactDetails.add(new ContactDetails(fd.eventSponsor_con_fname, fd.eventSponsor_con_lname, fd.eventSponsor_con_title, String.isNotBlank(fd.eventSponsor_con_emailParam) ? fd.eventSponsor_con_emailParam.trim() : fd.eventSponsor_con_emailParam, fd.eventSponsor_con_phone, fd.eventSponsor_con_twitter, fd.eventSponsor_con_github, fd.eventSponsor_con_linkedIn, False, fd.eventSponsor_con_id, 'eventSponsor_con'));

                // Added by @harshadk PO Contact First Name logic as per SOPS-555
                if (fd.po_con_name != null && fd.po_con_emailParam != null && fd.po_con_name != '' && fd.po_con_emailParam != ''){
                    List<String> nameList = fd.po_con_name.split(' ');
                    if (nameList.size() > 3){
                        allContactDetails.add(new ContactDetails('[[unknown]]', fd.po_con_name, null, fd.po_con_emailParam.trim(), null, null, null, null, False, null, 'po_con'));
                    } else if (nameList.size() == 3){
                        allContactDetails.add(new ContactDetails(nameList[0] + ' ' + nameList[1], nameList[2], null, fd.po_con_emailParam.trim(), null, null, null, null, False, null, 'po_con'));
                    } else if (nameList.size() == 2){
                        allContactDetails.add(new ContactDetails(nameList[0], nameList[1], null, fd.po_con_emailParam.trim(), null, null, null, null, False, null, 'po_con'));
                    } else if (nameList.size() == 1){
                        allContactDetails.add(new ContactDetails('[[unknown]]', nameList[0], null, fd.po_con_emailParam.trim(), null, null, null, null, False, null, 'po_con'));
                    }
                }

                //Linux Membership Contacts
                allContactDetails.add(new ContactDetails(fd.lm_primary_con_fname, fd.lm_primary_con_lname, fd.lm_primary_con_title, String.isNotBlank(fd.lm_primary_con_emailParam) ? fd.lm_primary_con_emailParam.trim() : fd.lm_primary_con_emailParam, fd.lm_primary_con_phone, fd.lm_primary_con_twitter, fd.lm_primary_con_github, fd.lm_primary_con_linkedIn, fd.lm_primary_con_subscribed, fd.lm_primary_con_id, 'lm_primary_con'));

                allContactDetails.add(new ContactDetails(fd.lm_billing_con_fname, fd.lm_billing_con_lname, fd.lm_billing_con_title, String.isNotBlank(fd.lm_billing_con_emailParam) ? fd.lm_billing_con_emailParam.trim() : fd.lm_billing_con_emailParam, fd.lm_billing_con_phone, fd.lm_billing_con_twitter, fd.lm_billing_con_github, fd.lm_billing_con_linkedIn, fd.lm_billing_con_subscribed, fd.lm_billing_con_id, 'lm_billing_con'));

                allContactDetails.add(new ContactDetails(fd.lm_authSig_fname, fd.lm_authSig_lname, fd.lm_authSig_title, String.isNotBlank(fd.lm_authSig_emailParam) ? fd.lm_authSig_emailParam.trim() : fd.lm_authSig_emailParam, fd.lm_authSig_phone, fd.lm_authSig_twitter, fd.lm_authSig_github, fd.lm_authSig_linkedIn, fd.lm_authSig_subscribed, fd.lm_authSig_id, 'lm_authSig'));

                allContactDetails.add(new ContactDetails(fd.lm_inv_con_fname, fd.lm_inv_con_lname, fd.lm_inv_con_title, String.isNotBlank(fd.lm_inv_con_emailParam) ? fd.lm_inv_con_emailParam.trim() : fd.lm_inv_con_emailParam, fd.lm_inv_con_phone, fd.lm_inv_con_twitter, fd.lm_inv_con_github, fd.lm_inv_con_linkedIn, fd.lm_inv_con_subscribed, fd.lm_inv_con_id, 'lm_inv_con'));

                allContactDetails.add(new ContactDetails(fd.lm_tech_con_1_fname, fd.lm_tech_con_1_lname, fd.lm_tech_con_1_title, String.isNotBlank(fd.lm_tech_con_1_emailParam) ? fd.lm_tech_con_1_emailParam.trim() : fd.lm_tech_con_1_emailParam, fd.lm_tech_con_1_phone, fd.lm_tech_con_1_twitter, fd.lm_tech_con_1_github, fd.lm_tech_con_1_linkedIn, fd.lm_tech_con_1_subscribed, fd.lm_tech_con_1_id, 'lm_tech_con_1'));

                allContactDetails.add(new ContactDetails(fd.lm_tech_con_2_fname, fd.lm_tech_con_2_lname, fd.lm_tech_con_2_title, String.isNotBlank(fd.lm_tech_con_2_emailParam) ? fd.lm_tech_con_2_emailParam.trim() : fd.lm_tech_con_2_emailParam, fd.lm_tech_con_2_phone, fd.lm_tech_con_2_twitter, fd.lm_tech_con_2_github, fd.lm_tech_con_2_linkedIn, fd.lm_tech_con_2_subscribed, fd.lm_tech_con_2_id, 'lm_tech_con_2'));

                allContactDetails.add(new ContactDetails(fd.lm_tech_con_3_fname, fd.lm_tech_con_3_lname, fd.lm_tech_con_3_title, String.isNotBlank(fd.lm_tech_con_3_emailParam) ? fd.lm_tech_con_3_emailParam.trim() : fd.lm_tech_con_3_emailParam, fd.lm_tech_con_3_phone, fd.lm_tech_con_3_twitter, fd.lm_tech_con_3_github, fd.lm_tech_con_3_linkedIn, fd.lm_tech_con_3_subscribed, fd.lm_tech_con_3_id, 'lm_tech_con_3'));

                allContactDetails.add(new ContactDetails(fd.lm_mkt_con_1_fname, fd.lm_mkt_con_1_lname, fd.lm_mkt_con_1_title, String.isNotBlank(fd.lm_mkt_con_1_emailParam) ? fd.lm_mkt_con_1_emailParam.trim() : fd.lm_mkt_con_1_emailParam, fd.lm_mkt_con_1_phone, fd.lm_mkt_con_1_twitter, fd.lm_mkt_con_1_github, fd.lm_mkt_con_1_linkedIn, fd.lm_mkt_con_1_subscribed, fd.lm_mkt_con_1_id, 'lm_mkt_con_1'));

                allContactDetails.add(new ContactDetails(fd.lm_mkt_con_2_fname, fd.lm_mkt_con_2_lname, fd.lm_mkt_con_2_title, String.isNotBlank(fd.lm_mkt_con_2_emailParam) ? fd.lm_mkt_con_2_emailParam.trim() : fd.lm_mkt_con_2_emailParam, fd.lm_mkt_con_2_phone, fd.lm_mkt_con_2_twitter, fd.lm_mkt_con_2_github, fd.lm_mkt_con_2_linkedIn, fd.lm_mkt_con_2_subscribed, fd.lm_mkt_con_2_id, 'lm_mkt_con_2'));

                allContactDetails.add(new ContactDetails(fd.lm_pr_con_fname, fd.lm_pr_con_lname, fd.lm_pr_con_title, String.isNotBlank(fd.lm_pr_con_emailParam) ? fd.lm_pr_con_emailParam.trim() : fd.lm_pr_con_emailParam, fd.lm_pr_con_phone, fd.lm_pr_con_twitter, fd.lm_pr_con_github, fd.lm_pr_con_linkedIn, fd.lm_pr_con_subscribed, fd.lm_pr_con_id, 'lm_pr_con'));

                allContactDetails.add(new ContactDetails(fd.lm_legal_con_fname, fd.lm_legal_con_lname, fd.lm_legal_con_title, String.isNotBlank(fd.lm_legal_con_emailParam) ? fd.lm_legal_con_emailParam.trim() : fd.lm_legal_con_emailParam, fd.lm_legal_con_phone, fd.lm_legal_con_twitter, fd.lm_legal_con_github, fd.lm_legal_con_linkedIn, fd.lm_legal_con_subscribed, fd.lm_legal_con_id, 'lm_legal_con'));

                //Added by Priyesh @CloudRoute to process the committeeData

                if (fd.committeeData != null && !fd.committeeData.isEmpty()){
                    System.debug(fd.committeeData);
                    System.debug('committeeData==>' + fd.committeeData);
                    for (JoinNowRequestWrapper.cls_committeeData cmData : fd.committeeData){
                        System.debug('commiteeData type==>' + cmData.committeeType);
                        if (cmData.committeeType != null && !cmData.committeeType.isEmpty()){
                            for (String cmtType : cmData.committeeType){
                                String contactId = cmData.ContactID != null && cmData.ContactID != '' ? cmData.ContactID : '';
                                String type = cmtType.contains('Technical Project') ? 'cmt_' + cmtType.substring(cmtType.indexOf('Technical Project'), cmtType.length()) : 'cmt_' + cmtType;
                                allContactDetails.add(new ContactDetails(cmData.FirstName, cmData.LastName, cmData.Title, String.isNotBlank(cmData.Email) ? cmData.Email.trim() : cmData.Email, '', '', '', '', false, contactId, type));
                            }
                        }
                    }
                }

                for (ContactDetails cd : allContactDetails){
                    System.debug('cd: ' + cd);
                }

                processContactDetails(allContactDetails);

                findOrCreateAccountAndContacts(fd.accountId, fd.company, fd.address, fd.city, fd.state, fd.country, fd.zip, fd.employeeSize, fd.logo_url, fd.website);


                if (fd.po_con_name != null && fd.po_con_emailParam != null && fd.po_con_name != '' && fd.po_con_emailParam != ''){
                    // SFDC-1284 - Bulkifiying LeadConversion
                    poContId = emailVsContactId.get(roleVsEmail.get('po_con'));
                    if (!contactRolesWrapMap.containsKey(roleVsEmail.get('po_con'))){
                        populateContactRolesMap(poContId, 'PO Contact', false);
                    }
                    if (!contactRolesLFWrapMap.containsKey(roleVsEmail.get('po_con'))){
                        populateLFContactRolesMap(poContId, 'PO Contact', false);
                    }
                }

                System.debug('emailVsContactId: ' + emailVsContactId);


                Account[] acc = [SELECT Id, Name, LF_Membership_Status__c
                                 FROM Account
                                 WHERE Id = :accId];

                List<Asset> assetRecs = [Select Id, AccountId, Product2.Name, Projects__r.Name
                                         from Asset
                                         WHERE (Status = 'Purchased' OR Status = 'Active') AND AccountID = :accId AND Projects__c = :fd.lm_project AND RecordType.Name = 'Corporate'];
                productDetailsMap = new Map<Id, Product_Details__c>([SELECT Id, Project__c, Project__r.Name, Project__r.OwnerId, Project__r.Opportunity_Owner__c, Products__c, Products__r.Name, Price__c,
                                                                     CurrencyIsoCode FROM Product_Details__c
                                                                     WHERE Id = :fd.lm_product OR Id = :fd.pm_product]);
                System.debug('productDetailsMap: ' + productDetailsMap);

                if (acc.size() > 0){

                    System.debug('All roles and its email one by one: ');
                    for (String role : roleVsEmail.keySet()){
                        System.debug('role: ' + role);
                        System.debug('email: ' + roleVsEmail.get(role));
                    }

                    System.debug('All email and its contact one by one: ');
                    for (String email : emailVsContactId.keySet()){
                        System.debug('email: ' + email);
                        System.debug('contact ID: ' + emailVsContactId.get(email));
                    }

                    /*Added On 28th Oct 2020 By Priyesh @CloudRoute to truncate the Opportunity Name based on field limit*/
                    String OppName = '';
                    String accName = acc[0].Name;
                    String projectName = '';
                    String membershipLevel = '';
                    String dateStr = String.valueOf(Date.Today().Year());
                    Id OppOwner;
                    List<OpportunityLineItem> openOppLine = new List<OpportunityLineItem>();
                    Date startDate = Date.today().day() < 15 ? Date.today().tostartofmonth() : Date.today().addmonths(1).tostartofmonth();

                    if (productDetailsMap.containsKey(fd.pm_product)){
                        Product_Details__c pd = productDetailsMap.get(fd.pm_product);
                        if (pd.Project__c != null && pd.Project__r.Name != null && pd.Project__r.Name != ''){
                            OppName = acc[0].Name + ' - ' + pd.Project__r.Name;
                            projectName = pd.Project__r.Name;
                            OppOwner = pd.Project__r.Opportunity_Owner__c != null ? pd.Project__r.Opportunity_Owner__c : pd.Project__r.OwnerId;
                        }

                        if (pd.Products__r.Name != NULL && +pd.Products__r.Name != ''){
                            membershipLevel = pd.Products__r.Name;
                            OppName += ' - ' + membershipLevel + ' - ' + dateStr; //startDate.year();
                        }

                        OppName = OppName.trim();
                        /*openOppLine = [
                         Select Id, OpportunityId, Opportunity.Name, Opportunity.OwnerId,Opportunity.AccountId, Opportunity.Owner.Email,opportunity.Preferred_Invoice_Method__c, Opportunity.CreatedByID, Product2Id, NetSuite_Invoice_Memo__c,Projects__c,Product_Details__c,
                         Display_Logo_On_Website__c, No_Press_Release_Announcement__c, Send_Invoice_Copy_to_Primary_Contact__c, Start_Date__c, End_Date__c, Quantity, UnitPrice, Membership_Tier__c,Opportunity.Employee_Count_Needs_Verified__c
                         From OpportunityLineItem
                         WHERE Opportunity.AccountId = :accId AND Opportunity.IsClosed = FALSE AND Opportunity.Type != 'Renewal'
                         AND Projects__c = :pd.Project__c
                         LIMIT 1
                         ];*/

                        List<Opportunity> newOpp = [Select ID, Name, OwnerID, AccountId, Owner.Email, Preferred_Invoice_Method__c, CreatedByID, (Select Id, OpportunityId, Opportunity.Name, Opportunity.OwnerId, Opportunity.AccountId, Opportunity.Owner.Email, opportunity.Preferred_Invoice_Method__c, Opportunity.CreatedByID, Product2Id, NetSuite_Invoice_Memo__c, Projects__c, Product_Details__c, Display_Logo_On_Website__c, No_Press_Release_Announcement__c, Send_Invoice_Copy_to_Primary_Contact__c, Start_Date__c, End_Date__c, Quantity, UnitPrice, Membership_Tier__c, Opportunity.Employee_Count_Needs_Verified__c
                                                                                                                                                 From OpportunityLineItems)
                                                    From Opportunity 
                                                    WHERE AccountId = :accId AND IsClosed = FALSE AND Type != 'Renewal' AND Individual__c = FALSE];
                        Boolean foundlF = FALSE;

                        for (Opportunity oppRec : newOpp){
                            if (fd.pm_project == label.The_Linux_Foundation_Project){
                                if (oppRec.OpportunityLineItems.size() == 1 && oppRec.OpportunityLineItems[0].Projects__c == label.The_Linux_Foundation_Project){
                                    openOppLine = oppRec.OpportunityLineItems;
                                }
                            } else{
                                for (OpportunityLineItem oli : oppRec.OpportunityLineItems){
                                    if (fd.pm_project == oli.Projects__c && !foundlF){
                                        openOppLine = new List<OpportunityLineItem>{ oli };
                                        foundlF = TRUE;
                                    }
                                }
                            }
                        }
                    }

                    if ((String.IsNotBlank(fd.pm_product) && productDetailsMap.containsKey(fd.pm_product) && String.IsNotBlank(fd.lm_product) && productDetailsMap.containsKey(fd.lm_product) && assetRecs.isEmpty()) || (!openOppLine.isEmpty() && openOppLine[0].Opportunity.Name.contains('& LF') && productDetailsMap.get(fd.pm_product).Project__c != Label.The_Linux_Foundation_Project)){
                        OppName = accName + ' - ' + projectName + ' & LF - ' + membershipLevel + ' - ' + dateStr;
                    } else if (String.IsNotBlank(fd.pm_product) && productDetailsMap.containsKey(fd.pm_product) && (String.isBlank(fd.lm_product) || (String.IsNotBlank(fd.lm_product) && !productDetailsMap.containsKey(fd.lm_product)))){
                        if (!openOppLine.isEmpty() && openOppLine[0].Opportunity.Name.contains('& LF') && productDetailsMap.get(fd.pm_product).Project__c == Label.The_Linux_Foundation_Project){
                            OppName = openOppLine[0].Opportunity.Name;
                        } else{
                            OppName = accName + ' - ' + projectName + ' - ' + membershipLevel + ' - ' + dateStr;
                        }
                    }

                    if (OppName.length() > 120 || (String.isNotBlank(fd.mode) && fd.mode.equalsIgnoreCase('test') && OppName.length() > 110)){
                        List<String> oppNamelist = OppName.split(' - ');
                        OppName = oppNamelist[0].abbreviate(40) + ' - ' + oppNamelist[1].abbreviate(40) + ' - ' + oppNamelist[2] + ' - ' + oppNamelist[3];
                        //If OppName still greater than 120, then trim ProjectName
                        //if (OppName.length() > 120) {
                        //OppName = oppNamelist[0].substring(0,40) + ' - '+ oppNamelist[1].substring(0,40)  +' - '+ oppNamelist[2]+ ' - '+ oppNamelist[3];
                        //}
                        System.debug('OppName ****' + OppName);
                    }

                    if (String.isNotBlank(fd.mode) && fd.mode.equalsIgnoreCase('test')){
                        opp.Name = 'Test - ' + OppName;
                    } else{
                        opp.Name = OppName;
                    }

                    system.debug('zero ' + fd.projectSlug);

                    //opp.CurrencyIsoCode = fd.projectSlug == 'lfeurope' ? 'EUR' : 'USD';
					opp.CurrencyIsoCode = productDetailsMap.containsKey(fd.pm_product) ? productDetailsMap.get(fd.pm_product).CurrencyIsoCode : 'USD';

                    opp.Description = fd.pm_addInt;

                    opp.StageName = '5. Decision Commitment';
                    opp.JoinNow_Update__c = Date.today();

                    opp.Signed_MSA__c = fd.sign_msa;
                    //opp.zero_membership__c = fd.zero_membership;

                    if (String.isNotBlank(fd.pm_po_required)){
                        opp.Opportunity_PO_Required__c = fd.pm_po_required.toLowerCase() == 'yes' ? True : False;
                    }

                    Boolean insertRecord = False;
                    String billToAddressID = findOrCreateBillToAddress(fd, accId);

                    if (openOppLine.size() > 0){
                         //
                        OpportunityLineItem oppLine = openOppLine[0];
                        opp.Id = oppLine.OpportunityId;
                        opp.CloseDate = Date.today().addMonths(1);
                        opp.OwnerId = oppLine.Opportunity.OwnerId;
                        if (String.isNotBlank(fd.preferred_invoice_method)){
                            opp.Preferred_Invoice_Method__c = fd.preferred_invoice_method;
                        }
                        setBeforeContext(opp);
                        insertOcrRoles(opp);
                    } else{
                        opp.AccountId = accId;
                        opp.CloseDate = Date.today().addMonths(1);
                        opp.Pricebook2Id = Label.JoinNow_Opportunity_Pricebook;
                        opp.RecordTypeId = Label.JoinNow_Opportunity_RecordTypeId;
                        opp.Preferred_Invoice_Method__c = fd.preferred_invoice_method;
                        if (OppOwner != null){
                            opp.OwnerId = OppOwner;
                        }

                        insertRecord = TRUE;
                    }

                    if (billToAddressID != NULL){
                        opp.Bill_To_Address__c = billToAddressID;
                    }
                    Upsert opp;

                    System.debug('opp.CurrencyIsoCode ' + opp.CurrencyIsoCode);
                  
                    Set<Id> productIdSet = new Set<Id>();
                    //Add project's product
                    if (productDetailsMap.containsKey(fd.pm_product)){
                        productIdSet.add(productDetailsMap.get(fd.pm_product).Products__c);
                    }
                    //Add linux's product
                    if (productDetailsMap.containsKey(fd.lm_product)){
                        productIdSet.add(productDetailsMap.get(fd.lm_product).Products__c);
                    }
                    //Fetching Pricebookentry based on curency
                    if (!productIdSet.isEmpty()){

                        List<PricebookEntry> pricebookEntryList = [SELECT Id, Product2Id, CurrencyIsoCode
                                                                   FROM PricebookEntry
                                                                   WHERE Pricebook2Id = :Label.JoinNow_Opportunity_Pricebook AND Product2Id IN: productIdSet AND CurrencyIsoCode = :opp.CurrencyIsoCode AND IsActive = True];
                        for (PricebookEntry pbe : pricebookEntryList){
                            productCurrencyVsPBSId.put(pbe.Product2Id + '-' + pbe.CurrencyIsoCode, pbe.id);
                        }
                        System.debug('productCurrencyVsPBSId' + productCurrencyVsPBSId);
                    }
                    if (insertRecord){
                        insertOcrRoles(opp);
                    }
                    setAfterContext(opp);


                    List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();

                    if (productDetailsMap.containsKey(fd.pm_product)){
                        Product_Details__c pd = productDetailsMap.get(fd.pm_product);
                        OpportunityLineItem oli = new OpportunityLineItem();
                        openOppLine = [Select Id, OpportunityId, Opportunity.OwnerId, Opportunity.Owner.Email, Product2Id, NetSuite_Invoice_Memo__c, Projects__c, Product_Details__c, Display_Logo_On_Website__c, No_Press_Release_Announcement__c, Send_Invoice_Copy_to_Primary_Contact__c, Start_Date__c, End_Date__c, Quantity, UnitPrice, Membership_Tier__c
                                       From OpportunityLineItem
                                       WHERE OpportunityId = :opp.Id AND Opportunity.IsClosed = FALSE AND Projects__c = :pd.Project__c AND Opportunity.AccountId = :accId AND Opportunity.IsClosed = FALSE AND Opportunity.Type != 'Renewal'
                                       LIMIT 1];
                        if (openOppLine.isEmpty() || (!openOppLine.isEmpty() && pd.Products__c != openOppLine[0].Product2Id)){
                            oli.Product2Id = pd.Products__c;
                            oli.OpportunityId = opp.Id;
                            
                        //Assign PBE
                        System.debug('pbe ' + productCurrencyVsPBSId.get(pd.Products__c + '-' + opp.CurrencyIsoCode));
                        if (productCurrencyVsPBSId.containsKey(pd.Products__c + '-' + opp.CurrencyIsoCode)){
                            oli.PricebookEntryId = productCurrencyVsPBSId.get(pd.Products__c + '-' + opp.CurrencyIsoCode);
                        }
                            if (!openOppLine.isEmpty() && pd.Products__c != openOppLine[0].Product2Id){
                                 //assetRecs.isEMpty()
                                setBeforeContext(openOppLine[0]);
                                delete openOppLine[0];
                            }
                        } else{
                            oli = openOppLine[0];
                            setBeforeContext(oli);
                        }

                        system.debug('zero ' + fd.zero_memebership);

                        oli.Projects__c = pd.Project__c;
                        oli.Project__c = pd.Project__r.Name;
                        oli.Product_Details__c = pd.Id;
                        oli.Display_Logo_On_Website__c = !fd.display_logo;
                        oli.No_Press_Release_Announcement__c = !fd.press_release_announcement;
                        oli.Send_Invoice_Copy_to_Primary_Contact__c = fd.pm_primary_con_invoice_copy;
                        oli.Quantity = 1;
                        oli.UnitPrice = (fd.zero_memebership == 'lfeurope' && fd.projectSlug == 'lfeurope') || (fd.zero_memebership == 'tlf' && fd.projectSlug == 'tlf') ? 0 : pd.Price__c;
                        oli.Zero_Membership__c = (fd.zero_memebership == 'lfeurope' && fd.projectSlug == 'lfeurope') || (fd.zero_memebership == 'tlf' && fd.projectSlug == 'tlf');
                        oli.Membership_Tier__c = fd.employeeSize;
                        if (String.isNotBlank(fd.category)){
                            oli.Category__c = fd.category;
                        }
                        if (String.isNotBlank(fd.pm_po)){
                            oli.PO_Number__c = fd.pm_po;
                        }

                        oppLineItems.add(oli);
                    }

                    System.debug('fd.lm_product: ' + fd.lm_product);
                    System.debug('fd.lm_product:dd ' + assetRecs.isEmpty());

                    
                    if (String.IsNotBlank(fd.lm_product) && productDetailsMap.containsKey(fd.lm_product) && assetRecs.isEmpty()){
                        Product_Details__c pd = productDetailsMap.get(fd.lm_product);
                        System.debug('pd: ' + pd);
                        OpportunityLineItem[] lm_oppLine = [Select Id, OpportunityId, Opportunity.OwnerId, Opportunity.Owner.Email, Product2Id, NetSuite_Invoice_Memo__c, Projects__c, Product_Details__c, Display_Logo_On_Website__c, No_Press_Release_Announcement__c, Send_Invoice_Copy_to_Primary_Contact__c, Start_Date__c, End_Date__c, Quantity, UnitPrice, Membership_Tier__c
                                                            From OpportunityLineItem
                                                            WHERE OpportunityId = :opp.Id AND Opportunity.IsClosed = FALSE AND Projects__c = :pd.Project__c
                                                            LIMIT 1];
                        System.debug('lm_oppLine: ' + lm_oppLine);
                        OpportunityLineItem oli = new OpportunityLineItem();

                        if (lm_oppLine.isEmpty() || (!lm_oppLine.isEmpty() && pd.Products__c != lm_oppLine[0].Product2Id)){
                            oli.Product2Id = pd.Products__c;
                            oli.OpportunityId = opp.Id;
                               //Assign PBE
                        System.debug('pbe lm' + productCurrencyVsPBSId.get(pd.Products__c + '-' + opp.CurrencyIsoCode));
                        if (productCurrencyVsPBSId.containsKey(pd.Products__c + '-' + opp.CurrencyIsoCode)){
                            oli.PricebookEntryId = productCurrencyVsPBSId.get(pd.Products__c + '-' + opp.CurrencyIsoCode);
                        }
                            if (!lm_oppLine.isEmpty() && pd.Products__c != lm_oppLine[0].Product2Id){
                                setBeforeContext(lm_oppLine[0]);
                                delete lm_oppLine[0];
                            }
                        } else{
                            oli = lm_oppLine[0];
                            setBeforeContext(oli);
                        }

                     

                        oli.Projects__c = pd.Project__c;
                        oli.Project__c = pd.Project__r.Name;
                        oli.Product_Details__c = pd.Id;
                        oli.Display_Logo_On_Website__c = !fd.display_logo;
                        oli.No_Press_Release_Announcement__c = !fd.press_release_announcement;
                        oli.Send_Invoice_Copy_to_Primary_Contact__c = fd.lm_primary_con_invoice_copy;
                        oli.Quantity = 1;
                        oli.UnitPrice = fd.zero_memebership == 'lfeurope' || fd.zero_memebership == 'tlf' ? 0 : pd.Price__c;
                        oli.Zero_Membership__c = fd.zero_memebership == 'lfeurope' || fd.zero_memebership == 'tlf' ;
                        oli.Membership_Tier__c = fd.employeeSize;

                        if (String.isNotBlank(fd.pm_po)){
                            oli.PO_Number__c = fd.pm_po;
                        }

                        if (String.isNotBlank(fd.mode) && fd.mode.equalsIgnoreCase('test')){
                            oli.Skip_NetSuite_Sync__c = true;
                        }
                        oppLineItems.add(oli);
                    }


                    System.debug('oppLineItems: ' + oppLineItems);
                    if (oppLineItems.size() > 0 && !Test.isRunningTest()){
                        upsert oppLineItems;
                        System.debug('roleVsSFrole before==' + roleVsSFrole);
                        insertProjectRoles(oppLineItems, fd, opp.Id);
                        for (OpportunityLineItem oli : oppLineItems){
                    
                            setAfterContext(oli);
                        }

                    }

                }

                //Check if primary contact needs to be updated
                System.debug('roleVsEmail: ' + roleVsEmail);
                System.debug('emailVsContactId: ' + emailVsContactId);
                System.debug('emailVsContactDetails: ' + emailVsContactDetails);

                Map<Id, String> contactIdVsEmail = new Map<Id, String>();

                if (roleVsEmail.containsKey('pm_primary_con') && emailVsContactId.containsKey(roleVsEmail.get('pm_primary_con')) && emailVsContactDetails.containsKey(roleVsEmail.get('pm_primary_con'))){

                    Id contId = emailVsContactId.get(roleVsEmail.get('pm_primary_con'));
                    String email = emailVsContactDetails.get(roleVsEmail.get('pm_primary_con')).Email;
                    contactIdVsEmail.put(contId, email);
                }

                if (roleVsEmail.containsKey('lm_primary_con') && emailVsContactId.containsKey(roleVsEmail.get('lm_primary_con')) && emailVsContactDetails.containsKey(roleVsEmail.get('lm_primary_con'))){

                    Id contId = emailVsContactId.get(roleVsEmail.get('lm_primary_con'));
                    String email = emailVsContactDetails.get(roleVsEmail.get('lm_primary_con')).Email;
                    contactIdVsEmail.put(contId, email);
                }

                contactRolesWrapMap = replaceEmailWithContactId(emailVSContactId, contactRolesWrapMap);
                contactRolesLFWrapMap = replaceEmailWithContactId(emailVSContactId, contactRolesLFWrapMap);

                System.debug(contactRolesWrapMap + '====> contactRolesWrapMap');
                System.debug(contactRolesLFWrapMap + '====> contactRolesWrapMap');

                addMembersToCampaign(fd.pm_project, contactRolesWrapMap);
                addMembersToCampaign(fd.lm_project, contactRolesLFWrapMap);

                if (prj.Id != null){
                    JoinNowUtility.upsertAccountAndProject(accId, prj.Id, fd.category);
                    if (beforeUpsertAccountAndProject != NULL){
                        setBeforeContext(beforeUpsertAccountAndProject);
                    }

                    if (afterUpsertAccountAndProject != NULL){
                        setAfterContext(afterUpsertAccountAndProject);
                    }
                }

                APIRequestLog.updateApiLog(apiId, beforeUpdate, afterUpdate);

            } else{
                //errorMessage = 'One or more Ids passed are not valid, or no records were found for those Ids';
                APIRequestLog.updateApiRequestLog(apiId, 'Error: ' + errorMessage);
            }

        } catch (exception e){
            System.debug('Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString() + ' and Cause: ' + e.getCause());
            errorMessage = 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString() + ' and Cause: ' + e.getCause();
            APIRequestLog.updateApiRequestLog(apiId, 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());

        }

        try{
            List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
            List<Opportunity> oppt = new List<Opportunity>();
            //OrgWideEmailAddress orgWideEmail = [SELECT ID,DisplayName,Address FROM OrgWideEmailAddress WHERE DisplayName = 'JoinNow'];
            Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
            Boolean oppExist = opp.Id != null;
            if (oppExist){
                oppt = [Select Id, Name, Owner.Email, Owner.FirstName, Opportunity_Link__c, Owner.LastName, Account.Name, (SELECT Name, Project__c, UnitPrice, Membership_Tier__c, Membership__c, Projects__r.Notifications_Group__c, CurrencyIsoCode
                                                                                                                           FROM OpportunityLineItems)
                        from Opportunity 
                        where Id = :opp.Id];
            }
            emailsList = JoinNowUtility.getAllEmailTemps(requestBody, errorMessage, oppt, orgWideEmailAddress, fd, prj, oppExist, informOppOwnerForWebsite, brandNewAccount, mergeWebsite, isEmployeeSizeUpdated);
            if (!emailsList.isEmpty()){
                Messaging.sendEmail(emailsList);
            }
        } catch (exception e){
            System.debug('Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString() + ' and Cause: ' + e.getCause());
            errorMessage = 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString();
            APIRequestLog.updateApiRequestLog(apiId, 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
        }

        System.debug('errorMessage' + errorMessage);
        if (String.isNotBlank(errorMessage)){
            requestBody = errorMessage;
            response.statusCode = 400;
        }

        return requestBody;
    }

    public static void insertProjectRoles(List<OpportunityLineItem> oppLineItems, JoinNowRequestWrapper fd, Id oppId){
        Map<String, List<Project_Role__c>> oliVsProjectRoles = new Map<String, List<Project_Role__c>>();
        Map<String, Map<String, Map<String, List<Project_Role__c>>>> oppIdVsRoles = new Map<String, Map<String, Map<String, List<Project_Role__c>>>>();
        List<Project_Role__c> existingProjectRoles = [SELECT Id, Contact__c, Role__c, Opportunity__c, Opportunity_Line_Item__c, Status__c, PrimaryContact__c, Alternate_Email__c
                                                      FROM Project_Role__c
                                                      WHERE Opportunity__c = :oppId AND Status__c = 'Active'];
        oppLineItems = [SELECT Id, OpportunityId, Product_Details__c
                        from OpportunityLineItem
                        Where Id IN:oppLineItems];
        Map<String, ID> emailVsAltEmail = new Map<string, ID>();
        For (Alternate_Email__c altObj : [Select ID, Alternate_Email_Address__c
                                          From Alternate_Email__c
                                          WHERE Alternate_Email_Address__c IN:emailVsContactId.keySet()]){
            emailVsAltEmail.put(altObj.Alternate_Email_Address__c, altObj.ID);
        }

        Set<ID> processedIds = new Set<ID>();
        for (Project_Role__c existingRole : existingProjectRoles){
            String key = existingRole.Opportunity__c + '' + existingRole.Opportunity_Line_Item__c;
            if (oppIdVsRoles.containskey(key)){
                if (oppIdVsRoles.get(key).ContainsKey(existingRole.Role__c)){
                    if (oppIdVsRoles.get(key).get(existingRole.Role__c).containsKey((String) existingRole.Contact__c)){
                        oppIdVsRoles.get(key).get(existingRole.Role__c).get((String) existingRole.Contact__c).add(existingRole);
                    } else{
                        oppIdVsRoles.get(key).get(existingRole.Role__c).put((String) existingRole.Contact__c, new List<Project_Role__c>{ existingRole });
                    }
                } else{
                    oppIdVsRoles.get(key).put(existingRole.Role__c, new Map<String, List<Project_Role__c>>{ (String) existingRole.Contact__c => new List<Project_Role__c>{ existingRole } });
                }

            } else{
                oppIdVsRoles.put(Key, new Map<String, Map<String, List<Project_Role__c>>>{ existingRole.Role__c => new Map<String, List<Project_Role__c>>{ (String) existingRole.Contact__c => new List<Project_Role__c>{ existingRole } } });
            }

        }


        Map<String, String> roleVsSFrole = getRolesMap();
        roleVsSFrole.put('pm_primary_con', 'Representative/Voting Contact');
        roleVsSFrole.put('lm_primary_con', 'Representative/Voting Contact');

        for (OpportunityLineItem oli : oppLineItems){

            for (String role : roleVsSFrole.keySet()){
                Boolean foundRecord = false;
                System.debug('Role ***' + role);
                Boolean isActive = FALSE;
                List<String> splitRole = roleVsSFrole.get(role).split(' ');
                //String roleStr = splitRole.size() == 3 ? splitRole[0] + ' ' + splitRole[1] : roleVsSFrole.get(role);
                String roleStr = splitRole.size() == 3 ? splitRole[2].isNumeric() ? splitRole[0] + ' ' + splitRole[1] : roleVsSFrole.get(role) : roleVsSFrole.get(role);

                if (splitRole.size() == 2 || (splitRole.size() == 3 && (!splitRole[2].isNumeric()))){
                    isActive = TRUE;
                }

                if (roleVsEmail.containsKey(role) && emailVsContactId.containsKey(roleVsEmail.get(role))){
                    ID altID = emailVsAltEmail.containsKey(roleVsEmail.get(role)) ? emailVsAltEmail.get(roleVsEmail.get(role)) : NULL;
                    Project_Role__c projectRole;
                    Boolean upsertRec = FALSE;

                    if (oli.Product_Details__c == fd.lm_product && (role.startsWith('lm_') || role.startsWith('po'))){
                        if (!oppIdVsRoles.isEmpty() && oppIdVsRoles.containsKey(oli.OpportunityId + '' + oli.ID) && oppIdVsRoles.get(oli.OpportunityId + '' + oli.ID).ContainsKey(roleStr)){
                             //oppIdVsRoles.get(oli.OpportunityId+''+oli.ID).ContainsKey(roleVsSFrole.get(role))
                            if (oppIdVsRoles.get(oli.OpportunityId + '' + oli.ID).get(roleStr).containskey(emailVsContactId.get(roleVsEmail.get(role)))){

                                for (Project_Role__c roleRec : oppIdVsRoles.get(oli.OpportunityId + '' + oli.ID).get(roleStr).get(emailVsContactId.get(roleVsEmail.get(role)))){
                                    if ((isActive && roleRec.PrimaryContact__c) || (!isActive && roleRec.PrimaryContact__c) || (!roleRec.PrimaryContact__c && isActive) || ((!isActive && !roleRec.PrimaryContact__c))){
                                        projectRole = roleRec;
                                        foundRecord = true;
                                    }
                                }

                                if (foundRecord){
                                    projectRole.Alternate_Email__c = altID;
                                    if (isActive){
                                        projectRole.PrimaryContact__c = True;
                                    } else{
                                        projectRole.PrimaryContact__c = False;
                                    }

                                    processedIds.add(projectRole.ID);
                                    upsertRec = TRUE;
                                } else{
                                    upsertRec = TRUE;
                                    projectRole = getProjectRole(emailVsContactId.get(roleVsEmail.get(role)), roleStr, isActive, oli.Id, oli.OpportunityId, altID);
                                }
                            } else{
                                upsertRec = TRUE;
                                projectRole = getProjectRole(emailVsContactId.get(roleVsEmail.get(role)), roleStr, isActive, oli.Id, oli.OpportunityId, altID);
                            }
                        } else{
                            upsertRec = TRUE;
                            projectRole = getProjectRole(emailVsContactId.get(roleVsEmail.get(role)), roleStr, isActive, oli.Id, oli.OpportunityId, altID);
                        }
                    } else if (oli.Product_Details__c == fd.pm_product && (role.startsWith('pm_') || role.startsWith('po') || role.startsWith('eventSponsor') || role.startsWith('cmt_'))){
                        System.debug(oppIdVsRoles.get(oli.OpportunityId + '' + oli.ID));
                        System.debug(roleVsSFrole.get(role));

                        if (!oppIdVsRoles.isEmpty() && oppIdVsRoles.containsKey(oli.OpportunityId + '' + oli.ID) && oppIdVsRoles.get(oli.OpportunityId + '' + oli.ID).ContainsKey(roleStr)){
                            if (oppIdVsRoles.get(oli.OpportunityId + '' + oli.ID).get(roleStr).containskey(emailVsContactId.get(roleVsEmail.get(role)))){
                                foundRecord = false;
                                for (Project_Role__c roleRec : oppIdVsRoles.get(oli.OpportunityId + '' + oli.ID).get(roleStr).get(emailVsContactId.get(roleVsEmail.get(role)))){

                                    if ((isActive && roleRec.PrimaryContact__c) || (!isActive && !roleRec.PrimaryContact__c) || (!isActive && roleRec.PrimaryContact__c) || (isActive && !roleRec.PrimaryContact__c)){
                                        projectRole = roleRec;
                                        foundRecord = true;
                                    }
                                }

                                if (foundRecord){
                                    projectRole.Alternate_Email__c = altID;
                                    if (isActive){
                                        projectRole.PrimaryContact__c = True;
                                    } else{
                                        projectRole.PrimaryContact__c = False;
                                    }
                                    processedIds.add(projectRole.ID);
                                    upsertRec = TRUE;
                                } else{
                                    upsertRec = TRUE;
                                    projectRole = getProjectRole(emailVsContactId.get(roleVsEmail.get(role)), roleStr, isActive, oli.Id, oli.OpportunityId, altID);
                                }
                            } else{
                                upsertRec = TRUE;
                                projectRole = getProjectRole(emailVsContactId.get(roleVsEmail.get(role)), roleStr, isActive, oli.Id, oli.OpportunityId, altID);
                            }
                        } else{
                            upsertRec = TRUE;
                            isActive = roleVsSFrole.get(role) == 'Representative/Voting Contact' ? TRUE : isActive;
                            projectRole = getProjectRole(emailVsContactId.get(roleVsEmail.get(role)), roleStr, isActive, oli.Id, oli.OpportunityId, altID);
                        }
                    }

                    if (upsertRec && oliVsProjectRoles.containsKey(oli.ID)){
                        oliVsProjectRoles.get(oli.ID).add(projectRole);
                    } else if (upsertRec){
                        oliVsProjectRoles.put(oli.ID, new List<Project_Role__c>{ projectRole });
                    }
                }
            }
        }
        List<Project_Role__c> allRoles = new List<Project_Role__c>();

        for (String opidOliID : oppIdVsRoles.keySet()){
            for (String roleStr : oppIdVsRoles.get(opidOliID).keySet()){
                for (String conID : oppIdVsRoles.get(opidOliID).get(roleStr).keySet()){
                    for (Project_Role__c prjRole : oppIdVsRoles.get(opidOliID).get(roleStr).get(conID)){
                        if (!processedIds.contains(prjRole.ID) && oliVsProjectRoles.containsKey(prjRole.Opportunity_Line_Item__c)){
                            prjRole.Status__c = 'Inactive';
                            allRoles.Add(prjRole);
                        }
                    }
                }
            }

        }
        // Map<String, Map<String, Map<String, List<Project_Role__c>>>>)

        for (Project_Role__c prjRole : allRoles){
            System.debug('**** ' + prjRole);
        }
        System.debug('oliVsProjectRoles ***' + oliVsProjectRoles);
        if (!oliVsProjectRoles.isEmpty()){
            for (String oliId : oliVsProjectRoles.keySet()){
                allRoles.addAll(oliVsProjectRoles.get(oliId));
            }
            upsert allRoles;
        }
    }

    public static Project_Role__c getProjectRole(String conID, String role, Boolean isPrimary, ID oliId, Id oppID, ID altID){
         //Date startDate, Date endDate,
        System.debug('get project role===>' + role);
        System.debug('get project role===>' + conID);
        Project_Role__c projectRole = new Project_Role__c();
        projectRole.Contact__c = conID;
        projectRole.Role__c = role;
        projectRole.PrimaryContact__c = isPrimary;
        projectRole.Opportunity_Line_Item__c = oliId;
        projectRole.Opportunity__c = oppId;
        if (altID != NULL)
            projectRole.Alternate_Email__c = altID;
        return projectRole;
    }

    public static String findOrCreateBillToAddress(JoinNowRequestWrapper fd, ID accID){
        String BillToAddressID = NULL;
        Address__c adressRec = new Address__c();
        Boolean createRec = False;
        Boolean updateRec = False;

        if (String.isNotBlank(fd.billto_account_id)){
            List<Address__c> adressRecs = [Select Account__c, Name, City__c, Country__c, Description__c, State__c, Street__c, Zip_Postal_Code__c
                                           from Address__c
                                           WHERE ID = :fd.billto_account_id
                                           LIMIT 1];

            if (!adressRecs.IsEmpty()){
                adressRec.ID = adressRecs[0].ID;
                BillToAddressID = adressRecs[0].ID;

                if (String.isNotBlank(fd.billto_account) && fd.billto_account != adressRecs[0].Account__c && fd.billto_account == accID){
                    adressRec.Account__c = fd.billto_account;
                    updateRec = TRUE;
                }

            } else{
                createRec = TRUE;
            }
        } else{
            createRec = TRUE;
        }

        if (createRec){
            adressRec.Account__c = accID;
            createRec = False;
            if (String.isNotBlank(fd.billto_account_name)){
                adressRec.Name = fd.billto_account_name;
                createRec = TRUE;
            }
            if (String.isNotBlank(fd.billto_street)){
                adressRec.Street__c = fd.billto_street;
                createRec = TRUE;
            }
            if (String.isNotBlank(fd.billto_city)){
                adressRec.City__c = fd.billto_city;
                createRec = TRUE;
            }
            if (String.isNotBlank(fd.billto_state)){
                adressRec.State__c = fd.billto_state;
                createRec = TRUE;
            }
            if (String.isNotBlank(fd.billto_country)){
                adressRec.Country__c = fd.billto_country;
                createRec = TRUE;
            }
            if (String.isNotBlank(fd.billto_zip)){
                adressRec.Zip_Postal_Code__c = fd.billto_zip;
                createRec = TRUE;
            }
        }

        if (createRec || updateRec){
            upsert adressRec;
            BillToAddressID = adressRec.ID;
        } else{
            BillToAddressID = BillToAddressID != NULL ? BillToAddressID : NULL;
        }

        return BillToAddressID;
    }

    public static void insertOcrRoles(Opportunity opp){
        List<OpportunityContactRole> ocRoles = new List<OpportunityContactRole>();
        if (roleVsEmail.get('pm_primary_con') != null && emailVsContactId.containsKey(roleVsEmail.get('pm_primary_con'))){
            OpportunityContactRole ocr = new OpportunityContactRole();
            ocr.OpportunityId = opp.Id;
            ocr.ContactId = emailVsContactId.get(roleVsEmail.get('pm_primary_con'));
            ocr.Role = 'Membership Decision Maker';

            List<OpportunityContactRole> existingOcrs = [SELECT ID
                                                         FROM OpportunityContactRole
                                                         WHERE OpportunityId = :ocr.OpportunityId AND ContactId = :ocr.ContactId AND Role = :ocr.Role];
            if (existingOcrs.isEmpty()){
                ocRoles.add(ocr);
            } else{
                for (OpportunityContactRole ocrRoles : existingOcrs){
                    setBeforeContext(ocrRoles);
                }

            }
        }

        if (ocRoles.size() > 0){
            insert ocRoles;
            for (OpportunityContactRole ocrRoless : ocRoles){
                setAfterContext(ocrRoless);
            }
        } else{
            for (OpportunityContactRole ocrRoless : ocRoles){
                setAfterContext(ocrRoless);
            }
        }
    }

    public static Map<String, ContactRolesWrapper> replaceEmailWithContactId(Map<String, Id> emailVSContactId, Map<String, ContactRolesWrapper> contactRolesWrapMap){
        for (String email : contactRolesWrapMap.keySet()){
            if (email.contains('@') && emailVSContactId.containskey(email)){
                ContactRolesWrapper contactRolesWrap = contactRolesWrapMap.get(email);
                contactRolesWrap.contactId = emailVSContactId.get(email);
                contactRolesWrapMap.remove(email);
                contactRolesWrapMap.put(emailVSContactId.get(email), contactRolesWrap);
            }
        }
        return contactRolesWrapMap;
    }

    public static void addMembersToCampaign(String projectID, Map<String, ContactRolesWrapper> contactRolesWrapMap){

        List<Campaign> campList = [SELECT Id, Name
                                   FROM Campaign
                                   WHERE Project__c = :projectID AND Type = 'Web Form - Join Now'];

        //contactRolesWrapMap = updateContactRolesName(contactRolesWrapMap);
        if (!campList.isEmpty()){
            Campaign joinNowCampaign = campList[0];

            Map<String, CampaignMember> contactIdVsMember = new Map<String, CampaignMember>();

            List<CampaignMember> memberList = [SELECT Id, Name, ContactId, Email, Project_Role_Subscriptions__c
                                               FROM CampaignMember
                                               WHERE CampaignId = :joinNowCampaign.id];
            if (!memberList.isEmpty()){
                for (CampaignMember member : memberList){
                    contactIdVsMember.put(member.ContactId, member);
                }
            }

            List<CampaignMember> campMembersToUpsert = new List<CampaignMember>();
            for (String contactId : contactIdVsMember.keySet()){
                if (contactRolesWrapMap.containsKey(contactId) && contactRolesWrapMap.get(contactId) != null){
                    ContactRolesWrapper wrap = contactRolesWrapMap.get(contactId);
                    CampaignMember member = contactIdVsMember.get(contactId);
                    member.MC_Project_Role_Subscriptions__c = String.join(wrap.rolesList, ';');
                    member.Project_Role_Subscriptions__c = String.join(wrap.subscribedRolesList, ';');
                    campMembersToUpsert.add(member);
                    //remove all the processed contact
                    contactRolesWrapMap.remove(contactId);
                }
            }
            //Check if there are contacts left. Create the remaining Campaign Members.
            if (contactRolesWrapMap.size() > 0){
                for (String contactId : contactRolesWrapMap.keySet()){
                    ContactRolesWrapper wrap = contactRolesWrapMap.get(contactId);
                    campMembersToUpsert.add(new CampaignMember(ContactId = contactId, CampaignId = joinNowCampaign.Id, MC_Project_Role_Subscriptions__c = String.join(wrap.rolesList, ';'), Project_Role_Subscriptions__c = String.join(wrap.subscribedRolesList, ';')));
                }
            }


            if (campMembersToUpsert.size() > 0){
                for (CampaignMember cmember : campMembersToUpsert){
                    setBeforeContext(cmember);
                }
                JoinNowUtility.addMembersToCampaign(JSON.serialize(campMembersToUpsert));
                for (CampaignMember cmember : campMembersToUpsert){
                    setAfterContext(cmember);
                }
            }
        }
    }

    //Method added by Priyesh @CloudRoute
    public static Map<String, String> getRolesMap(){
        Map<String, String> roleVsSFrole = new Map<String, String>();
        roleVsSFrole.put('pm_primary_con', 'Voting Contact');
        roleVsSFrole.put('pm_billing_con', 'Billing Contact');
        roleVsSFrole.put('pm_authSig', 'Authorized Signatory');
        roleVsSFrole.put('pm_inv_con', 'Billing Contact 2');
        roleVsSFrole.put('pm_tech_con_1', 'Technical Contact');
        roleVsSFrole.put('pm_tech_con_2', 'Technical Contact 2');
        roleVsSFrole.put('pm_tech_con_3', 'Technical Contact 3');
        roleVsSFrole.put('pm_mkt_con_1', 'Marketing Contact');
        roleVsSFrole.put('pm_mkt_con_2', 'Marketing Contact 2');
        roleVsSFrole.put('pm_pr_con', 'Press Contact');
        roleVsSFrole.put('pm_legal_con', 'Legal Contact');
        roleVsSFrole.put('eventSponsor_con', 'Event Sponsorship');
        roleVsSFrole.put('po_con', 'PO Contact');

        roleVsSFrole.put('lm_primary_con', 'Voting Contact');
        roleVsSFrole.put('lm_billing_con', 'Billing Contact');
        roleVsSFrole.put('lm_authSig', 'Authorized Signatory');
        roleVsSFrole.put('lm_inv_con', 'Billing Contact 2');
        roleVsSFrole.put('lm_tech_con_1', 'Technical Contact');
        roleVsSFrole.put('lm_tech_con_2', 'Technical Contact 2');
        roleVsSFrole.put('lm_tech_con_3', 'Technical Contact 3');
        roleVsSFrole.put('lm_mkt_con_1', 'Marketing Contact');
        roleVsSFrole.put('lm_mkt_con_2', 'Marketing Contact 2');
        roleVsSFrole.put('lm_pr_con', 'Press Contact');
        roleVsSFrole.put('lm_legal_con', 'Legal Contact');

        //Added by Priyesh @CloudRoute for commitee roles
        roleVsSFrole.put('cmt_Finance Committee', 'Finance Committee');
        roleVsSFrole.put('cmt_MarCom Committee', 'MarCom Committee');
        roleVsSFrole.put('cmt_Membership Committee', 'Membership Committee');
        roleVsSFrole.put('cmt_Governance Framework Committee', 'Governance Framework Committee');
        roleVsSFrole.put('cmt_Technical Project', 'Bedrock Technical Project');

        return roleVsSFrole;
    }

    public static void processContactDetails(List<ContactDetails> allContactDetails){
        System.debug('allContactDetails: ' + allContactDetails);

        Map<String, String> roleVsSFrole = getRolesMap(); //ToDo: Create a separate method for setting values in this map

        for (ContactDetails cd : allContactDetails){
            roleVsEmail.put(cd.Role, cd.Email);

            if (String.isNotBlank(cd.Email) && cd.Email.containsNone('*')){
                if (cd.Role.startsWith('pm_')){
                    populateContactRolesMap(cd.Email, roleVsSFrole.get(cd.Role), cd.Subscribed);
                } else{
                    populateLFContactRolesMap(cd.Email, roleVsSFrole.get(cd.Role), cd.Subscribed);
                }
                if (cd.Role.equals('po_con')){
                    populateContactRolesMap(cd.Email, roleVsSFrole.get(cd.Role), cd.Subscribed);
                    populateLFContactRolesMap(cd.Email, roleVsSFrole.get(cd.Role), cd.Subscribed);
                }
                emailVsContactDetails.put(cd.Email, cd);
            } else if (String.isNotBlank(cd.ContactId)){
                if (cd.Role.startsWith('pm_')){
                    populateContactRolesMap(cd.ContactId, roleVsSFrole.get(cd.Role), cd.Subscribed);
                } else{
                    populateLFContactRolesMap(cd.ContactId, roleVsSFrole.get(cd.Role), cd.Subscribed);
                }
                contactIdVsContactDetails.put(cd.ContactId, cd);
                if (contactIdVsRole.containsKey(cd.ContactId)){
                    contactIdVsRole.get(cd.ContactId).add(cd.role);
                } else{
                    contactIdVsRole.put(cd.ContactId, new List<String>{ cd.role });
                }

            }

        }
        System.debug('contactIdVsContactDetails: ' + contactIdVsContactDetails);

        for (Contact con : [SELECT Id, Email
                            From Contact
                            Where ID in:contactIdVsContactDetails.keySet() AND Email != null]){
            System.debug('con.Id: ' + con.Id);
            emailVsContactDetails.put(con.Email, contactIdVsContactDetails.get(con.Id));

            for (String role : contactIdVsRole.get(con.Id)){
                roleVsEmail.put(role, con.Email);
            }

        }
        System.debug('emailVsContactDetails: ' + emailVsContactDetails);
        System.debug('roleVsEmail: ' + roleVsEmail);

        System.debug('contactIdVsRole: ' + contactIdVsRole);
    }

    public static void findOrCreateAccountAndContacts(String accountId, String company, String address, String city, String state, String country, String zip, String employeeSize, String logo_url, String website){

        //Find Alternate Email records for all emails from submission
        //If the Alternate Email is inactive, make it active

        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        List<Contact> newContacts = new List<Contact>();
        Map<String, Contact> emailVsContact = new Map<String, Contact>();

        //Check for existing account or create a new one
        System.debug('accId: ' + accId);
        if (String.isNotBlank(accountId)){
            Account[] accs = [SELECT Id
                              From Account
                              WHERE Id = :accountId];
            if (!accs.isEmpty()){
                accId = accs[0].Id;
            }
        }
        System.debug('accId after query: ' + accId);

        // Added by @harshadk for fixing website truncation bug SOPS-686
        /*if (string.isNotBlank(website)) {
         List<String> websiteList = website.split('\\.');
         if(websiteList.size() > 1){
         website = websiteList[websiteList.size()-2]+'.'+websiteList[websiteList.size()-1];
         }
         }*/

        if (string.isNotBlank(website)){
            website = website.replace('http://', '').replace('https://', '').replace('www.', '').substringBefore('/');
        }

        if (String.isBlank(accId)){
            Account[] accounts = new List<Account>();
            Boolean updateName = False;
            Boolean setDummyWebsite = False;
            String webDomain;
            //Look for account based on name and website

            if (string.isNotBlank(website)){
                website = website.replace('http://', '').replace('https://', '').replace('www.', '').substringBefore('/');
            }

            if (string.isNotBlank(website)){
                webDomain = website.replace('http://', '').replace('https://', '').replace('www.', '').substringBefore('/');
                System.debug('webDomain: ' + webDomain);
                for (account a : [Select Id, Name, Account_Domain__c
                                  From Account
                                  Where Account_Domain__c = :webDomain
                                  LIMIT 1]){
                    setDummyWebsite = True;
                }
            }

            if (accounts.isEmpty() && String.isNotBlank(company)){
                accounts = [Select Id, Name, Account_Domain__c
                            From Account
                            Where Name = :company
                            LIMIT 1];
            }

            if (setDummyWebsite && String.isNotBlank(webDomain) && (accounts.isEmpty() || (!accounts.isEmpty() && accounts[0].Account_Domain__c != webDomain))){
                website = 'joinNow_' + webDomain;
                informOppOwnerForWebsite = True;
                mergeWebsite = website;
            }

            if (!accounts.isEmpty()){
                accId = accounts[0].Id;
                updateAccountDetails(accId, company, address, city, state, country, zip, logo_url, employeeSize, website, updateName);
            } else{
                /*Updated On 28th Oct 2020 By Priyesh @CloudRoute to truncate the address fields based on field limit*/
                Account acc = new Account();
                acc.Name = company != '' ? company : 'New Company';
                acc.BillingStreet = address?.left(255);
                acc.BillingCity = city?.left(40);
                acc.BillingState = state?.left(80);
                acc.BillingCountry = country?.left(80);
                acc.BillingPostalCode = zip?.left(20);
                acc.No_Of_Employess__c = employeeSize;
                acc.Website = website;
                acc.Logo_URL__c = logo_url != 'undefined' && logo_url != 'dummy.com' ? logo_url : '';
                insert acc;
                setAfterContext(acc);
                // if(String.isNotBlank(logo_url))
                //upsertLogo(NULL, logo_url, acc.ID);

                accId = acc.Id;
                brandNewAccount = true;
            }

        } else{
            updateAccountDetails(accId, company, address, city, state, country, zip, logo_url, employeeSize, website, false);
        }

        JoinNowUtility.getContacts(emailVsContactDetails.keySet(), accId);

        List<String> brandNewEmails = new List<String>();
        for (String email : emailVsContactDetails.keySet()){
            Boolean leadRecord = False;
            Boolean foundRec = False;
            if (JoinNowUtility.emailVsAltEmail.containsKey(email) && JoinNowUtility.emailVsAltEmail.get(email) != NULL){
                Alternate_Email__c altEmail = JoinNowUtility.emailVsAltEmail.get(email);
                if (altEmail.Contact_Name__c == null){
                    leadRecord = TRUE;
                }

                if (altEmail.Contact_Name__c != null){
                    foundRec = true;

                    emailVsContactId.put(email, altEmail.Contact_Name__r.ID);
                }

            }
            system.debug('JoinNowUtility.emailVsContact==>' + JoinNowUtility.emailVsContact);
            if ((leadRecord && JoinNowUtility.emailVsContact.containsKey(email) && JoinNowUtility.emailVsContact.get(email) != NULL) || (JoinNowUtility.emailVsContact.containsKey(email) && JoinNowUtility.emailVsContact.get(email) != NULL)){
                foundRec = true;
                emailVsContactId.put(email, JoinNowUtility.emailVsContact.get(email).ID);
            }

            if (!foundRec){
                brandNewEmails.add(email);
            }
        }


        for (string email : brandNewEmails){
            ContactDetails cd = emailVsContactDetails.get(email);
            System.debug('cd: ' + cd);
            Contact con = new Contact();
            con.AccountId = accId;
            con.FirstName = cd.FirstName.length() <= 40 ? cd.FirstName : cd.FirstName.substring(0, 40);
            con.LastName = cd.LastName.length() <= 80 ? cd.LastName : cd.LastName.substring(0, 80);
            con.Title = cd.Title;
            con.Email = cd.Email;
            con.Phone = cd.Phone;
            con.Twitter_ID__c = cd.Twitter;
            con.GitHub_ID__c = cd.GitHub;
            con.LinkedIn_ID__c = cd.LinkedIn;
            con.LeadSource = 'Join Us Form';
            con.Lead_Source_Detail1__c = 'Other';
            setAfterContext(con);
            emailVsContact.put(email, con);
        }
        if (!emailVsContact.isEmpty()){
            upsert emailVsContact.values();
            for (String email : emailVsContact.keySet()){
                emailVsContactId.put(email, emailVsContact.get(email).Id);
            }
        }

        updateContactDetails(emailVsContactId);
    }

    public static void populateContactRolesMap(String contORemail, String role, Boolean isSubscribed){
        ContactRolesWrapper contRolesWrap;
        if (contactRolesWrapMap.containskey(contORemail) && contactRolesWrapMap.get(contORemail) != null){
            contRolesWrap = contactRolesWrapMap.get(contORemail);
            contRolesWrap.rolesList.add(role);
            if (isSubscribed){
                contRolesWrap.subscribedRolesList.add(role);
            }
        } else{
            contRolesWrap = new ContactRolesWrapper();
            if (contORemail.contains('@')){
                contRolesWrap.emailAddress = contORemail;
            } else{
                contRolesWrap.contactId = contORemail;
            }
            contRolesWrap.rolesList = new List<String>{ role };
            contRolesWrap.subscribedRolesList = new List<String>();

            if (isSubscribed){
                System.debug('===Debug=> Subscribed Role' + contRolesWrap);
                contRolesWrap.subscribedRolesList.add(role);
            }

        }
        System.debug(contRolesWrap.subscribedRolesList + '====> contRolesWrap.subscribedRolesList');

        contactRolesWrapMap.put(contORemail, contRolesWrap);
        System.debug(contactRolesWrapMap + '====> contactRolesWrapMap');
    }

    public static void populateLFContactRolesMap(String contORemail, String role, Boolean isSubscribed){
        ContactRolesWrapper contRolesWrap;
        if (contactRolesLFWrapMap.containskey(contORemail) && contactRolesLFWrapMap.get(contORemail) != null){
            contRolesWrap = contactRolesLFWrapMap.get(contORemail);
            contRolesWrap.rolesList.add(role);
            if (isSubscribed){
                contRolesWrap.subscribedRolesList.add(role);
            }
        } else{
            contRolesWrap = new ContactRolesWrapper();
            if (contORemail.contains('@')){
                contRolesWrap.emailAddress = contORemail;
            } else{
                contRolesWrap.contactId = contORemail;
            }
            contRolesWrap.rolesList = new List<String>{ role };
            contRolesWrap.subscribedRolesList = new List<String>();

            if (isSubscribed){
                contRolesWrap.subscribedRolesList.add(role);
            }

        }
        System.debug(contRolesWrap.subscribedRolesList + '====> contRolesWrap.subscribedRolesList');

        contactRolesLFWrapMap.put(contORemail, contRolesWrap);
        System.debug(contactRolesLFWrapMap + '====> contactRolesWrapMap');
    }

    public static void updateAccountDetails(Id accId, String company, String street, String city, String state, String country, String postalCode, String logo_url, String employeeSize, String website, Boolean updateName){
        System.debug('inside updateAccountDetails ');
        if (accId != null){
            Account acc = [Select Id, Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Logo_URL__c, No_Of_Employess__c, Website, IsPersonAccount
                           From Account
                           Where Id = :accId];
            setBeforeContext(acc);
            Boolean updateAccount = false;
            String logoURL = '%' + logo_url + '%';
            /*List<Account_Logos__c> accLogo = [Select ID, Logo_URL__c ,Type__c, Account__c FROM Account_Logos__c WHERE Account__c =: acc.ID AND Join_Now__c = TRUE LIMIT 1];

             if(!accLogo.isEmpty() && String.isNotBlank(logo_url)){
             if(logo_url != accLogo[0].Logo_URL__c) {
             setBeforeContext(accLogo[0]);
             upsertLogo(accLogo[0], logo_url, accLogo[0].Account__c);
             }
             }
             else if(String.isNotBlank(logo_url)){
             upsertLogo(Null, logo_url, acc.ID);
             }*/

            if (acc.IsPersonAccount){
                Account accWithoutName = new Account();
                accWithoutName.Id = acc.Id;
                accWithoutName.BillingStreet = acc.BillingStreet;
                accWithoutName.BillingCity = acc.BillingCity;
                accWithoutName.BillingState = acc.BillingState;
                accWithoutName.BillingCountry = acc.BillingCountry;
                accWithoutName.BillingPostalCode = acc.BillingPostalCode;
                accWithoutName.Logo_URL__c = acc.Logo_URL__c;
                accWithoutName.No_Of_Employess__c = acc.No_Of_Employess__c;
                accWithoutName.Website = acc.Website;
                acc = accWithoutName;
            }

            /*Updated On 28th Oct 2020 By Priyesh @CloudRoute to truncate the address fields based on field limit*/
            if (String.isNotBlank(street) && acc.BillingStreet != street){
                acc.BillingStreet = street.left(255);
                updateAccount = true;
            }

            if (String.isNotBlank(city) && acc.BillingCity != city){
                acc.BillingCity = city.left(40);
                updateAccount = true;
            }

            if (String.isNotBlank(state) && acc.BillingState != state){
                acc.BillingState = state.left(80);
                updateAccount = true;
            }

            if (String.isNotBlank(country) && acc.BillingCountry != country){
                acc.BillingCountry = country.left(80);
                updateAccount = true;
            }

            if (String.isNotBlank(postalCode) && acc.BillingPostalCode != postalCode){
                acc.BillingPostalCode = postalCode.left(20);
                updateAccount = true;
            }

            if (String.isNotBlank(logo_url) && acc.Logo_URL__c != logo_url){
                acc.Logo_URL__c = logo_url != 'undefined' && logo_url != 'dummy.com' ? logo_url : acc.Logo_URL__c;
                updateAccount = true;
            }

            if (String.isNotBlank(employeeSize) && acc.No_Of_Employess__c != employeeSize){
                acc.No_Of_Employess__c = employeeSize;
                isEmployeeSizeUpdated = true;
                updateAccount = true;
            }

            if (String.isNotBlank(website) && acc.Website != website){
                acc.website = website;
                updateAccount = true;
            }

            if (updateAccount){
                System.debug('Updating account');
                setAfterContext(acc);
                update acc;
            } else{
                setAfterContext(acc);
            }
        }
    }

    /* public static void upsertLogo(Account_Logos__c recObj, String logoUrl, ID accID){
     Account_Logos__c logoObj = new Account_Logos__c();

     if(recObj != NULL) {
     logoObj.ID =  recObj.ID;

     if(recObj.Account__c != accID) {
     logoObj.Account__c = accID;
     }

     if(recObj.Logo_URL__c != logoUrl) {
     logoObj.Logo_URL__c = logoUrl;
     }

     if(recObj.Type__c != 'Membership') {
     logoObj.Type__c = 'Membership';
     }

     if(!recObj.Join_Now__c) {
     logoObj.Join_Now__c = TRUE;
     }

     }else {
     logoObj.Account__c = accID;
     logoObj.Logo_URL__c = logoUrl;
     logoObj.Type__c = 'Membership';
     logoObj.Join_Now__c = TRUE;
     }
     upsert logoObj;
     setAfterContext(logoObj);
     }*/
    public static void updateContactDetails(Map<String, String> emailVsContactId){
        for (string email : emailVsContactId.keySet()){
            System.debug(' updateContactDetails email: ' + email);
            if (emailVsContactDetails.containsKey(email)){
                ContactDetails cd = emailVsContactDetails.get(email);
                System.debug('updateContactDetails cd: ' + cd);
                cd.ContactId = emailVsContactId.get(email);
                contactIdVsContactDetails.put(cd.ContactId, cd);
            }
        }

        Set<Contact> contactsToUpdate = new Set<Contact>();
        Set<ID> conIdWithDiffAccount = new Set<ID>();
        Map<String, Boolean> shouldRemapCon = new Map<String, Boolean>();
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([Select ID, FirstName, LastName, Email, Title, Phone, AccountId, Twitter_ID__c, GitHub_ID__c, LinkedIn_ID__c, IsPersonAccount
                                                             From Contact
                                                             WHERE ID IN:emailVsContactId.values()]);

        for (Contact con : contactsMap.Values()){
            if (con.AccountId != (ID) accId){
                conIdWithDiffAccount.add(con.ID);
            }
        }

        if (!conIdWithDiffAccount.isEmpty()){
            shouldRemapCon = JoinNowUtility.checkForPersonAccount(conIdWithDiffAccount, accId);
        }

        for (String contId : contactIdVsContactDetails.keySet()){

            if (contactsMap.containsKey(contId)){
                Contact con = contactsMap.get(contId);

                setBeforeContext(con);
                ContactDetails cd = contactIdVsContactDetails.get(contId);

                System.debug('con: ' + con);

                if (contactIdVsRole.containsKey(contId)){
                    for (String roleString : contactIdVsRole.get(contId)){
                        string role = roleString;
                        string email = con.Email;
                        roleVsEmail.put(role, email);
                    }
                    System.debug('roleVsEmail: ' + roleVsEmail);
                }

                System.debug('con.IsPersonAccount: ' + con.IsPersonAccount);
                if (con.IsPersonAccount){
                    Contact personCon = new Contact();
                    personCon.Id = con.Id;
                    personCon.FirstName = con.FirstName.length() <= 40 ? con.FirstName : con.FirstName.substring(0, 40);
                    personCon.LastName = con.LastName.length() <= 80 ? con.LastName : con.LastName.substring(0, 80);
                    personCon.Title = con.Title;
                    personCon.Email = con.Email;
                    personCon.Phone = con.Phone;
                    personCon.Twitter_ID__c = con.Twitter_ID__c;
                    personCon.GitHub_ID__c = con.GitHub_ID__c;
                    personCon.LinkedIn_ID__c = con.LinkedIn_ID__c;
                    con = personCon;
                    System.debug('con inside If person condition: ' + con);
                }

                Boolean addToList = False;

                if (String.isNotBlank(cd.FirstName) && cd.FirstName.containsNone('*') && con.FirstName != cd.FirstName){
                    con.FirstName = cd.FirstName.length() <= 40 ? cd.FirstName : cd.FirstName.substring(0, 40);
                    addToList = True;
                }

                if (String.isNotBlank(cd.LastName) && cd.LastName.containsNone('*') && con.LastName != cd.LastName){
                    con.LastName = cd.LastName.length() <= 80 ? cd.LastName : cd.LastName.substring(0, 80);
                    addToList = True;
                }

                if (String.isNotBlank(cd.Title) && cd.Title.containsNone('*') && con.Title != cd.Title){
                    con.Title = cd.Title;
                    addToList = True;
                }

                if (String.isNotBlank(cd.Email) && cd.Email.containsNone('*') && con.Email != cd.Email){
                    con.Email = cd.Email;
                    addToList = True;
                }

                if (String.isNotBlank(cd.Phone) && cd.Phone.containsNone('*') && con.Phone != cd.Phone){
                    con.Phone = cd.Phone;
                    addToList = True;
                }

                if (String.isNotBlank(cd.Twitter) && cd.Twitter.containsNone('*') && con.Twitter_ID__c != cd.Twitter){
                    con.Twitter_ID__c = cd.Twitter;
                    addToList = True;
                }

                if (String.isNotBlank(cd.GitHub) && cd.GitHub.containsNone('*') && con.GitHub_ID__c != cd.GitHub){
                    con.GitHub_ID__c = cd.GitHub;
                    addToList = True;
                }

                if (String.isNotBlank(cd.LinkedIn) && cd.LinkedIn.containsNone('*') && con.LinkedIn_ID__c != cd.LinkedIn){
                    con.LinkedIn_ID__c = cd.LinkedIn;
                    addToList = True;
                }

                if ((!shouldRemapCon.isEmpty() && shouldRemapCon.containskey(con.Id) && shouldRemapCon.get(con.Id)) || (con.AccountId != accId && !shouldRemapCon.containskey(con.Id))){
                    con.AccountId = accId;
                    addToList = True;
                }

                if (addToList){
                    System.debug('con: ' + con);
                    setAfterContext(con);
                    contactsToUpdate.add(con);
                } else{
                    setAfterContext(con);
                }
            }


        }

        System.debug('contactsToUpdate: ' + contactsToUpdate);

        if (!contactsToUpdate.isEmpty()){
            update new List<Contact>(contactsToUpdate);
        }
    }

    public static void setBeforeContext(sObject objRec){
        if (String.isNotBlank(beforeUpdate)){
            beforeUpdate += ', \r\n\r\n' + JSON.serialize(objRec);
        } else{
            beforeUpdate = JSON.serialize(objRec);
        }
    }

    public static void setAfterContext(sObject objRec){
        if (String.isNotBlank(afterUpdate)){
            afterUpdate += ', \r\n\r\n' + JSON.serialize(objRec);
        } else{
            afterUpdate = JSON.serialize(objRec);
        }
    }

    public static Map<String, List<String>> getObjectVsIds(JoinNowRequestWrapper fd){
        Map<String, List<String>> objectVsIds = new Map<String, List<String>>();

        if (String.IsNotBlank(fd.AccountId))
            objectVsIds.put('Account', New List<String>{ fd.AccountId });
        Set<String> projectIds = new Set<String>();
        if (String.IsNotBlank(fd.pm_project))
            projectIds.add(fd.pm_project);
        if (String.IsNotBlank(fd.lm_project))
            projectIds.add(fd.lm_project);
        if (!projectIds.IsEmpty())
            objectVsIds.put('Project__c', new List<String>(projectIds));
        Set<String> productDetailIds = new Set<String>();
        if (String.IsNotBlank(fd.pm_product))
            productDetailIds.add(fd.pm_product);
        if (String.IsNotBlank(fd.lm_product))
            productDetailIds.add(fd.lm_product);
        if (!productDetailIds.IsEmpty())
            objectVsIds.put('Product_Details__c', new List<String>(productDetailIds));
        Set<String> contactIds = new Set<String>();
        if (String.IsNotBlank(fd.pm_primary_con_id))
            contactIds.add(fd.pm_primary_con_id);
        if (String.IsNotBlank(fd.pm_billing_con_id))
            contactIds.add(fd.pm_billing_con_id);
        if (String.IsNotBlank(fd.pm_authSig_id))
            contactIds.add(fd.pm_authSig_id);
        if (String.IsNotBlank(fd.pm_inv_con_id))
            contactIds.add(fd.pm_inv_con_id);
        if (String.IsNotBlank(fd.pm_tech_con_1_id))
            contactIds.add(fd.pm_tech_con_1_id);
        if (String.IsNotBlank(fd.pm_tech_con_2_id))
            contactIds.add(fd.pm_tech_con_2_id);
        if (String.IsNotBlank(fd.pm_tech_con_3_id))
            contactIds.add(fd.pm_tech_con_3_id);
        if (String.IsNotBlank(fd.pm_mkt_con_1_id))
            contactIds.add(fd.pm_mkt_con_1_id);
        if (String.IsNotBlank(fd.pm_mkt_con_2_id))
            contactIds.add(fd.pm_mkt_con_2_id);
        if (String.IsNotBlank(fd.pm_pr_con_id))
            contactIds.add(fd.pm_pr_con_id);
        if (String.IsNotBlank(fd.pm_legal_con_id))
            contactIds.add(fd.pm_legal_con_id);
        if (String.IsNotBlank(fd.lm_primary_con_id))
            contactIds.add(fd.lm_primary_con_id);
        if (String.IsNotBlank(fd.lm_billing_con_id))
            contactIds.add(fd.lm_billing_con_id);
        if (String.IsNotBlank(fd.lm_authSig_id))
            contactIds.add(fd.lm_authSig_id);
        if (String.IsNotBlank(fd.lm_inv_con_id))
            contactIds.add(fd.lm_inv_con_id);
        if (String.IsNotBlank(fd.lm_tech_con_1_id))
            contactIds.add(fd.lm_tech_con_1_id);
        if (String.IsNotBlank(fd.lm_tech_con_2_id))
            contactIds.add(fd.lm_tech_con_2_id);
        if (String.IsNotBlank(fd.lm_tech_con_3_id))
            contactIds.add(fd.lm_tech_con_3_id);
        if (String.IsNotBlank(fd.lm_mkt_con_1_id))
            contactIds.add(fd.lm_mkt_con_1_id);
        if (String.IsNotBlank(fd.lm_mkt_con_2_id))
            contactIds.add(fd.lm_mkt_con_2_id);
        if (String.IsNotBlank(fd.lm_pr_con_id))
            contactIds.add(fd.lm_pr_con_id);
        if (String.IsNotBlank(fd.lm_legal_con_id))
            contactIds.add(fd.lm_legal_con_id);
        if (!contactIds.IsEmpty())
            objectVsIds.put('Contact', new List<String>(contactIds));
        return objectVsIds;
    }

    //Wrapper Class
    public class ContactDetails{
        String FirstName;
        String LastName;
        String Title;
        String Email;
        String Phone;
        String Twitter;
        String GitHub;
        String LinkedIn;
        Boolean Subscribed;
        String ContactId;
        String Role;
        public ContactDetails(String FirstName, String LastName, String Title, String Email, String Phone, String Twitter, String GitHub, String LinkedIn, Boolean Subscribed, String ContactId, String Role){
            this.FirstName = FirstName;
            this.LastName = LastName;
            this.Title = Title;
            this.Email = String.isNotBlank(Email) ? Email.toLowerCase() : '';
            this.Phone = Phone;
            this.Twitter = Twitter;
            this.GitHub = GitHub;
            this.LinkedIn = LinkedIn;
            this.Subscribed = Subscribed;
            this.ContactId = ContactId;
            this.Role = Role;
        }

    }

    public class ContactRolesWrapper{
        String contactId;
        String emailAddress;
        List<String> rolesList;
        List<String> subscribedRolesList;

    }

}