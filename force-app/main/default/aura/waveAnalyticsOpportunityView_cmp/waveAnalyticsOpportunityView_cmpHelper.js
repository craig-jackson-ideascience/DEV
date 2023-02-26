({
    onPageReferenceChange_helper : function(component, event, helper, sortField) {
        console.log('onPageReferenceChange_helper:::');
        var foundationId = component.get("v.foundationId");
        //console.log('foundationId:::@SK=>' + foundationId);
        //
        var action = component.get("c.getOpportunityDetails");
        action.setParams({
            "foundationId": foundationId,
            "sortField": sortField,
            "isAsc": component.get("v.isAsc")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state::::=>"+state);
            //$A.get('e.force:refreshView').fire();
            if (state === "SUCCESS") {
                //console.log("response.getReturnValue=====:::@SK::=> " + response.getReturnValue());
                //console.log("response.getReturnValue=====:::@SK::=> " + JSON.stringify(response.getReturnValue()));
                
                var oRes = response.getReturnValue();
                
                if(oRes != null && oRes.length > 0 && oRes != undefined) {
                    component.set("v.opportunityList", oRes);
                    var oppDetails = component.get("v.opportunityList");
                    console.log("oppDetails=====:::@SK::=>");
                    console.log(oppDetails);
                    
                }
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
            } 
                else if (state === "ERROR") {
                    //  $A.get('e.force:refreshView').fire();
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
    },
    
    sortHelper: function(component, event, helper, sortFieldName) {
        var currentDir = component.get("v.arrowDirection");
        
        if (currentDir == 'arrowdown') {
            // set the arrowDirection attribute for conditionally rendred arrow sign  
            component.set("v.arrowDirection", 'arrowup');
            // set the isAsc flag to true for sort in Assending order.  
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        // call the onLoad function for call server side method with pass sortFieldName 
        this.onPageReferenceChange_helper(component, event, helper, sortFieldName);
    },
})