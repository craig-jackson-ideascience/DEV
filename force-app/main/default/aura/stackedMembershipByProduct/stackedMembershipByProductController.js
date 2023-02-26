({
    filteronOnStackedMembership: function(component, event, helper) {        
        var selectedFoundation = event.getParam('selectedProject');
        component.set('v.foundationRecord',selectedFoundation); 
        console.log('>>>>5>:: '+selectedFoundation+' Id>>5>>> ' +selectedFoundation.Id );
        
        if(selectedFoundation!=null){
            component.set('v.isWADisplay',true);  
        }        
        component.set("v.dashboardData",'');
        var dashboardData='{"datasets": {"PurchaseHistoryDS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedFoundation.Id+'"] } } ] } }';
        component.set("v.dashboardData",dashboardData);     
        
    },
})