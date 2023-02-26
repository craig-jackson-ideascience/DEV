@isTest
public class HubspotHttpMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
         HttpResponse res = new HttpResponse();
         System.debug('req.getEndpoint()'+req.getEndpoint());
        if(req.getEndpoint() == 'https://api.hubapi.com/email/public/v1/subscriptions/'){
            String json1 = '{\"success\":true}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(json1);
        }
        return res;
    }

}