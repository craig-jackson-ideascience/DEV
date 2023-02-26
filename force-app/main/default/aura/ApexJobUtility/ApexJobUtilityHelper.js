({
    //Init Method
    initHelper : function(component, event, helper) {
        component.set('v.showSpinner',true);
        component.find("service").callApex(component, helper, "c.init", {},
                                           this.initSucess);
    },
    
    //Success Method
    initSucess : function(component,returnValue,helper){
        console.log(JSON.parse(returnValue));
        var responseData = JSON.parse(returnValue);
        var records =responseData['Success'];
        
        //If Successful
        if(responseData['Success'] != null){
            var pageSize = component.get("v.pageSize");
            component.set('v.configuredJobs',records);
            component.set("v.totalRecords", records.length);
            component.set("v.maxPage", Math.ceil((records.length) / pageSize));
            helper.renderPage(component)
            component.set('v.showSpinner',false);
        }else{
            //To Display error Message
            component.set('v.showSpinner',false);
            helper.showToast('Error!','error',responseData['Error']);
        }
        
        //To Display Success Message
        if(responseData['SuccessMessage'] != null){
            helper.showToast('Success!','success',responseData['SuccessMessage']);
        }
        
    },
    
    //Render Method
    renderPage: function(component) {
        //Setting the paginationList
        var pageSize = component.get("v.pageSize");
        var records = component.get("v.configuredJobs"),
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
        component.set("v.PaginationList", pageRecords);  
    },
    
    //Execute Method
    executeJobHelper : function(component, event, helper) {
        component.set('v.showSpinner',true);
        helper.getSelectedJob(component, event, helper);
        component.find("service").callApex(component, helper, "c.executeJob", 
                                           {"selectedJob" : JSON.stringify(component.get('v.selectedJob'))} ,
                                           this.initSucess);
    },
    
    //Schedule Method
    scheduleJobHelper : function(component, event, helper) {
        component.set('v.showSpinner',true);
        helper.getSelectedJob(component, event, helper);
        component.find("service").callApex(component, helper, "c.scheduleJob", 
                                           {"selectedJob" : JSON.stringify(component.get('v.selectedJob'))} ,
                                           this.initSucess);
    },
    
    //Cancel method
    cancelJobHelper : function(component, event, helper) {
        component.set('v.showSpinner',true);
        helper.getSelectedJob(component, event, helper);
        component.find("service").callApex(component, helper, "c.cancelSchedule", 
                                           {"selectedJob" : JSON.stringify(component.get('v.selectedJob'))} ,
                                           this.initSucess);
    },
    
    //View Settings Method
    viewSettingsHelper : function(component,event,helper){
        component.find("service").callApex(component, helper, "c.viewSettings", 
                                           {} ,
                                           this.actionSuccess);
    },
    
    //View All Scheduled Job Method
    viewAllScheduledJobsHelper : function(component,event,helper){
        component.find("service").callApex(component, helper, "c.viewAllScheduledJobs", 
                                           {"actionType" : event.getSource().get('v.name')} ,
                                           this.actionSuccess);
    },
    
    //Monitor job Method
    viewMonitorJobsHelper : function(component,event,helper){
        component.find("service").callApex(component, helper, "c.viewMonitorJobs", 
                                           {} ,
                                           this.actionSuccess);

        /*var navService = component.find("navService");
        var pageReference ={    
            "type": "standard__objectPage",
            "attributes": {
                "objectApiName": "AsyncApexJob",
                "actionName": "list"
            },
            "state": {
                "filterName": "00B6s000000MviiEAC"
          }
        };
            navService.navigate(pageReference);*/
       
    },
    
    //Scheduling All Jobs Method
    executeAllJobsHelper : function(component,event,helper){
        component.set('v.showSpinner',true);
        component.find("service").callApex(component, helper, "c.scheduleAllJobs", 
                                           {"configuredJobs" : JSON.stringify(component.get('v.configuredJobs'))},
                                           this.initSucess);
    },
    
    //Canceling All Scheduled Job
    cancelAllScheduledJobsHelper : function(component,event,helper){
        component.set('v.showSpinner',true);
        component.find("service").callApex(component, helper, "c.cancelAllScheduledJobs", 
                                           {"configuredJobs" : JSON.stringify(component.get('v.configuredJobs'))},
                                           this.initSucess);
    },
    
    //Method to redirect at specified url returned from apex
    actionSuccess : function(component,returnValue,helper){
        component.find("navService").navigate({    
            "type": "standard__webPage",
            "attributes": {
                "url": returnValue // url returned from apex
            }
        })
    },
    
    //Method to Get the Selected Job
    getSelectedJob : function(component, event, helper) {
        var rowIndex = event.getSource().get('v.name');
        component.set('v.selectedJob',component.get('v.PaginationList')[rowIndex]);
    },
    
    //Method to Show Toast
    showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },
    
})