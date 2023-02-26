@isTest
public class TestProductDetail_Trigger{
	static testmethod void testTrigger(){

		// Insert  test products with or without Number_of_Years_Required__c
		List<Product2> prod = new List<Product2>();
		prod.add(new Product2(Name = 'Laptop X200', Family = 'Membership'));
		prod.add(new Product2(Name = 'Laptop X300', Family = 'Event'));
		prod.add(new Product2(Name = 'Laptop X400', Family = 'Training'));
        prod.add(new Product2(Name = 'Laptop X500', Family = 'Membership'));
		insert prod;

		// Get standard price book ID
		// This is available irrespective of the state of SeeAllData.
		Id pricebookId = Test.getStandardPricebookId();

		// Create a custom price book
		Pricebook2 customPB = new Pricebook2(Name = 'Custom Pricebook', isActive = true);
		insert customPB;


		// 1. Insert price book entries for the standard price book
		// Standard price book entries require the standard price book ID we got earlier
		// also for custom price book entries for custom pricebook that we created

		List<PricebookEntry> pbe = new List<PricebookEntry>();
		pbe.add(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod[0].Id, UnitPrice = 1000, IsActive = true));
		pbe.add(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod[1].Id, UnitPrice = 2000, IsActive = true));
		pbe.add(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod[2].Id, UnitPrice = 3000, IsActive = true));
		pbe.add(new PricebookEntry(Pricebook2Id = customPB.id, Product2Id = prod[0].Id, UnitPrice = 4000, IsActive = true));
		pbe.add(new PricebookEntry(Pricebook2Id = customPB.id, Product2Id = prod[1].Id, UnitPrice = 5000, IsActive = true));
		pbe.add(new PricebookEntry(Pricebook2Id = customPB.id, Product2Id = prod[2].Id, UnitPrice = 6000, IsActive = true));

		insert pbe;

		// insert custom object - PROJECT
		Project__c prjct = new Project__c(Name = 'The Linux Foundation', NS_Deferred_Revenue_Account__c = '284', NS_Department__c = '10', NetSuite_Class__c = 'External P&Ls : CII', NS_Income_GL_Account__c = '290', Category__c = 'Directed Fund', Slug__c = 'testing', Model__c = 'Membership', Type__c = 'Membership');
		insert prjct;
		prjct.Status__c = 'Active';
		prjct.Funding__c = 'Funded';
		update prjct;
        Project__c prjct1 = new Project__c(Name = 'SubProj of The Linux Foundation', Parent_Project__c = Label.The_Linux_Foundation_Project,Parent_Entity_Relationship__c = Label.The_Linux_Foundation_Project, NS_Deferred_Revenue_Account__c = '284', NS_Department__c = '10', NetSuite_Class__c = 'External P&Ls : CII', NS_Income_GL_Account__c = '290', Category__c = 'Subproject', Slug__c = 'jlc', Model__c = 'Membership', Type__c = 'Membership',Manual_Status_Check__c =False);
		insert prjct1;
		prjct1.Status__c = 'Active';
		prjct1.Funding__c = 'Funded';
		update prjct1;
        
		// insert custom object - EVENT
		Event__c evt = new Event__c(Name = 'testing', NS_Deferred_Revenue_Account__c = '284', NS_Department__c = '10', NetSuite_Class__c = 'External P&Ls : CII', NS_Income_GL_Account__c = '290', BillFromProject__c = prjct.Id);
		insert evt;

		// insert custom object - TRAINING
		Training__c trng = new Training__c(Name = 'testing', Category__c = 'Android Development Training', NS_Deferred_Revenue_Account__c = '284', NS_Department__c = '10', NetSuite_Class__c = 'External P&Ls : CII', NS_Income_GL_Account__c = '290');
		insert trng;

		// Fetching RecordType Ids of Product Detail object
		List<RecordType> recordType_list = new List<RecordType>([Select Id, Name
		                                                         From RecordType
		                                                         Where SobjectType = 'Product_Details__c']);

		List<Product_Details__c> proDetail = new List<Product_Details__c>();


		// insert custom object - PRODUCT DETAILS
		if (recordType_list != null && recordType_list.size() > 0){

			for (RecordType rt : recordType_list){


                if (rt.Name == 'Membership'){
					proDetail.add(new Product_Details__c(RecordTypeId = rt.Id, Products__c = prod[0].Id, Project__c = prjct.Id, Description__c = 'test'));
                	proDetail.add(new Product_Details__c(RecordTypeId = rt.Id, Products__c = prod[3].Id, Project__c = prjct1.Id, Description__c = 'test1'));
                }
				if (rt.Name == 'Event')
					proDetail.add(new Product_Details__c(RecordTypeId = rt.Id, Products__c = prod[1].Id, Event__c = evt.Id, Description__c = 'test'));
				if (rt.Name == 'Training')
					proDetail.add(new Product_Details__c(RecordTypeId = rt.Id, Products__c = prod[2].Id, Training__c = trng.Id, Description__c = 'test'));
			}

		}

		if (proDetail != null && proDetail.size() > 0)
			insert proDetail;
	}
}