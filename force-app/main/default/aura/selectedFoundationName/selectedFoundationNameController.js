({
	doInit : function(component, event, helper) {
        helper.doInit_helper(component, event, helper);
        //console.log(" doInit HERE ");
    },
    
    foundationId: function(component, event, helper) {
        var fndtnId = event.getParam('selectedProject');
        //console.log('fndtnId:::'+fndtnId);
        component.set("v.foundationId",fndtnId.Id);
        helper.doInit_helper(component, event, helper);
    },
})