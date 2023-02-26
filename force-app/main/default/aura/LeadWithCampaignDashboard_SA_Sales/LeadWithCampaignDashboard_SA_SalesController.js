({
    filteronOnLeadWithCampaign: function(component, event, helper) {        
        var selectedFoundation = event.getParam('selectedProject');
        component.set('v.foundationRecord',selectedFoundation); 
        console.log('>>>>>:: '+selectedFoundation+' Id>>>>> ' +selectedFoundation.Id );
        
        helper.serverSideCall(component, selectedFoundation).then(
            // resolve handler
            $A.getCallback(function(result) { 
                //alert(selectedProj.Id +'INNNNN');
                window.setTimeout(
                    $A.getCallback(function() {
                        //alert(component.isValid());
                        if(component.isValid()){
                            var evnt1 = $A.get('e.c:StackedMembershipByProductEvent');
                            evnt1.setParams({
                                "selectedProject" : selectedFoundation
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
        
        /*if(selectedFoundation!=null){
            component.set('v.isWADisplay',true);  
        }        
        component.set("v.dashboardData",'');
        var filtData='{"datasets": {"Leads_With_CampaignMember": [{"fields": ["CampaignId.Project__c.Id"], "filter": {"operator": "matches", "values":["'+selectedFoundation.Id+'"] } } ] } }';
        component.set("v.dashboardData",filtData);     */
        
    },
    
    viewAll: function(component , event, helper) {
        helper.viewAll_helper(component, event, helper);
    },
})