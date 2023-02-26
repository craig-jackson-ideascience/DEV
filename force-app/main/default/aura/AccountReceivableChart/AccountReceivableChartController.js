/**
 * Created by cloudroutesolutions on 20/01/21.
 */
({
	doInit: function (component, event, helper) {
		helper.getAccountReceivableData(component, event, helper);
		helper.getAccountReceivableTableData(component, event, helper);
	},

	setFoundationId: function (component, event, helper) {
		component.set("v.loaded", true);
		var projectId = event.getParam("selectedProject");
		component.set("v.daysFromPurchaseDate", "0");
		// Set here event attribute handler values
		component.set("v.foundationId", projectId.Id);
		helper.getAccountReceivableData(component, event, helper);
		helper.getAccountReceivableTableData(component, event, helper);
	},

	handlerChartClickEvent: function (component, event, helper) {
		component.set("v.loaded", true);
		var chartValue = event.getParam("clickedValue");
		// Set here event attribute handler values
		component.set("v.daysFromPurchaseDate", chartValue);
		helper.getAccountReceivableTableData(component, event, helper);
	},

	callViewAll: function (component, event, helper) {
		var url = window.location.origin + '/lightning/cmp/c__ViewMoreLC?c__foundationId=' + component.get("v.foundationId") +
			'&c__daysFromPurchaseDate=' + component.get("v.daysFromPurchaseDate") + '&c__componentType=AccountReceivable';
		window.open(url, '_blank');
	}


})