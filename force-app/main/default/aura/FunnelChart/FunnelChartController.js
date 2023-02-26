({
	doInit: function (component, event, helper) {
		component.set("v.showSpinner", true);
		window.setTimeout((function () {
			var response = component.get("v.chartJson");
			
			if (!$A.util.isUndefinedOrNull(response)) {
				helper.drawChart(component, JSON.parse(response));
			}
		}), 10000);
	}
})