@isTest
private class ContentDocumentTriggerHandlerTest {
    
    @isTest static void testRegularFileDelete() {
        //prep data
        Id fileID = createFile();
        
        //delete file
        deleteFile(fileID);
        
        //verify file was deleted
        Boolean wasDeleted = verifyFileDelete(fileID);
        System.assertEquals(true, wasDeleted);
    }
    
    @isTest static void testProjectSeriesAgreementDelete() {
        //prep data
        Id fileID = createFile();
        Id projID = createSeriesLLC();
        Date seriesAgreementDate = Date.newInstance(2000, 12, 31);
		ProjectFileUploadController.updateProjectAndFile(projID, fileID, 'series', seriesAgreementDate);
        
		//delete file
		deleteFile(fileID);
        
        //verify file was deleted
        Boolean wasDeleted = verifyFileDelete(fileID);
        System.assertEquals(true, wasDeleted);
        
        //verify Series Agreement URL field on Project was cleared out
        Project__c proj = new Project__c();
        proj = [SELECT Series_Agreement_URL__c FROM Project__c WHERE ID = :projID];
        System.assertEquals(null, proj.Series_Agreement_URL__c);
	}
    
    @isTest static void testProjectAssignmentAgreementDelete() {
        //prep data
        Id fileID = createFile();
        Id projID = createSeriesLLC();
		ProjectFileUploadController.updateProjectAndFile(projID, fileID, 'assignment', null);
        
        //delete file
        deleteFile(fileID);
        
        //verify file was deleted
        Boolean wasDeleted = verifyFileDelete(fileID);
        System.assertEquals(true, wasDeleted);
        
        //verify Assignment Agreement URL field on Project was cleared out
        Project__c proj = new Project__c();
        proj = [SELECT Assignment_Agreement_URL__c FROM Project__c WHERE ID = :projID];
        System.assertEquals(null, proj.Assignment_Agreement_URL__c);
	}
    
    @isTest static void testProjectIncorporationDocumentDelete() {
        //prep data
        Id fileID = createFile();
        Id projID = createIncorporatedProject();
        Date incorporationDocumentDate = Date.newInstance(2000, 12, 31);
		ProjectFileUploadController.updateProjectAndFile(projID, fileID, 'incorporation', incorporationDocumentDate);
        
        //delete file
        deleteFile(fileID);
        
        //verify file was deleted
        Boolean wasDeleted = verifyFileDelete(fileID);
        System.assertEquals(true, wasDeleted);
        
        //verify Incorporation Document URL field on Project was cleared out
        Project__c proj = new Project__c();
        proj = [SELECT Project_Entity_Formation_Document__c FROM Project__c WHERE ID = :projID];
        System.assertEquals(null, proj.Project_Entity_Formation_Document__c);
	}
    
    @isTest static void testProjectMSADelete() {
        //prep data
        Id fileID = createFile();
        Id projID = createIncorporatedProject();
        Date msaDate = Date.newInstance(2000, 12, 31);
		ProjectFileUploadController.updateProjectAndFile(projID, fileID, 'msa', msaDate);
        
        //delete file
        deleteFile(fileID);
        
        //verify file was deleted
        Boolean wasDeleted = verifyFileDelete(fileID);
        System.assertEquals(true, wasDeleted);
        
        //verify Management Services Agreement URL field on Project was cleared out
        Project__c proj = new Project__c();
        proj = [SELECT MasterServiceAgreementURL__c FROM Project__c WHERE ID = :projID];
        System.assertEquals(null, proj.MasterServiceAgreementURL__c);
	}
    
    @isTest static void testProjectGovernanceDocumentDelete() {
        //prep data
        Id fileID = createFile();
        Id projID = createIncorporatedProject();
		ProjectFileUploadController.updateProjectAndFile(projID, fileID, 'governance', null);
        
        //delete file
        deleteFile(fileID);
        
        //verify file was deleted
        Boolean wasDeleted = verifyFileDelete(fileID);
        System.assertEquals(true, wasDeleted);
        
        //verify Governance Document URL field on Project was cleared out
        Project__c proj = new Project__c();
        proj = [SELECT Governance_Document_URL__c FROM Project__c WHERE ID = :projID];
        System.assertEquals(null, proj.Governance_Document_URL__c);
	}
    
    @isTest static void testProjectDissolutionDocumentDelete() {
        //prep data
        Id fileID = createFile();
        Id projID = createIncorporatedProject();
        Date dissolutionDocumentDate = Date.newInstance(2000, 12, 31);
		ProjectFileUploadController.updateProjectAndFile(projID, fileID, 'dissolution', dissolutionDocumentDate);
        
        //delete file
        deleteFile(fileID);
        
        //verify file was deleted
        Boolean wasDeleted = verifyFileDelete(fileID);
        System.assertEquals(true, wasDeleted);
        
        //verify Dissolution Document URL field on Project was cleared out
        Project__c proj = new Project__c();
        proj = [SELECT Dissolution_Document_URL__c FROM Project__c WHERE ID = :projID];
        System.assertEquals(null, proj.Dissolution_Document_URL__c);
	}
    
    @isTest static void testAccountMSADelete() {
        //prep data
        Id fileID = createFile();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Website = 'testaccount.com';
        insert acc;
        AccountTrainingMSAController.addFileIDToAccount(acc.Id, fileID);
        
        //delete file
        deleteFile(fileID);
        
        //verify file was deleted
        Boolean wasDeleted = verifyFileDelete(fileID);
        System.assertEquals(true, wasDeleted);
        
        //verify Training MSA File ID field on Account was cleared out
        Account acc2 = new Account();
        acc2 = [SELECT Training_MSA_File_ID__c FROM Account WHERE ID = :acc.Id];
        System.assertEquals(null, acc2.Training_MSA_File_ID__c);
    }
    
    @isTest static void testAccountMSADelete15Digit() {
        //repeats Account MSA delete test, but this time with a 15-digit
        //ID in the Training_MSA_File_ID__c field (instead of the 18-digit
        //ID this field will typically have)
        
        //prep initial data
        Id fileID = createFile();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Website = 'testaccount.com';
        insert acc;
        AccountTrainingMSAController.addFileIDToAccount(acc.Id, fileID);
        
        //query 18-digit ID currently in the Training MSA File ID
        Account acc2 = new Account();
        acc2 = [SELECT Training_MSA_File_ID__c FROM Account WHERE ID = :acc.Id];
        
        //update 18-digit ID (string) to a 15-digit ID (string)
        Integer currentLength = acc2.Training_MSA_File_ID__c.length();
        String fifteenDigitID;
        if(currentLength == 18){
            fifteenDigitID = acc2.Training_MSA_File_ID__c.substring(0, 15);
        }
        
        //confirm this is now 15 digits to ensure a proper test
        System.assertEquals(15, fifteenDigitID.length());
        
        //update the Account MSA field with the 15-digit ID
        acc2.Training_MSA_File_ID__c = fifteenDigitID;
        update acc2;
        
        //delete file
        deleteFile(fileID);
        
        //verify file was deleted
        Boolean wasDeleted = verifyFileDelete(fileID);
        System.assertEquals(true, wasDeleted);
        
        //verify Training MSA File ID field on Account was cleared out
        Account acc3 = new Account();
        acc3 = [SELECT Training_MSA_File_ID__c FROM Account WHERE ID = :acc.Id];
        System.assertEquals(null, acc3.Training_MSA_File_ID__c);
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
    
    private static Id createSeriesLLC(){
        //Project
        Project__c prj = new Project__c(Name = 'LF Projects, LLC',Slug__c='lfproject', Do_not_Invoice__c = true,Status__c = 'Planned',Category__c = 'Subproject');
        insert prj;

        Project__c seriesLLC = new Project__c();
        seriesLLC.Name = 'Test Series LLC';
        seriesLLC.Project_Status__c = 'Formation - Exploratory';
        seriesLLC.Category__c = 'Series LLC';
        seriesLLC.Slug__c = 'test-series-llc';
        seriesLLC.Parent_Entity_Relationship__c = prj.Id;
        insert seriesLLC;
        return seriesLLC.Id;
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
    
    private static void deleteFile(ID fileID){
        ContentDocument file = new ContentDocument();
        file = [SELECT Id FROM ContentDocument WHERE Id = :fileID];
        delete file;
        return;
    }
    
    private static Boolean verifyFileDelete(ID fileID){
        List<ContentDocument> files = new List<ContentDocument>();
        files = [SELECT Id FROM ContentDocument WHERE Id = :fileID];
        if(files.size() == 0){
            return true;
        }else{
            return false;
        }
    }

}