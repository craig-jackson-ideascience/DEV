/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 07-01-2020.
 * Description: VisaRequestFormSubmissionTest
 ********************************************************/
@IsTest
public class VisaRequestFormSubmissionTest {
    @TestSetup
    static void setup() {
        Project__c pj = TestDataUtils.createProject(false, 'The Linux Foundation', 'Membership', 'Linux Foundation', 'Active');

        pj.Type__c = 'Membership';
 		pj.Project_Type__c = 'Project';
        pj.Project_Entity_Name__c = 'Test P Name';
        pj.Funding__c = 'Funded';
        insert pj;

        Event__c event = TestDataUtils.createEvent(false, 'testEventName', 'Unfunded', 'Non-LF Event', 'Planned');
        event.BillFromProject__c = pj.Id;
        insert event;
    }


    @IsTest
    static void testWithoutAltEmail() {
        // Set up a test request
        RestRequest request = new RestRequest();
		// Set request properties
        request.requestURI = 'https://linuxfoundation--stage.cs36.my.salesforce.com/services/apexrest/VisaRequestForm';
        request.httpMethod = 'POST';
        Map<String, String> mapBody = new Map<String, String>();
        mapBody.put('attendeeType', 'I will be Attending');
        mapBody.put('firstName', 'TestFName');
        mapBody.put('lastName', 'TestLName');
        mapBody.put('gender', 'Male');
        mapBody.put('email', 'test@test.com');
        mapBody.put('passport', 'asdf123');
        mapBody.put('dateOfBirth', '1999-02-02');
        mapBody.put('countryOfBirth', 'United States');
        mapBody.put('company', 'testCompany');
        mapBody.put('accomodationPaidBy', 'Test');
        mapBody.put('orgPayingForTravel', 'NO');
        mapBody.put('jobTitle', 'testTitle');
        mapBody.put('phone', '9999999999');
        mapBody.put('street', 'streeet');
        mapBody.put('addLine2', 'line2');
        mapBody.put('city', 'city');
        mapBody.put('state', 'state');
        mapBody.put('zip', '888888');
        mapBody.put('country', 'Country');
        mapBody.put('event', [SELECT Id FROM Event__c LIMIT 1].Id);

        request.requestBody = Blob.valueOf(System.JSON.serialize(mapBody));
		// Finally, assign the request to RestContext if used
        RestContext.request = request;


        String resBody = VisaRequestFormSubmission.processForm();
        //System.assertEquals(resBody, 'Not Registered');
    }


    @IsTest
    static void testWithAltEmailContact() {
        Contact con = new Contact(LastName = 'testName', Email = 'test@test.com');
        insert con;

        Event__c event = [SELECT Id FROM Event__c LIMIT 1];

        Event_Registrations__c eventReg = new Event_Registrations__c();
        eventReg.Name = 'test eventregis';
        eventReg.Contact__c = con.Id;
        eventReg.Event__c = event.Id;
        eventReg.Data_Source__c = 'Manual Entry';
        insert eventReg;

        // Set up a test request
        RestRequest request = new RestRequest();
		// Set request properties
        request.requestURI = 'https://linuxfoundation--stage.cs36.my.salesforce.com/services/apexrest/VisaRequestForm';
        request.httpMethod = 'POST';
        Map<String, String> mapBody = new Map<String, String>();
        mapBody.put('attendeeType', 'I will be Attending');
        mapBody.put('firstName', 'TestFName');
        mapBody.put('lastName', 'TestLName');
        mapBody.put('gender', 'Male');
        mapBody.put('email', 'test@test.com');
        mapBody.put('passport', 'asdf123');
        mapBody.put('dateOfBirth', '1999-02-02');
        mapBody.put('countryOfBirth', 'United States');
        mapBody.put('company', 'testCompany');
        mapBody.put('accomodationPaidBy', 'Test');
        mapBody.put('orgPayingForTravel', 'NO');
        mapBody.put('jobTitle', 'testTitle');
        mapBody.put('phone', '9999999999');
        mapBody.put('street', 'streeet');
        mapBody.put('addLine2', 'line2');
        mapBody.put('city', 'city');
        mapBody.put('state', 'state');
        mapBody.put('zip', '888888');
        mapBody.put('country', 'Country');
        mapBody.put('event', [SELECT Id FROM Event__c LIMIT 1].Id);

        request.requestBody = Blob.valueOf(System.JSON.serialize(mapBody));
		// Finally, assign the request to RestContext if used
        RestContext.request = request;


        String resBody = VisaRequestFormSubmission.processForm();
        //System.assertEquals(resBody, 'success');
    }

    @IsTest
    static void testWithAltEmailLead() {
        insert new Lead(LastName= 'testName',Company = 'testCompany', Email = 'test@test.com');

        // Set up a test request
        RestRequest request = new RestRequest();
		// Set request properties
        request.requestURI = 'https://linuxfoundation--stage.cs36.my.salesforce.com/services/apexrest/VisaRequestForm';
        request.httpMethod = 'POST';
        Map<String, String> mapBody = new Map<String, String>();
        mapBody.put('attendeeType', 'I will be Attending');
        mapBody.put('firstName', 'TestFName');
        mapBody.put('lastName', 'TestLName');
        mapBody.put('gender', 'Male');
        mapBody.put('email', 'test@test.com');
        mapBody.put('passport', 'asdf123');
        mapBody.put('dateOfBirth', '1999-02-02');
        mapBody.put('countryOfBirth', 'United States');
        mapBody.put('company', 'testCompany');
        mapBody.put('accomodationPaidBy', 'Test');
        mapBody.put('orgPayingForTravel', 'NO');
        mapBody.put('jobTitle', 'testTitle');
        mapBody.put('phone', '9999999999');
        mapBody.put('street', 'streeet');
        mapBody.put('addLine2', 'line2');
        mapBody.put('city', 'city');
        mapBody.put('state', 'state');
        mapBody.put('zip', '888888');
        mapBody.put('country', 'Country');
        mapBody.put('event', [SELECT Id FROM Event__c LIMIT 1].Id);

        request.requestBody = Blob.valueOf(System.JSON.serialize(mapBody));
		// Finally, assign the request to RestContext if used
        RestContext.request = request;


        String resBody = VisaRequestFormSubmission.processForm();
        //System.assertEquals(resBody, 'Not Registered');
    }
}