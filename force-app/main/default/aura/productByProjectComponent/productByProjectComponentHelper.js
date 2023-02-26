({
    callAR:function(component,selectedProj){
        return new Promise($A.getCallback(function(resolve, reject) {
            
            if(selectedProj!=null){
                component.set('v.isDisplay',true);  
            }        
            component.set("v.ProductFoundationFilterData",'');
            var filtData='{"datasets": {"PurchaseHistory_DS": [{"fields": ["Projects__c.Id"],"filter": {"operator": "matches", "values":["'+selectedProj.Id+'"] } } ]} }';
            component.set("v.ProductFoundationFilterData",filtData);
            
            if (component.get("v.ProductFoundationFilterData").length>0){
                resolve("Resolved");
            }else {
                reject("Rejected");
            }
        }));  
    }
})