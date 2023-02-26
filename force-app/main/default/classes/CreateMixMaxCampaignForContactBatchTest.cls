@isTest
public class CreateMixMaxCampaignForContactBatchTest {

    static testmethod  void testDataSetup(){
        try{
        Campaign objcam = TestFactory.getCampaign();
        Contact objcon = new Contact(lastname = 'Test Contact',Mixmax_Campaign_Name__c =objcam.Name,MixMax_Create_Campaign__c = true);
        insert objcon;
            
        }
        catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        Test.startTest();
        
         CreateMixMaxCampaignForContactBatch c = new CreateMixMaxCampaignForContactBatch();
         Database.executeBatch(c);
        Test.stopTest();
    }
    
}