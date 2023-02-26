/**
 * Created by cloudroutesolutions on 24/03/21.
 */
({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.initHelper(component, event, helper);
    },
    handleEventChange: function(component, event, helper) {
        helper.handleEventChangeHelper(component, event, helper);
    },
})