@isTest
private class NewProductDetailsControllerTest {
    
    @TestSetup
    public static void createTestData(){
        //Creating Project Record
        Project__c objProject = new Project__c ();
        objProject.Name = 'New Test Project';
        objProject.Status__c = 'Planned';
        objProject.Type__c = 'Membership';
        objProject.Manual_Status_Check__c = false; 
        objProject.Category__c ='Incorporated Entity';
        objProject.Slug__c = 'testing';
        insert objProject; 
        
    }
    // Test Method: getSessionIdAndServerUrl
    public static testmethod void Test_getRecordTypeId(){
        System.Assert(NewProductDetailsController.getRecordTypeId('Project__c') != null);
        System.Assert(NewProductDetailsController.getRecordTypeId('Event__c') != null);
        System.Assert(NewProductDetailsController.getRecordTypeId('Training__c') != null);
        System.Assert(!NewProductDetailsController.fetchRecordTypeValues().isEmpty());
    }
    
    //Test Method for getRecTypeIdProject()
    @isTest
    public static  void getRecTypeIdProject_Test(){
        Project__c project =[SELECT Id,LF_Membership_Required__c FROM Project__c LIMIT 1];
        Map<String,Object> responseMap = NewProductDetailsController.getRecTypeIdProject('Membership',project.Id);
        System.assertEquals(true, responseMap.containsKey('RecordTypeId'));
        System.assertEquals(true, responseMap.containsKey('ProjectRecord'));
        System.assertEquals(false, ((Project__c)responseMap.get('ProjectRecord')).LF_Membership_Required__c);
        
    }
    
}