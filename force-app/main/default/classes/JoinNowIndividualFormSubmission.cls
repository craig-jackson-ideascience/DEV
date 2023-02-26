/********************************************************
 * Created by: CloudRoute @ CloudRoute Solutions
 * Created Date: 14/04/20.
 * Update Deatils : 5/14/2020 by Pallavi line 94 added thank email text
 * Description: JoinNowIndividualFormSubmission
 ********************************************************/

@RestResource(urlMapping='/JoinNowIndividualForm/*')
global with sharing class JoinNowIndividualFormSubmission {

    global static Id contactId;
    global static Boolean findOpportunity;
    global static List<JoinNowUtility.EmailAndContactDetails>  emailAndContactDetails = new List<JoinNowUtility.EmailAndContactDetails>();
    global static Set<String> emailsAndContacts = new Set<String>();
    global static string apiId;
    @HttpPost
    global static String processForm() {

        String errorMessage;
        Opportunity opp = new Opportunity();
        Project__c prj;

        findOpportunity = TRUE;

        JoinNowIndividualRequestWrapper fd;

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        Blob requestBodyBlob = request.requestBody;
        String requestBody = requestBodyBlob.toString();
        System.debug('requestBody: ' + requestBody);


        apiId = APIRequestLog.createApiRequestLog(requestBody, 'Join Now Individual Form');
        System.debug('apiId: ' + apiId);

        try {
            fd = (JoinNowIndividualRequestWrapper) JSON.deserialize(requestBody, JoinNowIndividualRequestWrapper.class);
            if(String.isNotBlank(fd.pm_primary_con_emailParam)){
                fd.pm_primary_con_emailParam = fd.pm_primary_con_emailParam.toLowerCase();
            }

            prj = [Select Id, Name, Website__c, Internal_New_Individual_Opportuntiy__c,External_Submission_Notification__c  From Project__c Where Id = :fd.pm_project];
            System.debug('prj: ' + prj);


            Account acc = getAccountDetails(fd);
            acc = [SELECT Id, Name, Phone, IsPersonAccount FROM Account Where Id = :acc.Id];

            opp = upsertOpportunity(fd, acc, findOpportunity);
            JoinNowUtility.upsertAccountAndProject(acc.Id, prj.Id, fd.category);

        } catch (exception e) {
            System.debug('Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
            errorMessage = 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber();
            APIRequestLog.updateApiRequestLog(apiId, 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
        }

        try {
            string Body = 'Hi there, <br/> <br/> We have a new submission from Join Now form for Individual Membership. <br/> Please find below details of the submission<br/><br/>';
            requestBody = requestBody.replaceAll('":"', ' : ');
            requestBody = requestBody.replaceAll('","', '<br>');
            requestBody = requestBody.replaceAll('":false,"', ': false <br>');
            requestBody = requestBody.replaceAll('":true,"', ': true <br>');
            requestBody = requestBody.replace('{"', '<br>');
            requestBody = requestBody.replace('"}', '<br>');
            Body += requestBody;
            Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = label.JoinNow_Form_Submission_Recipients.split(';');
            mail.setToAddresses(toAddresses);
            mail.setOrgWideEmailAddressId(orgWideEmailAddress);
            mail.setSubject('Join Now Individual Form Submission');

            if (errorMessage != null && errorMessage != '') {
                Body += '<br/> <br/> ' + errorMessage;

                List<Opportunity> opps = [Select Id, Owner.Email FROM Opportunity Where Id = :opp.Id];
                if (!opps.IsEmpty()) {
                    toAddresses.add(opps[0].Owner.Email);
                }
                mail.setSubject('Join Now Individual Form Submission [Failed]');
            }


            mail.setHtmlBody(Body);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });


            //Email for Authorized Signatory
            if (contactId != null && opp.Id != null) {
                if (String.isNotBlank(fd.pm_primary_con_fname)) {
                    String subject = 'New Membership Application: '+prj.Name ;
                    //External_Submission_Notification__c
                    
                    String htmlBody = '';
                    //Internal_New_Individual_Opportuntiy__c
                    if(prj.External_Submission_Notification__c != NULL) {
                        htmlBody = prj.External_Submission_Notification__c;
                    }else{
                        htmlBody = Label.Join_Now_Form_Submission_Mail;
                    }
                    htmlBody = htmlBody.replace('[UserFirstName]',fd.pm_primary_con_fname).replace('[ProjectName]',prj.Name);
                    htmlBody = htmlBody.replace('[ProjectURL]','<ul><li>'+prj.Website__c+'</li></ul>');
                   
                    List<string> toAddress = new List<string>();
                    toAddress.add(fd.pm_primary_con_emailParam);

                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(toAddress);
                    email.setOrgWideEmailAddressId(orgWideEmailAddress);
                    email.setHtmlBody(htmlBody);
                    email.setSubject(subject);
                    email.setWhatId(opp.Id);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                }
            }


            //Email for Opportunity Owner
            if (opp.Id != null) {
                System.debug('sending email to owner ');
                Opportunity oppt = [Select Id, Name, Owner.Email,Billing_Contact__r.Name,Opportunity_Link__c, Owner.FirstName, Owner.LastName, Account.Name, (SELECT Name, Project__c, UnitPrice, Membership_Tier__c, Membership__c FROM OpportunityLineItems) from Opportunity where Id = :opp.Id];

                String subject = 'New Membership Application from ' + oppt.Billing_Contact__r.Name + ': ' + prj.Name;

                String htmlBody = '';
                String opprunityLink = '<a href="'+oppt.Opportunity_Link__c+'">'+oppt.Name+'</a>';
                if(prj.Internal_New_Individual_Opportuntiy__c != NULL && prj.Internal_New_Individual_Opportuntiy__c != ''){
                    htmlBody = prj.Internal_New_Individual_Opportuntiy__c;
                }
                else{
                    htmlBody = Label.JoinNowIndividual_OpportunityOwnerMail;
                }
                htmlBody = htmlBody.replace('[OpportunityOwnerFirstName]', oppt.Owner.FirstName).replace('[OpportunityName]',oppt.Name);
                String productDetails = '';
                if(!(oppt.OpportunityLineItems).isEmpty()) {
                    for(OpportunityLineItem oli : oppt.OpportunityLineItems) {
                        productDetails += oli.Project__c +' - '+oli.Membership__c;
                    }
                }
                htmlBody = htmlBody.replace('[MembershipDetails]', productDetails).replace('[OpportunityBillingContact]', oppt.Billing_Contact__r.Name).replace('[OpportunityLink]', opprunityLink);

                List<string> toAddress = new List<string>();

                toAddress.add(oppt.Owner.Email);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(toAddress);
                email.setOrgWideEmailAddressId(orgWideEmailAddress);
                email.setSubject(subject);
                email.setHtmlBody(htmlBody);
                email.setWhatId(opp.Id);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            }

        } catch (exception e) {
            System.debug('Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString() + ' and Cause: ' + e.getCause());
            errorMessage = 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString();
            APIRequestLog.updateApiRequestLog(apiId, 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
        }

        if (String.isNotBlank(errorMessage)) {
            requestBody = errorMessage + '<br/>' + requestBody;
        }

        return requestBody;
    }

    public static Account getAccountDetails(JoinNowIndividualRequestWrapper fd) {
        Account acc;
        getEmailAndContactDetails(fd);
        JoinNowUtility.getContacts(emailsAndContacts, Label.JoinNowIndividual_DefaultAccount);

        if(!emailAndContactDetails.isEmpty()) {
            JoinNowUtility.mergeDuplicateContacts(emailAndContactDetails);
        }

        if (String.IsNotBlank(fd.pm_primary_con_id)) {
            acc = updateContactIfExist(fd);
        }

        if (acc == null && String.isNotBlank(fd.pm_primary_con_emailParam)) {
            Boolean  leadRecord = false;
            System.debug('Contact ***'+JoinNowUtility.emailVsContact);
            System.debug('AltEmail ***'+JoinNowUtility.emailVsAltEmail);
            System.debug('EMail Param ***'+fd.pm_primary_con_emailParam);
            if(JoinNowUtility.emailVsContact.containsKey(fd.pm_primary_con_emailParam) || JoinNowUtility.emailVsAltEmail.containsKey(fd.pm_primary_con_emailParam)) {
                if(JoinNowUtility.emailVsAltEmail.containsKey(fd.pm_primary_con_emailParam) && JoinNowUtility.emailVsAltEmail.get(fd.pm_primary_con_emailParam) != NULL) {
                    Alternate_Email__c altEmail = JoinNowUtility.emailVsAltEmail.get(fd.pm_primary_con_emailParam);
                    if(altEmail.Contact_Name__c == null) {
                        leadRecord = TRUE;
                    }
                    if(altEmail.Contact_Name__c != null) {
                        acc = new Account();
                        acc.ID = checkIfPersonAccount(fd, altEmail.Contact_Name__r.Account.IsPersonAccount, altEmail.Contact_Name__c, altEmail.Contact_Name__r.AccountId);
                        updateContact(fd, altEmail.Contact_Name__c);
                    }
                    
                }

                if((leadRecord && JoinNowUtility.emailVsContact.containsKey(fd.pm_primary_con_emailParam) && JoinNowUtility.emailVsContact.get(fd.pm_primary_con_emailParam) != NULL) ||  
                    (JoinNowUtility.emailVsContact.containsKey(fd.pm_primary_con_emailParam) && JoinNowUtility.emailVsContact.get(fd.pm_primary_con_emailParam) != NULL)){
                    acc = new Account();
                    Contact con = JoinNowUtility.emailVsContact.get(fd.pm_primary_con_emailParam);
                    acc.Id = con.AccountID;
                    updateContact(fd, con.ID);
                }   
            }
            else {
                acc = createContact(fd, true);
            }

        }

        return acc;
    }

    public static Account updateContactIfExist(JoinNowIndividualRequestWrapper fd) {
        Account acc;
        Boolean isPersonAccount = False;
        String conID;

        String actualAccount;
        Boolean contactExist = FALSE;

        if(JoinNowUtility.emailVsAltEmail.containsKey(fd.pm_primary_con_id)) {
            contactExist = TRUE;
            Alternate_Email__c altEmail = JoinNowUtility.emailVsAltEmail.get(fd.pm_primary_con_id);
            isPersonAccount = altEmail.Contact_Name__r.Account.IsPersonAccount;
            conID = altEmail.Contact_Name__c;
            actualAccount = altEmail.Contact_Name__r.AccountID;
            System.debug('Contact With Alt Email --->'+altEmail);
        }
        else if(JoinNowUtility.emailVsContact.containsKey(fd.pm_primary_con_id)) {
            contactExist = TRUE;
            Contact conRec = JoinNowUtility.emailVsContact.get(fd.pm_primary_con_id);
            isPersonAccount = conRec.Account.IsPersonAccount;
            conID = conRec.ID;
            actualAccount = conRec.AccountID;
            System.debug('Contact Without Alt Email --->'+conRec);
        }

        if(contactExist) {
            acc = new Account();
            acc.ID = checkIfPersonAccount(fd, isPersonAccount, conID, actualAccount);
            updateContact(fd, conID);
        }
        return acc;
    }

    public static ID checkIfPersonAccount(JoinNowIndividualRequestWrapper fd,Boolean isPersonAccount, String conID, String actualAccount) {
        ID recId;
        String defaultAccount = Label.JoinNowIndividual_DefaultAccount;
        Boolean deleteAccount = true;
        if ((!isPersonAccount) || (isPersonAccount && !JoinNowUtility.checkForPersonAccount(conID, deleteAccount, defaultAccount))) {
            recId = actualAccount;
        } else {
            recId = defaultAccount;
        }
        return recId;
    }

    public static Account createContact(JoinNowIndividualRequestWrapper fd, Boolean brandNewEmail) {
        Account acc = new Account();
        acc.Id = Label.JoinNowIndividual_DefaultAccount;

        Id personAccountRecordTypeId = [Select Id, Name, DeveloperName From RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id;

        Contact con = new Contact();
        con.FirstName = fd.pm_primary_con_fname;
        con.LastName = fd.pm_primary_con_lname;
        con.Title = fd.pm_primary_con_title;
        con.Email = fd.pm_primary_con_emailParam;
        con.Phone = fd.pm_primary_con_phone;
        con.Twitter_ID__c = fd.pm_primary_con_twitter;
        con.GitHub_ID__c = fd.pm_primary_con_github;
        con.LinkedIn_ID__c = fd.pm_primary_con_linkedIn;
        con.AccountId = Acc.Id;
        /*Updated On 28th Oct 2020 By Priyesh @CloudRoute to truncate the address fields based on field limit*/
        con.MailingStreet = fd.pm_primary_con_street?.left(255);
        con.MailingCity = fd.pm_primary_con_city?.left(40);
        con.MailingState = fd.pm_primary_con_state?.left(80);
        con.MailingCountry = fd.pm_primary_con_country?.left(80);
        con.MailingPostalCode = fd.pm_primary_con_postalCode?.left(20);
        if(brandNewEmail) {
            con.LeadSource = 'Join Us Form';
            con.Lead_Source_Detail1__c = 'Other';
        }
        upsert con;

        contactId = con.Id;
        findOpportunity = False;

        return acc;
    }

    public static void updateContact(JoinNowIndividualRequestWrapper fd, Id contId) {
        contactId = contId;
        Contact con = [
                SELECT Id, FirstName, LastName, Email, Title, Phone, Twitter_ID__c, GitHub_ID__c, LinkedIn_ID__c,
                        MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode
                FROM Contact
                WHERE Id = :contId
        ];

        Boolean updateContact = False;

        if (String.isNotBlank(fd.pm_primary_con_fname) && con.FirstName != fd.pm_primary_con_fname) {
            con.FirstName = fd.pm_primary_con_fname;
            updateContact = True;
        }

        if (String.isNotBlank(fd.pm_primary_con_lname) && con.LastName != fd.pm_primary_con_lname) {
            con.LastName = fd.pm_primary_con_lname;
            updateContact = True;
        }

        if (String.isNotBlank(fd.pm_primary_con_emailParam) && con.Email != fd.pm_primary_con_emailParam) {
            con.Email = fd.pm_primary_con_emailParam;
            updateContact = True;
        }

        if (String.isNotBlank(fd.pm_primary_con_title) && con.Title != fd.pm_primary_con_title) {
            con.Title = fd.pm_primary_con_title;
            updateContact = True;
        }

        if (String.isNotBlank(fd.pm_primary_con_phone) && con.Phone != fd.pm_primary_con_phone) {
            con.Phone = fd.pm_primary_con_phone;
            updateContact = True;
        }

        if (String.isNotBlank(fd.pm_primary_con_twitter) && con.Twitter_ID__c != fd.pm_primary_con_twitter) {
            con.Twitter_ID__c = fd.pm_primary_con_twitter;
            updateContact = True;
        }

        if (String.isNotBlank(fd.pm_primary_con_github) && con.GitHub_ID__c != fd.pm_primary_con_github) {
            con.GitHub_ID__c = fd.pm_primary_con_github;
            updateContact = True;
        }

        if (String.isNotBlank(fd.pm_primary_con_linkedIn) && con.LinkedIn_ID__c != fd.pm_primary_con_linkedIn) {
            con.LinkedIn_ID__c = fd.pm_primary_con_linkedIn;
            updateContact = True;
        }

        if ((String.isNotBlank(fd.pm_primary_con_street) && con.MailingStreet != fd.pm_primary_con_street)
                || (String.isNotBlank(fd.pm_primary_con_city) && con.MailingCity != fd.pm_primary_con_city)
                || (String.isNotBlank(fd.pm_primary_con_state) && con.MailingState != fd.pm_primary_con_state)
                || (String.isNotBlank(fd.pm_primary_con_country) && con.MailingCountry != fd.pm_primary_con_country)
                || (String.isNotBlank(fd.pm_primary_con_postalCode) && con.MailingPostalCode != fd.pm_primary_con_postalCode)) {
            /*Updated On 28th Oct 2020 By Priyesh @CloudRoute to truncate the address fields based on field limit*/
            con.MailingStreet = fd.pm_primary_con_street?.left(255);
            con.MailingCity = fd.pm_primary_con_city?.left(40);
            con.MailingState = fd.pm_primary_con_state?.left(80);
            con.MailingCountry = fd.pm_primary_con_country?.left(80);
            con.MailingPostalCode = fd.pm_primary_con_postalCode?.left(20);
            updateContact = True;
        }

        System.debug('con: ' + con);
        System.debug('updateContact: ' + updateContact);
        if (updateContact) {
            update con;
        }

    }

    public static opportunity upsertOpportunity(JoinNowIndividualRequestWrapper fd, Account acc, Boolean findOpp) {
        Product_Details__c[] pds = [SELECT Id, Project__c, Project__r.Name, Project__r.OwnerId, Project__r.Opportunity_Owner__c, Products__c, Products__r.Name, Price__c FROM Product_Details__c WHERE Id = :fd.pm_product_detail];
        Opportunity opp = new Opportunity();
        List<String> individualMembesrhipsProcuts = Label.JoinNowIndividualProduct.split(',');
        Boolean individualOpportunity;
        if(!individualMembesrhipsProcuts.contains(fd.pm_product_detail)){
            individualOpportunity = TRUE;
        }
        else {
            individualOpportunity = FALSE;
        }

        if (!pds.IsEmpty()) {
            Product_Details__c pd = pds[0];
            String productName = pds[0].Products__r.Name;
            /*Added On 28th Oct 2020 By Priyesh @CloudRoute to truncate the Opportunity Name based on field limit*/
            String OppName = '';
            String conName = fd.pm_primary_con_fname + ' ' + fd.pm_primary_con_lname;
            //Id OppOwner; This will be handled via trigger

            if (pd.Project__c != null && pd.Project__r.Name != null && pd.Project__r.Name != '') {
                OppName = pd.Project__r.Name + ' ';
                //OppOwner = pd.Project__r.Opportunity_Owner__c != null ? pd.Project__r.Opportunity_Owner__c : pd.Project__r.OwnerId;
            }
            if (pd.Products__c != null && pd.Products__r.Name != null && pd.Products__r.Name != '') {
                OppName += pd.Products__r.Name;
            }
            OppName = OppName.trim();
            System.debug('OppName: ' + OppName);

            Boolean opportunityFound = False;
            Boolean contactRoleExist = False;
            OpportunityLineItem oppLine;

            System.debug('findOpp: ' + findOpp);
            System.debug('acc.Id: ' + acc.Id);
            System.debug('pd.Project__c: ' + pd.Project__c);

            if (findOpp) {
                //Logic for Finding opportunity
                string oppLineQuery = ' Select Id, OpportunityId, Opportunity.OwnerId, Opportunity.Owner.Email, Product2Id, Opportunity.Billing_Contact__c ' +
                        ' From OpportunityLineItem ' +
                        ' WHERE Opportunity.IsClosed = FALSE AND Product2.Name =: productName' +
                        ' AND Projects__c = \'' + pd.Project__c + '\' AND Opportunity.Billing_Contact__c = :contactId  AND  opportunity.Individual__c =: individualOpportunity';

                if (acc.IsPersonAccount) {
                    oppLineQuery += ' AND Opportunity.AccountId = \'' + acc.Id + '\'';
                }

                oppLineQuery += ' LIMIT 1 ';

                System.debug('oppLineQuery: ' + oppLineQuery);

                OpportunityLineItem[] openOppLine = (List<OpportunityLineItem>) Database.query(oppLineQuery);

                System.debug('openOppLine: ' + openOppLine);

                if (!openOppLine.isEmpty()) {
                    System.debug('Inside if ');
                    oppLine = openOppLine[0];
                    opportunityFound = True;

                } else {
                    System.debug('Inside else ');
                    String oppQuery = ' SELECT Id, Name, ( ' +
                            ' SELECT Id, OpportunityId, Opportunity.OwnerId, Opportunity.Owner.Email, Product2Id, Opportunity.Billing_Contact__c ' +
                            ' FROM OpportunityLineItems ' +
                            ' WHERE Product2.Name =: productName AND Projects__c = \'' + pd.Project__c + '\'' +
                            ' ) ' +
                            ' FROM Opportunity ' +
                            ' WHERE IsClosed = FALSE AND  Individual__c =: individualOpportunity' +
                            ' AND ID IN (SELECT OpportunityId FROM OpportunityContactRole WHERE (Role = \'Membership Decision Maker\' OR Role = \'\') AND ContactId = :contactId) ';

                    if (acc.IsPersonAccount) {
                        oppQuery += ' AND AccountId = \'' + acc.Id + '\'';
                    }

                System.debug('oppQuery: ' + oppQuery);

                    Opportunity[] opps = (List<Opportunity>) Database.query(oppQuery);

                    System.debug('opps: ' + opps);

                    if (!opps.isEmpty() && opps[0].OpportunityLineItems.size() == 1) {
                        oppLine = opps[0].OpportunityLineItems[0];
                        opportunityFound = True;
                        contactRoleExist = True;
                    }

                }

            }

            System.debug('opportunityFound: ' + opportunityFound);

            /*Added On 28th Oct 2020 By Priyesh @CloudRoute to truncate the Opportunity Name based on field limit*/
            if(OppName.length() < 120){
                if((conName + OppName).length() > 120) {
                    OppName = conName.substring(0, 119 - OppName.length()) + ' ' + OppName;
                }else{
                    OppName = conName + ' ' + OppName;
                }
            }else{
                OppName = (conName + ' ' + OppName).substring(0, 120);
            }

            opp.Name = OppName;
            opp.StageName = '5. Decision Commitment';
            opp.JoinNow_Update__c = Date.today();
            opp.Billing_Contact__c = contactId;

            if(!individualMembesrhipsProcuts.contains(fd.pm_product_detail)){
                opp.Individual__c = TRUE;
            }

            if (opportunityFound) {
                opp.Id = oppLine.OpportunityId;
            } else {
                opp.AccountId = acc.Id;
                opp.CloseDate = Date.today().addMonths(1);
                opp.Pricebook2Id = Label.JoinNow_Opportunity_Pricebook;
                opp.RecordTypeId = Label.JoinNow_Opportunity_RecordTypeId;
            }
            Upsert opp;

            //if (opportunityFound) {
                Boolean upsertOCR = FALSE;
                OpportunityContactRole[] ocrs = [Select Id, IsPrimary, Role FROM OpportunityContactRole WHERE ContactId = :contactId AND OpportunityId = :opp.Id AND (Role = '' OR Role = 'Membership Decision Maker')];

                OpportunityContactRole ocr = new OpportunityContactRole();
                ocr.OpportunityId = opp.Id;
                ocr.ContactId = contactId;

                if(ocrs.isEmpty() || (!ocrs.isEmpty() && ( String.isBlank(ocrs[0].Role) || !ocrs[0].IsPrimary))){
                    ocr.Role = 'Membership Decision Maker';
                    ocr.IsPrimary = TRUE;
                    upsertOCR = TRUE;

                    if(!ocrs.isEmpty() && ( String.isBlank(ocrs[0].Role) || !ocrs[0].IsPrimary)){
                        ocr.Id = ocrs[0].Id;
                    }
                }

                System.debug('ocr: ' + ocr);
                if (upsertOCR) {
                    upsert ocr;
                }
            //}

            OpportunityLineItem oli = new OpportunityLineItem();

            if (opportunityFound) {
                oli = oppLine;
            } else{
                oli.OpportunityId = opp.Id;
                oli.Product2Id = pd.Products__c;
            }

            oli.Projects__c = pd.Project__c;
            oli.Project__c = pd.Project__r.Name;
            oli.Product_Details__c = pd.Id;
            oli.Start_Date__c = Date.today().day() < 15 ? Date.today().tostartofmonth() : Date.today().addmonths(1).tostartofmonth();
            oli.Quantity = 1;
            oli.UnitPrice = pd.Price__c;
            upsert oli;
            
            OpportunityLineItem oliRec = [Select ID,End_Date__c,Start_Date__c,OpportunityId from OpportunityLineItem where ID =: oli.ID LIMIT 1];
            system.debug('Oli Rec ***'+oliRec);
            List<Project_Role__c> listOfPrjRoles = new List<Project_Role__c>();
            Boolean createBrandNew = FALSE;
            if(opportunityFound) {
                List<Project_Role__c> existingProjectRoles = [SELECT Id, Contact__c, Role__c, Status__c, Opportunity__c, Opportunity_Line_Item__c, Start_Date__c, End_Date__c FROM Project_Role__c WHERE Opportunity__c =: oli.OpportunityId AND Contact__c =: contactId];
                if(!existingProjectRoles.isEmpty()) {
                    Boolean billingRole = FALSE;
                    Boolean authRole = FALSE; 
                    Boolean votingRole = FALSE;
                    for(Project_Role__c prjRole : existingProjectRoles) {
                        if(prjRole.Role__c == 'Billing Contact') {
                            billingRole = TRUE;
                        }
                        if(prjRole.Role__c == 'Authorized Signatory') {
                            authRole = TRUE;    
                        }
                        if(prjRole.Role__c == 'Representative/Voting Contact') {
                            votingRole = TRUE;
                        }
                        

                        if((billingRole || authRole || votingRole) && (prjRole.Status__c != 'Active' || prjRole.Opportunity_Line_Item__c == NULL || prjRole.Opportunity_Line_Item__c != oliRec.ID || prjRole.Start_Date__c != oliRec.Start_Date__c || prjRole.End_Date__c != oliRec.End_Date__c)) {
                            prjRole.Status__c = 'Active';
                            prjRole.Opportunity_Line_Item__c = oliRec.ID;
                            prjRole.Start_Date__c = oliRec.Start_Date__c;
                            prjRole.End_Date__c = oliRec.End_Date__c;
                            listOfPrjRoles.add(prjRole);
                        }
                    }

                    if(!billingRole) {
                      listOfPrjRoles.add(getProjectRole('Billing Contact', contactId, oliRec));
                    }
                    if(!authRole){
                      listOfPrjRoles.add(getProjectRole('Authorized Signatory', contactId, oliRec));
                    }   
                    if(!votingRole){
                        listOfPrjRoles.add(getProjectRole('Representative/Voting Contact', contactId, oliRec));
                    }
                }
                else {
                    createBrandNew = True;
                }
            }
            
            if((opportunityFound && createBrandNew) || (!opportunityFound)){
                listOfPrjRoles.add(getProjectRole('Billing Contact', contactId, oliRec));
                listOfPrjRoles.add(getProjectRole('Authorized Signatory', contactId, oliRec));
                listOfPrjRoles.add(getProjectRole('Representative/Voting Contact', contactId, oliRec));
            }
            
            if(!listOfPrjRoles.isEmpty()) {
                upsert listOfPrjRoles;
            }
        }
        return opp;
    }

    public static void getEmailAndContactDetails(JoinNowIndividualRequestWrapper fd) {
        if(String.isNotBlank(fd.pm_primary_con_emailParam) && String.isNotBlank(fd.pm_primary_con_id)) {
            emailAndContactDetails.add(new JoinNowUtility.EmailAndContactDetails(fd.pm_primary_con_emailParam, Null, Null, Null, fd.pm_primary_con_id, Null, NULL));
        }

        if(String.isNotBlank(fd.pm_primary_con_emailParam)) {
            emailsAndContacts.add(fd.pm_primary_con_emailParam.toLowerCase());
        }

        if(String.isNotBlank(fd.pm_primary_con_id)) {
            emailsAndContacts.add((ID)fd.pm_primary_con_id);
        }
    }

    public static Project_Role__c getProjectRole(String role, ID conId, OpportunityLineItem oli) {
      Project_Role__c projectRole = new Project_Role__c(); 
      projectRole.Contact__c = conId;
      projectRole.Role__c = role;
      projectRole.Start_Date__c = oli.Start_Date__c;
      projectRole.End_Date__c = oli.End_Date__c;
      projectRole.PrimaryContact__c = True;
      projectRole.Opportunity_Line_Item__c = oli.Id;
      projectRole.Opportunity__c = oli.OpportunityId;  
      return projectRole;
    }


}