@RestResource(urlMapping='/RenewalForm/*')
global class RenewalFormSubmission {

    @HttpPost
    global static String processForm() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Blob requestBodyBlob = req.requestBody;
        String requestBody = requestBodyBlob.toString();
        System.debug('Request Body: ' + requestBody);

        Map<String, Object> formMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        System.debug('formMap: ' + formMap);

        /************************ Variables from Form Submissions Start *******************************/

        String oppId = (String) formMap.get('oppId');
        String oliId = (String) formMap.get('oliId');

        Boolean po_required = formMap.containsKey('po_required') ? boolean.valueOf((String) formMap.get('po_required') == 'on' ? 'true' : 'false') : false;

        String voting_con_fname = (String) formMap.get('voting_con_fname');
        String voting_con_lname = (String) formMap.get('voting_con_lname');
        String voting_con_email = (String) formMap.get('voting_con_email');
        String voting_con_title = (String) formMap.get('voting_con_title');
        String voting_con_twitter = (String) formMap.get('voting_con_twitter');
        String voting_con_github = (String) formMap.get('voting_con_github');
        String voting_con_linkedin = (String) formMap.get('voting_con_linkedin');

        String legal_con_fname = (String) formMap.get('legal_con_fname');
        String legal_con_lname = (String) formMap.get('legal_con_lname');
        String legal_con_email = (String) formMap.get('legal_con_email');
        String legal_con_title = (String) formMap.get('legal_con_title');
        String legal_con_twitter = (String) formMap.get('legal_con_twitter');
        String legal_con_github = (String) formMap.get('legal_con_github');
        String legal_con_linkedin = (String) formMap.get('legal_con_linkedin');

        String pr_con_fname = (String) formMap.get('pr_con_fname');
        String pr_con_lname = (String) formMap.get('pr_con_lname');
        String pr_con_email = (String) formMap.get('pr_con_email');
        String pr_con_title = (String) formMap.get('pr_con_title');
        String pr_con_twitter = (String) formMap.get('pr_con_twitter');
        String pr_con_github = (String) formMap.get('pr_con_github');
        String pr_con_linkedin = (String) formMap.get('pr_con_linkedin');

        String billing_con_1_fname = (String) formMap.get('billing_con_1_fname');
        String billing_con_1_lname = (String) formMap.get('billing_con_1_lname');
        String billing_con_1_email = (String) formMap.get('billing_con_1_email');
        String billing_con_1_title = (String) formMap.get('billing_con_1_title');
        String billing_con_1_twitter = (String) formMap.get('billing_con_1_twitter');
        String billing_con_1_github = (String) formMap.get('billing_con_1_github');
        String billing_con_1_linkedin = (String) formMap.get('billing_con_1_linkedin');

        String billing_con_2_fname = (String) formMap.get('billing_con_2_fname');
        String billing_con_2_lname = (String) formMap.get('billing_con_2_lname');
        String billing_con_2_email = (String) formMap.get('billing_con_2_email');
        String billing_con_2_title = (String) formMap.get('billing_con_2_title');
        String billing_con_2_twitter = (String) formMap.get('billing_con_2_twitter');
        String billing_con_2_github = (String) formMap.get('billing_con_2_github');
        String billing_con_2_linkedin = (String) formMap.get('billing_con_2_linkedin');

        String billing_con_3_fname = (String) formMap.get('billing_con_3_fname');
        String billing_con_3_lname = (String) formMap.get('billing_con_3_lname');
        String billing_con_3_email = (String) formMap.get('billing_con_3_email');
        String billing_con_3_title = (String) formMap.get('billing_con_3_title');
        String billing_con_3_twitter = (String) formMap.get('billing_con_3_twitter');
        String billing_con_3_github = (String) formMap.get('billing_con_3_github');
        String billing_con_3_linkedin = (String) formMap.get('billing_con_3_linkedin');

        String mkt_con_1_fname = (String) formMap.get('mkt_con_1_fname');
        String mkt_con_1_lname = (String) formMap.get('mkt_con_1_lname');
        String mkt_con_1_email = (String) formMap.get('mkt_con_1_email');
        String mkt_con_1_title = (String) formMap.get('mkt_con_1_title');
        String mkt_con_1_twitter = (String) formMap.get('mkt_con_1_twitter');
        String mkt_con_1_github = (String) formMap.get('mkt_con_1_github');
        String mkt_con_1_linkedin = (String) formMap.get('mkt_con_1_linkedin');

        String mkt_con_2_fname = (String) formMap.get('mkt_con_2_fname');
        String mkt_con_2_lname = (String) formMap.get('mkt_con_2_lname');
        String mkt_con_2_email = (String) formMap.get('mkt_con_2_email');
        String mkt_con_2_title = (String) formMap.get('mkt_con_2_title');
        String mkt_con_2_twitter = (String) formMap.get('mkt_con_2_twitter');
        String mkt_con_2_github = (String) formMap.get('mkt_con_2_github');
        String mkt_con_2_linkedin = (String) formMap.get('mkt_con_2_linkedin');

        String mkt_con_3_fname = (String) formMap.get('mkt_con_3_fname');
        String mkt_con_3_lname = (String) formMap.get('mkt_con_3_lname');
        String mkt_con_3_email = (String) formMap.get('mkt_con_3_email');
        String mkt_con_3_title = (String) formMap.get('mkt_con_3_title');
        String mkt_con_3_twitter = (String) formMap.get('mkt_con_3_twitter');
        String mkt_con_3_github = (String) formMap.get('mkt_con_3_github');
        String mkt_con_3_linkedin = (String) formMap.get('mkt_con_3_linkedin');

        String tech_con_1_fname = (String) formMap.get('tech_con_1_fname');
        String tech_con_1_lname = (String) formMap.get('tech_con_1_lname');
        String tech_con_1_email = (String) formMap.get('tech_con_1_email');
        String tech_con_1_title = (String) formMap.get('tech_con_1_title');
        String tech_con_1_twitter = (String) formMap.get('tech_con_1_twitter');
        String tech_con_1_github = (String) formMap.get('tech_con_1_github');
        String tech_con_1_linkedin = (String) formMap.get('tech_con_1_linkedin');

        String tech_con_2_fname = (String) formMap.get('tech_con_2_fname');
        String tech_con_2_lname = (String) formMap.get('tech_con_2_lname');
        String tech_con_2_email = (String) formMap.get('tech_con_2_email');
        String tech_con_2_title = (String) formMap.get('tech_con_2_title');
        String tech_con_2_twitter = (String) formMap.get('tech_con_2_twitter');
        String tech_con_2_github = (String) formMap.get('tech_con_2_github');
        String tech_con_2_linkedin = (String) formMap.get('tech_con_2_linkedin');

        String tech_con_3_fname = (String) formMap.get('tech_con_3_fname');
        String tech_con_3_lname = (String) formMap.get('tech_con_3_lname');
        String tech_con_3_email = (String) formMap.get('tech_con_3_email');
        String tech_con_3_title = (String) formMap.get('tech_con_3_title');
        String tech_con_3_twitter = (String) formMap.get('tech_con_3_twitter');
        String tech_con_3_github = (String) formMap.get('tech_con_3_github');
        String tech_con_3_linkedin = (String) formMap.get('tech_con_3_linkedin');

        /************************ Variables from Form Submissions End *******************************/


        //Check if the data is received
        System.debug('voting_con_fname: ' + voting_con_fname);
        System.debug('voting_con_lname: ' + voting_con_lname);
        System.debug('voting_con_email: ' + voting_con_email);

        System.debug('legal_con_fname: ' + legal_con_fname);
        System.debug('legal_con_lname: ' + legal_con_lname);
        System.debug('legal_con_email: ' + legal_con_email);

        System.debug('pr_con_fname: ' + pr_con_fname);
        System.debug('pr_con_lname: ' + pr_con_lname);
        System.debug('pr_con_email: ' + pr_con_email);

        System.debug('billing_con_1_fname: ' + billing_con_1_fname);
        System.debug('billing_con_1_lname: ' + billing_con_1_lname);
        System.debug('billing_con_1_email: ' + billing_con_1_email);

        System.debug('billing_con_2_fname: ' + billing_con_2_fname);
        System.debug('billing_con_2_lname: ' + billing_con_2_lname);
        System.debug('billing_con_2_email: ' + billing_con_2_email);

        System.debug('billing_con_3_fname: ' + billing_con_3_fname);
        System.debug('billing_con_3_lname: ' + billing_con_3_lname);
        System.debug('billing_con_3_email: ' + billing_con_3_email);

        System.debug('mkt_con_1_fname: ' + mkt_con_1_fname);
        System.debug('mkt_con_1_lname: ' + mkt_con_1_lname);
        System.debug('mkt_con_1_email: ' + mkt_con_1_email);

        System.debug('mkt_con_2_fname: ' + mkt_con_2_fname);
        System.debug('mkt_con_2_lname: ' + mkt_con_2_lname);
        System.debug('mkt_con_2_email: ' + mkt_con_2_email);

        System.debug('mkt_con_3_fname: ' + mkt_con_3_fname);
        System.debug('mkt_con_3_lname: ' + mkt_con_3_lname);
        System.debug('mkt_con_3_email: ' + mkt_con_3_email);

        System.debug('tech_con_1_fname: ' + tech_con_1_fname);
        System.debug('tech_con_1_lname: ' + tech_con_1_lname);
        System.debug('tech_con_1_email: ' + tech_con_1_email);

        System.debug('tech_con_2_fname: ' + tech_con_2_fname);
        System.debug('tech_con_2_lname: ' + tech_con_2_lname);
        System.debug('tech_con_2_email: ' + tech_con_2_email);

        System.debug('tech_con_3_fname: ' + tech_con_3_fname);
        System.debug('tech_con_3_lname: ' + tech_con_3_lname);
        System.debug('tech_con_3_email: ' + tech_con_3_email);

        System.debug('oppId: ' + oppId);
        System.debug('oliId: ' + oliId);

        Id accId;
        String project;

        //oppId = '0062h000002e7YrAAI'; //TODO - Hardcoded for now, otherwise will come from the form submission
        //oliId = '00k2h000003E3GD';

        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        Map<String, ContactDetails> emailVsContactDetails = new Map<String, ContactDetails>();
        Map<String, String> roleVsEmail = new Map<String, String>();

        Map<Id, String> leadToConvertIdVsEmail = new Map<Id, String>();
        Map<String, Id> emailVsContactId = new Map<String, Id>();
        Map<String, Contact> emailVsContactsToUpsert = new Map<String, Contact>();

        //Map<Id, Product_Details__c> productDetailsMap = new Map<Id, Product_Details__c>();

        String errorMessage;

        try {
            //Start checking form contacts one by one and add contacts with unique email Id in to map
            //Add email for each role

            if (voting_con_lname != '' && voting_con_email != '') {
                voting_con_email = voting_con_email.toLowerCase();
                if (!emailVsContactDetails.containsKey(voting_con_email)) {
                    emailVsContactDetails.put(voting_con_email, new ContactDetails(voting_con_fname, voting_con_lname, voting_con_email, voting_con_title, voting_con_twitter, voting_con_github, voting_con_linkedin));
                }
                roleVsEmail.put('voting_con', voting_con_email);
            }


            if (legal_con_lname != '' && legal_con_email != '') {
                legal_con_email = legal_con_email.toLowerCase();
                if (!emailVsContactDetails.containsKey(legal_con_email)) {
                    emailVsContactDetails.put(legal_con_email, new ContactDetails(legal_con_fname, legal_con_lname, legal_con_email, legal_con_title, legal_con_twitter, legal_con_github, legal_con_linkedin));
                }
                roleVsEmail.put('legal_con', legal_con_email);
            }


            if (pr_con_lname != '' && pr_con_email != '') {
                pr_con_email = pr_con_email.toLowerCase();
                if (!emailVsContactDetails.containsKey(pr_con_email)) {
                    emailVsContactDetails.put(pr_con_email, new ContactDetails(pr_con_fname, pr_con_lname, pr_con_email, pr_con_title, pr_con_twitter, pr_con_github, pr_con_linkedin));
                }
                roleVsEmail.put('pr_con', pr_con_email);
            }


            if (billing_con_1_lname != '' && billing_con_1_email != '') {
                billing_con_1_email = billing_con_1_email.toLowerCase();
                if (!emailVsContactDetails.containsKey(billing_con_1_email)) {
                    emailVsContactDetails.put(billing_con_1_email, new ContactDetails(billing_con_1_fname, billing_con_1_lname, billing_con_1_email, billing_con_1_title, billing_con_1_twitter, billing_con_1_github, billing_con_1_linkedin));
                }
                roleVsEmail.put('billing_con_1', billing_con_1_email);
            }


            if (billing_con_2_lname != '' && billing_con_2_email != '') {
                billing_con_2_email = billing_con_2_email.toLowerCase();
                if (!emailVsContactDetails.containsKey(billing_con_2_email)) {
                    emailVsContactDetails.put(billing_con_2_email, new ContactDetails(billing_con_2_fname, billing_con_2_lname, billing_con_2_email, billing_con_2_title, billing_con_2_twitter, billing_con_2_github, billing_con_2_linkedin));
                }
                roleVsEmail.put('billing_con_2', billing_con_2_email);
            }


            if (billing_con_3_lname != '' && billing_con_3_email != '') {
                billing_con_3_email = billing_con_3_email.toLowerCase();
                if (!emailVsContactDetails.containsKey(billing_con_3_email)) {
                    emailVsContactDetails.put(billing_con_3_email, new ContactDetails(billing_con_3_fname, billing_con_3_lname, billing_con_3_email, billing_con_3_title, billing_con_3_twitter, billing_con_3_github, billing_con_3_linkedin));
                }
                roleVsEmail.put('billing_con_3', billing_con_3_email);
            }


            if (mkt_con_1_lname != '' && mkt_con_1_email != '') {
                mkt_con_1_email = mkt_con_1_email.toLowerCase();
                if (!emailVsContactDetails.containsKey(mkt_con_1_email)) {
                    emailVsContactDetails.put(mkt_con_1_email, new ContactDetails(mkt_con_1_fname, mkt_con_1_lname, mkt_con_1_email, mkt_con_1_title, mkt_con_1_twitter, mkt_con_1_github, mkt_con_1_linkedin));
                }
                roleVsEmail.put('mkt_con_1', mkt_con_1_email);
            }


            if (mkt_con_2_lname != '' && mkt_con_2_email != '') {
                mkt_con_2_email = mkt_con_2_email.toLowerCase();
                if (!emailVsContactDetails.containsKey(mkt_con_2_email)) {
                    emailVsContactDetails.put(mkt_con_2_email, new ContactDetails(mkt_con_2_fname, mkt_con_2_lname, mkt_con_2_email, mkt_con_2_title, mkt_con_2_twitter, mkt_con_2_github, mkt_con_2_linkedin));
                }
                roleVsEmail.put('mkt_con_2', mkt_con_2_email);
            }


            if (mkt_con_3_lname != '' && mkt_con_3_email != '') {
                mkt_con_3_email = mkt_con_3_email.toLowerCase();
                if (!emailVsContactDetails.containsKey(mkt_con_3_email)) {
                    emailVsContactDetails.put(mkt_con_3_email, new ContactDetails(mkt_con_3_fname, mkt_con_3_lname, mkt_con_3_email, mkt_con_3_title, mkt_con_3_twitter, mkt_con_3_github, mkt_con_3_linkedin));
                }
                roleVsEmail.put('mkt_con_3', mkt_con_3_email);
            }


            if (tech_con_1_lname != '' && tech_con_1_email != '') {
                tech_con_1_email = tech_con_1_email.toLowerCase();
                if (!emailVsContactDetails.containsKey(tech_con_1_email)) {
                    emailVsContactDetails.put(tech_con_1_email, new ContactDetails(tech_con_1_fname, tech_con_1_lname, tech_con_1_email, tech_con_1_title, tech_con_1_twitter, tech_con_1_github, tech_con_1_linkedin));
                }
                roleVsEmail.put('tech_con_1', tech_con_1_email);
            }


            if (tech_con_2_lname != '' && tech_con_2_email != '') {
                tech_con_2_email = tech_con_2_email.toLowerCase();
                if (!emailVsContactDetails.containsKey(tech_con_2_email)) {
                    emailVsContactDetails.put(tech_con_2_email, new ContactDetails(tech_con_2_fname, tech_con_2_lname, tech_con_2_email, tech_con_2_title, tech_con_2_twitter, tech_con_2_github, tech_con_2_linkedin));
                }
                roleVsEmail.put('tech_con_2', tech_con_2_email);
            }


            if (tech_con_3_lname != '' && tech_con_3_email != '') {
                tech_con_3_email = tech_con_3_email.toLowerCase();
                if (!emailVsContactDetails.containsKey(tech_con_3_email)) {
                    emailVsContactDetails.put(tech_con_3_email, new ContactDetails(tech_con_3_fname, tech_con_3_lname, tech_con_3_email, tech_con_3_title, tech_con_3_twitter, tech_con_3_github, tech_con_3_linkedin));
                }
                roleVsEmail.put('tech_con_3', tech_con_3_email);
            }

            System.debug('emailVsContactDetails: ' + emailVsContactDetails);
            System.debug('roleVsEmail: ' + roleVsEmail);

            System.debug('roleVsEmail MAP PRINT: ');
            for (String roleName : roleVsEmail.keyset()) {
                System.debug('#roleName--' + roleName + '---#email--' + roleVsEmail.get(roleName));
            }

            //Find Opportunity and get opp record along with Opportunity Line Items
            List<Opportunity> opps = [
                    SELECT Id, Name, AccountId, (select Id, Name, Projects__c, Project__c, Product_Details__c from OpportunityLineItems WHERE Id = :oliId)
                    FROM Opportunity
                    WHERE Id = :oppId
            ];

            System.debug('#opps:--' + opps);

            if (opps.size() > 0 && opps[0].OpportunityLineItems.size() > 0) {

                accId = opps[0].AccountId;
                project = opps[0].OpportunityLineItems[0].Project__c;

                Map<String, ContactDetails> emailVsContactNotFound = new Map<String, ContactDetails>(emailVsContactDetails);

                List<Alternate_Email__c> altEmails = [SELECT Id, Alternate_Email_Address__c, Contact_Name__c, Contact_Name__r.FirstName, Contact_Name__r.LastName, Contact_Name__r.AccountId, Contact_Name__r.Account.Name, Lead_Name__c, Lead_Name__r.OwnerId FROM Alternate_Email__c WHERE Active__c = TRUE AND Alternate_Email_Address__c IN :emailVsContactDetails.keySet() AND (Contact_Name__c != Null OR Lead_Name__c != Null)];

                for (Alternate_Email__c altEmail : altEmails) {
                    if (altEmail.Contact_Name__c != null) {
                        emailVsContactId.put(altEmail.Alternate_Email_Address__c, altEmail.Contact_Name__c);
                    } else if (altEmail.Contact_Name__c == null && altEmail.Lead_Name__c != null) {
                        Database.LeadConvert lc = new Database.LeadConvert();
                        lc.setAccountId(accId);
                        lc.setLeadId(altEmail.Lead_Name__c);
                        lc.setConvertedStatus(Label.Lead_Converted_Status);
                        lc.setDoNotCreateOpportunity(true);

                        if (string.valueOf(altEmail.Lead_Name__r.OwnerId).startsWith('00G')) {
                            lc.setOwnerId(UserInfo.getUserId());
                        } else {
                            lc.setOwnerId(altEmail.Lead_Name__r.OwnerId);
                        }
                        leadsToConvert.add(lc);
                        leadToConvertIdVsEmail.put(altEmail.Lead_Name__c, altEmail.Alternate_Email_Address__c);
                    }
                    emailVsContactNotFound.remove(altEmail.Alternate_Email_Address__c);
                }

                if (leadsToConvert.size() > 0) {
                    Database.LeadConvertResult[] lcrs = Database.convertLead(leadsToConvert);
                    for (Database.LeadConvertResult lcr : lcrs) {
                        if (lcr.isSuccess()) {
                            emailVsContactId.put(leadToConvertIdVsEmail.get(lcr.getLeadId()), lcr.getContactId());
                        }
                    }
                }

                for (ContactDetails cd : emailVsContactNotFound.values()) {
                    Contact con = new Contact();
                    con.AccountId = accId;
                    con.FirstName = cd.FirstName;
                    con.LastName = cd.LastName;
                    con.Email = cd.Email;
                    con.Title = cd.Title;
                    con.Twitter_ID__c = cd.Twitter;
                    con.GitHub_ID__c = cd.GitHub;
                    con.LinkedIn_ID__c = cd.LinkedIn;
                    emailVsContactsToUpsert.put(cd.Email, con);
                }

                if (emailVsContactsToUpsert.size() > 0) {
                    insert emailVsContactsToUpsert.values();

                    for (Contact con : emailVsContactsToUpsert.values()) {
                        emailVsContactId.put(con.Email, con.Id);
                    }
                }

                System.debug('emailVsContactId: ' + emailVsContactId);


                OpportunityLineItem oli = new OpportunityLineItem();
                oli.Id = oliId;

                //add related contacts

                if (roleVsEmail.containsKey('voting_con') && emailVsContactId.containsKey(roleVsEmail.get('voting_con'))) {
                    oli.Representative_Voting_Contact__c = emailVsContactId.get(roleVsEmail.get('voting_con'));
                }

                if (roleVsEmail.containsKey('pr_con') && emailVsContactId.containsKey(roleVsEmail.get('pr_con'))) {
                    oli.Press_Contact__c = emailVsContactId.get(roleVsEmail.get('pr_con'));
                }

                if (roleVsEmail.containsKey('legal_con') && emailVsContactId.containsKey(roleVsEmail.get('legal_con'))) {
                    oli.Legal_Contact__c = emailVsContactId.get(roleVsEmail.get('legal_con'));
                }

                if (roleVsEmail.containsKey('billing_con_1') && emailVsContactId.containsKey(roleVsEmail.get('billing_con_1'))) {
                    oli.Billing_Contact__c = emailVsContactId.get(roleVsEmail.get('billing_con_1'));
                }

                if (roleVsEmail.containsKey('billing_con_2') && emailVsContactId.containsKey(roleVsEmail.get('billing_con_2'))) {
                    oli.Billing_Contact2__c = emailVsContactId.get(roleVsEmail.get('billing_con_2'));
                }

                if (roleVsEmail.containsKey('billing_con_3') && emailVsContactId.containsKey(roleVsEmail.get('billing_con_3'))) {
                    oli.Billing_Contact3__c = emailVsContactId.get(roleVsEmail.get('billing_con_3'));
                }

                if (roleVsEmail.containsKey('tech_con_1') && emailVsContactId.containsKey(roleVsEmail.get('tech_con_1'))) {
                    oli.Technical_Contact__c = emailVsContactId.get(roleVsEmail.get('tech_con_1'));
                }

                if (roleVsEmail.containsKey('tech_con_2') && emailVsContactId.containsKey(roleVsEmail.get('tech_con_2'))) {
                    oli.Technical_Contact_2__c = emailVsContactId.get(roleVsEmail.get('tech_con_2'));
                }

                if (roleVsEmail.containsKey('tech_con_3') && emailVsContactId.containsKey(roleVsEmail.get('tech_con_3'))) {
                    oli.Technical_Contact_3__c = emailVsContactId.get(roleVsEmail.get('tech_con_3'));
                }

                if (roleVsEmail.containsKey('mkt_con_1') && emailVsContactId.containsKey(roleVsEmail.get('mkt_con_1'))) {
                    oli.Marketing_Contact__c = emailVsContactId.get(roleVsEmail.get('mkt_con_1'));
                }

                if (roleVsEmail.containsKey('mkt_con_2') && emailVsContactId.containsKey(roleVsEmail.get('mkt_con_2'))) {
                    oli.Marketing_Contact_2__c = emailVsContactId.get(roleVsEmail.get('mkt_con_2'));
                }

                if (roleVsEmail.containsKey('mkt_con_3') && emailVsContactId.containsKey(roleVsEmail.get('mkt_con_3'))) {
                    oli.Marketing_Contact_3__c = emailVsContactId.get(roleVsEmail.get('mkt_con_3'));
                }

                update oli;
            }

            Opportunity opp = new Opportunity();
            opp.Id = oppId;
            opp.Opportunity_PO_Required__c = po_required;

            update opp;


        } catch (exception e) {
            System.debug('Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
            errorMessage = 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber();
        }

        string Body = 'Hi there, <br/> <br/> We have a Renewal submission from renewal form. <br/> Please find below details of the submission<br/><br/>';

        System.debug('requestBody: ' + requestBody);

        requestBody = requestBody.replaceAll('" : "', ' : ');
        requestBody = requestBody.replaceAll('", "', '<br>');
        requestBody = requestBody.replace('{"', '<br>');
        requestBody = requestBody.replace('"}', '<br>');

        Body += requestBody;

        if (errorMessage != null && errorMessage != '') {
            Body += '<br/> <br/> ' + errorMessage;
        }

        Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'pratik@cloudroute.in'};
        mail.setOrgWideEmailAddressId(orgWideEmailAddress);
        mail.setToAddresses(toAddresses);
        mail.setSubject('Renewal Form Submission');
        mail.setHtmlBody(Body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });

        String responseBody = '<div>';

        responseBody += 'Thank you for your submission. Your ' + project + ' contacts have been updated.  <br> <br>';

        if((billing_con_1_fname != '' && billing_con_1_email != '') || (billing_con_2_fname != '' && billing_con_2_email != '') || (billing_con_3_fname != '' & billing_con_3_email != '')) {

            responseBody += 'Billing Contacts <br>';

            responseBody += '<br>';

            if (billing_con_1_fname != '' && billing_con_1_email != '') {

                responseBody += billing_con_1_fname + ' ';
                responseBody += billing_con_1_lname + '<br>';
                responseBody += billing_con_1_email + '<br>';
                responseBody += billing_con_1_title + '<br>';
                responseBody += billing_con_1_twitter + '<br>';
                responseBody += billing_con_1_github + '<br>';
                responseBody += billing_con_1_linkedin + '<br>';

                responseBody += '<br>';
            }

            if (billing_con_2_fname != '' && billing_con_2_email != '') {
                responseBody += billing_con_2_fname + ' ';
                responseBody += billing_con_2_lname + '<br>';
                responseBody += billing_con_2_email + '<br>';
                responseBody += billing_con_2_title + '<br>';
                responseBody += billing_con_2_twitter + '<br>';
                responseBody += billing_con_2_github + '<br>';
                responseBody += billing_con_2_linkedin + '<br>';

                responseBody += '<br>';
            }

            if (billing_con_3_fname != '' && billing_con_3_email != '') {
                responseBody += billing_con_3_fname + ' ';
                responseBody += billing_con_3_lname + '<br>';
                responseBody += billing_con_3_email + '<br>';
                responseBody += billing_con_3_title + '<br>';
                responseBody += billing_con_3_twitter + '<br>';
                responseBody += billing_con_3_github + '<br>';
                responseBody += billing_con_3_linkedin + '<br>';

                responseBody += '<br>';
            }

            responseBody += '<br>';
        }

        if(voting_con_fname != '' && voting_con_email != '') {
            responseBody += 'Voting Contact <br>';

            responseBody += '<br>';

            responseBody += voting_con_fname + ' ';
            responseBody += voting_con_lname + '<br>';
            responseBody += voting_con_email + '<br>';
            responseBody += voting_con_title + '<br>';
            responseBody += voting_con_twitter + '<br>';
            responseBody += voting_con_github + '<br>';
            responseBody += voting_con_linkedin + '<br>';

            responseBody += '<br>';
            responseBody += '<br>';
        }

        if((tech_con_1_fname != '' && tech_con_1_email != '') || (tech_con_2_fname != '' && tech_con_2_email != '') || (tech_con_3_fname != '' & tech_con_3_email != '')) {
            responseBody += 'Technical Contacts <br>';

            responseBody += '<br>';

            if(tech_con_1_fname != '' && tech_con_1_email != '') {
                responseBody += tech_con_1_fname + ' ';
                responseBody += tech_con_1_lname + '<br>';
                responseBody += tech_con_1_email + '<br>';
                responseBody += tech_con_1_title + '<br>';
                responseBody += tech_con_1_twitter + '<br>';
                responseBody += tech_con_1_github + '<br>';
                responseBody += tech_con_1_linkedin + '<br>';

                responseBody += '<br>';
            }

            if(tech_con_2_fname != '' && tech_con_2_email != '') {
                responseBody += tech_con_2_fname + ' ';
                responseBody += tech_con_2_lname + '<br>';
                responseBody += tech_con_2_email + '<br>';
                responseBody += tech_con_2_title + '<br>';
                responseBody += tech_con_2_twitter + '<br>';
                responseBody += tech_con_2_github + '<br>';
                responseBody += tech_con_2_linkedin + '<br>';

                responseBody += '<br>';
            }

            if(tech_con_3_fname != '' & tech_con_3_email != '') {
                responseBody += tech_con_3_fname + ' ';
                responseBody += tech_con_3_lname + '<br>';
                responseBody += tech_con_3_email + '<br>';
                responseBody += tech_con_3_title + '<br>';
                responseBody += tech_con_3_twitter + '<br>';
                responseBody += tech_con_3_github + '<br>';
                responseBody += tech_con_3_linkedin + '<br>';

                responseBody += '<br>';
            }

            responseBody += '<br>';
        }

        if(legal_con_fname != '' && legal_con_email != '') {
            responseBody += 'Legal Contact <br>';

            responseBody += '<br>';

            responseBody += legal_con_fname + ' ';
            responseBody += legal_con_lname + '<br>';
            responseBody += legal_con_email + '<br>';
            responseBody += legal_con_title + '<br>';
            responseBody += legal_con_twitter + '<br>';
            responseBody += legal_con_github + '<br>';
            responseBody += legal_con_linkedin + '<br>';

            responseBody += '<br>';
            responseBody += '<br>';
        }

        if((mkt_con_1_fname != '' && mkt_con_1_email != '') || (mkt_con_2_fname != '' && mkt_con_2_email != '') || (mkt_con_3_fname != '' & mkt_con_3_email != '')) {
            responseBody += 'Marketing Contacts <br>';

            responseBody += '<br>';

            if(mkt_con_1_fname != '' && mkt_con_1_email != '') {
                responseBody += mkt_con_1_fname + ' ';
                responseBody += mkt_con_1_lname + '<br>';
                responseBody += mkt_con_1_email + '<br>';
                responseBody += mkt_con_1_title + '<br>';
                responseBody += mkt_con_1_twitter + '<br>';
                responseBody += mkt_con_1_github + '<br>';
                responseBody += mkt_con_1_linkedin + '<br>';

                responseBody += '<br>';
            }

            if(mkt_con_2_fname != '' && mkt_con_2_email != '') {
                responseBody += mkt_con_2_fname + ' ';
                responseBody += mkt_con_2_lname + '<br>';
                responseBody += mkt_con_2_email + '<br>';
                responseBody += mkt_con_2_title + '<br>';
                responseBody += mkt_con_2_twitter + '<br>';
                responseBody += mkt_con_2_github + '<br>';
                responseBody += mkt_con_2_linkedin + '<br>';

                responseBody += '<br>';
            }

            if(mkt_con_3_fname != '' & mkt_con_3_email != '') {
                responseBody += mkt_con_3_fname + ' ';
                responseBody += mkt_con_3_lname + '<br>';
                responseBody += mkt_con_3_email + '<br>';
                responseBody += mkt_con_3_title + '<br>';
                responseBody += mkt_con_3_twitter + '<br>';
                responseBody += mkt_con_3_github + '<br>';
                responseBody += mkt_con_3_linkedin + '<br>';

                responseBody += '<br>';
            }

            responseBody += '<br>';
        }

        if(pr_con_fname != '' && pr_con_email != '') {
            responseBody += 'Press Contact <br>';

            responseBody += '<br>';

            responseBody += pr_con_fname + ' ';
            responseBody += pr_con_lname + '<br>';
            responseBody += pr_con_email + '<br>';
            responseBody += pr_con_title + '<br>';
            responseBody += pr_con_twitter + '<br>';
            responseBody += pr_con_github + '<br>';
            responseBody += pr_con_linkedin + '<br>';
        }

        responseBody += '</div>';


        return responseBody;
    }


    //Wrapper Class
    public class ContactDetails {
        String FirstName;
        String LastName;
        String Email;
        String Title;
        String Twitter;
        String GitHub;
        String LinkedIn;

        public ContactDetails(String FirstName, String LastName, String Email, String Title, String Twitter, String GitHub, String LinkedIn) {
            this.FirstName = FirstName;
            this.LastName = LastName;
            this.Email = Email.toLowerCase();
            this.Title = Title;
            this.Twitter = Twitter;
            this.GitHub = GitHub;
            this.LinkedIn = LinkedIn;
        }
    }
}