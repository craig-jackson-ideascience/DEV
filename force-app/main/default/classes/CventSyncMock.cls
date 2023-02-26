@isTest
public class CventSyncMock implements WebServiceMock{
	public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType){

		//Login
		if (request instanceof CventAPI.Login_element){
			CventAPI.Login_element login = (CventAPI.Login_element)request;
			CventAPI.LoginResult loginResult = new CventAPI.LoginResult();
			//Correct Login
			if (login.Password == 'CPassword'){

				loginResult.LoginSuccess = true;
				loginResult.CventSessionHeader = 'testSessionHeader';
				CventAPI.LoginResponse_element loginResponse = new CventAPI.LoginResponse_element();
				loginResponse.LoginResult = loginResult;
				response.put('response_x', loginResponse);
			} else if (login.Password == 'TestSearch'){

				loginResult.LoginSuccess = true;
				loginResult.CventSessionHeader = 'testSearchSessionHeader';
				CventAPI.LoginResponse_element loginResponse = new CventAPI.LoginResponse_element();
				loginResponse.LoginResult = loginResult;
				response.put('response_x', loginResponse);
			}else if (login.Password == 'SearchEvent'){

				loginResult.LoginSuccess = true;
				loginResult.CventSessionHeader = 'testSearchEvent';
				CventAPI.LoginResponse_element loginResponse = new CventAPI.LoginResponse_element();
				loginResponse.LoginResult = loginResult;
				response.put('response_x', loginResponse);
			}
			//For Session Expired Login
			else if (login.Password == 'expired'){
				CalloutException e = new CalloutException();
				e.setMessage('Test Exception');
				throw e;
			}
			//For Errorneous Login
			else{
				loginResult.LoginSuccess = false;
				loginResult.ErrorMessage = 'TestError';
				CventAPI.LoginResponse_element loginResponse = new CventAPI.LoginResponse_element();
				loginResponse.LoginResult = loginResult;
				response.put('response_x', loginResponse);
			}
		}
		//Search
		else if (request instanceof CventAPI.Search_element){
			String id = '';
			CventAPI.Search_element cvApiSearch = (CventAPI.Search_element)request;
			CventAPI.V200611Soap api = (CventAPI.V200611Soap)stub;
				
			//Search based on objecttype
			if (cvApiSearch.ObjectType == 'Registration'){
				

				if (api.CventSessionHeader.CventSessionValue == 'testSearchSessionHeader'){
					CalloutException e = new CalloutException();
					e.setMessage('SESSION_EXPIRED : Test Search Exception');
					throw e;
				} else{
					id = 'TestSearchId45768';
				}
			} else if (cvApiSearch.ObjectType == 'Event'){
				id = api.CventSessionHeader.CventSessionValue == 'testSearchEvent' ? 'testSearchEvent' : 'TestEventId';
			} else if (cvApiSearch.ObjectType == 'Contact'){
				id = 'TestContactId';
			}
			CventAPI.SearchResult searchResult = new CventAPI.SearchResult();
			searchResult.Id = new List<String>{ id };
			CventAPI.SearchResponse_element searchResponse = new CventAPI.SearchResponse_element();
			searchResponse.SearchResult = searchResult;
			response.put('response_x', searchResponse);
		}
		//Retrieve Events
		else if (request instanceof CventAPI.RetrieveEvents_element){
			
			CventAPI.RetrieveEvents_element req = (CventAPI.RetrieveEvents_element)request;

			CventAPI.Event event = new CventAPI.Event();
			//For TestSearchEvent Pass Large number of ids which will throw error
			event.Id = !req.Ids.Id.isEmpty() && req.Ids.Id[0] == 'testSearchEvent' ? 'testtesttesttesttesttesttesttesttesttest' : 'TestEventId';
			event.EventCode = 'TestCode';
			event.EventTitle = 'TestTitle';
			event.EventStartDate = Datetime.now().addDays(-2);
			event.EventEndDate = Datetime.now().addDays(-1);
			event.LastModifiedDate = Datetime.now();
			CventAPI.CustomFieldDetail eventCustomDetail = new CventAPI.CustomFieldDetail();
			eventCustomDetail.FieldName = 'Project';
			eventCustomDetail.FieldValue = 'The Linux Foundation (LF)';
			event.CustomFieldDetail = new List<CventAPI.CustomFieldDetail>{ eventCustomDetail };

			CventAPI.TargetListDetail targetDetail = new CventAPI.TargetListDetail();
			targetDetail.TargetedListId = '091-4B11-9ADC-5E27CA9C9';
			targetDetail.TargetedListName = 'Invitation list';
			targetDetail.TargetedListLanguage = 'English';
			targetDetail.TargetedListDefault = true;
			event.TargetListDetail = new List<CventAPI.TargetListDetail>{ targetDetail };

			CventAPI.ArrayOfEvent retrieveEventsResult = new CventAPI.ArrayOfEvent();
			retrieveEventsResult.Event = new List<CventAPI.Event>{ event };
			CventAPI.RetrieveEventsResponse_element retrieveEventsResponse = new CventAPI.RetrieveEventsResponse_element();
			retrieveEventsResponse.RetrieveEventsResult = retrieveEventsResult;
			response.put('response_x', retrieveEventsResponse);
		}
		//Retrieve Registrations
		else if (request instanceof CventAPI.RetrieveRegistrations_element){
			CventAPI.OrderDetail ordrDetail = new CventAPI.OrderDetail();
			ordrDetail.OrderDetailItemId = 'TestOrderItemId';
			ordrDetail.OrderDetailId = 'TestOrderId';
			ordrDetail.ProductId = 'TestProductId';
			ordrDetail.ProductName = 'ServiceMeshCon Product';
			ordrDetail.Action = 'Registered';
			ordrDetail.Participant = true;
			ordrDetail.Amount = 10;
			ordrDetail.AmountDue = 50;
			ordrDetail.AmountPaid = 50;

			List<CventAPI.EventSurveyDetail> evtSurveyList = new List<CventAPI.EventSurveyDetail>();
			CventAPI.EventSurveyDetail evtSurveyDetail = new CventAPI.EventSurveyDetail();
			evtSurveyDetail.QuestionText = 'What gender do you identify with?';
			evtSurveyDetail.AnswerText = new List<String>{ 'Man' };
			evtSurveyList.add(evtSurveyDetail);

			CventAPI.EventSurveyDetail evtSurveyDetail1 = new CventAPI.EventSurveyDetail();
			evtSurveyDetail.QuestionText = 'Areas of Interest (new!)';
			evtSurveyDetail.AnswerText = new List<String>{ 'Blockchain', 'Financial Services', 'Interoperability' };
			evtSurveyList.add(evtSurveyDetail1);

			CventAPI.RetrieveRegistrations_element req = (CventAPI.RetrieveRegistrations_element)request;

			if (!req.Ids.Id.isEmpty() && req.Ids.Id[0] == 'TestSessionExpired'){
				CalloutException e = new CalloutException();
				e.setMessage('SESSION_EXPIRED : Test Retrieve Exception');
				throw e;
			}
			CventAPI.Registration registration = new CventAPI.Registration();
			registration.Id = !req.Ids.Id.isEmpty() ? req.Ids.Id[0] : 'TestSearchId45768';
			registration.ContactId = !req.Ids.Id.isEmpty() && req.Ids.Id[0] == 'TestWrongContact' ? '' : !req.Ids.Id.isEmpty() && req.Ids.Id[0] == 'TestSessionExpiredForContact' ? 'TestSessionExpiredContact' : 'TestContactId';

			registration.EmailAddress = !req.Ids.Id.isEmpty() && req.Ids.Id[0] == 'TestWrongEmail' ? 'testemail.com' : 'test@email.com';
			registration.SourceId = 'testcontact';
			registration.EventCode = 'TestCode';
			registration.EventTitle = 'TestTitle';
			registration.FirstName = 'Test';
			registration.LastName = 'Contact';
			registration.EventId = 'TestEventId';
			registration.OrderDetail = new List<CventAPI.OrderDetail>{ ordrDetail };
			system.debug('reg ' + registration);
			registration.EventSurveyDetail = new List<CventAPI.EventSurveyDetail>(evtSurveyList);

			CventAPI.ArrayOfRegistration retrieveRegistrationsArray = new CventAPI.ArrayOfRegistration();
			retrieveRegistrationsArray.Registration = new List<CventAPI.Registration>{ registration };
			CventAPI.RetrieveRegistrationsResponse_element retrieveRegistrations = new CventAPI.RetrieveRegistrationsResponse_element();
			retrieveRegistrations.RetrieveRegistrationsResult = retrieveRegistrationsArray;
			response.put('response_x', retrieveRegistrations);
		} else if (request instanceof CventAPI.RetrieveContacts_element){
			CventAPI.RetrieveContacts_element req = (CventAPI.RetrieveContacts_element)request;

			if (!req.Ids.Id.isEmpty() && req.Ids.Id[0] == 'TestSessionExpiredContact'){
				CalloutException e = new CalloutException();
				e.setMessage('SESSION_EXPIRED : Test Retrieve Contact Exception');
				throw e;
			}

			CventAPI.Contact contact = new CventAPI.Contact();
			contact.Id = 'TestContactId';
			contact.FirstName = 'Test';
			contact.LastName = 'Contact';
			contact.EmailAddress = 'test@email.com';
			contact.SourceId = 'testcontact';

			CventAPI.CustomFieldDetail contactCustomDetail = new CventAPI.CustomFieldDetail();
			contactCustomDetail.FieldName = 'What is your company size?';
			contactCustomDetail.FieldValue = '100';
			contact.CustomFieldDetail = new List<CventAPI.CustomFieldDetail>{ contactCustomDetail };

			CventAPI.ArrayOfContact retrieveContactElement = new CventAPI.ArrayOfContact();
			retrieveContactElement.Contact = new List<CventAPI.Contact>{ contact };
			CventAPI.RetrieveContactsResponse_element retrieveContactsElement = new CventAPI.RetrieveContactsResponse_element();
			retrieveContactsElement.RetrieveContactsResult = retrieveContactElement;
			response.put('response_x', retrieveContactsElement);
		}
	}
}