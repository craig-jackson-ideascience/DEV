@isTest
public class TestMixmaxContactLeadUpdateCampaignBatch {
    public static testmethod void testDataSetup(){
        Task objTask= new Task();
            objTask.Subject='MixMax :Test Campaign';
   			objTask.OwnerId=TestFactory.getUser().id;
   			objTask.Status='Not Started';
   			objTask.Priority='Normal';
   			objTask.WhoId=TestFactory.getContact().id;
   			objTask.Description='abc@salesforce.com';
   			objTask.TaskSubtype='task';
          insert objTask;
        Test.startTest();
         MixmaxContactLeadUpdateCampaignBatch c = new MixmaxContactLeadUpdateCampaignBatch();
         Database.executeBatch(c);
        Test.stopTest();
    }

}