@isTest
global class NetSuiteToSalesforce_Mock implements HttpCalloutMock {
   
    global HttpResponse respond(HttpRequest req){
         HttpResponse resp = new HttpResponse();
        if(req.getEndpoint() == 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=41&deploy=1'){
           resp.setBody('[{"id":"21170","recordtype":"salesorder","columns":{"mainline":"*","type":{"name":"Sales Order","internalid":"SalesOrd"},"entity":{"name":"Eldarion, Inc. - LF","internalid":"7825"},"account":{"name":"Sales Orders","internalid":"123"},"amount":5000,"custbody_fully_paid":true,"department":{"name":"Sales","internalid":"10"},"datecreated":"5/19/2016 10:25 am","custbody_primary_email":"billing@eldarion.com"}},{"id":"21170","recordtype":"salesorder","columns":{"mainline":"&nbsp;","type":{"name":"Sales Order","internalid":"SalesOrd"},"entity":{"name":"Eldarion, Inc. - LF","internalid":"7825"},"account":{"name":"4115 Membership Dues : Silver Membership","internalid":"292"},"memo":"2015 Linux Foundation Silver Membership (total employee size 0-99) - Linux Foundation Silver Membership Annual Dues","amount":5000,"custbody_fully_paid":true,"department":{"name":"Sales","internalid":"10"},"datecreated":"5/19/2016 10:25 am","item":{"name":"Membership : 2015 LF Silver Membership (total emp size 0-99)","internalid":"87"},"custbody_primary_email":"billing@eldarion.com"}}]');       
        }
        else if(req.getEndpoint() == 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=40&deploy=1'){
           WrapperToGetSalesOrderData wrap = new WrapperToGetSalesOrderData();
            wrap.id = '1539958';
            wrap.custbody_fully_paid = false;
            wrap.tranid = 'SO8624';
            String jsonBody = JSON.serialize(wrap);
            resp.setBody(jsonBody); 
        }
        else if(req.getEndpoint() == 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=39&deploy=1'){
            SalesOrderDataWrapper wrap = new SalesOrderDataWrapper();
            wrap.id = '1539958';
            SalesOrderDataWrapper.columns col = new  SalesOrderDataWrapper.columns();
            wrap.columns = col;
            col.custbody_fully_paid = True;
            wrap.recordtype = '';
            List<SalesOrderDataWrapper> jsonBody = new List<SalesOrderDataWrapper>();
            jsonBody.add(wrap);
            resp.setBody(JSON.serialize(jsonBody));
        }
        else{
            WrapperToGetSalesOrderDataForExisting wrap = new WrapperToGetSalesOrderDataForExisting();
            wrap.id = '1539958';
            wrap.custbody_fully_paid = false;
            wrap.tranid = 'SO8624';
            wrap.recordtype= 'salesorder';
           	resp.setBody(JSON.serialize(wrap)); 
        }
        
        resp.setStatus('Ok');
         resp.setHeader('Content-type','application/json');
         resp.setStatusCode(200);
         return resp;
    }

}