({
	doInit: function (component, event, helper) {
		component.set("v.loaded", true);
		var url_string = window.location.href;
		var url = new URL(url_string);
		// var categoryName = url.searchParams.get("foundationId");

		window.setTimeout($A.getCallback(function () {
			var l = window.location.href;
			var categoryName = helper.getJsonFromUrl().c__foundationId;
			component.set('v.foundationId', categoryName);
			component.set('v.topicID', categoryName);
			var daysFromPurchaseDate = helper.getJsonFromUrl().c__daysFromPurchaseDate;

			component.set('v.daysFromPurchaseDate', daysFromPurchaseDate);
			var componentType = helper.getJsonFromUrl().c__componentType;
			component.set("v.componentType", componentType);


			var selecteddaysvalues = daysFromPurchaseDate == '0' ? 'All' : daysFromPurchaseDate;
			helper.helperInit(component, event, helper);
			if (componentType == 'AccountReceivable') {
				var options = [{
						label: 'All',
						value: 'All'
					},
					{
						label: '30',
						value: '30'
					},
					{
						label: '60',
						value: '60'
					},
					{
						label: '90',
						value: '90'
					}, {
						label: '120+',
						value: '120'
					}
				];

				component.set("v.checkboxOptions", options);

				// var options = component.get('v.checkboxOptions');
				options.forEach(function (element) {
					if (selecteddaysvalues == 'All') {
						element.selected = true;
					} else if (element.value == selecteddaysvalues) {
						element.selected = true;
					}
				});
				component.set('v.checkboxOptions', options);
			}

			if (componentType == 'AccountReceivable') {
				helper.getAccountReceivableTableData(component, event, helper);
			} else if (componentType == 'Lead') {
				component.set("v.changePicklistValues", true);
				var selectedDateValues = helper.getJsonFromUrl().c__selectedDateValues;
				component.set("v.selectedDateValues", selectedDateValues.split(','));
				var compareOperator = helper.getJsonFromUrl().c__compareOperator;
				component.set("v.selectedDateValue", compareOperator);
				var selectedSource = helper.getJsonFromUrl().c__selectedSource;
				var selectedSourceList = [];
				selectedSourceList.push(selectedSource);
				component.set("v.selectedSource", selectedSourceList);
				component.set('v.checkboxValues', selectedSource);

				helper.getLeadTableData(component, event, helper);
			} else if (componentType == 'Revenue') {
				var selectedDateValues = helper.getJsonFromUrl().c__selectedDateValues;
				component.set("v.selectedDateValues", selectedDateValues.split(','));
				var compareOperator = helper.getJsonFromUrl().c__compareOperator;
				component.set("v.selectedDateValue", compareOperator);
				var selectedPurchaseTypes = helper.getJsonFromUrl().c__selectedPurchaseTypes;
				component.set("v.checkboxValues", selectedPurchaseTypes.split(','));
				helper.getRevenueTableData(component, event, helper);
				helper.getPurchaseTypes(component, event, helper);
			}
		}), 500);
	},


	dataChanged: function (component, event, helper) {

		component.set("v.loaded", true);
		helper.dataChanged(component, event, helper);
	},

	leadDataChanged: function (component, event, helper) {
		component.set("v.loaded", true);
		// helper.leadDataChanged(component, event, helper);
		// helper.getLeadData(component, event, helper);
		helper.getLeadTableData(component, event, helper);
	},

	handleDateChangeEvent: function (component, event, helper) {
		component.set("v.loaded", true);
		var selectedDateValues = event.getParam("dateValues");
		var compareOperator = event.getParam("compareOperator");
		component.set("v.selectedDateValues", selectedDateValues);
		component.set("v.selectedDateValue", compareOperator);
		component.set("v.changePicklistValues", true);
		if (component.get("v.componentType") == 'Lead') {
			helper.getLeadTableData(component, event, helper);
			component.set("v.selectedSource", 'All');
		} else if (component.get("v.componentType") == 'Revenue') {
			helper.getRevenueTableData(component, event, helper);
		}
	},

	handleSourceChangeEvent: function (component, event, helper) {
		if (component.get("v.componentType") == 'Lead') {
			component.set("v.loaded", true);
			var selectedSource = event.getParam("values");
			component.set("v.selectedSource", selectedSource);
			helper.getLeadTableData(component, event, helper);
			component.set("v.changePicklistValues", false);
		} else if (component.get("v.componentType") == 'Revenue') {
			helper.handlePurchaseTypeChange(component, event, helper);
		}

	},

	renderPage: function (component, event, helper) {
		helper.renderPage(component);
	}

})