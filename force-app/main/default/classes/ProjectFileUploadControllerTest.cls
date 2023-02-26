@isTest
private class ProjectFileUploadControllerTest {

	@isTest static void testSeriesAgreementUpload() {
        //prep data
        Id fileID = createFile();
        Id projID = TestDataUtils.createSeriesLLC();
        Date seriesAgreementDate = Date.newInstance(2000, 12, 31);
        
        //run method
		ProjectFileUploadController.updateProjectAndFile(projID, fileID, 'series', seriesAgreementDate);
        
        //query updated Project and verify results
        Project__c updatedSeriesLLC = new Project__c();
        updatedSeriesLLC = [SELECT Series_Agreement_URL__c, Start_Date__c
                            FROM Project__c
                            WHERE Id = :projID];
        System.assertEquals(getFileURL(fileID), updatedSeriesLLC.Series_Agreement_URL__c);
        System.assertEquals(seriesAgreementDate, updatedSeriesLLC.Start_Date__c);
	}
    
    @isTest static void testAssignmentAgreementUpload() {
        //prep data
        Id fileID = createFile();
        Id projID = TestDataUtils.createSeriesLLC();
        
        //run method
		ProjectFileUploadController.updateProjectAndFile(projID, fileID, 'assignment', null);
        
        //query updated Project and verify results
        Project__c updatedSeriesLLC = new Project__c();
        updatedSeriesLLC = [SELECT Assignment_Agreement_URL__c
                            FROM Project__c
                            WHERE Id = :projID];
        System.assertEquals(getFileURL(fileID), updatedSeriesLLC.Assignment_Agreement_URL__c);
	}
    
    @isTest static void testIncorporationDocumentUpload() {
        //prep data
        Id fileID = createFile();
        Id projID = createIncorporatedProject();
        Date incorporationDocumentDate = Date.newInstance(2000, 12, 31);
        
        //run method
		ProjectFileUploadController.updateProjectAndFile(projID, fileID, 'incorporation', incorporationDocumentDate);
        
        //query updated Project and verify results
        Project__c updatedInc = new Project__c();
        updatedInc = [SELECT Project_Entity_Formation_Document__c, Start_Date__c
                      FROM Project__c
                      WHERE Id = :projID];
        System.assertEquals(getFileURL(fileID), updatedInc.Project_Entity_Formation_Document__c);
        System.assertEquals(incorporationDocumentDate, updatedInc.Start_Date__c);
	}
    
    @isTest static void testMSAUpload() {
        //prep data
        Id fileID = createFile();
        Id projID = createIncorporatedProject();
        Date msaDate = Date.newInstance(2000, 12, 31);
        
        //run method
		ProjectFileUploadController.updateProjectAndFile(projID, fileID, 'msa', msaDate);
        
        //query updated Project and verify results
        Project__c updatedInc = new Project__c();
        updatedInc = [SELECT MasterServiceAgreementURL__c, Project_Entity_MSA_Date__c
                      FROM Project__c
                      WHERE Id = :projID];
        System.assertEquals(getFileURL(fileID), updatedInc.MasterServiceAgreementURL__c);
        System.assertEquals(msaDate, updatedInc.Project_Entity_MSA_Date__c);
	}
    
    @isTest static void testGovernanceDocumentUpload() {
        //prep data
        Id fileID = createFile();
        Id projID = createIncorporatedProject();
        
        //run method
		ProjectFileUploadController.updateProjectAndFile(projID, fileID, 'governance', null);
        
        //query updated Project and verify results
        Project__c updatedInc = new Project__c();
        updatedInc = [SELECT Governance_Document_URL__c
                      FROM Project__c
                      WHERE Id = :projID];
        System.assertEquals(getFileURL(fileID), updatedInc.Governance_Document_URL__c);
	}
    
    @isTest static void testDissolutionDocumentUpload() {
        //prep data
        Id fileID = createFile();
        Id projID = createIncorporatedProject();
        Date dissolutionDocumentDate = Date.newInstance(2000, 12, 31);
        
        //run method
		ProjectFileUploadController.updateProjectAndFile(projID, fileID, 'dissolution', dissolutionDocumentDate);
        
        //query updated Project and verify results
        Project__c updatedInc = new Project__c();
        updatedInc = [SELECT Dissolution_Document_URL__c, Project_Entity_Dissolution_Date__c
                      FROM Project__c
                      WHERE Id = :projID];
        System.assertEquals(getFileURL(fileID), updatedInc.Dissolution_Document_URL__c);
        System.assertEquals(dissolutionDocumentDate, updatedInc.Project_Entity_Dissolution_Date__c);
	}
    
    @isTest static void testPreventingUserAccess(){
        //create a standard user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User();
        u.Alias = 'standUsr';
        u.Email='test@linuxfoundation.org';
        u.EmailEncodingKey='UTF-8';
        u.LastName='Testing';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey='America/Los_Angeles';
        u.UserName='test@linuxfoundation.org';
        insert u;
        
        //create some project
        Id projectID = TestDataUtils.createSeriesLLC();
        
        //get standard user's edit access to that project
        Boolean result;
        System.runAs(u){
            result = ProjectFileUploadController.getUserEditAccess(projectID);
        }
        
        //verify standard user does not have access to use the file uploader
        System.assertEquals(false, result);
    }
    
    private static ID createFile(){
        //create new Content Version
        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf('Test Content Data');
        cv.Title = 'test file';
        cv.PathOnClient = 'test.pdf';
        insert cv;
        
        //query new Content Version to get ContentDocumentId from it
        ContentVersion uploadedFile = new ContentVersion();
        uploadedFile = [SELECT ContentDocumentId
                        FROM ContentVersion
                        WHERE Id = :cv.Id];
        
        return uploadedFile.ContentDocumentId;
    }
    
    private static Id createIncorporatedProject(){
        Project__c inc = new Project__c();
        inc.Name = 'Test Inc';
        inc.Project_Status__c = 'Formation - Exploratory';
        inc.Category__c = 'Incorporated Project';
        inc.Slug__c = 'test-inc';
        insert inc;
        return inc.Id;
    }
    
    private static String getFileURL(ID fileID){
        //return URL of newly created file
        String baseURL = System.Url.getOrgDomainUrl().toExternalForm();
        return baseURL + '/lightning/r/ContentDocument/' + fileID + '/view';
    }

}