/********************************************************
* Created by: Himani Goyanka
* Created Date: 11 - 07 - 2019.
* Name: OpportunityClosedWon
* Description: Create Assets on closed won and update those to respective OLI.
* Last Modified by - Tushar Mahadik 8/10/2020
* Added a feature whenever opp closed won then create/update respective Membership Roles with oli and asset details
********************************************************/
public class OpportunityClosedWon {
    
    public static void createAssetOnClosedWon(Map<Id,Opportunity> opportunitiesMap){
        Boolean zeroAmount = False;
        Set<ID> qualifiedOpp = new Set<ID>();
        List<Asset> astToBeInserted = new List<Asset>();
        List<OpportunityLineItem> oliToBeUpdated = new List<OpportunityLineItem>();
        Map<String, id> recordTypeMap = new Map<String, id>();
        Map<ID, OpportunityContactRole> oppConRole = new Map<ID, OpportunityContactRole>();
        Map<ID, OpportunityContactRole> oppConAuthorizedRole = new Map<ID, OpportunityContactRole>();
        Map<id,Id> oliWithParentAssetId = new Map<id,Id>();
        Map<id, asset> oliWithAsset = new Map<id, asset>();
        List<Project_Role__c> projectRoleToInserted = new List<Project_Role__c>();
        Set<Id> QualifiedOLIs = new Set<Id>();
        boolean checkBillingContactEmail = false;
        String opportunityId = '';
        
        //FILTER THE CLOSED OPPORTUNITIES
        for (Opportunity o :opportunitiesMap.values()) {
            system.debug('**o.HasOpportunityLineItem' + o.HasOpportunityLineItem);
            system.debug('**o.isWon' + o.isWon);
            
            if (o.isWon == true && o.HasOpportunityLineItem == true && o.Description != 'Dummy record created so that the Asset will renew') {
                qualifiedOpp.add(o.id);
                opportunityId = o.id;
                //oldStagename =  trigger.oldmap.get(o.id).stagename;
            }
        }
        boolean isMembership = false;
        map<id, boolean> opportunityIDvsBillingContact = new map<id, boolean>();
        map<id, boolean> opportunityIDvsBillingContactEmail = new map<id, boolean>();
        Map<Id, boolean> opportunityIDvsVotingContact = new Map<Id, boolean>();
        
        boolean isBillingContactThere = false;
        system.debug('____qualifiedOpp____' + qualifiedOpp);
        
        // PRIMARY CONTACTROLE FOR QUALIFIED OPPORTUNITIES
        for (OpportunityContactRole oppCon : [SELECT Id, OpportunityId, ContactId, Role,IsPrimary FROM OpportunityContactRole where OpportunityId = :qualifiedOpp AND ContactId != '' AND IsPrimary = true]) {
            oppConRole.put(oppCon.OpportunityId, oppCon);
            
        }

        //Get Existing Project role for validating for Representative/Voting Contact & Billing Contact
        List<String> roleList = new List<String>{'Representative/Voting Contact','Billing Contact'};
        Map<String,Project_Role__c> bilAndVotingprojectRoleMap = new Map<String,Project_Role__c>();
        for(Project_Role__c projectRole : [SELECT Id,Opportunity__c,Opportunity_Line_Item__c,Contact__c,Role__c, 
        Status__c, PrimaryContact__c, Contact__r.Email 
        FROM Project_Role__c WHERE Opportunity__c IN: qualifiedOpp AND PrimaryContact__c = TRUE AND 
        Role__c IN: roleList AND (Status__c = 'Active' OR Status__c = '')]){

            bilAndVotingprojectRoleMap.put(projectRole.Opportunity__c+' '+projectRole.Opportunity_Line_Item__c+' '+projectRole.Role__c,projectRole);
        }
        
        System.debug('bilAndVotingprojectRoleMap ' + bilAndVotingprojectRoleMap);
        System.debug('____oppConRole___' + oppConRole);
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        Map<Id, OpportunityLineItem> mapOfOpportunityLineItem = new Map<Id, OpportunityLineItem>();
        if (!qualifiedOpp.isEmpty()) {
            oppLineItemList = [
                SELECT Billing_Contact__r.email,UnitPrice,Is_Person_Account__c,TotalPrice,Quantity, Billing_Contact__c, PricebookEntry.Product2Id, PricebookEntry.Product2.Name, Description, Converted_to_Asset__c,
                Bill_From__c,Billfrom_ID__c,End_Tier__c,NetSuite_Class__c,NetSuite_Department__c,NetSuite_ID__c,NetSuite_Income_GL_Account__c,Product2.Type__c,
                NetSuite_Revenue_Schedule__c, NetSuite_Invoice_Memo__c,NetSuite_Deferred_Revenue_Account__c,Number_of_Years_Required__c,Start_Tier__c,Tax_Class__c,Tier__c, Year__c, Description__c,
                Opportunity.recordtypeid,Opportunity.recordtype.developername, Opportunity.accountid,Opportunity.account.IsPersonAccount,Opportunity.closeDate, type__c, AgreementDate__c,
                Start_date__c, End_date__c,opportunity.PAL_INVOICE__c,Order__c,Renewal_Type__c, Projects__c,Projects__r.name,event__c,event__r.name,Parent_Product__r.Name,
                Training__c,Training__r.name,PaymentFrequency__c,Skip_NetSuite_Sync__c,PaymentTerms__c,OpportunityId, Opportunity.Account.Name,Opportunity.Individual__c, PO_Number__c,Opportunity.Bill_to_Account__c,Opportunity.Bill_To_Address__c,NS_Entity_Id__c,
                Display_Logo_On_Website__c,No_Press_Release_Announcement__c,Product_Details__r.Price__c,Representative_Voting_Contact__c,CNCF_Level__c,Projects__r.Auto_Renew_Membership__c,Projects__r.Do_not_Invoice__c, Opportunity.Preferred_Invoice_Method__c,
                Send_Invoice_Copy_to_Primary_Contact__c,Parent_Product__c,Opportunity.Billing_Contact__c,Product2.Name,Opportunity.Billing_Contact__r.Name ,Opportunity.Type,
                Opportunity.parent_Asset__c,Projects__r.Status__c,Opportunity.Recordtype.Name,Parent_OppLineItem__c,Class_Development_Revenue__c,
                Authorized_Signatory__c,PO_Contact__c, Technical_Contact__c, Marketing_Contact__c, Press_Contact__c, Legal_Contact__c, Billing_Contact2__c,
                Billing_Contact3__c,Marketing_Contact_2__c, Marketing_Contact_3__c, Technical_Contact_2__c, Technical_Contact_3__c,Sponsorship_Contact__c
                ,Projects__r.Membership_Roles_Not_Required__c,Category__c,currencyisocode ,Zero_Membership__c
                FROM OpportunityLineItem
                WHERE OpportunityId = :qualifiedOpp AND Converted_to_Asset__c = false
            ];  
            //CREATE ASSETS FROM CLOSED OPPORTUNITY'S OPPORTUNITY LINE ITEMS
           for (OpportunityLineItem ol : oppLineItemList) {
            mapOfOpportunityLineItem.put(ol.Id,ol);//This we can use after JOIN Now Changes
                
                QualifiedOLIs.add(ol.Id);
                
                system.debug('___ol__in__For__loop__' + ol);
                
                Asset a = new Asset();
                a.currencyisocode = ol.currencyisocode;

                if(ol.Is_Person_Account__c || ol.Product2.Name == 'Individual Membership'){
                    a.recordtypeid =System.label.Individual_Asset_Record_Type;
                }else{
                    a.recordtypeid = ol.Opportunity.recordtype.developername.contains('Training')? Utility.corporateRecordTypeId  :System.label.Corporate_Asset_Record_Type;
                }
               
                /*if(ol.Opportunity.recordtype.developername != System.label.Ecommerce)
                a.recordtypeid = System.label.Corporate_Asset_Record_Type;
                else
                a.recordtypeid = System.label.Individual_Asset_Record_Type;*/
                
                
                if (ol.Opportunity.recordtype.developerName.equalsIgnoreCase('Membership') || 
                ol.Opportunity.recordtype.developerName.equalsIgnoreCase('Alternate_Funding')){
                    isMembership = true;
                }
                if (isMembership) {
                    if (ol.AgreementDate__c != null) {
                        a.Agreement_Date__c = ol.AgreementDate__c;
                    }
                    String key = ol.OpportunityId+' '+ol.Id;
                    System.debug('key '+key);
                    String billKey = key + ' '+'Billing Contact';
                    System.debug('billKey '+billKey);

                    if(!ol.Projects__r.Membership_Roles_Not_Required__c){
                    //Verify is there Billing Contact Project Role
                    if(!bilAndVotingprojectRoleMap.containsKey(billKey)){
                        system.debug('IN  billing');
                        opportunityIDvsBillingContact.put(ol.opportunityId, false);
                    }else if(bilAndVotingprojectRoleMap.get(billKey).Contact__r.Email == null){
                        opportunityIDvsBillingContactEmail.put(ol.opportunityId, false);
                    }

                    //Verify is there Representative/Voting Contact Project Role
                    String votingKey = key + ' '+'Representative/Voting Contact';
                    System.debug('votingKey '+votingKey+' '+(!bilAndVotingprojectRoleMap.containsKey(votingKey) && !ol.Is_Person_Account__c));
                    if(ol.Product2.Name != 'Individual Membership' && !bilAndVotingprojectRoleMap.containsKey(votingKey) && !ol.Is_Person_Account__c
                    && !ol.Opportunity.recordtype.developerName.equalsIgnoreCase('Alternate_Funding')){
                        system.debug('IN voting');
                        opportunityIDvsVotingContact.put(ol.opportunityId, false);
                    }
                }
                  /*  if (ol.Billing_Contact__c == null) {
                        opportunityIDvsBillingContact.put(ol.opportunityId, false);
                    }
                    if (ol.Billing_Contact__r.email == null) {
                        //checkBillingContactEmail = true;
                        opportunityIDvsBillingContactEmail.put(ol.opportunityId, false);
                    }
                    //check for boting/primary contact
                    if (!ol.Is_Person_Account__c && ol.Representative_Voting_Contact__c == null) {
                        opportunityIDvsVotingContact.put(ol.opportunityId, false);
                    }*/
                    
                } else {
                    if (ol.billing_contact__c != null) {
                        opportunityIDvsBillingContact.put(ol.opportunityId, true);
                    } else if (!(opportunityIDvsBillingContact.containsKey(ol.opportunityid) && opportunityIDvsBillingContact.get(ol.opportunityid))) {
                        opportunityIDvsBillingContact.put(ol.opportunityId, false);
                    }
                    if (ol.billing_contact__r.email != null) {
                        //checkBillingContactEmail = false;
                        opportunityIDvsBillingContactEmail.put(ol.opportunityId, true);
                    } else if (!(opportunityIDvsBillingContactEmail.containsKey(ol.opportunityid) && opportunityIDvsBillingContactEmail.get(ol.opportunityid))) {
                        //checkBillingContactEmail = true;
                        opportunityIDvsBillingContactEmail.put(ol.opportunityId, false);
                    }
                    if (!ol.Is_Person_Account__c && ol.Representative_Voting_Contact__c == null) {
                        opportunityIDvsVotingContact.put(ol.opportunityId, true);
                    }
                }
                
                a.AccountId = ol.Opportunity.accountid;
                a.Product2Id = ol.PricebookEntry.Product2Id;
                a.Quantity = ol.Quantity;
                a.Price = ol.TotalPrice;
                a.PurchaseDate = ol.Opportunity.closeDate;
                a.Status = 'Purchased';
                a.Description = ol.Description__C;
                a.Bill_From__c = ol.Bill_From__c;
                a.Parent_Product__c = ol.Parent_Product__c;
                a.Parent_OppLineItem__c = ol.Parent_OppLineItem__c;
               a.Class_Development_Revenue__c = ol.Class_Development_Revenue__c;
                if (ol.Billfrom_ID__c != null)
                    a.Bill_from_ID__c = Id.ValueOf(ol.Billfrom_ID__c);
                a.NetSuite_Class__c = ol.NetSuite_Class__c;
                a.NetSuite_Department__c = ol.NetSuite_Department__c;
                //a.NetSuite_ID__c = ol.NetSuite_ID__c;
                a.NetSuite_Income_GL_Account__c = ol.NetSuite_Income_GL_Account__c;
                a.NetSuite_Revenue_Schedule__c = ol.NetSuite_Revenue_Schedule__c;
                a.NetSuite_Deferred_Revenue_Account__c = ol.NetSuite_Deferred_Revenue_Account__c;
                a.Number_of_Years_Required__c = ol.Number_of_Years_Required__c;
                a.Tax_Class__c = ol.Tax_Class__c;
                a.Year__c = ol.Year__c;
                a.OpportunityLineItem__c = ol.id;
                a.purchasedate = ol.Opportunity.closedate;
                a.installdate = ol.start_date__c;
                a.usageenddate = ol.end_date__c;
                a.Projects__c = ol.Projects__c;
                a.Training__c = ol.Training__c;
                if(ol.Training__c != null){
                    a.Training_Category__c = ol.Product2.Type__c;
                }
               	a.Category__c = ol.Category__c;
                a.Event__c = ol.Event__c;
                a.Memo__c = ol.NetSuite_Invoice_Memo__c;
                a.Order__c = ol.Order__c;
                a.PaymentFrequency__c = ol.PaymentFrequency__c;
                a.PaymentTerms__c = ol.PaymentTerms__c;
                a.Renewal_Type__c = ol.Renewal_type__c;
                a.Opportunity__c = ol.OpportunityId;
                a.PO_Number__c = ol.PO_Number__c;
                a.Bill_To_Account__c = ol.Opportunity.Bill_To_Account__c;
                a.NS_Entity_Id__c = ol.NS_Entity_ID__c;
                a.PAL_INVOICE__c = ol.opportunity.PAL_INVOICE__c;
                //skip netsuite sync if on oli it is check or totalprice is $0 and opportunity's recordtype is Membership
                a.Skip_NetSuite_Sync__c = ol.Skip_NetSuite_Sync__c ||  (ol.TotalPrice == 0 && ol.Opportunity.Recordtype.Name == 'Membership') ;
                a.Display_Logo_On_Website__c = ol.Display_Logo_On_Website__c;
                a.Press_Release_Announcement__c = ol.No_Press_Release_Announcement__c;
                a.Annual_Full_Price__c = ol.Zero_Membership__c ? ol.UnitPrice :  ol.Product_Details__r.Price__c;
                a.Bill_To_Address__c = ol.Opportunity.Bill_To_Address__c;
                if(ol.Opportunity.RecordType.developername.equalsignorecase('Alternate_Funding')){
                    a.Auto_Renew__c = ol.Renewal_Type__c == 'Renewable' ? true : false;
                }//Added by pratikD Date = 01/12/2020
                else if(ol.End_Date__c != date.newInstance(2099,12,31)){
                    if(ol.Is_Person_Account__c || ol.Product2.Name == 'Individual Membership'){
                        a.Auto_Renew__c = ol.Projects__r.Auto_Renew_Membership__c ? TRUE : FALSE;
                    }else{
                        a.Auto_Renew__c = true;
                    }
                }else{
                    a.Auto_Renew__c =false;
                }
                //a.Auto_Renew__c = !ol.Is_Person_Account__c ? TRUE : ol.Projects__r.Auto_Renew_Membership__c ? TRUE : FALSE; //set autorenew to false for person account
                a.CNCF_Level__c = ol.CNCF_Level__c;//added new Field for Cncf
                a.Send_Invoice_Copy_to_Primary_Contact__c = ol.Send_Invoice_Copy_to_Primary_Contact__c;
                a.Preferred_Invoice_Method__c = ol.Opportunity.Preferred_Invoice_Method__c;
                // ASSIGN CONTACTID AS PRIMARY CONTACT ROLE ID IN ASSET FOR OPPORTUNITIES
                if (ol.Opportunity.recordtype.developername == System.label.Ecommerce && oppConRole != null && oppConRole.containsKey(ol.OpportunityID)) {
                    a.contactid = oppConRole.get(ol.OpportunityID).ContactId;
                    System.debug('____oppConRole ContactId___' + oppConRole.get(ol.OpportunityID).ContactId);
                }
                if(ol.Product2.Name == 'Individual Membership' && oppConRole != null && oppConRole.containsKey(ol.OpportunityID)){
                    a.contactId = oppConRole.get(ol.OpportunityID).ContactId;
                }else if(ol.Product2.Name == 'Individual Membership'){
                   a.contactId = ol.Opportunity.Billing_Contact__c;
                }
                
                system.debug('_____project_________' + ol.projects__c);
                system.debug('____event________' + ol.event__c);
                system.debug('____training________' + ol.Training__c);
                
                String assetName = '';
                
                if (ol.projects__c != null) {                    
                    assetName = ol.Product2.Name == 'Individual Membership' ? ol.opportunity.Billing_Contact__r.name + ' - ' + ol.projects__r.name :ol.opportunity.account.name + ' - ' + ol.projects__r.name;
                } else if (assetName == '' && ol.event__c != null) {
                    assetName = ol.opportunity.account.name + ' - ' + ol.event__r.name;
                } else if (assetName == '' && ol.Training__c != null) {
                    assetName = ol.opportunity.account.name + ' - ' + ol.Training__r.name;
                }
                
                system.debug('______assetName_________' + assetName);
                a.Name = assetName != '' ? assetName + ' - ' + ol.PricebookEntry.Product2.Name : ol.PricebookEntry.Product2.Name;
                
                if (a.Year__c != null)
                    a.Name = a.Name + ' - ' + a.Year__c;
                
                if (ol.Start_Tier__c != null || ol.End_Tier__c != null) {
                    if (ol.End_Tier__c != null)
                        a.Tier__c = String.valueOf(ol.Start_Tier__c) + ' - ' + String.valueOf(ol.End_Tier__c); else
                            a.Tier__c = String.valueOf(ol.Start_Tier__c);
                } else if (ol.Tier__c != null) {
                    a.Tier__c = ol.Tier__c;
                }
                
                system.debug('______assetName_________' + assetName);
                a.Name = assetName != '' ? assetName + ' - ' + ol.PricebookEntry.Product2.Name : ol.PricebookEntry.Product2.Name;
                
                if (a.Year__c != null)
                    a.Name = a.Name + ' - ' + a.Year__c;
                
                if(ol.Opportunity.Individual__c) {
                    a.AccountID = Label.JoinNowIndividual_DefaultAccount;
                    a.RecordTypeID = System.label.Individual_Asset_Record_Type;
                    a.ContactID = ol.Opportunity.Billing_Contact__c;
                    a.Name  =  ol.opportunity.Billing_Contact__r.name + ' - ' + ol.projects__r.name + ' - '+ol.PricebookEntry.Product2.Name;
                } 
                astToBeInserted.add(a);
                
                //UPDATE THE OPPORTUNITY LINE ITEM'S CONVERTED TO ASSET FIELD AS TRUE
                oliToBeUpdated.add(new OpportunityLineItem(id = ol.id, Converted_to_Asset__c = true));
            }
        }
        for (Opportunity opp : opportunitiesMap.values()) {
            
            if (opp.Amount == 0) {
                zeroAmount = True;
            }
            System.debug('zeroAmount '+zeroAmount);
            if (!zeroAmount) {
                if (opportunityIDvsBillingContact.containsKey(opp.id) && !opportunityIDvsBillingContact.get(opp.id)) {
                    opportunitiesMap.get(opp.id).addError(Label.Billing_Contact_Required);
                } else if (opportunityIDvsBillingContactEmail.containsKey(opp.id) && !opportunityIDvsBillingContactEmail.get(opp.id)) {
                    opportunitiesMap.get(opp.id).addError('Billing Contact Email is required');
                }
            }
            
            if (opportunityIDvsVotingContact.containsKey(opp.id) && !opportunityIDvsVotingContact.get(opp.id)) {
                opportunitiesMap.get(opp.id).addError(Label.Voting_Contact_Required);
            }
        }
        if (!oliToBeUpdated.isEmpty())
            update oliToBeUpdated;

         set<Id> setOfAssetIds = new set<Id>();
        if (!astToBeInserted.isEmpty()) {
            insert astToBeInserted;
            for (Asset asst : astToBeInserted) {
                setOfAssetIds.add(asst.id);
                system.debug('____asst_id___' + asst.Id + '___oli___' + asst.OpportunityLineItem__c);
                if (asst.OpportunityLineItem__c != null)
                    oliWithAsset.put(asst.OpportunityLineItem__c, asst);
            }
        }
       
        map<string, string> assetWithAccount = new map <string, string>();
        system.debug('_____oliToBeUpdated____' + oliToBeUpdated);
        System.debug('____astToBeInserted____ ' + astToBeInserted);

        Map<String,List<Project_Role__c>> oliWithProjectRolesList = new Map<String, List<Project_Role__c>>();
        Map<String,Map<String,List<Project_Role__c>>> oliWithProjectRole = new Map<String, Map<String, List<Project_Role__c>>>();
        
        
        System.debug('##QualifiedOLIs :'+QualifiedOLIs);
        if (!qualifiedOpp.isEmpty() && QualifiedOLIs != null && QualifiedOLIs.size() > 0) {
           
            //Below Code we can use after JOIN Now Changes
            /*Map<String,List<Project_Role__c>> oliWithProjectRoles = new Map<String, List<Project_Role__c>>();

            //GET EXISTING PROJECT ROLES FOR QUALIFIED OPPORTUNITY LINE ITEMS
            for(Project_Role__c pRole :[SELECT Id,Asset__c,Contact__c,Role__c, Status__c, PrimaryContact__c, Start_Date__c, End_Date__c, Opportunity_Line_Item__c FROM Project_Role__c WHERE Opportunity_Line_Item__c != null AND
                                              Opportunity_Line_Item__c =: QualifiedOLIs AND (Status__c = 'Active' OR Status__c = '') ]){
                System.debug('##pRole :'+pRole);
                if(!oliWithProjectRoles.containsKey(pRole.Opportunity_Line_Item__c)){
                    oliWithProjectRoles.put(pRole.Opportunity_Line_Item__c, new List<Project_Role__c>());
                }
                oliWithProjectRoles.get(pRole.Opportunity_Line_Item__c).add(pRole);
            }*/

            //GET EXISTING PROJECT ROLES FOR QUALIFIED OPPORTUNITY LINE ITEMS
            for(Project_Role__c pRole :[SELECT Id,Asset__c,Contact__c,Role__c, Status__c, PrimaryContact__c, Start_Date__c, End_Date__c, Opportunity_Line_Item__c FROM Project_Role__c WHERE Opportunity_Line_Item__c != null AND
            Opportunity_Line_Item__c =: QualifiedOLIs AND (Status__c = 'Active' OR Status__c = '') ]){

                //THIS map is for update additional roles which don't have Contact Lookup on Opp Product
                if(!oliWithProjectRolesList.containsKey(pRole.Opportunity_Line_Item__c)){
                    oliWithProjectRolesList.put(pRole.Opportunity_Line_Item__c, new List<Project_Role__c>());
                }
                oliWithProjectRolesList.get(pRole.Opportunity_Line_Item__c).add(pRole);
            }

            System.debug('##oliWithAsset :'+oliWithAsset);
            
            System.debug('##oliWithProjectRole :'+oliWithProjectRole);

            Set<String> oliIdRoleContactStringSet = new Set<String>();
            //Assign remaining Projects Roles which are not existed as Lookup on OLI
            if(!oliWithProjectRolesList.isEmpty()){
                for(String oliString : oliWithProjectRolesList.keySet()){
                    List<Project_Role__c> pRolesList = oliWithProjectRolesList.get(oliString);
                    OpportunityLineItem oppProduct = mapOfOpportunityLineItem.get(oliString); //Get Product
                    for(Project_Role__c projectRole : pRolesList){
                        String uniqueKey = projectRole.Opportunity_Line_Item__c+' '+projectRole.role__c+' '+projectRole.Contact__c;  
                        oliIdRoleContactStringSet.add(uniqueKey);
                        
                        //This condition check for all existing Project roles for respective OLI. If it already not taken care then update from here.
                        
                           // System.debug('updating prole'+projectRole);
                            if(projectRole.Start_Date__c == null || projectRole.Start_Date__c != oppProduct.Start_Date__c) //Check current SD on Project Role is empty then take a date from Order Product,  or there will change in PR Date and Opp Product Date
                                projectRole.Start_Date__c = oppProduct.Start_Date__c;
                            
                            if(projectRole.End_Date__c == null || projectRole.End_Date__c != oppProduct.End_Date__c)//Check current ED on Project Role is empty then take a date from Order Product,  or there will change in PR Date and Opp Product Date
                                projectRole.End_Date__c = oppProduct.End_Date__c;
                            
                            projectRole.Asset__c = oliWithAsset.get(oppProduct.id).id;
                            System.debug('updating prole'+projectRole);
                            projectRoleToInserted.add(projectRole);
                        
                    }
                }
            }

            //CREATE PROJECT ROLE FROM CLOSED OPPORTUNITY'S OPPORTUNITY LINE ITEMS
            /*for (OpportunityLineItem ol : oppLineItemList) {
                
                //For New Opportunity check there are already project roles are existed or not if yes then update those with Asset Id or create new role in case of Billing Contact and Voting Contact
                //For New Opportunity, create/update Project roles form line items
                if(oliWithAsset.containsKey(ol.id) && oliWithAsset.get(ol.id).id != null && ol.Project__c != null){
                    
                    if (ol.Representative_Voting_Contact__c != null) {
                        String key = ol.Id+' '+'Representative/Voting Contact'+' '+ol.Representative_Voting_Contact__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Representative/Voting Contact',ol,oliWithAsset,true,ol.Representative_Voting_Contact__c);
                            projectRoleToInserted.add(pr);
                            
                        }                        
                    }
                    
                    if (ol.Technical_Contact__c != null) {
                        String key = ol.Id+' '+'Technical Contact'+' '+ol.Technical_Contact__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Technical Contact',ol,oliWithAsset,true,ol.Technical_Contact__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    if (ol.Marketing_Contact__c != null) {
                        String key = ol.Id+' '+'Marketing Contact'+' '+ol.Marketing_Contact__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Marketing Contact',ol,oliWithAsset,true,ol.Marketing_Contact__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    if (ol.Press_Contact__c != null) {
                        String key = ol.Id+' '+'Press Contact'+' '+ol.Press_Contact__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Press Contact',ol,oliWithAsset,true,ol.Press_Contact__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    if (ol.Legal_Contact__c != null) {
                        String key = ol.Id+' '+'Legal Contact'+' '+ol.Legal_Contact__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Legal Contact',ol,oliWithAsset,true,ol.Legal_Contact__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    if (ol.Billing_Contact__c != null) {
                        String key = ol.Id+' '+'Billing Contact'+' '+ol.Billing_Contact__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Billing Contact',ol,oliWithAsset,true,ol.Billing_Contact__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    if (ol.Billing_Contact2__c != null) {
                        String key = ol.Id+' '+'Billing Contact'+' '+ol.Billing_Contact2__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Billing Contact',ol,oliWithAsset,false,ol.Billing_Contact2__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    if (ol.Billing_Contact3__c != null) {
                        String key = ol.Id+' '+'Billing Contact'+' '+ol.Billing_Contact3__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Billing Contact',ol,oliWithAsset,false,ol.Billing_Contact3__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    if (ol.Marketing_Contact_2__c != null) {
                        String key = ol.Id+' '+'Marketing Contact'+' '+ol.Marketing_Contact_2__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Marketing Contact',ol,oliWithAsset,false,ol.Marketing_Contact_2__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    if (ol.Marketing_Contact_3__c != null) {
                        String key = ol.Id+' '+'Marketing Contact'+' '+ol.Marketing_Contact_3__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Marketing Contact',ol,oliWithAsset,false,ol.Marketing_Contact_3__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    if (ol.Technical_Contact_2__c != null) {
                        String key = ol.Id+' '+'Technical Contact'+' '+ol.Technical_Contact_2__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Technical Contact',ol,oliWithAsset,false,ol.Technical_Contact_2__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    if (ol.Technical_Contact_3__c != null) {
                        String key = ol.Id+' '+'Technical Contact'+' '+ol.Technical_Contact_3__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Technical Contact',ol,oliWithAsset,false,ol.Technical_Contact_3__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    if (ol.PO_Contact__c != null) {
                        String key = ol.Id+' '+'PO Contact'+' '+ol.PO_Contact__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('PO Contact',ol,oliWithAsset,true,ol.PO_Contact__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    
                    if (ol.Authorized_Signatory__c != null) {
                        String key = ol.Id+' '+'Authorized Signatory'+' '+ol.Authorized_Signatory__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Authorized Signatory',ol,oliWithAsset,true,ol.Authorized_Signatory__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    
                    if (ol.Sponsorship_Contact__c != null) {
                        String key = ol.Id+' '+'Event Sponsorship'+' '+ol.Sponsorship_Contact__c;
                        if(!oliIdRoleContactStringSet.contains(key)){
                            Project_Role__c pr = createProjectRole('Event Sponsorship',ol,oliWithAsset,true,ol.Sponsorship_Contact__c);
                            projectRoleToInserted.add(pr);
                        }
                    }
                    
                }
                
                System.debug('projectRoleToInserted: ' + projectRoleToInserted);
                
            }*/
            

           



            //Below code we can use after JOIN Now Changes
            /*if(oliWithProjectRoles != null && mapOfOpportunityLineItem != null && !mapOfOpportunityLineItem.keySet().isEmpty()){//Only for New Business
                for(String oli : oliWithProjectRoles.keySet()){
                    OpportunityLineItem oppProduct = mapOfOpportunityLineItem.get(oli); //Get Product
                    List<Project_Role__c> pRolesList = oliWithProjectRoles.get(oli);
                    set<String> allRoles = new Set<String>();
                    for(Project_Role__c projectRole : pRolesList){
                        allRoles.add(projectRole.Role__c);
                        if(projectRole.Start_Date__c == null || projectRole.Start_Date__c != oppProduct.Start_Date__c) //Check current SD on Project Role is empty then take a date from Order Product,  or there will change in PR Date and Opp Product Date
                            projectRole.Start_Date__c = oppProduct.Start_Date__c;

                        if(projectRole.End_Date__c == null || projectRole.End_Date__c != oppProduct.End_Date__c)//Check current ED on Project Role is empty then take a date from Order Product,  or there will change in PR Date and Opp Product Date
                            projectRole.End_Date__c = oppProduct.End_Date__c;

                        projectRole.Asset__c = oliWithAsset.get(oppProduct.id).id;

                        projectRoleToInserted.add(projectRole);
                    }
                    //This logic for required OLI Contacts Like Voting Contact, Billing Contact, Authorized Signatory
                    //If there is no project roles for below specified roles then create the roles
                    for(String role : allRoles){
                        if(!allRoles.contains('Representative/Voting Contact')){
                            if(oppProduct.Representative_Voting_Contact__c != null){
                                projectRoleToInserted.add(createRole('Representative/Voting Contact',oppProduct.Representative_Voting_Contact__c, oppProduct, true, oliWithAsset));
                            }
                        }
                        if(!allRoles.contains('Billing Contact')){
                            if(oppProduct.Billing_Contact__c != null){
                                projectRoleToInserted.add(createRole('Billing Contact',oppProduct.Billing_Contact__c, oppProduct, false, oliWithAsset));
                            }
                        }
                        if(!allRoles.contains('Billing Contact 2')){
                            if(oppProduct.Billing_Contact2__c != null){
                                projectRoleToInserted.add(createRole('Billing Contact 2',oppProduct.Billing_Contact2__c, oppProduct, false, oliWithAsset));
                            }
                        }
                        if(!allRoles.contains('Billing Contact 3')){
                            if(oppProduct.Billing_Contact3__c != null){
                                projectRoleToInserted.add(createRole('Billing Contact 3',oppProduct.Billing_Contact3__c, oppProduct, false, oliWithAsset));
                            }
                        }
                        if(!allRoles.contains('Authorized Signatory')){
                            if(oppProduct.Authorized_Signatory__c != null){
                                projectRoleToInserted.add(createRole('Authorized Signatory',oppProduct.Authorized_Signatory__c, oppProduct, false, oliWithAsset));
                            }
                        }
                    }
                }
            }*/
        }
        
        system.debug('____projectRoleToInserted____' + projectRoleToInserted.size());
        
        if (!projectRoleToInserted.isEmpty()) {
            upsert projectRoleToInserted;
        }

        if (!astToBeInserted.isEmpty()) {
            
            if (!System.isFuture() && !System.isBatch() && zeroAmount == False) {
                if (isMembership) {
                    
                    NSAssetTriggerHelper.checkRecordTypeAndCallNS(setOfAssetIds, opportunityId, opportunitiesMap);

                    system.debug('**Member**');
                } else {
                    if (astToBeInserted[0].Skip_NetSuite_Sync__c == False) {
                        NSAssetTriggerHelper.checkRecordTypeAndCallNS1(astToBeInserted[0].id, opportunityId, opportunitiesMap);
                        system.debug('**Event**');
                        system.debug('**astToBeInserted' + astToBeInserted[0].id);
                    } else {
                        list <Asset> assetObjList = new list <Asset>();
                        assetObjList = [Select id from Asset where Opportunity__c = :astToBeInserted[0].Opportunity__c AND Skip_NetSuite_Sync__c = False Limit 1];
                        if (!assetObjList.isEmpty()) {
                            NSAssetTriggerHelper.checkRecordTypeAndCallNS1(assetObjList[0].id, opportunityId, opportunitiesMap);
                            system.debug('**Event Else**');
                            system.debug('**assetObjList[0]' + assetObjList[0].id);
                        }
                    }
                }
            }
        }

        //This Logic is used to update the Send_to_Groups_io__c checkbox when PurchaseHistory Status = Active
        List<String> assetIds = new List<String>();
        set<String> projectIds = new set<String>();
        Map<Id, String> mapContactProjectRole = new Map<Id, String>();
        Map<String, String> mapCampaignMemberRole = new Map<String, String>();
        List<Project_Role__c> updProjectRoles = new List<Project_Role__c>();
        
        for(Asset asset : astToBeInserted){
            assetIds.add(asset.id);
            if(asset.Projects__c != null){
                projectIds.add(asset.Projects__c);
            }
        }
        system.debug('projectIds....'+projectIds.size()+ ' projectIds....'+projectIds);
        
        List<Project_Role__c> lstProjectRoles = [Select Id, Contact__c, Send_to_Groups_io__c, Role__c, Asset__c from Project_Role__c where Asset__r.id IN :assetIds];
        system.debug('lstProjectRoles....'+lstProjectRoles);
        for(Project_Role__c pro : lstProjectRoles){
            if(pro.Role__c == 'Representative/Voting Contact'){
                mapCampaignMemberRole.put(pro.Role__c, 'Voting Contact');
            }
            else{
                mapCampaignMemberRole.put(pro.Role__c, pro.Role__c);
            }          
        }
       system.debug('mapCampaignMemberRole....'+mapCampaignMemberRole);
        
       if(!projectIds.isEmpty()){
        list<Campaign> campaignList = [SELECT Id, Project__c, Type, (Select Campaign.Type, Campaign.Project__c, Subscription__c, Project_Role_Subscriptions__c, ContactId from CampaignMembers where  Subscription__c = 'Subscribe') FROM Campaign WHERE Project__c IN: projectIds AND Type = 'Web Form - Join Now'];
        //List<CampaignMember> campaignMembers = [Select Campaign.Type, Campaign.Project__c, Subscription__c, Project_Role_Subscriptions__c, ContactId from CampaignMember where Campaign.Project__c IN : projectIds AND Campaign.Type = 'Web Form - Join Now' AND Subscription__c = 'Subscribe'AND CampaignId ='7012M000001JHyjQAG' limit 50000];
        system.debug(campaignList.size() + ' campaignList....'+campaignList);
        
        if(!campaignList.isEmpty()){
            for(Campaign camp: campaignList){
                for(CampaignMember cp : camp.CampaignMembers){
                    mapContactProjectRole.put(cp.ContactId, cp.Project_Role_Subscriptions__c);
                }
            }
            system.debug('mapContactProjectRole....'+mapContactProjectRole);
            
            for (Asset asset: astToBeInserted) {
                if(String.isNotBlank(asset.Status)){
                    for(Project_Role__c pr : lstProjectRoles){
                        if(!updProjectRoles.contains(pr)) {
                            //system.debug('if => :::: ' + mapContactProjectRole.get(pr.Contact__c).contains(mapCampaignMemberRole.get(pr.Role__c)));
                            if(String.isNotBlank(mapContactProjectRole.get(pr.Contact__c)) && String.isNotBlank(mapCampaignMemberRole.get(pr.Role__c)) && mapContactProjectRole.get(pr.Contact__c).contains(mapCampaignMemberRole.get(pr.Role__c))){
                                pr.Send_to_Groups_io__c = true;
                                updProjectRoles.add(pr);
                            }
                        }
                    }
                }
            }
            
            if(!updProjectRoles.isEmpty()){
                update updProjectRoles;
            }
        }
    }
}

    //Below code we can use after JOIN Now Changes
    /*private static Project_Role__c createRole(String role, Id contactId, OpportunityLineItem oppProduct, Boolean isPrimary, Map<Id, Asset> oliWithAsset){
        Project_Role__c projectRole = new Project_Role__c(Contact__c = contactId, Role__c = role, Asset__c = oliWithAsset.get(oppProduct.id).id,
                Start_Date__c = oppProduct.Start_Date__c, End_Date__c = oppProduct.End_Date__c,PrimaryContact__c = isPrimary, Opportunity_Line_Item__c = oppProduct.Id, Opportunity__c = oppProduct.OpportunityId);
        return projectRole;
    }*/
    /*private static Project_Role__c createProjectRole(String role,OpportunityLineItem oppProduct, Map<Id, Asset> oliWithAsset, Boolean isPrimary, Id contactId){
        Project_Role__c pr = new Project_Role__c(Contact__c = contactId, Role__c = role, Asset__c = oliWithAsset.get(oppProduct.id).id,
                                     Start_Date__c = oppProduct.Start_Date__c, End_Date__c = oppProduct.End_Date__c,PrimaryContact__c = isPrimary, Opportunity_Line_Item__c = oppProduct.Id, Opportunity__c = oppProduct.OpportunityId);
          System.debug('NEW Prole'+pr);
          return pr;
          
      }

    private static List<Project_Role__c> getProjectRole(String role,OpportunityLineItem oppProduct, Map<Id, Asset> oliWithAsset, Boolean isPrimary, Id contactId, Map<String,Map<String,List<Project_Role__c>>> oliWithProjectRole){
        List<Project_Role__c> pRoles = new List<Project_Role__c>();
        if(oliWithProjectRole != null && oliWithProjectRole.containsKey(oppProduct.Id)){
            Map<String,List<Project_Role__c>> mapOfProjectRole = oliWithProjectRole.get(oppProduct.Id);
            if(mapOfProjectRole.containsKey(role)){
                //pRoles = mapOfProjectRole.get(role);
                System.debug('pRoles before: ' + pRoles);
                for(Project_Role__c projectRole :mapOfProjectRole.get(role)){
                    if(projectRole.Contact__c == contactId) {
                if(projectRole.Start_Date__c == null || projectRole.Start_Date__c != oppProduct.Start_Date__c) //Check current SD on Project Role is empty then take a date from Order Product, or there will change in PR Date and Opp Product Date
                    projectRole.Start_Date__c = oppProduct.Start_Date__c;

                if(projectRole.End_Date__c == null || projectRole.End_Date__c != oppProduct.End_Date__c)//Check current ED on Project Role is empty then take a date from Order Product, or there will change in PR Date and Opp Product Date
                    projectRole.End_Date__c = oppProduct.End_Date__c;

                projectRole.Asset__c = oliWithAsset.get(oppProduct.id).id;
                        pRoles.add(projectRole);
                    }
                }

            }else { //Create a Project Role if it is not there.
                pRoles.add(new Project_Role__c(Contact__c = contactId, Role__c = role, Asset__c = oliWithAsset.get(oppProduct.id).id,
                        Start_Date__c = oppProduct.Start_Date__c, End_Date__c = oppProduct.End_Date__c,PrimaryContact__c = isPrimary, Opportunity_Line_Item__c = oppProduct.Id, Opportunity__c = oppProduct.OpportunityId));
                System.debug('pRoles 1st If: ' + pRoles);
            }
        }else { //Create a Project Role if it is not there.
            pRoles.add(new Project_Role__c(Contact__c = contactId, Role__c = role, Asset__c = oliWithAsset.get(oppProduct.id).id,
                    Start_Date__c = oppProduct.Start_Date__c, End_Date__c = oppProduct.End_Date__c,PrimaryContact__c = isPrimary, Opportunity_Line_Item__c = oppProduct.Id, Opportunity__c = oppProduct.OpportunityId));
            System.debug('pRoles 2nd If: ' + pRoles);
        }
        System.debug('##projectRole after:'+pRoles);
        return pRoles;
    }*/
}