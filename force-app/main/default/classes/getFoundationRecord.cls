public class getFoundationRecord {

    @AuraEnabled
    public static Project__c getFoundationName(String foundationId) {
        system.debug('Foundation Id:::'+foundationId);
        return [SELECT Name FROM Project__c WHERE id =: foundationId];
    }
}