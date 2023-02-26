@isTest public with sharing class BillToAddressesOnOppControllerTest {
    @isTest public static void testController() {
        //stage data
        Account acc = new Account();
        acc.Name = 'Acme Inc';
        insert acc;

        Address__c addr1 = new Address__c();
        addr1.Account__c = acc.Id;
        insert addr1;

        Address__c addr2 = new Address__c();
        addr2.Account__c = acc.Id;
        insert addr2;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Acme Opp';
        opp.StageName = '2. Discovery';
        opp.CloseDate = Date.today();
        opp.AccountId = acc.Id;
        opp.PaymentTerms__c = 'Net 30';
        insert opp;

        //test controller's methods and verify results
        List<Address__c> addresses = new List<Address__c>();
        addresses = BillToAddressesOnOppController.getBillToAddresses(opp.Id);
        System.assertEquals(2, addresses.size());
        
        ID nonexistantID1 = BillToAddressesOnOppController.getBillToAddress(opp.Id);
        System.assertEquals(null, nonexistantID1);
        
        BillToAddressesOnOppController.saveSelectedAddress(opp.Id, addr1.Id);
        ID addr1ID = BillToAddressesOnOppController.getBillToAddress(opp.Id);
        System.assertEquals(addr1.Id, addr1ID);
            
        BillToAddressesOnOppController.saveSelectedAddress(opp.Id, addr2.Id);
        ID addr2ID = BillToAddressesOnOppController.getBillToAddress(opp.Id);
        System.assertEquals(addr2.Id, addr2ID);
        
        BillToAddressesOnOppController.clearBillToAddress(opp.Id);
        ID nonexistantID2 = BillToAddressesOnOppController.getBillToAddress(opp.Id);
        System.assertEquals(null, nonexistantID2);
    }
}