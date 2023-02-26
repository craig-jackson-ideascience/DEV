@isTest
public class UpdateMixmaxEmailsSentCountOnParentTest {

    static testmethod  void testDataSetup(){
        Task objTask= new Task();
            objTask.Subject='Other';
   			objTask.OwnerId=TestFactory.getUser().id;
   			objTask.Status='Not Started';
   			objTask.Priority='Normal';
   			objTask.WhoId=TestFactory.getContact().id;
   			objTask.Description='Insight provided by Mixmax';
   			objTask.TaskSubtype='task';
          insert objTask;
        Test.startTest();
         UpdateMixmaxEmailsSentCountOnParent c = new UpdateMixmaxEmailsSentCountOnParent();
         Database.executeBatch(c);
        Test.stopTest();
    }
}