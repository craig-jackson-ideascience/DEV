({
	getAllEvents: function (component, event, helper) {
		component.find("service").callApex(component, helper, "c.getAllCNCFEvents", {}, this.getAllEventsSuccess);
	},

	getAllEventsSuccess: function (component, returnValue, helper) {
		/* to sort based on total price */
		if (returnValue) {
			var returnRecords = JSON.parse(returnValue);
			returnRecords.forEach(event => {
				event.StageValue.sort((a, b) => {
					return b.totalPrice - a.totalPrice;
				});
			});
			returnRecords.forEach(event => {
				var listOfTotalPrice = [],
					listOfStageName = [],
					listOfColor = [];
				event.StageValue.forEach(stage => {
					listOfTotalPrice.push(stage.totalPrice);
					listOfStageName.push(stage.stageName);
					listOfColor.push(stage.stageColor);
					event.StageValue.listOfTotalPrice = listOfTotalPrice;
					event.StageValue.listOfStageName = listOfStageName;
					event.StageValue.listOfColor = listOfColor;
					var chart = JSON.parse(event.chart);
					chart.listOfTotalPrice = listOfTotalPrice;
					chart.listOfStageName = listOfStageName;
					chart.listOfColor = listOfColor;
					chart.tooltipMap = chart.tooltipMap;
					chart.eventName = chart.eventName;
					chart.mapOfEventVsTotal = chart.mapOfEventVsTotal
					event.chart = JSON.stringify(chart);
				})

			});
			component.set("v.listOfAllEvent", returnRecords);
			component.set("v.listOfEvent", JSON.parse(JSON.stringify(returnRecords)));
			component.set("v.chartData", returnValue);
			component.set("v.showSpinner", false);
		}
	},

	handleChartClickEvent: function (component, event, helper) {
		var chartValue = event.getParam("clickedValue");
		component.set("v.selectedStage", chartValue);
		var chartId = event.getParam("chartId");
		var listOfEvent = component.get("v.listOfEvent");
		var indexVar = 0, innerLoop = 0;
		var allEvents = component.get("v.listOfAllEvent");
		listOfEvent.forEach(event => {
			if (event.eventName == chartId) {
				if (event.selectedStage == chartValue) {
					var listOfAllEvent = allEvents[indexVar];
					event.selectedStage = null;
					event.StageValue = listOfAllEvent.StageValue;
				} else {
					event.StageValue.forEach(stage => {
						if (stage.stageName == chartValue) {
							event.selectedStage = chartValue;
							stage.totalPrice = allEvents[indexVar].StageValue[innerLoop].totalPrice;
						} else {
							stage.totalPrice = null;
						}
                        innerLoop++;
					});
				}
			}
			indexVar++;
		});
		component.set("v.listOfAllEvent", JSON.parse(JSON.stringify(allEvents)));
		component.set("v.listOfEvent", listOfEvent);
		component.set("v.showSpinner", false);
	}
})