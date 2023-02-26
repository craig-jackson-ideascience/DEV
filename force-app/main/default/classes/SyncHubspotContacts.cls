/********************************************************
 * Created by: CloudRoute @ CloudRoute Solutions
 * Created Date: 30/06/21.
 * Description: SyncHubspotContacts
 ********************************************************/

global class SyncHubspotContacts implements Schedulable{

    public static Set<String> emails;
    public static Boolean hasMore;
    public static Integer vidOffset;

    global void execute(SchedulableContext SC) {
        startHubspotContactsSync();
    }


    public static void startHubspotContactsSync(){

        emails = new Set<String>();
        hasMore = true;
        vidOffset = 0;
        Integer i = 0;

        while (hasMore && i < 10 ){ //To get only 1000 record
            i++;
            getHubspotContacts();
        }

        updateLeadsAndContacts();
    }

    public static Boolean getHubspotContacts(){
        String endPointUrl = Label.Hubspot_ContactSync_Endpoint +  '?hapikey=' + Label.Hubspot_Api_Key + '&count=100';

        if (vidOffset > 0) {
            endPointUrl += '&vidOffset=' + vidOffset;
        }

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPointUrl);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(request);

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        hasMore = (Boolean) responseMap.get('has-more');
        vidOffset = (Integer) responseMap.get('vid-offset');

        List<Object> contacts = (List<Object>) responseMap.get('contacts');

        for (Object contactObj : contacts) {

            String contact = JSON.serialize(contactObj);
            Map<String, Object> contactPropertyMap = (Map<String, Object>) JSON.deserializeUntyped(contact);

            List<Object> identityProfiles = (List<Object>) contactPropertyMap.get('identity-profiles');
            String identityProfilesJSON = JSON.serialize(identityProfiles[0]);
            Map<String, Object> identityProfilesMap = (Map<String, Object>) JSON.deserializeUntyped(identityProfilesJSON);

            List<Object> identities = (List<Object>) identityProfilesMap.get('identities');
            for (Object obj : identities) {
                String identity = JSON.serialize(obj);
                Map<String, Object> identityMap = (Map<String, Object>) JSON.deserializeUntyped(identity);

                if (identityMap.containsKey('type') && (String) identityMap.get('type') == 'EMAIL') {
                    emails.add((String)identityMap.get('value'));
                }
            }
        }

        return hasMore;
    }

    public static void updateLeadsAndContacts(){
        Set<Contact> contactsToUpdate = new Set<Contact>();
        Set<Lead> leadsToUpdate = new Set<Lead>();

        for(Alternate_Email__c alternateEmail : [
                SELECT Id, Contact_Name__c, Contact_Name__r.Hubspot__c, Lead_Name__c, Lead_Name__r.Hubspot__c
                FROM Alternate_Email__c
                WHERE Alternate_Email_Address__c IN :emails
        ]){
            if (alternateEmail.Contact_Name__c != null && !alternateEmail.Contact_Name__r.Hubspot__c) {
                Contact con = new Contact();
                con.Id = alternateEmail.Contact_Name__c;
                con.Hubspot__c = true;
                contactsToUpdate.add(con);
            } else if(alternateEmail.Lead_Name__c != null && !alternateEmail.Lead_Name__r.Hubspot__c) {
                Lead l = new Lead();
                l.Id = alternateEmail.Lead_Name__c;
                l.Hubspot__c = true;
                leadsToUpdate.add(l);
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            update new List<Contact>(contactsToUpdate);
        }

        if (!leadsToUpdate.isEmpty()) {
            update new List<Lead>(leadsToUpdate);
        }

    }
}