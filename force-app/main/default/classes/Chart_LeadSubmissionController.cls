/**
 * Created by cloudroutesolutions on 04/02/21.
 * Test class Chart_LeadSubmissionControllerTest
 * Controller for Chart_LeadSubmission
 */
public without sharing class Chart_LeadSubmissionController{
	@AuraEnabled
	public static Project__c getSelectedProjectDetails(String foundationId){
		system.debug('foundationId=> ' + foundationId);
		return [Select Id, Name
		        from Project__c
		        where Id = :foundationId];
	}

	/* method for lead chart */
	@AuraEnabled
	public static String getLeadDetails(String foundationId, List<String> selectedSource, String selectedDateFilter, String selectedDateVariable, List<String> selectedDates){
		System.debug('#--selectedSource--#' + selectedSource);
		System.debug('#--selectedDateFilter--#' + selectedDateFilter);
		System.debug('#--selectedDateVariable--#' + selectedDateVariable);
		System.debug('#--selectedDates--#' + selectedDates);
		String sSoql;
		try{
			List<String> listOfLabel = new List<String>();
			Set<String> setOfLabel = new Set<String>();
			Map<String, Map<String, Decimal>> dataSetMap = new Map<String, Map<String, Decimal>>();
			Map<String, Set<Integer>> mapOfStatusVsMonths = new Map<String, Set<Integer>>();
			Map<String, Decimal> mapOfMonthVsCounts = new Map<String, Decimal>();
			Map<String, Double> listOfPercentData = new Map<String, Double>();
			Map<String, Decimal> mapOfXLabelVsStack = new Map<String, Decimal>();
			List<Id> leadIds = new List<Id>();
			String whereClause = selectedSource == null || selectedSource.isEmpty() ? '' : selectedSource[0] != 'All' && selectedSource[0] != '' ? ' AND LeadSource IN : selectedSource' : '';
			whereClause += getPreparedWhereClause(whereClause, selectedDateVariable, selectedDates);
			String query = 'SELECT Id, LeadId, Lead.CreatedDate, Lead.Status FROM CampaignMember WHERE Campaign.Project__c = :foundationId AND LeadId != null AND Lead.IsConverted = false ' + whereClause + ' ORDER BY Lead.CreatedDate ASC NULLS LAST LIMIT 48000';
			System.debug('query: ' + query);
			List<CampaignMember> members = Database.query(query);
			System.debug('#----#' + members.size());
			prepareMapsForChart(members, dataSetMap, mapOfMonthVsCounts, mapOfStatusVsMonths);
			System.debug('#--dataSetMap--#' + dataSetMap);
			List<ChartjsData.chartjsDataset> listOfChartJsData = new List<ChartjsData.chartjsDataset>();
			Integer i = 0;
			Integer loopVar = 0;
			Integer sumOfMonthlyLead = 0;
			prepareChart(dataSetMap, listOfChartJsData, mapOfMonthVsCounts, mapOfStatusVsMonths, listOfPercentData, mapOfXLabelVsStack, setOfLabel);
			System.debug('#--listOfPercentData--#' + listOfPercentData);
			listOfLabel.addAll(setOfLabel);
			ChartjsData chartjsData = new ChartjsData();
			chartjsData.labels = listOfLabel;//[24thJune,25thJune]
			chartjsData.dataSets = listOfChartJsData;//new List<ChartjsData.chartjsDataset>{dataset};
			if (members.size() > 45000){
				chartjsData.message = 'Large number of records, please use';
				Project__c prj = [Select Id, Name
				                  from Project__c
				                  where Id = :foundationId];
				String url = Label.Lead_Report_Link + prj.Name;
				chartjsData.reportLink = url;

			}
			/* dataSet.showCustomValue = false;
			 dataSet.stepSize = 10; */
			System.debug('#chart#' + JSON.serialize(chartjsData));
			return JSON.serialize(chartjsData);
		} catch (Exception ex){
			System.debug('Exception---: ' + ex.getMessage()+'==AT==' + ex.getLineNumber());
			return null;
		}
	}

	/* method for lead table */
	@AuraEnabled
	public static ReturnLeadWrapper getLeadTableDetails(String foundationId, List<String> selectedSource, String selectedMonth, String selectedDateVariable, List<String> selectedDates, String createdDate, String leadSource, String operator, Boolean applyLimit, Boolean isList){
		System.debug('#--createdDate--#' + createdDate);
		System.debug('#--selectedSource--#' + selectedSource);
		System.debug('#--selectedMonth--#' + selectedMonth);
		System.debug('#--selectedDateVariable--#' + selectedDateVariable);
		System.debug('#--selectedDateVariable--#' + selectedDates);
		System.debug('#--createdDate--#' + createdDate);
		System.debug('#--leadSource--#' + leadSource);
		System.debug('#--operator--#' + operator);
		System.debug('#--isList--#' + isList);
		list<Lead> leadList = new list<Lead>();
		String sSoql;
		String whereClauseSource = 'AND (';
		List<Id> leadIds = new List<Id>();
		String whereClause = selectedSource == null || selectedSource.isEmpty() ? '' : selectedSource[0] != 'All' && selectedSource[0] != '' ? ' AND LeadSource IN : selectedSource' : '';
		whereClause += getPreparedWhereClause(whereClause, selectedDateVariable, selectedDates);
		//whereClause += selectedMonth != '' ? 'LeadSource =: selectedSource';
		String currentMonth = selectedMonth != null ? (String)JSON.deserializeUntyped(selectedMonth) : '';
		System.debug('#--currentMonth--#' + currentMonth);
		String orderByField = currentMonth == null ? ' Lead.LeadSource DESC ' : ' Lead.CreatedDate ASC ';
		if (isList){
			List<Object> listOfLeadSource = (List<Object>)JSON.deserializeUntyped(leadSource);
			System.debug('#--listOfLeadSource--#' + listOfLeadSource);

			for (Integer i = 0; i < listOfLeadSource.size(); i++){
				if (String.valueOf(listOfLeadSource[i]) != 'All'){
					whereClauseSource += '\'{' + listOfLeadSource[i]+'}\'';
					if (i != listOfLeadSource.size()-1){
						whereClauseSource += ' OR ';
					}
				} else{
					whereClauseSource = '(';
					break;
				}
				system.debug('whereClauseSource--' + whereClauseSource);
			}
			whereClauseSource += ')';

		} else{
			whereClauseSource = '';
		}
		String queryFields = ' Id, LeadId, Lead.CreatedDate, Lead.Name, Lead.LeadSource, Lead.OwnerId, Lead.Owner.Name, Lead.Status ';
		String query = 'SELECT ' + queryFields + ' FROM CampaignMember WHERE Campaign.Project__c = :foundationId ANd LeadId != null AND Lead.IsConverted = false ' + whereClause;

		String countRecordQuery = 'SELECT COUNT(Id) recordCount ' + ' FROM CampaignMember WHERE Campaign.Project__c = :foundationId ANd LeadId != null AND Lead.IsConverted = false ' + whereClause;

		if (String.isNotEmpty(currentMonth)){
			Integer month = getIntegerMonthFromString(currentMonth);
			query += ' AND CALENDAR_MONTH(Lead.CreatedDate) =: month';
			countRecordQuery += ' AND CALENDAR_MONTH(Lead.CreatedDate) =: month';
		}
		if (applyLimit){
			query += ' ORDER BY LeadSource Desc LIMIT 10';
		} else{
			query += ' ORDER BY ' + orderByField + ' NULLS LAST LIMIT 1000';
		}
		System.debug('query: ' + query);
		System.debug('countRecordQuery: ' + countRecordQuery);
		Integer recordCount = (Integer)Database.query(countRecordQuery)[0].get('recordCount');
		System.debug('countRecordQuery: ' + recordCount);
		List<CampaignMember> members = Database.query(query);
		System.debug('#--whereClauseDays--#' + whereClauseSource);
		System.debug('#--operator--#' + operator);
		try{
			List<LeadWrapper> leadWrapList = new List<LeadWrapper>();
			for (CampaignMember mem : members){
				LeadWrapper leadWrap = new LeadWrapper();
				leadWrap.lead = mem.Lead;
				leadWrap.totalDays = String.valueOf((Date.valueOf(mem.Lead.CreatedDate).daysBetween(System.today())));
				leadWrapList.add(leadWrap);
			}
			ReturnLeadWrapper returnWrapper = new ReturnLeadWrapper();
			if (recordCount > 10000){
				returnWrapper.message = 'Large number of records, please use';
				Project__c prj = [Select Id, Name
				                  from Project__c
				                  where Id = :foundationId];
				String url = Label.Lead_Report_Link + prj.Name;
				returnWrapper.reportLink = url;
			}
			returnWrapper.leadWrapper = leadWrapList;
			System.debug('#--returnWrapper--#' + returnWrapper);
			return returnWrapper;
		} catch (Exception ex){
			System.debug('Exception---: ' + ex.getMessage()+'==AT==' + ex.getLineNumber());
			return null;
		}
	}

	private static String getPreparedWhereClause(String whereClause, String selectedDateVariable, List<String> selectedDates){
		if (String.isNotBlank(selectedDateVariable) && !selectedDates.isEmpty()){
			String appendTime = 'T00:00:00Z';
			switch on selectedDateVariable{
				when 'between'{
					String toDate = selectedDates[0]+appendTime;
					String fromDate = selectedDates[1]+appendTime;
					whereClause += ' AND Lead.CreatedDate <= ' + toDate + ' AND Lead.CreatedDate >= ' + fromDate;
				}
				when 'lessThanEqual'{
					String toDate = selectedDates[0]+appendTime;
					whereClause += ' AND Lead.CreatedDate <= ' + toDate;
				}
				when 'greaterThanEqual'{
					String fromDate = selectedDates[0]+appendTime;
					whereClause += ' AND Lead.CreatedDate >= ' + fromDate;
				}
				when 'equalLessThan'{
					String literal = selectedDates[0].substringBefore('_Plus_To_Date');
					System.debug('#--literal--#' + literal);
					if (literal.contains('Fiscal_Quarter')){
						whereClause += literal.contains('THIS') ? ' AND Lead.CreatedDate = ' + literal + ' AND Lead.CreatedDate <= TODAY' : ' AND (Lead.CreatedDate = ' + literal + ' OR Lead.CreatedDate = THIS_FISCAL_QUARTER)';
					} else if (literal.contains('Fiscal_Year')){
						whereClause += literal.contains('THIS') ? ' AND Lead.CreatedDate = ' + literal + ' AND Lead.CreatedDate <= TODAY' : ' AND (Lead.CreatedDate = ' + literal + ' OR Lead.CreatedDate = THIS_FISCAL_YEAR)';
					} else if (literal.contains('Year')){
						whereClause += literal.contains('THIS') ? ' AND Lead.CreatedDate = ' + literal + ' AND Lead.CreatedDate <= TODAY' : ' AND (Lead.CreatedDate = ' + literal + ' OR Lead.CreatedDate = THIS_YEAR)';
					} else if (literal.contains('Quarter')){
						whereClause += literal.contains('THIS') ? ' AND Lead.CreatedDate = ' + literal + ' AND Lead.CreatedDate <= TODAY' : ' AND (Lead.CreatedDate = ' + literal + ' OR Lead.CreatedDate = THIS_QUARTER)';
					} else if (literal.contains('Month')){
						whereClause += literal.contains('THIS') ? ' AND Lead.CreatedDate = ' + literal + ' AND Lead.CreatedDate <= TODAY' : ' AND (Lead.CreatedDate = ' + literal + ' OR Lead.CreatedDate = THIS_MONTH)';
					}
				}
				when 'equal'{
					if (selectedDates.size() == 1){
						whereClause += ' AND Lead.CreatedDate = ' + selectedDates[0];
					} else{
						whereClause += ' AND (';
						String whereClause1 = '';
						for (String str : selectedDates){
							whereClause1 += ' Lead.CreatedDate = ' + str + ' OR';
						}
						whereClause1 = whereClause1.removeEnd('OR');
						whereClause1 += ' )';
						whereClause += whereClause1;
					}
				}
			}
		} else{
			whereClause += ' AND Lead.CreatedDate = LAST_N_DAYS:7';
		}
		return whereClause;
	}

	private static void prepareMapsForChart(List<CampaignMember> members, Map<String, Map<String, Decimal>> dataSetMap, Map<String, Decimal> mapOfMonthVsCounts, Map<String, Set<Integer>> mapOfStatusVsMonths){
		for (CampaignMember member : members){
			Decimal countByStatusVsMonth = 0;
			Decimal countByMonthVsStatus = 0;
			Decimal monthVsCount = 0;
			if (!dataSetMap.containsKey(member.Lead.Status)){
				dataSetMap.put(member.Lead.Status, new Map<String, Decimal>());
			}
			if (!dataSetMap.get(member.Lead.Status).containsKey(String.valueOf(member.Lead.CreatedDate.month()))){
				dataSetMap.get(member.Lead.Status).put(String.valueOf(member.Lead.CreatedDate.month()), 0);
			}
			countByStatusVsMonth = dataSetMap.get(member.Lead.Status).get(String.valueOf(member.Lead.CreatedDate.month()));
			dataSetMap.get(member.Lead.Status).put(String.valueOf(member.Lead.CreatedDate.month()), countByStatusVsMonth + 1);
			if (!mapOfMonthVsCounts.containsKey(String.valueOf(member.Lead.CreatedDate.month()))){
				mapOfMonthVsCounts.put(String.valueOf(member.Lead.CreatedDate.month()), 0);
			}
			monthVsCount = mapOfMonthVsCounts.get(String.valueOf(member.Lead.CreatedDate.month()));
			mapOfMonthVsCounts.put(String.valueOf(member.Lead.CreatedDate.month()), monthVsCount + 1);

			if (!mapOfStatusVsMonths.containsKey(member.Lead.Status)){
				mapOfStatusVsMonths.put(member.Lead.Status, new Set<Integer>{});
			}
			mapOfStatusVsMonths.get(member.Lead.Status).add(member.Lead.CreatedDate.month());
		}
	}

	private static void prepareChart(Map<String, Map<String, Decimal>> dataSetMap, List<ChartjsData.chartjsDataset> listOfChartJsData, Map<String, Decimal> mapOfMonthVsCounts, Map<String, Set<Integer>> mapOfStatusVsMonths, Map<String, Double> listOfPercentData, Map<String, Decimal> mapOfXLabelVsStack, Set<String> setOfLabel){
		Integer i = 0;
		for (String status : dataSetMap.keySet()){
			List<Decimal> listOfStatusData = new List<Decimal>();
			for (String month : dataSetMap.get(status).keySet()){
				Integer integerMonth = Integer.valueOf(month);
				Decimal dataValue = dataSetMap.get(status).get(month);
				System.debug('#--dataValue--#' + dataValue);
				System.debug('#--listOfStatusData--#' + listOfStatusData);
				System.debug('#--mapOfMonthVsCounts--#' + mapOfMonthVsCounts);
				setOfLabel.add(getMonth(Integer.valueOf(month)));
				if (mapOfMonthVsCounts.containsKey(month)){
					Decimal total = mapOfMonthVsCounts.get(month);
					Double result = (dataValue / total) * 100;
					listOfPercentData.put(getMonth(integerMonth)+'-' + status, result);
					mapOfXLabelVsStack.put(getMonth(integerMonth), total);
					System.debug('#--mapOfMonthVsCounts.keySet().size()--#' + mapOfMonthVsCounts.keySet().size());
					if (mapOfStatusVsMonths.containsKey(status) && mapOfStatusVsMonths.get(status).contains(integerMonth)){
						listOfStatusData.add(dataValue);
					} else{
						listOfStatusData.add(0);
					}
				}
			}
			System.debug('#--listOfStatusData--#' + listOfStatusData);
			ChartjsData.chartjsDataset dataSet = new ChartjsData.chartjsDataset();
			dataSet.label = status;
			dataSet.dataInPercent = listOfStatusData;//[63,73]
			if (i == 0){
				dataSet.pointHighlightFill = '#52b7d8';
			} else if (i == 1){
				dataSet.pointHighlightFill = '#4fd2d2';
			} else if (i == 2){
				dataSet.pointHighlightFill = '#e16032';
			} else if (i == 3){
				dataSet.pointHighlightFill = '#e287b2';
			} else{
				dataSet.pointHighlightFill = '#52b7d8';
			}
			dataSet.showCustomValue = true;
			dataSet.stepSize = 10;
			dataSet.listOfPercentData = listOfPercentData;
			dataSet.mapOfXLabelVsStack = mapOfXLabelVsStack;
			listOfChartJsData.add(dataSet);
			i++;

		}
	}

	private static Integer getIntegerMonthFromString(String month){
		Map<String, Integer> monthIntVsString = new Map<String, Integer>{'january' => 1, 'february' => 2, 'march' => 3, 'april' => 4, 'may' => 5, 'june' => 6, 'july' => 7, 'august' => 8, 'september' => 9, 'october' => 10, 'november' => 11, 'december' => 12};
		return monthIntVsString.get(month.toLowerCase());
	}

	private static String getMonth(Integer month){
		Map<Integer, String> monthString = new Map<Integer, String>{1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April', 5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August', 9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December'};
		return monthString.get(month);
	}

	public class ReturnLeadWrapper{
		@AuraEnabled
		public List<LeadWrapper> leadWrapper;

		@AuraEnabled
		public String message{ get; set; }

		@AuraEnabled
		public String reportLink{ get; set; }
	}

	public class LeadWrapper{
		@AuraEnabled
		public String totalDays{ get; set; }

		@AuraEnabled
		public Lead lead{ get; set; }
	}
}