/**
 * Created by cloudroute on 22/09/20.
 */
({
    doInit : function(component, event, helper){
        helper.fetchFileName(component,event,helper);
        helper.doInitHelper(component,event,helper);
    }
})