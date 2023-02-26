public class ExpensifyReceiptRequest_Controller {

    @AuraEnabled
    public static Boolean fileName(string travelFundId, Boolean result) {
        Travel_Fund_Request__c tfrObj = [select Id,Approved_Amount__c,ContactEmail__c,Event__r.Expensify_Policy_ID__c,Name,FirstName__c,Expensify_ID__c,Status__c, TFREmail__c from Travel_Fund_Request__c where Id = :travelFundId AND Event__r.Expensify_Policy_ID__c != null AND Event__r.Accept_Travel_Fund__c = 'Yes'];

        ResponseWrapper responseData = new ResponseWrapper();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //callout:My_Named_Credential
        request.setEndpoint('callout:Expensify_Details');
        request.setMethod('POST');
        request.setHeader('content-Type', 'application/x-www-form-urlencoded');
            string templateBody = '<#if addHeader == true> ReportID,accountEmail,PolicyId,TotalAmount,ReportStatus,CreatedDate,<#lt> </#if><#assign reportNumber = 1> <#assign expenseNumber = 1> <#list reports as report> <#list report.transactionList as expense> <#-- note: expense.amount prints the original amount only --> ${report.reportID},<#t>${report.accountEmail},<#t> ${report.policyID},<#t>${report.total},<#t>${report.status},<#t>${report.created},<#t> <#assign expenseNumber = expenseNumber + 1></#list> <#assign reportNumber = reportNumber + 1> </#list>';
        string strBody = 'requestJobDescription={ "type":"file", "credentials":{ "partnerUserID":"' + System.Label.expensify_partnerUserID + '", "partnerUserSecret":"' + System.Label.expensify_partnerUserSecret + '" }, "onReceive":{ "immediateResponse":["returnRandomFileName"] }, "inputSettings":{ "type":"combinedReportData", "reportState":"SUBMITTED,APPROVED,REIMBURSED,ARCHIVED", "filters":{ "policyIDList":' + tfrObj.Event__r.Expensify_Policy_ID__c + ', "startDate":"2019-01-01", "endDate":"2050-12-30", "markedAsExported":"Expensify Export" } }, "outputSettings":{ "fileExtension":"csv" } }';

        System.debug('strBody: ' + strBody);

        strBody = strBody + '&template=' + EncodingUtil.urlEncode(templateBody, 'UTF-8');
        request.setBody(strBody);
        request.setTimeout(120000);
        HttpResponse response = http.send(request);
        system.debug('response::;' + response);
        System.debug('response.getBody:::: ' + response.getBody());
        System.debug('response.getStatus:::: ' + response.getStatus());
        System.debug('response.getStatusCode:::: ' + response.getStatusCode());
        responseData.strCode = string.valueof(response.getStatusCode());
        responseData.strDesc = response.getBody();
        System.debug('response.getBody() :1: ' + response.getBody());
        Boolean returnResult = receiptFetching(response.getBody(), tfrObj, result);
        if (returnResult == true) {
            return returnResult;
        }
        return null;
    }

    @AuraEnabled
    public static Boolean receiptFetching(String ReportID, Travel_Fund_Request__c tfrObj, Boolean result) {
        system.debug('ReportID ::: ' + ReportID);

        ResponseWrapper responseData = new ResponseWrapper();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Expensify_Details');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        string strBody = 'requestJobDescription={"type":"download","credentials":{ "partnerUserID":"' + System.Label.expensify_partnerUserID + '", "partnerUserSecret":"' + System.Label.expensify_partnerUserSecret + '" },"fileName":"' + ReportID + '","fileSystem":"integrationServer"}';
        request.setBody(strBody);
        request.setTimeout(120000);
        HttpResponse response = http.send(request);
        System.debug('response.getBody::2:: ' + response.getBody());
        System.debug('response.getStatus:::: ' + response.getStatus());
        System.debug('response.getStatusCode:::: ' + response.getStatusCode());
        responseData.strCode = string.valueof(response.getStatusCode());
        responseData.strDesc = response.getBody();

        Travel_Fund_Request__c travelFund = new Travel_Fund_Request__c();

        travelFund = tfrObj;

        String[] receipts = response.getBody().split(',');
        System.debug('receipts ::: ' + receipts);
        System.debug('receipts.size() ::: ' + receipts.size());

        for (string s : receipts) {
            System.debug('s: ' + s);
        }

        System.debug('##tfrObj ::: ' + tfrObj);
        List<ExpenseReceipt> ExpenseReceipts = new List<ExpenseReceipt>();
        //Integer count=0;
        if (receipts.size() > 6) {
            for (Integer i = 6; i < receipts.size() - 1; i = i + 6) {
                System.debug('tfrObj.TFREmail__c: ' + tfrObj.TFREmail__c);
                ExpenseReceipt receipt = new ExpenseReceipt();
                System.debug('receipts[i] ::: ' + receipts[i]);
                System.debug('receipts[i+1] ::: ' + receipts[i + 1]);
                System.debug('receipts[i+2] ::: ' + receipts[i + 2]);
                System.debug('receipts[i+3] ::: ' + receipts[i + 3]);
                System.debug('receipts[i+4] ::: ' + receipts[i + 4]);
                System.debug('receipts[i+5] ::: ' + receipts[i + 5]);
                if (tfrObj.TFREmail__c == receipts[i + 1]) {
                    receipt.ReportID = receipts[i];
                    receipt.accountEmail = receipts[i + 1];
                    receipt.PolicyId = receipts[i + 2];
                    receipt.TotalAmount = receipts[i + 3];
                    receipt.ReportStatus = receipts[i + 4];
                    receipt.ReportDate = Date.valueOf(receipts[i + 5]);
                    system.debug('receipt :: ' + receipt);
                    ExpenseReceipts.add(receipt);
                }
            }
        }
        system.debug('ExpenseReceipts :: ' + ExpenseReceipts);

        list<Expensify_Attachment__c> expenAttachList = new list<Expensify_Attachment__c>();

        Date expenseDate;
        ExpenseReceipt latestExpenseReceipt;
        for (ExpenseReceipt exRec : ExpenseReceipts) {
            if (expenseDate == null || expenseDate < exRec.ReportDate) {
                expenseDate = exRec.ReportDate;
                latestExpenseReceipt = exRec;
            }
        }

        System.debug('latestExpenseReceipt: ' + latestExpenseReceipt);

        if (latestExpenseReceipt != null) {
            if (latestExpenseReceipt.ReportID != null && latestExpenseReceipt.ReportID != '') {

                if ((latestExpenseReceipt.ReportStatus == 'Submitted' || latestExpenseReceipt.ReportStatus == 'Processing') && travelFund.Status__c != 'Expense Report Received - Waiting for Final Approval') {
                    travelFund.Expensify_ID__c = latestExpenseReceipt.ReportID;
                    travelFund.Expensify_Report_Name__c = latestExpenseReceipt.ReportID;
                    travelFund.Expensify_Submitted_amount__c = Decimal.valueOf(latestExpenseReceipt.TotalAmount) / 100;
                    travelFund.Status__c = 'Expense Report Received - Waiting Final Approval';
                    System.debug('travelFund.Expensify_Submitted_amount__c :::: ' + travelFund.Expensify_Submitted_amount__c);

                } else if (latestExpenseReceipt.ReportStatus == 'Approved' && travelFund.Status__c != 'Expense Report Approved') {
                    travelFund.Expensify_Approved_Amount__c = Decimal.valueOf(latestExpenseReceipt.TotalAmount) / 100;
                    travelFund.Expensify_Submitted_amount__c = Decimal.valueOf(latestExpenseReceipt.TotalAmount) / 100;
                    travelFund.Status__c = 'Expense Report Approved';

                } else if (latestExpenseReceipt.ReportStatus == 'Reimbursed' && travelFund.Status__c != 'Paid') {
                    travelFund.Expensify_Approved_Amount__c = Decimal.valueOf(latestExpenseReceipt.TotalAmount) / 100;
                    travelFund.Expensify_Submitted_amount__c = Decimal.valueOf(latestExpenseReceipt.TotalAmount) / 100;
                    travelFund.Expensify_Paid_Amount__c = Decimal.valueOf(latestExpenseReceipt.TotalAmount) / 100;
                    travelFund.Status__c = 'Paid';
                }

                upsert travelFund;
                result = true;
                return result;
            }
        }


        return null;
    }

    /*public static void requestorNotification(string travelFundId) { //Todo - did not find any usage of this method anywhere
        Travel_Fund_Request__c tfrObj = [select Id,Approved_Amount__c,ContactEmail__c,Event__r.Expensify_Policy_ID__c,Name,Event__r.Name,FirstName__c,Expensify_ID__c,Status__c from Travel_Fund_Request__c where Id = :travelFundId];
        ResponseWrapper responseData = new ResponseWrapper();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Expensify_Details');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        string strBody = '{ "type": "update", "credentials": { "partnerUserID": "' + System.Label.expensify_partnerUserID + '", "partnerUserSecret": "' + System.Label.expensify_partnerUserSecret + '" }, "inputSettings": { "type": "employees", "policyID":"6E4C9B0295966B86", "fileType": "csv" } }';//requestJobDescription={"type":"download","credentials":{"partnerUserID":"aa_sunil_chaudhary_webuters_com","partnerUserSecret":"4662ade007bf5c335228b5fe8f780810ea1b4bf4"},"fileName":"'+respData.strDesc+'","fileSystem":"integrationServer"}';
        strBody = '&data=';
        request.setBody(strBody);
        HttpResponse response = http.send(request);
        System.debug('response.getBody:::: ' + response.getBody());
        System.debug('response.getStatus:::: ' + response.getStatus());
        System.debug('response.getStatusCode:::: ' + response.getStatusCode());
        responseData.strCode = string.valueof(response.getStatusCode());
        responseData.strDesc = response.getBody();
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.Title = 'My Data';
        Blob blobValue = response.getBodyAsBlob();
        conVer.PathOnClient = 'My path on client';
        conVer.VersionData = blobValue; // converting your binary string to Blog
        insert conVer;
        system.debug('conVer::: ' + conVer);
        // First get the content document Id from ContentVersion
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;
        system.debug('conDoc::: ' + conDoc);
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = tfrObj.Id; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        /// /cDe.Visibility = 'InternalUsers';
        insert cDe;
    }*/

    @AuraEnabled
    public static void notifyExpensifyRequestor_Apex(string travelFundId) {
        Travel_Fund_Request__c tfrObj = [select Id,Approved_Amount__c,ContactEmail__c,Event__r.Expensify_Policy_ID__c,Name,Event__r.Name,FirstName__c,Expensify_ID__c,Status__c from Travel_Fund_Request__c where Id = :travelFundId];

        JSONGenerator gen = JSON.createGenerator(true);
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
        gen.writeStringField('policyID', tfrObj.Event__r.Expensify_Policy_ID__c);//the policyID corresponding to the policy which the employees will be added to;
        gen.writeStringField('fileType', 'csv');
        gen.writeEndObject();
        gen.writeEndObject();
        String requestJobDescription = gen.getAsString();

        String boundary = '-----------------------------BoundaryjQjTqoyRD07HQCVD';
        String header2 = '--' + boundary + '\n' + 'Content-Disposition: form-data; name="data"; filename="1.csv"' + '\r\nContent-Type: application/octet-stream\r\n\r\n';
        String header1 = '--' + boundary + '\n Content-Disposition: form-data;  name="requestJobDescription" \r\n\r\n' + requestJobDescription + '\r\n';
        string CSVString = 'EmployeeEmail,ManagerEmail,Admin\n' + tfrObj.ContactEmail__c + ',sunil.chaudhary@webuters.com,false';
        String footer = '--' + boundary + '--';
        String body = header1 + header2 + CSVString + '\r\n' + footer;//the CSVString is like 'EmployeeEmail,ManagerEmail,Admin\n'+'asidoj@qwe.com,qwdmka@ee.com,FALSE'

        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        req.setMethod('POST');
        req.setEndpoint('callout:Expensify_Details');
        req.setBody(body);
        req.setTimeout(120000);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('GGGGG' + res.getBody());
    }

    @AuraEnabled
    public static void updateStatusFromApprovedToReimbursed(string travelFundId) {
        system.debug('travelFundId New debug:::   =>  ' + travelFundId);
        list<Expensify_Attachment__c> expenAttach = [SELECT Id, Report_Id__c, URL__c FROM Expensify_Attachment__c WHERE Travel_Fund_Request__c = :travelFundId];
        //Travel_Fund_Request__c tfrObj=[select Id,Approved_Amount__c,ContactEmail__c,Expensify_Report_Name__c,Event__r.Expensify_Policy_ID__c ,Name,Event__r.Name,FirstName__c,Expensify_ID__c from Travel_Fund_Request__c where Id=:travelFundId];
        //system.debug('tfrObj New debug:::   =>  ' + tfrObj);
        list<String> reportIdList = new list<String>();

        for (Expensify_Attachment__c expAttObj : expenAttach) {
            reportIdList.add(expAttObj.Report_Id__c);
        }
        system.debug('reportIdList:: ' + reportIdList);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Expensify_Details');
        request.setMethod('POST');
        string strBody = 'requestJobDescription={"type":"update", "credentials":{"partnerUserID":"' + System.Label.expensify_partnerUserID + '", "partnerUserSecret":"' + System.Label.expensify_partnerUserSecret + '"}, "inputSettings":{"type":"reportStatus", "status" : "Reimbursed", "filters":{"reportIDList":"' + expenAttach[0].Report_Id__c + '"} } }';//requestJobDescription={"type":"download","credentials":{"partnerUserID":"aa_sunil_chaudhary_webuters_com","partnerUserSecret":"4662ade007bf5c335228b5fe8f780810ea1b4bf4"},"fileName":"'+respData.strDesc+'","fileSystem":"integrationServer"}';
        //strBody='&data=';
        request.setBody(strBody);
        HttpResponse response = http.send(request);
        System.debug('response.getBody:::: ' + response.getBody());
        System.debug('response.getStatus:::: ' + response.getStatus());
        System.debug('response.getStatusCode:::: ' + response.getStatusCode());
    }

    public class ResponseWrapper {
        @AuraEnabled
        public string strCode { get; set; }
        @AuraEnabled
        public string strDesc { get; set; }
    }
    public class ExpenseReceipt {
        @AuraEnabled
        public string ReportID { get; set; }
        @AuraEnabled
        public string accountEmail { get; set; }
        @AuraEnabled
        public string PolicyId { get; set; }
        @AuraEnabled
        public string TotalAmount { get; set; }
        @AuraEnabled
        public string ReportStatus { get; set; }
        @AuraEnabled
        public date ReportDate { get; set; }
    }
}