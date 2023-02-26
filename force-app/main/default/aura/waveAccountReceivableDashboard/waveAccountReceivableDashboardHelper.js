({
    serverSideCall:function(component,selectedProj){
        return new Promise($A.getCallback(function(resolve, reject) {
            //alert(selectedProj.Id);
            // do something
            component.set("v.waveAccountReceivableData",'');
            var waveAccountReceivableData='{"datasets": {"PurchaseHistoryOpty": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedProj.Id+'"] } } ],"PurchaseHistoryDS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedProj.Id+'"] } } ], "PurchaseHistory_DS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedProj.Id+'"] } } ] } }';
            component.set("v.waveAccountReceivableData",waveAccountReceivableData);
            var AccountReceivableData = component.get("v.waveAccountReceivableData");
            //console.log('purchaseHistoryData: ',component.get("v.purchaseHistoryData").length)
            if (component.get("v.waveAccountReceivableData").length>0){
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
        console.log('foundationName'+foundationName);
        var navService = component.find("navService");        
        var pageReference = {
            type: "standard__component",
            attributes: {
                componentName: "c__waveARList"
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