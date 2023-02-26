/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 14-01-2020.
 * Description: TravelFundRequestRestTest
 * LastModifiedBy: Harshad Kuhite @Proxima
 ********************************************************/
@isTest
public class TravelFundRequestRestTest {
    
    // test setup method
    @testSetup static void setup() {
        Project__c parentProject = new Project__c();
        parentProject.Name = 'Parent Project';
        parentProject.Slug__c = 'test_parent_slug';
        parentProject.Status__c = 'Active';
        parentProject.Funding__c = 'Funded';
        parentProject.Model__c = 'Membership';
        insert parentProject;

        TestDataUtils.createProject(true, 'The Linux Foundation', 'Membership', 'Linux Foundation', 'Planned');

        Event__c evt = TestDataUtils.createEvent(false, 'testEventName', 'Unfunded' , 'Non-LF Event', 'Planned');
        evt.BillFromProject__c = parentProject.Id;
        insert evt; 
    }
    
    // test success Travel Fund Request
    @isTest
    static void sendSuccessRequest() {
        RestResponse res = new RestResponse();
        Event__c evt = [Select Id,Name From Event__c Where Name='testEventName' Limit 1];
        evt.Accept_Travel_Fund__c = 'Yes';
        update evt;

        RestRequest request = new RestRequest();
        request.requestUri ='https://linuxfoundation--stage.cs36.my.salesforce.com/services/apexrest/travelFundRequest/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ "event": "' + evt.Id + '","firstName": "Martand", "lastName": "Atrey", "emailAddress": "martand.a+test889@cloudroute.in", "CompanyName": "CloudRoute", "receivedFunds": "No", "socialLink": "testLInk", "reasonToAttend": " TestDesc", "travellingFrom": "INdia", "group": "LGBTQIA+,Woman,Person of Color,Person with Disability,Other", "numOfNights": "2", "estimateCost": "2", "attendingBehalfofComp": "Yes", "writingBlog": "Yes", "otherDescription": "otherDescription", "otherEventName": "otherEventName", "otherEventLocation": "otherEventLocation", "orgPaying": "orgPaying", "expenses": [{ "Name": "Royal Orchid Hotel", "Type": "Hotel", "Value": "500" }, { "Name": "AirAsia", "Type": "Air", "Value": "300" }, { "Name": "Oberoi", "Type": "Hotel", "Value": "150" } ] }');
        RestContext.request = request;
        RestContext.response = res;
        TravelFundRequestRest.processForm();
        System.debug(RestContext.response + '====> res');
     }
    
    // test exception Travel Fund Request
    @isTest
    static void sendErrorRequest() {
        RestResponse res = new RestResponse();
        Event__c evt = [Select Id,Name From Event__c Where Name='testEventName' Limit 1];
        evt.Accept_Travel_Fund__c = 'Yes';
        update evt;

        RestRequest request = new RestRequest();
        request.requestUri ='https://linuxfoundation--stage.cs36.my.salesforce.com/services/apexrest/travelFundRequest/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ "event": "' + evt.Id + '","firstName": "Harshad", "lastName": "Kuhite", "emailAddress": "harshad.kuhite", "CompanyName": "Proxima", "receivedFunds": "No", "socialLink": "testLInk", "reasonToAttend": " TestDesc", "travellingFrom": "INdia", "group": "LGBTQ,Woman,Person of Color,Person with Disability,Other", "numOfNights": "2", "estimateCost": "2", "attendingBehalfofComp": "Yes", "writingBlog": "Yes", "otherDescription": "otherDescription", "otherEventName": "otherEventName", "otherEventLocation": "otherEventLocation", "orgPaying": "orgPaying", "expenses": [{ "Name": "Royal Orchid Hotel", "Type": "Hotel", "Value": "500" }, { "Name": "AirAsia", "Type": "Air", "Value": "300" }, { "Name": "Oberoi", "Type": "Hotel", "Value": "150" } ] }');
        RestContext.request = request;
        RestContext.response = res;
        TravelFundRequestRest.processForm();
        System.debug(RestContext.response + '====> res');
    }

    // test Travel Fund Request without Passing Event ID
    @isTest
    static void sendRequestWithoutEventID() {
        RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri ='https://linuxfoundation--stage.cs36.my.salesforce.com/services/apexrest/travelFundRequest/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ "otherDescription":"Test Description","CompanyName": "CloudRoute", "receivedFunds": "No", "socialLink": "testLInk", "reasonToAttend": " TestDesc", "travellingFrom": "INdia", "group": "LGBTQ,Woman,Person of Color,Person with Disability,Other", "numOfNights": "2", "estimateCost": "2", "attendingBehalfofComp": "Yes", "writingBlog": "Yes", "expenses": [{ "Name": "Royal Orchid Hotel", "Type": "Hotel", "Value": "500" }, { "Name": "AirAsia", "Type": "Air", "Value": "300" }, { "Name": "Oberoi", "Type": "Hotel", "Value": "150" } ] }');
        RestContext.request = request;
        RestContext.response = res;
        TravelFundRequestRest.processForm();
        System.debug(RestContext.response + '====> res');   
    }
    
    // test Travel Fund Request by Passing Event where Accept Travel Fund is False
    @isTest
    static void sendRequestWithEventAcceptTravelFundFalse() {
        Event__c evt = [Select Id,Name From Event__c Where Name='testEventName' Limit 1];
        evt.Accept_Travel_Fund__c = 'False';
        update evt;
		RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri ='https://linuxfoundation--stage.cs36.my.salesforce.com/services/apexrest/travelFundRequest/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ "event": "' + evt.Id + '","firstName": "Martand", "emailAddress": "martand.a+test889@cloudroute.in", "CompanyName": "CloudRoute", "receivedFunds": "No", "socialLink": "testLInk", "reasonToAttend": " TestDesc", "travellingFrom": "INdia", "group": "LGBTQ,Woman,Person of Color,Person with Disability,Other", "numOfNights": "2", "estimateCost": "2", "attendingBehalfofComp": "Yes", "writingBlog": "Yes", "expenses": [{ "Name": "Royal Orchid Hotel", "Type": "Hotel", "Value": "500" }, { "Name": "AirAsia", "Type": "Air", "Value": "300" }, { "Name": "Oberoi", "Type": "Hotel", "Value": "150" } ] }');
        RestContext.request = request;
        RestContext.response = res;
        TravelFundRequestRest.processForm();
        System.debug(RestContext.response + '====> res');
    }
	
    // test Travel Fund Request by Sending Dummy Event ID
    @isTest
    static void sendRequestWithDummyEventID() {      
		RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri ='https://linuxfoundation--stage.cs36.my.salesforce.com/services/apexrest/travelFundRequest/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ "event": "dummyeventid","firstName": "Martand", "emailAddress": "martand.a+test889@cloudroute.in", "CompanyName": "CloudRoute", "receivedFunds": "No", "socialLink": "testLInk", "reasonToAttend": " TestDesc", "travellingFrom": "INdia", "group": "LGBTQ,Woman,Person of Color,Person with Disability,Other", "numOfNights": "2", "estimateCost": "2", "attendingBehalfofComp": "Yes", "writingBlog": "Yes", "expenses": [{ "Name": "Royal Orchid Hotel", "Type": "Hotel", "Value": "500" }, { "Name": "AirAsia", "Type": "Air", "Value": "300" }, { "Name": "Oberoi", "Type": "Hotel", "Value": "150" } ] }');
        RestContext.request = request;
        RestContext.response = res;
        TravelFundRequestRest.processForm();
        System.debug(RestContext.response + '====> res');
    }
 
    // test Travel Fund Request without Passing Last Name
    @isTest
    static void sendRequestWithoutLastName() {
        Event__c evt = [Select Id,Name From Event__c Where Name='testEventName' Limit 1];
        evt.Accept_Travel_Fund__c = 'Yes';
        update evt;
		
        RestResponse res = new RestResponse();
		RestRequest request = new RestRequest();
        request.requestUri ='https://linuxfoundation--stage.cs36.my.salesforce.com/services/apexrest/travelFundRequest/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ "event": "' + evt.Id + '","firstName": "Martand", "CompanyName": "CloudRoute", "emailAddress": "martand.a+test889@cloudroute.in","receivedFunds": "No", "socialLink": "testLInk", "reasonToAttend": " TestDesc", "travellingFrom": "INdia", "group": "LGBTQ,Woman,Person of Color,Person with Disability,Other", "numOfNights": "2", "estimateCost": "2", "attendingBehalfofComp": "Yes", "writingBlog": "Yes", "expenses": [{ "Name": "Royal Orchid Hotel", "Type": "Hotel", "Value": "500" }, { "Name": "AirAsia", "Type": "Air", "Value": "300" }, { "Name": "Oberoi", "Type": "Hotel", "Value": "150" } ] }');
        RestContext.request = request;
        RestContext.response = res;
        TravelFundRequestRest.processForm();
        System.debug(RestContext.response + '====> res');
    }

    // test Travel Fund Request without Passing Email Address
    @isTest
    static void sendRequestWithoutEmailAddress() {
 		Event__c evt = [Select Id,Name From Event__c Where Name='testEventName' Limit 1];
        evt.Accept_Travel_Fund__c = 'Yes';
        update evt;
		RestResponse res = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri ='https://linuxfoundation--stage.cs36.my.salesforce.com/services/apexrest/travelFundRequest/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ "event": "' + evt.Id + '","firstName": "Martand", "CompanyName": "CloudRoute", "lastName": "Atrey","receivedFunds": "No", "socialLink": "testLInk", "reasonToAttend": " TestDesc", "travellingFrom": "INdia", "group": "LGBTQ,Woman,Person of Color,Person with Disability,Other", "numOfNights": "2", "estimateCost": "2", "attendingBehalfofComp": "Yes", "writingBlog": "Yes", "expenses": [{ "Name": "Royal Orchid Hotel", "Type": "Hotel", "Value": "500" }, { "Name": "AirAsia", "Type": "Air", "Value": "300" }, { "Name": "Oberoi", "Type": "Hotel", "Value": "150" } ] }');
        RestContext.request = request;
        RestContext.response = res;
        TravelFundRequestRest.processForm();
        System.debug(RestContext.response + '====> res');
    }
}