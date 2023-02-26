@isTest
private class ChangeProductUtilTest {

    @isTest static void testNewBusinessWithNoProductChange(){
        Project__c lfProject = new Project__c();
        lfProject.Name = 'The Linux Foundation';
        lfProject.Category__c = 'Incorporated Entity';
        lfProject.Project_Status__c = 'Active';
        lfProject.Funding__c = 'Funded';
        lfProject.slug__c = 'lf';
        lfProject.Project_Entity_Name__c = 'The Linux Foundation';
        lfProject.Start_Date__c = system.today();
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
        silverPD1.Description__c = 'description';
        insert silverPD1;
        
        Product_Details__c silverPD2 = new Product_Details__c();
        silverPD2.Products__c = silverMembershipProduct.Id;
        silverPD2.Project__c = lfProject.Id;
        silverPD2.Price__c = 1000;
        silverPD2.Status__c = 'Active';
        silverPD2.Number_Of_Years_Required__c = '1';
        silverPD2.Description__c = 'description';
        insert silverPD2;
        
        OpportunityLineItem newBusinessOLI = new OpportunityLineItem();
        newBusinessOLI.OpportunityId = newBusinessOpp.Id;
        newBusinessOLI.Product2Id = silverMembershipProduct.Id;
        newBusinessOLI.Product_Details__c = silverPD1.Id;
        newBusinessOLI.Start_Date__c = Date.today();
        newBusinessOLI.Quantity = 1;
        newBusinessOLI.TotalPrice = silverPD1.Price__c;
        newBusinessOLI.PricebookEntryId = silverPBE.Id;
        insert newBusinessOLI;        
        
        
        Map<Id,Product_Details__c> pdMap = new Map<Id,Product_Details__c>();
        pdMap.put(newBusinessOLI.Id, silverPD2);

        Map<Id,OpportunityLineItem> oliMap = new Map<Id,OpportunityLineItem>();
        oliMap.put(newBusinessOLI.Id, newBusinessOLI);
        ChangeProductUtil.changeProductDetailOnOLI(pdMap,oliMap);
        System.assertEquals(1, [SELECT count() FROM OpportunityLineItem WHERE ID=:newBusinessOLI.ID]);
    }
    
    @isTest 
    static void testRenewalWithProductChange(){
        Project__c lfProject = new Project__c();
        lfProject.Name = 'The Linux Foundation';
        lfProject.Category__c = 'Incorporated Entity';
        lfProject.Project_Status__c = 'Active';
        lfProject.Funding__c = 'Funded';
        lfProject.slug__c = 'lf';
        lfProject.Project_Entity_Name__c = 'The Linux Foundation';
        lfProject.Start_Date__c = system.today();
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
        
        Asset ph = new Asset();
        ph.Name = 'Parent Asset for Renewal Opp';
        ph.AccountId = acc.Id;
        ph.Projects__c = lfProject.Id;
        ph.Annual_Full_Price__c = 500;
        insert ph;
        
        Opportunity renewalOpp = new Opportunity();
        renewalOpp.AccountId = acc.Id;
        renewalOpp.StageName = '5. Decision Commitment';
        renewalOpp.Type = 'Renewal';
        renewalOpp.CloseDate = Date.today();
        renewalOpp.Name = 'Google Renewal Opp';
        renewalOpp.Pricebook2Id = pricebookId;
        renewalOpp.Parent_Asset__c = ph.Id;
        insert renewalOpp;
        
        Product2 goldMembershipProduct = new Product2();
        goldMembershipProduct.Name = 'Gold Membership';
        goldMembershipProduct.Family = 'Membership';
        insert goldMembershipProduct;
        
        Product2 silverMembershipProduct = new Product2();
        silverMembershipProduct.Name = 'Silver Membership';
        silverMembershipProduct.Family = 'Membership';
        insert silverMembershipProduct;
        
        PricebookEntry goldPBE = new PricebookEntry();
        goldPBE.Pricebook2Id = pricebookId;
        goldPBE.Product2Id = goldMembershipProduct.Id;
        goldPBE.UnitPrice = 5000;
        goldPBE.UseStandardPrice = false;
        goldPBE.IsActive = true;
        insert goldPBE;
        
        PricebookEntry silverPBE = new PricebookEntry();
        silverPBE.Pricebook2Id = pricebookId;
        silverPBE.Product2Id = silverMembershipProduct.Id;
        silverPBE.UnitPrice = 500;
        silverPBE.UseStandardPrice = false;
        silverPBE.IsActive = true;
        insert silverPBE;
        
        Product_Details__c goldPD = new Product_Details__c();
        goldPD.Products__c = goldMembershipProduct.Id;
        goldPD.Project__c = lfProject.Id;
        goldPD.Price__c = 5000;
        goldPD.Status__c = 'Active';
        goldPD.Number_Of_Years_Required__c = '1';
        goldPD.Description__c = 'description';
        insert goldPD;
        
        Product_Details__c silverPD1 = new Product_Details__c();
        silverPD1.Products__c = silverMembershipProduct.Id;
        silverPD1.Project__c = lfProject.Id;
        silverPD1.Price__c = 500;
        silverPD1.Status__c = 'Active';
        silverPD1.Description__c = 'description';
        insert silverPD1;
        
        OpportunityLineItem renewalOLI = new OpportunityLineItem();
        renewalOLI.OpportunityId = renewalOpp.Id;
        renewalOLI.Product2Id = silverMembershipProduct.Id;
        renewalOLI.Product_Details__c = silverPD1.Id;
        renewalOLI.Start_Date__c = Date.today();
        renewalOLI.Quantity = 1;
        renewalOLI.UnitPrice = silverPD1.Price__c;
        renewalOLI.PricebookEntryId = silverPBE.Id;
        insert renewalOLI;
        Contact c = new Contact(FirstName='test',LastName ='user',Email ='test@yser.com');
        insert c;
        Project_Role__c projectrole = New Project_Role__c();
        projectrole.Contact__c = c.Id;
        projectrole.Opportunity_Line_Item__c = renewalOLI.Id;
        projectrole.Role__c = 'Marketing Contact';
        insert projectrole;
  
        Map<Id,Product_Details__c> pdMap = new Map<Id,Product_Details__c>();
        pdMap.put(renewalOLI.Id, goldPD);

        Map<Id,OpportunityLineItem> oliMap = new Map<Id,OpportunityLineItem>();
        oliMap.put(renewalOLI.Id, renewalOLI);
        ChangeProductUtil.changeProductDetailOnOLI(pdMap,oliMap);
        System.assertEquals(0, [SELECT count() FROM OpportunityLineItem WHERE ID=:renewalOLI.ID]);

    }
    
}