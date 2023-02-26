//Test class for UtilityClass
@isTest
public class Test_Utility{
    @testsetup
    public static void createData(){
        Account account = new Account(Name = 'Acme, Inc.');
        insert account;
        Contact contact = new Contact(FirstName = 'Robin', LastName = 'Koehler', AccountId = account.Id);
        insert contact;
        Lead lead = new Lead();
        lead.LastName = 'Test Lead';
        lead.Email = 'testEmail@test.com';
        insert lead;

        Product2 parentProduct = new Product2(Name = 'Test Training Parent Product', productcode = 'parent', isActive = true, Type__c = 'Bundle');
        insert parentProduct;

        Product2 product = new Product2(Name = 'TestP', productcode = 'campaign', isActive = true, TI_Id__c = 'TestTiid');
        insert product;

        Bundle_Product__c bundleProduct = new Bundle_Product__c(Bundle__c = parentProduct.Id, Product__c = product.Id);
        insert bundleProduct;

        Campaign parentCampaign = new Campaign(Name = 'Training Bootcamp 2020', IsActive = TRUE, startDate = System.today() - 1, endDate = System.today() + 30, Product__c = 'Test Training Parent Product');
        insert parentCampaign;
        System.debug('parentCampaign ' + parentCampaign);

        Campaign campaign = new Campaign(Name = 'Test campaign', IsActive = TRUE, ParentId = parentCampaign.id, Type = 'Training');
        insert campaign;

        Enrollment__c enrollment = new Enrollment__c();
        enrollment.Name = 'Test enrollment';
        enrollment.Contact_Name__c = contact.Id;
        enrollment.Product_Name__c = product.Id;
        enrollment.Parent_Product__c = parentProduct.Id;
        enrollment.Is_free__c = true;
        enrollment.Source__c = 'SugarCRM';
        enrollment.Completion_Date__c = System.today() - 1;
        enrollment.isBootcampbundle__c = true;
        enrollment.Enrollment_Date__c = System.today();
        insert enrollment;

        parentProduct.Bootcamp_Campaign__c = true;
        update parentProduct;

        Cvent_Integration__c cventIntegration = TestDataUtils.createCventIntegrationSetting(true);

        
    }

    /*
	 Test Method batch
	 */
	@IsTest
	static void batchDataTest(){
        Project__c project = TestDataUtils.createProject(true, 'The Linux Foundation', 'Event', 'Directed Fund', 'Planned');
		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		Database.executeBatch(new GetEventFromCvent());
		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Event__c
		                        WHERE Cvent_Event_Id__c != null].size(), 'There must be an event');
	}

    @IsTest
	static void getRenewalCloseDate_Test(){

		Utility util = new Utility();
        util.getRenewalCloseDate(Date.newInstance(2021, 11, 18),30);
        util.getRenewalCloseDate(Date.newInstance(2021, 12, 18),30);
        util.getRenewalCloseDate(Date.newInstance(2021, 01, 18),30);



		/* System.assertEquals(1, [SELECT Id
		                        FROM Event__c
		                        WHERE Cvent_Event_Id__c != null].size(), 'There must be an event'); */
	}

    //Test Method for addCampaignMember()
    @isTest
    public static void testData(){
        Campaign campaign = [SELECT Id, Name
                             FROM Campaign
                             WHERE Parent.Name = 'Training Bootcamp 2020'];
        Test.startTest();
        Database.executeBatch(new EnrollmentToCampaignMemberBatch('Test Training Parent Product'));
        Test.stopTest();
        System.assertEquals('Sent', [SELECT id, Status
                                     FROM CampaignMember
                                     WHERE CampaignId = :campaign.Id][0].Status);
    }

    /*
	 Test Method for RetrieveRegistrationsFromCventBatch
	 */
	@isTest
	static void RetrieveRegistrationsFromCventBatchTest(){
		Cvent_Registration_Log__c cventRegistrationLog = TestDataUtils.createCventRegistrationLog(true, 'TestSearchId45768', 'Registration');
		Test.setMock(WebServiceMock.class, new CventSyncMock());
		Test.startTest();
		Database.executeBatch(new RetrieveRegistrationsFromCventBatch());
		Test.stopTest();
		System.assertEquals(1, [SELECT Id
		                        FROM Cvent_Registration_Log__c
		                        WHERE Retrieved__c != null].size(), 'There must be a record');
	}

    @isTest
    public static void getEmailAddresses_Test(){
        User user = TestFactory.getUser();
        Group newGroup = new Group();
        newGroup.Name = 'Test Group';
        newGroup.DeveloperName = 'Test_Group';
        insert newGroup;
        GroupMember newMember = new GroupMember();
        newMember.GroupId = newGroup.Id;
        newMember.UserOrGroupId = user.Id;
        insert newMember;
        List<String> returnAddress = Utility.getEmailAddresses('Test_Group');
        System.assertEquals('standarduser123@testorg.com', returnAddress.get(0), 'Email Address must be standarduser123@testorg.com');
    }

    //Test method for getDependentPicklistValues() and getPickListValuesIntoList()
    @isTest
    public static void general_testMethod(){
        List<String> leadSourcePickListValues = Utility.getPickListValuesIntoList('Lead', 'LeadSource');
        System.assertNotEquals(null, leadSourcePickListValues.size(), 'List must not be null');
        Lead lead = new Lead();
        lead.LastName = 'Lead source test';
        lead.Email = 'test@lead.com';
        insert lead;
        Map<String, List<String>> dependentPicklistValuesMap = Utility.getDependentPicklistValues(SObjectType.Lead, 'LeadSource', 'Lead_Source_Detail_p__c');

    }

    //Test method for updateLeadTechnology()
    @isTest
    public static void updateLeadTechnology_testMethod(){
        List<String> sObjectTechnology = new List<String>{ 'Application Development', 'Blockchain' };
        List<String> strlstLead = new List<String>{ 'System Administration' };
        Lead lead = new Lead();
        lead.LastName = 'Lead source test';
        lead.Email = 'test@lead.com';
        lead.Technology__c = 'System Administration';
        insert lead;
        List<Lead> leadList = Utility.updateLeadTechnology(lead, sObjectTechnology, strlstLead);
        System.assertEquals(true, leadList.get(0).Technology__c.contains('Application Development'), 'Technology of lead must contains Application Development');
    }

    //Test method for updateTechnologyOnContact()
    @isTest
    public static void updateTechnologyOnContact_testMethod(){
        List<String> sObjectTechnology = new List<String>{ 'Application Development', 'Blockchain' };
        List<String> strlstContact = new List<String>{ 'System Administration' };
        Contact contact = new Contact();
        contact.LastName = 'Contact test';
        contact.Email = 'test@contact.com';
        contact.Technology__c = 'System Administration';
        insert contact;
        List<Contact> contactList = Utility.updateTechnologyOnContact(contact, sObjectTechnology, strlstContact);
        System.assertEquals(true, contactList.get(0).Technology__c.contains('Application Development'), 'Technology of contact must contains Application Development');
    }

    //Test method for getFieldNames()
    @isTest
    public static void getFieldNames_testMethod(){
        Utility mergeUtility = new Utility();
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Contact.fields.getMap();
        Map<String, Object> returnedMap = mergeUtility.getFieldNames(schemaFieldMap);
        System.assertNotEquals(null, returnedMap);
        /* Map<String, Object> returnMap = mergeUtility.getFieldNames(schemaFieldMap);
         System.assertEquals(true,returnMap.containsKey('CheckboxFields'),'Must must contains CheckboxFields as a key');
         System.assertEquals(true,returnMap.containsKey('FieldNames'),'Must must contains FieldNames as a key'); */
    }

    @isTest
    public static void getLinuxFoundationId_test(){
        Project__c prjLf = new Project__c(Name = 'The Linux Foundation', Status__c = 'Planned', Category__c = 'Directed Fund', Subsidiary_ID__c = 8);
        prjLf.slug__c = 'testlf';
        insert prjLf;
        System.assertEquals(prjLf.Id, Utility.linuxFoundationId, 'Id must match');
        System.assertNotEquals(null, Utility.corporateRecordTypeId, 'Id must not be null');
    }
}