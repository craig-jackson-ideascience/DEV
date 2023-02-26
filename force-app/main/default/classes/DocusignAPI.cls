public class DocusignAPI{
    public static String AccountID{
        get{
            Docusign_Settings__c setting = Docusign_Settings__c.getOrgDefaults();
            return setting.AccountId__c;
        }
    }

    public static String DocuSignEndpoint{
        get{
            Docusign_Settings__c setting = Docusign_Settings__c.getOrgDefaults();
            return setting.Endpoint__c;
        }
    }

    //Get Authenticaion Header, Used for all request
    public static String authHeader(){
        Docusign_Settings__c setting = Docusign_Settings__c.getOrgDefaults();
        //Get Paramter from Custom Setting (sfdc cache) and construct auth header
        return '<DocuSignCredentials>' + 
             '<Username>' + setting.Username__c + '</Username>' + 
             '<Password>' + setting.Password__c + '</Password>' + 
             '<IntegratorKey>' + setting.Integrator_Key__c + '</IntegratorKey>' + 
             '</DocuSignCredentials>';
    }

    private static HTTPResponse makeCallout(String endpoint, String body, String method){
        String authorizationHeader = authHeader();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        System.debug(request.getEndpoint() + '====> request.getEndpoint()');
        request.setTimeout(20000);
        request.setHeader('X-DocuSign-Authentication', authorizationHeader);
        request.setHeader('Accept', 'application/json,application/pdf');

        if (String.isNotBlank(body)){
            request.setHeader('Content-type', 'application/json;charset=utf-8');
            request.setBody(body);
        }
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug(response + '====> response');
        System.debug(response.getBody() + '====> response');
        if (!(response.getStatusCode() == 201 || response.getStatusCode() == 200)){
            sendErrorEmail();
        }
        return response;
    }

    public static String createEnvelope(Id oppId){
        String endPoint = DocuSignEndpoint + 'accounts/' + accountID + '/envelopes';
        System.debug('endPoint' + endPoint);
        String req = createEnvelopeHelper(oppId);
        if (req == 'Error'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please Provide Docusign Fields on Project or product Details'));
        } else{
            HttpResponse response = makeCallout(endPoint, req, 'POST');
            if (response.getStatusCode() == 201){
                Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                String envelopeId = (String) resMap.get('envelopeId');
                return envelopeId;
            }
        }
        //set Content Type Header
        return null;
    }

    public static HttpResponse voidEnvelope(String envelopeId, String reason){
        String endpoint = DocuSignEndpoint + 'accounts/' + accountID + '/envelopes/' + envelopeId;
        String body = '{"status": "voided","voidedReason" : "' + reason + '"}';
        HttpResponse response = makeCallout(endpoint, body, 'PUT');
        return response;
    }

    public static HttpResponse reSendEnvelope(String envelopeId){
        String endpoint = DocuSignEndpoint + 'accounts/' + accountID + '/envelopes/' + envelopeId + '?resend_envelope=true';
        String body = '{}';
        HttpResponse response = makeCallout(endpoint, body, 'PUT');
        return response;
    }

    public static HttpResponse getDocument(String envelopeId){
        String endpoint = DocuSignEndpoint + 'accounts/' + accountID + '/envelopes/' + envelopeId + 
                                         '/documents/combined?recipient_id=1&watermark=true&&show_changes=true';
        String body = '';
        HttpResponse response = makeCallout(endpoint, body, 'GET');
        return response;
    }

    public static HttpResponse sendEnvelope(String envelopeId){
        String endpoint = DocuSignEndpoint + 'accounts/' + accountID + '/envelopes/' + envelopeId;
        String body = '{"status": "sent"}';
        HttpResponse response = makeCallout(endpoint, body, 'PUT');
        return response;
    }

    public static String getPreviewURL(String envelopeId){
        String endPoint = DocuSignEndpoint + 'accounts/' + accountID + '/envelopes/' + envelopeId + '/views/recipient_preview';
        String returnUrl = Url.getSalesforceBaseUrl().toExternalForm();
        HttpResponse response = makeCallout(endPoint, '{ "returnUrl":"' + returnUrl + '", "recipientId" : "1" }', 'POST');
        if (response.getStatusCode() == 201){
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            return (String) responseMap.get('url');
        }
        return null;
    }

    private static void sendErrorEmail(){
    }

    public static String createEnvelopeHelper(Id oppId){
        List<Opportunity> oppTemplateID = [Select Id, Docusign_Template_Id__c
                                           From Opportunity
                                           WHERE Id = :oppId];
        List<OpportunityLineItem> OppLineItem = [Select Id, Projects__r.Name, Opportunity.Opportunity_PO_Required__c, Display_Logo_On_Website__c, Projects__c, TotalPrice, Product_Name__c, Start_Tier__c, Product2.Name, No_Press_Release_Announcement__c, Start5000__c, Start500__c, Start1__c, Description__c, Project__c, PO_Number__c, Product_Details__r.Description__c, Opportunity.AccountId, Membership_Tier__c, CNCF_Level__c, Projects__r.Slug__c, Opportunity.Billing_To_Addr_Line_1__c, Opportunity.Billing_To_Addr_Line_2__c, Opportunity.Billing_To_Addr_Line_3__c, Opportunity.Account.Name, Opportunity.Preferred_Invoice_Method__c, Product_Details__r.Project_Signatory__c, Opportunity.Account.Website, Product_Details__r.Project_Signatory__r.name, Product_Details__r.Project_Signatory__r.email, Product_Details__r.Project_Signatory__r.title, Product_Details__r.Docusign_Template_Id__c, Projects__r.Project_Signatory__c, Projects__r.Project_Signatory__r.name, Projects__r.Project_Signatory__r.email, Projects__r.Project_Signatory__r.title, Projects__r.Docusign_Template_Id__c, Opportunity.Signed_MSA__c,Opportunity.CurrencyIsoCode
                                                 From OpportunityLineItem
                                                 WHERE opportunityId = :oppId AND Projects__r.Membership_Roles_Not_Required__c = false
                                                 ORDER BY Projects__r.Name];


        //store all project roles for each oli
        Map<String, List<Project_Role__c>> oliVsProjectRole = new Map<String, List<Project_Role__c>>();

        //get all the project roles
        List<Project_Role__c> projectRoles = [SELECT Id, Contact__c, Contact__r.Title, Contact__r.Email, ContactEmail__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Phone, Contact__r.Twitter_ID__c, Contact__r.GitHub_ID__c, Contact__r.LinkedIn_ID__c, Contact__r.Name, Role__c, ProjectName__c, Start_Date__c, End_Date__c, Opportunity_Line_Item__c, PrimaryContact__c
                                              FROM Project_Role__c
                                              WHERE Opportunity__c = :oppId AND Status__c = 'Active' AND PrimaryContact__c = TRUE
                                              ORDER BY ProjectName__c]; //Added by Priyesh @CloudRoute for Primary Contact
        System.debug('projectRoles==>' + projectRoles);

        //create the map oliId against list project roles
        for (Project_Role__c pr : projectRoles){
            if (oliVsProjectRole.containsKey(pr.Opportunity_Line_Item__c)){
                oliVsProjectRole.get(pr.Opportunity_Line_Item__c).add(pr);
            } else{
                oliVsProjectRole.put(pr.Opportunity_Line_Item__c, new List<Project_Role__c>{ pr });
            }
        }

        Envelope req = new Envelope();
        req.status = 'Created';
        // req.templateId = DocusignAPI.getTemplateId(OppLineItem);
        System.debug(req.templateId + '====> req.templateId');
        //req.Recipients
        //Instantiating two template roleslist as for some projects - Project and LF Signer are different
        List<templateRoles> projectListtemplateRoles = new List<templateRoles>();
        List<templateRoles> linuxlisttemplateRoles = new List<templateRoles>();
        List<templateRoles> trainingMsaTemplateRole = new List<templateRoles>();
        Map<Id, List<templateRoles>> itemidvsTemplateRoleList = new Map<Id, List<templateRoles>>();

        List<OpportunityContactRole> oppRoles = [SELECT Id, Contact.Name, Contact.Title, Contact.Email, Role
                                                 from OpportunityContactRole
                                                 Where OpportunityId = :oppId];
        system.debug('oppRole ' + oppRoles);
        Tabs tabsList = new Tabs();
        tabsList.textTabs = new List<textTabs>();
        String opportunityId = oppId;
        OpportunityLineItem linuxLineItem = new OpportunityLineItem();
        Integer index = 1;
        String roleName = 'Authorized Signatory for Your Company:';
        String linuxRoleName = 'Authorized Signatory for Linux Foundation:';

        Map<Id, Tabs> lineItemVsTab = new map<Id, Tabs>();
        Id linxFoundationid;
        Map<Id, OpportunityLineItem> oppLineItemMap = new Map<Id, OpportunityLineItem>(oppLineItem);
        for (OpportunityLineItem item : oppLineItem){
            Tabs lineItemtabsList = new Tabs();
            lineItemtabsList.textTabs = new List<textTabs>();
            if (item.Projects__r.Name != 'The Linux Foundation' && item.Projects__r.Name != 'Linux Foundation Europe'){
                lineItemtabsList.textTabs.addAll(getProjectMergeFields(item, oliVsProjectRole.get(item.Id)));
            } else{
                if (item.Projects__r.Name == 'The Linux Foundation'){
                    linxFoundationid = item.id;
                }
                lineItemtabsList.textTabs.addAll(getLFMergeFields(item, oliVsProjectRole.get(item.Id)));
                linuxLineItem = item;
            }
            if (linxFoundationid != null){
                linuxLineItem = oppLineItemMap.get(linxFoundationid);
            }
            lineItemtabsList.textTabs.addAll(getBillingAddress(item));
            lineItemtabsList.textTabs.add(createTextTabs('/Company/', item.Opportunity.Account.Name));
            lineItemtabsList.textTabs.add(createTextTabs('/Method/', item.Opportunity.Preferred_Invoice_Method__c));
            lineItemtabsList.textTabs.add(createTextTabs('/Web/', item.Opportunity.Account.Website));
            lineItemVsTab.put(item.Id, lineItemtabsList);

        }

        /*  if (!oppLineItem.isEmpty()){
         //passing 1st element of lineitem because populating billing address from opportunity
         tabsList.textTabs.addAll(getBillingAddress(oppLineItem[0]));
         tabsList.textTabs.add(createTextTabs('/Company/', oppLineItem[0].Opportunity.Account.Name));
         tabsList.textTabs.add(createTextTabs('/Method/', oppLineItem[0].Opportunity.Preferred_Invoice_Method__c));
         tabsList.textTabs.add(createTextTabs('/Web/', oppLineItem[0].Opportunity.Account.Website));
         } */

        if (oppLineItem.size() == 1 && oppLineItem[0].Projects__r.Name == 'The Linux Foundation' /* || oppLineItem[0].Projects__r.Name == 'Linux Foundation Europe') */){
            Project_Role__c authSign = new Project_Role__c();
            for (Project_Role__c role : oliVsProjectRole.get(oppLineItem[0].Id)){

                if (role.Role__c == 'Authorized Signatory'){
                    authSign = role;
                    lineItemVsTab.get(oppLineItem[0].Id).textTabs.add(createTextTabs('/AuthTitle/', role.Contact__r.Title));
                    lineItemVsTab.get(oppLineItem[0].Id).textTabs.add(createTextTabs('/AuthEmail/', role.Contact__r.Email));
                    lineItemVsTab.get(oppLineItem[0].Id).textTabs.add(createTextTabs('/AuthName/', role.Contact__r.Name));
                    break;
                }
            }

            templateRoles linuxtempRole = getTemplateRole(linuxRoleName, oppLineItem[0], index + 1);
            if (linuxtempRole.email != null){
                lineItemVsTab.get(oppLineItem[0].Id).textTabs.add(createTextTabs('/LFSignatoryName/', linuxtempRole.name));
                lineItemVsTab.get(oppLineItem[0].Id).textTabs.add(createTextTabs('/LFSignatoryTitle/', linuxtempRole.title));
                templateRoles templateRole = getTemplateRole(roleName, authSign, index);
                system.debug('authSign ' + authSign);
                if (!lineItemVsTab.get(oppLineItem[0].Id).textTabs.isEmpty()){
                    templateRole.tabs = lineItemVsTab.get(oppLineItem[0].Id);
                }
                linuxlisttemplateRoles.add(templateRole);
                linuxlisttemplateRoles.add(linuxtempRole);
                itemidvsTemplateRoleList.put(oppLineItem[0].id, linuxlisttemplateRoles);
            } else{
                System.debug('Error');
                return 'Error';
            }
        } else{
            for (OpportunityLineItem item : oppLineItem){
                if (item.Projects__r.Name != 'The Linux Foundation'){
                    Project_Role__c authSign = new Project_Role__c();
                    for (Project_Role__c role : oliVsProjectRole.get(item.Id)){
                        if (role.Role__c == 'Authorized Signatory'){
                            authSign = role;
                            lineItemVsTab.get(item.id).textTabs.add(createTextTabs('/AuthTitle/', role.Contact__r.Title));
                            lineItemVsTab.get(item.id).textTabs.add(createTextTabs('/AuthEmail/', role.Contact__r.Email));
                            lineItemVsTab.get(item.id).textTabs.add(createTextTabs('/AuthName/', role.Contact__r.Name));
                            break;
                        }
                    }
                    //Template role for project signatory of project
                    templateRoles projectSecondtempRole = getTemplateRole(linuxRoleName, item, index + 1);
                    if (projectSecondtempRole.email != null){
                        String projname = item.Projects__r.Name == 'Linux Foundation Europe' ? '/LFSignatoryName/' : '/ProjectSignatoryName/';
                        String projTitle = item.Projects__r.Name == 'Linux Foundation Europe' ? '/LFSignatoryTitle/' : '/ProjectSignatoryTitle/';

                        lineItemVsTab.get(item.id).textTabs.add(createTextTabs(projname, projectSecondtempRole.name));
                        lineItemVsTab.get(item.id).textTabs.add(createTextTabs(projTitle, projectSecondtempRole.title));
                        templateRoles linuxSecondtempRole = new templateRoles();
                        //Template role for project signatory of Linux project
                        if (linuxLineItem.Id != null){
                            linuxSecondtempRole = getTemplateRole(linuxRoleName, linuxLineItem, index + 1);
                            lineItemVsTab.get(item.id).textTabs.add(createTextTabs('/LFSignatoryName/', linuxSecondtempRole.name));
                            lineItemVsTab.get(item.id).textTabs.add(createTextTabs('/LFSignatoryTitle/', linuxSecondtempRole.title));
                        }

                        //get template role for authorised signatory
                        templateRoles projecttemplateRole1 = getTemplateRole(roleName, authSign, index);
                        if (!lineItemVsTab.get(item.id).textTabs.isEmpty()){
                            System.debug('In if ' + lineItemVsTab.get(item.id));
                            projecttemplateRole1.tabs = lineItemVsTab.get(item.id);
                        }

                        //add to projecttemplateroleList
                        projectListtemplateRoles.add(projecttemplateRole1);

                        //get template role for authorised signatory - calling it once again as we have to make tabs null for linux templaterole
                        templateRoles linuxtemplateRole1 = getTemplateRole(roleName, authSign, index);
                        //making null so the tags dont come as overlapping in template
                        linuxtemplateRole1.tabs = lineItemVsTab.get(linuxLineItem.id);
                        linuxlisttemplateRoles.add(linuxtemplateRole1);
                        projectListtemplateRoles.add(projectSecondtempRole);
                        if (linuxLineItem.Id != null){
                            linuxlisttemplateRoles.add(linuxSecondtempRole);
                        }
                    } else{
                        System.debug('Error');
                        return 'Error';
                    }
                    //break;
                }
            }
        }
        System.debug('projectListtemplateRoles ' + projectListtemplateRoles);
        System.debug('linuxlisttemplateRoles ' + linuxlisttemplateRoles);

        /*
         for (OpportunityContactRole oppRole : oppRoles) {
         String roleName = '';
         system.debug('Inside role' + oppRole.Role);
         if (oppRole.Role == 'Authorized Signatory' || oppRole.Role == 'Authorized LF Signatory') {
         index++;
         if (oppRole.Role == 'Authorized Signatory') {
         roleName = 'Authorized Signatory for Your Company:';
         } else if (oppRole.Role == 'Authorized LF Signatory') {
         roleName = 'Authorized Signatory for LF Membership:';
         }
         System.debug('Adding Role');
         listTemplateRoles.add(getTemplateRole(roleName, oppRole, tabsList,index));
         }
         }
         */

        //System.debug('listtemplateRoles: ' + listtemplateRoles);
        //req.templateRoles = listtemplateRoles;
        textCustomFields field = new textCustomFields();
        field.name = '##SFOpportunity';
        field.value = opportunityId;
        customFields customField = new customFields();
        customField.textcustomFields = new List<textcustomFields>();
        customField.textcustomFields.add(field);
        //req.customFields = customField;

        //Tabs tabsList = new Tabs();
        //tabsList.textTabs = txtTabsVarList;

        /*boolean hasLinuxMemberShip;
         if(oppLineItem.size() > 1){
         hasLinuxMemberShip = true;
         }*/

        List<compositeTemplates> compositeTemplates = new List<compositeTemplates>();

        //Compositetemplate for Linux
        compositeTemplates linuxcompositeTemplate = new compositeTemplates();
        linuxcompositeTemplate.serverTemplates = new List<serverTemplates>();
        linuxcompositeTemplate.inlineTemplates = new List<inlineTemplates>();

        //Compositetemplate for Linux Europe
        compositeTemplates linuxEuropecompositeTemplate = new compositeTemplates();
        linuxEuropecompositeTemplate.serverTemplates = new List<serverTemplates>();
        linuxEuropecompositeTemplate.inlineTemplates = new List<inlineTemplates>();

        //Compositetemplate for Project
        compositeTemplates projectcompositeTemplate = new compositeTemplates();
        projectcompositeTemplate.serverTemplates = new List<serverTemplates>();
        projectcompositeTemplate.inlineTemplates = new List<inlineTemplates>();

        system.debug('customField ' + customField);

        for (OpportunityLineItem item : oppLineItem){
            if (projectListtemplateRoles.size() > 1 || linuxlisttemplateRoles.size() > 1){
                system.debug('name ' + item.Projects__r.Name);
                /*  if(item.Projects__r.Name == 'Linux Foundation Europe'){
                 String templateId = item.Product_Details__r.Docusign_Template_Id__c != null ? item.Product_Details__r.Docusign_Template_Id__c : item.Projects__r.Docusign_Template_Id__c;
                 //get template and keep sequence as 1 for project so that email Subject and private message from template will be taken from Project 's template
                 System.debug('Project templateId ' + templateId);
                 linuxEuropecompositeTemplate.serverTemplates.add(new serverTemplates('1', templateId));
                 linuxEuropecompositeTemplate.inlineTemplates.add(prepareTemplate('1', customField, projectListtemplateRoles));

                 }else */if (item.Projects__r.Name != 'The Linux Foundation'){

                    String templateId = item.Product_Details__r.Docusign_Template_Id__c != null ? item.Product_Details__r.Docusign_Template_Id__c : item.Projects__r.Docusign_Template_Id__c;
                    //get template and keep sequence as 1 for project so that email Subject and private message from template will be taken from Project 's template
                    System.debug('Project templateId ' + templateId);
                    if ((linxFoundationid == null && item.Projects__r.Name == 'Linux Foundation Europe' && oppLineItem.size() > 1)){
                        //first merge the linux
                        linuxcompositeTemplate.serverTemplates.add(new serverTemplates('2', templateId));
                        linuxcompositeTemplate.inlineTemplates.add(prepareTemplate('2', customField, linuxlisttemplateRoles));
                    } else{
                        projectcompositeTemplate.serverTemplates.add(new serverTemplates('1', templateId));
                        projectcompositeTemplate.inlineTemplates.add(prepareTemplate('1', customField, projectListtemplateRoles));
                    }
                } else{
                    String templateId = (item.Projects__c != null && item.Product2.Name == 'Associate Membership') ? Label.Linux_Associate_Template_Id : Label.Linux_Membership_Template_Id;
                    System.debug('Linux templateId ' + templateId);
                    //first merge the linux
                    linuxcompositeTemplate.serverTemplates.add(new serverTemplates('2', templateId));
                    linuxcompositeTemplate.inlineTemplates.add(prepareTemplate('2', customField, linuxlisttemplateRoles));
                }
                //compositeTemplates.add(compositeTemplate);
            }
        }

        //need to add Linux template first in list so that Linux template is seen first in contract
        if (oppLineItem.size() > 1){
            compositeTemplates.add(linuxcompositeTemplate);
            compositeTemplates.add(projectcompositeTemplate);
            trainingMsaTemplateRole.addAll(projectListtemplateRoles);
        } else if (oppLineItem.size() == 1){
            OpportunityLineItem oppLineItemInstance = oppLineItem[0];
            if (oppLineItemInstance.Projects__r.Name != 'The Linux Foundation'){
                compositeTemplates.add(projectcompositeTemplate);
                trainingMsaTemplateRole.addAll(projectListtemplateRoles);

            } else{
                compositeTemplates.add(linuxcompositeTemplate);
                trainingMsaTemplateRole.addAll(linuxlisttemplateRoles);

            }
        }
        if (oppLineItem[0].opportunity.Signed_MSA__c){
            //Compositetemplate for Project
            compositeTemplates trainingCompositeTemplate = new compositeTemplates();
            trainingCompositeTemplate.serverTemplates = new List<serverTemplates>();
            trainingCompositeTemplate.inlineTemplates = new List<inlineTemplates>();

            //System.debug('Linux templateId ' + templateId);
            //first merge the linux
            trainingCompositeTemplate.serverTemplates.add(new serverTemplates('3', Label.Training_MSA_Template_Id));
            trainingCompositeTemplate.inlineTemplates.add(prepareTemplate('3', customField, trainingMsaTemplateRole));
            compositeTemplates.add(trainingCompositeTemplate);

        }
        req.compositeTemplates = compositeTemplates;

        mDebugUntruncated('json.serialize(req): ' + json.serialize(req));
        return json.serialize(req);
    }

    //method to prepare templates
    private static inlineTemplates prepareTemplate(String sequence, customFields customField, List<templateRoles> listtemplateRoles){
        inlineTemplates template = new inlineTemplates();
        template.sequence = sequence;
        template.customFields = customField;
        template.recipients = new recipients();
        template.recipients.signers = listTemplateRoles;
        return template;
    }

    private static textTabs createTextTabs(String anchorString, String value){
        textTabs tab = new textTabs();
        tab.value = value;
        tab.anchorString = anchorString;
        tab.locked = true;
        tab.required = false;
        tab.disableAutoSize = false;
        return tab;
    }

    private static List<textTabs> getBillingAddress(OpportunityLineItem oppLineItem){
        List<textTabs> textTabs = new List<textTabs>();
        //Billing Address
        textTabs.add(createTextTabs('/BillingStreet/', oppLineItem.Opportunity.Billing_To_Addr_Line_1__c));
        textTabs.add(createTextTabs('/BillingCity/', oppLineItem.Opportunity.Billing_To_Addr_Line_2__c));
        textTabs.add(createTextTabs('/BillingCountry/', oppLineItem.Opportunity.Billing_To_Addr_Line_3__c));
        return textTabs;
    }

    private static List<textTabs> getLFMergeFields(OpportunityLineItem oppLineItem, List<Project_Role__c> projectRoles){
        List<textTabs> textTabs = new List<textTabs>();
        for (Project_Role__c role : projectRoles){
            if (role.Role__c == 'Representative/Voting Contact'){
                textTabs.add(createTextTabs('/LFTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/LFEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/LFFirstName/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/LFLastName/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/LFPhoneNo/', role.Contact__r.Phone));
                textTabs.add(createTextTabs('/LFPrimaryFullName/', role.Contact__r.Name));

            } else if (role.Role__c == 'Billing Contact'){
                textTabs.add(createTextTabs('/LFBillFullName/', role.Contact__r.Name));
                textTabs.add(createTextTabs('/LFBillTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/LFBillEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/LFBillFirst/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/LFBillLast/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/LFBillPhone/', role.Contact__r.Phone));

            } else if (role.Role__c == 'Technical Contact'){
                textTabs.add(createTextTabs('/LFTechFullName/', role.Contact__r.Name));
                textTabs.add(createTextTabs('/LFTecTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/LFTecEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/LFTecFirst/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/LFTecLast/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/LFTecPhone/', role.Contact__r.Phone));

            } else if (role.Role__c == 'Press Contact'){
                textTabs.add(createTextTabs('/LFPressTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/LFPressEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/LFPressFirst/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/LFPressLast/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/LFPressPhone/', role.Contact__r.Phone));
                textTabs.add(createTextTabs('/LFPressFullName/', role.Contact__r.Name));

            } else if (role.Role__c == 'Marketing Contact'){
                textTabs.add(createTextTabs('/LFMarkTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/LFMarkEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/LFMarkFirst/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/LFMarkLast/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/LFMarkPhone/', role.Contact__r.Phone));
                textTabs.add(createTextTabs('/LFMarkFullName/', role.Contact__r.Name));

            } else if (role.Role__c == 'PO Contact'){
                textTabs.add(createTextTabs('/LFPOFirst/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/LFPOLast/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/LFPOEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/LFPOFullName/', role.Contact__r.Name));


            } else if (role.Role__c == 'Legal Contact'){
                textTabs.add(createTextTabs('/LFLegalFullName/', role.Contact__r.Name));
                textTabs.add(createTextTabs('/LFLegalTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/LFLegalEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/LFLegalFirst/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/LFLegalLast/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/LFLegalPhone/', role.Contact__r.Phone));

            }
            /*else if (role.Role__c == 'Authorized Signatory') {
             textTabs.add(createTextTabs('/LFAuthTitle/', role.Contact__r.Title));
             textTabs.add(createTextTabs('/LFAuthName/', role.Contact__r.Name));
             }*/
        }
        textTabs.add(createTextTabs('/LFTier/', oppLineItem.Membership_Tier__c));
        textTabs.add(createTextTabs('/LFProductName/', oppLineItem.Product_Name__c + '' + ',' + ''));

        Decimal totalprice = oppLineItem.TotalPrice;
        List<String> args = new String[]{ '0', 'number', '###,###,##0.00' };
        String s = String.format(totalprice.format(), args);
        System.debug(s);
        textTabs.add(createTextTabs('/LFAmount/', oppLineItem.Opportunity.CurrencyIsoCode +' ' + s));

        textTabs.add(createTextTabs('/LFPOReq/', oppLineItem.Opportunity.Opportunity_PO_Required__c ? 'Yes' : 'No'));
        textTabs.add(createTextTabs('/LFDLogo/', oppLineItem.Display_Logo_On_Website__c ? 'No' : 'Yes'));
        textTabs.add(createTextTabs('/LFNoPress/', oppLineItem.No_Press_Release_Announcement__c ? 'No' : 'Yes'));

        return textTabs;
    }

    private static List<textTabs> getProjectMergeFields(OpportunityLineItem oppLineItem, List<Project_Role__c> projectRoles){
        System.debug('====> getProjectMergeFields');
        List<textTabs> textTabs = new List<textTabs>();
        System.debug('projectRoles==>' + projectRoles);
        for (Project_Role__c role : projectRoles){
            if (role.Role__c == 'Representative/Voting Contact'){
                textTabs.add(createTextTabs('/Title/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/Email/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/FirstName/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/LastName/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/PhoneNo/', role.Contact__r.Phone));
                textTabs.add(createTextTabs('/PrimaryFullName/', role.Contact__r.Name));

                String vtwitterGithubLinkedInString = (role.Contact__r.Twitter_ID__c == null ? '' : role.Contact__r.Twitter_ID__c.substringAfter('com/')) + ' / ' + (role.Contact__r.GitHub_ID__c == null ? '' : role.Contact__r.GitHub_ID__c.substringAfter('com/')) + ' / ' + (role.Contact__r.LinkedIn_ID__c == null ? '' : role.Contact__r.LinkedIn_ID__c.substringAfter('in/'));
                textTabs votingTextTab = createTextTabs('/TwiLinGit/', vtwitterGithubLinkedInString);
                votingTextTab.disableAutoSize = true;
                textTabs.add(votingTextTab);

            } else if (role.Role__c == 'Billing Contact'){
                textTabs.add(createTextTabs('/BillFullName/', role.Contact__r.Name));
                textTabs.add(createTextTabs('/BillingTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/BillingEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/BillingFirstName/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/BillingLastName/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/BillingPhone/', role.Contact__r.Phone));

            } else if (role.Role__c == 'Technical Contact'){
                textTabs.add(createTextTabs('/TechFullName/', role.Contact__r.Name));
                textTabs.add(createTextTabs('/TechTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/TechEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/TechFirst/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/TechLast/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/TechPhone/', role.Contact__r.Phone));
                String twitterGithubLinkedInString = (role.Contact__r.Twitter_ID__c == null ? '' : role.Contact__r.Twitter_ID__c.substringAfter('com/')) + ' / ' + (role.Contact__r.GitHub_ID__c == null ? '' : role.Contact__r.GitHub_ID__c.substringAfter('com/')) + ' / ' + (role.Contact__r.LinkedIn_ID__c == null ? '' : role.Contact__r.LinkedIn_ID__c.substringAfter('in/'));
                textTabs technicalTextTab = createTextTabs('/TTwiLinGit/', twitterGithubLinkedInString);
                technicalTextTab.disableAutoSize = true;
                textTabs.add(technicalTextTab);

            } else if (role.Role__c == 'Press Contact'){
                textTabs.add(createTextTabs('/PressFullName/', role.Contact__r.Name));
                textTabs.add(createTextTabs('/PressTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/PressEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/PressFirst/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/PressLast/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/PressPhone/', role.Contact__r.Phone));

            } else if (role.Role__c == 'Marketing Contact'){
                textTabs.add(createTextTabs('/MarkFullName/', role.Contact__r.Name));
                textTabs.add(createTextTabs('/MarkTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/MarkEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/MarkFirst/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/MarkLast/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/MarkPhone/', role.Contact__r.Phone));
                String mtwitterGithubLinkedInString = (role.Contact__r.Twitter_ID__c == null ? '' : role.Contact__r.Twitter_ID__c.substringAfter('com/')) + ' / ' + (role.Contact__r.GitHub_ID__c == null ? '' : role.Contact__r.GitHub_ID__c.substringAfter('com/')) + ' / ' + (role.Contact__r.LinkedIn_ID__c == null ? '' : role.Contact__r.LinkedIn_ID__c.substringAfter('in/'));
                textTabs marketingTextTab = createTextTabs('/MTwiLinGit/', mtwitterGithubLinkedInString);
                marketingTextTab.disableAutoSize = true;
                textTabs.add(marketingTextTab);

            } else if (role.Role__c == 'PO Contact'){
                textTabs.add(createTextTabs('/POFullName/', role.Contact__r.Name));
                textTabs.add(createTextTabs('/POFirst/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/POLast/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/POEmail/', role.Contact__r.Email));

            } else if (role.Role__c == 'Legal Contact'){
                textTabs.add(createTextTabs('/LegalFullName/', role.Contact__r.Name));
                textTabs.add(createTextTabs('/LegalTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/LegalEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/LegalFirst/', role.Contact__r.FirstName));
                textTabs.add(createTextTabs('/LegalLast/', role.Contact__r.LastName));
                textTabs.add(createTextTabs('/LegalPhone/', role.Contact__r.Phone));
                String ltwitterGithubLinkedInString = (role.Contact__r.Twitter_ID__c == Null ? '' : role.Contact__r.Twitter_ID__c.substringAfter('com/')) + ' / ' + (role.Contact__r.GitHub_ID__c == Null ? '' : role.Contact__r.GitHub_ID__c.substringAfter('com/')) + ' / ' + (role.Contact__r.LinkedIn_ID__c == Null ? '' : role.Contact__r.LinkedIn_ID__c.substringAfter('in/'));
                textTabs legalTextTab = createTextTabs('/LTwiLinGit/', ltwitterGithubLinkedInString);
                legalTextTab.disableAutoSize = true;
                textTabs.add(legalTextTab);

            } else if (role.Role__c == 'Event Sponsorship'){
                textTabs.add(createTextTabs('/SponsorTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/SponsorEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/SponsorName/', role.Contact__r.Name));
                textTabs.add(createTextTabs('/SponsorPhone/', role.Contact__r.Phone));
                //textTabs.add(createTextTabs('/CncfLevel/', oppLineItem.CNCF_Level__c == 'End User' ? 'Yes' : 'No')); //TODO:  CNCF_Level__c which field to refer from roles?

                /*}else if(role.Role__c == 'Authorized Signatory'){
                 textTabs.add(createTextTabs('/AuthTitle/', role.Contact__r.Title));
                 textTabs.add(createTextTabs('/AuthEmail/', role.Contact__r.Email));
                 textTabs.add(createTextTabs('/AuthName/', role.Contact__r.Name));
                 */
            } else if (role.Role__c == 'Finance Committee'){
                //Added by priyesh @CloudRoute for new committee roles
                textTabs.add(createTextTabs('/FCTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/FCEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/FCName/', role.Contact__r.Name));

            } else if (role.Role__c == 'MarCom Committee'){
                //Added by priyesh @CloudRoute for new committee roles
                textTabs.add(createTextTabs('/MCTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/MCEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/MCName/', role.Contact__r.Name));

            } else if (role.Role__c == 'Membership Committee'){
                //Added by priyesh @CloudRoute for new committee roles
                textTabs.add(createTextTabs('/MECTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/MECEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/MECName/', role.Contact__r.Name));

            } else if (role.Role__c == 'Governance Framework Committee'){
                //Added by priyesh @CloudRoute for new committee roles
                textTabs.add(createTextTabs('/GFCTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/GFCEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/GFCName/', role.Contact__r.Name));

            } else if (role.Role__c == 'Bedrock Technical Project'){
                //Added by priyesh @CloudRoute for new committee roles
                textTabs.add(createTextTabs('/TPTitle/', role.Contact__r.Title));
                textTabs.add(createTextTabs('/TPEmail/', role.Contact__r.Email));
                textTabs.add(createTextTabs('/TPName/', role.Contact__r.Name));
            }
        }

        //Consolidated Employee
        textTabs.add(createTextTabs('/Tier/', oppLineItem.Membership_Tier__c)); //TODO: which type of role is this?

        textTabs.add(createTextTabs('/ProjectName/', oppLineItem.Projects__r.Name));

        textTabs.add(createTextTabs('/ProductName/', oppLineItem.Product_Name__c + '' + ',' + ''));
        textTabs.add(createTextTabs('/ProductType/', String.valueOf(oppLineItem.Start_Tier__c)));

        textTabs.add(createTextTabs('/PONumber/', oppLineItem.PO_Number__c));

        Decimal rA = oppLineItem.TotalPrice;
        List<String> args = new String[]{ '0', 'number', '###,###,##0.00' };
        String s = String.format(rA.format(), args);
        System.debug(s);
        textTabs.add(createTextTabs('/Amount/', oppLineItem.Opportunity.CurrencyIsoCode +' '+ +s));

        textTabs.add(createTextTabs('/DLogo/', oppLineItem.Display_Logo_On_Website__c ? 'No' : 'Yes'));
        textTabs.add(createTextTabs('/NoPress/', oppLineItem.No_Press_Release_Announcement__c ? 'No' : 'Yes'));
        textTabs.add(createTextTabs('/POReq/', oppLineItem.Opportunity.Opportunity_PO_Required__c ? 'Yes' : 'No'));

        textTabs.add(createTextTabs('/In/', oppLineItem.Product_Details__r.Description__c == 'RISC-V Switzerland Individual Members not representing a legal entity' ? 'X' : ''));
        textTabs.add(createTextTabs('/Com/', oppLineItem.Product_Details__r.Description__c == 'RISC-V Switzerland Community Membersship (academic and other non-profit legal entities)' ? 'X' : ''));
        textTabs.add(createTextTabs('/Board/', oppLineItem.Product_Details__r.Description__c == 'RISC-V Switzerland Premier Membership (Board and Technical Steering Committee)' ? 'X' : ''));
        textTabs.add(createTextTabs('/Tech/', oppLineItem.Product_Details__r.Description__c == 'RISC-V Switzerland Premier Membership (Technical Steering Committee)' ? 'X' : ''));

        textTabs.add(createTextTabs(getStartTierField(oppLineItem), 'X'));
        textTabs.add(createTextTabs(getProductNameField(oppLineItem), 'X'));

        //query category
        List<Account_And_Project__c> accProjects = [SELECT Account__c, Category__c, Project__c
                                                    FROM Account_And_Project__c
                                                    WHERE Account__c = :oppLineItem.Opportunity.AccountId AND Project__c = :oppLineItem.Projects__c];
        if (!accProjects.IsEmpty() && String.isNotBlank(accProjects[0].Category__c)){
            textTabs.add(createTextTabs('/ProjCategory/', accProjects[0].Category__c));
        }
        return textTabs;
    }

    /* private static String getPRValue(OpportunityLineItem oppLineItem) {
     String DLogoString = '';
     if (oppLineItem.Display_Logo_On_Website__c && oppLineItem.No_Press_Release_Announcement__c) {
     DLogoString = 'No to Logo and PR';
     } else if (!oppLineItem.Display_Logo_On_Website__c && !oppLineItem.No_Press_Release_Announcement__c) {
     DLogoString = 'Yes';
     } else if (!oppLineItem.Display_Logo_On_Website__c && oppLineItem.No_Press_Release_Announcement__c) {
     DLogoString = 'No to PR';
     } else if (oppLineItem.Display_Logo_On_Website__c && !oppLineItem.No_Press_Release_Announcement__c) {
     DLogoString = 'No to Logo';
     }
     return DLogoString;
     }
     */
    private static String getStartTierField(OpportunityLineItem oppLineItem){
        switch  on Integer.valueOf(oppLineItem.Start_Tier__c){
            when 1{
                return '/Start1/';
            }
            when 50{
                return '/Start50/';
            }
            when 500{
                return '/Start500/';
            }
            when 2000{
                return '/Start2000/';
            }
            when 5000{
                return '/Start5000/';
            }
            when else{
                return '';
            }
        }
    }

    private static String getProductNameField(OpportunityLineItem oppLineItem){
        switch  on oppLineItem.Product2.Name{
            when 'Premier Membership'{
                return '/ProductPremier/';
            }
            when 'General Membership'{
                return '/ProductGeneral/';
            }
            when 'Associate Membership'{
                return '/ProductAssociate/';
            }
            when else{
                return '';
            }
        }
    }

    private static String getLinksWithLineBreaks(String links){
        if (links != null)
            return String.join(links.split(','), '\n\n\n');
        return '';
    }

    private static inlineTemplates prepareTemplate(string templateId, String sequence, String oppLineItemId, List<OpportunityContactRole> oppRoles){
        inlineTemplates templates = new inlineTemplates();
        /*templates.sequence = sequence;

         //create custom field
         textCustomFields field = new textCustomFields();
         field.name = 'DSFSSourceObjectId';
         field.value = oppLineItemId+'~OpportunityLineItem';
         customFields customField = new customFields();
         customField.textcustomFields = new List<textcustomFields>();
         customField.textcustomFields.add(field);
         templates.customFields = customField;

         //create recipients
         List<templateRoles> listTemplateRoles = new List<templateRoles>();
         for(OpportunityContactRole oppRole : oppRoles )
         {
         String roleName='';
         if(oppRole.Role != 'Authorized Signatory' ||  oppRole.Role != 'Authorized LF Signatory')
         continue;
         if(oppRole.Role == 'Authorized Signatory'){
         roleName = 'Authorized Signatory for Your Company';
         }
         else if(oppRole.Role == 'Authorized LF Signatory'){
         roleName = 'Authorized Signatory for The Linux Foundation';
         }
         listTemplateRoles.add(getTemplateRole(roleName,oppRole));
         }

         templates.recipients =  new recipients();
         templates.recipients.signers = listTemplateRoles;*/
        return templates;
    }

    private static templateRoles getTemplateRole(string roleName, Project_Role__c role, Integer index){
        templateRoles templateRole = new templateRoles();
        System.debug('Authorized Signatory==>' + role.Contact__r.Name);
        templateRole.name = role.Contact__r.Name;
        templateRole.email = role.Contact__r.Email;
        templateRole.title = role.Contact__r.Title;
        templateRole.roleName = roleName;
        templateRole.recipientId = String.valueOf(index);

        /* if (!tabs.textTabs.isEmpty())
         templateRole.tabs = tabs;
         */

        system.debug('Template Role ' + templateRole);
        return templateRole;
    }

    //method to get second signer for project as well as linux
    private static templateRoles getTemplateRole(string roleName, opportunitylineitem oli, Integer index){
        System.debug('Index ' + index);
        templateRoles templateRoleObj = new templateRoles();

        //checking project signatory is not blank either on product details or project
        if (oli.Product_Details__r.Project_Signatory__c != null || oli.projects__r.Project_Signatory__c != null){

            //Store the name,title and email for project signer
            String projectSignername = oli.Product_Details__r.Project_Signatory__c != null ? oli.Product_Details__r.Project_Signatory__r.name : (oli.projects__r.Project_Signatory__c != null ? oli.projects__r.Project_Signatory__r.name : '');

            String projectSigneremail = oli.Product_Details__r.Project_Signatory__c != null ? oli.Product_Details__r.Project_Signatory__r.email : (oli.projects__r.Project_Signatory__c != null ? oli.projects__r.Project_Signatory__r.email : '');

            String projectSignerTitle = oli.Product_Details__r.Project_Signatory__c != null ? oli.Product_Details__r.Project_Signatory__r.title : (oli.projects__r.Project_Signatory__c != null ? oli.projects__r.Project_Signatory__r.title : '');

            System.debug('projectSignername ' + projectSignername);
            System.debug('projectSigneremail ' + projectSigneremail);
            System.debug('projectSignerTitle ' + projectSignerTitle);

            //create template role for project
            templateRoleObj.name = projectSignername;
            templateRoleObj.email = projectSigneremail;
            templateRoleObj.roleName = roleName;
            templateRoleObj.recipientId = String.valueOf(index);
            templateRoleObj.title = projectSignerTitle;

        }
        System.debug('Project Role ' + templateRoleObj);
        return templateRoleObj;
    }

    public static void mDebugUntruncated(String sMsg){
        for (Integer i = 0; i < sMsg.length(); i = i + 300){
            Integer iEffectiveEnd = (i + 300 > (sMsg.length() - 1) ? sMsg.length() - 1 : i + 300);
            System.debug(sMsg.substring(i, iEffectiveEnd));
        }
    }

    public class DocusignResponse{
        public String envelopeId;
        public String uri;
        public String statusDateTime;
        public String status;
        public DocusignResponse parse(String json){
            return (DocusignResponse)System.JSON.deserialize(json, DocusignResponse.class);
        }

    }

    public class Envelope{
        public String status;
        public String emailSubject;
        public String emailBlurb;
        public templateRoles[] templateRoles;
        public String templateId;
        public customFields customFields;
        public List<compositeTemplates> compositeTemplates;
    }

    public class Document{
        public String documentId;
        public String name;
        public String documentBase64;
    }

    public class templateRoles{
        public String email;
        public String name;
        public String roleName;
        public string title;
        public Tabs tabs;
        public String recipientId;
    }

    public class compositeTemplates{
        public serverTemplates[] serverTemplates;
        public inlineTemplates[] inlineTemplates;
    }

    public class serverTemplates{
        public String sequence;
        public String templateId;
        public serverTemplates(String sequence, String templateId){
            this.sequence = sequence;
            this.templateId = templateId;
        }

    }

    public class inlineTemplates{
        public String sequence;
        public customFields customFields;
        public recipients recipients;
    }

    public class recipients{
        public List<templateRoles> signers;
    }

    public class Tabs{
        public textTabs[] textTabs;
    }

    public class customFields{
        public textCustomFields[] textcustomFields;
    }

    public class textTabs{
        public String tabLabel;
        public String value;
        public String xPosition;
        public String yPosition;
        public String pageNumber;
        public Boolean disableAutoSize;
        public String width;
        public String underline;
        public String anchorString;
        public Boolean required;
        public Boolean locked;
    }

    public class textCustomFields{
        public String name;
        public String show;
        public String required;
        public String value;

    }

}