/*
 * Controller of ApexJobUtility Component
 * Test Class - ApexJobUtilityControllerTest
*/
public class ApexJobUtilityController {
    // Instantiate Variables
    private static final string DELETED_STATE = 'DELETED';  
    
    //Init Method
    @AuraEnabled
    public static String init() {
        Map<String,Object> mapOfData = new Map<String,Object>();
        List<configuredJob> configuredJobs = new List<configuredJob>();
        try {
            //Call method to get the configuredJobs Map
            configuredJobs = getCurrentConfiguredJobs();
            system.debug('configuredJobs '+configuredJobs);
            mapOfData.put('Success',configuredJobs);
            
        } catch (System.exception ex) {
            mapOfData.put('Error','Some Error Occured');
        }
        return JSON.serialize(mapOfData);
    }           
    
    //Method to get the configuredJobs Map
    public static List<configuredJob> getCurrentConfiguredJobs() {
        
        // Retrieve the custom metadata and add to map
        Map<string, Campaign_Email_List__mdt> jobSettings = new Map<String, Campaign_Email_List__mdt>();
        List<Campaign_Email_List__mdt> utilitySettings = [
            SELECT
            DeveloperName,
            CampaignId__c,
            Cron_Expression__c,
            ContactId__c,
            LeadId__c,
           Query__c,
            Job_Run_Time__c
            FROM Campaign_Email_List__mdt
        ];
        
        // Iterate through and add each record to a map
        for (Campaign_Email_List__mdt setting : utilitySettings) {
            jobSettings.put(setting.DeveloperName, setting);
        }
        
        //call method to get the job which are scheduled
        Map<string, CronTrigger> schedules = getSchedules(jobSettings.keySet());
        Map<string, configuredJob> result = new Map<string, configuredJob>();
        
        //Iterate through metadata and create the wrapper that will be returned
        for (string jobName : jobSettings.keySet()) {
            Campaign_Email_List__mdt settings = jobSettings.get(jobName);
            if (schedules.containsKey(jobName)) {
                result.put(
                    jobName,
                    createConfiguredJob(
                        settings,
                        schedules.get(jobName)
                    )
                );
            } else {
                result.put(jobName, createConfiguredJob(settings,null));
            }
        }
        return result.values();
    }
    
    //Returns a list of schedules (cron triggers) mapped to their name
    private static Map<string, CronTrigger> getSchedules(
        Set<string> scheduledJobNames
    ) {
        Map<string, CronTrigger> result = new Map<string, CronTrigger>();
        for (CronTrigger schedule : [
            SELECT Id, NextFireTime, State, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name IN :scheduledJobNames AND State != :DELETED_STATE
        ]) {
            result.put(schedule.CronJobDetail.Name, schedule);
        }
        return result;
    }
    
    //Creates an instance of a configured job with the specified properties
    private static configuredJob createConfiguredJob(
        Campaign_Email_List__mdt jobSetting,
        CronTrigger currentSchedule
    ) {
        configuredJob result = new configuredJob();
        result.name = jobSetting.DeveloperName;
        result.query = jobSetting.Query__c;
        result.contactId	 = jobSetting.ContactId__c	;
        result.campaignId = jobSetting.CampaignId__c;
        result.cronExpression = jobSetting.Cron_Expression__c;
        result.leadId = jobSetting.LeadId__c;
        result.jobRunTime = jobSetting.Job_Run_Time__c;
        if (currentSchedule != null) {
            result.status = currentSchedule.state;
            result.isScheduled = true;
            result.nextFireTime = currentSchedule.NextFireTime;
            result.cronTriggerId = currentSchedule.Id;
        } else {
            result.isScheduled = false;
        }
        System.debug('result '+result);
        return result;
    }
    
    //  Executes the batch job specified in parameter
    @AuraEnabled
    public static String executeJob(String selectedJob) {
        Map<String,Object> mapOfData = new Map<String,Object>();
        try {
            configuredJob job = (configuredJob)JSON.deserialize(selectedJob, configuredJob.class);
            Database.executeBatch(new AddCampaignMembersGenericBatch(job.query, job.contactId, job.leadId, job.campaignId));
            
            mapOfData.put('SuccessMessage','Job is executed Successfully');
        } catch (System.exception ex) {
            System.debug('Exception---: ' + ex.getMessage()+'==AT==' + ex.getLineNumber());
            mapOfData.put('Error','Some error occured while executing the job');
        }
        return JSON.serialize(mapOfData);
        
    }
    
    // Schedules the a batch job to run as defined by the cron expression
    @AuraEnabled
    public static String scheduleJob(String selectedJob) {
        Map<String,Object> mapOfData = new Map<String,Object>();
        try {
            
            configuredJob job = (configuredJob)JSON.deserialize(selectedJob, configuredJob.class);
            if(job.cronExpression != null){
                System.Schedule(
                    job.name,
                    job.cronExpression,
                    new AddCampaignMembersGenericBatchScheduler(job.query, job.contactId, job.leadId, job.campaignId)
                );
                mapOfData.put('Success',getCurrentConfiguredJobs());
                mapOfData.put('SuccessMessage','Job is Scheduled Successfully');
            }else{
                mapOfData.put('Error','Cron Expression is blank for record');
            }
            
        } catch (System.exception ex) {
            System.debug('Exception---: ' + ex.getMessage()+'==AT==' + ex.getLineNumber());
            mapOfData.put('Error','Some Error Occured while scheduling the job');
        }
        return JSON.serialize(mapOfData);
    }
    
    //Cancels a schedule specified by parameter
    @AuraEnabled
    public static String cancelSchedule(String selectedJob) {
        Map<String,Object> mapOfData = new Map<String,Object>();
        try {
            
            configuredJob job = (configuredJob)JSON.deserialize(selectedJob, configuredJob.class);
            if (job.cronTriggerId == null) {
                mapOfData.put('Error','This job has not been scheduled');
            }else{
                System.abortJob(job.cronTriggerId);
                mapOfData.put('Success',getCurrentConfiguredJobs());
                mapOfData.put('SuccessMessage','Scheduled Job is canceled successfully');
            }
            
        } catch (System.exception ex) {
            System.debug('Exception---: ' + ex.getMessage()+'==AT==' + ex.getLineNumber());
            mapOfData.put('Error',ex.getMessage());
        }
        return JSON.serialize(mapOfData);
        
    }
    
    //Cancels all scheduled jobs
    @AuraEnabled
    public static String cancelAllScheduledJobs(String configuredJobs) {
        Map<String,Object> mapOfData = new Map<String,Object>();
        try {
            Boolean hasSchedule = false;
            List<configuredJob> configuredJobsList= (List<configuredJob>)JSON.deserialize(configuredJobs, List<configuredJob>.class);
            for (configuredJob job : configuredJobsList) {
                if (job.cronTriggerId != null) {
                    System.abortJob(job.cronTriggerId);
                    hasSchedule=true;
                }
            }
            String message = hasSchedule ? 'All Jobs get Canceled successfully' : 
            'No Jobs are Scheduled to cancel';
            mapOfData.put('Success',getCurrentConfiguredJobs());
            mapOfData.put('SuccessMessage',message);
        } catch (System.exception ex) {
            System.debug('Exception---: ' + ex.getMessage()+'==AT==' + ex.getLineNumber());
            mapOfData.put('Error',ex.getMessage());
        }
        return JSON.serialize(mapOfData);
    }
    
    //Schedules All job
    @AuraEnabled
    public static String scheduleAllJobs(String configuredJobs) {
        Map<String,Object> mapOfData = new Map<String,Object>();
        try {
            Boolean hasSchedule = false;
            List<configuredJob> configuredJobsList= (List<configuredJob>)JSON.deserialize(configuredJobs, List<configuredJob>.class);
            if (!configuredJobsList.isEmpty()) {
                for (configuredJob job : configuredJobsList) {
                    if (job.cronTriggerId == null) {
                        System.Schedule(
                            job.name,
                            job.cronExpression,
                            new AddCampaignMembersGenericBatchScheduler(job.query, job.contactId, job.leadId, job.campaignId)
                        );
                        hasSchedule=true;
                    }
                    
                }
                String message = hasSchedule ? 'All Jobs get Scheduled successfully' : 
                'Jobs are already scheduled ';
                mapOfData.put('Success',getCurrentConfiguredJobs());
                mapOfData.put('SuccessMessage',message);
            }
        } catch (System.exception ex) {
            System.debug('Exception---: ' + ex.getMessage()+'==AT==' + ex.getLineNumber());
            mapOfData.put('Error','Some Error Occured While scheduling the jobs');
        }
        return JSON.serialize(mapOfData);
    }
    
    //Returns a page reference to a list view for the custom settings
    @AuraEnabled
    public Static String viewSettings() {
        string keyPrefix = Campaign_Email_List__mdt.sObjectType.getDescribe()
            .getKeyPrefix();
        PageReference ref = new PageReference('/' + keyPrefix);
        
        
        return ref.getUrl();
        
    }
    
    //Returns a page reference to the setup page to view all scheduled jobs
    @AuraEnabled
    public static String viewAllScheduledJobs() {
        string keyPrefix = CronTrigger.sObjectType.getDescribe().getKeyPrefix();
        PageReference ref = new PageReference(
            '/' +
            keyPrefix +
            '?setupid=ScheduledJobs'
        );
        
        return ref.getUrl();
    }
    
    //Returns a page reference to the setup page to monitor apex jobs
    @AuraEnabled
    public static String viewMonitorJobs() {
        PageReference ref = new PageReference(
            '/apexpages/setup/listAsyncApexJobs.apexp?setupid=AsyncApexJobs'
        );
        
        return ref.getUrl();
    }
    
    //Wrapper Class
    public class configuredJob {
        public string name { get; set; }
        public string query { get; set; }
        public string contactId { get; set; }
        public string campaignId { get; set; }
        public string cronExpression { get; set; }
        public string leadId { get; set; }
        public string status { get; set; }
        public DateTime nextFireTime { get; set; }
        public Id cronTriggerId { get; set; }
        public boolean isScheduled { get; set; }
        public string jobRunTime { get; set; }
        
        // Constructor
        public configuredJob() {
        }
        
        // Indicates that this job can be scheduled
        public boolean canSchedule {
            get {
                return !isScheduled;
            }
        }
        
        // Indicates that this job can be executed
        public boolean canExecute {
            get {
                return true;
            }
        }
        
        // Indicates that this job can be cancelled
        public boolean canCancel {
            get {
                return string.isNotBlank(cronTriggerId);
            }
        }
    }
}