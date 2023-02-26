@isTest
public class ApexJobUtilityControllerTest {
    
    //Init Test Method
    @isTest
    public static void controllerInit_TestMethod() {
        // Start the test
        Test.startTest();
        String result = ApexJobUtilityController.init();
        //Stop Test
        Test.stopTest();
        System.assertNotEquals(null,result);
    }
    
    //All Test-Cases Test Method
    @isTest
    public static void controllerExecute_TestMethod() {
        
        // Start the test
        Test.startTest();
        List<ApexJobUtilityController.configuredJob> configuredJobs = ApexJobUtilityController.getCurrentConfiguredJobs();
        if(!configuredJobs.isEmpty()){
            //execute
            String executeResult = ApexJobUtilityController.executeJob(JSON.serialize(configuredJobs[0]));
            System.assertNotEquals(null,executeResult);
            
            //schedule
            String scheduleResult = ApexJobUtilityController.scheduleJob(JSON.serialize(configuredJobs[0]));
            System.assertNotEquals(null,executeResult);
            
            //cancel
            String cancelResult = ApexJobUtilityController.cancelSchedule(JSON.serialize(configuredJobs[0]));
            System.assertNotEquals(null,cancelResult);
            
            //scheduleAllJobs
            String scheduleAllResult = ApexJobUtilityController.scheduleAllJobs(JSON.serialize(configuredJobs));
            System.assertNotEquals(null,cancelResult);
            
            //cancelAllScheduledJobs
            String cancelAllResult = ApexJobUtilityController.cancelAllScheduledJobs(JSON.serialize(configuredJobs));
            System.assertNotEquals(null,cancelResult);
            
            //viewSettings
            String viewSettingUrl = ApexJobUtilityController.viewSettings();
            System.assertNotEquals(null,cancelResult);
            
            //viewAllScheduledJobs
            String viewScheduleJobUrl = ApexJobUtilityController.viewAllScheduledJobs();
            System.assertNotEquals(null,cancelResult);
            
            //viewMonitorJobs
            String monitorJobUrl = ApexJobUtilityController.viewMonitorJobs();
            System.assertNotEquals(null,cancelResult);
        }
        
        //Stop Test
        Test.stopTest();
        
        
    }
    
    //All Error Test-Cases Test Method
    @isTest
    public static void controllerError_TestMethod() {
        
        // Start the test
        Test.startTest();
        List<ApexJobUtilityController.configuredJob> configuredJobs = ApexJobUtilityController.getCurrentConfiguredJobs();
        if(!configuredJobs.isEmpty()){
            //execute
            String executeResult = ApexJobUtilityController.executeJob('');
            System.assertNotEquals(null,executeResult);
            
            //schedule
            String scheduleResult = ApexJobUtilityController.scheduleJob('');
            System.assertNotEquals(null,executeResult);
            
            //cancel
            String cancelResult = ApexJobUtilityController.cancelSchedule('');
            System.assertNotEquals(null,cancelResult);
            
            //scheduleAllJobs
            String scheduleAllResult = ApexJobUtilityController.scheduleAllJobs('');
            System.assertNotEquals(null,cancelResult);
            
            //cancelAllScheduledJobs
            String cancelAllResult = ApexJobUtilityController.cancelAllScheduledJobs('');
            System.assertNotEquals(null,cancelResult);
            
            //viewSettings
            String viewSettingUrl = ApexJobUtilityController.viewSettings();
            System.assertNotEquals(null,cancelResult);
            
            //viewAllScheduledJobs
            String viewScheduleJobUrl = ApexJobUtilityController.viewAllScheduledJobs();
            System.assertNotEquals(null,cancelResult);
            
            //viewMonitorJobs
            String monitorJobUrl = ApexJobUtilityController.viewMonitorJobs();
            System.assertNotEquals(null,cancelResult);
        }
        
        //Stop Test
        Test.stopTest();
        
        
    }
}