@isTest
public class TestCancelMembershipReport {
    
    /*
    public static testmethod void testDataSetup(){
        Id MembershipOppId = [Select Id, Name From RecordType Where SobjectType = 'Opportunity' and Name='Membership'].Id;
        Account objAccount = TestFactory.getAccount();
        Contact objContact = TestFactory.getContact();
        Opportunity objOpportunity= TestFactory.getOpportunity();
        objOpportunity.RecordTypeId=MembershipOppId;
        objOpportunity.accountId=objAccount.Id ;
        objOpportunity.StageName='Closed Lost';
        objOpportunity.Loss_Reason__c ='Other' ;
        objOpportunity.Type='Renewal';
        objOpportunity.CloseDate=Date.today();
        objOpportunity.Renewal_Opportunity_Closed__c='True';
        Update objOpportunity;
        
        OpportunityLineItem ObjOppLineItem = TestFactory.getOpportunityLineItem();
       
             
        OpportunityContactRole objContactRole = new OpportunityContactRole();
        objContactRole.OpportunityId = objOpportunity.id;
        objContactRole.ContactId = objContact.id;
        objContactRole.Role ='Membership Decision Maker	';
        objContactRole.IsPrimary = true;
        insert objContactRole;
        
        Asset objAsset = TestFactory.getAsset();
        objAsset.Cancellation_Date__c =Date.today().addDays(4);
        objAsset.PurchaseDate =Date.today();
        objAsset.Cancellation_Reason__c ='Other';
        objAsset.Status ='Invoice Cancelled';
        update objAsset;
        Project__c objProject =TestFactory.getProject();
        Project_Role__c objPR= new Project_role__c();
        objPR.Asset__c =objAsset.id;
        objPR.Contact__c = objContact.id;
        objPR.Role__c ='Marketing Contact';
        objPR.Status__c ='Active';
        insert objPR;
        CancelMembershipReport objClass = new CancelMembershipReport();
        objClass.projectName ='[0066w000001rUUh]';
        objClass.getAsset();
        objClass.getselectedProject();
        objClass.ExportToExcel();
        objClass.startDate =System.today();
        objClass.EndDate=System.today();
        CancelMembershipReport.OppAssetWrapper obj= new CancelMembershipReport.OppAssetWrapper();
    }*/
    @isTest static void TestDataSetup1(){
        Id MembershipOppId = [Select Id, Name From RecordType Where SobjectType = 'Opportunity' and Name='Membership'].Id;
        Account acc = new Account(Name = 'Test account', billingStreet = 'street');
        insert acc;

        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;

        Opportunity oppt = new Opportunity(RecordTypeId=MembershipOppId,
                                           name='Test Cancelled Opportunity',
        accountId=acc.Id ,
        StageName='Closed Lost',
        Loss_Reason__c ='Other' ,
        Type='Renewal',
        CloseDate=Date.today(),
        Renewal_Opportunity_Closed__c='True');
        insert oppt;

        Id pricebookId = Test.getStandardPricebookId();
        PriceBook2 pbk = new PriceBook2(Name = 'testBook', isActive = true);
        insert pbk;

        Product2 prod = new Product2(Name = 'TestP', productcode = 'test', isActive = true);
        insert prod;

        PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId, Product2Id = prod.ID, isActive = true, unitPrice = 34);
        insert standardPbe;

        PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pbk.Id, isActive = true, Product2Id = prod.ID, unitPrice = 20.0, useStandardPrice = false);
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Quantity = 2, unitPrice = 200, PriceBookEntryId = standardPbe.ID, AgreementDate__c = System.today());
        insert oli;
        
        OpportunityContactRole objContactRole = new OpportunityContactRole();
        objContactRole.OpportunityId = oppt.id;
        objContactRole.ContactId = con.id;
        objContactRole.Role ='Membership Decision Maker	';
        objContactRole.IsPrimary = true;
        insert objContactRole;
        
        Asset objAsset = new Asset();
        objAsset.Name ='Test Asset';
        objAsset.Projects__c  = TestFactory.getProject().id;
        objAsset.Opportunity__c = oppt.id;
        objAsset.Product2Id = prod.id;
        objAsset.OpportunityLineItem__c = oli.id;
        objAsset.AccountId = acc.id;
        objAsset.Cancellation_Date__c =Date.today().addDays(4);
        objAsset.PurchaseDate =Date.today();
        objAsset.Cancellation_Reason__c ='Other';
        objAsset.Status ='Invoice Cancelled';
        insert objAsset;
        
        Project__c objProject =TestFactory.getProject();
        Project_Role__c objPR= new Project_role__c();
        objPR.Asset__c =objAsset.id;
        objPR.Contact__c = con.id;
        objPR.Role__c ='Marketing Contact';
        objPR.Status__c ='Active';
        insert objPR;
        
        Project_Role__c objPR1= new Project_role__c();
        objPR1.Asset__c =objAsset.id;
        objPR1.Contact__c = con.id;
        objPR1.Role__c ='Representative/Voting Contact';
        objPR1.Status__c ='Active';
        insert objPR1;
        
        Project_Role__c objPR2= new Project_role__c();
        objPR2.Asset__c =objAsset.id;
        objPR2.Contact__c = con.id;
        objPR2.Role__c ='Technical Contact';
        objPR2.Status__c ='Active';
        insert objPR2;
        
        CancelMembershipReport objClass = new CancelMembershipReport();
        objClass.projectName ='[0066w000001rUUh]';
        objClass.getAsset();
        objClass.getselectedProject();
        objClass.ExportToExcel();
        objClass.startDate =System.today();
        objClass.EndDate=System.today();
        CancelMembershipReport.OppAssetWrapper obj= new CancelMembershipReport.OppAssetWrapper();
    }
}