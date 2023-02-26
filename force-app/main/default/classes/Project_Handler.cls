public class Project_Handler implements ITriggerHandler{

    public static void BeforeInsert(List<Sobject> triggerNew) {
        //call on Insert action
        updateEDAndProgramManagerUser(triggerNew,null);
    }
    
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        markProjectForProcessing((Map<Id,Project__c>)newMap,(Map<Id,Project__c>)oldMap);
        updateEDAndProgramManagerUser((List<Project__c>)newMap.values(),(Map<Id,Project__c>)oldMap);
        //call before update actions
        // Project_Action action = new Project_Action();
        //   action.validateNetSuiteFieldsBeforeApproval((Map<Id,Project__c>)newMap,(Map<Id, Project__c>) oldMap);
        
    }    
  public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    } 
    
    public static void AfterInsert(Map<Id, SObject> newMap){
        //call onAfterInsert
        //createCollaborations((List<Project__c>)newMap.values());
    }   
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){  
        
        System.debug('>>>>>>> Call Project');
        //COMMENTED BY PRATIK D - 16-MAY-202
        //updateOpportunityOwner((Map<Id,Project__c>) oldMap, (Map<Id,Project__c>) newMap);
        updateRenewalOpportunityCloseDate((Map<Id, Project__c>) newMap,(Map<Id,Project__c>) oldMap);
    }
    
   public static void AfterDelete(Map<Id, Sobject> oldMap) {
    } 
    
    
   public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after undelete actions
    } 
    
    public Boolean IsDisabled(){
        return false;
    }
    
    //update Opp CloseDate based on projects' Days to deduct
    public static void updateRenewalOpportunityCloseDate(Map<Id, Project__c> newMap,Map<Id,Project__c> oldMap){
        Set<String> projectIdSet = new Set<String>();
        //Iterate through each record and check whether days to deduct is changed or not
        for(Project__c project : newMap.values()){
            if(project.Days_to_Deduct__c != oldMap.get(project.Id).Days_to_Deduct__c && 
               project.Days_to_Deduct__c != null){
                projectIdSet.add(project.Id);
            }
        }
        
        //if set is not empty
        if(!projectIdSet.isEmpty()){
            List<Opportunity> oppList = new List<opportunity>();
            //Get Line item of open renewal opportunity
            List<OpportunityLineItem> oppLineItem = [SELECT Id,OpportunityId,opportunity.parent_asset__r.UsageEndDate,Opportunity.closedate,
                                                     Projects__r.Days_to_Deduct__c
                                                     FROM OpportunityLineItem WHERE Projects__c IN: projectIdSet and Opportunity.Hold__c = false and 
                                                     opportunity.IsClosed = false and opportunity.type like 'Renewal%' and opportunity.parent_asset__c != null];
            if(!oppLineItem.isEmpty()){
                Utility util = new Utility();
                
                //Iterate through line item
                for(OpportunityLineItem oli : oppLineItem){
                    Date endDate = oli.opportunity.parent_asset__r.UsageEndDate;
                    Integer days = Integer.valueOf(oli.Projects__r.Days_to_Deduct__c);
                    
                    //call method to get closeddate
                    Date renewalCloseDate = util.getRenewalCloseDate(endDate, days);
                    if(renewalCloseDate != oli.Opportunity.closedate){
                        System.debug('Opp Id '+oli.OpportunityId+'---'+ oli.Opportunity.closedate);
                        //add to list
                        oppList.add(new Opportunity(Id=oli.OpportunityId,closedate=renewalCloseDate));
                    }
                }
                if(!oppList.isEmpty()){
                    system.debug('oppList '+oppList.size()+' '+oppList); 
                    //update
                    update oppList;
                }
            }
        }
    }
    
    //Mark Project Processing True when project status updated to Active
    public static void markProjectForProcessing( Map<Id,Project__c> newMap,Map<Id,Project__c> oldMap){
        //Id directedProjectId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Directed Fund').getRecordTypeId();
        //Id incorporatedProjectId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Incorporated').getRecordTypeId();
        for(Project__c proj : newMap.values()){
            if(proj.Status__c =='Active' && 
               (proj.Status__c != oldMap.get(proj.ID).Status__c ||
               proj.Name != oldMap.get(proj.ID).Name )&&
               (proj.LF_Membership_Required__c || proj.Category__c == 'Incorporated Entity')){
                proj.Project_Processing__c = true; 
            }
        }
        
    }
    
    // Whenver a project is created create colloborations
    /*public static void createCollaborations(List<Project__c> projects){
        List<Collaboration__c> collaborations = new List<Collaboration__c>();
        for(Project__c project : projects){
            //if the project type is foundation
            if(project.Project_Type__c == 'Foundation')
            {
                collaborations.add(createNewCollaboration('Committee','Governing Board',project.Id));
                collaborations.add(createNewCollaboration('Committee','TOC',project.Id));
                collaborations.add(createNewCollaboration('Committee','Marketing Committee',project.Id));
            }else if(project.Project_Type__c == 'Project'){
                collaborations.add(createNewCollaboration('Committers','Maintainers',project.Id));
                collaborations.add(createNewCollaboration('Committers','Top 100 Contributors',project.Id));
                collaborations.add(createNewCollaboration('Committee','TSC',project.Id));
            }
        }
        if(!collaborations.isEmpty()){
            insert collaborations;
        }
    }*/
    
    /*private static Collaboration__c createNewCollaboration(String collabType,String name,String projectId){
        Collaboration__c collaboration = new Collaboration__c();
        collaboration.Collaboration_Type__c =collabType;
        collaboration.Project_Name__c =projectId;
        collaboration.Collaboration_Name__c = name;
        return collaboration;
    }*/
    
     public static void updateEDAndProgramManagerUser(List<Project__c> projects, Map<Id,Project__c> oldProjects){
        List<Project__c> projectList = new List<Project__c>();
         for(Project__c project : projects) {
             if(oldProjects == null ||( oldProjects!= null && project.Program_Manager__c != oldProjects.get(project.ID).Program_Manager__c)){
                projectList.add(project);
             }
             if(oldProjects == null ||( oldProjects!= null && project.Executive_Director__c != oldProjects.get(project.ID).Executive_Director__c)){
                 projectList.add(project);
             }
             if(oldProjects == null ||( oldProjects!= null && project.Business_Development_Manager__c != oldProjects.get(project.ID).Business_Development_Manager__c)){
                projectList.add(project);   
             }
         }        
         if(!projectList.isEmpty()){
             Project_Action action = new Project_Action();
             action.updateEDAndProgramManagerUser(projectList);
         } 
    }
    //Added by pratik D For update Opportunity Owner From Project based on condition
    /*
    public static void updateOpportunityOwner(Map<Id,Project__c> oldMap, Map<Id,Project__c> newMap){
        
        system.debug('Inside');
        set<Id> setProjectId = new set<Id>();
        set<Id> setOpportunityId = new set<Id>();
        map<Id, Id> mapProjectId_OwnerId = new map<Id, Id>();
        map<Id, Id> mapProjectId_RenewOwnerId = new map<Id, Id>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        map<Id, Opportunity> mapOppId_OpportunityUpdate = new map<Id, Opportunity>();
        
        Id membershipRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        
        for(Project__c objProject : newMap.values()){
            
            if( objProject.Renewal_owner__c != oldMap.get(objProject.Id).Renewal_owner__c
                || objProject.Opportunity_owner__c != oldMap.get(objProject.Id).Opportunity_owner__c
                )
            {
                setProjectId.add(objProject.id);
                
                //Owner Preference - opportunityOwnerId, opportunityRenewOwner, ProgramManager
                Id opportunityOwnerId = ( objProject.Opportunity_owner__c != NULL ? objProject.Opportunity_owner__c : objProject.Program_Manager_U__c );
                
                //Owner Preference - opportunityRenewOwner, opportunityOwnerId, ProgramManager 
                
                Id opportunityRenewOwnerId = ( objProject.Renewal_owner__c != NULL ? objProject.Renewal_owner__c : 
                                                                             ( objProject.Opportunity_owner__c != NULL ? objProject.Opportunity_owner__c : objProject.Program_Manager_U__c ) 
                                                                             );
                
                mapProjectId_OwnerId.put( objProject.id, opportunityOwnerId);
                mapProjectId_RenewOwnerId.put( objProject.id, opportunityRenewOwnerId);
            }
        }
        
        map<Id,OpportunityLineItem> mapOpportunityLineItem = new map<Id,OpportunityLineItem>([ SELECT id,Projects__c,opportunityId,opportunity.ownerId 
                                                                                                FROM OpportunityLineItem 
                                                                                                WHERE Projects__c IN:setProjectId 
                                                                                                    AND opportunity.isClosed = false 
                                                                                                    AND opportunity.type != NULL
                                                                                                    AND opportunity.RecordTypeId =: membershipRTId
                                                                                                ]);

        for(OpportunityLineItem objOpportunityLineItem : mapOpportunityLineItem.values()){
            setOpportunityId.add(objOpportunityLineItem.opportunityId);
        }
        map<Id,Opportunity> mapOpportunity = new map<Id,Opportunity>([SELECT id, Name, ownerId, Total_Products_under_Opportunity__c, type
                                                                        FROM Opportunity 
                                                                        WHERE id IN:setOpportunityId 
                                                                            AND isClosed=false 
                                                                            AND type != NULL
                                                                            AND Opportunity.RecordTypeId =: membershipRTId
                                                                    ]);
        
        Integer cpuStart = Limits.getCpuTime();
        
        for(OpportunityLineItem objOpportunityLineItem : mapOpportunityLineItem.values()){
            
            Project__c objProject = newMap.get(objOpportunityLineItem.Projects__c); 
            
            Opportunity objOpportunity = mapOpportunity.get(objOpportunityLineItem.opportunityId);
            
                //NEW OPPORTUNITY
                if(objOpportunity.type == 'New Business'){
                    
                    if(objProject.name =='The Linux Foundation' && objOpportunity.Total_Products_under_Opportunity__c > 1){
                        
                        //DO NOT CHANGE OWNER
                    
                    }else{
                        //CHANGE OWNER
                        if(mapProjectId_OwnerId.get(objProject.Id) != null){
                            Opportunity opp = new Opportunity();
                            opp.Id = objOpportunity.Id;
                            opp.OwnerId = mapProjectId_OwnerId.get(objProject.Id);
                            mapOppId_OpportunityUpdate.put(opp.Id, opp);
                        }
                    }
                }else if( objOpportunity.type == 'Renewal' ){
                    
                    //RENEWAL OPPORTUNITY
                    if(mapProjectId_OwnerId.get(objProject.Id) != null){
                        Opportunity opp = new Opportunity();
                        opp.Id = objOpportunity.Id;
                        opp.OwnerId = mapProjectId_RenewOwnerId.get(objProject.Id);
                        mapOppId_OpportunityUpdate.put(opp.Id, opp);
                    }
                }
        }
        
        if(mapOppId_OpportunityUpdate.size()>0){
            update mapOppId_OpportunityUpdate.values();
        }
    }
    */
}