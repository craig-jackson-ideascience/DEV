/**
 * Created by cloudroutesolutions on 20/01/21.
 */
({
	getLeadData: function (component, event, helper) {
		var projectId = component.get("v.foundationId");
		var selectedSource = component.get("v.selectedSource");
		var selectedMonth = component.get("v.selectedMonth");
		var selectedDateVariable = component.get("v.selectedDateValue"); //ex. THIS_MONTH
		var selectedDates = component.get("v.selectedDateValues");
		component.find("service")
			.callApex(component, helper,
				"c.getLeadDetails", {
					"foundationId": projectId,
					"selectedSource": selectedSource,
					"selectedDateFilter": selectedMonth,
					"selectedDateVariable": selectedDateVariable,
					"selectedDates": selectedDates
				},
				this.getLeadDataSuccess);
	},

	getLeadDataSuccess: function (component, returnValue, helper) {
		if (returnValue != null && returnValue.length > 0) {
			component.set("v.hasData", true);
		} else {
			component.set("v.hasData", false);
		}
		component.set("v.loaded", false);
		if (component.get("v.hasData")) {
			component.set("v.chartData", returnValue);
			var dataSet = JSON.parse(returnValue).datasets.length > 0 ? JSON.parse(returnValue).datasets[0].datainPercent : [];
			component.set("v.dataInPercent", dataSet);
		}
	},

	getLeadTableData: function (component, returnValue, helper) {
		var projectId = component.get("v.foundationId");
		var selectedSource = component.get("v.selectedSource");
		var selectedMonth = component.get("v.selectedMonth");
		var selectedDateVariable = component.get("v.selectedDateValue"); //ex. THIS_MONTH
		var selectedDates = component.get("v.selectedDateValues");
		component.find("service")
			.callApex(component, helper,
				"c.getLeadTableDetails", {
					"foundationId": projectId,
					"selectedSource": selectedSource,
					"selectedMonth": JSON.stringify(selectedMonth),
					"selectedDateVariable": selectedDateVariable,
					"selectedDates": selectedDates,
					"applyLimit": true,
					"operator": null,
					"isList": false
				},
				this.getLeadTableDataSuccess);
	},

	getLeadTableDataSuccess: function (component, returnRecords, helper) {
		if (returnRecords) {
			var returnValue = returnRecords.leadWrapper;
			if (returnValue != null && returnValue.length > 0) {
				component.set("v.hasTableData", true);
			} else {
				component.set("v.hasTableData", false);
			}
			

			var cols = [{
					label: 'Name',
					fieldName: 'leadLink',
					type: 'link',
					attributes: {
						label: {
							fieldName: 'Name'
						},
						title: "Click to View(New Window)",
						target: '_blank'
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
				},
				{
					label: "Days",
					fieldName: "Days",
					type: "text",
					sortable: true
				},
				{
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
					label: 'All',
					value: 'All',
					selected: true
				};
				leadSourceFilterOptions.push(defaultVal);
				var tempSource = [];
				returnValue.forEach(rec => {
					if (!tempSource.includes(rec.lead.LeadSource) && rec.lead.LeadSource != null && rec.lead.LeadSource != '' && rec.lead.LeadSource != ' ') {
						tempSource.push(rec.lead.LeadSource);
						var soc = {
							label: rec.lead.LeadSource,
							value: rec.lead.LeadSource
						};
						leadSourceFilterOptions.push(soc);
					}
				});
				component.set("v.checkboxOptions", leadSourceFilterOptions);
			}

			/* returnValue.splice(3, 0, "test"); */
			var leadListArray = [];
			returnValue.forEach(function (leadWrap) {
				var leadInstance = {
					'Name': leadWrap.lead.Name,
					'LeadSource': leadWrap.lead.LeadSource,
					'Owner.Name': leadWrap.lead.Owner.Name,
					'CreatedDate': leadWrap.lead.CreatedDate,
					'Days': leadWrap.totalDays,
					'Status': leadWrap.lead.Status
				};
				leadInstance.leadLink = '/' + leadWrap.lead.Id;
				var leadInstanceString = JSON.parse(JSON.stringify(leadInstance));
				leadListArray.push(leadInstanceString);
			});
			component.set("v.chartTableData", leadListArray);
		}
		component.set("v.loaded", false);
	},
})