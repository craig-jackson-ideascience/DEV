public class ProjectRoleTriggerHandler implements ITriggerHandler{
    public static Boolean ProjectRoleTHRecursion = false;
    public static void BeforeInsert(List<SObject> triggerNew){
        //call before insert actions
        // updateSendDate(triggerNew);
        updateAlternateEmail((List<Project_Role__c>)triggerNew, null);

        /*Added By Priyesh @CloudRoute to populate the opportunity and lines items on project role when created from join now with asset*/
        populateOpportunityAndLineItem((List<Project_Role__c>)triggerNew);
    }

    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap){
        //call before update actions
        updateAlternateEmail((List<Project_Role__c>)newMap.values(), (Map<Id, Project_Role__c>)oldMap);
    }

    public static void BeforeDelete(Map<Id, Sobject> oldMap){
        //call before delete actions
    }

    public static void AfterInsert(Map<Id, SObject> newMap){
        //call onAfterInsert delete actions
        //updateProjectTeam((Map<Id, Project_Role__c>)newMap, null);
        updateAuthorisedOnOpportunity((Map<Id, Project_Role__c>)newMap, null);
        upsertRolesToOpenRenewalOpp((Map<Id, Project_Role__c>)newMap, null);
        if (!ProjectRoleTHRecursion){
            addRolesToParentAssetForRenewal((Map<Id, Project_Role__c>)newMap, null);
            
        }
    }

    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){
        //call onAfterUpdate update actions
        //updateProjectTeam((Map<Id, Project_Role__c>)newMap, (Map<Id, Project_Role__c>)oldMap);
        updateAuthorisedOnOpportunity((Map<Id, Project_Role__c>)newMap, (Map<Id, Project_Role__c>)oldMap);
        upsertRolesToOpenRenewalOpp((Map<Id, Project_Role__c>)newMap, (Map<Id, Project_Role__c>)oldMap);
        if (!ProjectRoleTHRecursion){
            addRolesToParentAssetForRenewal((Map<Id, Project_Role__c>)newMap, (Map<Id, Project_Role__c>)oldMap);
           
        }
    }

    public static void AfterDelete(Map<Id, Sobject> oldMap){
        //call onAfterDelete update actions
        upsertRolesToOpenRenewalOpp(null, (Map<Id, Project_Role__c>)oldMap);

        //updateProjectTeam(null, (Map<Id, Project_Role__c>)oldMap);
    }

    public static void AfterUnDelete(Map<Id, Sobject> newMap){
        //call after onAfterUnDelete actions
        //updateProjectTeam((Map<Id, Project_Role__c>)newMap, null);
    }

    public Boolean IsDisabled(){
        return false;
    }

    //method to update authorised contact on opportunity
    private static void updateAuthorisedOnOpportunity(Map<Id, Project_Role__c> newMap, Map<Id, Project_Role__c> oldMap){
        System.debug('In');
        Set<Id> oppIdSet = new Set<Id>();
        for (Project_Role__c pRole : newMap.values()){
            if (pRole.PrimaryContact__c && pRole.Role__c == 'Authorized Signatory' && pRole.Opportunity__c != null && pRole.Status__c == 'Active' && 
                                                         (oldMap == null || (oldMap.get(pRole.Id).PrimaryContact__c != pRole.PrimaryContact__c || oldMap.get(pRole.Id).Status__c != pRole.Status__c || oldMap.get(pRole.Id).Contact__c != pRole.Contact__c))){
                system.debug('pRole.Opportunity__c ' + pRole.Opportunity__c);
                oppIdSet.add(pRole.Opportunity__c);
            }
        }
        if (!oppIdSet.isEmpty()){
            /* List<Opportunity> updateOpportunity = new List<Opportunity>();
             List<Opportunity> oppList = [SELECT Id,
             (SELECT Id,Opportunity__c,Project__c,Project__r.name,Opportunity_Line_Item__c,Contact__c FROM Project_Roles__r
             WHERE Opportunity__c IN: oppIdSet
             AND PrimaryContact__c = TRUE
             AND Role__c = 'Authorized Signatory'
             AND Status__c='Active' AND Opportunity_Line_Item__c != null),
             (SELECT Id,Projects__c,Projects__r.Name FROM OpportunityLineItems) FROM Opportunity WHERE ID IN: oppIdSet];

             for(Opportunity oppty : oppList){
             Id OpportunityLineItemId = null;
             for(OpportunityLineItem oli : oppty.OpportunityLineItems){
             if(oli.Projects__c != null && oli.Projects__r.Name != 'The Linux Foundation'){
             OpportunityLineItemId = oli.Id;
             break;
             }else {
             OpportunityLineItemId = oli.Id;
             }
             }

             for(Project_Role__c pRole : oppty.Project_Roles__r){
             if(OpportunityLineItemId == pRole.Opportunity_Line_Item__c){
             Opportunity opp = new opportunity(
             id = oppty.Id,
             Authorized_Signatory__c = pRole.Contact__c
             );
             updateOpportunity.add(opp);
             break;
             }
             }

             }*/

            List<Project_Role__c> pRoleList = [SELECT Id, Opportunity__c, Project__c, Project__r.name, Contact__c
                                               FROM Project_Role__c
                                               WHERE Opportunity__c IN:oppIdSet AND PrimaryContact__c = TRUE AND Role__c = 'Authorized Signatory' AND Status__c = 'Active' AND Opportunity_Line_Item__c != null AND Opportunity__r.isClosed = false
                                               ORDER By Createddate Desc];
            system.debug('pRoleList ' + pRoleList);
            Map<Id, List<Project_Role__c>> oppVSProjectRoleMap = new Map<Id, List<Project_Role__c>>();
            List<Opportunity> updateOpportunity = new List<Opportunity>();
            for (Project_Role__c pRole : pRoleList){
                system.debug('pRole ' + pRole);
                if (!oppVSProjectRoleMap.containsKey(pRole.Opportunity__c)){
                    oppVSProjectRoleMap.put(pRole.Opportunity__c, new List<Project_Role__c>());
                }
                oppVSProjectRoleMap.get(pRole.Opportunity__c).add(pRole);
            }
            for (Id opportunityId : oppVSProjectRoleMap.keySet()){
                Id authorizedSignatory = null;
                for (Project_Role__c pRole : oppVSProjectRoleMap.get(opportunityId)){
                    system.debug('pRole ' + pRole);
                    if (pRole.Project__c != null && pRole.Project__r.Name != 'The Linux Foundation'){
                        authorizedSignatory = pRole.Contact__c;
                        break;
                    } else{
                        authorizedSignatory = pRole.Contact__c;
                    }

                }
                Opportunity opp = new opportunity(id = opportunityId, Authorized_Signatory__c = authorizedSignatory);
                updateOpportunity.add(opp);
            }
            system.debug('updateOpportunity ' + updateOpportunity);
            if (!updateOpportunity.isEmpty()){
                update updateOpportunity;
            }
        }
    }

    /*public static void updateProjectTeam(Map<Id, Project_Role__c> newMap, Map<Id, Project_Role__c> oldMap) {

     Set<Id> assetIds = new Set<Id>();
     Map<Id, Set<String>> mapOfAssetVsSetOfContacts = new Map<Id, Set<String>>();
     List<Project_Role__c> projectRolesToUpdate = new List<Project_Role__c>();
     //-- Check if the newmap is not null and whether it is insert or update or undelete action
     if (newMap != null) {
     for (Project_Role__c projectrole : newMap.values()) {
     if (oldMap == null || (oldMap != null && (oldMap.get(projectrole.id).contact__c != projectrole.contact__c))) {
     assetIds.add(projectrole.Asset__c);
     }
     }
     }

     //-- if the action is after delete
     if (newMap == null) {
     for (Project_Role__c projectrole : oldMap.values()) {
     assetIds.add(projectrole.Asset__c);
     }
     }

     List<Project_Role__c> projectRoles = [SELECT ID,Contact__r.Name,Asset__c FROM Project_Role__c WHERE Asset__c IN :assetIds];
     //-- Performing Loop operation in the list of project roles and then inserting into map of Asset ID vs set of Contact Names
     for (Project_Role__c projectrole : projectRoles) {
     if (!mapOfAssetVsSetOfContacts.containsKey(projectrole.Asset__c)) {
     mapOfAssetVsSetOfContacts.put(projectrole.Asset__c, new Set<String>{
     projectrole.Contact__r.Name
     });

     } else {
     mapOfAssetVsSetOfContacts.get(projectrole.Asset__c).add(projectrole.Contact__r.Name);

     }
     }

     //-- Updating the Project team field from the resulted contacts set and adding the records to the updateList
     for (Project_Role__c projectrole : projectRoles) {

     projectrole.Project_Team__c = String.join(new List<String>(mapOfAssetVsSetOfContacts.get(projectrole.Asset__c)), '\n');
     projectRolesToUpdate.add(projectrole);

     }

     //for sending the notificaion request to notification server when *Send_to_Groups_io__c* is checked.
     //Start Added Here by Sachin
     /*for(Project_Role__c prjctRL: newMap.values()) {
     //if(oldMap == null) {
     if(prjctRL.Send_to_Groups_io__c == true) {
     if(System.IsBatch() == false && System.isFuture() == false){
     notificationService_controller.getAccessToken(prjctRL.Id);
     }
     }
     /*} else {
     if(prjctRL.Send_to_Groups_io__c == true && (oldMap.get(prjctRL.id).ProjectName__c!=prjctRL.ProjectName__c
     ||oldMap.get(prjctRL.id).ContactEmail__c!=prjctRL.ContactEmail__c
     ||oldMap.get(prjctRL.id).Role__c!=prjctRL.Role__c)) {
     notificationService_controller.getAccessToken(prjctRL.Id);
     }
     }*/
    //}
    //ENd Here
    //-- Update projectRolesToUpdate List
    /* if (!projectRolesToUpdate.isEmpty()) {
     update projectRolesToUpdate;
     }
     }*/
    /*
     This method will populate the alternate email field on projects roles created from Custom Component
     -if primary email domain of contact is listed under public domains list then we calcuate Alternate Email
     -if primary email domain of contact is not listed under public domains list then we take primary email as Alternate Email
     */
    private static void updateAlternateEmail(List<Project_Role__c> newList, Map<Id, Project_Role__c> oldMap){
        System.debug('##newList :' + newList);
        System.debug('##oldMap :' + oldMap);
        set<String> contactDomains = new set<String>();
        Map<Id, String> contactWithAccDomain = new Map<Id, String>();
        Map<Id, Id> mapOfContactWithAEmailId = new Map<Id, Id>();
        set<Id> conIds = new Set<Id>();
        List<Project_Role__c> rolesToBeUpdated = new List<Project_Role__c>();
        ProjectRoleDummyUpdationSetting__c dummyUpdateSetting = ProjectRoleDummyUpdationSetting__c.getOrgDefaults();
        PublicDomain__mdt domainsToCheck = [SELECT MasterLabel, QualifiedApiName, EmailList__c
                                            FROM PublicDomain__mdt
                                            Where MasterLabel = 'DomainsToExclude'
                                            Limit 1];
        String domainsList = domainsToCheck.EmailList__c.replaceAll('(\\s+)', '');
        Set<String> domains = new Set<String>(domainsList.split(';'));

        for (Project_Role__c pr : newList){
            if ((oldMap == null && pr.Alternate_Email__c == null) || (oldMap != null && (dummyUpdateSetting.Dummy_Update__c || pr.Contact__c != oldMap.get(pr.Id).Contact__c))){
                System.debug('##Contact :' + pr.Contact__c);
                System.debug('##Contact Email :' + pr.ContactEmail__c);
                conIds.add(pr.Contact__c);
            }
        }

        if (!conIds.isEmpty()){
            List<Contact> conList = [SELECT Id, Account.Website
                                     FROM Contact
                                     WHERE Id IN:conIds];
            for (Contact con : conList){
                if (String.isNotBlank(con.Account.Website)){
                    String accDomain = con.Account.Website.replace('www.', '');
                    String accDomain2 = accDomain.replace('http://', '');
                    String accDomain3 = accDomain2.replace('https://', '');
                    String accDomain4 = accDomain3.replace('http://www.', '');
                    accDomain4 = accDomain4.replace('/', '');
                    if (!contactWithAccDomain.containskey(con.Id)){
                        contactWithAccDomain.put(con.Id, accDomain4.tolowercase());
                    }
                }
            }
            System.debug('##contactWithAccDomain :' + contactWithAccDomain);

            Map<Id, List<Alternate_Email__c>> mapOfAlternateEmailsByContact = new Map<Id, List<Alternate_Email__c>>();
            List<Alternate_Email__c> alternateEmails = [SELECT Id, Alternate_Email_Address__c, Contact_Name__c, Contact_Name__r.Contact_Domain__c, Primary_Email__c, Email_Address_Domain__c
                                                        FROM Alternate_Email__c
                                                        WHERE Contact_Name__c IN:conIds];
            if (!alternateEmails.isEmpty()){
                for (Alternate_Email__c ar : alternateEmails){
                    if (!mapOfAlternateEmailsByContact.containsKey(ar.Contact_Name__c)){
                        mapOfAlternateEmailsByContact.put(ar.Contact_Name__c, new List<Alternate_Email__c>());
                    }
                    mapOfAlternateEmailsByContact.get(ar.Contact_Name__c).add(ar);
                }
            }
            System.debug('##mapOfAlternateEmailsByContact :' + mapOfAlternateEmailsByContact);

            for (Id cId : conIds){
                String accDomain = contactWithAccDomain.containsKey(cId) ? contactWithAccDomain.get(cId) : '';
                List<Alternate_Email__c> aEmails = mapOfAlternateEmailsByContact.containsKey(cId) ? mapOfAlternateEmailsByContact.get(cId) : new List<Alternate_Email__c>();
                if (!aEmails.isEmpty()){
                    for (Alternate_Email__c ar : aEmails){
                        if (domains.Contains(ar.Contact_Name__r.Contact_Domain__c)){
                            if (ar.Email_Address_Domain__c != null && String.isNotBlank(accDomain) && (ar.Email_Address_Domain__c).tolowercase() == accDomain){
                                mapOfContactWithAEmailId.put(cId, ar.Id);
                                if (ar.Primary_Email__c)
                                    break;
                            }
                        }
                        if (!mapOfContactWithAEmailId.containsKey(cId) && ar.Primary_Email__c){
                            mapOfContactWithAEmailId.put(cId, ar.Id);
                        }
                    }
                }
            }

            System.debug('##mapOfContactWithAEmailId :' + mapOfContactWithAEmailId);

            if (!mapOfContactWithAEmailId.isEmpty()){
                for (Project_Role__c pr : newList){
                    if (mapOfContactWithAEmailId.containsKey(pr.Contact__c)){
                        pr.Alternate_Email__c = mapOfContactWithAEmailId.get(pr.Contact__c);
                    }
                }
            }
        }
    }

    /*Added By Priyesh @CloudRoute to populate the opportunity and lines items on project role when created from join now with asset*/
    private Static void populateOpportunityAndLineItem(List<Project_Role__c> newList){
        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        Set<Id> assetIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<String> oliIds = new Set<String>();
        Map<Id, OpportunityLineItem> oliIdVsOli = new Map<Id, OpportunityLineItem>();
        for (Project_Role__c role : newList){
            System.debug('Role==>' + role);
            if (role.Asset__c != null && role.Opportunity__c == null && role.Opportunity_Line_Item__c == null){
                assetIds.add(role.Asset__c);
            }
            oppIds.add(role.Opportunity__c);

            System.debug('Updated Role1==>' + role);
            System.debug('assetIds==>' + assetIds);
        }

        if (!oppIds.isEmpty()){
            oppMap = new Map<Id, Opportunity>([SELECT Id, AccountId, Project_Name__c
                                               FROM Opportunity
                                               WHERE Id In:oppIds]);
        }

        if (!assetIds.isEmpty()){
            assetMap = new Map<Id, Asset>([Select Id, Opportunity__c, OpportunityLineItem__c
                                           FROM Asset
                                           WHERE Id IN:assetIds]);
            System.debug('assetMap==>' + assetMap);
        }

        for (Project_Role__c role : newList){
            if (!assetMap.values().isEmpty() && assetMap.containsKey(role.Asset__c)){
                 //modified by Priyesh @Cloudroute
                if (assetMap.get(role.Asset__c).Opportunity__c != null){
                    role.Opportunity__c = assetMap.get(role.Asset__c).Opportunity__c;
                }
                if (assetMap.get(role.Asset__c).OpportunityLineItem__c != null){
                    role.Opportunity_Line_Item__c = assetMap.get(role.Asset__c).OpportunityLineItem__c;
                }
            }

            //Added by Priyesh @Cloudroute for populating account and project on role
            if (role.Opportunity_Line_Item__c != null){
                oliIds.add(role.Opportunity_Line_Item__c);
            }

            System.debug('Updated Role==>' + role);
        }

        //Added by Priyesh @Cloudroute for populating account and project on role
        if (!oliIds.isEmpty()){
            oliIdVsOli = new Map<Id, OpportunityLineItem>([SELECT Id, Projects__c, Opportunity.AccountId, Start_Date__c, End_Date__c
                                                           from OpportunityLineItem
                                                           WHERE Id IN:oliIds]);

            if (!oliIdVsOli.values().isEmpty()){
                for (Project_Role__c role : newList){
                    //Added by Priyesh @Cloudroute for populating account and project on role
                    if (oliIdVsOli.containsKey(role.Opportunity_Line_Item__c)){
                        role.Account__c = oliIdVsOli.get(role.Opportunity_Line_Item__c).Opportunity.AccountId;
                        role.Project__c = oliIdVsOli.get(role.Opportunity_Line_Item__c).Projects__c;

                        if (role.Start_Date__c == null || role.Start_Date__c != oliIdVsOli.get(role.Opportunity_Line_Item__c).Start_Date__c)
                            role.Start_Date__c = oliIdVsOli.get(role.Opportunity_Line_Item__c).Start_Date__c;
                        if (role.End_Date__c == null || role.End_Date__c != oliIdVsOli.get(role.Opportunity_Line_Item__c).End_Date__c)
                            role.End_Date__c = oliIdVsOli.get(role.Opportunity_Line_Item__c).End_Date__c;
                    }
                    System.debug('Updated Role==>' + role);
                }
            }
        }
    }

    //Method to add Project Roles to Parent Asset for Renewal
    private static void addRolesToParentAssetForRenewal(Map<Id, Project_Role__c> newMap, Map<Id, Project_Role__c> oldMap){
        Set<ID> parentAssetIdSet = new Set<Id>();
        Set<Id> proleIdSet = new Set<Id>();
        Set<String> roleSet = new Set<String>();
        Set<Id> contactIdSet = new Set<Id>();
        List<Project_Role__c> proleListToUpsert = new List<Project_Role__c>();
        for (Project_Role__c pRole : newMap.values()){
            system.debug('pRole.type__c ' + pRole.type__c);

            //If Renewal and on insert or update of status or primary contact
            if (pRole.type__c != null && pRole.type__c.contains('Renewal') && pRole.Parent_Asset__c != null && (oldMap == null || (oldMap.get(pRole.Id).PrimaryContact__c != pRole.PrimaryContact__c || oldMap.get(pRole.Id).Status__c != pRole.Status__c))){
                roleSet.add(pRole.Role__c);
                contactIdSet.add(pRole.contact__c);
                System.debug('pRole.Parent_Asset__c ' + pRole.Parent_Asset__c);
                parentAssetIdSet.add(pRole.Parent_Asset__c);
                proleIdSet.add(pRole.Id);
            }
        }
        system.debug('proleIdSet ' + proleIdSet);
        system.debug('parentAssetIdSet ' + parentAssetIdSet);
        if (!parentAssetIdSet.isEmpty()){
            //Retrieve Parent Asset and its Project Role
            Map<Id, Asset> assetPojectRoleMap = new Map<Id, Asset>([SELECT Opportunity__c, OpportunityLineItem__c, InstallDate, UsageEnddate, Opportunity__r.Type, (SELECT Id, Role__c, Contact__c, Asset__c, Status__c, PrimaryContact__c
                                                                                                                                                                    FROM Project_Roles__r
                                                                                                                                                                    WHERE Role__c IN:roleSet and Contact__c IN:contactIdSet)
                                                                    FROM Asset
                                                                    WHERE ID IN:parentAssetIdSet AND (Status = 'Active' OR Status = 'Purchased')]);

            Map<String, Project_Role__c> existingroleVsProjectRole = new Map<String, Project_Role__c>();

            //Iterate to create a map for ProjectRole
            for (Asset asset : assetPojectRoleMap.values()){
                system.debug('asset.Id ' + asset.Id);
                for (Project_Role__c pRole : asset.Project_Roles__r){
                    system.debug((pRole.Role__c + ' ' + pRole.Contact__c + ' ' + pRole.Asset__c));
                    existingroleVsProjectRole.put(pRole.Role__c + ' ' + pRole.Contact__c + ' ' + pRole.Asset__c, pRole);
                }

            }

            //Itrerate on Renewal's ProjectRole
            for (Id proleId : proleIdSet){

                //Trigger Instance
                Project_Role__c newProjectRole = newMap.get(proleId);
                if (assetPojectRoleMap.containsKey(newProjectRole.Parent_Asset__c)){

                    //New Instance to upsert
                    Project_Role__c projectRole = new Project_Role__c();

                    //Parent Asset
                    Asset asst = assetPojectRoleMap.get(newProjectRole.Parent_Asset__c);
                    System.debug('asst ' + asst.Id);
                    String key = newProjectRole.Role__c + ' ' + newProjectRole.Contact__c + ' ' + asst.Id;
                    system.debug('key ' + key);

                    //If Project Role exist
                    if (existingroleVsProjectRole.containsKey(key)){
                        //update status and primary contact
                        if (existingroleVsProjectRole.get(key).Status__c != newProjectRole.Status__c || existingroleVsProjectRole.get(key).PrimaryContact__c != newProjectRole.PrimaryContact__c){
                            projectRole.Id = existingroleVsProjectRole.get(key).Id;
                            projectRole.Status__c = newProjectRole.Status__c;
                            projectRole.PrimaryContact__c = newProjectRole.PrimaryContact__c;
                            proleListToUpsert.add(projectRole);
                        }
                    } else{
                        //Clone
                        projectRole = newProjectRole.clone(false, false, false, false);
                        projectRole.Type__c = asst.Opportunity__r.Type;
                        projectRole.Start_Date__c = asst.InstallDate;
                        projectRole.End_Date__c = asst.UsageEnddate;
                        projectRole.Opportunity_Line_Item__c = asst.OpportunityLineItem__c;

                        //Linking Opportunity only if project role is not Authorised Signatory
                        if (newProjectRole.Role__c != 'Authorized Signatory'){
                            projectRole.Opportunity__c = asst.Opportunity__c;
                        } else{
                            projectRole.Opportunity__c = null;
                        }
                        projectRole.Asset__c = asst.Id;
                        proleListToUpsert.add(projectRole);
                    }
                    system.debug('##projectRole :' + projectRole);

                }


            }
            if (!proleListToUpsert.isEmpty()){
                ProjectRoleTHRecursion = true;
                //upsert
                upsert proleListToUpsert;
                ProjectRoleTHRecursion = false;

            }
        }
    }

    /* Method to add/delete roles to the open renewal opp from active purchase history in case of any changes */
    private static void upsertRolesToOpenRenewalOpp(Map<Id, Project_Role__c> newMap, Map<Id, Project_Role__c> oldMap){
        system.debug('upsertRolesToOpenRenewalOpp ');
        Set<ID> assetIdSet = new Set<Id>();
        Set<Id> proleIdSet = new Set<Id>();
        Set<String> roleSet = new Set<String>();
        Set<Id> contactIdSet = new Set<Id>();

        //If insert/update then assign newmap or else for delete asign oldmap
        List<Project_Role__c> proleTriggerList = newMap != null ? newMap.values() : oldMap.values();

        //Iterate
        for (Project_Role__c pRole : proleTriggerList){
            system.debug('pRole.type__c ' + pRole.type__c);

            //If Role is associated with and Active Purchase history
            if (pRole.Asset__c != null && (prole.Asset_Status__c == 'Active' || prole.Asset_Status__c == 'Purchased')){

                System.debug('pRole.Asset__c ' + pRole.Asset__c);

                roleSet.add(pRole.Role__c);
                contactIdSet.add(pRole.contact__c);
                assetIdSet.add(pRole.Asset__c);
                proleIdSet.add(pRole.Id);
            }
        }

        //asset set is not empty
        if (!assetIdSet.isEmpty()){

            //Retrieve all open renewal opp for the assets along with the roles and line items
            List<Opportunity> opportunityList = [SELECT Id, Parent_Asset__c, Type, (SELECT Id, Role__c, Contact__c, Asset__c, Status__c, PrimaryContact__c
                                                                                    FROM Project_Roles__r
                                                                                    WHERE Role__c IN:roleSet and Contact__c IN:contactIdSet), (SELECT Id,Start_Date__c,End_Date__c ,Projects__c
                                                                                                                                               FROM OpportunityLineItems),(SELECT Id,Opportunity__c,Projects__c FROM Asset__r)
                                                 FROM Opportunity 
                                                 WHERE Parent_Asset__c IN:assetIdSet];
            if (!opportunityList.isEmpty()){
                Map<Id, Opportunity> parentAssetIdVsOppMap = new Map<Id, Opportunity>();
                Map<String, OpportunityLineItem> oppProjectStrVsLineItemIdMap = new Map<String, OpportunityLineItem>();
                Map<String, Id> oppProjectStrVsAssetIdMap = new Map<String, Id>();


                Map<String, Project_Role__c> existingroleVsProjectRole = new Map<String, Project_Role__c>();

                //iterate
                for (Opportunity opportunity : opportunityList){

                    system.debug('asset.Id ' + asset.Id);
                    for (Project_Role__c pRole : opportunity.Project_Roles__r){
                        system.debug((pRole.Role__c + ' ' + pRole.Contact__c));
                        existingroleVsProjectRole.put(pRole.Role__c + ' ' + pRole.Contact__c + ' ' + opportunity.Parent_Asset__c, pRole);
                    }
                    parentAssetIdVsOppMap.put(opportunity.Parent_Asset__c, opportunity);
                    for (OpportunityLineItem oppLineItem : opportunity.OpportunityLineItems){
                        String key = opportunity.Id + ' ' + oppLineItem.Projects__c;
                        oppProjectStrVsLineItemIdMap.put(key, oppLineItem);
                    }
                    for (Asset asset : opportunity.Asset__r){
                        String key = opportunity.Id + ' ' + Asset.Projects__c;
                        oppProjectStrVsAssetIdMap.put(key, asset.Id);
                    }

                }
                List<Project_Role__c> proleListToUpsert = new List<Project_Role__c>();
                List<Project_Role__c> proleListToDelete = new List<Project_Role__c>();

                for (Id proleId : proleIdSet){
                    Project_Role__c newProjectRole = newMap != null ? newMap.get(proleId) : oldMap.get(proleId);
                    String key = newProjectRole.Role__c + ' ' + newProjectRole.Contact__c + ' ' + newProjectRole.Asset__c;
                    Project_Role__c projectRole = new Project_Role__c();
                    //for delete
                    if (newMap == null && existingroleVsProjectRole.containsKey(key)){
                        projectRole.Id = existingroleVsProjectRole.get(key).Id;
                        proleListToDelete.add(projectRole);
                    }
                    //for insert/update
                    else if (newMap != null && parentAssetIdVsOppMap.containsKey(newProjectRole.Asset__c)){
                        projectRole = newProjectRole.clone(false, false, false, false);

                        Opportunity openRenewalOpp = parentAssetIdVsOppMap.get(newProjectRole.Asset__c);

                        projectRole.Id = existingroleVsProjectRole.containsKey(key) ? existingroleVsProjectRole.get(key).id : null;

                        projectRole.opportunity__c = openRenewalOpp.Id;
                        projectRole.Type__c = openRenewalOpp.Type;
                        String projectKey = openRenewalOpp.Id + ' ' + newProjectRole.Project__c;
                        projectRole.Asset__c = oppProjectStrVsAssetIdMap.containsKey(projectKey) ? oppProjectStrVsAssetIdMap.get(projectKey) : null;
                        projectRole.Heroku_Connect_Id__c = null;
                        projectRole.Opportunity_Line_Item__c = oppProjectStrVsLineItemIdMap.containsKey(projectKey) ? oppProjectStrVsLineItemIdMap.get(projectKey).Id : null;
                        if(oppProjectStrVsLineItemIdMap.containsKey(projectKey)){

                            projectRole.Start_Date__c = oppProjectStrVsLineItemIdMap.get(projectKey).Start_Date__c;
                            projectRole.End_Date__c = oppProjectStrVsLineItemIdMap.get(projectKey).End_Date__c;
    
                        }
                        proleListToUpsert.add(projectRole);

                    }
                }
                if (!proleListToUpsert.isEmpty()){
                    ProjectRoleTHRecursion = true;

                    upsert proleListToUpsert;
                    ProjectRoleTHRecursion = false;

                }
                if (!proleListToDelete.isEmpty()){
                    ProjectRoleTHRecursion = true;

                    delete proleListToDelete;
                    ProjectRoleTHRecursion = false;

                }
            }
        }
    }

    /*public static void updateSendDate(List<Project_Role__c> triggerNew) {
     try {
     Set<Id> assetIds = new Set<Id>();
     Map<Id, String> mapOfAssetIdVsOppProduct = new Map<Id, String>();

     for (Project_Role__c projectrole : triggerNew) {
     assetIds.add(projectrole.Asset__c);
     }

     List<Asset> assetList = [SELECT Id,OpportunityLineItem__c FROM Asset WHERE Id IN:assetIds];
     for (Asset asset : assetList) {
     mapOfAssetIdVsOppProduct.put(asset.Id, asset.OpportunityLineItem__c);
     }
     Map<Id, OpportunityLineItem> opptyProducts = new Map<Id, OpportunityLineItem>([SELECT ID,Send_Date__c FROM OpportunityLineItem WHERE ID IN:mapOfAssetIdVsOppProduct.values()]);

     for (Project_Role__c projectrole : triggerNew) {
     projectrole.Send_Date__c = opptyProducts.get(mapOfAssetIdVsOppProduct.get(projectrole.Asset__c)).Send_Date__c;
     }
     }

     catch (Exception e) {
     System.debug('Error  : ' + e.getMessage() + ' line : ' + e.getLineNumber());
     }

     }*/
}