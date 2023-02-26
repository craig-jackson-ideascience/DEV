/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 09-10-2019.
 * Description: EmailValidatorHttpMock
 ********************************************************/
@isTest
public class EmailValidatorHttpMock implements HttpCalloutMock {
    Boolean throwErrorBool;
    public EmailValidatorHttpMock(Boolean error){
        this.throwErrorBool = error;
    }

    public HttpResponse respond(HttpRequest request) {
        if(throwErrorBool){
            throw new CalloutException('Max Callout Reached');
        }
        PageReference pageReference = new PageReference(request.getEndpoint());
        Map<String, String> parameters = pageReference.getParameters();
        String email = parameters.get('email');

        HttpResponse response = new HttpResponse();
        response.setStatus('OK');
        response.setStatusCode(200);

        MailBoxWrapper wrap = new MailBoxWrapper();
        if ((new List<String>{
                'test0@test.com', 'test1@test.com', 'test2@test.com', 'test3@test.com', 'test50@test.com'
        }).contains(email)) {
            wrap.smtp_check = true;
        } else {
            wrap.smtp_check = false;
        }
        String json = JSON.serialize(wrap);
        response.setBody(json);
        return response;
    }
}