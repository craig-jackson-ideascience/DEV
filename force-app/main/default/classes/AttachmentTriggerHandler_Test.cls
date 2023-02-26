/********************************************************
* Created by: Martand Atrey @ CloudRoute Solutions
* Created Date: 04-11-2019.
* Description: AttachmentTriggerHandler_Test
********************************************************/
@isTest
public class AttachmentTriggerHandler_Test {
    static testMethod void testupdateDocusignContractFileName(){
        Account account =  new Account(Name='Test Account #1');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity #1', CloseDate = Date.today(),StageName = '2. Discovery',
                                                  AccountId = account.Id);
        insert opportunity;
        Attachment attach=new Attachment();   	
        attach.Name='OpportunityNameContract';
        Blob bodyBlob=Blob.valueOf('OpportunityNameContract');
        attach.body=bodyBlob;
        attach.parentId=opportunity.id;
        insert attach;
        System.assertEquals('Test Opportunity #1-FullyExecuted', [SELECT Name From Attachment WHERE ParentId = :opportunity.Id].Name);
        Attachment attachment = [SELECT Id,Name From Attachment WHERE ParentId = :opportunity.Id];
        attachment.Name = 'TEST ATTACHMENT';
        update attachment;
        delete attachment;
    }
}