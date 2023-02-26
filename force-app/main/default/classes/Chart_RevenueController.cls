/***
 ** Created by Cloudroute Solutions on 01-03-2021
 ** Controller for Chart_RevenueLC
 ** Test class Chart_RevenueControllerTest
 ***/
public without sharing class Chart_RevenueController{
	/* method do show Revenue chart */
	@AuraEnabled
	public static String getFilteredChartData(String projectId, String selectedDateVariable, List<String> selectedDates, String listOfPurchaseTypesString, String selectedMonth, Boolean isMonthly){
		try{
			System.debug('#--projectId--#' + projectId);
			System.debug('#--selectedDateVariable--#' + selectedDateVariable);
			System.debug('#--selectedDates--#' + selectedDates);
			System.debug('#--listOfPurchaseTypes--#' + listOfPurchaseTypesString);
			System.debug('#--isMonthly--#' + isMonthly);
			Map<String, Map<String, Decimal>> dataSetMap = new Map<String, Map<String, Decimal>>();
			Map<String, Decimal> lfSilverMpsfMap = new Map<String, Decimal>();
			Set<String> setOfMonth = new Set<String>();
			Set<String> setOfYear = new Set<String>();
			Map<String, Set<String>> mapOfProdNameVsMonths = new Map<String, Set<String>>();
			Map<String, Decimal> mapOfMonthVsCounts = new Map<String, Decimal>();
			List<AggregateResult> lfSilverMemberMpsfSum = new List<AggregateResult>();
			List<Asset> listOfPurchaseHist = getListOfAssets(projectId, selectedDateVariable, selectedDates, listOfPurchaseTypesString, '', '', lfSilverMemberMpsfSum, false, isMonthly, null);
			prepareMapForAggregatePurchaseHist(lfSilverMemberMpsfSum, lfSilverMpsfMap, isMonthly);
			prepareMapsForChart(listOfPurchaseHist, dataSetMap, mapOfProdNameVsMonths, setOfMonth, setOfYear, mapOfMonthVsCounts, isMonthly);
			System.debug('#--mapOfProdNameVsMonths--#' + mapOfProdNameVsMonths);
			for (String month : lfSilverMpsfMap.keySet()){
				if (dataSetMap.containsKey('Silver Membership') && dataSetMap.get('Silver Membership').containsKey(month)){
					Decimal total = dataSetMap.get('Silver Membership').get(month);
					total += lfSilverMpsfMap.get(month);
					dataSetMap.get('Silver Membership').put(month, total);
				}
			}
			Map<String, Map<String, Set<Id>>> activeMembersMap = getPreparedActiveMembersMap(projectId, isMonthly);
			ChartjsData chartjsData = getPreparedChart(dataSetMap, setOfMonth, mapOfProdNameVsMonths, mapOfMonthVsCounts, isMonthly, selectedDates, activeMembersMap);
			System.debug('#chart#' + JSON.serialize(chartjsData));
			return JSON.serialize(chartjsData);

		} catch (Exception e){
			System.debug('#---Exception---#' + e.getMessage()+e.getLineNumber());
			return null;
		}
	}

	/* to get total active members against selected project */
	@AuraEnabled
	public static Integer getActiveMembers(String projectId){
		try{
			Id corporateId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
			List<AggregateResult> listOfAsset = [SELECT count(AccountId) countId
			                                     FROM Asset 
			                                     WHERE Projects__c = :projectId AND AccountId != null AND Product2.Family in ('Membership') AND Status = 'Active' AND RecordTypeId = :corporateId];
			return Integer.valueOf(listOfAsset[0].get('countId'));
		} catch (Exception e){
			System.debug('#--Exception at--#' + e.getLineNumber()+' ' + e.getMessage());
			return null;
		}
	}

	/* method do show Revenue chart table */
	@AuraEnabled
	public static ReturnAssetWrapper getFilteredTableData(String projectId, String selectedDateVariable, List<String> selectedDates, String listOfPurchaseTypesString, String selectedMonth, String selectedProduct, Boolean applyLimit, Boolean isMonthly){
		Map<String, Set<Integer>> mapOfProdNameVsMonths = new Map<String, Set<Integer>>();
		ReturnAssetWrapper returnWrapper = new ReturnAssetWrapper();
		List<AssetWrapper> listOfAssetWrapper = new List<AssetWrapper>();
		List<Integer> totalRecords = new List<Integer>();
		System.debug('#--totalRecords--#' + totalRecords.size());
		List<Asset> listOfPurchaseHist = getListOfAssets(projectId, selectedDateVariable, selectedDates, listOfPurchaseTypesString, selectedMonth, selectedProduct, null, applyLimit, isMonthly, totalRecords);
		System.debug('#--totalRecords--#' + totalRecords.size());
		for (Asset asset : listOfPurchaseHist){
			AssetWrapper wrapper = new AssetWrapper();
			/* if (projectId == Label.The_Linux_Foundation_Project){
			 if (asset.Product2.Name != 'Silver Membership - MPSF'){ */
			wrapper.asset = asset;
			listOfAssetWrapper.add(wrapper);
			/* }
			 } else{
			 wrapper.asset = asset;
			 listOfAssetWrapper.add(wrapper);
			 } */
		}
		returnWrapper.AssetWrapper = listOfAssetWrapper;
		if (totalRecords[0] > 1000){
			returnWrapper.message = 'Large number of records, please use';
			Project__c proj = [SELECT Id, Name
			                   FROM Project__c
			                   WHERE Id = :projectId];
			String url = Label.Revenue_Chart_Report_Link + proj.Name;
			returnWrapper.reportLink = url;
		}
		return returnWrapper;
	}

	@AuraEnabled
	public static List<String> getPurchaseTypes(){
		try{
			List<String> pickListValuesList = new List<String>();
			Schema.DescribeFieldResult fieldResult = Opportunity.Type.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry pickListVal : ple){
				pickListValuesList.add(pickListVal.getLabel());
			}
			return pickListValuesList;
		} catch (Exception e){
			System.debug('#--Exception At--#' + e.getLineNumber()+' ' + e.getMessage());
			return null;
		}
	}
	
    @TestVisible
	private static List<Asset> getListOfAssets(String projectId, String selectedDateVariable, List<String> selectedDates, String listOfPurchaseTypesString, String selectedMonth, String selectedProduct, List<AggregateResult> lfSilverMpsfSum, Boolean applyLimit, Boolean isMonthly, List<Integer> totalRecords){
		String linuxFoundationId = Label.The_Linux_Foundation_Project;
		List<Asset> listOfPurchaseHist = new List<Asset>();
		Map<String, Double> mapName = new Map<String, Double>();
		List<Object> purchaseTypes = new List<Object>();
		List<String> listOfPurchaseTypes = new List<String>();
		Set<String> setOfProdNames = getRequiredProducts();
		Set<String> setOfStatus = getRequiredStatus();
		String silverMpsfFilter = '';
		if (String.isNotEmpty(listOfPurchaseTypesString)){
			purchaseTypes = (List<Object>)JSON.deserializeUntyped(listOfPurchaseTypesString);
		}
		for (Object obj : purchaseTypes){
			listOfPurchaseTypes.add(String.valueOf(obj));
		}
		System.debug('#--listOfPurchaseTypes--#' + listOfPurchaseTypes);
		String soqlQuery = 'SELECT Id, Name, Status, AccountId, InstallDate, Account.Name, Product2.Name, Price FROM Asset WHERE Projects__c = :projectId AND Product2.Family = \'Membership\' ';
		String whereQuery = '';
		whereQuery += ' AND InstallDate != null AND AccountId != NULL AND Status IN :setOfStatus ';
		if (!listOfPurchaseTypes.isEmpty() && listOfPurchaseTypes[0] != 'All'){
			whereQuery += ' AND Opportunity__r.Type IN :listOfPurchaseTypes';
		}
		if (projectId == linuxFoundationId){
			silverMpsfFilter = ' AND Product2.Name != \'Silver Membership - MPSF\'';
		}
		if (String.isNotBlank(selectedMonth) && String.isNotEmpty(selectedMonth)){
			Integer month = 0, year = 0;
			if (isMonthly){
				month = getIntegerMonthFromString(selectedMonth.substring(0, selectedMonth.length()-5));
				year = Integer.valueOf(selectedMonth.right(4));
				whereQuery += ' AND CALENDAR_MONTH(InstallDate) =: month AND CALENDAR_YEAR(InstallDate) =: year';
			} else{
				year = Integer.valueOf(selectedMonth);
				whereQuery += ' AND CALENDAR_YEAR(InstallDate) =: year';
			}
			//getIntegerMonthFromString(selectedMonth);
			System.debug('#--month--#' + month);

		} else{
			whereQuery += getPreparedWhereClause(selectedDateVariable, selectedDates);
		}
		if (String.isNotBlank(selectedProduct)){
			whereQuery += ' AND Product2.Name = :selectedProduct ';
		}
		soqlQuery += silverMpsfFilter + whereQuery;
		soqlQuery += ' ORDER BY InstallDate, Product2.Name';
		if (applyLimit){
			soqlQuery += ' LIMIT 10';
		} else{
			soqlQuery += ' LIMIT 40000';
		}
		System.debug('#--soqlQuery--#' + soqlQuery);
		listOfPurchaseHist = Database.query(soqlQuery);
		System.debug('#--size--#' + listOfPurchaseHist.size());
		if (projectId != linuxFoundationId && lfSilverMpsfSum != null){
			String lfSilverMpsfSumQuery = 'SELECT SUM(Price)total FROM Asset WHERE Product2.Name = \'Silver Membership - MPSF\' and Projects__c = :linuxFoundationId ';
			/* AggregateResult lfSilverMemberMpsfSum = [SELECT SUM(Price)total
			 FROM Asset
			 WHERE Product2.Name = 'Silver Membership - MPSF' and Projects__c = linuxFoundationId AND Status IN ('Active', 'Completed', 'Expired', 'Purchased')
			 LIMIT 1]; */
			lfSilverMpsfSumQuery += whereQuery;
			lfSilverMpsfSumQuery += ' GROUP BY CALENDAR_MONTH(InstallDate), CALENDAR_YEAR(InstallDate) ORDER BY CALENDAR_YEAR(InstallDate), CALENDAR_MONTH(InstallDate) LIMIT 5000';
			lfSilverMpsfSum = Database.query(lfSilverMpsfSumQuery);
            System.debug('#lfSilverMpsfSum== '+lfSilverMpsfSum);
		}
		if (totalRecords != null && totalRecords.isEmpty()){
			String countRecordQuery = 'SELECT COUNT(Id) recordCount FROM Asset WHERE Projects__c = :projectId AND Product2.Family = \'Membership\' ' + silverMpsfFilter + whereQuery;
			Integer recordCount = (Integer)Database.query(countRecordQuery)[0].get('recordCount');
			totalRecords.add(recordCount);
			System.debug('#--totalRecords--#' + totalRecords.size());
		}
		return listOfPurchaseHist;
	}

	private static Map<String, Map<String, Set<Id>>> getPreparedActiveMembersMap(String projectId, Boolean isMonthly){
		String query = '';
		query += ' SELECT Id, Name, Status, AccountId, InstallDate, Account.Name, Product2.Name, Price FROM Asset';
		query += ' WHERE Projects__c = :projectId AND AccountId != null AND Product2.Family in (\'Membership\')';
		query += ' AND Status NOT IN (\'Invoice Cancelled\', \'Associate Cancelled\')';
		query += ' AND ((Status IN (\'Active\', \'Purchased\') AND Asset.Opportunity__r.Type = \'New Business\') OR (Asset.Opportunity__r.Type = \'Renewal\' AND Status IN (\'Active\')))';
		System.debug('#--query--#' + query);
		List<Asset> listOfActiveMembers = Database.query(query);
		Map<String, Map<String, Set<Id>>> mapOfActiveMembers = new Map<String, Map<String, Set<Id>>>();
		for (Asset asset : listOfActiveMembers){
			String prodName = asset.Product2.Name;
			String yearString = String.valueOf(asset.InstallDate.year());
			String stringMonth = '';
			if (isMonthly){
				stringMonth = getMonth(asset.InstallDate.month())+'-' + yearString;
			} else{
				stringMonth = yearString;
			}
			if (!mapOfActiveMembers.containsKey(prodName)){
				mapOfActiveMembers.put(prodName, new Map<String, Set<Id>>());
			}
			if (!mapOfActiveMembers.get(prodName).containsKey(stringMonth)){
				mapOfActiveMembers.get(prodName).put(stringMonth, new Set<Id>());
			}
			mapOfActiveMembers.get(prodName).get(stringMonth).add(asset.AccountId);
		}
		return mapOfActiveMembers;
	}

	private static Set<String> getRequiredProducts(){
		Set<String> setOfProdNames = new Set<String>();
		setOfProdNames.add('Gold Membership');
		setOfProdNames.add('Platinum Membership');
		setOfProdNames.add('Silver Membership');
		//setOfProdNames.add('Silver Membership - MPSF');
		return setOfProdNames;
	}

	private static Set<String> getRequiredStatus(){
		Set<String> setOfStatus = new Set<String>();
		setOfStatus.add('Active');
		setOfStatus.add('Completed');
		setOfStatus.add('Expired');
		setOfStatus.add('Purchased');
		return setOfStatus;
	}

	private static void prepareMapsForChart(List<Asset> listOfPurchaseHist, Map<String, Map<String, Decimal>> dataSetMap, Map<String, Set<String>> mapOfProdNameVsMonths, Set<String> setOfMonth, Set<String> setOfYear, Map<String, Decimal> mapOfMonthVsCounts, Boolean isMonthly){
		for (Asset asset : listOfPurchaseHist){
			Decimal totalAnnualPrice = 0;
			Decimal monthVsCount = 0;
			String stringMonth = '';
			String yearString = String.valueOf(asset.InstallDate.year());
			String prodName = asset.Product2.Name;
			/* if (projectId == Label.The_Linux_Foundation_Project){ */
			/* if (asset.Product2.Name != 'Silver Membership - MPSF'){ */
			/* prodName = ; */
			/* }
			 } else{
			 prodName = asset.Product2.Name;
			 } */
			/* if (String.isNotEmpty(prodName)){ */
			if (isMonthly){
				stringMonth = getMonth(asset.InstallDate.month())+'-' + yearString;
			} else{
				stringMonth = yearString;
			}
			if (!dataSetMap.containsKey(prodName)){
				dataSetMap.put(prodName, new Map<String, Decimal>());
			}
			if (dataSetMap.containsKey(prodName) && !dataSetMap.get(prodName).containsKey(stringMonth)){
				dataSetMap.get(prodName).put(stringMonth, 0);
			}
			if (dataSetMap.containsKey(prodName)){
				if (asset.Price != null){
					totalAnnualPrice = dataSetMap.get(prodName).get(stringMonth)+asset.Price;
				} else{
					totalAnnualPrice = dataSetMap.get(prodName).get(stringMonth);
				}
				dataSetMap.get(prodName).put(stringMonth, totalAnnualPrice);
			}
			if (!mapOfProdNameVsMonths.containsKey(prodName)){
				mapOfProdNameVsMonths.put(prodName, new Set<String>());
			}
			mapOfProdNameVsMonths.get(prodName).add(stringMonth);
			if (!mapOfMonthVsCounts.containsKey(stringMonth)){
				mapOfMonthVsCounts.put(stringMonth, 0);
			}
			if (asset.Price != null){
				monthVsCount = mapOfMonthVsCounts.get(stringMonth)+asset.Price;
			} else{
				monthVsCount = mapOfMonthVsCounts.get(stringMonth);
			}
			mapOfMonthVsCounts.put(stringMonth, monthVsCount);
			setOfMonth.add(stringMonth);
			setOfYear.add(yearString);

		}
	}

	/* this method prepares map for aggregate result of The Linux Foundation Silver Membership - MPSF product. This is then added to individual products */
    @TestVisible
	private static void prepareMapForAggregatePurchaseHist(List<AggregateResult> lfSilverMemberMpsfSum, Map<String, Decimal> lfSilverMpsfMap, Boolean isMonthly){
		for (AggregateResult asset : lfSilverMemberMpsfSum){
			Decimal totalAnnualPrice = 0;
			Decimal monthVsCount = 0;
			String stringMonth = String.valueOf(asset.get('month'));
			String yearString = String.valueOf(asset.get('year'));
			Integer integerMonth = Integer.valueOf(asset.get('month'));
			Double price = Double.valueOf(asset.get('total'));
			if (isMonthly){
				stringMonth = getMonth(integerMonth)+'-' + yearString;
			} else{
				stringMonth = yearString;
			}
			if (!lfSilverMpsfMap.containsKey(stringMonth)){
				lfSilverMpsfMap.put(stringMonth, 0);
			}
			totalAnnualPrice = lfSilverMpsfMap.get(stringMonth)+price;
			lfSilverMpsfMap.put(stringMonth, totalAnnualPrice);
		}
	}

	private static string getMonth(Integer month){
		Map<Integer, String> monthString = new Map<Integer, String>{1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April', 5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August', 9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December'};
		return monthString.get(month);
	}

	private static Integer getIntegerMonthFromString(String month){
		Map<String, Integer> monthIntVsString = new Map<String, Integer>{'january' => 1, 'february' => 2, 'march' => 3, 'april' => 4, 'may' => 5, 'june' => 6, 'july' => 7, 'august' => 8, 'september' => 9, 'october' => 10, 'november' => 11, 'december' => 12};
		return monthIntVsString.get(month.toLowerCase());
	}

	/* this method creates chart based on condition for monthly/yearly */
	private static ChartjsData getPreparedChart(Map<String, Map<String, Decimal>> dataSetMap, Set<String> setOfMonth, Map<String, Set<String>> mapOfProdNameVsMonths, Map<String, Decimal> mapOfMonthVsCounts, Boolean isMonthly, List<String> selectedDates, Map<String, Map<String, Set<Id>>> activeMembersMap){

		List<String> listOfLabel = new List<String>();
		Decimal totalRevenue = 0;
		List<ChartjsData.chartjsDataset> listOfChartJsData = new List<ChartjsData.chartjsDataset>();
		Set<String> setOfLabel = new Set<String>();
		Map<String, Double> listOfPercentData = new Map<String, Double>();
		Map<String, Decimal> mapOfXLabelVsStack = new Map<String, Decimal>();
		Map<String, Integer> mapOfActiveMembers = new Map<String, Integer>();
		Integer i = 0;
		System.debug('#--keyset--#' + dataSetMap.keySet());
		System.debug('#--dataSet--#' + dataSetMap);
		/* selected monthly: show all months */
		if (isMonthly){
			for (String prodName : dataSetMap.keySet()){
				List<Decimal> listOfStatusData = new List<Decimal>();
				List<Decimal> listOfCumulativeRevenue = new List<Decimal>();
				Decimal cumulativeTotal = 0;
				for (String month : setOfMonth){
					if (month.contains('January')){
						cumulativeTotal = 0;
					}
					Decimal currentValue = dataSetMap.get(prodName).containsKey(month) ? dataSetMap.get(prodName).get(month) : 0;
					cumulativeTotal += currentValue;
					totalRevenue += currentValue;
					if (mapOfProdNameVsMonths.containsKey(prodName) && mapOfProdNameVsMonths.get(prodName).contains(month)){
						listOfStatusData.add(currentValue);
						//listOfCumulativeRevenue.add(cumulativeTotal);
					} else{
						listOfStatusData.add(0);
						//listOfCumulativeRevenue.add(cumulativeTotal);
					}

					//For Hiding Cumulative bar for future month
					List<String> monthAndYear = month.split('-');
					//Retrieve the month and year from list
					Integer monthInt = getIntegerMonthFromString(monthAndYear[0].toLowerCase());
					Integer yearInt = Integer.valueOf(monthAndYear[1]);
					//If the month and year is less than the currentmonth and current year then only add cumulative data or else don't
					if (yearInt < date.TODAY().Year() || (monthInt <= date.TODAY().Month() && yearInt <= date.TODAY().Year())){
						System.debug('cumulativeTotal ' + cumulativeTotal);
						listOfCumulativeRevenue.add(cumulativeTotal);
					}
					setOfLabel.add(month);
					if (mapOfMonthVsCounts.containsKey(month)){
						Decimal total = mapOfMonthVsCounts.get(month);
						Double result = 0;
						if (total != 0){
							result = (currentValue / total) * 100;
						}
						listOfPercentData.put(month + '-' + prodName, result);
						mapOfXLabelVsStack.put(month + '-' + prodName, total.setScale(2));
					} else{
						mapOfXLabelVsStack.put(month + '-' + prodName, cumulativeTotal.setScale(2));
					}
					if (activeMembersMap.containsKey(prodName) && activeMembersMap.get(prodName).containsKey(month)){
						mapOfActiveMembers.put(month + '-' + prodName, activeMembersMap.get(prodName).get(month).size());
					} else{
						mapOfActiveMembers.put(month + '-' + prodName, 0);
					}
				}
				prepareChart(i, prodName, listOfPercentData, listOfStatusData, mapOfXLabelVsStack, listOfChartJsData, listOfCumulativeRevenue, mapOfActiveMembers);
				i++;
			}
		} else{
			//selected yearly, show data based on years
			for (String prodName : dataSetMap.keySet()){
				List<Decimal> listOfStatusData = new List<Decimal>();
				for (String year : dataSetMap.get(prodName).keySet()){
					Decimal currentValue = dataSetMap.get(prodName).get(year);
					listOfStatusData.add(currentValue);
					totalRevenue += currentValue;
					setOfLabel.add(year);
					if (mapOfMonthVsCounts.containsKey(year)){
						Decimal total = mapOfMonthVsCounts.get(year);
						Double result = (currentValue / total) * 100;
						listOfPercentData.put(year + '-' + prodName, result);
						mapOfXLabelVsStack.put(year, total);
					} else{
						mapOfXLabelVsStack.put(year, currentValue);
					}
					if (activeMembersMap.containsKey(prodName) && activeMembersMap.get(prodName).containsKey(year)){
						mapOfActiveMembers.put(year + '-' + prodName, activeMembersMap.get(prodName).get(year).size());
					} else{
						mapOfActiveMembers.put(year + '-' + prodName, 0);
					}
				}
				prepareChart(i, prodName, listOfPercentData, listOfStatusData, mapOfXLabelVsStack, listOfChartJsData, null, mapOfActiveMembers);
				i++;
			}
		}

		listOfLabel.addAll(setOfLabel);
		ChartjsData chartjsData = new ChartjsData();
		chartjsData.labels = listOfLabel;
		chartjsData.dataSets = listOfChartJsData;
		chartjsData.totalRevenue = totalRevenue.setScale(2); // to show total revenue on chart top
		return chartjsData;
	}

	/* this method prepares the combined chart with all required attributes */
	private static void prepareChart(Integer i, String prodName, Map<String, Double> listOfPercentData, List<Decimal> listOfStatusData, Map<String, Decimal> mapOfXLabelVsStack, List<ChartjsData.chartjsDataset> listOfChartJsData, List<Decimal> listOfCumulativeRevenue, Map<String, Integer> mapOfActiveMembers){
		ChartjsData.chartjsDataset dataSet = new ChartjsData.chartjsDataset();
		dataSet.label = prodName; //product label
		dataSet.dataInPercent = listOfStatusData; // list of data to show: [16K, 12K]
		if (i == 0){
			dataSet.pointHighlightFill = '#6dce56'; // color of graph
		} else if (i == 1){
			dataSet.pointHighlightFill = '#e16032';
		} else if (i == 2){
			dataSet.pointHighlightFill = '#52b7d8';
		} else if (i == 3){
			dataSet.pointHighlightFill = '#4fd2d2';
		} else if (i == 4){
			dataSet.pointHighlightFill = '#e287b2';
		} else if (i == 5){
			dataSet.pointHighlightFill = '#ffb03b';
		} else if (i == 6){
			dataSet.pointHighlightFill = '#52b7d8';
		} else{
			dataSet.pointHighlightFill = '#52b7d8';
		}
		dataSet.showCustomValue = true; // show custom y axis with K and M
		dataSet.stepSize = 10;
		dataSet.listOfPercentData = listOfPercentData; // percent data for tool tip
		dataSet.mapOfXLabelVsStack = mapOfXLabelVsStack; //used for mapping with tool tip
		dataSet.mapOfActiveMembers = mapOfActiveMembers; // used for Active Members
		if (listOfCumulativeRevenue != null && !listOfCumulativeRevenue.isEmpty()){
			dataSet.cumulativeArray = listOfCumulativeRevenue; //cumulative total
		}
		System.debug('#--dataSet.pointHighlightFill--#' + dataSet.pointHighlightFill);
		listOfChartJsData.add(dataSet);
	}

	/* prepare where condition based on selected dates and operator */
	private static String getPreparedWhereClause(String selectedDateVariable, List<String> selectedDates){
		String whereClause = '';
		if (String.isNotBlank(selectedDateVariable) && !selectedDates.isEmpty()){
			switch on selectedDateVariable{
				when 'between'{
					String toDate = selectedDates[0];
					String fromDate = selectedDates[1];
					whereClause += ' AND InstallDate <= ' + toDate + ' AND InstallDate >= ' + fromDate;
				}
				when 'lessThanEqual'{
					String toDate = selectedDates[0];
					whereClause += ' AND InstallDate <= ' + toDate;
				}
				when 'greaterThanEqual'{
					String fromDate = selectedDates[0];
					whereClause += ' AND InstallDate >= ' + fromDate;
				}
				when 'equalLessThan'{
					String literal = selectedDates[0].substringBefore('_Plus_To_Date');
					System.debug('#--literal--#' + literal);
					if (literal.contains('Fiscal_Quarter')){
						whereClause += literal.contains('THIS') ? ' AND InstallDate = ' + literal + ' AND InstallDate <= TODAY' : ' AND (InstallDate = ' + literal + ' OR InstallDate = THIS_FISCAL_QUARTER)';
					} else if (literal.contains('Fiscal_Year')){
						whereClause += literal.contains('THIS') ? ' AND InstallDate = ' + literal + ' AND InstallDate <= TODAY' : ' AND (InstallDate = ' + literal + ' OR InstallDate = THIS_FISCAL_YEAR)';
					} else if (literal.contains('Year')){
						whereClause += literal.contains('THIS') ? ' AND InstallDate = ' + literal + ' AND InstallDate <= TODAY' : ' AND (InstallDate = ' + literal + ' OR InstallDate = THIS_YEAR)';
					} else if (literal.contains('Quarter')){
						whereClause += literal.contains('THIS') ? ' AND InstallDate = ' + literal + ' AND InstallDate <= TODAY' : ' AND (InstallDate = ' + literal + ' OR InstallDate = THIS_QUARTER)';
					} else if (literal.contains('Month')){
						whereClause += literal.contains('THIS') ? ' AND InstallDate = ' + literal + ' AND InstallDate <= TODAY' : ' AND (InstallDate = ' + literal + ' OR InstallDate = THIS_MONTH)';
					}
				}
				when 'equal'{
					if (selectedDates.size() == 1){
						whereClause += ' AND InstallDate = ' + selectedDates[0];
					} else{
						whereClause += ' AND (';
						String whereClause1 = '';
						for (String str : selectedDates){
							whereClause1 += ' InstallDate = ' + str + ' OR';
						}
						whereClause1 = whereClause1.removeEnd('OR');
						whereClause1 += ' )';
						whereClause += whereClause1;
					}
				}
			}
		} else{
			whereClause += ' AND InstallDate = THIS_YEAR';
		}
		return whereClause;
	}

	public class AssetWrapper{
		@AuraEnabled
		public Asset asset{ get; set; }
	}

	public class ReturnAssetWrapper{
		@AuraEnabled
		public List<AssetWrapper> AssetWrapper;

		@AuraEnabled
		public String message{ get; set; }

		@AuraEnabled
		public String reportLink{ get; set; }
	}
}