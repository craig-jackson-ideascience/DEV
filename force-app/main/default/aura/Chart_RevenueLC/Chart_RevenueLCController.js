({
	doInit: function (component, event, helper) { // component.set("v.loaded", true);
		helper.getPurchaseTypes(component, event, helper);
	},

	setFoundationId: function (component, event, helper) {
		component.set("v.loaded", true);
		var projectId = event.getParam("selectedProject");
		// Set here event attribute handler values
		component.set("v.foundationId", projectId.Id);
		/* reset filters */
		helper.resetDefaultFilters(component, event, helper);
		helper.getFilteredChartData(component, event, helper);
		helper.getFilteredTableData(component, event, helper);
		helper.getActiveMembers(component, event, helper);
	},

	handleDateChangeEvent: function (component, event, helper) {
		helper.handleDateChangeEvent(component, event, helper);
	},

	handlePurchaseTypeChange: function (component, event, helper) {
		component.set("v.loaded", true);
		helper.handlePurchaseTypeChange(component, event, helper);
	},

	handleYearlyChanged: function (component, event, helper) {
		helper.handleYearlyChanged(component, event, helper);
	},

	handlerChartClickEvent: function (component, event, helper) {
		component.set("v.loaded", true);
		component.set("v.applyLimit", false);
		var chartValue = event.getParam("clickedValue");
		var yAxisValue = event.getParam("yAxisValue");
		component.set("v.selectedMonth", chartValue);
		component.set("v.selectedProduct", yAxisValue);
		// helper.getFilteredChartData(component, event, helper);
		helper.getFilteredTableData(component, event, helper);
	},

	callViewAll: function (component, event, helper) {
		var selectedDateArrays = [];
		var selectedDateValues = component.get("v.selectedDateValues");
		if (selectedDateValues.length == 0) {
			selectedDateValues.push('THIS_YEAR');
			// selectedDateValues = selectedDateArrays;
		}
		var compareOperator = component.get("v.selectedDateValue");
		var selectedPurchaseType = component.get("v.checkboxValues");
		if (selectedPurchaseType.length == 0) {
			selectedPurchaseType.push('All');
		}
		var url = window.location.origin + '/lightning/cmp/c__ViewMoreLC?c__foundationId=' + component.get("v.foundationId") + '&c__componentType=Revenue' + '&c__selectedDateValues=' + selectedDateValues + '&c__compareOperator=' + compareOperator + '&c__selectedPurchaseTypes=' + selectedPurchaseType;
		window.open(url, '_blank');
	}
})