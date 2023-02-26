/*
* Test Class For - CalculateEnrollmentsBatch and CalculateEnrollmentsBatchHelper 
*/
@isTest
public class CalculateEnrollmentsBatchTest {

    @TestSetup static void generateTestData() {

        Campaign camp = new Campaign(Name = 'Test Campaign', LF_Training__c = TRUE, Technology__c = 'Blockchain');
        insert camp;

        Product2 prod = new Product2(Name = 'Test Product', Technology__c = 'Blockchain');
        insert prod;

        Contact con1 = new Contact(FirstName = 'Test ', LastName = 'Contact1', Email = 'TestEnrollCount1@gmail.com');
        insert con1;
        
        Contact con2 = new Contact(FirstName = 'Test ', LastName = 'Contact2', Email = 'TestEnrollCount2@gmail.com');
        insert con2;

        Contact conRec1 = [Select ID from Contact Where Email='TestEnrollCount1@gmail.com' Limit 1];
        Contact conRec2 = [Select ID from Contact Where Email='TestEnrollCount2@gmail.com' limit 1];
        Product2 prodRec = [Select ID from Product2 limit 1];
        Campaign campRec = [Select ID from Campaign limit 1];

        CampaignMember campMem1 = new CampaignMember(CampaignId = campRec.ID, ContactId = conRec1.ID);
        insert campMem1;
        
        CampaignMember campMem2 = new CampaignMember(CampaignId = campRec.ID, ContactId = conRec2.ID);
        insert campMem2;

        Enrollment__c enroll1 = new Enrollment__c(Product_Name__c = prodRec.ID, Contact_Name__c = conRec1.ID);
        insert enroll1;
        
        Enrollment__c enroll2 = new Enrollment__c(Product_Name__c = prodRec.ID, Contact_Name__c = conRec1.ID);
        insert enroll2;
        
        Test.setCreatedDate(campMem1.Id, Datetime.now().addDays(-1)); 
        Test.setCreatedDate(campMem2.Id, Datetime.now().addDays(-1)); 

    }

    @isTest 
    public static void testCount(){
        Test.startTest();
        ScheduleCalculateEnrollmentsBatch sc = new ScheduleCalculateEnrollmentsBatch();
        sc.execute(null);
        Test.stopTest();
    }
}