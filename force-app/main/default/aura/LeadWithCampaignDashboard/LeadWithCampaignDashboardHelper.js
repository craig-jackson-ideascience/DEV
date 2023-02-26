({
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