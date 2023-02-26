({
	doInit : function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
        //console.log('myPageRef:::'+myPageRef);
        var fId = myPageRef.state.c__foundationId;
        var filtData='{"datasets": {"PurchaseHistoryDS": [{"fields": ["Projects__c.Id"],"filter": {"operator": "matches", "values":["'+fId+'"] } } ]} }';
      	component.set("v.filterData",filtData);
        
        helper.doInit_helper(component, event, helper, fId);
	}
})