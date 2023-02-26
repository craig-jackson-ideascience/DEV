public class TravelFundExpensifyHandler implements Queueable,Database.AllowsCallouts {
    // to Get  Travel Fund from Trigger
    private list<Travel_Fund_Request__c> travelFundList;
    //Contructor to set Travel Fund Record from Salesforce
    public TravelFundExpensifyHandler(list<Travel_Fund_Request__c> trvlFundList) {
        this.travelFundList=trvlFundList;
    }
    //Execute Queueable method with Call Method
    public void execute(QueueableContext queCont) {
        TravelFundExpensifyHandler.notifyExpensifyRequestor(travelFundList);
    }
    //Creating a call to Creating a expensify Report to Requestor
    public static void CreateExpensifyReport(list<Travel_Fund_Request__c> travelFundList) {
        list<Travel_Fund_Request__c> trvlFunfList=new list<Travel_Fund_Request__c>();
        for(Travel_Fund_Request__c trvlFundObj:[select Id,Approved_Amount__c,ContactEmail__c,Name,FirstName__c,Status__c from Travel_Fund_Request__c where Id IN:travelFundList]) {
            if(trvlFundObj.Status__c.equals('Request Approved - Waiting For Expense Report')){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:Expensify_Details');
                request.setMethod('POST');
                request.setBody('requestJobDescription={ "type": "create","credentials": {"partnerUserID":"' + System.Label.expensify_partnerUserID + '" ,"partnerUserSecret": "' + System.Label.expensify_partnerUserSecret + '" },"inputSettings": {"type":"report","policyID": "554237F4AB23B96D","report": { "title": "'+trvlFundObj.FirstName__c+'", "fields":{ "reason_of_trip": "Business trip",  "employees": "3" } }, "employeeEmail": "' + trvlFundObj.ContactEmail__c + '","expenses": [{"date": "2019-11-07",  "currency": "USD","merchant": "'+trvlFundObj.Name+'", "amount": 1234 }] }}');
                HttpResponse response = http.send(request);
                System.debug(response.getBody());
                System.debug(response.getStatus());
                // Output in list Format            
                Object JsonParse = (object)Json.deserializeUntyped(response.getBody());            
                Map<String,Object> StrObjMap = (Map<string,Object>)JsonParse;
                system.debug('KKKKK'+StrObjMap.get('reportID'));
                trvlFundObj.Expensify_ID__c= string.valueOf(StrObjMap.get('reportID'));
                trvlFunfList.add(trvlFundObj);
            }
        }
        if(trvlFunfList.size()>0){
            update trvlFunfList;
        }
    }
    // Notification to Requestor to Create a Expesify Report once Request is Approved from Salesforce
    public static void notifyExpensifyRequestor(list<Travel_Fund_Request__c> travelFundList) {
        list<Travel_Fund_Request__c> trvlFundList=[select Id,Approved_Amount__c,ContactEmail__c,Event__r.Expensify_Policy_ID__c ,Name,Event__r.Name,FirstName__c,Expensify_ID__c,Status__c from Travel_Fund_Request__c where Id IN:travelFundList];
        try{
            for(Travel_Fund_Request__c trvlFundObj:trvlFundList) {
                if(trvlFundObj.Status__c.equals('Request Approved - Waiting For Expense Report')){
                    JSONGenerator gen=JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeStringField('type', 'update');
                    gen.writeFieldName('credentials');
                    gen.writeStartObject();
                    gen.writeStringField('partnerUserID', System.Label.expensify_partnerUserID);//Should be changed 
                    gen.writeStringField('partnerUserSecret', System.Label.expensify_partnerUserSecret);//Should be changed
                    gen.writeEndObject();
                    gen.writeFieldName('inputSettings');
                    gen.writeStartObject();
                    gen.writeStringField('type', 'employees');        
                    //the policyID corresponding to the policy which the employees will be added to;
                    gen.writeStringField('policyID', trvlFundObj.Event__r.Expensify_Policy_ID__c);       
                    gen.writeStringField('fileType', 'csv');
                    gen.writeEndObject();
                    gen.writeEndObject();
                    String requestJobDescription=gen.getAsString();        
                    String boundary = '-----------------------------BoundaryjQjTqoyRD07HQCVD';
                    String header2 = '--'+boundary+'\n'+ 'Content-Disposition: form-data; name="data"; filename="1.csv"'+'\r\nContent-Type: application/octet-stream\r\n\r\n';
                    String header1 = '--'+boundary+'\n Content-Disposition: form-data;  name="requestJobDescription" \r\n\r\n'+requestJobDescription+'\r\n';
                    string CSVString = 'EmployeeEmail,ManagerEmail,Admin\n'+trvlFundObj.ContactEmail__c+','+System.Label.expensify_Adm_Email+',false';
                    String footer = '--'+boundary+'--';             
                    String body=header1+header2+CSVString+'\r\n'+footer;//the CSVString is like 'EmployeeEmail,ManagerEmail,Admin\n'+'asidoj@qwe.com,qwdmka@ee.com,FALSE'
                    HttpRequest req = new HttpRequest();
                    req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
                    req.setMethod('POST');
                    req.setEndpoint('callout:Expensify_Details');
                    req.setBody(body);
                    req.setTimeout(120000);        
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    system.debug('Response Expensify ::'+res.getBody());
                    system.debug('Response Expensify Code ::'+res.getStatusCode());
                }
            }
        }catch(exception ex){
            system.debug(logginglevel.ERROR,ex.getLineNumber()+'ERROR in notifyExpensifyRequestor::'+ex);
        }
    }
    public static void updateStatusFromApprovedToReimbursed(string travelFundId) {
        system.debug('travelFundId New debug:::   =>  ' + travelFundId);
        list<Expensify_Attachment__c> expenAttach = [SELECT Id, Report_Id__c, URL__c FROM Expensify_Attachment__c WHERE Travel_Fund_Request__c =: travelFundId];
        list<String> reportIdList = new list<String>();        
        for(Expensify_Attachment__c expAttObj: expenAttach) {
            reportIdList.add(expAttObj.Report_Id__c);
        }
        system.debug('reportIdList:: ' + reportIdList);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Expensify_Details');
        request.setMethod('POST');
        string strBody='requestJobDescription={"type":"update", "credentials":{"partnerUserID":"' + System.Label.expensify_partnerUserID + '", "partnerUserSecret":"' + System.Label.expensify_partnerUserSecret + '"}, "inputSettings":{"type":"reportStatus", "status" : "Reimbursed", "filters":{"reportIDList":"'+ expenAttach[0].Report_Id__c+'"} } }';//requestJobDescription={"type":"download","credentials":{"partnerUserID":"aa_sunil_chaudhary_webuters_com","partnerUserSecret":"4662ade007bf5c335228b5fe8f780810ea1b4bf4"},"fileName":"'+respData.strDesc+'","fileSystem":"integrationServer"}';
        request.setBody(strBody);
        HttpResponse response = http.send(request);
        System.debug('response.getBody:::: ' + response.getBody());
        System.debug('response.getStatus:::: ' + response.getStatus());
        System.debug('response.getStatusCode:::: ' + response.getStatusCode());
    }
}