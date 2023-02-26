({
	doInit : function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
        //console.log('myPageRef:::'+myPageRef);
        var fId = myPageRef.state.c__foundationId;
        component.set("v.filterData",'');
        var filtData='{"datasets": {"Leads_With_CampaignMember": [{"fields": ["CampaignId.Project__c.Id"], "filter": {"operator": "matches", "values":["'+fId+'"] } } ] } }';
        component.set("v.filterData",filtData);
        helper.doInit_helper(component, event, helper, fId);
	}
})