/********************************************************
* Created by: Martand Atrey @ CloudRoute Solutions
* Created Date: 23-12-2019.
* Description: TravelFundRequestRest
********************************************************/
@RestResource(urlMapping='/travelFundRequest/*')
global with sharing class TravelFundRequestRest {
    @HttpPost
    global static void processForm() {

        String errorMessage;

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, String> header = req.headers;
        System.debug('Header is ' + header);

        TFRResponseWrapper responseWrapper;

        Blob requestBodyBlob = req.requestBody;
        String requestBody = requestBodyBlob.toString();
        System.debug('Request Body: ' + requestBody);

        String apiId;
        apiId = APIRequestLog.createApiRequestlog(requestBody, 'Travel Fund Request Form');

        Map<String, Object> formMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        System.debug('formMap: ' + formMap);

        String event;
        if (formMap.containsKey('event') && formMap.get('event') != null) {
            event = (String) formMap.get('event');

            List<Event__c> events = [SELECT Id, Accept_Travel_Fund__c From Event__c where Id = :event];

            if (events.isEmpty()) {
                responseWrapper = new TFRResponseWrapper();
                responseWrapper.error = new ErrorWrapper('No Event with id: ' + event + ' found.');
                res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                res.statusCode = 200;
                return;
            } else if (events[0].Accept_Travel_Fund__c != 'Yes') {
                responseWrapper = new TFRResponseWrapper();
                responseWrapper.error = new ErrorWrapper('This event doesn\'t accept travel fund request.');
                res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                res.statusCode = 200;
                return;
            }

        } else {
            responseWrapper = new TFRResponseWrapper();
            responseWrapper.error = new ErrorWrapper('Event is required to create Travel Fund Request');
            res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
            res.statusCode = 200;
            return;
        }
        String firstName;
        if (formMap.containsKey('firstName') && formMap.get('firstName') != null)
            firstName = (String) formMap.get('firstName');
        String lastName;
        if (formMap.containsKey('lastName') && formMap.get('lastName') != null) {
            lastName = (String) formMap.get('lastName');
        } else {
            responseWrapper = new TFRResponseWrapper();
            responseWrapper.error = new ErrorWrapper('LastName is required to create Travel Fund Request');
            res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
            res.statusCode = 200;
            return;
        }
        String emailAddress;
        if (formMap.containsKey('emailAddress') && formMap.get('emailAddress') != null) {
            emailAddress = (String) formMap.get('emailAddress');
        } else {
            responseWrapper = new TFRResponseWrapper();
            responseWrapper.error = new ErrorWrapper('EmailAddress is required to create Travel Fund Request');
            res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
            res.statusCode = 200;
            return;
        }

        String CompanyName;
        if (formMap.containsKey('CompanyName') && formMap.get('CompanyName') != null)
            CompanyName = (String) formMap.get('CompanyName');
        String receivedFunds;
        if (formMap.containsKey('receivedFunds') && formMap.get('receivedFunds') != null)
            receivedFunds = (String) formMap.get('receivedFunds');
        String socialLink;
        if (formMap.containsKey('socialLink') && formMap.get('socialLink') != null)
            socialLink = (String) formMap.get('socialLink');
        String groupsString;
        if (formMap.containsKey('group') && formMap.get('group') != null) {
            groupsString = (String) formMap.get('group');
            groupsString = groupsString.replaceAll(',', ';');
        }
        String otherDescription;
        if (formMap.containsKey('otherDescription') && formMap.get('otherDescription') != null)
            otherDescription = (String) formMap.get('otherDescription');
        String reasonToAttend;
        if (formMap.containsKey('reasonToAttend') && formMap.get('reasonToAttend') != null)
            reasonToAttend = (String) formMap.get('reasonToAttend');
        String travellingFrom;
        if (formMap.containsKey('travellingFrom') && formMap.get('travellingFrom') != null)
            travellingFrom = (String) formMap.get('travellingFrom');
        String numOfNights ;
        if (formMap.containsKey('numOfNights') && formMap.get('numOfNights') != null)
            numOfNights = (String) formMap.get('numOfNights');
        Decimal estimateCost = 0;
        if (formMap.containsKey('estimateCost') && formMap.get('estimateCost') != null)
            estimateCost = Decimal.valueOf((String) formMap.get('estimateCost'));
        Boolean attendingBehalfofComp = false;
        if (formMap.containsKey('attendingBehalfofComp') && formMap.get('attendingBehalfofComp') != null)
            attendingBehalfofComp = ((String) formMap.get('attendingBehalfofComp')).toLowerCase() == 'yes';
        Boolean writingBlog = false;
        if (formMap.containsKey('writingBlog') && formMap.get('writingBlog') != null)
            writingBlog = ((String) formMap.get('writingBlog')).toLowerCase() == 'yes';
        List<ExpenseWrapper> expenses = (List<ExpenseWrapper>) JSON.deserialize(JSON.serialize(formMap.get('expenses')), List<ExpenseWrapper>.class);
        String otherEventName;
        if (formMap.containsKey('otherEventName') && formMap.get('otherEventName') != null)
            otherEventName = (String) formMap.get('otherEventName');
        String otherEventLocation;
        if (formMap.containsKey('otherEventLocation') && formMap.get('otherEventLocation') != null)
            otherEventLocation = (String) formMap.get('otherEventLocation');
        String otherEventStartDate;
        if (formMap.containsKey('otherEventStartDate') && formMap.get('otherEventStartDate') != null)
            otherEventStartDate = (String) formMap.get('otherEventStartDate');
        String otherEventEndDate;
        if (formMap.containsKey('otherEventEndDate') && formMap.get('otherEventEndDate') != null)
            otherEventEndDate = (String) formMap.get('otherEventEndDate');
        String orgPaying;
        if (formMap.containsKey('orgPaying') && formMap.get('orgPaying') != null)
            orgPaying = (String) formMap.get('orgPaying');

        System.debug('otherEventName: ' + otherEventName);
        System.debug('otherEventLocation: ' + otherEventLocation);
        System.debug('otherEventStartDate: ' + otherEventStartDate);
        System.debug('otherEventEndDate: ' + otherEventEndDate);

        /*  List<ContentVersion> cvList = new List<ContentVersion>();
        for (integer i = 0; i < LineItemCount; i++) {
        String fileName= (String) formMap.get('FILENAMEfileToUpload_' + i);
        if (fileName != null && fileName  != '') {
        ContentVersion cv = new ContentVersion();
        cv.Title = (String) formMap.get('expenseName_' + i);
        cv.PathOnClient = (String) formMap.get('FILENAMEfileToUpload_' + i);
        String base64String = (String) formMap.get('BODYfileToUpload_' + i);
        base64String = base64String.subString(base64String.indexOf('base64') + 7);
        Blob b = EncodingUtil.base64Decode(base64String);
        cv.Versiondata = b;
        cvList.add(cv);
        }
        }*/


        try {
            responseWrapper = new TFRResponseWrapper();
            responseWrapper.expenses = new List<ExpenseWrapper>();
            Travel_Fund_Request__c travelFundRequest = new Travel_Fund_Request__c(
                    Status__c = 'Waiting Approval',
                    FirstName__c = firstName,
                    LastName__c = lastName,
                    Event__c = event,
                    TFREmail__c = emailAddress,
                    Company_or_Organization__c = CompanyName,
                    q03_Can_Receive_Funding_From_Org__c = receivedFunds,
                    Link_Entered__c = socialLink,
                    Diversity__c = groupsString,
                    Other_Underrepresent__c = otherDescription,
                    Reason_to_attend__c = reasonToAttend,
                    Travelling_From__c = travellingFrom,
                    Hotel_Accommodations__c = Decimal.valueOf(numOfNights),
                    Estimated_Cost__c = estimateCost,
                    Attending_on_behalf_of_a_company__c = attendingBehalfofComp,
                    Blog_on_event_experience__c = writingBlog

            );

            if (otherEventName != null && otherEventName != '') {
                travelFundRequest.NonLF_Event__c = otherEventName;
            }
            if (otherEventLocation != null && otherEventLocation != '') {
                travelFundRequest.Non_LFEvent_Location__c = otherEventLocation;
            }
            if (otherEventStartDate != null && otherEventStartDate != '') {
                travelFundRequest.NonLF_Event_StartDate__c = otherEventStartDate.contains('/') ? Date.parse(otherEventStartDate) : Date.valueOf(otherEventStartDate);
            }
            if (otherEventEndDate != null && otherEventEndDate != '') {
                travelFundRequest.NonLF_Event_EndDate__c = otherEventEndDate.contains('/') ? Date.parse(otherEventEndDate) : Date.valueOf(otherEventEndDate);
            }
            if (orgPaying != null && orgPaying != '') {
                travelFundRequest.Company_Assistance__c = orgPaying;
            }
            insert travelFundRequest;

            responseWrapper.travelFundRequestId = travelFundRequest.id;

            /* Map<String, String> contentDocumentStrings = new Map<String, String>();
            List<ContentVersion> contentVersionsList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ID IN :cvList];
            for (ContentVersion cv : contentVersionsList) {
            contentDocumentStrings.put(cv.PathOnClient, cv.ContentDocumentId);
            }
            */
            List<Travel_Fund_Request_Line_Item__c> travelFundRequestLIList = new List<Travel_Fund_Request_Line_Item__c>();
            //Integer count = INteger.valueOf((String) formMap.get('count'));

            if (expenses != null) {
                for (ExpenseWrapper expense : expenses) {
                    travelFundRequestLIList.add(new Travel_Fund_Request_Line_Item__c(
                            Travel_Fund_Request__c = travelFundRequest.Id,
                            Line_Description__c = expense.Name,
                            Type__c = expense.type,
                            Cost__c = expense.value
                    ));

                }
                /* travelFundRequestLIList.add(new Travel_Fund_Request_Line_Item__c(Travel_Fund_Request__c = travelFundRequest.Id, Cost__c = expenseValue_0, Line_Description__c = expenseName_0, Type__c = expenseType_0));
                travelFundRequestLIList.add(new Travel_Fund_Request_Line_Item__c(Travel_Fund_Request__c = travelFundRequest.Id, Cost__c = expenseValue_1, Line_Description__c = expenseName_1, Type__c = expenseType_1));
                */
                insert travelFundRequestLIList;

                for (Travel_Fund_Request_Line_Item__c tfrLItem : travelFundRequestLIList) {
                    responseWrapper.expenses.add(
                            new ExpenseWrapper(tfrLItem.Id, tfrLItem.Line_Description__c, tfrLItem.Type__c, tfrLItem.Cost__c)
                    );
                }
            }
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
            //return JSON.serialize(responseWrapper);
        } catch (Exception e) {
            System.debug('Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());
            responseWrapper = new TFRResponseWrapper();
            responseWrapper.error = new ErrorWrapper(e.getTypeName() + '\n' + e.getMessage());
            res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
            res.statusCode = 200;
            errorMessage = 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString() + ' and Cause: ' + e.getCause();
            //return JSON.serialize(responseWrapper);

            APIRequestLog.updateApiRequestLog(apiId, 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
        }

        try {
            string Body = 'Hi there, <br/> <br/> We have a new submission Travel Fund Request. <br/> Please find below details of the submission<br/><br/>';
            requestBody = requestBody.replaceAll('" : "', ' : ');
            requestBody = requestBody.replaceAll('", "', '<br>');
            requestBody = requestBody.replace('{"', '<br>');
            requestBody = requestBody.replace('"}', '<br>');
            Body += requestBody;
            OrgWideEmailAddress orgWideEmail = [SELECT ID,DisplayName,Address FROM OrgWideEmailAddress WHERE DisplayName = 'JoinNow'];


            if (errorMessage != null && errorMessage != '') {
                Body += '<br/> <br/> ' + errorMessage;
            }


            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = label.JoinNow_Form_Submission_Recipients.split(';');
            mail.setToAddresses(toAddresses);
            mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            mail.setSubject('Travel Fund Request Submission');
            mail.setHtmlBody(Body);

            //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString() + ' and Cause: ' + e.getCause());
            APIRequestLog.updateApiRequestLog(apiId, 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
        }

    }


    global class ExpenseWrapper {
        global String name;
        global String Id;
        global String type;
        global Decimal value;

        global ExpenseWrapper(String Id, String name, String type, Decimal value) {
            this.value = value;
            this.Id = Id;
            this.name = name;
            this.type = type;
        }
    }

    global class TFRResponseWrapper {
        global ErrorWrapper error;
        global String travelFundRequestId;
        global List<ExpenseWrapper> expenses;
    }

    global class ErrorWrapper {
        String errorMessage;

        global ErrorWrapper(String errorMessage) {
            this.errorMessage = errorMessage;
        }
    }
}