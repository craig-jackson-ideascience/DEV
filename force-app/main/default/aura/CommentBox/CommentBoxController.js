({
    doint : function(component, event, helper) {
        
    },
    cancel:function(cmp, event, helper) {
        cmp.set("v.fields", "");

    },
    handleLoad: function(cmp, event, helper) {
        
    },

    handleSubmit: function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    handleError: function(cmp, event, helper) {
        
    },

    handleSuccess: function(cmp, event, helper) {
        cmp.find('notifLib').showToast({
            "title": "Record updated!",
            "message": "The record "+ event.getParam("id") + " has been updated successfully.",
            "variant": "success"
        });
        
    },
    
   /* handleSuccess: function (cmp, event, helper) {
        cmp.find('notifLib').showToast({
            "title": "Record updated!",
            "message": "The record "+ event.getParam("id") + " has been updated successfully.",
            "variant": "success"
        });
    },

    handleError: function (cmp, event, helper) {
        cmp.find('notifLib').showToast({
            "title": "Something has gone wrong!",
            "message": event.getParam("message"),
            "variant": "error"
        });
    },
    */
    foundationId: function (cmp, event, helper){
        var fndtnId = event.getParam('selectedProject');
        //console.log('fndtnId:::'+fndtnId);
        cmp.set("v.foundationId",fndtnId.Id);
        helper.doInit_helper(cmp, event, helper);
    }
})