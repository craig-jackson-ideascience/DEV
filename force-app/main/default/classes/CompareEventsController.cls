/*
Controller Class For CompareEvent Component on Events Dashboard
Test Class - CompareEventsControllerTest
*/
public class CompareEventsController{
	//static class variables
	public static final String LABEL = 'label';
	public static final String VALUE = 'value';
	public static List<String> statusList = new List<String>{'Canceled', 'Cancelled'};
	//Method to get all the eventsMap with the dafault
	//one selected and all its registration details on init
	@AuraEnabled
	public static Map<String, Object> getAllEvents(String defaultId){

		//Initialize Variable
		Map<String, Object> responseMap = new Map<String, Object>();
		List<Map<String, String>> eventNames = new List<Map<String, String>>();

		try{

			//Loop on all events to create eventNames List.
			for (Event__c event : [SELECT Id, Name, Event_Registrations__c
			                       FROM Event__c
			                       WHERE Event_Registrations__c != 0
			                       ORDER BY Name]){
				
				eventNames.add(new Map<String, String>{LABEL => event.Name, VALUE => event.Id});


			}

			//store registration details
			responseMap.put('Details', getRegistrationDetails(defaultId));
			//events list
			responseMap.put('Events', eventNames);
			//Debug
			System.debug('eventNames :' + eventNames);
		} catch (Exception ex){
			System.debug('Exception---: ' + ex.getMessage()+'==AT==' + ex.getLineNumber());
			responseMap.put('Error', 'Something went wrong');
		}

		//retun the created list
		return responseMap;
	}

	//Mehod to get registrationDetails For specifed eventId
	@AuraEnabled
	public static Map<String, Object> getRegistrationDetails(String eventIds){
		system.debug('in getRegistrationDetails');

		Map<String, Object> responseMap = new Map<String, Object>();
		try{
			System.debug('#--eventIds--#' + eventIds);
			if (String.isNotEmpty(eventIds)){
				//This will contains only one id as the component uses single select picklist
				List<Id> eventIdList = (List<Id>)JSON.deserialize(eventIds, List<Id>.class);

				//Retrieve registrations for the event
				List<Event_Registrations__c> evtRegistrationList = [SELECT Id, Name, Cvent_Registration_RegistrationDate__c, Cvent_Registration_Status__c,
				 Cvent_Registration_Amount_Formula__c,Event__r.Start_Date__c
				                                                    FROM Event_Registrations__c
				                                                    WHERE Event__c IN :eventIdList
				                                                    ORDER BY Cvent_Registration_RegistrationDate__c desc];
				System.debug('Event_Registrations__c ' + evtRegistrationList);
				if (!evtRegistrationList.isempty()){

					system.debug('Registration ' + evtRegistrationList[0].Cvent_Registration_RegistrationDate__c);

					//store total revenue of event
					Decimal totalAmount = 0;
					//store total registrations for event
					Integer count = 0;
					//store last registration date
					Date lastDate;
					Date eventStartDate;

					//Iterate
					for (Event_Registrations__c evtReg : evtRegistrationList){
						//just to store last registration date
						if (lastDate == null && evtReg.Cvent_Registration_RegistrationDate__c != null){

							lastDate = evtReg.Cvent_Registration_RegistrationDate__c.dateGMT();
							eventStartDate = evtReg.event__r.Start_Date__c;
							System.debug('lastDate ' + lastDate);
						}

						//get number of registrations and total Revenue for event
						if (!statusList.contains(evtReg.Cvent_Registration_Status__c) || evtReg.Cvent_Registration_Status__c == null){
							count += 1;
							if (!statusList.contains(evtReg.Cvent_Registration_Status__c)){
								totalAmount += evtReg.Cvent_Registration_Amount_Formula__c != null ? evtReg.Cvent_Registration_Amount_Formula__c : 0;
							}

						}

					}
					system.debug('eventStartDate ' + eventStartDate);
					System.debug('totalAmount ' + totalAmount);
					//Call method to get the RegistrationWrapper for the table on component
					String tableString = getRegistrationTableDetails(eventStartDate, eventIdList, count, totalAmount);

					responseMap.put('Last Registration', lastDate);
					responseMap.put('Total Registrations', count);
					responseMap.put('Registration Details', tableString);
				}
			}
		} catch (Exception ex){
			System.debug('Exception---: ' + ex.getMessage()+'==AT==' + ex.getLineNumber());
			responseMap.put('Error', 'Something went wrong');
		}

		return responseMap;
	}

	//Method to get the RegistrationWrapper for the table on component
	private static String getRegistrationTableDetails(Date eventStartDate, List<Id> eventIdList, Integer totalMemberCount, Decimal totalAmount){


		//store total registrations for event
		Integer overAllMemberCount = totalMemberCount;

		//Monday's date of last registartion Date
		Date lastRegistrationMonday = eventStartDate.toStartofWeek()+1;

		//Monday's date of last 20 weeks
		Date firstRegistrationMonday = lastRegistrationMonday.addDays(-140);
		System.debug('lastRegistrationMonday ' + lastRegistrationMonday);
		System.debug('firstRegistrationMonday ' + firstRegistrationMonday);


		/*The Week range is from Monday to Sunday and we are going back in time
			 i.e from the week of the last registration date to the 20 weeks before the last registrationdate
			 we are moving back in time and the weekcount is increased by one
		 */
		//Monday's date of last registartion Date
		Date registrationWeekStart = lastRegistrationMonday;

		//last registration date
		Date registrationWeekEnd = lastRegistrationMonday.addDays(6);

		//Get Registrations of twenty weeks
		Map<Id,Event_Registrations__c> evtRegListMap = new Map<Id,Event_Registrations__c>
		([SELECT Id, Name, Cvent_Registration_RegistrationDate__c, Cvent_Registration_Amount_Formula__c
		                                           FROM Event_Registrations__c
		                                           WHERE Event__c IN :eventIdList AND Cvent_Registration_RegistrationDate__c != null 
												   AND Cvent_Registration_Status__c NOT IN :statusList AND 
												   day_only(Cvent_Registration_RegistrationDate__c) <= :registrationWeekEnd 
												   AND day_only(Cvent_Registration_RegistrationDate__c) >= :firstRegistrationMonday
		                                           ORDER BY Cvent_Registration_RegistrationDate__c desc]);
		Map<String, EventRegistrationWrapper> evtRegWrapperMap = new Map<String, EventRegistrationWrapper>();
		System.debug('#--evtRegListMap--#' + evtRegListMap.size());			
			System.debug('registrationWeekStart ' + registrationWeekStart);
			System.debug('registrationWeekEnd ' + registrationWeekEnd);
			String key = '';


			
//Iterate through 20 Weeks loop
				for(Integer weekCount=0; weekCount<21 ; weekCount++){
					key = weekCount < 10 ? '0' + String.valueOf(weekCount)+' Weeks Out' :
					 String.valueOf(weekCount)+' Weeks Out';
				
					EventRegistrationWrapper evtRegWrapper = new EventRegistrationWrapper(key, 0, totalMemberCount, totalAmount, 0);
					evtRegWrapperMap.put(key, evtRegWrapper);

					//Iterate through EventRegistrationList
					for(Event_Registrations__c evtReg : evtRegListMap.values()){
						Decimal revenueAmount = evtReg.Cvent_Registration_Amount_Formula__c != null ? evtReg.Cvent_Registration_Amount_Formula__c : 0;
						Date regDate = evtReg.Cvent_Registration_RegistrationDate__c.dateGMT();
				
						System.debug('evtReg ' + evtReg);
				System.debug('key ' + key);
				System.debug('regDate ' + regDate);
				System.debug('gg ' + (regDate >= registrationWeekStart));
				System.debug('ll ' + (regDate <= registrationWeekEnd));

				System.debug('if registrationWeekStart ' + registrationWeekStart);
				System.debug('if registrationWeekEnd ' + registrationWeekEnd);
				System.debug('if totalMemberCount ' + totalMemberCount);
				System.debug('if totalAmount ' + totalAmount);

						//if registrationdate falls in the week range
				if (regDate >= registrationWeekStart && regDate <= registrationWeekEnd){
						//increase the number by 1 and revenue by cventregistrationamount
						evtRegWrapper = evtRegWrapperMap.get(key);
						evtRegWrapper.newReg += 1;
						evtRegWrapper.individualWeekRevenue += revenueAmount;
					
					evtRegWrapperMap.put(key, evtRegWrapper);
					System.debug(' if evtRegWrapper ' + evtRegWrapper);

					//Remove that registration from map which has been counted
					evtRegListMap.remove(evtReg.Id);
				}else{
					break;
				} 
					}
						

//Week-end becomes weekstart-1 as we go back in time
registrationWeekEnd = registrationWeekStart.addDays(-1);
//Week-start becomes weekend-6 as we go back in time
registrationWeekStart = registrationWeekEnd.addDays(-6);

//decrease the total member by the new registration of the week
totalMemberCount -= evtRegWrapperMap.get(key).newReg;
//decrease the totalamount by individual's revenue
totalAmount -= evtRegWrapperMap.get(key).individualWeekRevenue;

					}

			


	// 		for (Event_Registrations__c evtReg : evtRegListMap){
	// 			System.debug('evtReg ' + evtReg);
	// 			//prepare the keys as 00 weeks and so on
	// 			key = weekCount < 10 ? 
	// 																  '0' + String.valueOf(weekCount)+' Weeks Out' : String.valueOf(weekCount)+' Weeks Out';
	// 			EventRegistrationWrapper evtRegWrapper = new EventRegistrationWrapper();

	// 			//cventRegistration date of event registration record
	// 			Date regDate = evtReg.Cvent_Registration_RegistrationDate__c.dateGMT();
				
	// 			System.debug('key ' + key);
	// 			System.debug('regDate ' + regDate);
	// 			System.debug('gg ' + (regDate >= registrationWeekStart));
	// 			System.debug('ll ' + (regDate <= registrationWeekEnd));

	// 			System.debug('if registrationWeekStart ' + registrationWeekStart);
	// 			System.debug('if registrationWeekEnd ' + registrationWeekEnd);
	// 			System.debug('if totalMemberCount ' + totalMemberCount);
	// 			System.debug('if totalAmount ' + totalAmount);

	// 			//if the registration date do not fall in the week range then calculate the cumulative variables
	// 			if (!(regDate >= registrationWeekStart && regDate <= registrationWeekEnd)){
	// 				if(!evtRegWrapperMap.containsKey(key)){
	// 				for(Integer i=weekCount; i<21 ; i++){
	// 					//if lastRegistration is not falling in week range
	// 					if(!(regDate >= registrationWeekStart && regDate <= registrationWeekEnd)){
	// 						//then add the wrapper with 0 count as registration for that week
	// 					key = weekCount < 10 ? 
	// 																	  '0' + String.valueOf(weekCount)+' Weeks Out' : String.valueOf(weekCount)+' Weeks Out';
					
	// 					 evtRegWrapper = new EventRegistrationWrapper(key, 0, totalMemberCount, totalAmount, 0);
	// 						evtRegWrapperMap.put(key, evtRegWrapper);
	// 						//increase weekcount by one
	// weekCount += 1;
	// //Week-end becomes weekstart-1 as we go back in time
	// registrationWeekEnd = registrationWeekStart.addDays(-1);
	// //Week-start becomes weekend-6 as we go back in time
	// registrationWeekStart = registrationWeekEnd.addDays(-6);
	
	// //decrease the total member by the new registration of the week
	// totalMemberCount -= evtRegWrapperMap.get(key).newReg;
	// //decrease the totalamount by individual's revenue
	// totalAmount -= evtRegWrapperMap.get(key).individualWeekRevenue;
	
	// 					}else{
	// 						//if falls in the week range then comw out of loop
	// 						break;
	// 					}
	// 				}
	// 			}
					
	// 				}
				
	// 			//if registrationdate falls in the week range
	// 			if (regDate >= registrationWeekStart && regDate <= registrationWeekEnd){

	// 				//if the registration is the first for the week
	// 				if (!evtRegWrapperMap.containskey(key)){
	// 					evtRegWrapper = new EventRegistrationWrapper(key, 1, totalMemberCount, totalAmount, revenueAmount);

	// 				} else{
	// 					//increase the number by 1 and revenue by cventregistrationamount
	// 					evtRegWrapper = evtRegWrapperMap.get(key);
	// 					evtRegWrapper.newReg += 1;
	// 					evtRegWrapper.individualWeekRevenue += revenueAmount;
	// 				}
	// 				evtRegWrapperMap.put(key, evtRegWrapper);
	// 				System.debug(' if evtRegWrapper ' + evtRegWrapper);
	// 			} 


	// 		}
	// 		//if weekcount is not 20 then create other weekcounts
	// 		if (weekCount != 20){
	// 			System.debug('weekCount ' + weekCount);
	// 			//get prior weeks details
	// 			String priorkey = key;
	// 			Integer priorTotalToDate = evtRegWrapperMap.containsKey(priorkey) ? evtRegWrapperMap.get(priorkey).totalToDate - evtRegWrapperMap.get(priorkey).newReg : overAllMemberCount;
	// 			// Integer priorTotalToDate  = overAllMemberCount - weeksTotalToDate ;
	// 			System.debug('priorTotalToDate ' + priorTotalToDate);

	// 			//Iterate and create the weeks for the table
	// 			for (Integer i = weekCount + 1; i <= 20; i++){
	// 				String newkey = i < 10 ? 
	// 																	  '0' + String.valueOf(i)+' Weeks Out' : String.valueOf(i)+' Weeks Out';
	// 				EventRegistrationWrapper evtRegWrapper = new EventRegistrationWrapper(newkey, 0, priorTotalToDate, 0, 0);
	// 				evtRegWrapperMap.put(newkey, evtRegWrapper);
	// 			}
	// 		}
	
			for (EventRegistrationWrapper evt : evtRegWrapperMap.values()){
				System.debug('bucket--' + evt.bucket + 'newReg---' + evt.newReg + 'totalToDate-----' + evt.totalToDate + 'Revenue----' + evt.Revenue);
			}
		

		return !evtRegWrapperMap.isEmpty() ? JSON.serialize(evtRegWrapperMap.values()) : '';
	}

	//Wrapper Class
	public class EventRegistrationWrapper{
		@AuraEnabled
		public String bucket;
		@AuraEnabled
		public Integer newReg;
		@AuraEnabled
		public Integer totalToDate;
		@AuraEnabled
		public Decimal revenue;
		@AuraEnabled
		public Decimal individualWeekRevenue;
		//Constructor
		public EventRegistrationWrapper(){
		}

		public EventRegistrationWrapper(String bucket, Integer newReg, Integer totalToDate, Decimal revenue, Decimal revenueAmount){
			this.bucket = bucket;
			this.newReg = newReg;
			this.totalToDate = totalToDate;
			this.revenue = revenue;
			this.individualWeekRevenue = revenueAmount;
		}
	}

	private static String getSpace(){
		String space = '--------------------------';
		return space;
	}
}