@isTest
global class getAccessTokenCalloutMock implements HttpCalloutMock {
	global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('{"access_token":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlJFWTNSVGcyTTBVMk5URTRSamcwTUVRNU9VSkZRMFpGTVVGRVJUaEVRVVF5TTBZeVF6QXhOQSJ9.eyJpc3MiOiJodHRwczovL2xpbnV4Zm91bmRhdGlvbi1kZXYuYXV0aDAuY29tLyIsInN1YiI6IjdvUzV6V1dPVmR0WFozbUlnSFEwMHZ3bkJjV253RElMQGNsaWVudHMiLCJhdWQiOiJodHRwczovL2FwaS1ndy5kZXYucGxhdGZvcm0ubGludXhmb3VuZGF0aW9uLm9yZy8iLCJpYXQiOjE1ODA5MjAzNTYsImV4cCI6MTU4MDkzMTE1NiwiYXpwIjoiN29TNXpXV09WZHRYWjNtSWdIUTAwdnduQmNXbndESUwiLCJzY29wZSI6ImFjY2Vzczp"}');
        return res;
    }
}