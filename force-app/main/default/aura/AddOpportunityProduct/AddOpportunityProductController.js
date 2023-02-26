({
	doInit : function(component, event, helper) {
		helper.fetchOpportunityTypes(component,event,helper);
	},
    handleProductTypeChange : function(component,event,helper){
        helper.handleProductTypeChangeHelper(component,event,helper);
    },
    handleProductCategoryChange : function(component,event,helper){
        helper.handleProductCategoryChangeHelper(component,event,helper);
    },
    handleProjectChange : function(component,event,helper){
        helper.handleProjectChangeHelper(component,event,helper);
    },
    handleCancel : function(component,event,helper){
        helper.handleCancelHelper(component,event,helper);
    },
    handleInsert : function(component,event,helper){
        helper.handleInsertHelper(component,event,helper);
    }
})