@isTest
private class SendContractDocuSignExtension_Test
{
    @testSetup
    static void setup(){
        Account a = new Account(Name = 'testAccount ');
        insert a;
        Contact con = new Contact(lastname = 'testCreateAsset', email = 'AssetonClosedWon@gmail.com', accountid = a.id);
        insert con;
        Opportunity o = new Opportunity();
        o.AccountId = a.Id;
        o.Name = 'test';
        o.StageName = '2. Discovery';
        o.Type = 'Existing Business';
        o.CloseDate = date.today();
        o.Bill_To_Account__c = a.Id;
        o.Authorized_Signatory__c = con.Id;
        insert o;
        
         ID priceBookID = Test.getStandardPricebookId();
        User standardUser = TestFactory.getUser();

        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Family = 'Membership';
        prod.IsActive = true;
        insert prod;

        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Product2Id = prod.id;
        standardPrice.UnitPrice = 234;
        standardPrice.IsActive = true;
        standardPrice.Pricebook2Id = pricebookId;
        insert standardPrice;
        
        OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = o.id, contactid = con.id, role = 'Membership Decision Maker', IsPrimary = True);
        insert ocr;        
        
        Project__c prj = new Project__c(Name = 'testing11',Do_not_Invoice__c = true, Status__c = 'Planned', Subsidiary_ID__c = 8,Category__c ='Subproject',slug__c='testdocusign');
        insert prj;
        
        Product_Details__c Pd = new Product_Details__c();
        Pd.Price__c = 56;
        //Pd.Subsidiary__c='The Linux Foundation';
        Pd.NS_Income_GL_Account__c = '290';
        pd.NS_Deferred_Revenue_Account__c = '284';
        pd.NS_Department__c = '10';
        pd.NS_Revenue_Schedule__c = '29';
        Pd.Netsuite_Sync__c = false;
        Pd.Duration__c = '45';
        Pd.Description__c = 'Description_Test';
        Pd.Tier__c = 'Test';
        pd.Netsuite_ID__c = '889955';
        pd.Project__c = prj.id;
        pd.Products__c = prod.id;
        pd.Project_Signatory__c=standardUser.Id;
        pd.Docusign_Template_Id__c='test';
        insert Pd;

		OpportunityLineItem ol = new OpportunityLineItem();
        ol.OpportunityId = o.Id;
        ol.Quantity = 1;
        ol.UnitPrice = 2.00;
        ol.PricebookEntryId = standardPrice.Id;
        //ol.start_date__c=date.today();
        ol.start_date__c = Date.newInstance(2016, 8, 1);
        ol.end_date__c = date.today().addDays(2);
        ol.Prorate__c = true;
        ol.Technical_Contact__c = con.Id;
        ol.Representative_Voting_Contact__c = con.Id;
        ol.Marketing_Contact__c = con.Id;
        ol.Authorized_Signatory__c = con.Id;
        ol.Marketing_Contact_2__c = con.Id;
        ol.Marketing_Contact_3__c= con.Id;
        ol.Technical_Contact_2__c= con.Id;
        ol.Technical_Contact_3__c= con.Id;
        ol.PO_Contact__c = con.Id;
        ol.Press_Contact__c = con.Id;
        ol.Legal_Contact__c = con.Id;
        ol.Sponsorship_Contact__c = con.Id;
        ol.Billing_Contact__c = con.Id;
        ol.billing_contact2__c = con.Id;
        ol.billing_contact3__c = con.Id;
        ol.Projects__c = prj.Id;
        ol.Product_Details__c = pd.id;
        ol.PO_Number__c = '8899774455';
        //  ol.End_Date__c= Date.newInstance(2016, 12, 9);
        insert ol;

        List<Project_Role__c> projectRoles = new List<Project_Role__c>();
        Project_Role__c objProjectRole = new Project_Role__c();
        objProjectRole.status__c ='Active';
        objProjectRole.Contact__c = con.id;
        objProjectRole.Role__c ='Billing Contact';
        objProjectRole.PrimaryContact__c=true;
        objProjectRole.Opportunity__c = o.Id;
        objProjectRole.Opportunity_Line_Item__c = ol.Id;
        projectRoles.add(objProjectRole);

        Project_Role__c objProjectRole1 = new Project_Role__c();
        objProjectRole1.status__c ='Active';
        objProjectRole1.Contact__c = con.id;
        objProjectRole1.Role__c ='Representative/Voting Contact';
        objProjectRole1.PrimaryContact__c=true;
        objProjectRole1.Opportunity__c = o.Id;
        objProjectRole1.Opportunity_Line_Item__c = ol.Id;
        projectRoles.add(objProjectRole1);

        Project_Role__c objProjectRole2 = new Project_Role__c();
        objProjectRole2.status__c ='Active';
        objProjectRole2.Contact__c = con.id;
        objProjectRole2.Role__c ='Technical Contact';
        objProjectRole2.PrimaryContact__c=true;
        objProjectRole2.Opportunity__c = o.Id;
        objProjectRole2.Opportunity_Line_Item__c = ol.Id;
        projectRoles.add(objProjectRole2);

        Project_Role__c objProjectRole3 = new Project_Role__c();
        objProjectRole3.status__c ='Active';
        objProjectRole3.Contact__c = con.id;
        objProjectRole3.Role__c ='Marketing Contact';
        objProjectRole3.PrimaryContact__c=true;
        objProjectRole3.Opportunity__c = o.Id;
        objProjectRole3.Opportunity_Line_Item__c = ol.Id;
        projectRoles.add(objProjectRole3);

        Project_Role__c objProjectRole4 = new Project_Role__c();
        objProjectRole4.status__c ='Active';
        objProjectRole4.Contact__c = con.id;
        objProjectRole4.Role__c ='Press Contact';
        objProjectRole4.PrimaryContact__c=true;
        objProjectRole4.Opportunity__c = o.Id;
        objProjectRole4.Opportunity_Line_Item__c = ol.Id;
        projectRoles.add(objProjectRole4);

        Project_Role__c objProjectRole5 = new Project_Role__c();
        objProjectRole5.status__c ='Active';
        objProjectRole5.Contact__c = con.id;
        objProjectRole5.Role__c ='Legal Contact';
        objProjectRole5.PrimaryContact__c=true;
        objProjectRole5.Opportunity__c = o.Id;
        objProjectRole5.Opportunity_Line_Item__c = ol.Id;
        projectRoles.add(objProjectRole5);

        Project_Role__c objProjectRole6 = new Project_Role__c();
        objProjectRole6.status__c ='Active';
        objProjectRole6.Contact__c = con.id;
        objProjectRole6.Role__c ='Authorized Signatory';
        objProjectRole6.PrimaryContact__c=true;
        objProjectRole6.Opportunity__c = o.Id;
        objProjectRole6.Opportunity_Line_Item__c = ol.Id;
        projectRoles.add(objProjectRole6);

        Project_Role__c objProjectRole7 = new Project_Role__c();
        objProjectRole7.status__c ='Active';
        objProjectRole7.Contact__c = con.id;
        objProjectRole7.Role__c ='Event Sponsorship';
        objProjectRole7.PrimaryContact__c=true;
        objProjectRole7.Opportunity__c = o.Id;
        objProjectRole7.Opportunity_Line_Item__c = ol.Id;
        projectRoles.add(objProjectRole7);

        Project_Role__c objProjectRole8 = new Project_Role__c();
        objProjectRole8.status__c ='Active';
        objProjectRole8.Contact__c = con.id;
        objProjectRole8.Role__c ='PO Contact';
        objProjectRole8.PrimaryContact__c=true;
        objProjectRole8.Opportunity__c = o.Id;
        objProjectRole8.Opportunity_Line_Item__c = ol.Id;
        projectRoles.add(objProjectRole8);

        insert projectRoles;

        
    }
    
    public static testmethod void Test_docusignStatusSent(){
        Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp()); 
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name='test' LIMIT 1];
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Sent', dsfs__Opportunity__c = o.id);
        insert ds;
        SendContractDocuSignExtension instance = new SendContractDocuSignExtension(new ApexPages.StandardController(o));
        System.Assert(instance.processDocusign() == null);
        instance.goToRecord();
    }
    
     public static testmethod void Test_docusignStatusWithoutVotingContact(){
        Project_Role__c votingProj = [Select Id from Project_Role__c Where Role__c ='Representative/Voting Contact'];
        delete votingProj;
        Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp()); 
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name='test' LIMIT 1];
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Sent', dsfs__Opportunity__c = o.id);
        insert ds;
        SendContractDocuSignExtension instance = new SendContractDocuSignExtension(new ApexPages.StandardController(o));
        System.Assert(instance.processDocusign() == null);
        instance.goToRecord();
    }
    
    public static testmethod void Test_docusignStatusWithoutAuthSignatory(){
        Project_Role__c authProj = [Select Id from Project_Role__c Where Role__c ='Authorized Signatory'];
        delete authProj;
        Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp()); 
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name='test' LIMIT 1];
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Sent', dsfs__Opportunity__c = o.id);
        insert ds;
        SendContractDocuSignExtension instance = new SendContractDocuSignExtension(new ApexPages.StandardController(o));
        System.Assert(instance.processDocusign() == null);
        instance.goToRecord();
    }
    
    public static testmethod void Test_docusignStatusWithoutBillingRole(){
        Project_Role__c billProj = [Select Id from Project_Role__c Where Role__c ='Billing Contact'];
        delete billProj;
        Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp()); 
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name='test' LIMIT 1];
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Sent', dsfs__Opportunity__c = o.id);
        insert ds;
        SendContractDocuSignExtension instance = new SendContractDocuSignExtension(new ApexPages.StandardController(o));
        System.Assert(instance.processDocusign() == null);
        instance.goToRecord();
    }
    
    public static testmethod void Test_docusignIsNotSent(){
        Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp());
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name='test' LIMIT 1];       
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Not Sent', dsfs__Opportunity__c = o.id);
        insert ds;
        
        SendContractDocuSignExtension instance = new SendContractDocuSignExtension(new ApexPages.StandardController(o));
        Test.startTest();
        instance.processDocusign();
        instance.sendDocuSign();
        instance.sendDS();
        instance.goToRecord();
        Test.stopTest();
    }
    public static testmethod void Test_docusignStatusNotPresent(){
        
        Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp());
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name='test' LIMIT 1];        
        SendContractDocuSignExtension instance = new SendContractDocuSignExtension(new ApexPages.StandardController(o));
        Test.startTest();
        instance.processDocusign();
        instance.envelopeId = 'test';
        instance.sendDocuSign();
        //instance.sendDS();
        instance.goToRecord();
        Test.stopTest();
    }
    
    
    @isTest
    public static void validateDates_test(){
        Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp());
        Account acc = TestDataUtils.createAccount('free training Account');
        
        Opportunity opp = TestDataUtils.createOpenOpportunity(acc.id,'free training opp','2. Discovery');
        
        //INSERT MEMBERSHIP PRODUCT
        Product2 prodId = TestDataUtils.createProduct('hyperledger','description',6,'Membership');
        //INSERT FREE TRAINING PRODUCT
        Product2 prodId2 = TestDataUtils.createProduct('Free Training','description',6,'Training');
        
        PricebookEntry pbid = TestDataUtils.createPriceBookEntryID(prodId.id);
        PricebookEntry pbid2 = TestDataUtils.createPriceBookEntryID(prodId2.id);
        
        OpportunityLineItem oppProdID = TestDataUtils.createOpportunityProduct(opp.id,pbid.id);
        
        
        SendContractDocuSignExtension instance = new SendContractDocuSignExtension(new ApexPages.StandardController(opp));
        Test.startTest();
        instance.processDocusign();
        Test.stopTest();
    }
    
    @isTest
    public static void validateAuthorizedSignatory_test(){
        Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp());
        Account acc = TestDataUtils.createAccount('free training Account');
        
        Opportunity opp = TestDataUtils.createOpenOpportunity(acc.id,'free training opp','2. Discovery');
        
        //INSERT MEMBERSHIP PRODUCT
        Product2 prodId = TestDataUtils.createProduct('hyperledger','description',6,'Membership');
        //INSERT FREE TRAINING PRODUCT
        Product2 prodId2 = TestDataUtils.createProduct('Free Training','description',6,'Training');
        
        PricebookEntry pbid = TestDataUtils.createPriceBookEntryID(prodId.id);
        PricebookEntry pbid2 = TestDataUtils.createPriceBookEntryID(prodId2.id);
        
        OpportunityLineItem oppProdID = TestDataUtils.createOpportunityProduct(opp.id,pbid.id);
        oppProdID.Start_Date__c = system.today();
        oppProdID.End_Date__c = system.today();
        update oppProdID;
        
        SendContractDocuSignExtension instance = new SendContractDocuSignExtension(new ApexPages.StandardController(opp));
        Test.startTest();
        instance.processDocusign();
        Test.stopTest();
    }
    
    
    @isTest
    public static void processDocusign_test(){
        Test.setMock(HttpCalloutMock.class, new DocusignAPIMockHttp());
        Account account = TestDataUtils.createAccount('free training Account');
        Contact contact = new Contact();
        contact.LastName = 'Test Contact';
        contact.AccountId = account.Id;
        contact.Email = 'test@noReply.com';
        insert contact;
        
        Opportunity opp = TestDataUtils.createOpenOpportunity(account.id,'free training opp','2. Discovery'); 
        
        //INSERT MEMBERSHIP PRODUCT
        Product2 prodId = TestDataUtils.createProduct('hyperledger','description',6,'Membership');
        //INSERT FREE TRAINING PRODUCT
        Product2 prodId2 = TestDataUtils.createProduct('Free Training','description',6,'Training');
        
        PricebookEntry pbid = TestDataUtils.createPriceBookEntryID(prodId.id);
        PricebookEntry pbid2 = TestDataUtils.createPriceBookEntryID(prodId2.id);
        
        OpportunityLineItem oppProdID = TestDataUtils.createOpportunityProduct(opp.id,pbid.id);
        oppProdID.Start_Date__c = system.today();
        oppProdID.End_Date__c = system.today();
        oppProdID.Authorized_Signatory__c = contact.Id;
        update oppProdID;
        
        SendContractDocuSignExtension instance = new SendContractDocuSignExtension(new ApexPages.StandardController(opp));
        Test.startTest();
        instance.processDocusign();
        instance.sendDocuSign();
        Test.stopTest();
    }
    
}