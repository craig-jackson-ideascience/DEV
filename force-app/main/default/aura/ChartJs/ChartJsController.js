/**
 * Created by cloudroutesolutions on 20/01/21.
 */
({
	afterChartJsLoaded: function (component, event, helper) {
		try {
			var response = component.get("v.chartJson");
			if (!$A.util.isUndefinedOrNull(response) && JSON.parse(response).datasets.length > 0 && JSON.parse(response).datasets[0].datainPercent.length > 0) {
				if (component.get("v.isGroupedStackedBar")) {
					helper.prepareStackGroupBarChart(component);
				}
				helper.drawChart(component, JSON.parse(response), {
					legend: {
						display: false
					}
				});

			}
		} catch (err) {
			console.log('#--errorr--#' + err);
		}
	}
})