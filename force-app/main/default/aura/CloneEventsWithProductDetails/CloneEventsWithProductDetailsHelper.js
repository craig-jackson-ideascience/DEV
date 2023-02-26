({
	doInitHelper : function(component,event,helper) {
        component.find("service").callApex(component, helper, "c.clone_method", {
            "evtId" : component.get('v.recordId')
        }, this.doInitHelperSuccess);
	},
    doInitHelperSuccess : function(component,eventId,helper){
        if(eventId.startsWith('a0A')){
            var navigationEvent = $A.get("e.force:navigateToSObject");
            navigationEvent.setParams({
                "recordId": eventId,
                "slideDevName": "detail"
            });
            navigationEvent.fire();
        }else{
            helper.showToast("Error!","error",eventId);
        }
    },
     showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }
})