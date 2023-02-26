({
	handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            helper.handleRecordUpdatedHelper(component,event,helper);
        }
    },
    handleConvert : function(component,event,helper){
        helper.handleConvertHelper(component,event,helper);
    },
    handleMerge : function(component,event,helper){
        helper.handleMergeHelper(component,event,helper);
    }
})