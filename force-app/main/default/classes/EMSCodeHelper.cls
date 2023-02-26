public class EMSCodeHelper implements Queueable, Database.AllowsCallouts {
    public String recordId;
    public EMS__c emsRecord;
    
    public static Endpoints__c settings{
        get{
            if(settings == null){
                List<Endpoints__c> endPointObj = new List<Endpoints__c>([SELECT Name, Endpoint__c, Password__c, User_Id__c,
                 Nlauth_Account__c, Access_Token__c, Consumer_Key__c, Consumer_Secret__c, Realm__c, Token_Secret__c, Script_Id__c
                 FROM Endpoints__c WHERE name = 'For EMS Code To NS']);         
                if (endPointObj.size() > 0) {
                    settings = endPointObj[0];
                }
            }
            return settings;
        }
        set;
    }

    public EMSCodeHelper(String id){
        recordId = id;
        List<EMS__c> emsList = [SELECT Id, EMS_Number__c, Netsuite_Job_Code_Id__c, SubsidiaryID__c, NS_Class__c, Netsuite_Job_Code_Error__c, Event__c,
         Event__r.BillFromProject__r.Subsidiary_ID__c, Event__r.BillFromProject__r.NetSuite_Class__c
         FROM EMS__c WHERE Id =: recordId];
        if (emsList.size() > 0) {
            emsRecord = emsList[0];
        }
    }

    public void execute(QueueableContext context) {
        if (emsRecord != null) {
            try{
                if (settings != null) {
                String body = createRequestJSON(); // create json body
                
                HttpRequest httpRequestObject = new HttpRequest();
                httpRequestObject.setMethod('POST');

                if(String.isNotBlank(body)){
                    httpRequestObject.setBody(body);
                }
                httpRequestObject.setHeader('Content-Type', 'application/json');

                Map<String, String> urlParams = new Map<String, String>();
                urlParams.put('script', settings.Script_Id__c);

                httpRequestObject = NetSuiteIntegrationHelper.addEndpointAndAuthHeader(httpRequestObject, settings, urlParams);

                Http http = new Http();
                HttpResponse response = http.send(httpRequestObject);

                System.debug('Response ==>' + response.getBody());
                emsRecord.NetSuite_Job_Code_Error__c = null;
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                    ResponseWrapper successWrapper = (ResponseWrapper)JSON.deserialize(response.getBody() , ResponseWrapper.class);
                    System.debug(successWrapper);
                    if (successWrapper.success == true && successWrapper.id != null) {
                        emsRecord.NetSuite_Job_Code_Id__c = successWrapper.id;
                        if (emsRecord.Event__c != null) {
                            Event__c emsEvent = [SELECT Id, Job_Code__c, NS_Department__c, NS_Deferred_Revenue_Account__c, NS_Revenue_Schedule__c   FROM Event__c WHERE Id =: emsRecord.Event__c];
                            emsEvent.Job_Code__c = successWrapper.id;
                            emsEvent.EMS_Number__c = emsRecord.EMS_Number__c;
                            emsEvent.NS_Department__c = '2'; //NS Department = Events
                            emsEvent.NS_Deferred_Revenue_Account__c = '284'; //NS Deferred Revenue Account = Deferred Revenue : Deferred Revenue - Other
                            emsEvent.NS_Revenue_Schedule__c = '6'; //NS Revenue Schedule = Straight Line
                            update emsEvent;
                        }
                    }
                    else {
                        emsRecord.NetSuite_Job_Code_Error__c ='NetSuite Job Code Sync Failed: ' + response.getBody();
                    }
                }else{
                    ResponseErrorWrapper errorWrapper = (ResponseErrorWrapper)JSON.deserialize(response.getBody() , ResponseErrorWrapper.class);
                    System.debug(errorWrapper);
                    emsRecord.NetSuite_Job_Code_Error__c ='NetSuite Job Code Sync Failed: ' + errorWrapper.error.message;
                }
                update emsRecord;

                }
            }
            catch (Exception ex) {
                emsRecord.NetSuite_Job_Code_Error__c = 'Exception Caught: ' + ex.getMessage();
                update emsRecord;
            }
        }
    }
    
    public String createRequestJSON() {
        Map<String, Object> jsonMappingObject = new Map<String, Object>();

        jsonMappingObject.put('name', emsRecord.EMS_Number__c);
        jsonMappingObject.put('subsidiary', emsRecord.Event__r.BillFromProject__r.Subsidiary_ID__c);
        jsonMappingObject.put('class', emsRecord.Event__r.BillFromProject__r.NetSuite_Class__c);
        jsonMappingObject.put('jobType', 7); //'Project Event'); 

        String jsonString = JSON.serialize(jsonMappingObject);       
        return jsonString;
    }


    public class ResponseWrapper {
        public String id {get; set;}
        public Boolean success {get; set;}
        public String error {get; set;}
    }

    public class ResponseErrorWrapper {
        public ResponseError error {get; set;}
    }

    public class ResponseError {
        public String code {get; set;}
        public String message {get; set;}
    }
}