({
    handleDoInit : function(component,event,helper){
        component.find("service").callApex(component, helper, "c.getDocuSignStatus", {
            "opportunityId" : component.get('v.recordId')}, this.doInitSuccess);
    },
    doInitSuccess : function(component,returnValue,helper){
        if(returnValue == ''){
            $A.get("e.force:closeQuickAction").fire();
            helper.showToast("Error","Error!","No Contract Found");
        }
        else{
            component.set("v.envelopeId", returnValue);
        }
        
    },
    handleSaveHelper : function(component,event,helper){
       
        if(!$A.util.isUndefinedOrNull(component.find('field').get('v.value'))){
            component.find("service").callApex(component, helper, "c.voidEnvelope", {
                "envelopeId" : component.get('v.envelopeId') ,
                 "reason" : component.find('field').get('v.value'),
                "opportunityId" : component.get('v.recordId')},
                 this.saveHelperSuccess);
        }
        else{
           return;
         }
        
    },
    saveHelperSuccess : function(component,returnValue,helper){
        $A.get("e.force:closeQuickAction").fire();
        if(returnValue == 'OK'){
            helper.showToast("Success","Success","Contract is voided successfully");
        }
        else{
            helper.showToast("Error","Error!","Some Error occurred.");
        }
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