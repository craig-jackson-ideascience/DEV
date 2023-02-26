/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 09-10-2019.
 * Description: EmailValidator
 ********************************************************/
public class EmailValidator {

    public static MailBoxWrapper validate(String email) {
        system.debug('Email Validate');
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://apilayer.net/api/check?access_key=' + Label.MailBoxLayerAccessCode + '&email=' + email + '&smtp=1&format=1');
        request.setMethod('GET');
        request.setTimeout(120000);
        System.debug(request.getEndpoint() + '====> request.getEndpoint()');
        HttpResponse response;
        try{
            response = (new Http()).send(request);
        } catch(Exception e){
            System.debug('Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());
            MailBoxWrapper wrap = new MailBoxWrapper();
            wrap.success = false;
            wrap.Error = new MailBoxWrapper.Error();
            wrap.Error.info = 'Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString();
            return wrap;
        }
        System.debug(response + '====> response');
        if (response != null && response.getStatusCode() == 200 && response.getStatus() == 'OK') {
            MailBoxWrapper wrap = MailBoxWrapper.parse(response.getBody());
            return wrap;
        }
        return null;
    }

    @InvocableMethod(label='Run Email Validator Batch')
    public static void runValidatorBatch(List<Id> alternateEmailIds) {
        System.debug(alternateEmailIds + '====> alternateEmailIds');
        if(!(System.isBatch() || System.isFuture())){
            Database.executeBatch(new AlternateEmailValidatorBatch(alternateEmailIds), 100);
        }
        
    }

}