@IsTest
public class BatchUpdateAccountPicklistTest {

    @IsTest
    static void UpdatePicklistSuccessTest() {
        //Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Subproject'].Id;
        
        Project__c proj = new Project__c();
        proj.Name = 'testProject';
        proj.Category__c = 'Incorporated Entity';
        proj.Status__c = 'Planned';
        proj.Type__c = 'Membership';
        proj.Manual_Status_Check__c = false;
        proj.Slug__c = 'test_slug';
        insert proj;
        
        Project__c Proj1 = new Project__c();
        proj1.Category__c = 'Incorporated Entity';
        proj1.Status__c = 'Planned';
        proj1.Type__c = 'Membership';
        proj1.Manual_Status_Check__c = false;
        proj1.Name = 'testProject1';
        proj1.Slug__c = 'test_slug1';
        insert proj1;
        
        proj.Status__c = 'Active';
        proj.Manual_Status_Check__c = false;
        update proj;
        
        proj1.Status__c = 'Active';
        proj1.Manual_Status_Check__c = false;
        update proj1;
        
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl(true));
        BatchUpdateAccountPicklist picklistUpdate = new BatchUpdateAccountPicklist();
        Database.executeBatch(picklistUpdate);
        Test.stopTest();
        
        
    }

    @IsTest
    static void UpdatePicklistErrorTest() {
        //Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Subproject'].Id;
        
        Project__c proj = new Project__c();
        proj.Name = 'testProject';
        proj.Category__c = 'Incorporated Entity';
        proj.Status__c = 'Planned';
        proj.Type__c = 'Membership';
        proj.Manual_Status_Check__c = false;
        proj.Slug__c = 'test_slug';
        insert proj;
        
        Project__c Proj1 = new Project__c();
        proj1.Category__c = 'Incorporated Entity';
        proj1.Status__c = 'Planned';
        proj1.Type__c = 'Membership';
        proj1.Manual_Status_Check__c = false;
        proj1.Name = 'testProject1';
        proj1.Slug__c = 'test_slug1';
        insert proj1;
        
        proj.Status__c = 'Active';
        proj.Manual_Status_Check__c = false;
        update proj;
        
        proj1.Status__c = 'Active';
        proj1.Manual_Status_Check__c = false;
        update proj1;
        
        Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl(false));
        try{
            Test.startTest();
            BatchUpdateAccountPicklist picklistUpdate = new BatchUpdateAccountPicklist();
            Database.executeBatch(picklistUpdate);
            
            Test.stopTest();
        }catch(Exception e){
            
        }
        
    }
    
}