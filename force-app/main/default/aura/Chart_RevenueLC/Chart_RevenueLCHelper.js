({
	getPurchaseTypes: function (component, event, helper) {
		component.find("service").callApex(component, helper, "c.getPurchaseTypes", {}, this.getPurchaseTypesSuccess);
	},

	getPurchaseTypesSuccess: function (component, returnValue, helper) {
		if (returnValue != null) {
			var purchaseTypeOptions = [];
			var defaultVal = {
				label: 'All',
				value: 'All',
				selected: true
			};
			purchaseTypeOptions.push(defaultVal);
			returnValue.forEach(rec => {
				/* rec.leadLink = '/' + rec.lead.Id; */
				var item = {
					label: rec,
					value: rec,
					selected: true
				};
				purchaseTypeOptions.push(item);
			});
			component.set("v.purchaseTypeOptions", purchaseTypeOptions);
		}
	},

	getActiveMembers: function (component, event, helper) {
		var projectId = component.get("v.foundationId");
		component.find("service").callApex(component, helper, "c.getActiveMembers", {
			"projectId": projectId
		}, this.getActiveMembersSuccess);
	},

	getActiveMembersSuccess: function (component, returnValue, helper) {
		component.set("v.activeMembers", returnValue)
	},

	getFilteredChartData: function (component, event, helper) {
		var selectedMonth = component.get("v.selectedMonth");
		var selectedDateVariable = component.get("v.selectedDateValue"); // ex. THIS_MONTH
		var selectedDates = component.get("v.selectedDateValues");
		var projectId = component.get("v.foundationId");
		var isMonthly = component.get("v.selectedYearlyOption") == 'Monthly' ? true : false;
		component.find("service").callApex(component, helper, "c.getFilteredChartData", {
			"projectId": projectId,
			"selectedDateVariable": selectedDateVariable,
			"selectedDates": selectedDates,
			"listOfPurchaseTypesString": JSON.stringify(component.get("v.checkboxValues")),
			"isMonthly": isMonthly
		}, this.getFilteredChartDataSuccess);
	},

	getFilteredTableData: function (component, event, helper) {
		var selectedMonth = component.get("v.selectedMonth");
		var selectedDateVariable = component.get("v.selectedDateValue"); // ex. THIS_MONTH
		var selectedDates = component.get("v.selectedDateValues");
		var projectId = component.get("v.foundationId");
		var isMonthly = component.get("v.selectedYearlyOption") == 'Monthly' ? true : false;
		component.find("service").callApex(component, helper, "c.getFilteredTableData", {
			"projectId": projectId,
			"selectedDateVariable": selectedDateVariable,
			"selectedDates": selectedDates,
			"listOfPurchaseTypesString": JSON.stringify(component.get("v.checkboxValues")),
			"selectedMonth": selectedMonth,
			"applyLimit": component.get("v.applyLimit"),
			"isMonthly": isMonthly,
			"selectedProduct": component.get("v.selectedProduct")
		}, this.getFilteredTableDataSuccess);
	},

	getFilteredChartDataSuccess: function (component, returnValue, helper) {
		var isMonthly = component.get("v.selectedYearlyOption") == 'Monthly' ? true : false;
		component.set("v.isStackedBar", !isMonthly);
		component.set("v.isGroupedStackedBar", isMonthly);
		if (returnValue) {
			component.set("v.chartData", returnValue);
			var parseValue = JSON.parse(returnValue);
			component.set("v.totalRevenue", parseValue.totalRevenue.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","))
			var dataSet = parseValue.datasets.length > 0 ? parseValue.datasets[0].datainPercent : [];
			component.set("v.dataInPercent", dataSet);
		}
		component.set("v.loaded", false);
	},

	getFilteredTableDataSuccess: function (component, returnRecords, helper) {
		if (returnRecords) {
			var returnValue = returnRecords.AssetWrapper;
			var cols = [{
				label: 'Purchase Name History',
				fieldName: 'assetLink',
				type: 'link',
				attributes: {
					label: {
						fieldName: 'Name'
					},
					title: "Click to View(New Window)",
					target: '_blank'
				},
				sortable: true
			}, {
				label: "Member",
				fieldName: "Account.Name",
				type: "text",
				sortable: true
			}, {
				label: "Revenue",
				fieldName: "Price",
				type: "number",
				attributes: {
					formatter: "currency",
					currencyCode: "USD"
				},
				sortable: true
			}];
			component.set("v.columns", cols);
			var assetInstanceArray = [];
			returnValue.forEach(function (assetWrap) {
				var assetInstance = {
					'Name': assetWrap.asset.Name,
					'Account.Name': assetWrap.asset.Account.Name,
					'Price': assetWrap.asset.Price
				};
				assetInstance.assetLink = '/' + assetWrap.asset.Id;
				var assetInstanceString = JSON.parse(JSON.stringify(assetInstance));
				assetInstanceArray.push(assetInstanceString);
			});
			component.set("v.tableData", assetInstanceArray);
			component.set("v.message", returnRecords.message);
			component.set("v.reportURL", returnRecords.reportLink);
		}
		component.set("v.selectedMonth", null);
		component.set("v.selectedProduct", null);
		component.set("v.applyLimit", true);
		component.set("v.loaded", false);
	},

	handleDateChangeEvent: function (component, event, helper) {
		component.set("v.loaded", true);
		var selectedDateValues = event.getParam("dateValues");
		var compareOperator = event.getParam("compareOperator");
		component.set("v.selectedDateValues", selectedDateValues);
		component.set("v.selectedDateValue", compareOperator);
		component.set("v.selectedMonth", '');
		helper.getFilteredChartData(component, event, helper);
		helper.getFilteredTableData(component, event, helper);
	},

	handlePurchaseTypeChange: function (component, event, helper) {
		var selectedSource = event.getParam("values");
		// var checkboxValuesArray = [];
		// checkboxValuesArray.push(selectedSource);
		if (selectedSource.length > 1 && selectedSource[0] == 'All') {
			selectedSource.splice(0, 1);
		}
		component.set("v.checkboxValues", selectedSource);
		helper.getFilteredChartData(component, event, helper);
		helper.getFilteredTableData(component, event, helper);
	},

	handleYearlyChanged: function (component, event, helper) {
		component.set("v.loaded", true);
		helper.getFilteredChartData(component, event, helper);
	},

	resetDefaultFilters: function (component, event, helper) {
		/* reset date filter */
		var selectedDateValues = [];
		selectedDateValues.push('THIS_YEAR');
		component.set("v.selectedDateValues", selectedDateValues);
		var dateOptions = component.get("v.DateOptions");
		var resetDateOptions = [];
		dateOptions.forEach(dateOption => {
			var item = {
				label: dateOption.label,
				value: dateOption.value,
				selected: dateOption.value == 'THIS_YEAR' ? true : false
			};
			resetDateOptions.push(item);
		});
		component.set("v.DateOptions", resetDateOptions);
		component.set("v.selectedDateValue", null);

		/* reset purchase type filter */
		var purchaseTypeOptions = component.get("v.purchaseTypeOptions");
		var resetPurchaseOptions = [];
		purchaseTypeOptions.forEach(purchaseType => {
			var item = {
				label: purchaseType.label,
				value: purchaseType.value,
				selected: purchaseType.label == 'All' ? true : false
			};
			resetPurchaseOptions.push(item);
		});
		component.set("v.purchaseTypeOptions", resetPurchaseOptions);
		component.set("v.checkboxValues", "All");
	}
})