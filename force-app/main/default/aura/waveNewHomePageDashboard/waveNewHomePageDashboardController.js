({
	filteronOnPurchaseHistory: function(component, event, helper) {
        var selectedProj = event.getParam('selectedProject');
        component.set("v.foundationRecord",selectedProj);
        //alert(selectedProj.Id);
        helper.serverSideCall(component, selectedProj).then(
            // resolve handler
            $A.getCallback(function(result) { 
                //alert(selectedProj.Id +'INNNNN');
                window.setTimeout(
                    $A.getCallback(function() {
                        //alert(component.isValid());
                        if(component.isValid()){
                            var evnt1 = $A.get('e.c:waveAccountReceivableEvent');
                            evnt1.setParams({
                                "selectedProject" : selectedProj
                            });
                            evnt1.fire();
                        }
                    }), 6000
                );
            }),
            // reject handler
            $A.getCallback(function(error) {
                console.log("Promise was rejected: ", error);
            })
        )  
    },
    
    viewAll: function(component , event, helper) {
        helper.viewAll_helper(component, event, helper);
    },
})