@isTest
public class OpportunitiesRelatedToProject_Test{
	@isTest
	static void createTestMethod(){

		//Creating Project Record Id
		//Id directedProjectId = [Select Id, Name From RecordType Where SobjectType = 'Project__c' and Name='Subproject'].Id;
		Id MembershipOppId = [Select Id, Name
		                      From RecordType
		                      Where SobjectType = 'Opportunity' and Name = 'Membership'].Id;
		testFactory.getAccount();
		Project__c testProjObj = new Project__c();
		testProjObj.Name = 'New Test Project';
		testProjObj.Category__c = 'Subproject';
		testProjObj.Status__c = 'Planned';
		testProjObj.Type__c = 'Membership';
		testProjObj.Manual_Status_Check__c = false;
		testProjObj.Slug__c = 'testing';
		insert testProjObj;

		// Creating Account Record in Test Class
		Account testAcntObj = new Account();
		testAcntObj.Name = 'Test Acnt Record';
		insert testAcntObj;

		// Creating Product2 Record in Test Class
		Product2 testProdObj = new Product2();
		testProdObj.Name = 'Test Prod Record';
		testProdObj.Family = 'Membership';
		insert testProdObj;

		// Creating Purchase History Record in Test Class
		Asset testAssetObj = new Asset();
		testAssetObj.Name = 'Test Asset Record';
		testAssetObj.AccountId = testAcntObj.Id;
		testAssetObj.Projects__c = testProjObj.Id;
		testAssetObj.Status = 'Active';
		testAssetObj.Price = 50000.0;
		testAssetObj.SalesOrderStatus__c = 'Open';
		testAssetObj.PurchaseDate = date.today()-1;
		testAssetObj.InstallDate = date.today()-1;
		insert testAssetObj;

		// Create Opportunity Record
		Opportunity testOppObj = new Opportunity(RecordTypeId = MembershipOppId, Name = 'Opportunity testing 1', accountId = testAcntObj.Id, StageName = '2. Discovery', Type = 'New Business', CloseDate = Date.today().addDays(4), Renewal_Opportunity_Closed__c = 'True');
		insert testOppObj;

		// This is how we get the Standard PriceBook Id.  Prior to Summer '14, we needed
		// to use SeeAllData=true, so this is a big improvement
		Id pricebookId = Test.getStandardPricebookId();

		//Create your product
		Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X', isActive = true);
		insert prod;

		//Create your pricebook entry
		PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 100.00, IsActive = true);
		insert pbEntry;

		//create your opportunity line item.  This assumes you already have an opportunity created, called opp
		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = testOppObj.Id, Quantity = 5, PricebookEntryId = pbEntry.Id, TotalPrice = 1 * pbEntry.UnitPrice, Project__c = testProjObj.id);
		insert oli;
		system.debug('Opportunity RecordS:' + oli);

		//Creating Account Project Record
		Account_And_Project__c testAcntProjectObj = new Account_And_Project__c();
		testAcntProjectObj.Account__c = testAcntObj.id;
		testAcntProjectObj.Project__c = testProjObj.id;
		insert testAcntProjectObj;

		//Starting Test Class Method
		Test.startTest();
		// Callig apex Class Method
		OpportunitiesRelatedToProject_Controller.getFoundationName(testProjObj.Id);
		OpportunitiesRelatedToProject_Controller.getOpportunityDetails('', 'Name', false);
		OpportunitiesRelatedToProject_Controller.getOpportunityDetails(testProjObj.Id, 'Name', false);
		OpportunitiesRelatedToProject_Controller.getOpportunityDetailsWithOppTypeFilter(testProjObj.Id, 'Name', false, 'Open');
		OpportunitiesRelatedToProject_Controller.getOpportunityDetailsWithOppTypeFilter('', 'Name', true, 'Closed');

		list<membershipOpportunityViewCMP_controller.OpportunityListWrapper> opportunityListWrapper = new list<membershipOpportunityViewCMP_controller.OpportunityListWrapper>();
		Datetime createdDateTime = system.now();
		Date createdDateActual = createdDateTime.Date();
		String createdDate = DateTime.newInstance(createdDateActual.year(), createdDateActual.month(), createdDateActual.day()).format('MM/dd/yyyy');
		String gmtFormat = createdDateTime.formatGmt('EEE, MMM d yyyy HH:mm:ss, zz');
		Integer ageInDays = createdDateActual.daysBetween(Date.Today());
		Date closeDateActual = Date.ValueOf(system.now().addDays(10));
		String closeDate = DateTime.newInstance(closeDateActual.year(), closeDateActual.month(), closeDateActual.day()).format('MM/dd/yyyy');
		system.debug('createdDate:::@SK::::=>' + createdDate + 'closeDate:::@SK::::=>' + closeDate + ' gmtFormat:::::@SK:::=>' + gmtFormat + ' ageInDays:::@SK::::=>' + ageInDays);
		opportunityListWrapper.add(new membershipOpportunityViewCMP_controller.OpportunityListWrapper(false, testOppObj, ageInDays, createdDate, closeDate));

		Test.stopTest();
	}
}