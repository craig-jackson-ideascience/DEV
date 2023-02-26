/*
* Test Class For-EMSTriggerHandler and EMSCodeHelper Class
*/ 
@isTest
public with sharing class EMSCodeHelperTest {
	
    @isTest
	static void emsSuccessSync() {
		Endpoints__c endPoint = new Endpoints__c();
		endPoint.name = 'For EMS Code to NS';
		endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl';
		endPoint.Access_Token__c = '123';
		endPoint.Consumer_Key__c = '123';
		endPoint.Consumer_Secret__c = '123';
		endPoint.Realm__c = '1234';
		endPoint.Token_Secret__c = '123';
		endPoint.Script_Id__c = '73';
		insert endPoint;

		Test.setMock(HttpCalloutMock.class, new EMSCalloutMock());
		Test.startTest();
		Project__c project = new Project__c(Name = 'The Linux Foundation',Category__c = 'Incorporated Entity', Status__c ='Planned', Funding__c ='Funded', Manual_Status_Check__c  = false, slug__c = 'testproject', Model__c = 'Membership');
		insert project;        
		project.Status__c = 'active';
		update project;
			
		Event__c evt  = new Event__c(Name = 'Test Event', Category__c = 'Project Event', BillFromProject__c = project.id);
		insert evt;
		evt.NS_Deferred_Revenue_Account__c = '284';
		update evt;

		EMS__c ems = [SELECT Id, EMS_Number__c FROM EMS__c];
		System.debug(ems);

		ems.EMS_Number__c = null;
		update ems;

		ems.EMS_Number__c = '456';
		update ems;
			
		delete ems;
		undelete ems;
			
		Test.stopTest();
	}
		
	@isTest
	static void emsSuccessSyncError() {
		Endpoints__c endPoint = new Endpoints__c();
		endPoint.name = 'For EMS Code to NS';
		endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl';
		endPoint.Access_Token__c = '123';
		endPoint.Consumer_Key__c = '123';
		endPoint.Consumer_Secret__c = '123';
		endPoint.Realm__c = '1234';
		endPoint.Token_Secret__c = '123';
		endPoint.Script_Id__c = '73';
		insert endPoint;

		Test.setMock(HttpCalloutMock.class, new EMSSyncErrorCalloutMock());
		Test.startTest();
		Project__c project = new Project__c(Name = 'The Linux Foundation',Category__c = 'Incorporated Entity', Status__c ='Planned', Funding__c ='Funded', Manual_Status_Check__c  = false, slug__c = 'testproject', Model__c = 'Membership');
		insert project;        
		project.Status__c = 'active';
		update project;
			
		Event__c evt  = new Event__c(Name = 'Test Event', Category__c = 'Project Event', BillFromProject__c = project.id);
		insert evt;
		evt.NS_Deferred_Revenue_Account__c = '284';
		update evt;

		EMS__c ems = [SELECT Id, EMS_Number__c FROM EMS__c];
		System.debug(ems);
			
		Test.stopTest();
	}

	@isTest
	static void emsFailedSync() {
		Endpoints__c endPoint = new Endpoints__c();
		endPoint.name = 'For EMS Code to NS';
		endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl';
		endPoint.Access_Token__c = '123';
		endPoint.Consumer_Key__c = '123';
		endPoint.Consumer_Secret__c = '123';
		endPoint.Realm__c = '1234';
		endPoint.Token_Secret__c = '123';
		endPoint.Script_Id__c = '73';
		insert endPoint;

		Test.setMock(HttpCalloutMock.class, new EMSCalloutMockFailure());
		Test.startTest();
		Project__c project = new Project__c(Name = 'The Linux Foundation',Category__c = 'Incorporated Entity', Status__c ='Planned', Funding__c ='Funded', Manual_Status_Check__c  = false, slug__c = 'testproject', Model__c = 'Membership');
		insert project;
		project.Status__c = 'active';
		update project;
			
		Event__c evt  = new Event__c(Name = 'Test Event', Category__c = 'Project Event', BillFromProject__c = project.Id);
		insert evt;
		evt.NS_Deferred_Revenue_Account__c = '284';
		update evt;

		EMS__c ems = [SELECT Id, EMS_Number__c FROM EMS__c];
		System.debug(ems);

		Test.stopTest();
	}
		
	@isTest
	static void emsExceptionSync() {
		Endpoints__c endPoint = new Endpoints__c();
		endPoint.name = 'For EMS Code to NS';
		endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl';
		endPoint.Access_Token__c = '123';
		endPoint.Consumer_Key__c = '123';
		endPoint.Consumer_Secret__c = '123';
		endPoint.Realm__c = '1234';
		endPoint.Token_Secret__c = '123';
		endPoint.Script_Id__c = '73';
		insert endPoint;

		Test.setMock(HttpCalloutMock.class, new EMSExceptionCallout());
		Test.startTest();
		Project__c project = new Project__c(Name = 'The Linux Foundation',Category__c = 'Incorporated Entity', Status__c ='Planned', Funding__c ='Funded', Manual_Status_Check__c  = false, slug__c = 'testproject', Model__c = 'Membership');
		insert project;
		project.Status__c = 'active';
		update project;
			
		Event__c evt  = new Event__c(Name = 'Test Event', Category__c = 'Project Event', BillFromProject__c = project.Id);
		insert evt;
		evt.NS_Deferred_Revenue_Account__c = '284';
		update evt;

		EMS__c ems = [SELECT Id, EMS_Number__c FROM EMS__c];
		System.debug(ems);

		Test.stopTest();
	}
		
		
	// MockCallout for successful ems sync
	public class EMSCalloutMock implements HttpCalloutMock {
		// create response method
		public HTTPResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			EMSCodeHelper.ResponseWrapper wrap = new EMSCodeHelper.ResponseWrapper();
			wrap.id = '123';
			wrap.success = true;
			wrap.error = null;
			res.setBody(JSON.serialize(wrap));
			res.setStatusCode(200);
			return res;
		}
	}
	
	// MockCallout for successful ems sync with failed Sync Error
	public class EMSSyncErrorCalloutMock implements HttpCalloutMock {
		// create response method
		public HTTPResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			EMSCodeHelper.ResponseWrapper wrap = new EMSCodeHelper.ResponseWrapper();
			wrap.id = null;
			wrap.success = false;
			wrap.error = 'NetSuite Job Code Sync Failed due to Exceeding Character Limit';
			res.setBody(JSON.serialize(wrap));
			res.setStatusCode(200);
			return res;
		}
	}
	
	// MockCallout for failed ems sync
	public class EMSCalloutMockFailure implements HttpCalloutMock {
		// create response method
		public HTTPResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			EMSCodeHelper.ResponseError error = new EMSCodeHelper.ResponseError();
			error.code = '123';
			error.message = 'Fail';
			EMSCodeHelper.ResponseErrorWrapper wrap = new EMSCodeHelper.ResponseErrorWrapper();
			wrap.error = error;
			res.setBody(JSON.serialize(wrap));
			res.setStatusCode(401);
			return res;
		}
	}
	
	// MockCallout for exception
	public class EMSExceptionCallout implements HttpCalloutMock {
		// create response method
		public HTTPResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			// throw exception    
			CalloutException e = (CalloutException)CalloutException.class.newInstance();
			e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
			throw e;       
		}
	}
}