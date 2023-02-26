({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.getAllEvents(component, event, helper);
    },

    handlerChartClickEvent : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.handleChartClickEvent(component, event, helper);
    }
})