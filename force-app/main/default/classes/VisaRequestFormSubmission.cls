/********************************************************
 * Created by: CloudRoute Solutions
 * Created Date: 18/11/19.
 * Description: VisaRequestFormSubmission
 ********************************************************/
@RestResource(UrlMapping='/VisaRequestForm/*')
global class VisaRequestFormSubmission {

    @HttpPost
    global static String processForm() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Blob requestBodyBlob = req.requestBody;
        String requestBody = requestBodyBlob.toString();
        System.debug('Request Body: ' + requestBody);

        String apiId;
        apiId = APIRequestLog.createApiRequestlog(requestBody, 'Visa Request Form');
        System.debug('apiId: ' + apiId);

        Map<String, Object> formMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        System.debug('formMap: ' + formMap);

        String attendeeType = (String) formMap.get('attendeeType');
        String firstName = (String) formMap.get('firstName');
        String lastName = (String) formMap.get('lastName');
        String gender = (String) formMap.get('gender');
        String email = (String) formMap.get('email');
        String passport = (String) formMap.get('passport');
        String dateOfBirth = (String) formMap.get('dateOfBirth');
        String countryOfBirth = (String) formMap.get('countryOfBirth');
        String company = (String) formMap.get('company');
        String accommodationPaidBy = (String) formMap.get('accommodationPaidBy');
        String orgPayingForTravel = (String) formMap.get('orgPayingForTravel');
        String jobTitle = (String) formMap.get('jobTitle');
        String phone = (String) formMap.get('phone');
        String street = (String) formMap.get('street');
        String addLine2 = (String) formMap.get('addLine2');
        String city = (String) formMap.get('city');
        String state = (String) formMap.get('state');
        String zip = (String) formMap.get('zip');
        String country = (String) formMap.get('country');
        String event = (String) formMap.get('event');

        Id contId;
        Id accId;
        String status = 'failed';
        String errorMessage = '';

        try {

            if (email != null && email != '') {
                //Create Visa Request for the Contact
                Visa_Request__c visa_request = new Visa_Request__c();
                visa_request.Event__c = event.replace(',', ''); //ToDo: Check why comma is added
                //visa_request.Contact__c = contId;
                visa_request.Attendee_Type__c = attendeeType;
                visa_request.FirstName__c = firstName;
                visa_request.LastName__c = lastName;
                visa_request.Gender__c = gender;
                visa_request.ContactEmail__c = email;
                visa_request.Passport_Number__c = passport;
                visa_request.CountryOfBirth__c = countryOfBirth;
                visa_request.Company_or_Organization__c = company;
                visa_request.Accommodation_Paid_by__c = accommodationPaidBy;
                visa_request.Title__c = jobTitle;
                visa_request.Office_phone__c = phone; //ToDo: Pratik to confirm if the mapping is correct
                visa_request.Org_paying_for_your_travel__c = orgPayingForTravel;
                visa_request.mailing_Address1__c = street;
                visa_request.mailing_Address_2__c = addLine2;
                visa_request.City__c = city;
                visa_request.State__c = state;
                visa_request.Country__c = country;
                visa_request.Zipcode__c = zip;
                visa_request.Register_Event__c = true;
                if(String.isNotBlank(dateOfBirth)){
                   visa_request.DateofBirth__c = dateOfBirth.contains('/') ? Date.parse(dateOfBirth) : Date.valueOf(dateOfBirth);
                }

                SObjectAccessDecision visaRequestSecurityDecision = Security.stripInaccessible(AccessType.CREATABLE, new List<Visa_Request__c>{
                        visa_request
                });
                insert visaRequestSecurityDecision.getRecords();

                status = 'success';
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());
            errorMessage = 'Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString();
            APIRequestLog.updateApiRequestLog(apiId, 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
            if (e.getMessage().contains('No event registration found')) {
                status = 'Not Registered';
                sendNotRegisteredEmail(apiId, firstName, lastName, email, event);
            } else if(e.getMessage().contains('DUPLICATES_DETECTED')){
                status = 'Duplicate';
            } else {
                sendLogEmail(requestBody, errorMessage, status);
            }
            //res.statusCode = 400;
        }
        return status;
    }

    global static void sendLogEmail(String requestBody, String errorMessage, String status) {
        String emailBody = 'Hi there, <br/> <br/> We have a new submission from Visa Request Form. <br/> Please find below details of the submission<br/><br/>';
        emailBody += 'Response: ' + status;

        if (errorMessage != null && errorMessage != '') {
            emailBody += '<br/> <br/> ' + errorMessage + '<br/>';
        }
        requestBody = requestBody.replaceAll('" : "', ' : ');
        requestBody = requestBody.replaceAll('", "', '<br>');
        requestBody = requestBody.replace('{"', '<br>');
        requestBody = requestBody.replace('"}', '<br>');
        emailBody += requestBody;


        Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = Label.Visa_Request_Form_Submission_Recipients.split(';');
        mail.setOrgWideEmailAddressId(orgWideEmailAddress);
        mail.setToAddresses(toAddresses);
        mail.setSubject('Visa Request Form Submission');
        mail.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }

    public static void sendNotRegisteredEmail(String apiId, String firstName, String lastName, String email, String event) {
        try {

            Event__c e = [SELECT Id, Event_Registration_URL__c FROM Event__c WHERE Id = :event];


            String emailBody = Label.Visa_Request_Form_Submission_Not_Registered_Email;

            emailBody = emailBody.replace('[Name]', firstName + ' ' + lastName);
            emailBody = emailBody.replace('[RegistrationURL]', e.Event_Registration_URL__c);

            Id orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'visaletters@linuxfoundation.org' LIMIT 1].Id;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new List<String>{
                    email
            };
            mail.setOrgWideEmailAddressId(orgWideEmailAddress);
            mail.setToAddresses(toAddresses);
            mail.setSubject('There was an error with your visa letter request submission');
            mail.setHtmlBody(emailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
        } catch (Exception e) {
            APIRequestLog.updateApiRequestLog(apiId, 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
        }
    }

}