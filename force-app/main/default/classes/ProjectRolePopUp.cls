/********************************************************
* Created by: Pratik D
* Created Date: 22 - 07 - 2020.
* Description: ProjectRolePopUp
* JIRA - SFDC-1748 - Create Project Roles from Membership Role Button on Opportunity.
* Last Modified by - Tushar Mahadik 8/10/2020
* Revamp the complete Lightning Component "ProjectRoleTablePopup".
********************************************************/
public class ProjectRolePopUp {
   
    @AuraEnabled
    public static Opportunity getOpportunityDetails(Id recordId){
        return [SELECT Id, Type, IsClosed, Parent_Asset__c, IsWon, RecordType.DeveloperName FROM Opportunity WHERE Id =: recordId];
    }
    
    @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityLineItem(Id recordId){
        List<OpportunityLineItem> OpportunityLineItemList=new List<OpportunityLineItem>();
        for(OpportunityLineItem opportunityLineItemDetail:[
            SELECT Projects__r.Name,Product2.Name 
            FROM OpportunityLineItem WHERE OpportunityId=:recordId
            AND Projects__r.Membership_Roles_Not_Required__c = false]){
                /* if(!String.isEmpty(opportunityLineItemDetail.Projects__r.Name)){
if(opportunityLineItemDetail.Projects__r.Name.toLowerCase().contains('the linux foundation')){
if(linuxProjectCount==0){
linuxProjectCount++;
OpportunityLineItemList.add(opportunityLineItemDetail);
}

}
if(otherProjectCount==0){
if(!opportunityLineItemDetail.Projects__r.Name.toLowerCase().contains('the linux foundation')){
otherProjectCount++;
OpportunityLineItemList.add(opportunityLineItemDetail);
}
}   
}*/
                OpportunityLineItemList.add(opportunityLineItemDetail);
            } 
        return OpportunityLineItemList;
    }
    
    //Added by Priyesh @Cloudroute to allow users to add membership roles after closing opp only if renewal is not created
    @AuraEnabled
    public Static Boolean checkForRenewal(Id oliId){
        OpportunityLineItem oli = [SELECT Id, Projects__c, OpportunityId, Opportunity.IsClosed, Opportunity.AccountId FROM OpportunityLineItem WHERE Id =: oliId];
        System.debug('oli:: ' + oli);
        List<Asset> renewalAsset = [SELECT Id, Renewal_Opportunity_Created__c FROM Asset WHERE OpportunityLineItem__c =: oli.Id AND Opportunity__c =: oli.OpportunityId];
        if(!renewalAsset.isEmpty() && renewalAsset[0] != null) {
            return !renewalAsset[0].Renewal_Opportunity_Created__c;
        }else{
            return true;
        }
    }
    
    @AuraEnabled
    public static List<Project_role__c> fetchProjectRole(Id recordId,string lineItemID, String oppRecord){
        System.debug('##lineItemID :'+lineItemID);
        System.debug('##oppRecord :'+oppRecord);
        Opportunity opp;
        if(string.isNotBlank(oppRecord)){
            opp = (Opportunity)JSON.deserialize(oppRecord, Opportunity.class);
        }
        System.debug('##opp :'+opp);
        
        List<Project_role__c> projectRoles = new List<Project_Role__c>();
        String oppType = opp.Type;
        String parentAssetId = opp.Parent_Asset__c != null ? opp.Parent_Asset__c : null;
        System.debug('##oppType :'+oppType);
        System.debug('##parentAssetId :'+parentAssetId);
        if(string.isNotBlank(oppType)){
            Boolean queryRun = false;
            string query = 'SELECT Name, Contact_Name__c, Account__c,Account__r.name,Contact__c, PrimaryContact__c, BoardMember__c, CreatedDate, Role__c, ContactEmail__c,Corporate_Email__c, ' +
                'End_Date__c, Start_Date__c, Status__c FROM Project_Role__c WHERE IsDeleted = false '; //Added Contact__c by Priyesh @CloudRoute to make the contact column clickable
            
            //Added by Priyesh @Cloudroute for Renewal - Downgrade/Upgrade
            /*if(oppType == 'Renewal' && !opp.IsClosed && !opp.IsWon){
queryRun = true;
query += ' AND Asset__c =: parentAssetId';
}else if(oppType == 'New Business' || (oppType == 'Renewal' && opp.IsClosed && opp.IsWon)){
queryRun = true;
query += ' AND Opportunity__c =: recordId AND Opportunity_Line_Item__c=: lineItemID ';
}*/
            if(oppType == 'New Business' || oppType.contains('Renewal')){
                queryRun = true;
                query += ' AND Opportunity__c =: recordId AND Opportunity_Line_Item__c=: lineItemID ';
            }
            System.debug('##query :'+query);
            if(queryRun){
                projectRoles = Database.query(query);
            }else{
                projectRoles = new List<Project_Role__c>();
            }
        }
        System.debug('##projectRoles :'+projectRoles);
        
        List<Project_Role__c> pRoles = new List<Project_Role__c>();
        
        //Added by Priyesh @Cloudroute to insert the membership roles for renewal opp
        if(oppType.contains('Renewal') && !opp.IsClosed && !opp.IsWon && projectRoles.isEmpty()){
            List<Project_Role__c> newRoles = new List<Project_Role__c>();
            Map<Id, OpportunityLineItem> olList = new Map<Id, OpportunityLineItem>([SELECT Id, End_Date__c, Start_Date__c, OpportunityId FROM OpportunityLineItem WHERE Id =: lineItemID]);
            List<Project_Role__c> parentAssetRoles = [SELECT Id, Contact__c, PrimaryContact__c, Role__c FROM Project_Role__c WHERE Asset__c =: parentAssetId AND IsDeleted = false];
            for(Project_Role__c pr :parentAssetRoles){
                newRoles.add(createRole(pr.Role__c, pr.Contact__c, olList.get(lineItemID), pr.PrimaryContact__c));
            }
            //call this to upsert new roles and update the current renewal oli
            //insertProjectRoles(newRoles, lineItemId);
            upsert newRoles;
            pRoles = [SELECT Name, Contact_Name__c, PrimaryContact__c, BoardMember__c, CreatedDate, Role__c, ContactEmail__c, 
                      End_Date__c, Start_Date__c, Status__c FROM Project_Role__c WHERE IsDeleted = false AND  Opportunity_Line_Item__c=: lineItemID];
            System.debug('pRoles for renewal: ' + pRoles);
            
        }else if(oppType == 'New Business' || oppType.contains('Renewal')) {
            //pRoles.addAll(createProjectRoles(lineItemID, projectRoles, oppType, parentAssetId));
        }
        if(!projectRoles.isEmpty()) {
            pRoles.addAll(projectRoles);
        }
        return pRoles;
    }
    
    /*
private static List<Project_Role__c> createProjectRoles(string lineItemID, List<Project_Role__c> projectRoles, string oppType, string parentAssetId){
List<Project_Role__c> projectRolesToBeInserted = new List<Project_Role__c>();
Map<String, List<Id>> mapOfProjectRoles = new Map<String, List<Id>>();
//Create Map of old project Roles
if(!projectRoles.isEmpty()){
for(Project_Role__c pr : projectRoles){
if(mapOfProjectRoles.containsKey(pr.Role__c)){
mapOfProjectRoles.get(pr.Role__c).add(pr.Contact__c);
}else{
mapOfProjectRoles.put(pr.Role__c, new List<Id>{pr.Contact__c});
}
}
}
System.debug('##mapOfProjectRoles :'+mapOfProjectRoles);

//Get Opportunity Line Item
List<OpportunityLineItem> olList = [SELECT Id, Authorized_Signatory__c,PO_Contact__c, Representative_Voting_Contact__c, Technical_Contact__c, Marketing_Contact__c, Press_Contact__c, Legal_Contact__c, Billing_Contact__c, Billing_Contact2__c, Billing_Contact3__c,
Marketing_Contact_2__c, Marketing_Contact_3__c, Technical_Contact_2__c, Technical_Contact_3__c, End_Date__c, Start_Date__c,Sponsorship_Contact__c,Opportunity.Type, OpportunityId FROM OpportunityLineItem WHERE Id =: lineItemID and Projects__c != null AND Opportunity.IsClosed = FALSE];
if(olList != null && !olList.isEmpty()) {
OpportunityLineItem ol = olList[0];

if (ol.Opportunity.Type == 'New Business' || ol.Opportunity.Type.contains('Renewal')) {
//Modified By Priyesh @Cloudroute for removing the billing-1-2, technical-1-2 and marketing-1-2 roles and keeping the single role
if (ol.Representative_Voting_Contact__c != null && (!mapOfProjectRoles.containsKey('Representative/Voting Contact') || (mapOfProjectRoles.containsKey('Representative/Voting Contact') && !mapOfProjectRoles.get('Representative/Voting Contact').contains(ol.Representative_Voting_Contact__c)))) {
projectRolesToBeInserted.add(createRole('Representative/Voting Contact',ol.Representative_Voting_Contact__c,ol,true));
}
if (ol.Technical_Contact__c != null && (!mapOfProjectRoles.containsKey('Technical Contact') || (mapOfProjectRoles.containsKey('Technical Contact') && !mapOfProjectRoles.get('Technical Contact').contains(ol.Technical_Contact__c)))) {
projectRolesToBeInserted.add(createRole('Technical Contact',ol.Technical_Contact__c,ol,true));
}
if (ol.Marketing_Contact__c != null && (!mapOfProjectRoles.containsKey('Marketing Contact') || (mapOfProjectRoles.containsKey('Marketing Contact') && !mapOfProjectRoles.get('Marketing Contact').contains(ol.Marketing_Contact__c)))) {
projectRolesToBeInserted.add(createRole('Marketing Contact',ol.Marketing_Contact__c,ol,true));
}
if (ol.Press_Contact__c != null && (!mapOfProjectRoles.containsKey('Press Contact') || (mapOfProjectRoles.containsKey('Press Contact') && !mapOfProjectRoles.get('Press Contact').contains(ol.Press_Contact__c)))) {
projectRolesToBeInserted.add(createRole('Press Contact',ol.Press_Contact__c,ol,true));
}
if (ol.Legal_Contact__c != null && (!mapOfProjectRoles.containsKey('Legal Contact') || (mapOfProjectRoles.containsKey('Legal Contact') && !mapOfProjectRoles.get('Legal Contact').contains(ol.Legal_Contact__c)))) {
projectRolesToBeInserted.add(createRole('Legal Contact',ol.Legal_Contact__c,ol,true));
}
if (ol.Billing_Contact__c != null && (!mapOfProjectRoles.containsKey('Billing Contact') || (mapOfProjectRoles.containsKey('Billing Contact') && !mapOfProjectRoles.get('Billing Contact').contains(ol.Billing_Contact__c)))) {
projectRolesToBeInserted.add(createRole('Billing Contact',ol.Billing_Contact__c,ol,true));
}
if (ol.Billing_Contact2__c != null && (!mapOfProjectRoles.containsKey('Billing Contact') || (mapOfProjectRoles.containsKey('Billing Contact') && !mapOfProjectRoles.get('Billing Contact').contains(ol.Billing_Contact2__c)))) {
projectRolesToBeInserted.add(createRole('Billing Contact',ol.Billing_Contact2__c,ol,false));
}
if (ol.Billing_Contact3__c != null && (!mapOfProjectRoles.containsKey('Billing Contact') || (mapOfProjectRoles.containsKey('Billing Contact') && !mapOfProjectRoles.get('Billing Contact').contains(ol.Billing_Contact3__c)))) {
projectRolesToBeInserted.add(createRole('Billing Contact',ol.Billing_Contact3__c,ol,false));
}
if (ol.Marketing_Contact_2__c != null && (!mapOfProjectRoles.containsKey('Marketing Contact') || (mapOfProjectRoles.containsKey('Marketing Contact') && !mapOfProjectRoles.get('Marketing Contact').contains(ol.Marketing_Contact_2__c)))) {
projectRolesToBeInserted.add(createRole('Marketing Contact',ol.Marketing_Contact_2__c,ol,false));
}
if (ol.Marketing_Contact_3__c != null && (!mapOfProjectRoles.containsKey('Marketing Contact') || (mapOfProjectRoles.containsKey('Marketing Contact') && !mapOfProjectRoles.get('Marketing Contact').contains(ol.Marketing_Contact_3__c)))) {
projectRolesToBeInserted.add(createRole('Marketing Contact',ol.Marketing_Contact_3__c,ol,false));
}
if (ol.Technical_Contact_2__c != null && (!mapOfProjectRoles.containsKey('Technical Contact') || (mapOfProjectRoles.containsKey('Technical Contact') && !mapOfProjectRoles.get('Technical Contact').contains(ol.Technical_Contact_2__c)))) {
projectRolesToBeInserted.add(createRole('Technical Contact',ol.Technical_Contact_2__c,ol,false));
}
if (ol.Technical_Contact_3__c != null && (!mapOfProjectRoles.containsKey('Technical Contact') || (mapOfProjectRoles.containsKey('Technical Contact') && !mapOfProjectRoles.get('Technical Contact').contains(ol.Technical_Contact_3__c)))) {
projectRolesToBeInserted.add(createRole('Technical Contact',ol.Technical_Contact_3__c,ol,false));
}
if (ol.PO_Contact__c != null && (!mapOfProjectRoles.containsKey('PO Contact') || (mapOfProjectRoles.containsKey('PO Contact') && !mapOfProjectRoles.get('PO Contact').contains(ol.PO_Contact__c)))) {
projectRolesToBeInserted.add(createRole('PO Contact',ol.PO_Contact__c,ol,true));
}
if (ol.Authorized_Signatory__c != null && (!mapOfProjectRoles.containsKey('Authorized Signatory') || (mapOfProjectRoles.containsKey('Authorized Signatory') && !mapOfProjectRoles.get('Authorized Signatory').contains(ol.Authorized_Signatory__c)))) {
projectRolesToBeInserted.add(createRole('Authorized Signatory',ol.Authorized_Signatory__c,ol,true));
}
if (ol.Sponsorship_Contact__c != null && (!mapOfProjectRoles.containsKey('Event Sponsorship') || (mapOfProjectRoles.containsKey('Event Sponsorship') && !mapOfProjectRoles.get('Event Sponsorship').contains(ol.Sponsorship_Contact__c)))) {
projectRolesToBeInserted.add(createRole('Event Sponsorship',ol.Sponsorship_Contact__c,ol,true));
}
}else{
//No need create Project Roles for renewal because we are taking them from Parent Asset.
}
}
if(!projectRolesToBeInserted.isEmpty()){
insert projectRolesToBeInserted;
}

System.debug('##projectRolesToBeInserted :'+projectRolesToBeInserted);
List<Project_Role__c> updateProjectRoles = new List<Project_Role__c>();
updateProjectRoles = [SELECT Name, Contact_Name__c, PrimaryContact__c, BoardMember__c, CreatedDate, Role__c,
End_Date__c, Start_Date__c, Status__c FROM Project_Role__c WHERE IsDeleted = false AND Id IN : projectRolesToBeInserted];

System.debug('##updateProjectRoles :'+updateProjectRoles);
return updateProjectRoles;
}
*/
    
    private static Project_Role__c createRole(String role, Id contactId, OpportunityLineItem oppProduct, Boolean isPrimary){
        Project_Role__c projectRole = new Project_Role__c(Contact__c = contactId, Role__c = role,
                                                          Start_Date__c = oppProduct.Start_Date__c, End_Date__c = oppProduct.End_Date__c,PrimaryContact__c = isPrimary, Opportunity_Line_Item__c = oppProduct.Id, Opportunity__c = oppProduct.OpportunityId);
        return projectRole;
    }
    
    @AuraEnabled
    public static void saveProjectRoles(String recordId, String pRoles, string lineItemID, String oppRecord){
        System.debug('##recordId :'+recordId);
        System.debug('##pRoles :'+pRoles);
        
        Opportunity opp;
        if(string.isNotBlank(oppRecord)){
            opp = (Opportunity)JSON.deserialize(oppRecord, Opportunity.class);
        }
        System.debug('##opp :'+opp);
        
        String oppType = opp.Type;
        
        //Added by Priyesh @Cloudroute to allow users to add membership roles after closing opp only if renewal is not created
        Map<Id, Asset> assetDetails = new Map<Id, Asset>();
        String parentAssetId ;
        if(opp.IsWon){
            Asset asset = [SELECT Id, OpportunityLineItem__c, Opportunity__c, InstallDate, UsageEndDate 
                           FROM Asset 
                           WHERE Opportunity__c =: opp.Id AND OpportunityLineItem__c =: lineItemID LIMIT 1];
            parentAssetId = asset?.Id;
            assetDetails=new Map<Id,Asset>(new List<Asset>{asset});
            
        }/*else{
parentAssetId = opp.Parent_Asset__c != null ? opp.Parent_Asset__c : null;
if(String.isNotBlank(parentAssetId)){
assetDetails = new Map<Id, Asset>([SELECT Id, OpportunityLineItem__c, Opportunity__c, InstallDate, UsageEndDate FROM Asset WHERE Id =: parentAssetId AND OpportunityLineItem__c != null ]);
}

}*/
        
        System.debug('##oppType :'+oppType);
        System.debug('##parentAssetId :'+parentAssetId);
        
        //Get Old Project List for specific line Item
        List<Project_role__c> oldProjectRoles = fetchProjectRole(recordId,lineItemID,oppRecord);
        Map<Id, Project_Role__c> mapOfProjectRoles = new Map<Id, Project_Role__c>();
        Map<String, Id> existingActiveBillingContact = new Map<String, Id>();
        if(oldProjectRoles != null && !oldProjectRoles.isEmpty()){
            for(Project_Role__c pr : oldProjectRoles){
                mapOfProjectRoles.put(pr.Id, pr);
                if(pr.Role__c == 'Billing Contact' && pr.Status__c == 'Active' && pr.PrimaryContact__c){
                    existingActiveBillingContact.put('Billing Contact', pr.Contact__c);
                }
            }
        }
        System.debug('##mapOfProjectRoles :'+mapOfProjectRoles);
        System.debug('##lineItemID before:'+lineItemID);
        
        
        
        System.debug('##assetDetails :'+assetDetails);
        
        List<ProjectRoleWrapper> projectRolesWrappers = (List<ProjectRoleWrapper>)JSON.deserialize(pRoles, List<ProjectRoleWrapper>.class);
        System.debug('##projectRolesWrappers :'+projectRolesWrappers);
        
        List<Project_role__c> pRolesList = new List<Project_Role__c>();
        List<OpportunityLineItem> oliList = [SELECT Id, Type__c, Start_Date__c, End_Date__c, OpportunityId, Opportunity.Billing_Contact__c, Opportunity.Type, Projects__r.Name FROM OpportunityLineItem WHERE Id =: lineItemID and Projects__c != null];
        System.debug('##oliList :'+oliList);
        if(projectRolesWrappers != null && !projectRolesWrappers.isEmpty() && !oliList.isEmpty()){
            OpportunityLineItem oli = oliList[0];
            List<OpportunityContactRole> contactRole = new List<OpportunityContactRole>();
            
            
            for(ProjectRoleWrapper p : projectRolesWrappers){
                system.debug('##p.isOld :'+p.isOld);
                if(p.isOld == 'false'){
                    Project_role__c pRole = new Project_role__c();
                    pRole.Contact__c = p.contactName;
                    pRole.Role__c = p.pr.Role__c;
                    pRole.PrimaryContact__c = p.Pr.PrimaryContact__c;
                    pRole.BoardMember__c = p.Pr.BoardMember__c;
                    /*if(!pRole.PrimaryContact__c && p.pr.Role__c == 'Representative/Voting Contact' && p.pr.Status__c == 'Active'){
pRole.PrimaryContact__c = true;
}*/
                    pRole.Status__c = p.pr.Status__c;
                    if(pRole.Status__c == ''){
                        pRole.Status__c = 'Active';
                    }
                    if(oppType == 'New Business' || oppType.contains('Renewal')){
                        pRole.Type__c = oppType.contains('Renewal') ? 'Renewal': oppType;
                        pRole.Start_Date__c = oli.Start_Date__c;
                        pRole.End_Date__c = oli.End_Date__c;
                        prole.Opportunity_Line_Item__c = p.pr.Opportunity_Line_Item__c;
                        pRole.Opportunity__c = recordId;
                        pRole.Asset__c = parentAssetId; //Added by Priyesh @Cloudroute to allow users to add membership roles after closing opp only if renewal is not created
                        system.debug('##pRole :'+pRole);
                        pRolesList.add(pRole);
                    }
                    //Else is commented because we are not adding membershiproles to parent opportunity for renewal through component
                    /*else if(string.isNotBlank(parentAssetId) && !assetDetails.isEmpty() && assetDetails.containsKey(parentAssetId)){ //For renewal
pRole.Type__c = 'Renewal';
pRole.Asset__c = parentAssetId;
pRole.Start_Date__c = assetDetails.get(parentAssetId).InstallDate;
pRole.End_Date__c = assetDetails.get(parentAssetId).UsageEndDate;
prole.Opportunity_Line_Item__c = assetDetails.get(parentAssetId).OpportunityLineItem__c; //p.pr.Opportunity_Line_Item__c;
pRole.Opportunity__c = assetDetails.get(parentAssetId).Opportunity__c;
system.debug('##pRole :'+pRole);
pRolesList.add(pRole);

//lineItemID = assetDetails.get(parentAssetId).OpportunityLineItem__c; //For renewals we need to consider Old OLI Id
}*/
                    /*if(p.pr.Role__c == 'Billing Contact' && p.pr.Status__c == 'Active' && p.pr.PrimaryContact__c){
existingActiveBillingContact.put('Billing Contact', Id.valueOf(p.contactName));
system.debug('existing role--'+existingActiveBillingContact.get('Billing Contact'));
}*/
                }else{
                    system.debug('##p :'+p.pr);
                    if(mapOfProjectRoles != null && mapOfProjectRoles.containsKey(p.pr.id)){
                        Project_Role__c oldRec = mapOfProjectRoles.get(p.pr.id);
                        if(p.pr.End_Date__c != oldRec.End_Date__c || p.pr.Status__c != oldRec.Status__c || p.pr.PrimaryContact__c != oldRec.PrimaryContact__c){
                            p.pr.Start_Date__c = p.pr.Start_Date__c == null ? oli.Start_Date__c : p.pr.Start_Date__c;
                            p.pr.End_Date__c = p.pr.End_Date__c == null ?oli.End_Date__c :(oldRec.Status__c == 'Inactive' && (p.pr.Status__c == 'Active' || p.pr.Status__c == '')) ? oli.End_Date__c : p.pr.End_Date__c;
                            System.debug('##Inside This :'+p.pr);
                            pRolesList.add(p.pr);
                        }
                        /*if(oldRec.Role__c == 'Billing Contact' && oldRec.Status__c == 'Active' && oldRec.PrimaryContact__c){
existingActiveBillingContact.put('Billing Contact', oldRec.Contact__c);
system.debug('existing role--'+existingActiveBillingContact.get('Billing Contact'));
}*/
                        
                    }
                }
                if(p.pr.Role__c == 'Billing Contact' && p.pr.Status__c == 'Active' && p.pr.PrimaryContact__c){
                    Id contactId = p.contactName != null ? Id.valueOf(p.contactName) : p.pr.Contact__c;
                    existingActiveBillingContact.put('Billing Contact', contactId);
                    system.debug('existing role--'+existingActiveBillingContact.get('Billing Contact'));
                }
                
            }
            
            system.debug('oli.Type__c--'+oli.Type__c);
            system.debug('oli.Projects__r.Name--'+oli.Projects__r.Name);
            system.debug('existingActiveBillingContact.values()--'+existingActiveBillingContact.values());
            if(oli.Type__c == 'Alternate Funding' && oli.Projects__r.Name != 'The Linux Foundation' && !existingActiveBillingContact.values().isEmpty() && existingActiveBillingContact.containsKey('Billing Contact')){
                
                contactRole = [SELECT Id, ContactId, Role FROM OpportunityContactRole WHERE OpportunityId =: oli.OpportunityId AND Role = 'Membership Decision Maker'];
                system.debug('contactRole exisiting--'+contactRole);
                system.debug('existing role--'+existingActiveBillingContact.get('Billing Contact'));
                if(!contactRole.isEmpty() && existingActiveBillingContact.get('Billing Contact') != contactRole[0].ContactId){
                    contactRole[0].ContactId = existingActiveBillingContact.get('Billing Contact');
                    update  contactRole[0];
                }else if(contactRole.isEmpty()){
                    OpportunityContactRole newBillingContactRole = new OpportunityContactRole();
                    newBillingContactRole.Role = 'Membership Decision Maker';
                    newBillingContactRole.ContactId = existingActiveBillingContact.get('Billing Contact');
                    newBillingContactRole.OpportunityId = oli.OpportunityId;
                    newBillingContactRole.IsPrimary = true;
                    system.debug('new contactrole--'+ newBillingContactRole);
                    insert newBillingContactRole;
                }
                
                if(oli.Opportunity.Billing_Contact__c == null || (oli.Opportunity.Billing_Contact__c != null && oli.Opportunity.Billing_Contact__c != existingActiveBillingContact.get('Billing Contact'))){
                    Opportunity updateBillingOpp = new Opportunity(Id = oli.OpportunityId, Billing_Contact__c = existingActiveBillingContact.get('Billing Contact'));
                    update updateBillingOpp;
                }
            }
            
            System.debug('##pRolesList :'+pRolesList);
            System.debug('##lineItemID :'+lineItemID);
            //Call method to insert Project Roles
            if(!pRolesList.isEmpty() && string.isNotBlank(lineItemID)){
                //insertProjectRoles(pRolesList,lineItemID);
                upsert pRolesList;
            }
        }
    }
    
    //This method is used to insert Projects Roles and then add the relationship with related OppLineItem
    /*public static void insertProjectRoles(List<Project_Role__c> projectRoles,Id lineItemId){
try{
System.debug('##projectRoles :'+projectRoles); 
System.debug('##lineItemId :'+lineItemId);

//First upsert all projectRoles
upsert projectRoles;

System.debug('##projectRoles new:'+projectRoles.size());
System.debug('##projectRoles new:'+projectRoles);

//Update Opportunity Lines Items

List<OpportunityLineItem> listOpportunityLineItems = new List<OpportunityLineItem>();
List<Project_Role__c> updatedProjectRoles = [SELECT role__c,contact__c,Status__c, PrimaryContact__c FROM Project_Role__c WHERE Id IN: projectRoles AND Opportunity_Line_Item__c != null
AND contact__c != null ORDER BY Status__c DESC NULLS LAST
]; //Id IN: projectRoles AND (role__c ='Billing Contact' OR role__c ='Representative/Voting Contact' OR Role__c = 'Authorized Signatory')
System.debug('##updatedProjectRoles :'+updatedProjectRoles);

if(updatedProjectRoles != null && !updatedProjectRoles.isEmpty()){
//Update Billing Contact and Voting contact on line Item
//Added by Priyesh @Cloudroute to get the existing values from oli
OpportunityLineItem lItem = [SELECT Id, Authorized_Signatory__c,PO_Contact__c, Representative_Voting_Contact__c, Technical_Contact__c,
Marketing_Contact__c, Press_Contact__c, Legal_Contact__c, Billing_Contact__c, Billing_Contact2__c, Billing_Contact3__c,
Marketing_Contact_2__c, Marketing_Contact_3__c, Technical_Contact_2__c, Technical_Contact_3__c, Sponsorship_Contact__c
FROM OpportunityLineItem
WHERE Id = :lineItemId
];
//lItem.Id = lineItemId;
for(Project_Role__c pRole : updatedProjectRoles){
Id contactId = (pRole.Status__c =='Active' || pRole.Status__c == '') ? pRole.Contact__c : null;
//Modified By Priyesh @Cloudroute for removing the billing-1-2, technical-1-2 and marketing-1-2 roles and keeping the single role
if(pRole.role__c == 'Representative/Voting Contact'){
lItem.Representative_Voting_Contact__c = contactId;
}else if(pRole.Role__c == 'Authorized Signatory'){
lItem.Authorized_Signatory__c = contactId;
}else if(pRole.Role__c == 'Press Contact'){
lItem.Press_Contact__c = contactId;
}else if(pRole.Role__c == 'Legal Contact'){
lItem.Legal_Contact__c = contactId;
}else if(pRole.Role__c == 'PO Contact'){
lItem.PO_Contact__c = contactId;
}else if(pRole.Role__c == 'Event Sponsorship'){
lItem.Sponsorship_Contact__c = contactId;
}else if(pRole.role__c == 'Billing Contact'){
if(pRole.PrimaryContact__c) {
lItem.Billing_Contact__c = contactId;
}else if(lItem.Billing_Contact2__c == null){
lItem.Billing_Contact2__c = contactId;
}else  if(lItem.Billing_Contact3__c == null){
lItem.Billing_Contact3__c = contactId;
}
}else if(pRole.Role__c == 'Technical Contact'){
System.debug('lItem.Technical_Contact__c: ' + lItem.Technical_Contact__c);
System.debug('lItem.Technical_Contact_2__c: ' + lItem.Technical_Contact_2__c);
System.debug('lItem.Technical_Contact_3__c: ' + lItem.Technical_Contact_3__c);
if(pRole.PrimaryContact__c) {
lItem.Technical_Contact__c = contactId;
}else if(lItem.Technical_Contact_2__c == null){
lItem.Technical_Contact_2__c = contactId;
}else  if(lItem.Technical_Contact_3__c == null){
lItem.Technical_Contact_3__c = contactId;
}
}else if(pRole.Role__c == 'Marketing Contact'){
if(pRole.PrimaryContact__c) {
lItem.Marketing_Contact__c = contactId;
}else if(lItem.Marketing_Contact_2__c == null){
lItem.Marketing_Contact_2__c = contactId;
}else  if(lItem.Marketing_Contact_3__c == null){
lItem.Marketing_Contact_3__c = contactId;
}
}
}
listOpportunityLineItems.add(lItem);
System.debug('##listOpportunityLineItems update:'+listOpportunityLineItems);

if(!listOpportunityLineItems.isEmpty()){
OpportunityProductTriggerHandler.OpportunityProductTriggerRecursion = false;
update listOpportunityLineItems;
}
}
}catch(Exception e){
System.debug('Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());
}
}*/
    
    @AuraEnabled //get Account Industry Picklist Values
    public static Map<String, String> getRole(Id oliId){
        System.debug('oliId==>'+oliId);
        Map<String, String> options = new Map<String, String>();
        //get Role Field Describe
        Schema.DescribeFieldResult fieldResult = Project_role__c.Role__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        
        //Added by Priyesh @CloudRoute for adding extra membership roles defined in metadata
        if(oliId != null) {
            String slug = [SELECT Id, Projects__r.Slug__c FROM OpportunityLineItem WHERE Id =: oliId].Projects__r.Slug__c;
            System.debug('slug==>'+slug);
            for (Custom_Membership_Role__mdt membershipRoles : [
                SELECT id, MasterLabel, Membership_Role__c
                FROM Custom_Membership_Role__mdt
                WHERE Active__c = TRUE AND Project_Slug__c =: slug
            ]) {
                options.put(membershipRoles.Membership_Role__c, membershipRoles.Membership_Role__c);
            }
        }
        return options;
        //return JSON.serialize(PicklistOptionsUtility.getPicklistOptions(Schema.Project_role__c.Role__c.getDescribe(),true,false));
    }
    
    //Method to copy Project role from specified lineitem to all other lineitem of an opportunity
    @AuraEnabled
    public Static void copyProjectRoleToLineItem(Id activeLineItemId,Id oppId){
        
        //Variables
        set<string> setRole_Contact = new set<string>();
        set<string> setRole_Primary = new set<string>();
        List<String> excludeRolesList = new List<String>{'Finance Committee','Membership Committee',
            'Governance Framework Committee','Finance Committee','Event Sponsorship','MarCom Committee','Bedrock Technical Project'};
                
                //Projectroles that to be copied
                Map<Id,Project_role__c> projectRoleActiveLineItemMap = new Map<ID,Project_role__c>
                ([Select id,Asset__c,Contact__c,Role__c, ContactEmail__c,
                  Start_Date__c,End_Date__c,PrimaryContact__c,BoardMember__c,Status__c,
                  Opportunity__c,Opportunity_Line_Item__c 
                  FROM Project_role__c 
                  WHERE Opportunity__c =:oppId AND Opportunity_Line_Item__c =:activeLineItemId AND 
                  Status__c ='Active' AND Role__c NOT IN: excludeRolesList]);
        
        //Retrieve LineItems except the one which is passed as argument,Assets,ProjectRoles for the opportunity
        List<Opportunity> oppList = [SELECT Id,(SELECT  id,Asset__c,Contact__c,Role__c, ContactEmail__c,
                                                Start_Date__c,End_Date__c,PrimaryContact__c,BoardMember__c,Status__c,
                                                Opportunity__c,Opportunity_Line_Item__c 
                                                FROM Project_roles__r 
                                                WHERE  Id NOT IN: projectRoleActiveLineItemMap.keyset() AND 
                                                Status__c ='Active' AND Role__c NOT IN: excludeRolesList ),
                                     (SELECT Id,Start_Date__c,End_Date__c FROM OpportunityLineItems WHERE Id !=: activeLineItemId AND Projects__r.Membership_Roles_Not_Required__c = false),
                                     (SELECT ID,OpportunityLineItem__c FROM Asset__r WHERE OpportunityLineItem__c !=:activeLineItemId)
                                     FROM Opportunity WHERE Id =:oppId];
        
        Map<Id,Id> oliVSAssetIdMap = new Map<Id,Id>();
        Set<String> existingProjRoleSet = new Set<String>();
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        List<Project_role__c> lstPrRoleToInsert = new List<Project_role__c>();
        //Iterate
        for (Opportunity opp : oppList) {
            //Add the lineitems to list
            if(!opp.OpportunityLineItems.isEmpty()){
                
                oppLineItemList.addAll(opp.OpportunityLineItems);
                
            }
            //ProjectRoles
            if(!opp.Project_roles__r.isEmpty()){
                for(Project_role__c pRole : opp.Project_roles__r){
                    
                    String key = pRole.Opportunity_Line_Item__c+' '+pRole.Role__c+' '
                        +pRole.Contact__c+' '+pRole.PrimaryContact__c;
                    setRole_Contact.add(pRole.Opportunity_Line_Item__c+' '+pRole.Role__c+' '+pRole.Contact__c);
                    setRole_Primary.add(pRole.Opportunity_Line_Item__c+' '+pRole.Role__c+' '
                                        +pRole.PrimaryContact__c);
                    
                    existingProjRoleSet.add(key);
                    
                }
            }
            
            //Assets
            if(!opp.Asset__r.isEmpty()){
                for(Asset asst :opp.Asset__r){
                    oliVSAssetIdMap.put(asst.OpportunityLineItem__c,asst.Id);
                }
            }
            
        }
        
        if(!oppLineItemList.isEmpty()){
            //Project Role to be copied list
            for(Project_role__c projRoleToCopy : projectRoleActiveLineItemMap.values()){
                //LineItem on to which to copy
                for(OpportunityLineItem oli : oppLineItemList){
                    String key = oli.Id+' '+projRoleToCopy.Role__c+' '+projRoleToCopy.contact__c+' '+
                        projRoleToCopy.PrimaryContact__c;
                    //If that projectroles does not exist on lineitem
                    if(!setRole_Contact.contains(oli.Id+' '+projRoleToCopy.Role__c+' '+projRoleToCopy.Contact__c) && 
                       !setRole_Primary.contains(oli.Id+' '+projRoleToCopy.Role__c+' '+projRoleToCopy.PrimaryContact__c)){
                           
                           Project_role__c objProjectRole1 = new Project_role__c();
                           objProjectRole1.Contact__c = projRoleToCopy.Contact__c;
                           objProjectRole1.Role__c = projRoleToCopy.Role__c;
                           objProjectRole1.Start_Date__c = oli.Start_Date__c;
                           objProjectRole1.End_Date__c = oli.End_Date__c;
                           objProjectRole1.PrimaryContact__c = projRoleToCopy.PrimaryContact__c;
                           objProjectRole1.BoardMember__c = projRoleToCopy.BoardMember__c;
                           objProjectRole1.Status__c = projRoleToCopy.Status__c;
                           objProjectRole1.Opportunity__c = oppId;
                           objProjectRole1.Opportunity_Line_Item__c =oli.Id;
                           if(oliVSAssetIdMap.containsKey(oli.Id)){
                               objProjectRole1.Asset__c =oliVSAssetIdMap.get(oli.Id);
                           }
                           
                           lstPrRoleToInsert.add(objProjectRole1);
                           
                       }
                }
            }
            //Insert
            if(!lstPrRoleToInsert.isEmpty()){
                insert lstPrRoleToInsert;
            }
        }
    }
    
    //Old Method to Copy ProjectRoles .Kept in class for referring in future if any issue causes due to the new method
    /*
@AuraEnabled
public Static void insertCopiedProjectRole(Id newoppLineId,Id oppId,Id oldoppLineId){
system.debug('newoppLineId--->'+newoppLineId);  
system.debug('oppId--->'+oppId);  
system.debug('oldoppLineId--->'+oldoppLineId);
List<Project_role__c> lstPrRole = new List<Project_role__c>();
map<string,string> mapRoleActive = new map<string,string>();
map<string,boolean> mapPrimaryCheck = new map<string,boolean>();
set<string> setRole_Contact = new set<string>();
set<string> setRole_Primary = new set<string>();
set<Id> AssetId = new set<Id>();
Id parentAssetId;

//AssetId.add(objOpportunity.Parent_Asset__c);
//parentAssetId = objOpportunity.Parent_Asset__c;
//}
for(Project_role__c objProjectRole :[Select Contact__r.id,Role__c,Status__c,PrimaryContact__c from Project_role__c 
where Opportunity__c =:oppId AND Opportunity_Line_Item__c =:newoppLineId AND Status__c ='Active'
AND Role__c !='MarCom Committee' AND Role__c !='Bedrock Technical Project'
AND Role__c !='Finance Committee' AND Role__c !='Membership Committee'
AND Role__c !='Governance Framework Committee' AND Role__c !='Event Sponsorship']){
mapRoleActive.put(objProjectRole.Role__c+objProjectRole.Contact__r.id,objProjectRole.Status__c); 
setRole_Contact.add(objProjectRole.Role__c+objProjectRole.Contact__r.id);
setRole_Primary.add(objProjectRole.Role__c+objProjectRole.PrimaryContact__c);
// mapPrimaryCheck.put(objProjectRole.Role__c,objProjectRole.PrimaryContact__c);
}
for(Opportunity objOpportunity :[Select Parent_Asset__c,Type From Opportunity Where Id=:oppId AND isClosed =false]){
for(Project_role__c objProjectRole :[Select id,Asset__c,Contact__r.id,Contact__c,Role__c,Start_Date__c,End_Date__c,PrimaryContact__c,BoardMember__c,Status__c,Opportunity__c,Opportunity_Line_Item__c from Project_role__c 
where Opportunity__c =:oppId AND Opportunity_Line_Item__c =:oldoppLineId AND Status__c ='Active' AND Role__c !='MarCom Committee' AND Role__c !='Bedrock Technical Project'
AND Role__c !='Finance Committee' AND Role__c !='Membership Committee'
AND Role__c !='Governance Framework Committee' AND Role__c !='Event Sponsorship']){
if(!setRole_Contact.contains(objProjectRole.Role__c+objProjectRole.Contact__r.id) && 
!setRole_Primary.contains(objProjectRole.Role__c+objProjectRole.PrimaryContact__c)){
Project_role__c objProjectRole1 = new Project_role__c();
objProjectRole1.Contact__c = objProjectRole.Contact__c;
if(objOpportunity.Type =='Renewal' || objOpportunity.Type =='Renewal - Downgrade' || objOpportunity.Type =='Renewal - Upgrade'){
objProjectRole1.Asset__c =objOpportunity.Parent_Asset__c; 
}
objProjectRole1.Role__c = objProjectRole.Role__c;
objProjectRole1.Start_Date__c = objProjectRole.Start_Date__c;
objProjectRole1.End_Date__c = objProjectRole.End_Date__c;
objProjectRole1.PrimaryContact__c = objProjectRole.PrimaryContact__c;
objProjectRole1.BoardMember__c = objProjectRole.BoardMember__c;
objProjectRole1.Status__c = objProjectRole.Status__c;
objProjectRole1.Opportunity__c = oppId;
objProjectRole1.Opportunity_Line_Item__c =newoppLineId;
lstPrRole.add(objProjectRole1);
}
}
} 
for(Asset objAsset : [Select Id,OpportunityLineItem__c from Asset Where Opportunity__c =:oppId]){
for(Project_role__c objProjectRole :[Select id,Asset__c,Contact__r.id,Contact__c,Role__c,Start_Date__c,End_Date__c,PrimaryContact__c,BoardMember__c,Status__c,Opportunity__c,Opportunity_Line_Item__c from Project_role__c 
where Opportunity__c =:oppId AND Opportunity_Line_Item__c =:oldoppLineId AND Status__c ='Active' 
AND Role__c !='MarCom Committee' AND Role__c !='Bedrock Technical Project'
AND Role__c !='Finance Committee' AND Role__c !='Membership Committee'
AND Role__c !='Governance Framework Committee' AND Role__c !='Event Sponsorship']){
if(!setRole_Contact.contains(objProjectRole.Role__c+objProjectRole.Contact__r.id) && 
!setRole_Primary.contains(objProjectRole.Role__c+objProjectRole.PrimaryContact__c)
&& newoppLineId == objAsset.OpportunityLineItem__c){
Project_role__c objProjectRole1 = new Project_role__c();
objProjectRole1.Contact__c = objProjectRole.Contact__c;
objProjectRole1.Asset__c =objAsset.id; 
objProjectRole1.Role__c = objProjectRole.Role__c;
objProjectRole1.Start_Date__c = objProjectRole.Start_Date__c;
objProjectRole1.End_Date__c = objProjectRole.End_Date__c;
objProjectRole1.PrimaryContact__c = objProjectRole.PrimaryContact__c;
objProjectRole1.BoardMember__c = objProjectRole.BoardMember__c;
objProjectRole1.Status__c = objProjectRole.Status__c;
objProjectRole1.Opportunity__c = oppId;
objProjectRole1.Opportunity_Line_Item__c =newoppLineId;
lstPrRole.add(objProjectRole1);
}
}
}
if(lstPrRole.size()>0){
Insert lstPrRole;
}

}
*/
    
    @AuraEnabled //get Account Industry Picklist Values
    public static Map<String, String> getStatus(){
        Map<String, String> options = new Map<String, String>();
        //get Role Field Describe
        Schema.DescribeFieldResult fieldResult = Project_role__c.Status__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
        //return JSON.serialize(PicklistOptionsUtility.getPicklistOptions(Schema.Project_role__c.Status__c.getDescribe(),true,false));
    }
    
    public class ProjectRoleWrapper{
        @AuraEnabled public String contactName{get;set;}
        @AuraEnabled public Project_Role__c pr{get;set;}
        @AuraEnabled public string isOld{get;set;}
    }
}