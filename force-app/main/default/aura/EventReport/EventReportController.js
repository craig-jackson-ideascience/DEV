/**
 * Created by CR on 13-07-2020.
 */
({

    doInit : function(component,event,helper){
        helper.doInitHelper(component,event,helper);
    },

    handleRunReport : function(component,event,helper){
        helper.handleRunReportHelper(component,event,helper);
    },

    handleExport : function(component,event,helper){
        helper.handleExportHelper(component,event,helper);
    },

    renderPage : function(component,event,helper){
        helper.renderPage(component);
    }

})