/***
 ** Created by Cloudroute Solutions on 05-04-2021
 ** Controller for CNCF_DashboardLC
 ** CNCF_DashboardLC is used to display all events where Bill From Project is CNCF of current fiscal year
 @author Cloudroute Solutions
 ***/
public with sharing class CNCF_DashboardController{
	/***
	 ** This method returns list of CNCF Wrapper in String format
	 ** CNCF Wrapper contains eventName, stageName, totalValue, reportLink that needs to be displayed for each chart
	 */
	@AuraEnabled
	public static String getAllCNCFEvents(){
		try{
			Map<String, Event__c> mapOfNameVsEvent = new Map<String, Event__c>();
			/* query all events of current fiscal year against CNCF project */
			List<Event__c> listOfEvent = [SELECT Id, Name, Revenue_Goal__c
			                              FROM Event__c
			                              WHERE BillFromProject__r.Slug__c = 'cncf' AND Start_Date__c = THIS_FISCAL_YEAR];
			for (Event__c event : listOfEvent){
				mapOfNameVsEvent.put(event.name, event);
			}

			/* query opportunity line items in the current fiscal year events agains CNCF project */
			List<OpportunityLineItem> listOfOLI = [SELECT TotalPrice, Opportunity.StageName, Event__r.Name, Event__r.Revenue_Goal__c
			                                       FROM OpportunityLineItem
			                                       WHERE Event__r.Name IN :mapOfNameVsEvent.keySet()
			                                       ORDER BY Opportunity.StageName DESC];
System.debug('#--listOfOli--#' + listOfOLI);
			List<CNCFWrapper> cncfWrapperList = prepareWrapper(listOfOLI, mapOfNameVsEvent);
			System.debug('#--cncfWrapperList--#' + cncfWrapperList);
			return JSON.serialize(cncfWrapperList);
		} catch (Exception e){
			System.debug('#--Exception At--#' + e.getLineNumber()+' ' + e.getMessage());
			return null;
		}
	}

	/**
	 * prepareWrapper This method prepares wrapper given the list of opportunity line items and map of events
	 *
	 * @param listOfOLI (List<OpportunityLineItem>): listOfOLI
	 * @param mapOfNameVsEvent (Map<String, Event__c>): mapOfNameVsEvent
	 * @@ Return List<CNCFWrapper>: This is returned wrapper which will be displayed as a chart
	 */
	private static List<CNCFWrapper> prepareWrapper(List<OpportunityLineItem> listOfOLI, Map<String, Event__c> mapOfNameVsEvent){
		Map<String, Map<String, Double>> eventNameVsStageVsPrice = new Map<String, Map<String, Double>>();
		Map<String, Double> tooltipMap = new Map<String, Double>();
		Map<String, Double> mapOfEventVsTotal = new Map<String, Double>();
		Map<String, String> mapOfStageVsColor = getPreparedStageColorMap();
		List<CNCFWrapper> cncfWrapperList = new List<CNCFWrapper>();
		for (OpportunityLineItem oli : listOfOLI){
			String eventName = oli.Event__r.Name;
			String stageName = oli.Opportunity.StageName;
			Double totalPrice = 0;
			Double totalOfAllStage = 0;
			if (!eventNameVsStageVsPrice.containsKey(eventName)){
				eventNameVsStageVsPrice.put(eventName, new Map<String, Double>());
			}
			if (!eventNameVsStageVsPrice.get(eventName).containsKey(stageName)){
				eventNameVsStageVsPrice.get(eventName).put(stageName, 0);
			}
			totalPrice = eventNameVsStageVsPrice.get(eventName).get(stageName)+oli.TotalPrice;
			eventNameVsStageVsPrice.get(eventName).put(stageName, totalPrice);
			if (!mapOfEventVsTotal.containsKey(eventName)){
				mapOfEventVsTotal.put(eventName, 0);
			}
			totalOfAllStage = mapOfEventVsTotal.get(eventName)+oli.TotalPrice;
			mapOfEventVsTotal.put(eventName, totalOfAllStage);
		}
		for (String eventName : eventNameVsStageVsPrice.keySet()){
			CNCFWrapper cncfWrapper = new CNCFWrapper();
			FunnelChart funnelChart = new FunnelChart();
			cncfWrapper.eventName = eventName;
			funnelChart.eventName = eventName;
			List<String> listOfStageName = new List<String>();
			List<Double> listOfTotalPrice = new List<Double>();
			List<String> listOfColor = new List<String>();
			Double revenueGoal = 0;
			if (mapOfNameVsEvent.containsKey(eventName)){
				if (mapOfNameVsEvent.get(eventName).Revenue_Goal__c != null){
					revenueGoal = mapOfNameVsEvent.get(eventName).Revenue_Goal__c;
				}
				cncfWrapper.revenueGoal = revenueGoal;
				cncfWrapper.reportLink = Label.CNCF_Report_Link + mapOfNameVsEvent.get(eventName).Id;
			}
			List<StageValue> listOfStageValue = new List<StageValue>();
			for (String stageName : eventNameVsStageVsPrice.get(eventName).keySet()){
				Double totalPrice = eventNameVsStageVsPrice.get(eventName).get(stageName);
				String stageColor = mapOfStageVsColor.containsKey(stageName) ? mapOfStageVsColor.get(stageName) : '#36A2EB';
				StageValue stageValue = new StageValue();
				stageValue.stageName = stageName;
				stageValue.totalPrice = totalPrice;
				stageValue.stageColor = stageColor;
				listOfStageValue.add(stageValue);
				if (stageName == 'Closed Won'){
					Double percentGoal = revenueGoal != 0 ? Math.ceil((totalPrice / revenueGoal) * 100) : 0;
					cncfWrapper.percentOfGoal = percentGoal;
				}
				if (mapOfEventVsTotal.containsKey(eventName)){
					Double totalOfAllStage = mapOfEventVsTotal.get(eventName) != null && mapOfEventVsTotal.get(eventName) != 0 ? mapOfEventVsTotal.get(eventName) : 1;
					tooltipMap.put(stageName, (totalPrice / totalOfAllStage) * 100);
				}
				listOfColor.add(stageColor);
				listOfStageName.add(stageName);
				listOfTotalPrice.add(totalPrice);
			}
			funnelChart.listOfStageName = listOfStageName;
			funnelChart.listOfTotalPrice = listOfTotalPrice;
			funnelChart.tooltipMap = tooltipMap;
			funnelChart.mapOfEventVsTotal = mapOfEventVsTotal;
			funnelChart.listOfColor = listOfColor;
			cncfWrapper.StageValue = listOfStageValue;
			cncfWrapper.chart = JSON.serialize(funnelChart);
			cncfWrapperList.add(cncfWrapper);
		}
		return cncfWrapperList;
	}

	/**
	 * getPreparedStageColorMap get color of each stage stored in metadata
	 * ## Return Map<String, String>: map of Stage vs its color
	 *
	 */
	private static Map<String, String> getPreparedStageColorMap(){
		List<Opportunity_Stage_Color__mdt> listOfStageColor = [SELECT Label, Color__c
		                                                       FROM Opportunity_Stage_Color__mdt];
		Map<String, String> mapOfStageVsColor = new Map<String, String>();
		for (Opportunity_Stage_Color__mdt item : listOfStageColor){
			mapOfStageVsColor.put(item.Label, item.Color__c);
		}
		return mapOfStageVsColor;
	}

	/***
	 ** Wrapper Class for CNCF
	 **This wrapper class is used for mapping opportunity line items value to chart
	 */
	public class CNCFWrapper{
		@AuraEnabled
		public String eventName{ get; set; }

		@AuraEnabled
		public Decimal percentOfGoal{ get; set; }

		@AuraEnabled
		public Decimal revenueGoal{ get; set; }

		@AuraEnabled
		public List<StageValue> StageValue{ get; set; }

		@AuraEnabled
		public String reportLink{ get; set; }

		@AuraEnabled
		public String chart{ get; set; }

		@AuraEnabled
		public String selectedStage{ get; set; }
	}

	/***
	 ** Wrapper Class for Stage-Value
	 **Used to show stage value and its total price value of opportunity line item
	 */
	public class StageValue{
		@AuraEnabled
		public String stageName{ get; set; }

		@AuraEnabled
		public Double totalPrice{ get; set; }

		@AuraEnabled
		public String stageColor{ get; set; }
	}

	/***
	 ** Wrapper Class for Funnel Chart
	 **Used to display chart and tooltip of the chart
	 */
	public class FunnelChart{
		@AuraEnabled
		public String eventName{ get; set; }

		@AuraEnabled
		public List<String> listOfStageName{ get; set; }

		@AuraEnabled
		public List<String> listOfColor{ get; set; }

		@AuraEnabled
		public List<Double> listOfTotalPrice{ get; set; }

		@AuraEnabled
		public Map<String, Double> tooltipMap{ get; set; }

		@AuraEnabled
		public Map<String, Double> mapOfEventVsTotal{ get; set; }
	}
}