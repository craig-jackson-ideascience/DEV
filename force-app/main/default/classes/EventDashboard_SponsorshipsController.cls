/***
 ** Created by Cloudroute Solutions on 30-03-2021
 ** Controller for EventDashboard_SponsorshipsLC
 ** Test class EvtDashboardSponsorshipControllerTest
 ***/
public with sharing class EventDashboard_SponsorshipsController{
	/* get picklist event names */
	@AuraEnabled
	public static List<Event__c> getLastSevenDaysEvents(){
		try{
			List<Event__c> listOfEvents = [SELECT Id, Name
			                               FROM Event__c
			                               WHERE Start_Date__c >= Last_N_Days:7 AND Event_Registrations__c != 0
			                               ORDER BY Name];
			return listOfEvents;
		} catch (Exception e){
			System.debug('#--Exception at--#' + e.getLineNumber()+' ' + e.getMessage());
			return null;
		}
	}

	/* to get current week and last week number */
	@AuraEnabled
	public static Map<String, String> getWeekNumbers(){
		try{
			Map<String, String> yearWeek = getListOfWeekNumbers();
			return yearWeek;
		} catch (Exception e){
			System.debug('#--Exception at--#' + e.getLineNumber()+' ' + e.getMessage());
			return null;
		}
	}

	/* get active sponsored events */
	@AuraEnabled
	public static List<EventWrapper> getActiveSponsoredEvents(List<String> listOfSelectedEvents){
		try{
			System.debug('#--listOfSelectedEvents--#' + listOfSelectedEvents);
			Set<Id> setOfEventId = new Set<Id>();
			String eventsQuery = 'SELECT Id, Name, Revenue_Goal__c FROM Event__c WHERE Status__c = \'Active\'';
			String assetsQuery = 'SELECT Price, Event__c, Event__r.name, PurchaseDate, Opportunity__r.CloseDate FROM Asset WHERE Event__c != null AND Event__r.Status__c = \'Active\' AND Event__r.Event_Registrations__c > 0 AND Opportunity__r.IsWon = true';
			if (!listOfSelectedEvents.isEmpty()){
				eventsQuery += ' AND Name IN :listOfSelectedEvents';
				assetsQuery += ' AND Event__r.Name IN :listOfSelectedEvents';
			}
			List<Asset> listOfAssets = Database.query(assetsQuery);
			for (Asset asset : listOfAssets){
				setOfEventId.add(asset.Event__c);
			}
			eventsQuery += ' AND Id IN :setOfEventId ORDER BY Name';
			List<Event__c> listOfEvents = Database.query(eventsQuery);
			System.debug('#--size--#' + listOfEvents.size());
			List<EventWrapper> listOfEventWrapper = getPreparedEventWrapper(listOfEvents, listOfAssets);
			return listOfEventWrapper;
		} catch (Exception e){
			System.debug('#--Exception at--#' + e.getLineNumber()+' ' + e.getMessage());
			return null;
		}
	}

	private static List<EventWrapper> getPreparedEventWrapper(List<Event__c> listOfEvents, List<Asset> listOfAssets){
		Date endDateOfPreviousWeek = System.today().toStartOfWeek().addDays(-2);
		Integer currentWeekNumber = Integer.valueOf(System.now().format('w'));
		Integer previousWeekNumber = Integer.valueOf(((Datetime)endDateOfPreviousWeek).format('w'));
		List<String> yearWeek = new List<String>{endDateOfPreviousWeek.year()+'' + previousWeekNumber, system.now().year()+'' + currentWeekNumber};
		System.debug('#--previousWeekNumber--#' + previousWeekNumber);
		System.debug('#--currentWeekNumber--#' + currentWeekNumber);
		List<EventWrapper> listOfEventWrapper = new List<EventWrapper>();
		Map<String, Event__c> mapOfNameVsEvent = new Map<String, Event__c>();
		Map<String, Map<String, Double>> mapOfNameVsDateVsRevenue = new Map<String, Map<String, Double>>();
		for (Event__c event : listOfEvents){
			mapOfNameVsEvent.put(event.name, event);
		}
		for (Asset asset : listOfAssets){
			String eventName = String.valueOf(asset.Event__r.Name);
			Double eventRevenue = 0;
			if (!mapOfNameVsDateVsRevenue.containsKey(eventName)){
				Map<String, Double> innerMap = new Map<String, Double>();
				innerMap.put(yearWeek[0], 0);
				innerMap.put(yearWeek[1], 0);
				mapOfNameVsDateVsRevenue.put(eventName, innerMap);
			}

			String opportunityCloseDate = asset.Opportunity__r.CloseDate.year()+'' + Integer.valueOf(((Datetime)asset.Opportunity__r.CloseDate).format('w'));
			if (Integer.valueOf(opportunityCloseDate) <= Integer.valueOf(yearWeek[0])){
				eventRevenue = mapOfNameVsDateVsRevenue.get(eventName).get(yearWeek[0]);
				mapOfNameVsDateVsRevenue.get(eventName).put(yearWeek[0], eventRevenue + asset.Price);
				eventRevenue = mapOfNameVsDateVsRevenue.get(eventName).get(yearWeek[1]);
				mapOfNameVsDateVsRevenue.get(eventName).put(yearWeek[1], eventRevenue + asset.Price);
			} else{
				eventRevenue = mapOfNameVsDateVsRevenue.get(eventName).get(yearWeek[1]);
				mapOfNameVsDateVsRevenue.get(eventName).put(yearWeek[1], eventRevenue + asset.Price);
			}
		}

		System.debug('#--mapOfNameVsDateVsRevenue--#' + mapOfNameVsDateVsRevenue);
		for (String name : mapOfNameVsDateVsRevenue.keySet()){
			EventWrapper eventWrap = new EventWrapper();
			eventWrap.eventName = name;
			for (String dateVar : mapOfNameVsDateVsRevenue.get(name).keySet()){
				Double eventRevenue = mapOfNameVsDateVsRevenue.get(name).get(dateVar);
				Double revenueGoal = 0;
				if (mapOfNameVsEvent.containsKey(name)){
					if (mapOfNameVsEvent.get(name).Revenue_Goal__c != null){
						revenueGoal = mapOfNameVsEvent.get(name).Revenue_Goal__c;
					}
					eventWrap.eventId = mapOfNameVsEvent.get(name).Id;
				}
				if (Integer.valueOf(Integer.valueOf(dateVar)) <= Integer.valueOf(yearWeek[0])){
					eventWrap.revenue1 = revenueGoal - eventRevenue;
				} else{
					eventWrap.revenue2 = revenueGoal - eventRevenue;
				}
			}
			listOfEventWrapper.add(eventWrap);
		}
		return listOfEventWrapper;
	}

	private static Map<String, String> getListOfWeekNumbers(){
		Date endDateOfPreviousWeek = System.today().toStartOfWeek().addDays(-2);
		Integer currentWeekNumber = Integer.valueOf(System.now().format('w'));
		Integer previousWeekNumber = Integer.valueOf(((Datetime)endDateOfPreviousWeek).format('w'));
		Map<String, String> yearWeek = new Map<String, String>{endDateOfPreviousWeek.year()+'' + previousWeekNumber => String.valueOf(System.today()), System.now().year()+'' + currentWeekNumber => String.valueOf(endDateOfPreviousWeek)};
		return yearWeek;
	}

	public class EventWrapper{
		@AuraEnabled
		public String eventId{ get; set; }

		@AuraEnabled
		public String eventName{ get; set; }

		@AuraEnabled
		public Double revenue1{ get; set; }

		@AuraEnabled
		public Double revenue2{ get; set; }
	}
}