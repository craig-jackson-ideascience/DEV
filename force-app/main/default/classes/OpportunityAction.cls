public class OpportunityAction{
    private static Id corporateTrainingRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();
    //
    public void restrictOppStageUpdateWithoutOCRs(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap){
        Set<Id> filteredOppIds = new Set<Id>();
        List<Opportunity> oppListTofindOCR = new List<Opportunity>();

        for (Opportunity o : newOppMap.values()){
            //Commented by Pratik D on 6 may system.debug('__o____' + o.Id + ' ' + o.StageName + ' ' + oldOppMap.get(o.Id).StageName + ' ' + userinfo.getProfileId());
            if (o.StageName != null && o.StageName != '2. Discovery' && oldOppMap.get(o.Id).StageName != o.StageName && userinfo.getProfileId() != System.Label.Executive_Event_Sales && ((o.Type.contains('Renewal') && o.StageName == 'Closed Won') || o.Type == 'New Business')){
                filteredOppIds.add(o.Id);
            }
        }

        if (filteredOppIds != null && filteredOppIds.size() > 0){
            oppListTofindOCR = [Select Id, (Select Id
                                            from OpportunityContactRoles)
                                from Opportunity 
                                where Id In:filteredOppIds AND RecordType.DeveloperName NOT IN ('Corporate_Training', 'Training_PO')];
        }

        if (oppListTofindOCR != null && oppListTofindOCR.size() > 0){

            for (Opportunity op : oppListTofindOCR){
                If (op.OpportunityContactRoles.size() == 0 || op.OpportunityContactRoles.size() < 0){
                    Opportunity errorOpp = newOppMap.get(op.Id);
                    errorOpp.addERROR('This Opportunity does not have any contact role associated to it. Hence, its stage can not be updated');
                }
            }
        }
    }

    /*This method Create a task for Opportunity Owner that Renewal Opportunity is not Closed */
    /*public void createTaskForOpenRenewalOpportunity(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap) {
     Set<Id> renewalOppIds = new Set<Id>();
     List<Opportunity> oppListToCreateTask = new List<Opportunity>();
     Map<id, Opportunity> oppMap = new Map<id, Opportunity>();
     List<Task> taskList = new List<Task>();

     for (Opportunity o : newOppMap.values()) {
     if (!o.isClosed && o.Type == 'Renewal' && o.Renewal_Opportunity_Closed__c != '' && o.Renewal_Opportunity_Closed__c == 'True') {
     renewalOppIds.add(o.Id);
     }
     }
     if (renewalOppIds != null && renewalOppIds.size() > 0) {
     oppListToCreateTask = [SELECT id, ownerid FROM opportunity where Id In :renewalOppIds];
     }
     if (oppListToCreateTask != null && oppListToCreateTask.size() > 0) {
     for (Opportunity opp : oppListToCreateTask) {
     Task tsk = new Task();
     tsk.OwnerId = opp.OwnerId;
     tsk.Subject = System.Label.Renewal_Opportunity_Task_Status;
     tsk.Priority = 'Normal';
     tsk.Status = 'Not Started';
     //tsk.Name= 'Open Renewal Opp- '+opp.Name;
     tsk.whatId = Opp.Id;

     taskList.add(tsk);

     }

     }
     if (taskList != null && taskList.size() > 0) {
     insert taskList;
     }

     }*/
    /*This method validate that requires a contract be attached to an opportunity before it can be closed won. */
    /**** Created by - Sandeep Sharma ********/
    /*** Modified by - Ankita Gandhi - 20/07/2017
     Added exception to exclude opps with type RENEWAL
     ***/
    /*** Modified by - Viraj@CR - 03/06/2020
     Added exception to exclude training Invoice Only Opportunities
     ***/
    public void validateBeforeClosedWon(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap){
        Set<ID> oppWithCompletedDocusignRec = new Set<ID>();
        Set<Id> qualifiedOppIds = new Set<Id>();
        Set<ID> oppWithAttachtment = new Set<ID>();

        for (Opportunity op : newOppMap.Values()){
            if (op.Type == 'New Business' && oldOppMap.get(op.Id).isWon != op.isWon && op.isWon){
                qualifiedOppIds.add(op.Id);
            }
        }
        if (!qualifiedOppIds.isEmpty()){
            for (dsfs__DocuSign_Status__c d : [SELECT Id, Name, dsfs__Contact__c, dsfs__Envelope_Status__c, dsfs__Opportunity__c
                                               FROM dsfs__DocuSign_Status__c
                                               WHERE dsfs__Opportunity__c in:qualifiedOppIds AND dsfs__Envelope_Status__c = 'Completed']){
                oppWithCompletedDocusignRec.add(d.dsfs__Opportunity__c);
            }
            for (Attachment att : [SELECT Id, ParentId, Name
                                   FROM Attachment
                                   WHERE ParentID IN:qualifiedOppIds]){
                if (att.Name.tolowercase().contains('executed')){
                    oppWithAttachtment.add(att.ParentId);
                }
            }
            for (ContentDocumentLink contentDocumentLink : [SELECT ContentDocumentId, ContentDocument.Title, LinkedEntityId
                                                            FROM ContentDocumentLink
                                                            WHERE LinkedEntityId IN:qualifiedOppIds]){
                if (contentDocumentLink.ContentDocument.Title.tolowercase().contains('executed')){
                    oppWithAttachtment.add(contentDocumentLink.LinkedEntityId);
                }
            }
            for (Opportunity opp : newOppMap.values()){
                if (qualifiedOppIds.contains(opp.Id)){
                    if (opp.RecordTypeId != corporateTrainingRecordId && !oppWithCompletedDocusignRec.contains(opp.id) && !oppWithAttachtment.contains(opp.id)){
                        System.debug(LoggingLevel.INFO, '____Add error Location________');

                        opp.addError('Contract record is required before Closing Opportunity');
                    } else if (opp.RecordTypeId == corporateTrainingRecordId && !oppWithAttachtment.contains(opp.id) && ((!opp.Invoice_Only_Opp__c) || (opp.Invoice_Only_Opp__c && opp.No_of_Quotes__c > 0))){
                        opp.addError('Contract record is required before Closing Opportunity');
                    }
                }
            }
        }
    }

    public void sendClosedLostEmailNotification(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap){

        Id membershipRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        Set<Id> opportunityIds = new Set<Id>();
        //Iterate through each Opportunity
        for (Opportunity oppRecord : newOppMap.values()){
            //if Stage is Closed Lost then add the opportunity to set
            if (oppRecord.StageName == 'Closed Lost' && oppRecord.recordTypeId == membershipRecordId && (oldOppMap == null || (oldOppMap != null && oppRecord.StageName != oldOppMap.get(oppRecord.Id).StageName))){
                opportunityIds.add(oppRecord.Id);
            }
        }
        if (!opportunityIds.isEmpty()){
            sendClosedLostEmails(opportunityIds, newOppMap);
        }
    }

    private static void sendClosedLostEmails(Set<Id> oppIds, Map<Id, Opportunity> newOpps){

        Map<Id, Opportunity> IdVsOpportunity = new Map<Id, Opportunity>(newOpps);
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        Map<String, Set<String>> oppIdVsEmails = new Map<String, Set<String>>();
        Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
        List<string> projectNames = System.Label.ProjectsForClosedLostNotification.Split(';');
        Set<String> setProjectNames = new Set<String>();
        String htmlBody = System.Label.Closed_Lost_Email_Notification;


        if (!Test.isRunningTest()){
            for (string projectName : projectNames){
                string s = projectName.trim();
                setProjectNames.add(s);
            }
        } else{
            setProjectNames.add('The Linux Foundation');
        }

        List<Messaging.SingleEmailMessage> emailMsgList = new List<Messaging.SingleEmailMessage>();

        if (!oppIds.isEmpty() && !setProjectNames.isEmpty()){
            if (!setProjectNames.contains('All')){
                oppLineItems = [SELECT Id, Projects__r.Notifications_Group__c, OpportunityId, Opportunity.Name, Opportunity.Opportunity_Link__c, Opportunity.Owner.FirstName, Opportunity.Owner.Email, Projects__r.Name
                                FROM OpportunityLineItem
                                WHERE OpportunityId IN:oppIds AND Projects__r.Notifications_Group__c != Null AND Projects__r.Name IN:setProjectNames];
            } else{
                oppLineItems = [SELECT Id, Projects__r.Notifications_Group__c, OpportunityId, Opportunity.Name, Opportunity.Opportunity_Link__c, Opportunity.Owner.FirstName, Opportunity.Owner.Email, Projects__r.Name
                                FROM OpportunityLineItem
                                WHERE OpportunityId IN:oppIds AND Projects__r.Notifications_Group__c != Null];
            }

        }
        System.debug(LoggingLevel.INFO, 'List of OLI' + oppLineItems);
        if (!oppLineItems.isEmpty()){
            for (OpportunityLineItem oli : oppLineItems){
                if (!oppIdVsEmails.containsKey(oli.OpportunityId)){
                    oppIdVsEmails.put(oli.OpportunityId, new Set<String>());
                }
                if (String.isNotBlank(oli.Projects__r.Notifications_Group__c)){
                    oppIdVsEmails.get(oli.OpportunityId).add(oli.Projects__r.Notifications_Group__c);
                }
            }

            for (String oppId : oppIdVsEmails.keyset()){

                List<String> toAddress = new List<String>(oppIdVsEmails.get(oppId));
                Opportunity oppRecord = IdVsOpportunity.get(oppId);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String subject = oppRecord.Name + ' Opportunity is Closed Lost';

                htmlBody = htmlBody.replace('[OpportunityLink]', oppRecord.Opportunity_Link__c).replace('[OpportunityName]', oppRecord.Name);
                email.setToAddresses(toAddress);
                email.setOrgWideEmailAddressId(orgWideEmailAddress);
                email.setSubject(subject);
                email.setHtmlBody(htmlBody);
                email.setWhatId(oppId);
                emailMsgList.add(email);

            }
        }


        if (!emailMsgList.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMsgList);
            for (Messaging.SendEmailResult res : results){
                if (!res.success){
                    System.debug(LoggingLevel.INFO, res + '====> res');
                } else{
                    System.debug(LoggingLevel.INFO, 'success ' + res);
                }
            }
        }
    }

    public void filterClosedOppsToLock(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){

        Set<Id> filteredOppIds = new Set<Id>();

        for (Opportunity op : newMap.Values()){
            if (op.isWon == true && op.isWon != oldMap.get(op.Id).isWon && op.Record_Locked__c == false){
                //filteredOppIds.add(op.Id);
                op.Record_Locked__c = true;
            }
        }

        /* if(filteredOppIds!=null && filteredOppIds.size()>0){
         lockClosedOpps(filteredOppIds);
         }
         */
    }

    /*  @future
     public static void lockClosedOpps(Set<Id> OppIds){
     List<Opportunity> oppsToUpdate = new List<Opportunity>();
     for(Id oId : OppIds){
     oppsToUpdate.add(new Opportunity(Id=oId , Record_Locked__c=true));
     }
     if(oppsToUpdate!=null && oppsToUpdate.size()>0){
     update oppsToUpdate;
     }
     }
     */
    public void restrictUpdatingLockedOpps(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        Boolean hasPermission = FeatureManagement.checkPermission('AdminCanUpdateClosedOpp');
        Set<Id> filteredOppIds = new Set<Id>();

        if (!hasPermission){
            for (Opportunity op : newMap.Values()){
                if ((op.isWon == true && op.isWon == oldMap.get(op.Id).isWon && op.Record_Locked__c == oldMap.get(op.Id).Record_Locked__c) || (op.StageName != 'Closed Won' && oldMap.get(op.Id).StageName == 'Closed Won' && op.Record_Locked__c == true)){
                    // mpoer to remove conditions on this ASAP 2018-07-03
                    // if(Test.IsRunningTest()) {
                    op.addError('Can not update Closed Won Opportunity');
                    // }
                }
            }
        }
    }

    public void updateApplicationStatusField(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        Id membershipRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();

        for (Opportunity op : newMap.Values()){
            //skip Non-Membership RecordTypes
            if (op.RecordTypeId != membershipRecordId || op.Type != 'New Business'){
                continue;
            }
            if (oldMap == null){

                op.ApplicationStatus__c = 'Application Received';

            } else{
                if (op.Type == 'New Business' && oldMap.get(op.Id).isWon != op.isWon && op.isWon){
                    op.ApplicationStatus__c = 'Complete';
                } else if (op.Type == 'New Business' && op.StageName == 'Closed Lost' && oldMap.get(op.Id).StageName != 'Closed Lost'){
                    op.ApplicationStatus__c = 'Cancelled';
                }
            }
        }
    }

    public void validateIfProductIsAdded(Map<Id, Opportunity> oldOppMap, List<Opportunity> newOpp){
        for (Opportunity opp : newOpp){
            if (opp.isWon && opp.isWon != oldOppMap.get(opp.Id).isWon && opp.Total_Products_under_Opportunity__c == 0){
                opp.addError(Label.No_Opp_Product);
            }
        }
    }

    public void validateDateClosedWon(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap){
        /*Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([
         Select Id, (Select Id,Start_Date__c,End_Date__c,Type__c,Projects__c,Projects__r.Status__c,Event__c,
         Event__r.Status__c,Projects__r.Do_Not_Invoice__c from OpportunityLineItems)
         from Opportunity
         where Id = :newOppMap.keySet()
         ]);*/
        //get Membership recordtype ID
        Set<Id> closedWonOppIds = new Set<Id>();
        for (Opportunity opp : newOppMap.values()){
            //if opportunity is closed won
            if (opp.isWon && opp.isWon != oldOppMap.get(opp.Id).isWon){
                closedWonOppIds.add(opp.Id);
            }
        }
        if (!closedWonOppIds.isEmpty()){
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([Select Id, isWon, recordTypeId, (Select Id, Start_Date__c, End_Date__c, Type__c, Projects__c, Projects__r.Status__c, Event__c, Event__r.Status__c, Projects__r.Do_Not_Invoice__c
                                                                                                             from OpportunityLineItems)
                                                                            from Opportunity 
                                                                            where Id = :closedWonOppIds]);
            // check if start date and end date is populated on opp products
            Id membershipRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
            for (Opportunity opp : opportunityMap.values()){
                for (OpportunityLineItem oppItem : opportunityMap.get(opp.Id).OpportunityLineItems){
                    if (opp.isWon && opp.isWon != oldOppMap.get(opp.Id).isWon){
                        if (opp.recordTypeId == membershipRecordId){
                            if (oppItem.Start_Date__c == null){
                                //throw error if start date is null
                                newOppMap.get(opp.Id).addError(Label.Start_Date_Not_Null);
                                break;
                            } else if (oppItem.End_Date__c == null){
                                newOppMap.get(opp.Id).addError(Label.End_Date_Not_Null);
                                break;
                            }
                        }
                        if ((oppItem.Projects__c != null && oppItem.Projects__r.Status__c == 'Planned' && !oppItem.Projects__r.Do_Not_Invoice__c) || oppItem.Event__c != null && oppItem.Event__r.Status__c == 'Planned'){
                            newOppMap.get(opp.Id).addError('All the OLIs should be associated to Active Project/Event for this Stage');
                            break;
                        }
                    }
                }
            }
        }
        /*if (opp.isWon && opp.isWon != oldOppMap.get(opp.Id).isWon && opp.recordTypeId == membershipRecordId) {
         // check if start date and end date is populated on opp products
         for (OpportunityLineItem oppItem : opportunityMap.get(opp.Id).OpportunityLineItems) {
         if (oppItem.Start_Date__c == null) {//throw error if start date is null
         opp.addError(Label.Start_Date_Not_Null);
         break;
         } else if (oppItem.End_Date__c == null) {
         opp.addError(Label.End_Date_Not_Null);
         break;
         }
         }
         }*/
        //check if planned status
        /*if(opp.isWon && opp.isWon != oldOppMap.get(opp.Id).isWon){
         for (OpportunityLineItem oppItem : opportunityMap.get(opp.Id).OpportunityLineItems) {
         if((oppItem.Projects__c != null && oppItem.Projects__r.Status__c =='Planned' && !oppItem.Projects__r.Do_Not_Invoice__c) ||
         oppItem.Event__c != null && oppItem.Event__r.Status__c =='Planned'){
         opp.addError('All the OLIs should be associated to Active Project/Event for this Stage');
         break;
         }
         }
         }*/
    }

    //This creates default contact role for person account
    /*
     public void addDefaultContactRole(Map<Id, Opportunity> newOpportunities) {
     List<OpportunityContactRole> roles = new List<OpportunityContactRole>();

     Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT AccountId,Account.PersonContactId,Id from Opportunity where ID In:newOpportunities.keyset() AND Account.IsPersonAccount = true]);

     if (!oppMap.isEmpty()) {
     for (Opportunity opp : newOpportunities.values()) {
     if (oppMap.containsKey(opp.Id)) {
     OpportunityContactRole role = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = oppMap.get(opp.Id).Account.PersonContactId, Role = 'Membership Decision Maker');
     roles.add(role);
     }
     }
     if (!roles.isEmpty()) {
     insert roles;
     }
     }
     }
     */
    /*If Opp is closed then update Opp Line Item start and end date using Today's Date
     * else if Opp is open and JoinNowUpdate && Close Date are changed concurrently,
     * then update Opp Line Item Start and End date using Opp.CloseDate
     */
    public void updateOppCloseDateAndInstallDate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        List<Opportunity> updatedOpportunity = new List<Opportunity>();
        Map<Id, Date> mapJoinNowUpdatedOpp = new Map<Id, Date>();
        for (Opportunity opp : newMap.values()){
            if (opp.isWon && !oldMap.get(opp.Id).isWon && opp.isClosed && !oldMap.get(opp.Id).isClosed && opp.Type == 'New Business'){
                updatedOpportunity.add(opp);
            } else if (!opp.isClosed && opp.JoinNow_Update__c != oldMap.get(opp.Id).JoinNow_Update__c && opp.CloseDate != oldmap.get(opp.Id).CloseDate){
                updatedOpportunity.add(opp);
                mapJoinNowUpdatedOpp.put(opp.id, opp.CloseDate);
            }
        }

        if (!updatedOpportunity.IsEmpty()){
            List<OpportunityLineItem> oppLineItems = [SELECT Id, Product2.name, TotalPrice, Opportunity.Total_Products_under_Opportunity__c, Projects__r.Name, Projects__r.Skip_Start_Date_Validation__c, Projects__r.Membership_Start_date__c, Description__c, End_Date__c
                                                      FROM OpportunityLineItem
                                                      WHERE OpportunityId IN:updatedOpportunity AND Opportunity.Skip_Start_Date_Validation__c = false];
            Map<Id, Boolean> skipValidationByOppId = new Map<Id, Boolean>();
            List<OpportunityLineItem> opportunityLineItemstoUpdate = new List<OpportunityLineItem>();
            for (OpportunityLineItem oli : oppLineItems){
                //if multiple products,give preference to othe than LF project
                if ((oli.Opportunity.Total_Products_under_Opportunity__c > 1 && oli.Projects__r.Name != 'The Linux Foundation') || oli.Opportunity.Total_Products_under_Opportunity__c == 1){
                    skipValidationByOppId.put(oli.OpportunityId, oli.Projects__r.Skip_Start_Date_Validation__c);
                }
            }
            List<String> productNameToExclude = LABEL.Product_Names_to_Exclude.split(';');
            for (OpportunityLineItem oli : oppLineItems){
                Date startDate;
                if (skipValidationByOppId.containsKey(oli.OpportunityId) && !skipValidationByOppId.get(oli.OpportunityId)){
                    if (mapJoinNowUpdatedOpp.containsKey(oli.OpportunityId)){
                        Date closeDate = mapJoinNowUpdatedOpp.get(oli.OpportunityId);
                        startDate = closeDate.day() < 15 ? Date.newInstance(closeDate.year(), closeDate.month(), 1) : Date.newInstance(closeDate.year(), closeDate.month() + 1, 1);
                        oli.Start_Date__c = startDate;
                    } else{
                        startDate = System.today().day() < 15 ? Date.newInstance(System.today().year(), System.today().month(), 1) : Date.newInstance(System.today().year(), System.today().month() + 1, 1);
                        oli.Start_Date__c = startDate;
                    }

                    if (!(productNameToExclude.contains(oli.Product2.Name) && oli.TotalPrice == 0)){
                        oli.End_Date__c = startDate.addYears(1) - 1;
                        System.debug(LoggingLevel.INFO, '#--end--#' + oli.End_Date__c);
                    }
                    System.debug(LoggingLevel.INFO, 'else ' + startDate + '---' + startDate.addYears(1));
                    opportunityLineItemstoUpdate.add(oli);
                    system.debug(LoggingLevel.INFO, 'OLI Name: ' + oli.Description__c);
                    system.debug(LoggingLevel.INFO, 'OLI start date: ' + string.valueOf(oli.Start_Date__c) + ' End Date: ' + string.valueOf(oli.End_Date__c));

                }
            }
            if (!opportunityLineItemstoUpdate.isEmpty()){
                TriggerStopper.stopOppLine = true;

                //SObjectAccessDecision decisionopportunityLineItemstoUpdate = Security.stripInaccessible(AccessType.UPDATABLE, opportunityLineItemstoUpdate);
                //update decisionopportunityLineItemstoUpdate.getRecords();

                update opportunityLineItemstoUpdate;

                TriggerStopper.stopOppLine = false;
            }
        }
    }

    @InvocableMethod(label = 'Send Email to the Opportunity Owner')
    public static void sendOpportunityEmail(List<Id> opportunitiesIds){
        List<Opportunity> opportunities = [SELECT Id, Opportunity_PO_Required__c, OwnerId
                                           FROM Opportunity
                                           WHERE Id IN:opportunitiesIds];
        if (opportunities.size() > 0){
            Opportunity opp = opportunities[0];
            List<EmailTemplate> emailTemplates = [SELECT Id
                                                  FROM EmailTemplate
                                                  WHERE DeveloperName = :(opp.Opportunity_PO_Required__c ? 'DocuSign_Complete' :'Opp_Closed_Docusign_Complete')];
            if (emailTemplates.size() > 0){
                Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.SingleEmailMessage msg = Messaging.renderStoredEmailTemplate(emailTemplates[0].Id, opp.OwnerId, opp.Id);
                mail.setOrgWideEmailAddressId(orgWideEmailAddress);
                mail.setHtmlBody(msg.getHtmlBody());
                mail.setSubject(msg.getSubject());
                mail.setTargetObjectId(opp.OwnerId);
                mail.setSaveAsActivity(false);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
                for (Messaging.SendEmailResult res : results){
                    if (!res.success){
                        System.debug(LoggingLevel.INFO, res + '====> res');
                    }
                }
            }
        }
    }

    public void pushOpportunity(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldMap){
        System.debug(LoggingLevel.INFO, 'pushOpportunity');
        Date dNewCloseDate;
        Date dOldCloseDate;
        Boolean bPushed = false;

        for (Opportunity oIterator : newOpportunities){
            //Bulk trigger handler so that you can mass update opportunities and this fires for all'
            // gets new values for updated rows
            dNewCloseDate = oIterator.CloseDate; // get the new closedate
            dOldCloseDate = oldMap.get(oIterator.Id).CloseDate; //get the old closedate for this opportunity
            if (dOldCloseDate < dNewCloseDate){
                //if the new date is after the old one, look if the month numbers are different
                if (dOldCloseDate.month() < dNewCloseDate.month()){
                    // the month number is higher, it's been pushed out
                    bPushed = true;
                } else{
                    if (dOldCloseDate.year() < dNewCloseDate.year()){
                        // the month wasn't higher, but the year was, pushed!
                        bPushed = true;
                    }
                }

            }
            if (bPushed){
                // let's go make them sorry
                if (oIterator.PushCount__c == null){
                    oIterator.PushCount__c = 1;
                } else{
                    oIterator.PushCount__c++;
                }
            }
        }
    }

    //updates Invoice Memo field on Training Opportunity Products when Corporate Training Bundle is checked and Opportunity is Closed won
    public void updateInvoiceMemoForTrainingProduct(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap){
        Set<Id> opportunities = new Set<Id>();
        for (Opportunity opp : newMap.values()){
            if (String.isNotBlank(opp.NetSuite_Invoice_Memo__c) && oldMap.get(opp.Id).NetSuite_Invoice_Memo__c != opp.NetSuite_Invoice_Memo__c){
                opportunities.add(opp.Id);
            }
        }
        if (!opportunities.isEmpty()){
            List<OpportunityLineItem> trainingOlis = [SELECT Id, Opportunity.NetSuite_Invoice_Memo__c, Training__c
                                                      FROM OpportunityLineItem
                                                      WHERE OpportunityId IN:opportunities AND Training__c != null];
            if (!trainingOlis.isEmpty()){
                List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
                for (OpportunityLineItem oli : trainingOlis){
                    oli.NetSuite_Invoice_Memo__c = oli.Opportunity.NetSuite_Invoice_Memo__c;
                    oliToUpdate.add(oli);
                }
                if (!oliToUpdate.isEmpty()){

                    //SObjectAccessDecision decisionoliToUpdate = Security.stripInaccessible(AccessType.UPDATABLE, oliToUpdate);
                    //update decisionoliToUpdate.getRecords();
                    update oliToUpdate;

                }
            }
        }
    }

    public void createAssetOnClosedWon(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities){
        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>();
        Set<Id> oppIdSet = new Set<Id>();
        Id membershipRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        for (Opportunity opp : newOpportunities){
            if (opp.IsWon && (oldOpportunities == null || !oldOpportunities.get(opp.Id).IsWon)){
                opportunities.put(opp.Id, opp);
                //if membership opp doesn't have any quote
                if (opp.No_of_Quotes__c == 0 && opp.recordTypeId == membershipRecordId){
                    oppIdSet.add(opp.Id);
                }
            }
        }
        if (!oppIdSet.isEmpty()){
            Map<Id, Quote> oppIdVSquoteMap = new Map<Id, Quote>();
            //create quote for membership opp
            for (Id oppId : oppIdSet){
                Quote quote = new Quote(Name = opportunities.get(oppId).Name, OpportunityId = oppId);
                oppIdVSquoteMap.put(oppId, quote);
            }
            if (!oppIdVSquoteMap.isEmpty()){
                //set the variable to not fire opportunity trigger
                TriggerStopper.stopOpp = true;
                //insert
                insert oppIdVSquoteMap.values();
                /*Retrieve opplineitem because we need to insert it as quote lineitem
                 as from apex automatic insertion of quotelineitem doesn't take place when quote is inserted*/
                List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId, UnitPrice, Quantity, PricebookEntryId, Product2Id, Discount, ServiceDate, SortOrder
                                                     FROM OpportunityLineItem
                                                     WHERE OpportunityId IN:oppIdVSquoteMap.keySet()];
                List<QuoteLineItem> qliList = new List<QuoteLineItem>();
                //Iterate on oppLineItem
                for (OpportunityLineItem oli : oliList){
                    if (oppIdVSquoteMap.containsKey(oli.OpportunityId)){
                        //create instance of quotelineitem
                        QuoteLineItem qli = new QuoteLineItem();
                        qli.quoteId = oppIdVSquoteMap.get(oli.OpportunityId).Id;
                        qli.UnitPrice = oli.UnitPrice;
                        qli.Product2Id = oli.Product2Id;
                        qli.Quantity = oli.Quantity;
                        qli.PriceBookentryid = oli.PriceBookentryId;
                        qli.OpportunityLineItemId = oli.Id;
                        qli.Discount = oli.Discount;
                        qli.ServiceDate = oli.ServiceDate;
                        qli.SortOrder = oli.SortOrder;
                        qliList.add(qli);
                    }
                }
                system.debug(LoggingLevel.INFO, ' qliList ' + qliList.size());
                if (!qliList.isEmpty()){
                    //insert

                    //SObjectAccessDecision decisionqliList = Security.stripInaccessible(AccessType.CREATABLE, qliList);
                    //insert decisionqliList.getRecords();
                    insert qliList;
                }
                //rest so opportunity trigger can fire
                TriggerStopper.stopOpp = false;
            }
        }
        if (!opportunities.IsEmpty()){
            OpportunityClosedWon.createAssetOnClosedWon(opportunities);
        }
    }

    public void addBillingContact(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities){
        //Id trainingrecordty
        Map<Id, Id> billingContactIdByoppId = new Map<Id, Id>();
        Id trainingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        // on billin contact chane
        for (Opportunity opp : newOpportunities){
            if (opp.Billing_Contact__c != null && opp.RecordTypeId == trainingRecordTypeId && (oldOpportunities == null || oldOpportunities.get(opp.Id).Billing_Contact__c != opp.Billing_Contact__c)){
                billingContactIdByoppId.put(opp.Id, opp.Billing_Contact__c);
            }
        }
        //query all oppLineItem
        if (!billingContactIdByoppId.isEmpty()){
            for (OpportunityLineItem oppItem : [SELECT ID, OpportunityId, Billing_Contact__c
                                                FROM OpportunityLineItem
                                                WHERE OpportunityId IN:billingContactIdByoppId.keySet()]){
                oppItem.Billing_Contact__c = billingContactIdByoppId.get(oppItem.OpportunityId);
                oppLineItems.add(oppItem);
            }
        }
        if (!oppLineItems.IsEmpty()){

            //SObjectAccessDecision decisionOppLineItems = Security.stripInaccessible(AccessType.UPDATABLE, oppLineItems);
            //update decisionOppLineItems.getRecords();
            update oppLineItems;
        }
    }

    //***(Only for Corporate Training Opportunity)##If the training field on opportunity is not blank, it will update the relatedto and product detail of its opportunity products**/
    /*  public void updateTrainingAndProductDetails(Map<Id,Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities){
     Id trainingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();
     Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
     Set<Id> trainingIds = new Set<Id>();
     for(Opportunity oppty:newOpportunities.values()){
     //get only Corporate training opportunities whose training field is updated
     if(oppty.RecordTypeId == trainingRecordTypeId && oppty.Training__c != null && oppty.Training__c != oldOpportunities.get(oppty.Id).Training__c){
     opportunityMap.put(oppty.Id,oppty);
     trainingIds.add(oppty.Training__c);
     }
     }
     if(!opportunityMap.isEmpty()){
     //get Opportunity products of qualified opportunies
     List<OpportunityLineItem> oliList = [SELECT Id,Name,Training__c,Product_details__c,product2Id,opportunity.Training__c FROM
     OpportunityLineItem WHERE OpportunityId IN: opportunityMap.keySet()];
     List<OpportunityLineItem> oliListToUpdate = new List<OpportunityLineItem>();
     if(!oliList.isEmpty()){
     Set<Id> productIds = new Set<Id>();
     Map<String,Id> productDetailsIdByTrainingAndProducts = new Map<String,Id>();
     for(OpportunityLineItem oli:oliList){
     productIds.add(oli.Product2Id);
     }
     //get the product details matching with new training of opportunity and products of oppotunity line items
     List<Product_details__c> pdetails = [SELECT Id,Training__c,Products__c FROM Product_details__c WHERE
     Training__c IN: trainingIds AND Products__c IN:productIds];
     if(!pdetails.isEmpty()){
     for(Product_Details__c pd:pdetails){
     productDetailsIdByTrainingAndProducts.put(pd.Training__c+' '+pd.Products__c,pd.Id);
     }
     for(OpportunityLineItem oli:oliList){
     //populate new training from opportunity
     oli.Training__c = oli.opportunity.Training__c;
     if(productDetailsIdByTrainingAndProducts.containsKey(oli.Training__c+' '+oli.Product2Id)){
     //populate new product detail with new training and existing product
     oli.Product_Details__c = productDetailsIdByTrainingAndProducts.get(oli.Training__c+' '+oli.Product2Id);
     oliListToUpdate.add(oli);
     }else{// if any of the product detail is not found in
     opportunityMap.get(oli.opportunityId).addError('No Product Detail Found');
     }
     }
     System.debug('oliListToUpdate'+oliListToUpdate);
     if(!oliListToUpdate.isEmpty()){
     update oliListToUpdate;
     }
     }else{// if no product details found, will throw error
     for(Opportunity opp:opportunityMap.values()){
     opp.addError('No Product Detail Found');
     }
     }
     }
     }
     }*/
    //Method to store the terms on a hodden field based on trainingMode selection
    public void addTermsToAgreement(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities){
        String terms = '';
        for (Opportunity opty : newOpportunities){
            if (opty.RecordTypeId == corporateTrainingRecordId && (oldOpportunities == null || (oldOpportunities != null && oldOpportunities.get(opty.Id).Training_Modes__c != opty.Training_Modes__c))){
                if (opty.Training_Modes__c != null){
                    terms = getTerms(opty.Training_Modes__c.split(';'));
                    opty.Engagement_Terms__c = terms;
                } else{
                    opty.Engagement_Terms__c = terms;
                }
            }
        }
    }

    //Method to get the term on the basis of selected values
    public String getTerms(List<String> selectedValues){
        List<String> learningSubscription = new List<String>{ 'Enterprise eLearning + Certification Subscription', 'Course Subscription' };
        List<String> certificationSubscription = new List<String>{ 'Certification Subscription', 'Bulk Certifications', 'Certifications' };

        //retrieve the custom metadata to get the terms
        Map<String, String> trainingMap = new Map<String, String>();
        List<Training_Modes_Terms__mdt> trainingModeMDT = [SELECT MasterLabel, Term__c
                                                           FROM Training_Modes_Terms__mdt
                                                           WHERE MasterLabel != 'Instructor Led'];
        for (Training_Modes_Terms__mdt training : trainingModeMDT){
            trainingMap.put(training.MasterLabel, training.Term__c);
        }
        System.debug(LoggingLevel.INFO, 'trainingMap ' + trainingMap);
        String subscripHeading = '';
        String subscripContent;
        String certifictnContent;
        String certifctnHeading = '';
        String terms = '';
        System.debug(LoggingLevel.INFO, 'selectedValues ' + selectedValues);

        //Iterate through each selected value and get the terms together
        for (String str : selectedValues){

            if (learningSubscription.contains(str)){
                subscripHeading += str + ' ,';
                subscripContent = '\n' + trainingMap.get('Subscription Term') + '\n\n';
            }

            if (trainingMap.containsKey(str)){
                terms += str + '\n' + trainingMap.get(str) + '\n\n';
            }

            if (certificationSubscription.contains(str)){
                CertifctnHeading += str + ' ,';
                certifictnContent = '\n' + trainingMap.get('Certifications Term');

            }
        }
        if (!String.isBlank(subscripHeading) && !String.isBlank(subscripContent)){
            terms += subscripHeading.removeEnd(',') + subscripContent;
        }
        if (!String.isBlank(CertifctnHeading) && !String.isBlank(certifictnContent)){
            terms += CertifctnHeading.removeEnd(',') + certifictnContent;
        }
        System.debug(LoggingLevel.INFO, 'terms ' + terms);
        return terms;
    }

    //This method runs validation for corporate training before closing
    public void validateTrainingOpportunity(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        List<Opportunity> opps = new List<Opportunity>();
        for (Opportunity oppty : newMap.values()){
            if (oppty.RecordTypeId == corporateTrainingRecordId && oppty.StageName == 'Closed Won' && !oldMap.get(oppty.Id).IsWon){
                opps.add(oppty);
            }
        }
        if (!opps.isEmpty()){
            Map<Id, Opportunity> trainingOppswithLineItems = new Map<Id, Opportunity>([SELECT Id, Subscription_Expiration_Date__c, ti_panorama_sublicense_id__c, (SELECT Id, Training__r.Name
                                                                                                                                                                  FROM OpportunityLineItems
                                                                                                                                                                  WHERE Training__r.Category__c IN ('Subscription', 'Certification'))
                                                                                       FROM Opportunity 
                                                                                       WHERE RecordTypeId = :corporateTrainingRecordId AND (Subscription_Expiration_Date__c = NULL OR ti_panorama_sublicense_id__c = NULL)]);
            for (Opportunity oppty : opps){
                if (oppty.SyncedQuoteId == null && oppty.No_of_Quotes__c > 0){
                    oppty.addError('Sync the Quote');
                }

                //this checks if billing contact on opp is populated or not
                if (oppty.Billing_Contact__c == null){
                    oppty.addError('Billing Contact cannot be blank.Please add it on opportunity');
                }

                //this checks if netsuite invoice memo field is populated,when corp training checkbox is checked
                if (oppty.Corporate_Training_Bundle__c && oppty.NetSuite_Invoice_Memo__c == null){
                    oppty.addError('Netsuite Invoice Memo cannot be blank.Please add it on opportunity');
                }

                //this checks if Subscription Expiration Date is populated on the Opportunity for Subscription and Certification opportunities
                if (trainingOppswithLineItems.containsKey(oppty.Id) && trainingOppswithLineItems.get(oppty.Id).Subscription_Expiration_Date__c == null && !trainingOppswithLineItems.get(oppty.Id).OpportunityLineItems.isEmpty()){
                    oppty.addError(Label.Opportunity_SubscriptionExpirationValidation);
                }

                if (trainingOppswithLineItems.containsKey(oppty.Id) && trainingOppswithLineItems.get(oppty.Id).ti_panorama_sublicense_id__c == null && !trainingOppswithLineItems.get(oppty.Id).OpportunityLineItems.isEmpty()){
                    for (OpportunityLineItem oli : trainingOppswithLineItems.get(oppty.Id).OpportunityLineItems){
                        if (oli.Training__r.Name != 'Finops Trainings'){
                            oppty.addError(Label.Opportunity_tiPanoramaSublicenseIdValidation);
                        }
                    }
                }

                if (oppty.Is_CreditCard_Pay__c == null){
                    oppty.addError('Please select Is CreditCard Pay to close the opportunity.');
                }
            }
        }
    }

    /*When Opportunity is Closed Update Training Opportunity Line Item Start Date And End Date*/
    public void updateStartAndEndDate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        Set<Id> opportunityIds = new Set<Id>();

        for (Opportunity opp : newMap.values()){
            if (opp.isWon && !oldMap.get(opp.Id).isWon && opp.RecordTypeId == corporateTrainingRecordId){
                opportunityIds.add(opp.Id);
            }
        }

        if (!opportunityIds.isEmpty()){
            List<OpportunityLineItem> opportunityLineItemstoUpdate = new List<OpportunityLineItem>();
            for (OpportunityLineItem oli : [SELECT Id, Start_Date__c, End_Date__c
                                            FROM OpportunityLineItem
                                            WHERE OpportunityId IN:opportunityIds AND (Start_Date__c = null OR End_Date__c = null)]){
                oli.Start_Date__c = oli.Start_Date__c == null ? System.today() : oli.Start_Date__c;
                oli.End_Date__c = oli.End_Date__c == null ? oli.Start_Date__c : oli.End_Date__c;
                opportunityLineItemstoUpdate.add(oli);
            }
            if (!opportunityLineItemstoUpdate.isEmpty()){

                //SObjectAccessDecision decisionOpportunityLineItemstoUpdate = Security.stripInaccessible(AccessType.UPDATABLE, opportunityLineItemstoUpdate);
                //update decisionOpportunityLineItemstoUpdate.getRecords();
                update opportunityLineItemstoUpdate;

            }
        }
    }

    //Method restrict the opportunity if its products description is null and it is getting closed won
    public void validateOpportunityProductToRestrictOppsToClosedWon(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        Set<Id> oppIds = new Set<Id>();

        //get Training recordtype ID
        Id corporateTrainingRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();

        //Iterate through each opportunity
        for (Opportunity oppty : newMap.values()){

            //add the closed won and training opportunity to the set
            if (oppty.StageName == 'Closed Won' && !oldMap.get(oppty.Id).IsWon && oppty.RecordTypeId == corporateTrainingRecordId){
                oppIds.add(oppty.Id);
            }
        }

        //if set is not empty
        if (!oppIds.isEmpty()){
            Set<Id> opportyIdSet = new Set<Id>();
            Set<Id> iltOpportyIdSet = new Set<Id>();

            //Retrieve the OpportunityProducts where Skip_NetSuite_Sync__c is unchecked
            List<OpportunityLineItem> oppLineItemList = [SELECT Id, OpportunityId, Description__c, Start_Date__c, End_Date__c, Training__c, Training__r.Category__c, Skip_NetSuite_Sync__c, Training__r.Is_Dummy_Product__c
                                                         FROM OpportunityLineItem
                                                         WHERE OpportunityId IN:oppIds AND (Skip_NetSuite_Sync__c = false OR (Training__c != null AND Training__r.Category__c = 'Instructor-Led' AND Training__r.Is_Dummy_Product__c = true))];

            //loop to find the oppProducts with description null and then add its opportunity to set
            for (OpportunityLineItem oppLineItem : oppLineItemList){
                if (String.isBlank(oppLineItem.Description__c) && !oppLineItem.Skip_NetSuite_Sync__c){
                    opportyIdSet.add(oppLineItem.OpportunityId);
                }
                if (oppLineItem.Training__c != null && oppLineItem.Training__r.Category__c == 'Instructor-Led' && oppLineItem.Training__r.Is_Dummy_Product__c){
                    iltOpportyIdSet.add(oppLineItem.OpportunityId);
                }
            }

            if (!opportyIdSet.isEmpty() || !iltOpportyIdSet.isEmpty()){

                //Iterate through records
                for (Opportunity oppty : newMap.values()){
                    if (opportyIdSet.contains(oppty.id)){
                        oppty.addError('Please Provide description for its Opportunity Line Item');
                    }
                    if (iltOpportyIdSet.contains(oppty.id)){
                        oppty.addError(Label.Instructor_Led_Products_Error);
                    }
                }
            }
        }
    }

    public void createAddressObjForAccount(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap){
        Set<Id> accountIds = new Set<Id>();
        //Iterate over the new values
        for (Opportunity opp : newMap.values()){
            //For insert and update
            if (oldMap == null || (oldMap.get(opp.Id).AccountId != opp.AccountId || oldMap.get(opp.Id).Bill_To_Account__c != opp.Bill_To_Account__c)){
                //if accountid or billtoaccount is not null then add it to set
                if (opp.AccountId != null){
                    accountIds.add(opp.AccountId);
                }
                if (opp.Bill_To_Account__c != null){
                    accountIds.add(opp.Bill_To_Account__c);
                }
            }
        }
        System.debug(LoggingLevel.INFO, 'accountIds ' + accountIds);
        if (!accountIds.isEmpty()){

            List<Address__c> addressToInsert = new List<Address__c>();
            Boolean alreadyExist = false;
            //Retrieve the Account records with its associated address records
            List<Account> accountList = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, (SELECT Id, Address__c
                                                                                                                                        FROM Addresses__r)
                                         FROM Account 
                                         WHERE Id IN:accountIds AND BillingCity != null AND BillingState != null AND BillingPostalCode != null];
            System.debug(LoggingLevel.INFO, 'accountList ' + accountList);
            //Iterate over the list
            for (Account accnt : accountList){
                //if it has any address record associated with it
                if (accnt.Addresses__r.size() > 0){
                    //Storing the billing address in the form which is stored on address record
                    String billingAddress = (!String.isBlank(accnt.BillingStreet) ? accnt.BillingStreet + ' ' : '') + '<br>' + accnt.BillingCity + ', ' + accnt.BillingState + ' ' + accnt.BillingPostalCode + '<br>' + (!String.isBlank(accnt.BillingCountry) ? accnt.BillingCountry : '');
                    //if the oldAddress of account matches with address record's address do nothing
                    for (Address__c addressObj : accnt.Addresses__r){
                        if (billingAddress == addressObj.Address__c){
                            alreadyExist = true;
                            break;
                        }

                    }

                }
                //if no adddress record found for an account then insert a new address record
                if (!alreadyExist){
                    Address__c addrss = new Address__c();
                    String billToNameString = (accnt.Name + (String.isNotBlank(accnt.BillingCountry) ? ' - ' + accnt.BillingCountry : '')).length() >= 80 ? (accnt.Name + (String.isNotBlank(accnt.BillingCountry) ? ' - ' + accnt.BillingCountry : '')).subString(0, 80) : (accnt.Name + (String.isNotBlank(accnt.BillingCountry) ? ' - ' + accnt.BillingCountry : ''));
                    addrss.Name = billToNameString;
                    addrss.Account__c = accnt.Id;
                    addrss.Street__c = String.isNotBlank(accnt.BillingStreet) ? accnt.BillingStreet : '';
                    addrss.City__c = String.isNotBlank(accnt.BillingCity) ? accnt.BillingCity : '';
                    addrss.State__c = String.isNotBlank(accnt.BillingState) ? accnt.BillingState : '';
                    addrss.Zip_Postal_Code__c = String.isNotBlank(accnt.BillingPostalCode) ? accnt.BillingPostalCode : '';
                    addrss.Country__c = String.isNotBlank(accnt.BillingCountry) ? accnt.BillingCountry : '';
                    addressToInsert.add(addrss);
                }
                alreadyExist = false;
            }
            System.debug(LoggingLevel.INFO, 'addressToInsert ' + addressToInsert);

            //Insert records
            if (!addressToInsert.isEmpty()){

                //SObjectAccessDecision decisionAddressToInsert = Security.stripInaccessible(AccessType.CREATABLE, addressToInsert);
                //insert decisionAddressToInsert.getRecords();
                insert addressToInsert;
            }
        }
    }

    public void updateInvoiceMemoForMembershipLineItems(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap){
        Set<ID> oppIds = new Set<ID>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for (Opportunity opp : newMap.values()){
            if (Opp.RecordTypeID == Label.JoinNow_Opportunity_RecordTypeId && opp.Preferred_Invoice_Method__c != oldMap.get(opp.ID).Preferred_Invoice_Method__c){
                oppIds.add(opp.ID);
            }
        }

        if (!oppIds.isEmpty()){
            Map<ID, OpportunityLineItem> idVsOli = new Map<ID, OpportunityLineItem>([Select ID, NetSuite_Invoice_Memo__c, OpportunityId
                                                                                     FROM OpportunityLineItem
                                                                                     WHERE OpportunityId IN:oppIds]);
            if (!idVsOli.isEmpty()){
                for (OpportunityLineItem oli : idVsOli.Values()){
                    if (newMap.containsKey(oli.OpportunityId)){
                        if (oli.NetSuite_Invoice_Memo__c != newMap.get(oli.OpportunityId).Preferred_Invoice_Method__c){
                            oli.NetSuite_Invoice_Memo__c = newMap.get(oli.OpportunityId).Preferred_Invoice_Method__c;
                            oliList.add(oli);
                        }
                    }
                }
            }
        }
        if (!oliList.isEmpty()){

            //SObjectAccessDecision decisionOliList = Security.stripInaccessible(AccessType.UPDATABLE, oliList);
            //update decisionOliList.getRecords();
            update oliList;
        }
    }

    //method when syncedquoteid is changed or the fields on opp is changed when syncedquoteid != null
    public void oppSyncMethod(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        //initialize variable
        Map<Id, Id> startSyncQuoteMap = new Map<Id, Id>();
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        //Iterate through each record
        for (Opportunity opp : newMap.values()){

            //if syncedquoteid is changed and not null
            if (opp.SyncedQuoteId != oldMap.get(opp.Id).SyncedQuoteId){
                if (opp.SyncedQuoteId != null){
                    startSyncQuoteMap.put(opp.SyncedQuoteId, opp.Id);
                }
                continue;
            }

            //if anything is changed on synced opp that changes should be add on to quote
            if (opp.SyncedQuoteId != null){
                opportunityIds.add(opp.Id);
                quoteIdSet.add(opp.SyncedQuoteId);
            }
        }
        System.debug(LoggingLevel.INFO, opportunityIds + ' ' + quoteIdSet + ' ' + startSyncQuoteMap);
        TriggerStopper.stopOpp = true;
        //if set is not empty then map fields from opp to quote
        if (!opportunityIds.isEmpty()){
            //get all custom fields  of quote that need to be mapped from QuoteSyncUtil class
            Set<String> quoteFields = QuoteSyncUtil.getQuoteFields();
            String quoteFieldsStr = QuoteSyncUtil.getQuoteFieldsString();
            //String query on quote of opp
            String quoteQuery = 'select Id, OpportunityId' + quoteFieldsStr + ' from Quote where Id IN:quoteIdSet';

            List<Quote> quotes = Database.query(String.escapeSingleQuotes(quoteQuery));
            List<Quote> updateQuotes = new List<Quote>();
            //Iterate through each quote
            for (Quote quote : quotes){
                //Get opportunity
                Opportunity opp = newMap.get(quote.OpportunityId);
                boolean hasChange = false;
                //Iterate through each custom field
                for (String quoteField : quoteFields){
                    //get corresponding opportunity field
                    String oppField = QuoteSyncUtil.getQuoteFieldMapTo(quoteField);
                    //get quote and opportunity fields values
                    Object oppValue = opp.get(oppField);
                    Object quoteValue = quote.get(quoteField);
                    //if there is change in value then map to quote
                    if (oppValue != quoteValue){
                        hasChange = true;
                        quote.put(quoteField, oppValue);
                        /* if (oppValue == null) quote.put(quoteField, null);
                         else quote.put(quoteField, oppValue);    */
                    }
                }
                //add to list
                if (hasChange){
                    updateQuotes.add(quote);
                }
            }
            //if list is not empty
            if (!updateQuotes.isEmpty()){
                TriggerStopper.stopQuote = true;
                //update
                Database.update (updateQuotes);
                TriggerStopper.stopQuote = false;
            }
        }

        // if startSyncQuoteMap is not empty then map fields from quotelineitem to oppLineItem
        if (!startSyncQuoteMap.isEmpty()){
            //Get Ids of Opps and its quote from map to use it in string query
            Set<Id> quotesIds = startSyncQuoteMap.keySet();
            List<Id> oppIdList = startSyncQuoteMap.values();

            //Get custom fields of quotelineitem and oppLineItem
            String qliFields = QuoteSyncUtil.getQuoteLineFieldsString();
            String oliFields = QuoteSyncUtil.getOppLineFieldsString();
            Set<String> quoteLineFields = QuoteSyncUtil.getQuoteLineFields();

            //String query on quotelineitem and oppLineItem
            String qliQuery = 'select Id, QuoteId, PricebookEntryId, UnitPrice, Quantity, Discount, SortOrder,OpportunityLineItemId' + qliFields + ' from QuoteLineItem where QuoteId IN:quotesIds order by QuoteId, SortOrder ASC';

            String oliQuery = 'select Id, OpportunityId, PricebookEntryId, UnitPrice, Quantity, Discount, SortOrder' + oliFields + ' from OpportunityLineItem where OpportunityId IN:oppIdList order by OpportunityId, SortOrder ASC';

            //List to store quotelineitem and oppLineItem
            List<QuoteLineItem> qlis = Database.query(String.escapeSingleQuotes(qliQuery));
            List<OpportunityLineItem> olis = Database.query(String.escapeSingleQuotes(oliQuery));

            List<OpportunityLineItem> updateOliSet = new List<OpportunityLineItem>();
            List<OpportunityLineItem> updateOliList = new List<OpportunityLineItem>();
            Map<Id, QuoteLineItem> oppLineItemIDVSQuoteLineItemMap = new Map<Id, QuoteLineItem>();
            if (!qlis.isEmpty()){
                //map of oppLineItem vs its quotelineitem object
                oppLineItemIDVSQuoteLineItemMap = QuoteSyncUtil.getOppLineItemVsQuoteLineItemMap(qlis);
            }

            //Iterate through each oppLineItem
            for (OpportunityLineItem oli : olis){

                //if map contains current oppLineItem
                if (oppLineItemIDVSQuoteLineItemMap.containsKey(oli.Id)){
                    boolean hasChange = false;
                    //Get its QuoteLineItem
                    QuoteLineItem qli = oppLineItemIDVSQuoteLineItemMap.get(oli.Id);
                    //if all the specified fields matches between quotelineitem and oppLineItem
                    if (oli.pricebookentryid == qli.pricebookentryId && oli.UnitPrice == qli.UnitPrice && oli.Quantity == qli.Quantity && oli.Discount == qli.Discount && oli.SortOrder == qli.SortOrder){

                        //Iterate through each custom field
                        for (String qliField : quoteLineFields){
                            //get corresponding opportunityLineItem field
                            String oliField = QuoteSyncUtil.getQuoteLineFieldMapTo(qliField);
                            Object oliValue = oli.get(oliField);
                            Object qliValue = qli.get(qliField);
                            //if there is change in values of fields
                            if (oliValue != qliValue){
                                hasChange = true;
                                oli.put(oliField, qliValue);
                                /*if (qliValue == null) oli.put(oliField, null);
                                 else oli.put(oliField, qliValue); */
                            }
                        }

                        //add to list
                        if (hasChange){
                            updateOliSet.add(oli);
                        }
                    }
                }
            }

            if (!updateOliSet.isEmpty()){
                TriggerStopper.stopQuote = true;
                TriggerStopper.stopOppLine = true;
                TriggerStopper.stopQuoteLine = true;

                //update
                Database.update (updateOliSet);
                TriggerStopper.stopQuote = false;
                TriggerStopper.stopOppLine = false;
                TriggerStopper.stopQuoteLine = false;
            }
        }

        TriggerStopper.stopOpp = false;
    }

    public void validateSubscriptionExpirationDate(Map<Id, Opportunity> newMap){
    }

    //Method to check skip netsuite on lineitem if issccPay checkbox is checked While Closing the Opportunity
    public void checkSkipNSSyncOnProducts(List<Opportunity> oppList, Map<Id, Opportunity> oldMap){
        Set<Id> oppIdSet = new Set<Id>();
        for (Opportunity opty : oppList){
            if (opty.RecordTypeId == corporateTrainingRecordId &&
                opty.Is_CreditCard_Pay__c == 'Yes' &&
             opty.IsWon != oldmap.get(opty.id).IsWon){
                oppIdSet.add(opty.id);
            }
        }
        if (!oppIdSet.isEmpty()){
            List<OpportunityLineItem> oppLineItemList = [SELECT Id
                                                         FROM OpportunityLineItem
                                                         WHERE opportunityID IN:oppIdSet AND Skip_NetSuite_Sync__c = false];
            for (OpportunityLineItem oli : oppLineitemList){
                oli.Skip_NetSuite_Sync__c = true;
            }
            if (!oppLineItemList.isEmpty()){
                update oppLineItemList;
            }
        }
    }

}