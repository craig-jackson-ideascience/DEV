public with sharing class ProjectFileUploadController {

    @AuraEnabled(cacheable=true)
    public static Boolean getUserEditAccess(Id projectID){
        //returns true if running user has edit access to the given project ID; otherwise returns false
        Project__c proj = [SELECT UserRecordAccess.HasEditAccess FROM Project__c WHERE Id = :projectID];
        return proj.UserRecordAccess.HasEditAccess;
    }

    @AuraEnabled
    public static void updateProjectAndFile(Id projectID, Id fileID, String docType, Date effectiveDate) {
        //expects one of the following docTypes:  assignment, dissolution, governance, incorporation, msa, series
        if(!(docType == 'assignment' || docType == 'dissolution' || docType == 'governance' ||
             docType == 'incorporation' || docType == 'msa' || docType == 'series')){
               return;
        }

        //query the file that was just uploaded
        ContentVersion file = [SELECT Title, CreatedDate
                               FROM ContentVersion
                               WHERE ContentDocumentId = :fileID
                               ORDER BY CreatedDate DESC
                               LIMIT 1];

        //query the project that the file was uploaded to
        Project__c proj = [SELECT Name, Assignment_Agreement_URL__c, Governance_Document_URL__c,
                                  Project_Entity_Formation_Document__c, MasterServiceAgreementURL__c,
                                  Series_Agreement_URL__c, Start_Date__c, Project_Entity_MSA_Date__c,
                                  Dissolution_Document_URL__c, Project_Entity_Dissolution_Date__c
                           FROM Project__c
                           WHERE Id = :projectID];

        //create the complete URL of the uploaded file
        String baseURL = System.Url.getOrgDomainUrl().toExternalForm();
        String fileURL = baseURL + '/lightning/r/ContentDocument/' + fileID + '/view';

        //set the appropriate Project field to the file's URL,
        //and set the docTypeName to be used in file's title
        String docTypeName = '';
        switch on docType {
            when 'incorporation' {
                proj.Project_Entity_Formation_Document__c = fileURL;
                docTypeName += 'Incorporation Document';
            }	
            when 'dissolution' {
                proj.Dissolution_Document_URL__c = fileURL;
                docTypeName += 'Dissolution Document';
            }
            when 'governance' {
                proj.Governance_Document_URL__c = fileURL;
                docTypeName += 'Governance Document';
            }
            when 'assignment' {
                proj.Assignment_Agreement_URL__c = fileURL;
                docTypeName += 'Assignment Agreement';
            }
            when 'msa' {
                proj.MasterServiceAgreementURL__c = fileURL;
                docTypeName += 'Management Services Agreement';
            }
            when 'series' {
                proj.Series_Agreement_URL__c = fileURL;
                docTypeName += 'Series Agreement';
            }
        }

        //handle the effective date for the specific document types it's relevant for
        if(docType == 'incorporation' || docType == 'series'){
            //set the Formation Date
            proj.Start_Date__c = effectiveDate;
        }else if(docType == 'msa'){
            //set the MSA Effective Date
            proj.Project_Entity_MSA_Date__c = effectiveDate;
        }else if(docType == 'dissolution'){
            //set the Dissolution/End Date
            proj.Project_Entity_Dissolution_Date__c = effectiveDate;
        }

        //update the project
        update proj;

        //set attributes on the file record
        file.Description = file.Title; //preserve original document name in the Description field
        file.Document_Type__c = 'Project ' + docTypeName;
        file.Related_Record_ID__c = projectID;

        //abbreviate the docTypeName used in the file's title for MSAs
        if(docTypeName == 'Management Services Agreement'){
            docTypeName = 'MSA';
        }

        //standardize titles of project-related files
        file.Title = proj.Name + ' ' + docTypeName;

        //update the file
        update file;
    }
    
}