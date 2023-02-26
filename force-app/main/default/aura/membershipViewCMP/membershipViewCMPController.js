({
	foundationId: function(component, event, helper) {
        var selectedProject = event.getParam('selectedProject');

        component.set("v.foundationRecord",selectedProject);
	},
    
    handleSelection : function(component, event, helper) {
		helper.hadleSelection_helper(component, event, helper);
	},
})