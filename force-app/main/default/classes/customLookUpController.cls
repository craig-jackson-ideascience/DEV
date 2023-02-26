public class customLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName,string ContactId) {
        system.debug('ObjectName-->' + ObjectName);
        system.debug('searchKeyWord-->' + searchKeyWord);
        system.debug('ContactId-->'+ContactId);
        String searchKey = searchKeyWord + '%';

        List < sObject > returnList = new List < sObject > ();

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5

        //String sQuery =  'select id, Name from ' +ObjectName + ' where (Name LIKE: searchKey OR Email LIKE: searchKey) order by createdDate DESC limit 5';

        //Added by Priyesh @CloudRoute to search contacts by alternate email as well
        String sQuery;
        if(string.isNotEmpty(ContactId)){
            sQuery = 'select Id, Contact_Name__r.FirstName,Contact_Name__r.Account_Name__c,Contact_Name__r.Email,Contact_Name__r.Account.Name,Contact_Name__r.Name, Contact_Name__r.LastName, Contact_ID__c from ' + ObjectName + ' where Contact_Name__c != null AND Contact_Name__r.Name LIKE: searchKey AND Contact_Name__r.id=:ContactId AND Active__c = true order by createdDate DESC limit 50';
        }else{
         sQuery = 'select Id, Contact_Name__r.FirstName,Contact_Name__r.Account_Name__c,Contact_Name__r.Email,Contact_Name__r.Account.Name,Contact_Name__r.Name, Contact_Name__r.LastName, Contact_ID__c from ' + ObjectName + ' where Contact_Name__c != null AND (Contact_Name__r.Name LIKE: searchKey OR Alternate_Email_Address__c LIKE: searchKey) AND Active__c = true order by createdDate DESC limit 50';
        }
            System.debug('sQuery: ' + sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        System.debug('lstOfRecords: ' + lstOfRecords);
        Set<String> uniqueContactId = new Set<String>();
        for (sObject obj: lstOfRecords) {
            if(uniqueContactId.size() < 5) {
                if(!uniqueContactId.contains((String)obj.get('Contact_ID__c'))) {
                    uniqueContactId.add((String) obj.get('Contact_ID__c'));
                    sObject tempObj = Schema.getGlobalDescribe().get('Contact').newSObject();
                    tempObj.put('Id', obj.get('Contact_ID__c'));
                    tempObj.put('FirstName', obj.getSObject('Contact_Name__r').get('FirstName'));
                    tempObj.put('LastName', obj.getSObject('Contact_Name__r').get('LastName'));
                    tempObj.put('Title', obj.getSObject('Contact_Name__r').get('Account_Name__c'));
                    tempObj.put('Email', obj.getSObject('Contact_Name__r').get('Email'));
                    returnList.add(tempObj);
                }
            }else{
                break;
            }
        }
        System.debug('uniqueContactId: ' + uniqueContactId);
        //returnList = [SELECT Id, Name FROM Contact WHERE Id In: uniqueContactId];

        System.debug('returnList: ' + returnList);
        return returnList;
    }
}