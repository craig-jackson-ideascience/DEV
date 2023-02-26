@isTest
public class DocusignAPIMockHttp implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        //('https://demo.docusign.net/restapi/v2.1/accounts/34b9d81f-63d3-48cb-968d-72fc1a9df29f/envelopes');
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"envelopeId":"test"}');
        res.setStatus('OK');
        System.debug('req.getEndpoint()'+req.getEndpoint());
        if(req.getEndpoint().contains('/envelopes/test')){
            res.setStatusCode(200);
        } 
        else{
            res.setStatusCode(201);
        }
        return res;
    }
}