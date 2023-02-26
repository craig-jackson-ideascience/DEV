/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 07-01-2020.
 * Description: GetEventsDropdownTest
 ********************************************************/
@isTest
public class GetEventsDropdownTest{
	@testSetup
	static void setup(){
		Project__c testProj = TestDataUtils.createProject(true, 'The Linux Foundation', 'Membership', 'Linux Foundation', 'Planned');
		testProj.Status__c = 'Active';
		update testProj;

		Event__c testEvent = TestDataUtils.createEvent(false, 'testEventName', 'Unfunded', 'Non-LF Event', 'Planned');
		testEvent.BillFromProject__c = testProj.Id;
		insert testEvent;
	}

	@isTest
	static void eventIdTest(){
		Event__c event = [SELECT ID
		                  from Event__c
		                  LIMIT 1];
		// Set up a test request
		RestRequest request = new RestRequest();
		// Set request properties
		request.requestUri = 
				'https://linuxfoundation--stage.cs36.my.salesforce.com/services/apexrest/VisaRequestForm';
		request.httpMethod = 'POST';
		Map<String, String> mapBody = new Map<String, String>();
		mapBody.put('eventId', event.Id);
		mapBody.put('query', 'SELECT Id,Name From Event__c');
		request.requestBody = Blob.valueOf(System.JSON.serialize(mapBody));
		// Finally, assign the request to RestContext if used
		RestContext.request = request;
		String respString = GetEventsDropdown.getDOMString();
		System.assert(respString.contains('<input'));
	}

	@isTest
	static void queryTest(){
		// Set up a test request
		RestRequest request = new RestRequest();
		// Set request properties
		request.requestUri = 
				'https://linuxfoundation--stage.cs36.my.salesforce.com/services/apexrest/VisaRequestForm';
		request.httpMethod = 'POST';
		Map<String, String> mapBody = new Map<String, String>();
		mapBody.put('eventId', '');
		mapBody.put('query', 'SELECT Id, Name From Event__c');
		request.requestBody = Blob.valueOf(System.JSON.serialize(mapBody));
		// Finally, assign the request to RestContext if used
		RestContext.request = request;
		String respString = GetEventsDropdown.getDOMString();
		System.assert(respString.contains('<select'));
	}
}