({
	serverSideCall:function(component,selectedProj){
        return new Promise($A.getCallback(function(resolve, reject) {
          // alert('ting'+selectedProj.Id);
            // do something
            component.set("v.filterData",'');
            //var filterData='{"datasets": {"PurchaseHistory_DS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedProj.Id+'"] } } ], "PurchaseHistoryDS": [{"fields": ["Proj"], "filter": {"operator": "matches", "values":["'+selectedProj.Id+'"] } } ] } }';
            var filterData='{"datasets": {"PurchaseHistory_DS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedProj.Id+'"] } } ], "PurchaseHistoryDS": [{"fields": ["Proj"], "filter": {"operator": "matches", "values":["'+selectedProj.Id+'"] } } ],"Opty_His_1": [{"fields": ["Project_Name__c"], "filter": {"operator": "matches", "values":["'+selectedProj.Id+'"] } } ] } }';
            component.set("v.filterData",filterData);
            var purchaseHistoryData = component.get("v.filterData");
            //console.log('purchaseHistoryData: ',component.get("v.purchaseHistoryData").length)
            if (component.get("v.filterData").length>0){
                resolve("Resolved");
            }else {
                reject("Rejected");
            }
        }));
    },
    
    viewAll_helper: function(component, event, helper) {
        
        var foundationRecord = component.get("v.foundationRecord");
        var foundationId = foundationRecord.Id;
        var navService = component.find("navService");        
        var pageReference = {
            type: "standard__component",
            attributes: {
                componentName: "c__waveMambershipGrowthList"
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