/**
 * Test class for SyncToNetSuiteController
 */
@isTest
public class SyncToNetSuiteController_Test {
    /**
	 * TestSetup inserting required data for test class
	 */
    @testSetup
    static void createTestData(){
    	Account account = TestDataUtils.createAccount(false, 'Test Account');
		account.website = 'testaccount.com';
		insert account;

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test Contact';
        contact.Email = 'testContact@noReply.com';
        insert contact;
        
        Project__c project = TestDataUtils.createProject(true, 'The Linux Foundation', 'Membership', 'Directed Fund', 'Planned');
        project.Status__c ='Active';
        project.Funding__c ='Funded';
        update project;
        
        Event__c evt = TestDataUtils.createEvent(false, 'Test Event', 'Unfunded', 'LF Event', 'Planned');
        evt.BillFromProject__c = project.Id;
        insert evt;
       
    }

    /**
	 * hotelCommissionSync_Test : Test Method for checkObjectType by passing Hotel_Commissions__c as Object Type
	 */    
	@isTest
    static void hotelCommissionSync_Test(){
        Account account = [SELECT Id FROM Account limit 1];
        Contact contact = [SELECT Id FROM Contact limit 1];
        Hotel_Commissions__c hotelCommission = new Hotel_Commissions__c();
        hotelCommission.Name = 'Test Hotel Commissions';
        hotelCommission.Amount__c = 123;
        hotelCommission.Bill_to_Account__c = account.Id;
        hotelCommission.Bill_to_Contact__c = contact.Id;
        hotelCommission.Product_Description__c = 'Test Description';
        hotelCommission.Start_Date__c = System.today();
        hotelCommission.End_Date__c = System.today()+2;
        insert hotelCommission;
        String returnedString = SyncToNetSuiteController.checkObjectType(hotelCommission.Id,'Hotel_Commissions__c');
        HotelCommissionSyncToNetSuiteController.HotelCommissionSyncWrapper wrapper = (HotelCommissionSyncToNetSuiteController.HotelCommissionSyncWrapper)JSON.deserialize(returnedString, HotelCommissionSyncToNetSuiteController.HotelCommissionSyncWrapper.class);
        
        //Asserts
        System.assertEquals('No files attached. Please upload the file.', wrapper.message,'There must be no files attached');
    }
    
    /**
	 * syncEMS_test : Test Method for checkObjectType by passing EMS__c as Object Type
	 */    
    @isTest
    static void syncEMS_test(){
        Account account = [SELECT Id FROM Account limit 1];
        Contact contact = [SELECT Id FROM Contact limit 1];
        Event__c event = [SELECT Id FROM Event__c limit 1];
        Project__c project = [SELECT Id FROM Project__c limit 1];
        EMS__c ems = new EMS__c();
        ems.Name = 'Test Hotel Commissions';
        ems.Amount__c = 123;
        ems.Bill_To_Account__c = account.Id;
        ems.Contact__c = contact.Id;
        ems.Description__c = 'Test Description';
        ems.StartDate__c = System.today();
        ems.Event__c = event.Id;
        ems.Bill_From__c = project.Id;
        
        insert ems;
        
        String returnedString = SyncToNetSuiteController.checkObjectType(ems.Id,'EMS__c');
        EMSSyncToNetSuiteController.EMSSyncWrapper wrapper = (EMSSyncToNetSuiteController.EMSSyncWrapper)JSON.deserialize(returnedString, EMSSyncToNetSuiteController.EMSSyncWrapper.class);
        
        //Asserts
        System.assertEquals('No files attached. Please upload the file.', wrapper.message,'There must be no files attached');
    }

     /**
	 * syncEMS_test : Test Method for checkObjectType by passing EMS__c as Object Type
	 */    
    @isTest
    static void syncAsset_test(){
        Asset asset =  TestFactory.getAsset();
        
        String returnedString = SyncToNetSuiteController.checkObjectType(asset.Id,'Asset');
        AssetSyncToNetSuiteController.AssetSyncWrapper wrapper = (AssetSyncToNetSuiteController.AssetSyncWrapper)JSON.deserialize(returnedString, AssetSyncToNetSuiteController.AssetSyncWrapper.class);
        System.debug('wrapper '+wrapper);
        //Asserts
        System.assertEquals('The Start Date is not populated.', wrapper.message,'Wrapper \'s message should match');
    }
}