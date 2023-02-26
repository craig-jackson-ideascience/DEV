@isTest
public class HotelCommissionSyncToNetsuite_Test {
    @testSetup
    public static void testdata(){
        
        Endpoints__c endPoint = new Endpoints__c();
        endPoint.Name = 'For Other than Membership Asset';
        endPoint.Endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=40&deploy=1';
        endPoint.Password__c = 'jYdpn8sp22F8C45b';
        endPoint.User_Id__c = 'nsapi@linuxfoundation.org';
        endPoint.Nlauth_Account__c = '4010327_SB1';
        insert endPoint;
        
        Endpoints__c endPoint2 = new Endpoints__c();
        endPoint2.Name = 'For Product Details';
        endPoint2.Endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=41&deploy=1';
        endPoint2.Password__c = 'jYdpn8sp22F8C45b';
        endPoint2.User_Id__c = 'nsapi@linuxfoundation.org';
        endPoint2.Nlauth_Account__c = '4010327_SB1';
        insert endPoint2;
        
    	Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test Contact';
        contact.Email = 'testContact@noReply.com';
        insert contact;
        
        Hotel_Commissions__c hotelCommission = new Hotel_Commissions__c();
        hotelCommission.Name = 'Test Hotel Commissions';
        hotelCommission.Amount__c = 123;
        hotelCommission.Bill_to_Account__c = account.Id;
        hotelCommission.Bill_to_Contact__c = contact.Id;
        hotelCommission.Product_Description__c = 'Test Description';
        hotelCommission.Start_Date__c = System.today();
        hotelCommission.End_Date__c = System.today()+2;
        insert hotelCommission;
        
        ContentVersion objCV = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.pdf',
                                                  VersionData = Blob.valueOf('Test Content'), 
                                                  IsMajorVersion = true );
        insert objCV;
        
        ContentVersion objContentVer = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :objCV.Id];
        ContentDocumentLink newFileShare = new ContentDocumentLink();
        system.debug('conDoc -->'+ objContentVer.contentDocumentid);
        newFileShare.contentdocumentid = objContentVer.contentDocumentid;
        newFileShare.LinkedEntityId = hotelCommission.Id;
        newFileShare.ShareType= 'V';
        insert newFileShare;
    }
    
	@isTest
    static void validateContactTest(){
        Hotel_Commissions__c hotelCommission= [SELECT Id FROM Hotel_Commissions__c limit 1];
        hotelCommission.Bill_to_Contact__c = null;
        update hotelCommission;
        
        String jsonWrapper = HotelCommissionSyncToNetSuiteController.validateAndSyncToNetSuite(hotelCommission.Id);
        Map<String, Object> hotelCommissionsMap = (Map<String, Object>) JSON.deserializeUntyped(jsonWrapper);
        system.assertEquals(hotelCommissionsMap.get('message'), 'The Bill To Contact field is not populated.');
    }
    
    @isTest
    static void validateFileTest(){
        Account account = [SELECT Id FROM Account limit 1];
        Contact contact = [SELECT Id FROM Contact limit 1];
        Hotel_Commissions__c hotelCommission = new Hotel_Commissions__c();
        hotelCommission.Name = 'Test Hotel Commissions';
        hotelCommission.Amount__c = 123;
        hotelCommission.Bill_to_Account__c = account.Id;
        hotelCommission.Product_Description__c = 'Test Description';
        hotelCommission.Start_Date__c = System.today();
        hotelCommission.End_Date__c = System.today()+2;
        insert hotelCommission;
        
        String jsonWrapper = HotelCommissionSyncToNetSuiteController.validateAndSyncToNetSuite(hotelCommission.Id);
        Map<String, Object> hotelCommissionsMap = (Map<String, Object>) JSON.deserializeUntyped(jsonWrapper);
        system.assertEquals(hotelCommissionsMap.get('message'), 'No files attached. Please upload the file.');
    }
    
    @isTest
    static void validateDescriptionTest(){
        Hotel_Commissions__c hotelCommission= [SELECT Id FROM Hotel_Commissions__c limit 1];
        hotelCommission.Product_Description__c = '';
        update hotelCommission;
        
        String jsonWrapper = HotelCommissionSyncToNetSuiteController.validateAndSyncToNetSuite(hotelCommission.Id);
        Map<String, Object> hotelCommissionsMap = (Map<String, Object>) JSON.deserializeUntyped(jsonWrapper);
        system.assertEquals(hotelCommissionsMap.get('message'), 'The Description is not populated.');
    }
    
    @isTest
    static void validateStartDateTest(){
        Hotel_Commissions__c hotelCommission= [SELECT Id FROM Hotel_Commissions__c limit 1];
        hotelCommission.Start_Date__c = null;
        update hotelCommission;
        String jsonWrapper = HotelCommissionSyncToNetSuiteController.validateAndSyncToNetSuite(hotelCommission.Id);
        Map<String, Object> hotelCommissionsMap = (Map<String, Object>) JSON.deserializeUntyped(jsonWrapper);
        system.assertEquals(hotelCommissionsMap.get('message'), 'The Start Date is not populated.');
    }
    
    @isTest
    static void validateEndDateTest(){
        Hotel_Commissions__c hotelCommission= [SELECT Id FROM Hotel_Commissions__c limit 1];
        hotelCommission.End_Date__c = null;
        update hotelCommission;
        
        String jsonWrapper = HotelCommissionSyncToNetSuiteController.validateAndSyncToNetSuite(hotelCommission.Id);
        Map<String, Object> hotelCommissionsMap = (Map<String, Object>) JSON.deserializeUntyped(jsonWrapper);
        system.assertEquals(hotelCommissionsMap.get('message'), 'The End Date is not populated.');
    }
    
    @isTest
    static void validateAmountTest(){
        Hotel_Commissions__c hotelCommission= [SELECT Id FROM Hotel_Commissions__c limit 1];
        hotelCommission.Amount__c = null;
        update hotelCommission;
        
        String jsonWrapper = HotelCommissionSyncToNetSuiteController.validateAndSyncToNetSuite(hotelCommission.Id);
        Map<String, Object> hotelCommissionsMap = (Map<String, Object>) JSON.deserializeUntyped(jsonWrapper);
        system.assertEquals(hotelCommissionsMap.get('message'), 'The Amount is not populated.');
    }
    
    @isTest
    static void validateAlreadySyncedTest(){
        Hotel_Commissions__c hotelCommission= [SELECT Id FROM Hotel_Commissions__c limit 1];
        hotelCommission.Sync_to_Netsuite__c = True;
        update hotelCommission;
        
        String jsonWrapper = HotelCommissionSyncToNetSuiteController.validateAndSyncToNetSuite(hotelCommission.Id);
        Map<String, Object> hotelCommissionsMap = (Map<String, Object>) JSON.deserializeUntyped(jsonWrapper);
        system.assertEquals(hotelCommissionsMap.get('message'), 'This record is already synced.');
    }
    
    @isTest
    static void validateSuccessTest(){
        List<Endpoints__c> endpoints = [SELECT name, endpoint__c, Password__c, User_Id__c, Nlauth_Account__c FROM Endpoints__c];
        Hotel_Commissions__c hotelCommission= [SELECT Id FROM Hotel_Commissions__c limit 1];
        
        Test.setMock(HttpCalloutMock.class, new NetSuiteToSalesforce_Mock());
        Test.startTest();
        String jsonWrapper = HotelCommissionSyncToNetSuiteController.validateAndSyncToNetSuite(hotelCommission.Id);
        Test.stopTest();
        System.debug('jsonWrapper'+jsonWrapper);
        Map<String, Object> hotelCommissionsMap = (Map<String, Object>) JSON.deserializeUntyped(jsonWrapper);
        system.assertEquals(True, hotelCommissionsMap.get('isSuccess'));
    }
}