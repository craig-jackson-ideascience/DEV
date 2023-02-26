({
	doInit : function(component, event, helper) {
		helper.getColumns(component,event,helper);
	},
    handleRowSelect : function(component,event,helper){
        helper.handleRowSelectHelper(component,event,helper);
    },
    handleSort : function(component,event,helper){
        helper.handleSortHelper(component,event,helper);
    },
    filter : function(component,event,helper){
        helper.filterHelper(component,event,helper);
    },
    removeProductFromList : function(component,event,helper){
        helper.removeProductFromListHelper(component,event,helper);
    }
})