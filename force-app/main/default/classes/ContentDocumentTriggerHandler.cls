public class ContentDocumentTriggerHandler implements ITriggerHandler {
    
    public static void BeforeInsert(List<SObject> triggerNew){
        //call before insert actions
    }

    public static void BeforeUpdate(Map<id,SObject> newContentDocument,Map<id,SObject> oldContentDocument){
        //call before update actions
    }

    public static void BeforeDelete(Map<Id, Sobject> oldMap){
        //call before delete actions
        clearFileIDFromRelatedRecords( (List<ContentDocument>)oldMap.values() );
    }

    public static void AfterInsert(Map<Id, SObject> newMap){
        //call after insert actions
    }

    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){
        //call after update actions
    }

    public static void AfterDelete(Map<Id, Sobject> oldMap){
        //call after delete actions
    }

    public static void AfterUndelete(Map<Id, Sobject> newMap){
        //call after undelete actions
    }

    public Boolean IsDisabled(){
        return false;
    }

    public static void clearFileIDFromRelatedRecords(List<ContentDocument> deletedDocs){
        Set<Id> deletedDocIDs = (new Map<Id,ContentDocument>(deletedDocs)).keySet();
        List<ContentVersion> docVersions = new List<ContentVersion>();
        docVersions = [SELECT Related_Record_ID__c, Document_Type__c, ContentDocument.Id
                       FROM ContentVersion
                       WHERE ContentDocument.Id IN :deletedDocIDs
                       AND Related_Record_ID__c != null
                       AND Document_Type__c != null
                      ];

        if(docVersions.size() == 0){
            //no related record ID (or no document type) on deleted files,
            //so exit method
            return;
        }

        Set<ID> accountIDs = new Set<ID>();
        Set<ID> projectIDs = new Set<ID>();

        for(ContentVersion dv : docVersions){
            switch on dv.Document_Type__c {
                when 'Account Training Master Service Agreement' {
                    accountIDs.add(dv.Related_Record_ID__c);
                }
                when 'Project Assignment Agreement' {
                    projectIDs.add(dv.Related_Record_ID__c);
                }
                when 'Project Dissolution Document' {
                    projectIDs.add(dv.Related_Record_ID__c);
                }
                when 'Project Governance Document' {
                    projectIDs.add(dv.Related_Record_ID__c);
                }
                when 'Project Incorporation Document' {
                    projectIDs.add(dv.Related_Record_ID__c);
                }
                when 'Project Management Services Agreement' {
                    projectIDs.add(dv.Related_Record_ID__c);
                }
                when 'Project Series Agreement' {
                    projectIDs.add(dv.Related_Record_ID__c);
                }
            }
        }

        List<Account> accounts = new List<Account>();
        List<Project__c> projects = new List<Project__c>();

        if( accountIDs.size() > 0 ){
            accounts = [SELECT Training_MSA_File_ID__c
                        FROM Account
                        WHERE ID IN :accountIDs
                       ];
        }else if( projectIDs.size() > 0 ){
            projects = [SELECT Assignment_Agreement_URL__c, Dissolution_Document_URL__c,
                               Governance_Document_URL__c, Project_Entity_Formation_Document__c,
                               MasterServiceAgreementURL__c, Series_Agreement_URL__c
                        FROM Project__c
                        WHERE ID IN :projectIDs
                       ];
        }else{
            //exit method, since no accounts or projects were queried
            return;
        }

        Boolean accountsModified = false;
        Boolean projectsModified = false;

        for(ContentVersion dv : docVersions){

            if(dv.Document_Type__c.startsWith('Account ')){
                for(Account acc : accounts){
                    if( idsMatch(dv.ContentDocument.Id, acc.Training_MSA_File_ID__c) ){
                        acc.Training_MSA_File_ID__c = null;
                        accountsModified = true;
                    }
                }
            }else if(dv.Document_Type__c.startsWith('Project ')){
                for(Project__c proj : projects){
                    switch on dv.Document_Type__c {
                        when 'Project Assignment Agreement' {
                            if( idMatchesURL(dv.ContentDocument.Id, proj.Assignment_Agreement_URL__c) ){
                                proj.Assignment_Agreement_URL__c = null;
                                projectsModified = true;
                            }
                        }
                        when 'Project Dissolution Document' {
                            if( idMatchesURL(dv.ContentDocument.Id, proj.Dissolution_Document_URL__c) ){
                                proj.Dissolution_Document_URL__c = null;
                                projectsModified = true;
                            }
                        }
                        when 'Project Governance Document' {
                            if( idMatchesURL(dv.ContentDocument.Id, proj.Governance_Document_URL__c) ){
                                proj.Governance_Document_URL__c = null;
                                projectsModified = true;
                            }
                        }
                        when 'Project Incorporation Document' {
                            if( idMatchesURL(dv.ContentDocument.Id, proj.Project_Entity_Formation_Document__c) ){
                                proj.Project_Entity_Formation_Document__c = null;
                                projectsModified = true;
                            }
                        }
                        when 'Project Management Services Agreement' {
                            if( idMatchesURL(dv.ContentDocument.Id, proj.MasterServiceAgreementURL__c) ){
                                proj.MasterServiceAgreementURL__c = null;
                                projectsModified = true;
                            }
                        }
                        when 'Project Series Agreement' {
                            if( idMatchesURL(dv.ContentDocument.Id, proj.Series_Agreement_URL__c) ){
                                proj.Series_Agreement_URL__c = null;
                                projectsModified = true;
                            }
                        }
                    }
                }
            }
        }

        if(accountsModified){
            update accounts;
        }

        if(projectsModified){
            update projects;
        }

        return;
    }

    private static Boolean idsMatch(ID fileID, String fileIDOnRelatedRecord){
        if( get18DigitIDString(fileIDOnRelatedRecord).equals(fileID) ){
            return true;
        }else{
            return false;
        }
    }

    private static Boolean idMatchesURL(ID fileID, String urlOnRelatedRecord){
        //get ID from URL on Related Record
        String urlBeginning = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/ContentDocument/';
        String idString = urlOnRelatedRecord.removeEnd('/view').removeStart(urlBeginning);
        return idsMatch(fileID, idString);
    }

    private static String get18DigitIDString(String idString){
        //get 18-digit ID, even if the 15-digit ID was provided
        if( idString.length() == 15 ){
            Id idValue = idString;
            String idString18 = idValue;
            return idString18;
        }else{
            return idString;
        }
    }

}