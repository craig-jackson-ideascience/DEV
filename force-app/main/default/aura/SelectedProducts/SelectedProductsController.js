/**
 * Created by ANT-MAN on 12-05-2020.
 */
({
    doInit : function(component,event,helper){
        helper.doInitHelper(component,event,helper);
    },
    
    handleRowAction : function(component,event,helper){
        helper.removeProductHelper(component,event,helper);
    }
})