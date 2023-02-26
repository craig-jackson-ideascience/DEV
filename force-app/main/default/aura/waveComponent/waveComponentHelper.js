({
    serverSideCall:function(component,selectedProj){
        return new Promise($A.getCallback(function(resolve, reject) {
            //alert(selectedProj.Id);
            // do something
            component.set("v.purchaseHistoryData",'');
            var filtData='{"datasets": {"PurchaseHistory_DS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedProj.Id+'"] } } ], "PurchaseHistoryDS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedProj.Id+'"] } } ] } }';
            component.set("v.purchaseHistoryData",filtData);
            var purchaseHistoryData = component.get("v.purchaseHistoryData");
            //console.log('purchaseHistoryData: ',component.get("v.purchaseHistoryData").length)
            if (component.get("v.purchaseHistoryData").length>0){
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
                componentName: "c__membershipViewCMP"
            },
            state: { 
                "c__foundationId" : foundationId,
                "c__foundationName" : foundationName
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