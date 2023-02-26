/********************************************************
 * Created by: CloudRoute @ CloudRoute Solutions
 * Created Date: 23/07/21.
 * Description: SyncHubspotContactsMockTest
 ********************************************************/

@IsTest
global class SyncHubspotContactsMockTest implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "contacts": [ { "identity-profiles": [ { "identities": [ { "type": "EMAIL", "value": "test@lflead.com" } ] } ] }, { "identity-profiles": [ { "identities": [ { "type": "EMAIL", "value": "test@lfcontact.com" } ] } ] } ], "has-more": true, "vid-offset": 5158651 }');
        res.setStatusCode(200);
        return res;
    }
}