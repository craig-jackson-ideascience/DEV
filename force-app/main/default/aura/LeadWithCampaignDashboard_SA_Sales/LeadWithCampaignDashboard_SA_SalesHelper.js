({
    serverSideCall:function(component,selectedFoundation){
        return new Promise($A.getCallback(function(resolve, reject) {
            //alert(selectedProj.Id);
            // do something
            component.set("v.dashboardData",'');
            var dashboardData='{"datasets": {"Leads_With_CampaignMember": [{"fields": ["CampaignId.Project__c.Id"], "filter": {"operator": "matches", "values":["'+selectedFoundation.Id+'"] } } ] } }';
            component.set("v.dashboardData",dashboardData);
            var LeadsWithCampaignMemberdashboardData = component.get("v.dashboardData");
            console.log('LeadsWithCampaignMemberdashboardData: ',LeadsWithCampaignMemberdashboardData);
            if (component.get("v.dashboardData").length>0){
                resolve("Resolved");
            }else {
                reject("Rejected");
            }
        }));
    },
    
	viewAll_helper: function(component, event, helper) {
        var foundationRecord = component.get("v.foundationRecord");
        var foundationId = foundationRecord.Id;
        var foundationName = foundationRecord.Name;
        var navService = component.find("navService");        
        var pageReference = {
            type: "standard__component",
            attributes: {
                componentName: "c__waveLeadWithCampaignDashboard"
            },
            state: { 
                "c__foundationId" : foundationId
            }
        };
        component.set("v.pageReference", pageReference);
        
        const handleUrl = (url) => {
            window.open(url);
        };
        const handleError = (error) => {
            console.log(error);
        };
            navService.generateUrl(pageReference).then(handleUrl, handleError);
    },
})