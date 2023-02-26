/**
 * CventCalloutUtility : Utility Class to perform Cvent Callouts
 * TestClass -  CventCalloutUtility_Test class,GetEventFromCvent_Test
 */
public with sharing class CventCalloutUtility{
	
	public Cvent_Integration__c cventIntegration = Cvent_Integration__c.getOrgDefaults();
	/**
	 * cventLogin : Method for login to cvent
	 */
	public String cventLogin(){
		String cventHeader = '';
		CventAPI.V200611Soap api = new CventAPI.V200611Soap();
		CventAPI.LoginResult loginResult = api.Login(cventIntegration.Cvent_AccountNumber__c, cventIntegration.Cvent_Username__c, cventIntegration.Cvent_Password__c);
		//SuccessFul login
		cventHeader = loginResult.LoginSuccess ? loginResult.CventSessionHeader : 'Error : ' + loginResult.ErrorMessage;
		return cventHeader;
	}

	/**
	 * getCventFilter : Method to get Cvent Filter Instance
	 * @param  fieldname : fieldName on to the filter to be set
	 * @param  operator  : Operator for filter
	 * @param  value : filter value
	 * @param  valueArray : array of values for filtering
	 */
	public CventAPI.Filter getCventFilter(String fieldname, String operator, String value, List<String> valueArray){
		CventAPI.Filter cventFilter = new CventAPI.Filter();
		cventFilter.Field = fieldname;
		cventFilter.Operator = operator;
		if (valueArray != null){
			CventAPI.ArrayOfString arrayString = new CventAPI.ArrayOfString();
			arrayString.Value = valueArray;
			cventFilter.ValueArray = arrayString;
		} else if (String.isNotEmpty(value)){
			cventFilter.Value = value;
		}
		return cventFilter;
	}

	/**
	 * @description cventSearch : Method to perform search Operation in cvent for an object to retrieve cvents' Id array
	 * @param  cventSessionHeader : cventSessionHeader for performing callout
	 * @param  searchObjectName : objectname that is to be searched
	 * @param  cvSearchObject : instance of cvSearchObject
	 */
	public CventAPI.IdArray cventSearch(String cventSessionHeader, String searchObjectName, CventAPI.CvSearch cvSearchObject){

		CventAPI.IdArray searchedIdArray;
		CventAPI.V200611Soap api = new CventAPI.V200611Soap();
		api.CventSessionHeader = new CventAPI.CventSessionHeader();
		api.CventSessionHeader.CventSessionValue = cventSessionHeader;
		CventAPI.SearchResult searchResult = api.Search_x(searchObjectName, cvSearchObject);
		
		if (searchResult != null && searchResult.Id != null){
			searchedIdArray = new CventAPI.IdArray();
			searchedIdArray.Id = new List<String>(searchResult.Id);
		}
		return searchedIdArray;
	}

	/**
	 * @description getCvSearchObject :Methos to get instance of CvSearch
	 * @param  searchType : what kind of search to be perform that can be 'AndSearch OR OrSearch'
	 * @param  cventFilter : List of filters
	 */
	public CventAPI.CvSearch getCvSearchObject(String searchType, List<CventAPI.Filter> cventFilter){
		//Create filters
		CventAPI.CvSearch cvSearchObject = new CventAPI.CvSearch();
		cvSearchObject.SearchType = searchType;
		cvSearchObject.Filter = cventFilter;
		return cvSearchObject;
	}

	/**
	 * @description getESTDateTime Method to get the Time in EST TimeZone as we have to pass it in cvent
	 * @param  convertingDateTime : DateTime that is to be converted
	 */
	public String getESTDateTime(DateTime convertingDateTime){
		//String convertedTime = convertingDateTime.format('yyyy-mm-dd HH:mm:ss', 'America/New_York');
		return convertingDateTime.format('yyyy-MM-dd HH:mm:ss', 'America/New_York');
	}

	/**
	 * @description convertDateToDateTime : Method to convert the date to dateTime Object
	 * @param  convertingDate : conversion date
	 */	 
	public DateTime convertDateToDateTime(Date convertingDate){
		return dateTime.newInstance(convertingDate.year(), convertingDate.month(), convertingDate.day());
	}

	/**
	 * @description searchEvents : Method For searching the Events in cvent based on statuslist and lastmodified filter
	 * @param  cventSessionHeader : sessionHeader for callout
	 * @param  statusList : List of statuses of the events to be searched
	 * @param  lastModifiedTime : from which lastmodiifed event must be searched
	 */
	public CventAPI.IdArray searchEvents(String cventSessionHeader, List<String> statusList, DateTime lastModifiedTime){

		//EventStatus Filter
		CventAPI.Filter statusfilter = getCventFilter('EventStatus', 'Includes', null, statusList);

		String lastSyncedTime = getESTDateTime(lastModifiedTime);

		
		//LastModified Filter
		CventAPI.Filter lastModifiedFilter = getCventFilter('LastModifiedDate', 'Greater than or Equal to', lastSyncedTime, null);		

		//Get SearchObject
		CventAPI.CvSearch cvSearchObject = getCvSearchObject('AndSearch', new List<CventAPI.Filter>{statusfilter,lastModifiedFilter});

		//Search
		CventAPI.IdArray eventIdArray = cventSearch(cventSessionHeader, 'Event', cvSearchObject);
		return eventIdArray;
	}

	/**
	 * @description searchAndRetrieveEvents : Method for searching and Retrieving the events from cvent system
	 * @param  statusList       : List of statuses of the events to be searched
	 * @param  lastModifiedTime : from which lastmodiifed event must be searched
	 */ 
	public List<CventAPI.Event> searchAndRetrieveEvents(List<String> statusList, DateTime lastModifiedTime){

		List<CventAPI.Event> cventEventsList = new List<CventAPI.Event>();
		String cventSessionHeader = '';
		//Login
		cventSessionHeader = cventLogin();
		if (String.isNotEmpty(cventSessionHeader) && !cventSessionHeader.contains('Error : ')){

			//Search
			CventAPI.IdArray eventIdArray = searchEvents(cventSessionHeader, statusList, lastModifiedTime);
			if (eventIdArray != null){
				
				//Retrieve Block
				CventAPI.V200611Soap api = new CventAPI.V200611Soap();
				api.CventSessionHeader = new CventAPI.CventSessionHeader();
				api.CventSessionHeader.CventSessionValue = cventSessionHeader;


				//Retrieve Event Details by event Id List
				CventAPI.ArrayOfEvent eventArrayResult = api.RetrieveEvents(eventIdArray);
				
				
				if (eventArrayResult != null && eventArrayResult.Event != null){
					cventEventsList = eventArrayResult.Event;
				}
			}
		}
		return cventEventsList;
	}


	/**
	 * @description searchRegistrations : Method for searching the eventregistrations from cvent
	 * @param  cventEventIds 		:	List of EventsIds whose registration is to be searched
	 * @param  lastSyncedTime 		:   from which lastmodiifed registration must be searched
	 * @param  cventSessionHeader 	: cvent header for callout
	 */
	public CventAPI.IdArray searchRegistrations(List<String> cventEventIds, String lastSyncedTime, String cventSessionHeader){
		//EventId Filter
		
		//CventAPI.Filter eventIdFIlter = getCventFilter('EventId', 'Includes', null, new List<String>{cventEventIds[0]});
		CventAPI.Filter eventIdFIlter = getCventFilter('EventId', 'Includes', null, cventEventIds);
		
		//LastModified Filter
		CventAPI.Filter lastSyncedFilter = getCventFilter('LastModifiedDate', 'Greater than or Equal to', lastSyncedTime, null);
		
		CventAPI.CvSearch cvSearchObject = getCvSearchObject('AndSearch', new List<CventAPI.Filter>{eventIdFIlter,lastSyncedFilter});
		//Search
		CventAPI.IdArray registrationIdArray = cventSearch(cventSessionHeader, 'Registration', cvSearchObject);
		
		return registrationIdArray;
	}

	/**
	 * retrieveRegistrations : Method to Retrieve registrations from cvent
	 * @param  registrationIdArray : Id which is to be retrieved
	 * @param  cventSessionHeader  : cventsessionHeader for login
	 */
	public List<CventAPI.Registration> retrieveRegistrations(CventAPI.IdArray registrationIdArray, String cventSessionHeader){
		List<CventAPI.Registration> registrationCvent;
		CventAPI.V200611Soap api = new CventAPI.V200611Soap();
		api.CventSessionHeader = new CventAPI.CventSessionHeader();
		api.CventSessionHeader.CventSessionValue = cventSessionHeader;


		//Retrieve Event Details by event Id List
		CventAPI.ArrayOfRegistration registrationArrayResult = api.RetrieveRegistrations(registrationIdArray);
				
		if (registrationArrayResult != null && registrationArrayResult.Registration != null){
			registrationCvent = registrationArrayResult.Registration;
		}
		return registrationCvent;
	}

	/**
	 * @description otherTimeToGMTTime : Method for Converting From DateTime From GivenTimeZone to GMTTimeZone
	 * @param  dateTimeString : datetime which is to be converted
	 * @param  timezoneName   : timezone from which is to be convrted
	 */ 
	public Datetime otherTimeToGMTTime(String dateTimeString, String timezoneName){
		Datetime estTime = DateTime.valueOfGmt((dateTimeString).substringBeforeLast('.').replace('T', ' '));
		
		TimeZone timeZoneInstance = TimeZone.getTimeZone(timezoneName);
		Integer offsetMinutes = timeZoneInstance.getOffset(estTime) / 1000 / 60;
		
		Datetime gmtTime = estTime.addMinutes(-offsetMinutes);
		
		return gmtTime;
	}

	/**
	 * @description getCventLogsToInsertRecords : Method to get the cvent lods which is to be inserted
	 * @param  registrationIds : registrationid set
	 */ 
	public List <Cvent_Registration_Log__c> getCventLogsToInsertRecords(List<String> registrationIds){
		List<Cvent_Registration_Log__c> registrationLogsToInsert = new List<Cvent_Registration_Log__c>();
		Map<String,Cvent_Registration_Log__c> cventLogMap = new Map<String,Cvent_Registration_Log__c>();
		//Retrieve Existing cventLogs record based on cventId
		List<Cvent_Registration_Log__c> cventLogsList =[SELECT Cvent_Id__c,Successfully_Processed__c
		                                                 FROM Cvent_Registration_Log__c
		                                                 WHERE Cvent_Id__c IN :registrationIds];

		//Iterate and create set of cventIds
		for (Cvent_Registration_Log__c registrationLog : cventLogsList){
			cventLogMap.put(registrationLog.Cvent_Id__c,registrationLog);
		}

		//Iterate on registrationids
		for (String registrationId : registrationIds){
			
				registrationLogsToInsert.add(new Cvent_Registration_Log__c(Cvent_Id__c = registrationId,Searched__c=Datetime.now(),Type__c='Registration',Successfully_Processed__c = false,Sfdc_Upsert_Last_Error__c = '',sfdc_upsert_last_attempt_time__c = null,sfdc_upsert_attempts_count__c = 0,Retrieved__c = null));
			
		}
		System.debug('registrationLogsToInsert ' + registrationLogsToInsert);
		return registrationLogsToInsert;
	}

	public void sendErrorMail(String subject, String body){
		Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>();
			Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setOrgWideEmailAddressId(orgWideEmailAddress);
			mail.setToAddresses(Utility.getEmailAddresses('System_Administrator_Group'));
			//mail.setToAddresses(new List<String>{'meenakshi.j@cloudroute.in'});
			mail.setSubject(subject);
			mail.setHtmlBody(body);
			emails.add(mail);
			system.debug('------' + emails);
			if (emails.size() > 0){
				Messaging.sendEmail(emails);
			}
	}
}