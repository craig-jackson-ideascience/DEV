@isTest
global class sendNotificationRequestCallOut implements HttpCalloutMock {
    String entity; 
    global sendNotificationRequestCallOut(String entity){
        this.entity = entity;
    }
    
    global sendNotificationRequestCallOut(){}
	global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        if(entity == 'Error'){
            res.setStatus('Error');
        	res.setStatusCode(404);
        	res.setBody('{"Code":404,"Message":"Your request has been queued. Reference id : d6a7f380-1305-593e-b6e4-a534e361bfca"}');
        	return res;
        }
        else{
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('{"Code":200,"Message":"Your request has been queued. Reference id : d6a7f380-1305-593e-b6e4-a534e361bfca"}');
        return res;
        }
    }
}