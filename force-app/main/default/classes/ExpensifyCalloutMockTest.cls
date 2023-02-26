@isTest
global class ExpensifyCalloutMockTest implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        req.setEndpoint('https://integrations.expensify.com');
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String resString ='ReportID, accountEmail, PolicyId, TotalAmount, ReportStatus, ReportDate,';
        resString = resString + '53845065,';
        resString = resString + 'test@linuxfoundation.org,';
        resString = resString + '554237F4AB23B96D,';
        resString = resString + '1200,';
        resString = resString + 'Processing,';
        resString = resString + String.valueOf(System.Date.today().addDays(-2));
        
        res.setBody(resString);
        //res.setBody('status:success');
        res.setStatus('OK');
        res.setStatusCode(200);
        return res;
    } 
}