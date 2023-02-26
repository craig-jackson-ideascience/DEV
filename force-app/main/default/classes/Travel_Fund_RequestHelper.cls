public class Travel_Fund_RequestHelper {

    // the label of the Continuation
    public String requestLabel;

    public Boolean CongaComposerInvocation(Travel_Fund_Request__c request, String templateId) {
        System.debug('Travel_Fund_RequestHelper::CongaComposerInvocation invoked');
        System.debug('using Travel_Fund_Request__c record with an Id of ' + request.Id);
        System.debug('using templateId value of ' + templateId);

        // build the URL string using the same params that we built up in the Conga Composer Solution wizard
        String url = 'https://composer.congamerge.com/composer8/index.html';
        url += '?APIMode=12';
        url += '&serverUrl={!API.Partner_Server_URL_370}';
        url += '&Id=' + request.Id;
        url += '&DS7=2';
        url += '&EmailToId=' + request.Contact__c;
        url += '&EmailRelatedToId=' + request.Id;
        url += '&CongaEmailTemplateId=' + templateId;
        url += '&EmailFromId=0D241000000TWqc'; // @todo handle hard-coded value, should be dynamic too
        url += '&ContactId=' + request.Contact__c;

        // build the HTTP call to Conga Composer
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setTimeout(60000);

        Continuation con = new Continuation(60);
        con.continuationMethod='CongaComposerContinuationHandler';
        con.state = request.Id;
        this.requestLabel = con.addHttpRequest(req);
        System.debug('Travel_Fund_RequestHelper::CongaComposerInvocation set the Continuation to send the email, using requestLabel ' + this.requestLabel);

        return TRUE;
    }

    public void CongaComposerContinuationHandler() {
        System.debug('Travel_Fund_RequestHelper::CongaComposerContinuationHandler invoked');
        HttpResponse response = Continuation.getResponse(this.requestLabel);
    }

}