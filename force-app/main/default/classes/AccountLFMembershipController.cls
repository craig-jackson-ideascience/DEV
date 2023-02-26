public with sharing class AccountLFMembershipController {

    @AuraEnabled(cacheable=true)
    public static List<String> getLFMembershipDetails(ID accountID) {
        List<Membership__c> lfMembership = new List<Membership__c>();
        lfMembership = [SELECT Status__c, Product__r.Name, Start_Date__c, End_Date__c
                        FROM Membership__c
                        WHERE Account__c = :accountID
                        AND Project__r.Name LIKE '%Linux Foundation%' order by Start_Date__c asc 
                       ];
        
        List<String> details = new List<String>();

        /*  
            Per SOPS-151 New Logic will support multiple LF Memberships and lend visibility to accounts that were either children or acquisitions.

            Logic
            If multiple LF Memberships then
            Active Membership = Active LF membership
            Active Membership end date = End Date
            Earliest start date regardless of status = member since
        */
        if(lfMembership.size() > 1){
            for (Membership__c membership : lfMembership) {
                if (membership.status__c == 'Active') {
                    details.add(membership.Status__c);
                    details.add(membership.Product__r.Name);
                    details.add(string.valueOf(lfMembership[0].Start_Date__c.year()));
                    details.add(membership.End_Date__c.format());
                }
            }
            //if no active memberships in multiple memberships, then return latest inactive membership
            if (details.isEmpty()) {
                Membership__c latestmembership = lfMembership.get(lfMembership.size()-1);
                details.add(latestmembership.Status__c);
                details.add(latestmembership.Product__r.Name);
                details.add(string.valueOf(latestmembership.Start_Date__c.year()));
                details.add(latestmembership.End_Date__c.format());
            }            
        } else if(lfMembership.size() == 1){            
       
            Integer startYear = lfMembership[0].Start_Date__c.year();
            String startYearString = String.valueOf(startYear);

            String endDateString = lfMembership[0].End_Date__c.format();

            details.add(lfMembership[0].Status__c);
            details.add(lfMembership[0].Product__r.Name);
            details.add(startYearString);
            details.add(endDateString);
        }
        return details;
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getAtRiskRenewals(ID accountID){
        Id membershipRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        return [SELECT Name, Amount, Owner.FirstName, Owner.LastName, CloseDate, StageName,
                       Hold__c, Hold_Reason__c, Renewal_Hold_Comment__c, Renewal_Likelihood__c
                FROM Opportunity
                WHERE AccountId = :accountID
                AND StageName != 'Closed Won'
                AND StageName != 'Closed Lost'
                AND Type LIKE 'Renewal%' 
                AND RecordTypeId = :membershipRTId
                AND (   StageName != :Label.Renewal_Opportunity_Stage
                     OR Hold__c = TRUE
                     OR Renewal_Likelihood__c LIKE 'At Risk%'
                    )
               ];
    }
    
    @AuraEnabled(cacheable=true)
    public static Account getAccountRecord(Id recordId)
    {
        system.debug('recordId--->'+recordId);
        return [Select Strategic_Account__c from Account where Id =:recordId];
    }
}