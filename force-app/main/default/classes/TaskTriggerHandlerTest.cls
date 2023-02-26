/**
* Test class for TaskTriggerHandler
*/
@isTest
public class TaskTriggerHandlerTest {
    
    static testmethod  void testDataSetup(){
        // create Task record
        Task objTask= new Task();
        objTask.Subject='Other';
        objTask.OwnerId=TestFactory.getUser().id;
        objTask.Status='Not Started';
        objTask.Priority='Normal';
        objTask.WhoId=TestFactory.getContact().id;
        objTask.Description='Insight provided by Mixmax';
        objTask.TaskSubtype='task';
        // insert task
        insert objTask;
        objTask.Check_if_type_Contact_or_Lead__c =False;
        // update task
        update objTask;
        // delete task
        delete objTask;
        // undelete task
        undelete objTask;
    }
}