({
    hadleSelection_helper : function(component, event, helper) {
        var params = event.getParams();
        var payload = params.payload;
        //console.log("payload:::::@SK==>"+payload);
        //console.log(JSON.stringify(payload));
        if (payload) {
            var step = payload.step;
            var data = payload.data;
            //console.log("data:::::@SK==>"+data);
            //console.log(JSON.stringify(data));
            data.forEach(function(obj) {
                for (var k in obj) {
                    if (k === 'InstallDate_Month') {
                        component.set("v.installDateMonth", obj[k]);                        
                    }
                }
            });
        }
        
        var installDateMonth = component.get("v.installDateMonth");
        //console.log("installDateMonth:::::@SK==>"+installDateMonth);
        helper.membershipDetails(component, event, helper);
    },
    
    membershipDetails: function(component, event, helper) {
        var installDateMonth = component.get("v.installDateMonth");
        var foundationRecord = component.get("v.foundationRecord");
        var foundationId = foundationRecord.Id;
        
        //console.log("installDateMonth:::::@SK==>"+installDateMonth);
        //console.log("foundationId:::::@SK==>"+foundationId);
        
        var action = component.get("c.getMembershipDetails");
        action.setParams({
            "foundationId": foundationId,
            "installDateMonth": installDateMonth
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log("state:New:::=>"+state);
            //$A.get('e.force:refreshView').fire();
            if (state === "SUCCESS") {
                //console.log("response.getReturnValue=====:::@SK::=> " + response.getReturnValue());
                //console.log("response.getReturnValue=====:::@SK::=> " + JSON.stringify(response.getReturnValue()));
                
                var oRes = response.getReturnValue();
                
                if(oRes != null && oRes.length > 0 && oRes != undefined) {
                    component.set("v.membershipDetails", oRes);
                    component.set("v.ifNoRecordsFound",false);
                    var membershipDetails = component.get("v.membershipDetails");
                    console.log("membershipDetails=====:::@SK::=>");
                    console.log(membershipDetails);
                    
                }
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
                component.set("v.ifNoRecordsFound",true);
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