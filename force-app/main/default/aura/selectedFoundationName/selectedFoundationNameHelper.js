({
    doInit_helper : function(component, event, helper) {
        var foundationId = component.get("v.foundationId");
        //console.log('foundationName foundationId:::@SK=>' + foundationId);
        
        var action = component.get("c.getFoundationName");
        action.setParams({
            "foundationId": foundationId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log("foundationName state::::=>"+state);
            //$A.get('e.force:refreshView').fire();
            if (state === "SUCCESS") {
                //console.log("response.getReturnValue=====:::@SK::=> " + response.getReturnValue());
                //console.log("response.getReturnValue=====:::@SK::=> " + JSON.stringify(response.getReturnValue()));
                
                var oRes = response.getReturnValue();
                component.set("v.foundationName", oRes);
                var fName = component.get("v.foundationName.Name");
                //console.log("fName=====:::@SK::=>");
                //console.log(fName);
                
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
})