/*Utilty Class for hubspot
* Test-Class-Covered from -TestLeadTrigger and ContactTriggerHandlerTest
*/
public class Hubspot_Utility {
    @future(callout=true)
    public static void unsubscribeFromHubspot(Set<String> emails){
        
        String hapikey =Label.Hubspot_Api_Key;
        String endpoint = 'https://api.hubapi.com/email/public/v1/subscriptions/';
        String body = '{"unsubscribeFromAll": true}';
        
        for(String email : emails){
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint + email + '?hapikey=' + hapikey);
            req.setMethod('PUT');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(body);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('hubspot response '+res);
            System.debug('hubspot response '+res.getBody());
        }
        
    }
    
    public static void updateHubspotField(List<SObject> sobjectList){
        List<String> userList = Label.Hubspot_User_List.split(';'); 
        for(SObject sobjectInstance : sobjectList){
            if(userList.contains(UserInfo.getUserId())){
                sobjectInstance.put('Hubspot__c',true);
            }
        }
    }
}