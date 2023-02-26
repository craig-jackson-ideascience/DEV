@isTest
private class OppChangeProductControllerTest{
	@isTest
	static void testGetOptions(){
		Project__c lfProject = new Project__c();
		lfProject.Name = 'The Linux Foundation';
		lfProject.Category__c = 'Incorporated Entity';
		lfProject.Project_Status__c = 'Active';
		lfProject.Funding__c = 'Funded';
		lfProject.Slug__c = 'testing';
        lfProject.Project_Entity_Name__c = 'The Linux Foundation';
        lfProject.Start_Date__c = System.today();
        lfProject.Industry__c = 'Non-profit Organizations';
        lfProject.Model__c = 'Alternate Funding';
        lfProject.Technology__c = 'Blockchain';
        lfProject.Technical_Activity_Type__c = 'Open Source Software';
        lfProject.Description__c = 'description';
		insert lfProject;

		Project__c lfnProject = new Project__c();
		lfnProject.Name = 'LF Networking';
		lfnProject.Category__c = 'Subproject';
		lfnProject.Project_Status__c = 'Active';
		lfnProject.Funding__c = 'Funded';
        lfnProject.Slug__c = 'testing1';
        lfnProject.Project_Entity_Name__c = 'The Linux Foundation';
        lfnProject.Start_Date__c = System.today();
        lfnProject.Industry__c = 'Non-profit Organizations';
        lfnProject.Model__c = 'Alternate Funding';
        lfnProject.Technology__c = 'Blockchain';
        lfnProject.Technical_Activity_Type__c = 'Open Source Software';
        lfnProject.Description__c = 'description';
        lfnProject.Parent_Entity_Relationship__c = lfProject.Id;
        lfnProject.Parent_Project__c = lfProject.Id;
		insert lfnProject;

		Account acc = new Account();
		acc.Name = 'Google';
		acc.Website = 'www.google.com';
		insert acc;

		Id pricebookId = Test.getStandardPricebookId();

		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.StageName = '5. Decision Commitment';
		opp.Type = 'New Business';
		opp.CloseDate = Date.today();
		opp.Name = 'Google New Business Opp';
		opp.Pricebook2Id = pricebookId;
		insert opp;

		Product2 silverMembershipProduct = new Product2();
		silverMembershipProduct.Name = 'Silver Membership';
		silverMembershipProduct.Family = 'Membership';
		insert silverMembershipProduct;

		PricebookEntry silverPBE = new PricebookEntry();
		silverPBE.Pricebook2Id = pricebookId;
		silverPBE.Product2Id = silverMembershipProduct.Id;
		silverPBE.UnitPrice = 500;
		silverPBE.UseStandardPrice = false;
		silverPBE.IsActive = true;
		insert silverPBE;

		Product_Details__c silverPDLF = new Product_Details__c();
		silverPDLF.Products__c = silverMembershipProduct.Id;
		silverPDLF.Project__c = lfProject.Id;
		silverPDLF.Price__c = 500;
		silverPDLF.Start_Tier__c = 1;
		silverPDLF.Status__c = 'Active';
        silverPDLF.Description__c = 'test';
		insert silverPDLF;

		Product_Details__c silverPDLFN = new Product_Details__c();
		silverPDLFN.Products__c = silverMembershipProduct.Id;
		silverPDLFN.Project__c = lfnProject.Id;
		silverPDLFN.Price__c = 750;
		silverPDLFN.Start_Tier__c = 1;
		silverPDLFN.Status__c = 'Active';
        silverPDLFN.Description__c = 'test';
		insert silverPDLFN;

		Product_Details__c silverPDLF2 = new Product_Details__c();
		silverPDLF2.Products__c = silverMembershipProduct.Id;
		silverPDLF2.Project__c = lfProject.Id;
		silverPDLF2.Price__c = 5000;
		silverPDLF2.Start_Tier__c = 500;
		silverPDLF2.Status__c = 'Active';
        silverPDLF2.Description__c = 'test';
		insert silverPDLF2;

		Product_Details__c silverPDLFN2 = new Product_Details__c();
		silverPDLFN2.Products__c = silverMembershipProduct.Id;
		silverPDLFN2.Project__c = lfnProject.Id;
		silverPDLFN2.Price__c = 7500;
		silverPDLFN2.Start_Tier__c = 500;
		silverPDLFN2.Status__c = 'Active';
        silverPDLFN2.Description__c = 'test';
		insert silverPDLFN2;

		OpportunityLineItem lfOLI = new OpportunityLineItem();
		lfOLI.OpportunityId = opp.Id;
		lfOLI.Product2Id = silverMembershipProduct.Id;
		lfOLI.Product_Details__c = silverPDLF.Id;
		lfOLI.Projects__c = lfProject.Id;
		lfOLI.Start_Date__c = Date.newInstance(2020, 1, 1);
		lfOLI.Quantity = 1;
		lfOLI.TotalPrice = silverPDLF.Price__c;
		lfOLI.PricebookEntryId = silverPBE.Id;
		insert lfOLI;

		OpportunityLineItem lfnOLI = new OpportunityLineItem();
		lfnOLI.OpportunityId = opp.Id;
		lfnOLI.Product2Id = silverMembershipProduct.Id;
		lfnOLI.Product_Details__c = silverPDLFN.Id;
		lfnOLI.Projects__c = lfnProject.Id;
		lfnOLI.Start_Date__c = Date.newInstance(2020, 1, 1);
		lfnOLI.Quantity = 1;
		lfnOLI.TotalPrice = silverPDLF.Price__c;
		lfnOLI.PricebookEntryId = silverPBE.Id;
		insert lfnOLI;

		OppChangeProductController.getOptions(opp.Id);
	}

	@isTest
	static void testGetOptionsEmptyList(){
		Account acc = new Account();
		acc.Name = 'Google';
		acc.Website = 'www.google.com';
		insert acc;

		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.StageName = '5. Decision Commitment';
		opp.Type = 'New Business';
		opp.CloseDate = Date.today();
		opp.Name = 'Google New Business Opp';
		insert opp;

		OppChangeProductController.getOptions(opp.Id);
	}

	@isTest
	static void testUpdateProducts(){
		Project__c lfProject = new Project__c();
		lfProject.Name = 'The Linux Foundation';
		lfProject.Category__c = 'Incorporated Entity';
		lfProject.Project_Status__c = 'Active';
		lfProject.Funding__c = 'Funded';
        lfProject.Slug__c = 'testing';
        lfProject.Project_Entity_Name__c = 'The Linux Foundation';
        lfProject.Start_Date__c = System.today();
        lfProject.Industry__c = 'Non-profit Organizations';
        lfProject.Model__c = 'Alternate Funding';
        lfProject.Technology__c = 'Blockchain';
        lfProject.Technical_Activity_Type__c = 'Open Source Software';
        lfProject.Description__c = 'description';
		insert lfProject;

		Account acc = new Account();
		acc.Name = 'Google';
		acc.Website = 'www.google.com';
		insert acc;

		Id pricebookId = Test.getStandardPricebookId();

		Opportunity newBusinessOpp = new Opportunity();
		newBusinessOpp.AccountId = acc.Id;
		newBusinessOpp.StageName = '5. Decision Commitment';
		newBusinessOpp.Type = 'New Business';
		newBusinessOpp.CloseDate = Date.today();
		newBusinessOpp.Name = 'Google New Business Opp';
		newBusinessOpp.Pricebook2Id = pricebookId;
		insert newBusinessOpp;

		Product2 silverMembershipProduct = new Product2();
		silverMembershipProduct.Name = 'Silver Membership';
		silverMembershipProduct.Family = 'Membership';
		insert silverMembershipProduct;

		PricebookEntry silverPBE = new PricebookEntry();
		silverPBE.Pricebook2Id = pricebookId;
		silverPBE.Product2Id = silverMembershipProduct.Id;
		silverPBE.UnitPrice = 500;
		silverPBE.UseStandardPrice = false;
		silverPBE.IsActive = true;
		insert silverPBE;

		Product_Details__c silverPD1 = new Product_Details__c();
		silverPD1.Products__c = silverMembershipProduct.Id;
		silverPD1.Project__c = lfProject.Id;
		silverPD1.Price__c = 500;
		silverPD1.Status__c = 'Active';
        silverPD1.Description__c = 'test';
		insert silverPD1;

		Product_Details__c silverPD2 = new Product_Details__c();
		silverPD2.Products__c = silverMembershipProduct.Id;
		silverPD2.Project__c = lfProject.Id;
		silverPD2.Price__c = 1000;
		silverPD2.Status__c = 'Active';
        silverPD2.Description__c = 'test';
		insert silverPD2;

		OpportunityLineItem newBusinessOLI = new OpportunityLineItem();
		newBusinessOLI.OpportunityId = newBusinessOpp.Id;
		newBusinessOLI.Product2Id = silverMembershipProduct.Id;
		newBusinessOLI.Product_Details__c = silverPD1.Id;
		newBusinessOLI.Start_Date__c = Date.newInstance(2020, 1, 1);
		newBusinessOLI.Quantity = 1;
		newBusinessOLI.TotalPrice = silverPD1.Price__c;
		newBusinessOLI.PricebookEntryId = silverPBE.Id;
		newBusinessOLI.Projects__c = lfProject.Id;
		insert newBusinessOLI;

		List<ID> pdIDsList = new List<ID>();
		pdIDsList.add(silverPD2.Id);

		OppChangeProductController.updateProducts(newBusinessOpp.Id, pdIDsList);
	}
}