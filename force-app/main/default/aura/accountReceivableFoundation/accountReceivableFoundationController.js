({
	filteronOnPurchaseHistory : function(component, event, helper) {
		var selectedProject = event.getParam('selectedProject');
        component.set("v.purchaseHistoryData",'');
        var filtData='{"datasets": {"DaysPurchaseHistory_DS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedProject.Id+'"] } } ]} }';
        component.set("v.purchaseHistoryData",filtData);
	}
})