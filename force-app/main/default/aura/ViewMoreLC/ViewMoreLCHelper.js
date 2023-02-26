({
	helperInit: function (component, event, helper) {
		component.find("service").callApex(component, helper, "c.getSelectedProjectDetails", {
			foundationId: component.get("v.foundationId")
		}, this.getProjectNameSuccess);
	},

	getProjectNameSuccess: function (component, returnValue, helper) {
		component.set("v.selectedProjectName", returnValue.Name);
	},

	getAccountReceivableTableData: function (component, returnValue, helper) {
		var projectId = component.get("v.foundationId");
		var daysFromPurchaseDate = [];
		daysFromPurchaseDate.push(component.get("v.daysFromPurchaseDate"));
		var operator = daysFromPurchaseDate != 0 ? "Equals" : null;
		component.find("service").callApex(component, helper, "c.getAccountReceivableTableDetails", {
			foundationId: projectId,
			daysFromPurchaseDate: JSON.stringify(daysFromPurchaseDate),
			applyLimit: false,
			operator: operator,
			isList: true
		}, this.getAccountReceivableTableDataSuccess);
	},

	getAccountReceivableTableDataSuccess: function (component, returnValue, helper) {
		if (returnValue != null && returnValue.length > 0) {
			component.set("v.hasTableData", true);
		} else {
			component.set("v.hasTableData", false);
		}
		var cols;
		var checkboxOptions;
		var checkboxValues;
		var componentType = component.get("v.componentType");
		if (componentType == "AccountReceivable") {
			cols = [{
				label: "Purchase History Name",
				fieldName: "assetLink",
				type: "link",
				attributes: {
					label: {
						fieldName: "Name"
					},
					title: "Click to View(New Window)",
					target: "_blank"
				}
			}, {
				label: "Purchase Date",
				fieldName: "PurchaseDate",
				type: "date",
				sortable: true
			}, {
				label: "Revenue",
				fieldName: "Price",
				type: "number",
				attributes: {
					formatter: "currency",
					currencyCode: "USD"
				}
			}];
		} else if (componentType == "Lead") {
			cols = [{
					label: "Name",
					fieldName: "leadLink",
					type: "link",
					attributes: {
						label: {
							fieldName: "Name"
						},
						title: "Click to View(New Window)",
						target: "_blank"
					}
				},
				{
					label: "Lead Source",
					fieldName: "LeadSource",
					type: "text",
					sortable: true
				},
				{
					label: "Lead Owner",
					fieldName: "Owner.Name",
					type: "text",
					sortable: false
				},
				{
					label: "Created Date",
					fieldName: "CreatedDate",
					type: "date",
					sortable: true
				}, {
					label: "Status",
					fieldName: "Status",
					type: "text",
					sortable: true
				}
			];
			checkboxOptions = "{ 'label': 'All', 'value': 'All' }";
			checkboxValues = "{ 'label': 'All', 'value': 'All' }";
			component.set("v.checkboxOptions", checkboxOptions);
			component.set("v.checkboxValues", checkboxValues);
		}
		component.set("v.columns", cols);

		if (returnValue != null) {
			returnValue.forEach((rec) => {
				rec.assetLink = "/" + rec.Id;
			});
		}

		component.set("v.chartTableData", returnValue);
		component.set("v.loaded", false);
	},

	dataChanged: function (component, event, helper) {
		try {
			var projectId = component.get("v.foundationId");
			var isList = component.get("v.checkboxValues").length != 0 ? true : false;
			var operator = component.get("v.checkboxValues").length != 0 ? component.get("v.selectedOperator") : null;
			var daysFromPurchaseDate = [];
			daysFromPurchaseDate.push(component.get("v.daysFromPurchaseDate"));
			component.find("service").callApex(component, helper, "c.getAccountReceivableTableDetails", {
				foundationId: projectId,
				daysFromPurchaseDate: JSON.stringify(daysFromPurchaseDate),
				applyLimit: false,
				operator: operator,
				isList: isList
			}, this.getAccountReceivableTableDataSuccess);
		} catch (err) {
			console.log("#--err--#" + err);
		}
	},

	leadDataChanged: function (component, event, helper) {
		var projectId = component.get("v.foundationId");
		component.find("service").callApex(component, helper, "c.getLeadTableDetails", {
			foundationId: projectId,
			applyLimit: false,
			operator: null,
			isList: false
		}, this.leadDataChangedSuccess);
	},

	leadDataChangedSuccess: function (component, returnValue, helper) {
		if (returnValue) {
			if (returnValue.length > 0) {
				component.set("v.hasTableData", true);
			} else {
				component.set("v.hasTableData", false);
			}
			component.set("v.chartTableData", returnValue);
		}
		component.set("v.loaded", false);
	},

	getLeadData: function (component, event, helper) {
		var projectId = component.get("v.foundationId");
		var selectedSource = component.get("v.selectedSource");
		var selectedMonth = component.get("v.selectedMonth");
		var selectedDateVariable = component.get("v.selectedDateValue"); // ex. THIS_MONTH
		var selectedDates = component.get("v.selectedDateValues");
		component.find("service").callApex(component, helper, "c.getLeadDetails", {
			foundationId: projectId,
			selectedSource: selectedSource,
			selectedDateFilter: selectedMonth,
			selectedDateVariable: selectedDateVariable,
			selectedDates: selectedDates
		}, this.getLeadDataSuccess);
	},

	getLeadDataSuccess: function (component, returnValue, helper) {
		if (returnValue) {
			if (returnValue.length > 0) {
				component.set("v.hasData", true);
			} else {
				component.set("v.hasData", false);
			}
			component.set("v.chartData", returnValue);
			var dataSet = JSON.parse(returnValue).datasets.length > 0 ? JSON.parse(returnValue).datasets[0].datainPercent : "[]";
			component.set("v.dataInPercent", dataSet);
		}
		component.set("v.loaded", false);
	},

	getLeadTableData: function (component, returnValue, helper) {
		var projectId = component.get("v.foundationId");
		var selectedSource = component.get("v.selectedSource");
		var selectedMonth = component.get("v.selectedMonth");
		var selectedDateVariable = component.get("v.selectedDateValue"); // ex. THIS_MONTH
		var selectedDates = component.get("v.selectedDateValues");
		component.find("service").callApex(component, helper, "c.getLeadTableDetails", {
			foundationId: projectId,
			selectedSource: selectedSource,
			selectedMonth: selectedMonth,
			selectedDateVariable: selectedDateVariable,
			selectedDates: selectedDates,
			applyLimit: false,
			operator: null,
			isList: false
		}, this.getLeadTableDataSuccess);
	},

	getLeadTableDataSuccess: function (component, returnRecords, helper) {
		if (returnRecords) {
			var returnValue = returnRecords.leadWrapper;
			var pageSize = component.get("v.pageSize");
			if (returnValue.length > 0) {
				component.set("v.hasTableData", true);
			} else {
				component.set("v.hasTableData", false);
			}
			component.set("v.message", returnRecords.message);
			component.set("v.reportURL", returnRecords.reportLink);

			var cols = [{
					label: "Name",
					fieldName: "leadLink",
					type: "link",
					attributes: {
						label: {
							fieldName: "Name"
						},
						title: "Click to View(New Window)",
						target: "_blank"
					}
				},
				{
					label: "Lead Source",
					fieldName: "LeadSource",
					type: "text",
					sortable: true
				},
				{
					label: "Lead Owner",
					fieldName: "Owner.Name",
					type: "text",
					sortable: false
				},
				{
					label: "Created Date",
					fieldName: "CreatedDate",
					type: "date",
					sortable: true
				}, {
					label: "Days",
					fieldName: "Days",
					type: "text",
					sortable: true
				}, {
					label: "Status",
					fieldName: "Status",
					type: "text",
					sortable: true
				}
			];
			component.set("v.columns", cols);

			if (component.get("v.changePicklistValues")) {
				var leadSourceFilterOptions = [];
				var defaultVal = {
					label: "All",
					value: "All",
					selected: true

				};
				var isAllSelected = true;
				if (component.get("v.selectedSource") != null && component.get("v.selectedSource")[0] != 'All') {
					defaultVal.selected = false;
					isAllSelected = false;
				}
				leadSourceFilterOptions.push(defaultVal);
				var tempSource = [];
				returnValue.forEach((rec) => {
					/* rec.leadLink = '/' + rec.lead.Id; */
					if (!tempSource.includes(rec.lead.LeadSource) && rec.lead.LeadSource != null && rec.lead.LeadSource != "" && rec.lead.LeadSource != " ") {
						tempSource.push(rec.lead.LeadSource);
						var soc = {
							label: rec.lead.LeadSource,
							value: rec.lead.LeadSource,
							selected: isAllSelected
						};
						if (soc.label == component.get("v.selectedSource")) {
							soc.selected = true;
						}
						leadSourceFilterOptions.push(soc);
					}
				});
				component.set("v.checkboxOptions", leadSourceFilterOptions);
				
			}

			/* returnValue.splice(3, 0, "test"); */
			var leadListArray = [];
			returnValue.forEach(function (leadWrap) {
				var leadInstance = {
					Name: leadWrap.lead.Name,
					LeadSource: leadWrap.lead.LeadSource,
					"Owner.Name": leadWrap.lead.Owner.Name,
					CreatedDate: leadWrap.lead.CreatedDate,
					Days: leadWrap.totalDays,
					Status: leadWrap.lead.Status
				};
				leadInstance.leadLink = "/" + leadWrap.lead.Id;
				var leadInstanceString = JSON.parse(JSON.stringify(leadInstance));
				leadListArray.push(leadInstanceString);
			});
			component.set("v.chartTableData", leadListArray);
			component.set("v.leadTableAllRecords", leadListArray);
			component.set("v.totalRecords", leadListArray.length);
			component.set("v.pageNumber", 1);
			component.set("v.maxPage", Math.ceil(leadListArray.length / pageSize));
			helper.renderPage(component);
		}
		component.set("v.loaded", false);
	},

	getRevenueTableData: function (component, event, helper) {
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
			"selectedProduct": '',
			"applyLimit": false,
			"isMonthly": isMonthly
		}, this.getFilteredTableDataSuccess);
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
			component.set("v.chartTableData", assetInstanceArray);
			component.set("v.message", returnRecords.message);
			component.set("v.reportURL", returnRecords.reportLink);
		}
		component.set("v.loaded", false);

	},

	getPurchaseTypes: function (component, event, helper) {
		component.find("service").callApex(component, helper, "c.getPurchaseTypes", {}, this.getPurchaseTypesSuccess);
	},
	getPurchaseTypesSuccess: function (component, returnValue, helper) {
		var selectedPurchaseType = component.get("v.checkboxValues");
		var defaultAll = false;
		if (selectedPurchaseType.length == 5 || selectedPurchaseType.length == 1 && selectedPurchaseType[0] == 'All') {
			defaultAll = true;
		}
		if (returnValue != null) {
			var purchaseTypeOptions = [];
			var defaultVal = {
				label: 'All',
				value: 'All',
				selected: defaultAll
			};
			purchaseTypeOptions.push(defaultVal);
			returnValue.forEach(rec => {
				var item = {
					label: rec,
					value: rec,
					selected: defaultAll ? true : selectedPurchaseType.includes(rec) ? true : false
				};
				purchaseTypeOptions.push(item);
			});
			component.set("v.purchaseTypeOptions", purchaseTypeOptions);
		}
		component.set("v.loaded", false);
	},

	handlePurchaseTypeChange: function (component, event, helper) {
		var selectedSource = event.getParam("values");
		// var checkboxValuesArray = [];
		// checkboxValuesArray.push(selectedSource);
		component.set("v.checkboxValues", selectedSource);
		helper.getRevenueTableData(component, event, helper);
	},

	getJsonFromUrl: function () {
		var query = location.search.substr(1);
		var result = {};
		query.split("&").forEach(function (part) {
			var item = part.split("=");
			result[item[0]] = decodeURIComponent(item[1]);
		});
		return result;
	},

	renderPage: function (component) {
		var pageSize = component.get("v.pageSize");
		var records = component.get("v.leadTableAllRecords");
		var pageNumber = component.get("v.pageNumber");
		var pageRecords = records.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
		component.set("v.chartTableData", pageRecords);
	}
});