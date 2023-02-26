({
    productByFoundation: function(component, event, helper) { 
        var selectedFoundation = event.getParam('selectedProject');
        if(selectedFoundation!=null){
            component.set('v.isPProjectDisplay',true);  
        }        
        component.set("v.ProductFoundationFilterData",'');
        var filtData='{"datasets": {"PurchaseHistoryDS": [{"fields": ["Projects__c.Id"],"filter": {"operator": "matches", "values":["'+selectedFoundation.Id+'"] } } ]} }';
        component.set("v.ProductFoundationFilterData",filtData);
        window.setTimeout(
            $A.getCallback(function() {
                //alert(component.isValid());
                if(component.isValid()){
                    var arEvnt = $A.get('e.c:waveAccountReceivableEvent');
                    arEvnt.setParams({
                        "selectedProject" : selectedFoundation
                    });
                    arEvnt.fire();
                }
            }), 6000
        );
        /* 
        helper.callAR(component, selectedFoundation).then(
            // resolve handler
            $A.getCallback(function(result) { 
                //alert(selectedProj.Id +'INNNNN');
                window.setTimeout(
                    $A.getCallback(function() {
                        //alert(component.isValid());
                        if(component.isValid()){
                            var arEvnt = $A.get('e.c:waveAccountReceivableEvent');
                            arEvnt.setParams({
                                "selectedProject" : selectedProj
                            });
                            arEvnt.fire();
                        }
                    }), 6000
                );
            }),
            // reject handler
            $A.getCallback(function(error) {
                console.log("Promise was rejected: ", error);
            })
        )*/
    }
})