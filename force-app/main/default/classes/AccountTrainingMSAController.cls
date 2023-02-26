public with sharing class AccountTrainingMSAController {

    @AuraEnabled
    public static void addFileIDToAccount(Id accountID, Id fileID) {
        Account acc = [SELECT Name, Training_MSA_File_ID__c
                       FROM Account
                       WHERE Id = :accountID];
        acc.Training_MSA_File_ID__c = fileID;
        update acc;

        ContentVersion file = [SELECT Title, CreatedDate
                               FROM ContentVersion
                               WHERE ContentDocumentId = :fileID
                               ORDER BY CreatedDate DESC
                               LIMIT 1];
        file.Description = file.Title; //preserve original document name in the Description field
        file.Title = 'Training MSA: ' + acc.Name; //standardize titles of all Training MSAs
        file.Document_Type__c = 'Account Training Master Service Agreement';
        file.Related_Record_ID__c = accountID;
        update file;
    }

}