/**
 * Created by cloudroutesolutions on 20/01/21.
 */
({
	getAccountReceivableData: function (component, event, helper) {
		var projectId = component.get("v.foundationId");
		component.find("service")
			.callApex(component, helper,
				"c.getAccountReceivableDetails", {
					"foundationId": projectId,
					"daysFromPurchaseDate": 0
				},
				this.getAccountReceivableDataSuccess);
	},

	getAccountReceivableDataSuccess: function (component, returnValue, helper) {
		if (returnValue) {
			if (returnValue.length > 0) {
				component.set("v.hasData", true);
			} else {
				component.set("v.hasData", false);
			}
			component.set("v.chartData", returnValue);
			component.set("v.dataInPercent", JSON.parse(returnValue).datasets[0].datainPercent);
		}
		component.set("v.loaded", false);
	},

	getAccountReceivableTableData: function (component, returnValue, helper) {
		var projectId = component.get("v.foundationId");
		var daysFromPurchaseDate = [];
		daysFromPurchaseDate.push(component.get("v.daysFromPurchaseDate"));
		component.find("service")
			.callApex(component, helper,
				"c.getAccountReceivableTableDetails", {
					"foundationId": projectId,
					"daysFromPurchaseDate": JSON.stringify(daysFromPurchaseDate),
					"applyLimit": true,
					"operator": null,
					"isList": false
				},
				this.getAccountReceivableTableDataSuccess);
	},

	getAccountReceivableTableDataSuccess: function (component, returnValue, helper) {
		if (returnValue) {
			if (returnValue.length > 0) {
				component.set("v.hasTableData", true);
			} else {
				component.set("v.hasTableData", false);
			}

			var cols = [{
					label: 'Purchase Hisory Name',
					fieldName: 'assetLink',
					type: 'link',
					sortable: true,
					attributes: {
						label: {
							fieldName: 'Name'
						},
						title: "Click to View(New Window)",
						target: '_blank'
					}
				},
				{
					label: "Purchase Date",
					fieldName: "PurchaseDate",
					type: "date",
					sortable: true
				},
				{
					label: "Revenue",
					fieldName: "Price",
					type: "number",
					attributes: {
						formatter: "currency",
						currencyCode: "USD"
					},
					sortable: true
				}
			];
			component.set("v.columns", cols);

			returnValue.forEach(rec => {
				rec.assetLink = '/' + rec.Id;
			});

			component.set("v.chartTableData", returnValue);
		}
		component.set("v.loaded", false);
	},
})