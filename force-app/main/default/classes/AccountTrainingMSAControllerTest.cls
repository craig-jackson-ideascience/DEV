@isTest
private class AccountTrainingMSAControllerTest {

	@isTest static void testSeriesAgreementUpload() {
        //prep data
        Id fileID = createFile();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Website = 'testaccount.com';
        insert acc;
        
        //run method
		AccountTrainingMSAController.addFileIDToAccount(acc.Id, fileID);
        
        //query updated Account and verify result
        Account updatedAcc = new Account();
        updatedAcc = [SELECT Training_MSA_File_ID__c FROM Account WHERE ID = :acc.Id];
        System.assertEquals(fileID, updatedAcc.Training_MSA_File_ID__c);
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
    
}