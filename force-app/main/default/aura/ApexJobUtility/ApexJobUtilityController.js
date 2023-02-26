({
    //Init Method
	doInit : function(component, event, helper) {
		helper.initHelper(component, event, helper);
	},
    
    //Render Method
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },
    
    //Method called when execute button is clicked
    executeTheJob : function(component, event, helper) {
		helper.executeJobHelper(component, event, helper);
	},
    
    //Method called when schedule button is clicked
    scheduleTheJob : function(component, event, helper) {
		helper.scheduleJobHelper(component, event, helper);
	},
    
    //Method called when Cancel button is clicked
    cancelTheSchedule : function(component, event, helper) {
		helper.cancelJobHelper(component, event, helper);
	},
    
    //Method called when View Settings button is clicked
    viewSettingsController: function(component, event, helper) {
		helper.viewSettingsHelper(component, event, helper);
	},
    
    //Method called when View All Scheduled button is clicked
     viewAllScheduledJobsController: function(component, event, helper) {
		helper.viewAllScheduledJobsHelper(component, event, helper);
	},
    
    //Method called when Monitor Jobs button is clicked
     viewMonitorJobsController: function(component, event, helper) {
		helper.viewMonitorJobsHelper(component, event, helper);
	},
    
    //Method called when Schedule All Jobs button is clicked
     executeAllJobsController: function(component, event, helper) {
		helper.executeAllJobsHelper(component, event, helper);
	},
    
    //Method called when Cancel All Jobs button is clicked
     cancelAllScheduledJobsController: function(component, event, helper) {
		helper.cancelAllScheduledJobsHelper(component, event, helper);
	},
})