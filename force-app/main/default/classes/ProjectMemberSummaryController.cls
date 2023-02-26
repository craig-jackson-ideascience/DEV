public with sharing class ProjectMemberSummaryController {

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getCorporateMemberships(ID projectID) {
        List<AggregateResult> groupedResults = new List<AggregateResult>();
        groupedResults = [SELECT Product__r.Name, COUNT(Id)
                          FROM Membership__c
                          WHERE Project__c = :projectID
                          AND Product__c != null
                          AND (Status__c = 'Active' OR Status__c = 'Purchased')
                          GROUP BY Product__r.Name
                          ORDER BY AVG(Annual_Price__c) DESC
                         ];
        return groupedResults;
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getIndividualMemberships(ID projectID) {
        List<AggregateResult> groupedResults = new List<AggregateResult>();
        groupedResults = [SELECT Product2.Name, COUNT(Id)
                          FROM Asset
                          WHERE Projects__c = :projectID 
                          AND Status = 'Active'
                          AND ProductFamily = 'Membership'
                          AND RecordTypeId = :Label.Individual_Asset_Record_Type
                          AND Product2.Name != 'Individual Supporter'
                          AND Product2.Name != 'Lifetime Linux.com Email Add-On'
                          GROUP BY Product2.Name 
                          ORDER BY AVG(Price) DESC
                         ];
        return groupedResults;
    }

}