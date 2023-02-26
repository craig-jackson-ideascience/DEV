({
	handleDoInit : function(component,event,helper){
        component.find("service").callApex(component, helper, "c.getEnvelopeId", {
            "opportunityId" : component.get('v.recordId')}, this.doInitSuccess);
    },
    doInitSuccess : function(component,returnValue,helper){
        if(returnValue == ''){
            helper.showToast("Error","Error!","No Contract Found");
        }
        else if(returnValue = 'OK'){
            helper.showToast("Success","Success","Mail sent successfully");
        }
            else{
                helper.showToast("Error","Error!","Some Error Occurred");
            }
       $A.get("e.force:closeQuickAction").fire(); 
    },
    showToast: function(type,title,message){
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": type,
                "title": title,
                "message":message
            });
            toastEvent.fire();
    }
})