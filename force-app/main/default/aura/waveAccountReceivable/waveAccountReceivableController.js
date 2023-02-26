({
    filteronOnAR: function(component, event, helper) {        
        var selectedFoundation = event.getParam('selectedProject');
        console.log('>>>>>:: '+selectedFoundation+' Id>>>>> ' +selectedFoundation.Id );
        
        if(selectedFoundation!=null){
            component.set('v.isWADisplay',true);  
        }        
        component.set("v.waveAccountReceivableData",'');
        var filtData='{"datasets": {"PurchaseHistory_DS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedFoundation.Id+'"] } } ], "PurchaseHistoryDS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedFoundation.Id+'"] } } ] } }';
        component.set("v.waveAccountReceivableData",filtData);       
    }
})