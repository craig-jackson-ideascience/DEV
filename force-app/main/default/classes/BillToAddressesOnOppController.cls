public with sharing class BillToAddressesOnOppController {

    @AuraEnabled(cacheable=true)
    public static List<Address__c> getBillToAddresses(ID oppID) {
        Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :oppID LIMIT 1];
        List<Address__c> addresses = new List<Address__c>();
        addresses = [SELECT Name, Street__c, City__c, State__c, Zip_Postal_Code__c, Country__c
                     FROM Address__c
                     WHERE Account__c = :opp.AccountId];
        return addresses;
    }

    @AuraEnabled(cacheable=true)
    public static ID getBillToAddress(ID oppID) {
        Opportunity opp = [SELECT Bill_To_Address__c FROM Opportunity WHERE Id = :oppID LIMIT 1];
        return opp.Bill_To_Address__c;
    }

    @AuraEnabled
    public static void saveSelectedAddress(ID oppID, ID addrID){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppID LIMIT 1];
        opp.Bill_To_Address__c = addrID;
        update opp;
    }

    @AuraEnabled
    public static void clearBillToAddress(ID oppID){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppID LIMIT 1];
        opp.Bill_To_Address__c = null;
        update opp;
    }

}