@istest
public class DisplayAssetsTest{
	public static testMethod void DisplayAccountsProjectTest(){

		PageReference pg = Page.AssetsOnProject;
		Test.setCurrentPage(pg);

		Account acc = new Account(Name = 'Test Account 1');
		insert acc;

		Project__c project1 = new Project__c(Name = 'The Linux Foundation', Type__c = 'Membership', Category__c = 'Directed Fund', Status__c = 'Planned', Slug__c = 'testing1');
		insert project1;

		List<Asset> asst = new List<Asset>();
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 1', Projects__c = project1.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 2', Projects__c = project1.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 3', Projects__c = project1.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 4', Projects__c = project1.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 5', Projects__c = project1.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 6', Projects__c = project1.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 7', Projects__c = project1.Id));
		insert asst;

		System.debug('>>>>>>>>' + asst);

		String projectID = String.valueOf(project1.Id);
		ApexPages.StandardController ssc = new ApexPages.StandardController(project1);
		DisplayAssets controller = new DisplayAssets(ssc);
		controller.strID = projectID;
		controller.assetsListMethod();
	}

	public static testMethod void DisplayAccountsEventTest(){

		PageReference pg = Page.AssetsOnEvents;
		Test.setCurrentPage(pg);

		Account acc = new Account(Name = 'Test Account 1');
		insert acc;

		Project__c project1 = new Project__c(Name = 'The Linux Foundation', Type__c = 'Membership', Category__c = 'Directed Fund', Status__c = 'Planned', Slug__c = 'testing', Model__c = 'Membership');
		insert project1;

        project1.Status__c = 'Active';
		project1.Funding__c = 'Funded';
		update project1;

		Event__c event = new Event__c(Name = 'Test Event', Type__c = 'Membership', BillFromProject__c = project1.Id);
		insert event;

		List<Asset> asst = new List<Asset>();
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 1', Event__c = event.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 2', Event__c = event.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 3', Event__c = event.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 4', Event__c = event.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 5', Event__c = event.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 6', Event__c = event.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 7', Event__c = event.Id));
		insert asst;

		System.debug('>>>>>>>>' + asst);
		String eventID = String.valueOf(event.Id);

		ApexPages.StandardController ssc = new ApexPages.StandardController(event);
		DisplayAssets controller = new DisplayAssets(ssc);
		controller.strID = eventID;
		controller.assetsListMethod();
	}

	public static testMethod void DisplayAccountsTrainingTest(){

		PageReference pg = Page.AssetsOnTraining;
		Test.setCurrentPage(pg);

		Account acc = new Account(Name = 'Test Account 1');
		insert acc;

		Project__c project1 = new Project__c(Name = 'The Linux Foundation', Type__c = 'Membership', Category__c = 'Directed Fund', Status__c = 'Planned', Slug__c = 'testing1');
		insert project1;

		Training__c tc = new Training__c(Category__c = 'Android Development Training', Type__c = 'Membership');
		insert tc;

		List<Asset> asst = new List<Asset>();
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 1', Training__c = tc.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 2', Training__c = tc.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 3', Training__c = tc.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 4', Training__c = tc.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 5', Training__c = tc.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 6', Training__c = tc.Id));
		asst.add(new Asset(AccountId = acc.Id, Name = 'ABC Asset 7', Training__c = tc.Id));
		insert asst;

		System.debug('>>>>>>>>' + asst);
		String trainingID = String.valueOf(tc.Id);

		ApexPages.StandardController ssc = new ApexPages.StandardController(tc);
		DisplayAssets controller = new DisplayAssets(ssc);
		controller.strID = trainingID;
		controller.assetsListMethod();
	}
}