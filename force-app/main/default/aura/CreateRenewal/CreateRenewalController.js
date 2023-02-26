({
	handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            helper.showContent(component,event,helper);
        }
    },
    handleCancel : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    handleOk : function(component,event,helper){
        helper.handleOkHelper(component,event,helper);
       
    }
})