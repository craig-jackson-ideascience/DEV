@isTest
global class CallOutToNetSuiteTrigger_Test_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        String json=        '[{'+
        '   "custbody_tlf_needs_upload_to_portal": false,'+
        '   "orderstatus": {'+
        '       "internalid": "A",'+
        '       "name": "Pending Approval"'+
        '   },'+
        '   "shipzip": "123456",'+
        '   "trandate": "1/11/2018",'+
        '   "tobeprinted": false,'+
        '   "billcountry": {'+
        '       "internalid": "BR",'+
        '       "name": "Brazil"'+
        '   },'+
        '   "shipcity": "Test City",'+
        '   "ccapproved": false,'+
        '   "custbody_processed_by_sugar": false,'+
        '   "terms": {'+
        '       "internalid": "2",'+
        '       "name": "Net 30"'+
        '   },'+
        '   "billingaddress_text": "BAC_NameChange\nStreet add change\nSt. Petersburg null Z54394\nRussian Federation",'+
        '   "shipstate": "Test State",'+
        '   "id": "1099065",'+
        '   "custbody_fully_paid": false,'+
        '   "tobeemailed": false,'+
        '   "item": [{'+
        '       "amount": 34,'+
        '       "deferrevrec": false,'+
        '       "department": {'+
        '           "internalid": "10",'+
        '           "name": "Sales"'+
        '       },'+
        '       "description": "undefined",'+
        '       "fromjob": false,'+
        '       "isclosed": false,'+
        '       "isestimate": false,'+
        '       "item": {'+
        '           "internalid": "191200",'+
        '           "name": "Academic Membership, test1 project 10 jan"'+
        '       },'+
        '       "quantity": 1,'+
        '       "revrecenddate": "12/31/2018",'+
        '       "revrecschedule": {'+
        '           "internalid": "29",'+
        '           "name": "Directed Fund"'+
        '       },'+
        '       "revrecstartdate": "1/1/2018"'+
        '   }],'+
        '   "custbody_tlf_transaction_uploaded": false,'+
        '   "billaddress": "BAC_NameChange\nStreet add change\nSt. Petersburg null Z54394\nRussian Federation",'+
        '   "subsidiary": {'+
        '       "internalid": "8",'+
        '       "name": "R Consortium"'+
        '   },'+
        '   "isrecurringpayment": false,'+
        '   "subtotal": 34,'+
        '   "billaddr1": "Test Street",'+
        '   "createddate": "1/11/2018 2:26 am",'+
        '   "revenuestatus": "A",'+
        '   "deferredrevenue": 0,'+
        '   "billzip": "123456",'+
        '   "shipaddressee": "test 11 jan",'+
        '   "billingaddress": {'+
        '       "zip": "123456",'+
        '       "country": {'+
        '           "internalid": "BR",'+
        '           "name": "Brazil"'+
        '       },'+
        '       "addressee": "test 11 jan",'+
        '       "city": "Test City",'+
        '       "addr1": "Test Street",'+
        '       "state": "Test State",'+
        '       "override": true,'+
        '       "addrtext": "BAC_NameChange\nStreet add change\nSt. Petersburg null Z54394\nRussian Federation"'+
        '   },'+
        '   "tobefaxed": false,'+
        '   "total": 34,'+
        '   "recognizedrevenue": 0,'+
        '   "recordtype": "salesorder",'+
        '   "ccprocessaspurchasecard": false,'+
        '   "department": {'+
        '       "internalid": "10",'+
        '       "name": "Sales"'+
        '   },'+
        '   "shippingaddress": {'+
        '       "zip": "123456",'+
        '       "country": {'+
        '           "internalid": "BR",'+
        '           "name": "Brazil"'+
        '       },'+
        '       "addressee": "test 11 jan",'+
        '       "city": "Test City",'+
        '       "addr1": "Test Street",'+
        '       "state": "Test State",'+
        '       "override": false,'+
        '       "addrtext": "test 11 jan\nTest Street\nTest City Test State 123456\nBrazil"'+
        '   },'+
        '   "shippingaddress_text": "test 11 jan\nTest Street\nTest City Test State 123456\nBrazil",'+
        '   "tranid": "SO5800",'+
        '   "shipcountry": {'+
        '       "internalid": "BR",'+
        '       "name": "Brazil"'+
        '   },'+
        '   "lastmodifieddate": "1/11/2018 2:26 am",'+
        '   "billingschedule": [{'+
        '       "billamount": 34,'+
        '       "billdate": "1/11/2018"'+
        '   }],'+
        '   "billstate": "Test State",'+
        '   "shipaddr1": "Test Street",'+
        '   "billaddressee": "test 11 jan",'+
        '   "saleseffectivedate": "1/11/2018",'+
        '   "custbody_sugar_reference": "https://cs77.salesforce.com/0060t000005Wmgk",'+
        '   "customform": {'+
        '       "internalid": "108",'+
        '       "name": "Linux Sales Order"'+
        '   },'+
        '   "getauth": false,'+
        '   "entity": {'+
        '       "internalid": "164963",'+
        '       "name": "test 11 jan - LF"'+
        '   },'+
        '   "billcity": "Test City"'+
        '}]';
        
        
        String json1 = '[{\"custbody_tlf_needs_upload_to_portal\":false,\"orderstatus\":{\"internalid\":\"A\",\"name\":\"Pending Approval\"},\"shipzip\":\"123456\",\"trandate\":\"1/11/2018\",\"tobeprinted\":false,\"billcountry\":{\"internalid\":\"BR\",\"name\":\"Brazil\"},\"shipcity\":\"Test City\",\"ccapproved\":false,\"custbody_processed_by_sugar\":false,\"terms\":{\"internalid\":\"2\",\"name\":\"Net 30\"},\"billingaddress_text\":\"BAC_NameChange\\nStreet add change\\nSt. Petersburg null Z54394\\nRussian Federation\",\"shipstate\":\"Test State\",\"id\":\"1099065\",\"custbody_fully_paid\":false,\"tobeemailed\":false,\"item\":[{\"amount\":34,\"deferrevrec\":false,\"department\":{\"internalid\":\"10\",\"name\":\"Sales\"},\"description\":\"undefined\",\"fromjob\":false,\"isclosed\":false,\"isestimate\":false,\"item\":{\"internalid\":\"191200\",\"name\":\"Academic Membership, test1 project 10 jan\"},\"quantity\":1,\"revrecenddate\":\"12/31/2018\",\"revrecschedule\":{\"internalid\":\"29\",\"name\":\"Directed Fund\"},\"revrecstartdate\":\"1/1/2018\"}],\"custbody_tlf_transaction_uploaded\":false,\"billaddress\":\"BAC_NameChange\\nStreet add change\\nSt. Petersburg null Z54394\\nRussian Federation\",\"subsidiary\":{\"internalid\":\"8\",\"name\":\"R Consortium\"},\"isrecurringpayment\":false,\"subtotal\":34,\"billaddr1\":\"Test Street\",\"createddate\":\"1/11/2018 2:26 am\",\"revenuestatus\":\"A\",\"deferredrevenue\":0,\"billzip\":\"123456\",\"shipaddressee\":\"test 11 jan\",\"billingaddress\":{\"zip\":\"123456\",\"country\":{\"internalid\":\"BR\",\"name\":\"Brazil\"},\"addressee\":\"test 11 jan\",\"city\":\"Test City\",\"addr1\":\"Test Street\",\"state\":\"Test State\",\"override\":true,\"addrtext\":\"BAC_NameChange\\nStreet add change\\nSt. Petersburg null Z54394\\nRussian Federation\"},\"tobefaxed\":false,\"total\":34,\"recognizedrevenue\":0,\"recordtype\":\"salesorder\",\"ccprocessaspurchasecard\":false,\"department\":{\"internalid\":\"10\",\"name\":\"Sales\"},\"shippingaddress\":{\"zip\":\"123456\",\"country\":{\"internalid\":\"BR\",\"name\":\"Brazil\"},\"addressee\":\"test 11 jan\",\"city\":\"Test City\",\"addr1\":\"Test Street\",\"state\":\"Test State\",\"override\":false,\"addrtext\":\"test 11 jan\\nTest Street\\nTest City Test State 123456\\nBrazil\"},\"shippingaddress_text\":\"test 11 jan\\nTest Street\\nTest City Test State 123456\\nBrazil\",\"tranid\":\"SO5800\",\"shipcountry\":{\"internalid\":\"BR\",\"name\":\"Brazil\"},\"lastmodifieddate\":\"1/11/2018 2:26 am\",\"billingschedule\":[{\"billamount\":34,\"billdate\":\"1/11/2018\"}],\"billstate\":\"Test State\",\"shipaddr1\":\"Test Street\",\"billaddressee\":\"test 11 jan\",\"saleseffectivedate\":\"1/11/2018\",\"custbody_sugar_reference\":\"https://cs77.salesforce.com/0060t000005Wmgk\",\"customform\":{\"internalid\":\"108\",\"name\":\"Linux Sales Order\"},\"getauth\":false,\"entity\":{\"internalid\":\"164963\",\"name\":\"test 11 jan - LF\"},\"billcity\":\"Test City\"}]';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');     
        res.setBody(json1);
        res.setStatusCode(200);               
        return res;
    }
}