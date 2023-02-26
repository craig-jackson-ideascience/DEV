public Class OpportunityProductTriggerHandler implements ITriggerHandler{
    public static Boolean OpportunityProductTriggerRecursion = true;
    OpportunityProductTriggerAction opa = new OpportunityProductTriggerAction();
    //This will handle before delete event
    public void beforeDelete(Map<Id, SObject> oldMap){
        deleteseriesLLCCHildProduct((Map<Id, OpportunityLineItem>)oldMap);
    }

    //This method will handle before insert method
    public void beforeInsert(List<SObject> newItems){
        syncQuoteFields(newItems);
        updateInvoiceMemo((List<OpportunityLineItem>)newItems);
        updateInvoiceMemoForMembershipLineItems((List<OpportunityLineItem>)newItems);
    }

    //This method will handle before update event
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        updateTrainingAndProductDetails((Map<Id, OpportunityLineItem>)newMap, (Map<Id, OpportunityLineItem>)oldMap);
        prorateOpportunityLineItem((List<OpportunityLineItem>)newMap.values(), (Map<Id, OpportunityLineItem>)oldMap);
    }

    public void afterInsert(Map<Id, SObject> newMap){
        insertChildProductDetail((Map<Id, OpportunityLineItem>)newMap);
        opa.updateOpportunityFields((List<OpportunityLineItem>)newMap.values());
        opa.updateOpportunityOwner((List<OpportunityLineItem>)newMap.values());
        updateStartDate((List<OpportunityLineItem>)newMap.values());
        updateEngagementTypeOnOpportunity((Map<Id, OpportunityLineItem>)newMap, null);
        insertContactRoleForIndividualMembership((Map<Id, OpportunityLineItem>)newMap);
        updateFieldsOfBundleAndSubscriptionSubproduct((List<OpportunityLineItem>)newMap.values(), null);
        updateAccountTeamMember((Map<Id, OpportunityLineItem>)newMap);
        UpdateOriginalRenewalAmount((Map<Id, OpportunityLineItem>)newMap);
        updateParentLineItem((Map<Id, OpportunityLineItem>)newMap);
        //call method to sync oppLineItem and QuoteLineItem
        oppLineSyncMethod((Map<Id, OpportunityLineItem>)newMap, null);
        System.debug('starting upsertApiLogs');
        APIRequestLog.upsertApiLogs(Null, newMap, 'OpportunityLineItem', 'INSERT');
        //System.debug('upsertApiLogs completed successfully');
    }

    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        updateFieldsOfBundleAndSubscriptionSubproduct((List<OpportunityLineItem>)newMap.values(), (Map<Id, OpportunityLineItem>)oldMap);
        //call method to sync oppLineItem and QuoteLineItem
        oppLineSyncMethod((Map<Id, OpportunityLineItem>)newMap, (Map<Id, OpportunityLineItem>)oldMap);


        //System.debug('APIRequestLog.alreadyLogged***' + APIRequestLog.alreadyLogged);
        /*if (!APIRequestLog.alreadyLogged){
            System.debug('***Calling Logs***');
            
        }*/
        APIRequestLog.upsertApiLogs(oldMap, newMap, 'OpportunityLineItem', 'UPDATE');
        System.debug('Update starting upsertApiLogs');
    }

    public void afterDelete(Map<Id, SObject> oldMap){
        updateEngagementTypeOnOpportunity(null, (Map<Id, OpportunityLineItem>)oldMap);
        deleteAssociatedProjectRoles((Map<Id, OpportunityLineItem>)oldMap);
        
    }

    public void afterUndelete(Map<Id, SObject> newMap){
    }

    public Boolean IsDisabled(){
        System.debug(TriggerStopper.stopOppLine + '====> TriggerStopper.stopOppLine');
        return TriggerStopper.stopOppLine;
    }

    //method to sync oppLineItem and QuoteLineItem
    private void oppLineSyncMethod(Map<Id, OpportunityLineItem> newMap, Map<Id, OpportunityLineItem> oldMap){
        Set<Id> syncedQuoteIdSet = new Set<Id>();
        //Query to get lineItem whose opportunity is synced
        List<OpportunityLineItem> oppLineItemList = [SELECT ID, Opportunity.SyncedQuoteId
                                                     FROM OpportunityLineItem
                                                     WHERE ID IN :newMap.keySet() AND Opportunity.SyncedQuoteId != null];
        //Iterate through each record
        for (OpportunityLineItem oli : oppLineItemList){
            syncedQuoteIdSet.add(oli.Opportunity.SyncedQuoteId);
        }
        //if set is not empty
        if (!syncedQuoteIdSet.isEmpty()){
            //Get Custom quotelinefields to map
            Set<String> quoteLineFields = QuoteSyncUtil.getQuoteLineFields();
            String qliFields = QuoteSyncUtil.getQuoteLineFieldsString();
            String qliQuery = 'select Id,Related_To__c, QuoteId,OpportunityLineItemId, PricebookEntryId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' + qliFields + ' from QuoteLineItem where QuoteId IN:syncedQuoteIdSet order by QuoteId, SortOrder ASC';
            System.debug('qliQuery ' + qliQuery);
            List<QuoteLineItem> qlis = Database.query(qliQuery);
            Map<Id, QuoteLineItem> oppLineItemIDVSQuoteLineItemMap = new Map<Id, QuoteLineItem>();

            if (!qlis.isEmpty()){
                //map of oppLineItem vs its quotelineitem object
                oppLineItemIDVSQuoteLineItemMap = QuoteSyncUtil.getOppLineItemVsQuoteLineItemMap(qlis);
            }
            List<QuoteLineItem> updateQlis = new List<QuoteLineItem>();
            List<OpportunityLineItem> updateOlis = new List<OpportunityLineItem>();

            //Iterate through each oppLineItem
            for (OpportunityLineItem oli : oppLineItemList){
                if (oppLineItemIDVSQuoteLineItemMap.containsKey(oli.Id)){
                    OpportunityLineItem completeOli = newMap.get(oli.Id);
                    boolean updateQli = false;
                    OpportunityLineItem oldOli = null;
                    //Get its QuoteLineItem
                    QuoteLineItem qli = oppLineItemIDVSQuoteLineItemMap.get(oli.Id);

                    //if all the specified fields matches between quotelineitem and oppLineItem
                    if (completeOli.pricebookentryid == qli.pricebookentryId// && completeOli.Related_To__c == qli.Related_To__c
                     && completeOli.UnitPrice == qli.UnitPrice && completeOli.Quantity == qli.Quantity && completeOli.Discount == qli.Discount && completeOli.ServiceDate == qli.ServiceDate && completeOli.SortOrder == qli.SortOrder){
                        //if update
                        if (oldMap != null){
                            oldOli = oldMap.get(oli.Id);
                            //if condition is true then we will update Quotelineitem
                            if (completeOli.UnitPrice == oldOli.UnitPrice && completeOli.Quantity == oldOli.Quantity && completeOli.Discount == oldOli.Discount && completeOli.ServiceDate == oldOli.ServiceDate && completeOli.SortOrder == oldOli.SortOrder)
                                updateQli = true;
                        }

                        boolean hasChange = false;
                        //Iterate through each custom field
                        for (String qliField : quoteLineFields){
                            //get corresponding opportunityLineItem field
                            String oliField = QuoteSyncUtil.getQuoteLineFieldMapTo(qliField);
                            Object oliValue = completeOli.get(oliField);
                            Object qliValue = qli.get(qliField);
                            //if value is change
                            if (oliValue != qliValue){
                                //if insert or (update and updateQli flag is false) then update oppLineItem
                                if (oldMap == null || (oldMap != null && !updateQli)){
                                    oli.put(oliField, qliValue);
                                    hasChange = true;
                                }
                                //if update and updateQli flag is true then update quoteLineItem
                                else if (oldMap != null && updateQli){
                                    qli.put(qliField, oliValue);
                                    hasChange = true;
                                }
                            }
                        }
                        if (hasChange){
                            //add to list
                            if (oldMap == null || (oldMap != null && !updateQli)){
                                updateOlis.add(oli);
                            } else if (trigger.isUpdate && updateQli){
                                updateQlis.add(qli);
                            }
                        }

                    }
                }
            }
            TriggerStopper.stopOpp = true;
            TriggerStopper.stopQuote = true;
            TriggerStopper.stopOppLine = true;
            TriggerStopper.stopQuoteLine = true;
            if (!updateOlis.isEmpty()){
                //update
                Database.update(updateOlis);
            }

            if (!updateQlis.isEmpty()){
                //update
                Database.update(updateQlis);
            }

            TriggerStopper.stopOpp = false;
            TriggerStopper.stopQuote = false;
            TriggerStopper.stopOppLine = false;
            TriggerStopper.stopQuoteLine = false;
        }
    }

    
    /********************AFTER INSERT**************/
    /*public void afterInsert(List<OpportunityLineItem> newOli){
    //INSERT FREE TRAINING PRODUCT
    //opa.insertFreeTrainingProduct(newOli);
    //INSERT NOTE UNDER OPPORTUNITY IF Required Active LF Membership CHECKBOX = TRUE
    //Commented by Himani G
    //opa.noteInsert(newOli);
    // Method for update opportunity name based on first project/Training/Event And first product
     opa.updateOpportunityFields(newOli);
     }*/
    private void prorateOpportunityLineItem(List<OpportunityLineItem> newOliItems, Map<Id, OpportunityLineItem> oldLineItems){
        //Quantity fields are limited to 2 decimal places via the UI, but can be more via API
        //if quantity is > 2 decimals already, retain this for Prorated records
        for (OpportunityLineItem newOLI : newOliItems){
            OpportunityLineItem oldOpp = oldLineItems.get(newOLI.Id);
            if (newOLI.Renewal_Type__c == 'Prorate'){
                newOLI.Quantity = oldOpp.Quantity;
            } else if (newOLI.Renewal_Type__c != null){
                newOLI.Quantity = 1;
            }
        }
    }

    private void syncQuoteFields(List<OpportunityLineItem> newOliItems){
        if (QuoteSyncUtil.isRunningTest){
            for (OpportunityLineItem oli : newOliItems){
                QuoteSyncUtil.populateRequiredFields(oli);
            }
        }
    }

    private static void updateEngagementTypeOnOpportunity(Map<Id, OpportunityLineItem> newMap, Map<Id, OpportunityLineItem> oldMap){
        Set<Id> opportunityIds = new Set<Id>();
        List<OpportunityLineItem> oliList = oldMap == null ? newMap.values() : oldMap.values();
        for (OpportunityLineItem oli : oliList){
            if (oli.Training__c != null){
                opportunityIds.add(oli.OpportunityId);
            }
        }
        if (!opportunityIds.isEmpty()){
            List<Opportunity> oppToUpdate = new List<Opportunity>();
            List<Opportunity> opportunities = [SELECT Id, (SELECT Id, Training__c, Training__r.DeliveryMode__c, Product2.Type__c
                                                           FROM OpportunityLineItems
                                                           WHERE Training__c != null)
                                               FROM Opportunity
                                               WHERE Id IN :opportunityIds];
            if (!opportunities.isEmpty()){
                for (Opportunity oppty : opportunities){
                    Set<String> engagementTypes = new Set<String>();
                    for (OpportunityLineItem oli : oppty.OpportunityLineItems){
                        engagementTypes.add(oli.Product2.Type__c == 'Instructor-Led' ? oli.Training__r.DeliveryMode__c : oli.Product2.Type__c);
                    }
                    oppty.Engagement_Type__c = string.join(new List<String>(engagementTypes), ';');
                    oppToUpdate.add(oppty);
                }
            }
            if (!oppToUpdate.isEmpty()){
                update oppToUpdate;
            }
        }
    }

    private static void insertContactRoleForIndividualMembership(Map<Id, OpportunityLineItem> newMap){
        List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId, Product2.Name, Opportunity.Billing_Contact__c
                                             FROM OpportunityLineItem
                                             WHERE ID IN :newMap.keySet() AND Product2.Name = 'Individual Membership' AND Opportunity.Account.IsPersonAccount != true AND Opportunity.Billing_Contact__c != null];
        if (!oliList.isEmpty()){
            Map<Id, Id> opportunityIdVsContactIdMap = new Map<Id, Id>();
            Map<Id, Set<String>> opportunityIdVsContactRolesMap = new Map<Id, Set<String>>();

            for (OpportunityLineItem oli : oliList){
                opportunityIdVsContactIdMap.put(oli.OpportunityId, oli.Opportunity.Billing_Contact__c);
            }
            //get list of existing contactRoles
            List<OpportunityContactRole> contactRoles = [SELECT ID, ContactId, OpportunityId
                                                         FROM OpportunityContactRole
                                                         WHERE OpportunityId IN :opportunityIdVsContactIdMap.keySet() AND (ROLE = 'Membership Decision Maker' OR Role = '')];
            if (!contactRoles.isEmpty()){
                for (OpportunityContactRole ocr : contactRoles){
                    if (!opportunityIdVsContactRolesMap.containsKey(ocr.OpportunityId)){
                        opportunityIdVsContactRolesMap.put(ocr.OpportunityId, new Set<String>());
                    }
                    opportunityIdVsContactRolesMap.get(ocr.OpportunityId).add(ocr.ContactId);
                }
            }
            System.debug('opportunityIdVsContactIdMap' + opportunityIdVsContactIdMap);
            System.debug('opportunityIdVsContactRolesMap' + opportunityIdVsContactRolesMap);

            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
            for (Id opptyId : opportunityIdVsContactIdMap.keySet()){
                if (!opportunityIdVsContactRolesMap.containsKey(opptyId) || !opportunityIdVsContactRolesMap.get(opptyId).contains(opportunityIdVsContactIdMap.get(opptyId))){
                    OpportunityContactRole contactRole = new OpportunityContactRole();
                    contactRole.OpportunityId = opptyId;
                    contactRole.ContactId = opportunityIdVsContactIdMap.get(opptyId);
                    contactRole.Role = 'Membership Decision Maker';
                    contactRole.IsPrimary = true;
                    ocrList.add(contactRole);
                }
            }
            if (!ocrList.isEmpty()){
                insert ocrList;
            }
        }
    }

    private static void updateInvoiceMemo(List<OpportunityLineItem> newItems){
        //List<OpportunityLineItem> olisToUpdate = new List<OpportunityLineItem>();
        Set<Id> parentProductIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        for (OpportunityLineItem oli : newItems){
            if (oli.Training__c != null){
                opportunityIds.add(oli.OpportunityId);
            }
        }
        if (!opportunityIds.isEmpty()){
            Map<Id, Opportunity> OpportunityIdVsOpportunity = new Map<Id, Opportunity>([SELECT Id, Corporate_Training_Bundle__c, NetSuite_Invoice_Memo__c
                                                                                        FROM Opportunity
                                                                                        WHERE ID IN :opportunityIds]);
            for (OpportunityLineItem oli : newItems){
                if (oli.Training__c != null && OpportunityIdVsOpportunity.containsKey(oli.OpportunityId)){
                    oli.NetSuite_Invoice_Memo__c = OpportunityIdVsOpportunity.get(oli.OpportunityId).NetSuite_Invoice_Memo__c;
                }
            }
        }
    }

     //This method will update NetSuite_Invoice_Memo__c,Description__c and PO_Number__c fields of E-Learning and Certification olis from Bundle/Subscription Products
     private void updateFieldsOfBundleAndSubscriptionSubproduct(List<OpportunityLineItem> newOliItems, Map<Id, OpportunityLineItem> oldMap){
        Map<Id, Map<Id, OpportunityLineItem>> olisByProductByOpportunityId = new Map<Id, Map<Id, OpportunityLineItem>>();
        Set<Id> parentLineItemIds = new Set<Id>();
        for (OpportunityLineItem oli : newOliItems){
            if (oli.Training__c != null && oli.Parent_Product__c == null && (String.isNotBlank(oli.Description__c) || String.isNotBlank(oli.NetSuite_Invoice_Memo__c) || String.isNotBlank(oli.PO_Number__c)) && (oldMap == null || (oldMap != null && (oli.Description__c != oldMap.get(oli.Id).Description__c || oli.NetSuite_Invoice_Memo__c != oldMap.get(oli.Id).NetSuite_Invoice_Memo__c || oli.PO_Number__c != oldMap.get(oli.Id).PO_Number__c)))){
                if (!olisByProductByOpportunityId.containsKey(oli.OpportunityId)){
                    olisByProductByOpportunityId.put(oli.OpportunityId, new Map<Id, OpportunityLineItem>());
                }
                
                    olisByProductByOpportunityId.get(oli.OpportunityId).put(oli.Id, oli);
                    parentLineItemIds.add(oli.Id);
               
            }
        }
        
        if (!olisByProductByOpportunityId.isEmpty()){
            List<OpportunityLineItem> subOlis = [SELECT Id, Training__r.Category__c, Description__c, NetSuite_Invoice_Memo__c,Training_Category__c,
                                                 PO_Number__c, Parent_Product__c, Opportunity.Corporate_Training_Bundle__c,Parent_OppLineItem__c
                                                 FROM OpportunityLineItem
                                                 WHERE OpportunityId IN :olisByProductByOpportunityId.keySet() AND 
                                                 (Parent_OppLineItem__c IN:parentLineItemIds)];
            if (!subOlis.isEmpty()){
                List<OpportunityLineItem> olisToUpdate = new List<OpportunityLineItem>();
                for (OpportunityLineItem oli : subOlis){
                    if(olisByProductByOpportunityId.get(oli.OpportunityId).containsKey(oli.Parent_OppLineItem__c)){

                        OpportunityLineItem oppLineItem = olisByProductByOpportunityId.get(oli.OpportunityId).get(oli.Parent_OppLineItem__c);
                        if (oli.Description__c != oppLineItem.Description__c){
                            oli.Description__c = oppLineItem.Description__c;
                        }
                        if (oli.PO_Number__c != oppLineItem.PO_Number__c){
                            oli.PO_Number__c = oppLineItem.PO_Number__c;
                        }
                        if (!oli.Opportunity.Corporate_Training_Bundle__c && oli.NetSuite_Invoice_Memo__c != oppLineItem.NetSuite_Invoice_Memo__c){
                            oli.NetSuite_Invoice_Memo__c = oppLineItem.NetSuite_Invoice_Memo__c;
                        }
                        olisToUpdate.add(oli);

                    }
                }
                if (!olisToUpdate.isEmpty()){
                    update olisToUpdate;
                }
            }
        }
    }


    Public static void updateAccountTeamMember(map<Id, OpportunityLineItem> newMap){
        map<Id, AccountTeamMember> mapATM = new map<Id, AccountTeamMember>();
        map<string, Team_Member_for_Project__c> mapTROLI = new map<string, Team_Member_for_Project__c>();
        set<Id> accIds = new set<Id>();
        List<OpportunityLineItem> lstOLIUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lstOLI = [Select id, Opportunity.AccountId, Projects__r.id
                                            from OpportunityLineItem
                                            Where Id IN :newMap.keySet() AND Opportunity.type = 'New Business'];
        System.debug('lstOLI-->' + lstOLI);
        for (OpportunityLineItem objOLI : lstOLI){
            accIds.add(objOLI.Opportunity.AccountId);
        }
        for (AccountTeamMember objATM : [Select id, AccountId, User.Name, User.Title, TeamMemberRole
                                         From AccountTeamMember
                                         Where AccountId IN :accIds]){
            mapATM.put(objATM.id, objATM);
        }
        for (Team_Member_for_Project__c objTROLI : [Select id, Name, Role__c
                                                    from Team_Member_for_Project__c]){
            mapTROLI.put(objTROLI.Name, objTROLI);
        }
        system.debug('mapATM-->' + mapATM);
        id TRFPId;
        for (OpportunityLineItem objOLI : lstOLI){
            Team_Member_for_Project__c objTROLI = mapTROLI.get(objOLI.Projects__r.id);
            if (objTROLI != null){
                for (AccountTeamMember objATM : mapATM.values()){
                    if (objOLI.Projects__r.id == objTROLI.Name && objATM.TeamMemberRole.contains(objTROLI.role__c)){
                        objOLI.Account_Team_Member__c = objATM.User.Name;
                        objOLI.Team_Member_Title__c = objATM.User.Title;
                    }
                }
                lstOLIUpdate.add(objOLI);
            }
        }
        if (!lstOLIUpdate.isEmpty()){
            Update lstOLIUpdate;
        }
    }

    public static void updateInvoiceMemoForMembershipLineItems(List<OpportunityLineItem> newItems){

        Set<ID> oppId = new Set<ID>();
        Map<Id, OpportunityLineItem> updateMap = new Map<Id, OpportunityLineItem>();
        for (OpportunityLineItem oli : newItems){
            if (oli.OpportunityId != NULL){
                oppId.add(oli.OpportunityId);
            }
        }
        Map<Id, Opportunity> idVsOpps = new Map<Id, Opportunity>([Select ID, Preferred_Invoice_Method__c
                                                                  FROM Opportunity
                                                                  WHERE Preferred_Invoice_Method__c != NULL AND ID IN :oppId AND RecordTypeID = :Label.JoinNow_Opportunity_RecordTypeId]);
        if (!idVsOpps.isEmpty()){
            for (OpportunityLineItem oli : newItems){
                if (idVsOpps.containsKey(oli.OpportunityId)){
                    oli.NetSuite_Invoice_Memo__c = idVsOpps.get(oli.OpportunityId).Preferred_Invoice_Method__c;
                }
            }
        }
    }

    public void updateTrainingAndProductDetails(Map<Id, OpportunityLineItem> newMap, Map<Id, OpportunityLineItem> oldMap){
        Set<Id> trainingIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Map<Id, OpportunityLineItem> opportunityLineItemMap = new Map<Id, OpportunityLineItem>();

        for (OpportunityLineItem oppLineItem : newMap.values()){
            //if overwriteTrainingProduct field is changed on lineitem
            if (oppLineItem.Overwrite_Training_Product__c != null && oppLineItem.Overwrite_Training_Product__c != oldMap.get(oppLineItem.Id).Overwrite_Training_Product__c){
                opportunityLineItemMap.put(oppLineItem.Id, oppLineItem);
                trainingIds.add(oppLineItem.Overwrite_Training_Product__c);
                productIds.add(oppLineItem.Product2Id);
            }
        }
        if (!opportunityLineItemMap.isEmpty()){

            //get the product details matching with new training  and products of oppotunitylineitems
            List<Product_details__c> pdetails = [SELECT Id, Training__c, Products__c, Training__r.Category__c, Training__r.StartDateTime__c, Training__r.End_DateTime__c
                                                 FROM Product_details__c
                                                 WHERE Training__c IN :trainingIds AND Products__c IN :productIds];
            if (!pdetails.isEmpty()){
                Map<String, Product_Details__c> productDetailsIdByTrainingAndProducts = new Map<String, Product_Details__c>();
                for (Product_Details__c pd : pdetails){
                    productDetailsIdByTrainingAndProducts.put(pd.Training__c + ' ' + pd.Products__c, pd);
                }
                for (OpportunityLineItem oli : opportunityLineItemMap.values()){
                    if (productDetailsIdByTrainingAndProducts.containsKey(oli.Overwrite_Training_Product__c + ' ' + oli.Product2Id)){
                        //populate new training
                        oli.Training__c = oli.Overwrite_Training_Product__c;
                        //populate new product detail with new training and existing product
                        Product_details__c prodDetail = productDetailsIdByTrainingAndProducts.get(oli.Overwrite_Training_Product__c + ' ' + oli.Product2Id);
                        oli.Product_Details__c = prodDetail.Id;

                        //if training is of instructor led then change the startdate abd enddate
                        if (prodDetail.Training__r.Category__c == 'Instructor-Led'){
                            oli.Start_Date__c = prodDetail.Training__r.StartDateTime__c.date();
                            oli.End_Date__c = prodDetail.Training__r.End_DateTime__c.date();
                        }
                    } else{
                        // if any of the product detail is not found in
                        oli.addError('No Product Detail Found');
                    }
                }

            } else{
                // if no product details found, will throw error
                for (OpportunityLineItem oppLineItem : opportunityLineItemMap.values()){
                    oppLineItem.addError('No Product Detail Found');
                }
            }
        }
    }

    //This method is used to delete associated project roles from Opp Product
    private static void deleteAssociatedProjectRoles(Map<Id, OpportunityLineItem> oldMap){
        set<Id> oppLineItemIds = new Set<Id>();
        oppLineItemIds.addAll(oldMap.keySet());

        //Get related project roles
        List<Project_Role__c> projectRoles = [SELECT Id
                                              FROM Project_Role__c
                                              WHERE Opportunity_Line_Item__c IN :oppLineItemIds];
        System.debug('##projectRoles :' + projectRoles);
        if (!projectRoles.isEmpty()){
            delete projectRoles;
        }
    }

    Public static void UpdateOriginalRenewalAmount(Map<Id, OpportunityLineItem> newMap){
        set<Id> oppIds = new set<Id>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        map<Id, OpportunityLineItem> mapOpportunity = new map<Id, OpportunityLineItem>();
        for (OpportunityLineItem objOLI : newMap.values()){
            oppIds.add(objOLI.OpportunityId);
            mapOpportunity.put(objOLI.OpportunityId, objOLI);
        }
        system.debug('mapOpportunity--->' + mapOpportunity.values());
        for (Opportunity objOpp : [Select Id, Original_Renewal_Amount__c, Type
                                   from Opportunity
                                   Where Id IN :oppIds]){
            OpportunityLineItem objOLI = mapOpportunity.get(objOpp.Id);
            if (objOpp.Type == 'Renewal' && objOpp.Original_Renewal_Amount__c == 0){
                objOpp.Original_Renewal_Amount__c = objOLI.TotalPrice;
                lstOpp.add(objOpp);
            }
        }
        if (lstOpp.size() > 0){
            Update lstOpp;
        }
    }

       //method to populate startdate on membership lineitem
       private void updateStartDate(List<OpportunityLineItem> newList){
        Set<Id> opportunityIdSet = new Set<Id>();
        List<String> productNameToExclude = LABEL.Product_Names_to_Exclude.split(';');
        for (OpportunityLineItem oli : newList){
             //for membership lineitem and startdate is null
            if (oli.projects__c != null){
                opportunityIdSet.add(oli.OpportunityId);
            }
        }

        if (!opportunityIdSet.isEmpty()){
             //Retrieve opportunity and project
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, CloseDate, Project_Name__r.Membership_Start_date__c, Skip_Start_Date_Validation__c
                                                                    ,(SELECT Id,Start_Date__c,Product2.Name,TotalPrice 
                                                                    from opportunitylineitems)
                                                                    FROM Opportunity
                                                                    WHERE Id IN :opportunityIdSet AND Type = 'New Business' 
                                                                    AND RecordType.Name='Membership']);


            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            Map<Id, Opportunity> oppUpdateMap = new Map<Id, Opportunity>();
            for (Opportunity opportunity : oppMap.values()){
                for(OpportunityLineItem oli : opportunity.Opportunitylineitems){

                    //if opportunity skip startdate is unchcked
                    if (!(opportunity.Skip_Start_Date_Validation__c && oli.Start_Date__c != null)){
                        Date closeDate = opportunity.CloseDate;
                        Date startDate;
                        
                        //if project's membership date is in future then the startdate will be project membership start date
                        if (opportunity.Project_Name__c != null && 
                        opportunity.Project_Name__r.Membership_Start_date__c != null && 
                        opportunity.Project_Name__r.Membership_Start_date__c > System.today()){
                            startDate = opportunity.Project_Name__r.Membership_Start_date__c;

                            if (!opportunity.Skip_Start_Date_Validation__c){
                                oppUpdateMap.put(opportunity.Id, new opportunity(Id = opportunity.Id, Skip_Start_Date_Validation__c = true));

                            }
                        } else if (closeDate.day() < 15){
                             //if today's day is less than fifteen then startdate will be 1st of this month
                            startDate = Date.newInstance(closeDate.year(), closeDate.month(), 1);
                        } else{
                             //else startdate will be 1st of next month
                            startDate = Date.newInstance(closeDate.year(), closeDate.month()+1, 1);
                        }
                        oli.Start_Date__c = startDate;
                        System.debug(oli);
                        if(!(productNameToExclude.contains(oli.Product2.Name) && oli.TotalPrice == 0)){
                            
                        oli.End_Date__c = startDate.addYears(1) - 1;
                        System.debug('#--end--#' + oli.End_Date__c);
                        }
                        oliList.add(oli);
                    }
                }
            }

            if (!oppUpdateMap.isEmpty()){
                update oppUpdateMap.values();
            }
            if (!oliList.isEmpty()){
                TriggerStopper.stopOppLine = true;
                update oliList;
                TriggerStopper.stopOppLine = false;
            }
        }
    }
    public static void updateParentLineItem(Map<Id, OpportunityLineItem> newMap){
        Map<String,Id> keyVsLineItemId = new Map<String,Id>();
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        Set<Id> parentProductSet = new Set<Id>();
        for(OpportunityLineItem oppLineItem : newMap.values()){
            if(oppLineItem.Type__c == 'Training' && oppLineItem.Training__c != null &&
               (oppLineItem.Training_Category__c == 'Bundle' 
                || oppLineItem.Training_Category__c=='Subscription')){
                    if(oppLineItem.parent_Product__c == null){
                        keyVsLineItemId.put(oppLineItem.OpportunityId+' '+oppLineItem.Product2Id,oppLineItem.Id);
                    }
                }
        }
        if(!keyVsLineItemId.isEmpty()){
            for(OpportunityLineItem oppLineItem : newMap.values()){
                if(oppLineItem.Type__c == 'Training' && oppLineItem.Training__c != null && 
                   (oppLineItem.Training_Category__c == 'Bundle' 
                    || oppLineItem.Training_Category__c=='Subscription')){
                        if(oppLineItem.parent_Product__c != null && 
                           keyVsLineItemId.containsKey(oppLineItem.OpportunityId+' '+oppLineItem.parent_Product__c)){
                               oppLineItemList.add(new OpportunityLineItem(Id=oppLineItem.Id,
                                                                           Parent_OppLineItem__c=keyVsLineItemId.get(oppLineItem.OpportunityId+' '+oppLineItem.parent_Product__c)));
                           }
                    }
                
            }
            if(!oppLineItemList.isEmpty()){
                TriggerStopper.stopOppLine = true;
                update oppLineItemList;
                TriggerStopper.stopOppLine = false;
            }
        }
    }
    
     //Method to add the child Product detail if parent product detail is added on lineitem
    public static void insertChildProductDetail(Map<Id,OpportunityLineItem> newMap){
        Set<Id> prodDetailIdSet = new Set<Id>();
        Set<Id> oliIdSet  = new Set<Id>();
        
        
        //Iterate and get the productdetails id
        for(OpportunityLineItem oli : newMap.values()){
            if(oli.Product_Details__c != null && oli.Projects__c != null && oli.Business_Type__c == 'New Business'){
                prodDetailIdSet.add(oli.Product_Details__c);
                oliIdSet.add(oli.Id);
                
            }
        }     
        
        if(!prodDetailIdSet.isEmpty()){
            
            //Retrieve the active child productdetail of the productdetail
            List<Product_Details__c> childProdDetailList = [SELECT Parent_Product_Detail__c,products__c,Products__r.tax_class__c,
                                    Products__r.name,Description__c,Tier__c,Start_Tier__c,End_Tier__c,
                                    Price__c,NetSuite_Class__c,toLabel(NS_Department__c),toLabel(NS_Income_GL_Account__c),
                                    toLabel(NS_Revenue_Schedule__c),toLabel(NS_Deferred_Revenue_Account__c),
                                    project__r.name,project__r.status__c,project__r.Payment_Frequency__c,
                                    Renewal_Type__c,project__r.LF_Membership_Required__c,project__r.Membership_Roles_Not_Required__c,
                                    Netsuite_ID__c,project__c,Event__C,duration__c,Training__c , Number_of_Years_Required__c,Products__r.Type__c 
                                    FROM Product_details__c 
                                    WHERE Parent_Product_Detail__c IN: prodDetailIdSet AND Status__c = 'Active'];
            System.debug('#--childProdDetailList--#' + childProdDetailList.size());
            
            if(!childProdDetailList.isEmpty()){
                Set<Id> childProdIdSet  = new Set<Id>();
                Map<Id,List<Product_Details__c>> parentVsChildProductDetail = new Map<Id,List<Product_Details__c>>();
                
                //Iterate and get map of parentproductdatail against the list of childproduct detail
                for(Product_Details__c prodDetail : childProdDetailList){
                    System.debug('prodDetail '+prodDetail);
                    if(!parentVsChildProductDetail.containsKey(prodDetail.Parent_Product_Detail__c)){
                        parentVsChildProductDetail.put(prodDetail.Parent_Product_Detail__c,new List<Product_Details__c>());
                        
                    }parentVsChildProductDetail.get(prodDetail.Parent_Product_Detail__c).add(prodDetail);
                    childProdIdSet.add(prodDetail.products__c);
                }
                
                //Get the pricebookentry for the child product
                Map<ID,ID> productIDtoPricebookEntryID = new Map<ID,ID>();
                if(!childProdIdSet.isEmpty()){
                    system.debug('childProdIdSet '+childProdIdSet);
                    for(PricebookEntry pbe : [SELECT id,product2id,Pricebook2Id 
                                              FROM PricebookEntry 
                                              WHERE product2id IN:childProdIdSet and 
                                              pricebook2.isStandard=true]){
                                                  
                                                  productIDtoPricebookEntryID.put(pbe.product2id,pbe.id);
                                              }
                    
                }
                List<OpportunityLineItem> oliListToInsert = new List<OpportunityLineItem>();
                
                //Iterate
                for(Id oliId : oliIdSet){
                    
                    //LineItem
                    OpportunityLineItem oppLineItem = newMap.get(oliId);
                    
                    //If Child Product detail exist
                    if(parentVsChildProductDetail.containsKey(oppLineItem.Product_Details__c)){
                        
                        //Iterate on child product details
                        for(Product_Details__c pd  : parentVsChildProductDetail.get(oppLineItem.Product_Details__c)){
                            
                            
                            Opportunitylineitem oli = new Opportunitylineitem();
                            
                            //POPULATE STANDARD FIELDS
                            oli.Opportunityid = oppLineItem.opportunityID;
                            oli.UnitPrice = pd.Price__c;
                            oli.Quantity = 1;
                            oli.Parent_OppLineItem__c = oliId;
                            
                            oli.PricebookEntryId = productIDtoPricebookEntryID.get(pd.products__c);
                            
                            //POPULATE CUSTOM FIELDS
                            oli.Product_Details__c = pd.Id;
                            oli.description__c = pd.Description__c;
                            oli.End_Tier__c = pd.End_Tier__c;
                            oli.NetSuite_Class__c = pd.NetSuite_Class__c;
                            oli.NetSuite_Department__c =pd.NS_Department__c;
                            oli.NetSuite_ID__c = pd.NetSuite_ID__c;
                            oli.NetSuite_Income_GL_Account__c = pd.NS_Income_GL_Account__c;
                            oli.NetSuite_Revenue_Schedule__c =pd.NS_Revenue_Schedule__c;
                            oli.NetSuite_Deferred_Revenue_Account__c = pd.NS_Deferred_Revenue_Account__c;
                            
                      
                            if(pd.Number_of_Years_Required__c != null)
                                oli.Number_of_Years_Required__c = Integer.valueOf(pd.Number_of_Years_Required__c);
                            
                            //PROJECT LOOKUP
                            oli.Projects__c = pd.project__c;
                            oli.Renewal_type__c = pd.Renewal_type__c;
                            oli.Skip_NetSuite_Sync__c = pd.Products__r.Type__c == 'Bundle' ? True :FALSE;
                            
                            oli.Project__c = pd.project__r.name;
                            oli.Project_Event_Status__c = pd.project__r.status__c;
                            oli.PaymentFrequency__c =pd.project__r.Payment_Frequency__c;
                            
                            //IF MEMBERSHIP IS OF TYPE DIRECTED FUNDS
                            if(pd.project__r.LF_Membership_Required__c)
                                oli.Required_Active_LF_Membership__c = true;
                            
                            if(pd.project__r.Membership_Roles_Not_Required__c){
                                oli.Skip_NetSuite_Sync__c = true;
                            }
                            
                            oli.Start_Tier__c = pd.Start_Tier__c;
                            oli.Tax_Class__c = pd.Products__r.tax_class__c;
                            oli.Tier__c = pd.Tier__c;
                            oli.type__c=oppLineItem.type__c;
                            oliListToInsert.add(oli);
                           
                        }
                    }
                }
                if(!oliListToInsert.isEmpty()){
                    //insert
                    insert oliListToInsert;
                }
            }
        }
    }

    //Methos to delete the series LLC Child Product if parent Series LLC Product is deleted
    public static void deleteseriesLLCCHildProduct(Map<Id, OpportunityLineItem> oldMap){
        Set<Id> parentOliSet = new Set<Id>();

        //Iterate
        for(OpportunityLineItem oli : oldMap.values()){
            if(oli.project__c != null){
                System.debug('oli.Id '+oli.Id);
                parentOliSet.add(oli.Id);
            }
        }
        
        //set is not empty
        if(!parentOliSet.isEmpty()){
            //Retrieve child lineitems to delete
            List<OpportunityLineItem> oppListTodelete = [SELECT Id 
            FROM OpportunityLineItem WHERE Parent_OppLineItem__c IN: parentOliSet];
            
            if(!oppListTodelete.isEmpty()){
                //delete
                delete oppListTodelete;
            }
        }
    }
}