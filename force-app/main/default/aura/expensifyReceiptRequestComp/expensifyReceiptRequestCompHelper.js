({
    fetchReceipt_helper : function(component, event, helper) {
        console.log('Record ID ::: => '+component.get("v.recordId"));
        var action = component.get("c.fileName");
        action.setParams({
            travelFundId: component.get("v.recordId"),
            result: component.get("v.returnResult")
        });        
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('result  ::: => '+result);
            if(result != null) {
                var state = response.getState();
                console.log('state  ::: => '+state);
                console.log('result  ::: => '+result);
                if(state==="SUCCESS" && result===true){
                    helper.showToastSuccess(component, event, helper);
                    $A.get('e.force:refreshView').fire();       
                    component.set("v.msg","Receipt Fetched!!");
                    window.setTimeout(
                        $A.getCallback(function() {
                            $A.get("e.force:closeQuickAction").fire();
                        }), 2000
                    );
                } else {
                    helper.showToastError(component, event, helper);
                    component.set("v.msg","Receipt are not fetched due to ERROR!!");
                    window.setTimeout(
                        $A.getCallback(function() {
                            $A.get("e.force:closeQuickAction").fire();
                        }), 2000
                    );
                }
            } else {
                helper.showToastWarning(component, event, helper);
                component.set("v.msg","NO Report is created!!");
                window.setTimeout(
                    $A.getCallback(function() {
                        $A.get("e.force:closeQuickAction").fire();
                    }), 2000
                );
                
            }
        });
        $A.enqueueAction(action);
    },
    
    /*showToastInfo : function(component, event, helper) {
        component.find('notifLib').showToast({
            "variant": "info",
            "title": "Notif library Info!",
            "message": "The record has been updated successfully."
        });
    },*/
    
    showToastWarning : function(component, event, helper) {
        component.find('notifLib').showToast({
            "variant": "warning",
            "title": "Warning!",
            "message": "Receipts are not fetched. Something went wrong."
        });
    },
    
    showToastSuccess : function(component, event, helper) {
        component.find('notifLib').showToast({
            "variant": "success",
            "title": "Success!",
            "message": "Receipts are fetched successfully."
        });
    },
    
    showToastError : function(component, event, helper) {
        component.find('notifLib').showToast({
            "variant": "error",
            "title": "Error!",
            "message": "Receipts are not fetched. Something went wrong."
        });
    },
})