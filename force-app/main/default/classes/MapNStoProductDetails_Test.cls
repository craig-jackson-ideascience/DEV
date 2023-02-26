/**
 * Test class for MapNStoProductDetails
 */
@IsTest
public Class MapNStoProductDetails_Test{
	/**
	 * testSetup: for creating required data for testing
	 */
	@testSetup
	static void testSetup(){
		/* endpoint */
		Endpoints__c endPoint = new Endpoints__c();
		endPoint.name = 'For Product Details';
		endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=11';
		insert endPoint;


		/* parent project */
		
		Project__c parentProject = new Project__c(Name = 'The Linux Foundation', Category__c = 'Incorporated Entity');
		parentProject.NS_Deferred_Revenue_Account__c = '284';
		parentProject.NS_Income_GL_Account__c = '171';
		parentProject.NS_Department__c = '2';
		parentProject.Project_Code__c = '105 - CODE';
		parentProject.Subsidiary_ID__c = 1;
        parentProject.Slug__c = 'testlinux';
		parentProject.LF_Membership_Required__c = true;
		insert parentProject;
        
        Project__c parentProject2 = new Project__c(Name = 'LF Projects, LLC', Category__c = 'Incorporated Entity');
		parentProject2.NS_Deferred_Revenue_Account__c = '284';
		parentProject2.NS_Income_GL_Account__c = '171';
		parentProject2.NS_Department__c = '2';
		parentProject2.Project_Code__c = '105 - CODE';
		parentProject2.Subsidiary_ID__c = 1;
        parentProject2.Slug__c = 'testlfllc';
		parentProject2.LF_Membership_Required__c = true;
        insert parentProject2;

		/* projects */
		List<Project__c> projList = new List<Project__c>();

		Project__c proj1 = TestDataUtils.createProject(false, 'test Project', 'Membership', 'Subproject', 'Planned');
		proj1.Name = 'Test Proj';
		proj1.Slug__c = 'cncf';
		proj1.Project_Status__c = 'Active';
		proj1.Status__c = 'Active';
		proj1.Funding__c = 'Funded';
        proj1.Industry__c ='Automotive';
		proj1.Category__c = 'Series LLC';
        proj1.Technology__c ='System Administration';
        proj1.Technical_Activity_Type__c ='Open Source Software';
        proj1.Parent_Entity_Relationship__c = parentProject2.Id;
        proj1.Parent_Project__c = parentProject2.Id;
		projList.add(proj1);

		Project__c proj2 = TestDataUtils.createProject(false, 'test Project', 'Membership', 'Subproject', 'Planned');
		proj2.Subsidiary_ID__c = 1;
		proj2.Category__c = 'Subproject';
		proj2.Parent_Project__c = parentProject.Id;
		proj2.Model__c = 'Membership';
		projList.add(proj2);

		insert projList;

		/* product */
		List<Product2> prodList = new List<Product2>();

		Product2 prod1 = new Product2();
		prod1.Name = 'Test';
		prod1.IsActive = True;
		prod1.ProductCode = 'Test';
		prod1.Family = 'Alternate Funding';
		prodList.add(prod1);

		Product2 prod2 = prod1.clone();
		prod2.Family = 'Event';
		prodList.add(prod2);

		insert prodList;

		/* event */
		List<Event__c> evtList = new List<Event__c>();

		Event__c event1 = TestDataUtils.createEvent(false, 'Test Event 999', 'Event', 'Project Event', 'Active');
		event1.BillFromProject__c = proj1.Id;
		event1.NetSuite_Class__c = 'Training : Certification';
		event1.NS_Department__c = '10';
		event1.NS_Income_GL_Account__c = '171';
		event1.NS_Deferred_Revenue_Account__c = '284';
		evtList.add(event1);

		Event__c event2 = event1.clone();
		evtList.add(event2);

		insert evtList;

		/* product details */
		List<Product_Details__c> proDetailsList = new List<Product_Details__c>();

		Product_Details__c pd1 = new Product_Details__c();
		pd1.Products__c = prod1.Id;
		pd1.Description__c = 'test';
		pd1.NetSuite_Class__c = 'Training : Certification';
		pd1.NS_Income_GL_Account__c = '171';
		pd1.NS_Revenue_Schedule__c = '29';
		pd1.NS_Deferred_Revenue_Account__c = '284';
		pd1.NS_Department__c = '2';
		pd1.Project_Code__c = '105 - CODE';
		pd1.price__c = 11;
		pd1.Project__c = parentProject.Id;
		proDetailsList.add(pd1);

		Product_Details__c pd2 = pd1.clone();
		pd2.Project__c = null;
		pd2.Event__c = event1.Id;
		pd2.Products__c = prod2.id;
		proDetailsList.add(pd2);

		insert proDetailsList;

		/* Account */
		Account acc = TestDataUtils.createAccount(true, 'Test Account');

		/* opportunity */
		Opportunity op = TestDataUtils.createOpenOpportunity(true, acc.Id, 'Test Opportunity', '2. Discovery');

		/* pricebook entry */
		PriceBookEntry pbe1 = TestDataUtils.createPriceBookEntryID(true, prodList[0].Id);
		PriceBookEntry pbe2 = TestDataUtils.createPriceBookEntryID(true, prodList[1].Id);

		/* opportunity line items */
		List<OpportunityLineItem> listOfOLI = new List<OpportunityLineItem>();
		OpportunityLineItem ol1 = TestDataUtils.createOpportunityProduct(false, op.Id, pbe1.Id);
		ol1.Event__c = event1.id;
		ol1.Product_Details__c = pd2.Id;
		listOfOLI.add(ol1);

		OpportunityLineItem ol2 = TestDataUtils.createOpportunityProduct(false, op.Id, pbe2.Id);
		ol2.Event__c = event2.id;
		ol2.Product_Details__c = pd2.Id;
		listOfOLI.add(ol2);

		insert listOfOLI;
	}

	/**
	 * mappingMethod_Test test method for testing mappingMethod for project
	 */
	@IsTest
	static void mappingMethod_test(){
		List<Project__c> proj = [SELECT Id, Name
		                         FROM Project__c
		                         LIMIT 1];
		Integer result = MapNStoProductDetails.mappingMethod(proj[0].id, 'Project');
		System.assertEquals(1, result, 'Return value should be 1');
	}
    
    @IsTest
	static void mappingMethodProject_test(){
		List<Project__c> proj = [SELECT Id, Name
		                         FROM Project__c
		                         LIMIT 1];
        proj[0].NS_Deferred_Revenue_Account__c = null;
        update proj[0];
		Integer result = MapNStoProductDetails.mappingMethod(proj[0].id, 'Project');
		System.assertEquals(3, result, 'Return value should be 3');
	}
    
    @IsTest
	static void mappingMethodEventError_test(){
		List<Event__c> proj = [SELECT Id
		                       FROM Event__c
		                       LIMIT 1];
        proj[0].NS_Deferred_Revenue_Account__c = null;
        update proj[0];
		Integer result = MapNStoProductDetails.mappingMethod(proj[0].id, 'event');
		System.assertEquals(2, result, 'Return value should be 2');
	}


	/**
	 * mappingMethodForEvent_test test method for testing mappingMethod for event
	 */
	@IsTest
	static void mappingMethodForEvent_test(){
		List<Event__c> proj = [SELECT Id
		                       FROM Event__c
		                       LIMIT 1];
		Integer result = MapNStoProductDetails.mappingMethod(proj[0].id, 'event');
		System.assertEquals(1, result, 'Return value should be 1');
	}
}