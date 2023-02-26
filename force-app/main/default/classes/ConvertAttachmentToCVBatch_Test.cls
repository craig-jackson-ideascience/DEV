@isTest
public class ConvertAttachmentToCVBatch_Test {
    @testsetup
    public static void makeData(){
        Account account =  new Account(Name='Test Account #1');
        insert account;
        Project__c proj = TestFactory.getProject();
        List<opportunity> oppList = new List<Opportunity>();
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity #1', CloseDate = Date.today(),StageName = '2. Discovery',
                                                  AccountId = account.Id,Project_Name__c=proj.Id);
        oppList.add(opportunity);
        
        Opportunity opportunity1 = new Opportunity(Name = 'Test Opportunity #2', CloseDate = Date.today(),StageName = '2. Discovery',
                                                   AccountId = account.Id,Project_Name__c=proj.Id);
        oppList.add(opportunity1);
        insert oppList;
        List<attachment> attachmentList = new List<Attachment>();
        For(Integer i=0;i<oppList.size();i++){
            Attachment attach=new Attachment();   	
            attach.Name='Test Attach executed'+i;
            Blob bodyBlob=Blob.valueOf('OpportunityNameContract'+i);
            attach.body=bodyBlob;
            attach.parentId=oppList[i].id;
            attachmentList.add(attach);
        }
        insert attachmentList;
        
        
    }
    @isTest
    public static void testData(){
       String query='select id,(SELECT Id,AccountId,Project_Name__c,Name FROM Opportunities'+
                                              ' WHERE RecordType.Name=\'Membership\' order by createddate desc) '+
           'from Account';
		
        Test.startTest();
        Database.executebatch(new ConvertAttachmentToCVBatch(query));
        Test.stopTest();
        List<Opportunity> oppList = [SELECT Id FROm Opportunity];
        System.assertEquals(false, [SELECT Id From ContentVersion 
                                              WHERE FirstPublishLocationId IN:oppList].isEmpty());
       
    }
}