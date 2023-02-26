/********************************************************
* Created by: Martand Atrey @ CloudRoute Solutions
* Created Date: 12-11-2019.
* Description: CallOutToNetSuiteMockHttp
********************************************************/
@isTest
public class CallOutToNetSuiteMockHttp implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        System.debug('req.getEndpoint()'+req.getEndpoint());
        if(req.getEndpoint() == 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=11'){
            String json1 = '"12345"';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(json1);
            
        }
        else if(req.getEndpoint() == 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=90&deploy=4'){
            WrapperToGetSalesOrderData wrap = new WrapperToGetSalesOrderData();
            wrap.id = '1539958';
            wrap.custbody_fully_paid = false;
            wrap.tranid = 'SO8624';
            List<WrapperToGetSalesOrderData> jsonBody = new List<WrapperToGetSalesOrderData>();
            jsonBody.add(wrap);
            res.setBody(JSON.serialize(jsonBody));
            
        }
        else if(req.getEndpoint() == 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=70&deploy=2'){
            InvoiceWrapperNS wrap = new InvoiceWrapperNS();
            wrap.id = '153995845';
            wrap.recordtype = 'Test';
			InvoiceWrapperNS.Columns column = new InvoiceWrapperNS.Columns();
			column.custbody_cancelled = true;
			
			InvoiceWrapperNS.Priority priority= new InvoiceWrapperNS.Priority();
			priority.name = 'Category C';
			
			InvoiceWrapperNS.Createdfrom createdfrom =new InvoiceWrapperNS.Createdfrom();
			createdfrom.name = 'SO18298';
			createdfrom.internalid = '145670';
			column.createdfrom = createdfrom;
			column.custbody_priority = priority;
			wrap.columns = column;
            List<InvoiceWrapperNS> jsonBody = new List<InvoiceWrapperNS>();
            jsonBody.add(wrap);
            res.setBody(JSON.serialize(jsonBody));
            
        }
        else {
            WrapperToGetSalesOrderData wrap = new WrapperToGetSalesOrderData();
            wrap.id = '1539958';
            wrap.custbody_fully_paid = false;
            wrap.tranid = 'SO8624';
            String jsonBody = JSON.serialize(wrap);
            res.setBody(jsonBody);
            
        }
        
        res.setStatusCode(200);
        return res;
    }
}