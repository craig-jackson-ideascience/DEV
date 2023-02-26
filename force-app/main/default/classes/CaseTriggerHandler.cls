public class CaseTriggerHandler implements ITriggerHandler{
    
    public static void BeforeInsert(List<SObject> triggerNew){
        updateContactLeadAndOwnerOnCase(Null,(List<Case>) triggerNew);
    }
    public void beforeUpdate(Map<Id,SObject> newMap, Map<Id,SObject> oldMap){
        updateContactLeadAndOwnerOnCase((Map<Id,Case>)oldMap,(List<Case>) newMap.values());
    }
    
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    } 
    
    public static void afterInsert(Map<Id, SObject> newMap){
        
        
    }      
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){ 
       
    } 
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) { 
        
    }
    
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        
    }
    public Boolean IsDisabled(){
        return false;
    }
    
    public static void updateContactLeadAndOwnerOnCase(Map<Id,Case> oldCaseMap,List<Case> newCaseMap){
        
        Set<string> jiraReporters = new Set<string>();
        Set<string> jiraAssignees = new Set<string>();
        
        List<Contact> lstContact = new List<Contact>();
        List<Lead> lstLead = new List<Lead>();
        List<User> lstUser = new List<User>();
        
        Map<string,Contact> usernameVsContact = new Map<string,Contact>();
        Map<string,Lead> usernameVsLead = new Map<string,Lead>();
        Map<string,User> lfidVsUser = new Map<string,User>();
        
        for(Case objCase :newCaseMap){
            if(String.isNotBlank(objCase.JIRA_Reporter__c) && (oldCaseMap == null || (oldCaseMap != null && oldCaseMap.get(objCase.Id).JIRA_Reporter__c != objCase.JIRA_Reporter__c))){
                jiraReporters.add(objCase.JIRA_Reporter__c);
            }
            if(String.isNotBlank(objCase.Jira_Assignee__c) && (oldCaseMap == null || (oldCaseMap != null && oldCaseMap.get(objCase.Id).Jira_Assignee__c != objCase.Jira_Assignee__c))){
                jiraAssignees.add(objCase.Jira_Assignee__c);
            }
        }
		
        if(!jiraReporters.isEmpty()){
        	lstContact =[Select Id,Username__c from Contact where Username__c IN:jiraReporters Limit 10000];
        	lstLead =[Select Id,Username__c from Lead where IsConverted = FALSE AND Username__c IN:jiraReporters Limit 5000];
        }
        if(!jiraAssignees.isEmpty()){
        	lstUser =[Select Id,User_LFID__c from User where IsActive = TRUE AND User_LFID__c IN:jiraAssignees Limit 2000];
        }
        if(!lstContact.isEmpty()){
            for(Contact objContact : lstContact){
              usernameVsContact.put(objContact.Username__c,objContact);   
            }
        }
        if(!lstLead.isEmpty()){
            for(Lead objLead : lstLead){
              usernameVsLead.put(objLead.Username__c,objLead);   
            }
        }
        if(!lstUser.isEmpty()){
            for(User objUser : lstUser){
              lfidVsUser.put(objUser.User_LFID__c,objUser);   
            }
        }
        for(Case objCase :newCaseMap){
            if(objCase.JIRA_Reporter__c != Null){
                if(usernameVsContact.containsKey(objCase.JIRA_Reporter__c)){
                    Contact objContact = usernameVsContact.get(objCase.JIRA_Reporter__c);
                	if(objContact != null){
                   		objCase.ContactId = objContact.id;
                   		objCase.Lead__c = Null;
                	}
                }
                if(usernameVsLead.containsKey(objCase.JIRA_Reporter__c)){
                	Lead objLead = usernameVsLead.get(objCase.JIRA_Reporter__c);
                	if(objLead != null){
                   		objCase.Lead__c =objLead.id;
                   		objCase.ContactId = Null;
                	}
            	}
            }
            if(objCase.Jira_Assignee__c != Null && lfidVsUser.containsKey((objCase.Jira_Assignee__c).toLowercase())){
                User objUser = lfidVsUser.get((objCase.Jira_Assignee__c).toLowercase());
                if(objUser != null){
                   objCase.OwnerId =objUser.id;
                }
            }
        }
    }

}