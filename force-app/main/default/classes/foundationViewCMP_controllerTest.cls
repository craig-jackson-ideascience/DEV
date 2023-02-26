/****************
* Created Date: 12 SEP 2019
* Class Name : foundationViewCMP_controllerTest
* Type : Test Class 
* 
* 
* 
*****************/
@isTest
public class foundationViewCMP_controllerTest {
    
    testmethod static void createTestData(){
        //Creating Project Record Id
        //Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Directed Fund'].Id;
        Account acc = new Account();
        acc = testFactory.getAccount();
        Project__c testProjObj = new Project__c ();
        testProjObj.Name = 'New Test Project';
        //testProjObj.RecordTypeId = directedProjectId;
        testProjObj.Status__c = 'Planned';
        testProjObj.Type__c = 'Membership';
        testProjObj.Category__c = 'Directed Fund';
        testProjObj.Manual_Status_Check__c = false;
		testProjObj.Project_Type__c='Project Group';
        testProjObj.Slug__c = 'testing';
        testProjObj.Days_to_Deduct__c = '30';
        insert testProjObj;
        
        testProjObj.Status__c = 'Active';
        update testProjObj;
        
        // Creating Product2 Record in Test Class
        Product2 testProdObj = new Product2();
        testProdObj.Name ='Test Prod Record' ;
        testProdObj.Family = 'Membership';
        insert testProdObj;
        //Create Product Detail Record Id
        product_details__c productDetails = new product_details__c();
        productDetails.Project__c = testProjObj.Id;
        productDetails.Products__c = testProdObj.Id;
        productDetails.Status__c = 'Active';
        productDetails.Description__c = 'Test Product Detail';
        insert productDetails;
       
        //Creating the Opportunity for the Project
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opportunity';
        testOpp.StageName ='5.Decision Commitment';
        testOpp.CloseDate = Date.today();
        testOpp.Project_Name__c = testProjObj.Id;
        testOpp.RecordTypeId = RecordTypeIdOpportunity;
        testOpp.AccountId = acc.Id ;
        insert testOpp;
        
        //Creating the Asset for the Project
        Asset testAsset = new Asset();
        testAsset.Name ='Test Asset';
        testAsset.Product2Id= testProdObj.Id;
        testAsset.Projects__c= testProjObj.Id;
        testAsset.Status ='Active';
        insert testAsset;
            
        Test.startTest();
        foundationViewCMP_controller.getLoggedInUserRole_Apex();
        foundationViewCMP_controller.getFoundationDeails_Apex('',true);
        foundationViewCMP_controller.getFoundationDeails_Apex('Name',true);
        foundationViewCMP_controller.getFoundationDeails_Apex('',false);
        foundationViewCMP_controller.getFoundationDeails_Apex('Name',false);
        Test.stopTest();
    }
}