public class DeleteAutoJoinTestOppsBatch implements Database.Batchable<sObject>,Schedulable {
    
    String query;
    public void execute(SchedulableContext sc){
        Database.executeBatch(new DeleteAutoJoinTestOppsBatch());
    }
    
    public DeleteAutoJoinTestOppsBatch(){
    
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, (Select ID from Asset__r) , '+
            ' (Select ID from Project_Roles__r) , (Select ID from R00N80000002fD9vEAE ) ,(SELECT ContentDocumentId FROM ContentDocumentLinks ) '+
            'FROM Opportunity WHERE RecordType.Name = \'Membership\' AND (Name  Like \'Test - %\' OR IsSpam__c=true) AND Type = \'New Business\' '
        );
        
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope){ 
        Map <Id, Project_Role__c> projectRolesMap = new Map<Id, Project_Role__c>();
        map <Id, dsfs__DocuSign_Status__c > docusignStatusMap = new Map<Id, dsfs__DocuSign_Status__c >();
        map <Id, ContentDocumentLink > contentDocumentMap = new Map<Id, ContentDocumentLink >();
        List <ContentDocument> documentList = new List <ContentDocument>();
        Map <Id, Asset> assetMap = new Map<Id, Asset>();
        for(Opportunity opp : scope) 
        {
            for(Asset assetRec : opp.Asset__r) 
            { 
                assetMap.put(assetRec.ID, assetRec);
            }
            for(Project_Role__c projectRole : opp.Project_Roles__r) 
            { 
                projectRolesMap.put(projectRole.ID, projectRole);
            }
            for(dsfs__DocuSign_Status__c docusignStatus : opp.R00N80000002fD9vEAE) 
            { 
                docusignStatusMap.put(docusignStatus.ID, docusignStatus);
            }
            for(ContentDocumentLink document : opp.ContentDocumentLinks) 
            { 
                contentDocumentMap.put(document.ContentDocumentId, document);
            }
            
        }
        
        if(!contentDocumentMap.isEmpty()) 
        {
            documentList = [Select Id From ContentDocument Where ID IN: contentDocumentMap.keySet() ];
        }
        
        if(!assetMap.isEmpty()) 
        {
            List<Project_Role__c> projectRoles = [SELECT Id FROM Project_Role__c where asset__c IN :assetMap.keySet()];
            for(Project_Role__c projectRole : projectRoles)
            {
                projectRolesMap.put(projectRole.ID, projectRole);  
            }
        }
        if(!documentList.isEmpty()){
             delete documentList;
        }
        if(!projectRolesMap.isEmpty()){
            delete projectRolesMap.Values();
        }
        if(!docusignStatusMap.isEmpty()){
            delete docusignStatusMap.Values();
        }
        if(!assetMap.isEmpty()){
            delete assetMap.Values();
        }       
        delete scope;
    }
    
    
    public void finish(Database.BatchableContext bc){
        
    }    
}