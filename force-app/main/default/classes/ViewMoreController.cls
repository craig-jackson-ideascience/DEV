public with sharing class ViewMoreController{
	@AuraEnabled
	public static List<Asset> getAccountReceivableTableDetails(String foundationId, String daysFromPurchaseDate, Boolean applyLimit, String operator, Boolean isList){
		return AccountReceivableChartController.getAccountReceivableTableDetails(foundationId, daysFromPurchaseDate, applyLimit, operator, isList);
	}

	@AuraEnabled
	public static Chart_LeadSubmissionController.ReturnLeadWrapper getLeadTableDetails(String foundationId, List<String> selectedSource, String selectedDateFilter, string selectedDateVariable, List<String> selectedDates, String createdDate, String leadSource, String operator, Boolean applyLimit, Boolean isList){
		return Chart_LeadSubmissionController.getLeadTableDetails(foundationId, selectedSource, selectedDateFilter, selectedDateVariable, selectedDates, createdDate, leadSource, operator, applyLimit, isList);
	}

	@AuraEnabled
	public static String getLeadDetails(String foundationId, List<String> selectedSource, String selectedDateFilter, string selectedDateVariable, List<String> selectedDates){
		return Chart_LeadSubmissionController.getLeadDetails(foundationId, selectedSource, selectedDateFilter, selectedDateVariable, selectedDates);
	}

	@AuraEnabled
	public static Project__c getSelectedProjectDetails(String foundationId){
		return AccountReceivableChartController.getSelectedProjectDetails(foundationId); 
	}

	@AuraEnabled
	public static Chart_RevenueController.ReturnAssetWrapper getFilteredTableData(String projectId, String selectedDateVariable, List<String> selectedDates, String listOfPurchaseTypesString, String selectedMonth, String selectedProduct, Boolean applyLimit, Boolean isMonthly){
		System.debug('#--projectId--#' + projectId);
		return Chart_RevenueController.getFilteredTableData(projectId, selectedDateVariable, selectedDates, listOfPurchaseTypesString, selectedMonth, selectedProduct, applyLimit, isMonthly);
	}

	@AuraEnabled
	public static List<String> getPurchaseTypes(){
		return Chart_RevenueController.getPurchaseTypes();
	}
}