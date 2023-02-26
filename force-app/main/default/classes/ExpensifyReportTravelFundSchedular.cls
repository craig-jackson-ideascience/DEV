public class ExpensifyReportTravelFundSchedular {
    // call Queueable method To Execute Expensify Report
    public void execute(QueueableContext context) {
        ExpensifyReportTravelFundSchedular.fetchReportNames();
    }
    @future(callout=true)
    public static void fetchReportNames() {
        try {
            ResponseWrapper responseData = new ResponseWrapper();
            Boolean result;
            string strPolicies = '';
            Set<String> policies = new Set<String>();
            //Need to put filter How long we have running Event and Checking Travel Fund Requests
            //now it is set for 6 Months only

            list<Travel_Fund_Request__c> trvlFundList = [
                    SELECT Id, Expensify_Report_Name__c, Expensify_ID__c, ContactEmail__c, TFREmail__c, Expensify_Submitted_amount__c,
                            Expensify_Approved_Amount__c, Expensify_Paid_Amount__c, Status__c,
                            Event__r.Accept_Travel_Fund__c, Event__r.Expensify_Policy_ID__c
                    FROM Travel_Fund_Request__c
                    WHERE Event__r.Accept_Travel_Fund__c != '' AND Event__r.Expensify_Policy_ID__c != null
                    AND TFREmail__c != null
                    AND ((Status__c = 'Request Approved - Waiting For Expense Report' AND Expensify_Submitted_amount__c = null)
                    OR (Status__c = 'Expense Report Received - Waiting Final Approval' AND Expensify_Approved_Amount__c = null)
                    OR (Status__c = 'Expense Report Approved' AND Expensify_Paid_Amount__c = null))
            ];
            System.debug(trvlFundList);
            for (Travel_Fund_Request__c tfr : trvlFundList) {
                policies.add(tfr.Event__r.Expensify_Policy_ID__c);
            }

            /*for (Event__c evnt : [select id,Expensify_Policy_ID__c from Event__c where Expensify_Policy_ID__c != null AND Accept_Travel_Fund__c = 'Yes']) {
                policies.add(evnt.Expensify_Policy_ID__c);
            }*/
            strPolicies = String.join(new List<String>(policies), ',');

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //callout:My_Named_Credential
            request.setEndpoint('callout:Expensify_Details');
            request.setMethod('POST');
            request.setHeader('content-Type', 'application/x-www-form-urlencoded');
            system.debug('strPolicies:::-  ' + strPolicies);
            //string templateBody='<#if addHeader == true> ReportID, accountEmail,ReportURL<#lt> </#if><#assign reportNumber = 1> <#assign expenseNumber = 1> <#list reports as report> <#list report.transactionList as expense> <#-- note: expense.amount prints the original amount only --> ${report.reportID},<#t>${report.accountEmail},<#t> ${expense.receiptObject.url},<#t> <#assign expenseNumber = expenseNumber + 1></#list> <#assign reportNumber = reportNumber + 1> </#list>';     
            string templateBody = '<#if addHeader == true> ReportID,accountEmail,PolicyId,TotalAmount,ReportStatus,CreatedDate,<#lt> </#if><#assign reportNumber = 1> <#assign expenseNumber = 1> <#list reports as report> <#list report.transactionList as expense> <#-- note: expense.amount prints the original amount only --> ${report.reportID},<#t>${report.accountEmail},<#t> ${report.policyID},<#t>${report.total},<#t>${report.status},<#t>${report.created},<#t> <#assign expenseNumber = expenseNumber + 1></#list> <#assign reportNumber = reportNumber + 1> </#list>';
            string strBody = 'requestJobDescription={ "type":"file", "credentials":{ "partnerUserID":"{!HTMLENCODE($Credential.Username)}", "partnerUserSecret":"{!HTMLENCODE($Credential.Password)}" }, "onReceive":{ "immediateResponse":["returnRandomFileName"] }, "inputSettings":{ "type":"combinedReportData", "reportState":"APPROVED,REIMBURSED,OPEN,SUBMITTED,ARCHIVED","filters":{ "policyIDList":"' + strPolicies + '", "startDate":"2019-01-01", "endDate":"2029-11-30", "markedAsExported":"Expensify Export" } }, "outputSettings":{ "fileExtension":"csv"} }';
            strBody = strBody + '&template=' + EncodingUtil.urlEncode(templateBody, 'UTF-8');
            system.debug('strBody:::-  ' + strBody);
            request.setBody(strBody);
            HttpResponse response = http.send(request);
            responseData.strCode = string.valueof(response.getStatusCode());
            responseData.strDesc = response.getBody();
            System.debug('response.getBody() ::::' + response.getBody());
            //To Fetch Receipt once Report Ids Fetched from Expencsify Account
            receiptFetching(response.getBody(), trvlFundList);
        } catch (exception ex) {
            system.debug(logginglevel.ERROR, ex.getLineNumber() + 'Error In fetchReportNames::' + ex);
        }
    }


    // To Fetch receipt based on Report Ids which is fetch from Above Callout method
    public static void receiptFetching(String ReportID, List<Travel_Fund_Request__c> trvlFundList) {
        try {
            ResponseWrapper responseData = new ResponseWrapper();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Expensify_Details');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            string strBody = 'requestJobDescription={"type":"download","credentials":{ "partnerUserID":"' + System.Label.expensify_partnerUserID + '", "partnerUserSecret":"' + System.Label.expensify_partnerUserSecret + '" },"fileName":"' + ReportID + '","fileSystem":"integrationServer"}';
            request.setBody(strBody);
            HttpResponse response = http.send(request);
            system.debug(response);
            responseData.strCode = string.valueof(response.getStatusCode());
            responseData.strDesc = response.getBody();
            System.debug('response.getBody() ::::' + response.getBody());
            String[] receipts = response.getBody().split(',');
            system.debug('RECEIPT ::::' + receipts);
            list<String> emailList = new list<String>();
            List<ExpenseReceipt> ExpenseReceipts = new List<ExpenseReceipt>();

            map<string, String> reportIdStatusMap = new map<string, String>();
            if (receipts.size() > 6) {
                for (Integer i = 6; i < receipts.size() - 1; i = i + 6) {
                    ExpenseReceipt receipt = new ExpenseReceipt();

                    System.debug('receipts[i] ::: ' + receipts[i]);
                    System.debug('receipts[i+1] ::: ' + receipts[i + 1]);
                    System.debug('receipts[i+2] ::: ' + receipts[i + 2]);
                    System.debug('receipts[i+3] ::: ' + receipts[i + 3]);
                    System.debug('receipts[i+4] ::: ' + receipts[i + 4]);
                    System.debug('receipts[i+5] ::: ' + receipts[i + 5]);
                    receipt.ReportID = receipts[i];
                    receipt.accountEmail = receipts[i + 1];
                    receipt.PolicyId = receipts[i + 2].trim();
                    receipt.TotalAmount = receipts[i + 3];
                    receipt.ReportStatus = receipts[i + 4];
                    receipt.ReportDate = Date.valueOf(receipts[i + 5]);

                    emailList.add(receipts[i + 1]);

                    ExpenseReceipts.add(receipt);
                }
            }
            system.debug('Email List::::' + emailList);

            set<Travel_Fund_Request__c> updatedtrvlFundList = new set<Travel_Fund_Request__c>();
            system.debug('trvlFundList:::::' + trvlFundList);

            Map<String, Travel_Fund_Request__c> emailVsTFR = new Map<String, Travel_Fund_Request__c>();
            Map<String, Map<String, Travel_Fund_Request__c>> policyVsTravelFundRequestMap = new Map<String, Map<String, Travel_Fund_Request__c>>();

            for (Travel_Fund_Request__c trvlFund : trvlFundList) {
                if (String.isNotBlank(trvlFund.TFREmail__c)) {
                    emailVsTFR.put(trvlFund.TFREmail__c, trvlFund);
                }

                System.debug('trvlFund: ' + trvlFund);
                System.debug('trvlFund.Event__r.Expensify_Policy_ID__c: ' + trvlFund.Event__r.Expensify_Policy_ID__c);
                Map<String, Travel_Fund_Request__c> tempMap = new Map<String, Travel_Fund_Request__c>();
                if (policyVsTravelFundRequestMap.containsKey(trvlFund.Event__r.Expensify_Policy_ID__c)) {
                    tempMap = policyVsTravelFundRequestMap.get(trvlFund.Event__r.Expensify_Policy_ID__c);
                }
                tempMap.put(trvlFund.TFREmail__c, trvlFund);
                policyVsTravelFundRequestMap.put(trvlFund.Event__r.Expensify_Policy_ID__c, tempMap);
            }

            System.debug('policyVsTravelFundRequestMap: ' + policyVsTravelFundRequestMap);


            Map<String, Map<String, ExpenseReceipt>> policyVsExpenseReceiptMap = new Map<String, Map<String, ExpenseReceipt>>();

            for (ExpenseReceipt expenseReceipt : ExpenseReceipts) {
                System.debug('expenseReceipt: ' + expenseReceipt);

                Map<String, ExpenseReceipt> tempMap = new Map<String, ExpenseReceipt>();
                if (policyVsExpenseReceiptMap.containsKey(expenseReceipt.PolicyId)) {
                    tempMap = policyVsExpenseReceiptMap.get(expenseReceipt.PolicyId);
                }

                if (!tempMap.containsKey(expenseReceipt.accountEmail)
                        || (tempMap.containsKey(expenseReceipt.accountEmail) && tempMap.get(expenseReceipt.accountEmail).ReportDate < expenseReceipt.ReportDate)) {
                    tempMap.put(expenseReceipt.accountEmail, expenseReceipt);
                }

                policyVsExpenseReceiptMap.put(expenseReceipt.PolicyId, tempMap);
            }

            System.debug('policyVsExpenseReceiptMap: ' + policyVsExpenseReceiptMap);

            List<Travel_Fund_Request__c> tfToUpdate = new List<Travel_Fund_Request__c>();

            for (String policyId : policyVsExpenseReceiptMap.keySet()) {

                System.debug('policyId: ' + policyId);
                System.debug('##policyVsTravelFundRequestMap.containsKey(policyId)= ' + policyVsTravelFundRequestMap.containsKey(policyId));

                for (String emailAddress : policyVsExpenseReceiptMap.get(policyId).keySet()) {
                    ExpenseReceipt exRec = policyVsExpenseReceiptMap.get(policyId).get(emailAddress);

                    System.debug('emailAddress: ' + emailAddress);
                    System.debug('##policyVsTravelFundRequestMap.get(policyId).containsKey(emailAddress)=' +policyVsTravelFundRequestMap.get(policyId).containsKey(emailAddress));

                    if (policyVsTravelFundRequestMap.containsKey(policyId) && policyVsTravelFundRequestMap.get(policyId).containsKey(emailAddress)) {
                        Travel_Fund_Request__c trvlFund = policyVsTravelFundRequestMap.get(policyId).get(emailAddress);

                        System.debug('exRec: ' + exRec);
                        System.debug('trvlFund: ' + trvlFund);

                        trvlFund.Expensify_Report_Name__c = exRec.ReportID;
                        trvlFund.Expensify_ID__c = exRec.ReportID;

                        /*if (exRec.ReportStatus == 'Processing') {
                            trvlFund.Expensify_Submitted_amount__c = Decimal.valueOf(exRec.TotalAmount) / 100;
                            trvlFund.Status__c = 'Request Approved - Waiting for Expense Report';
                            System.debug('trvlFund.Expensify_Submitted_amount__c :::: ' + trvlFund.Expensify_Submitted_amount__c);

                        } else*/
                        if (exRec.ReportStatus == 'Submitted' && trvlFund.Status__c != 'Expense Report Received - Waiting for Final Approval') {
                            trvlFund.Expensify_ID__c = exRec.ReportID;
                            trvlFund.Expensify_Report_Name__c = exRec.ReportID;
                            trvlFund.Expensify_Submitted_amount__c = Decimal.valueOf(exRec.TotalAmount) / 100;
                            trvlFund.Status__c = 'Expense Report Received - Waiting for Final Approval';
                            System.debug('trvlFund.Expensify_Submitted_amount__c :::: ' + trvlFund.Expensify_Submitted_amount__c);
                            tfToUpdate.add(trvlFund);

                        } else if (exRec.ReportStatus == 'Approved' && trvlFund.Status__c != 'Expense Report Approved') {
                            trvlFund.Expensify_Approved_Amount__c = Decimal.valueOf(exRec.TotalAmount) / 100;
                            trvlFund.Expensify_Submitted_amount__c = Decimal.valueOf(exRec.TotalAmount) / 100;
                            trvlFund.Status__c = 'Expense Report Approved';
                            tfToUpdate.add(trvlFund);

                        } else if (exRec.ReportStatus == 'Reimbursed' && trvlFund.Status__c != 'Paid') {
                            trvlFund.Expensify_Approved_Amount__c = Decimal.valueOf(exRec.TotalAmount) / 100;
                            trvlFund.Expensify_Submitted_amount__c = Decimal.valueOf(exRec.TotalAmount) / 100;
                            trvlFund.Expensify_Paid_Amount__c = Decimal.valueOf(exRec.TotalAmount) / 100;
                            trvlFund.Status__c = 'Paid';
                            tfToUpdate.add(trvlFund);
                        }

                    }
                }
            }

            System.debug('tfToUpdate: ' + tfToUpdate);

            if (!tfToUpdate.isEmpty()) {
                update tfToUpdate;
            }

        } catch (exception ex) {
            system.debug(logginglevel.ERROR, ex.getLineNumber() + 'Error In receiptFetching::' + ex);
        }
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