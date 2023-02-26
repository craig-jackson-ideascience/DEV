@isTest
public class HotelCommissionsTriggerHandler_Test {
	
    @isTest
    public static void populateDefaultNSFields_Test(){
        List<Hotel_Commissions__c> hotelCommissionList = new List<Hotel_Commissions__c>(); 
        Account account = new Account();
        account.Name = 'Test Account For Hotel Commission';
        insert account;
        
        Contact contact = new Contact();
        contact.LastName = 'Test Contact for Hotel Commission';
        contact.AccountId = account.Id;
        contact.Email = 'testContact@hotel.com';
        insert contact;
        
        for(Integer i=0;i<80;i++){
            Hotel_Commissions__c hotelCommission = new Hotel_Commissions__c();
            hotelCommission.Name = 'test hotel Commission'+''+i;
            hotelCommission.Amount__c = 1000;
            hotelCommission.Bill_to_Account__c = account.Id;
            hotelCommission.Bill_to_Contact__c = contact.Id;
            hotelCommission.Start_Date__c = System.today();
            hotelCommission.Product_Description__c = 'test description';
            hotelCommissionList.add(hotelCommission);
        }
        insert hotelCommissionList;
        System.assertEquals('2', [SELECT Id,NS_Department__c FROM Hotel_Commissions__c limit 1].NS_Department__c);
        
        delete hotelCommissionList;
    }
}