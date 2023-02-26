/**
 * Created by cloudroutesolutions on 04/02/21.
 */
({
	doInit: function (component, event, helper) {
		helper.getLeadData(component, event, helper);
		helper.getLeadTableData(component, event, helper);
		component.set("v.changePicklistValues", true);
	},

	setFoundationId: function (component, event, helper) { // component.set("v.loaded", true);
		var projectId = event.getParam("selectedProject");
		console.log({
			projectId
		});
		// Set here event attribute handler values
		component.set("v.foundationId", projectId.Id);
		helper.getLeadData(component, event, helper);
		helper.getLeadTableData(component, event, helper);
	},

	callViewAll: function (component, event, helper) {
		var selectedDateValues = component.get("v.selectedDateValues");
		var compareOperator = component.get("v.selectedDateValue");
		var selectedSource = component.get("v.selectedSource") != null ? component.get("v.selectedSource") : 'All';
		var url = window.location.origin + '/lightning/cmp/c__ViewMoreLC?c__foundationId=' + component.get("v.foundationId") + '&c__componentType=Lead' + '&c__selectedDateValues=' + selectedDateValues + '&c__compareOperator=' + compareOperator + '&c__selectedSource=' + selectedSource;
		window.open(url, '_blank');
	},

	handlerChartClickEvent: function (component, event, helper) {
		component.set("v.loaded", true);
		var chartValue = event.getParam("clickedValue");
		// Set here event attribute handler values
		component.set("v.selectedMonth", chartValue);
		// helper.getAccountReceivableData(component, event, helper);
		helper.getLeadTableData(component, event, helper);
	},

	handleSourceChangeEvent: function (component, event, helper) {
		component.set("v.loaded", true);
		var selectedSource = event.getParam("values");
		component.set("v.selectedSource", selectedSource[0]);
		component.set("v.changePicklistValues", false);
		component.set("v.changePicklistValues", false);
		helper.getLeadData(component, event, helper);
		helper.getLeadTableData(component, event, helper);

	},

	handleDateChangeEvent: function (component, event, helper) {
		component.set("v.loaded", true);
		var selectedDateValues = event.getParam("dateValues");
		var compareOperator = event.getParam("compareOperator");
		var componentType = event.getParam("type");
		/* if (componentType == 'Lead') { */
		component.set("v.selectedDateValues", selectedDateValues);
		component.set("v.selectedDateValue", compareOperator);
		component.set("v.changePicklistValues", true);
		component.set("v.selectedMonth", '');
		component.set("v.selectedSource", 'All');
		helper.getLeadData(component, event, helper);
		helper.getLeadTableData(component, event, helper);
		/* } */
	}
})