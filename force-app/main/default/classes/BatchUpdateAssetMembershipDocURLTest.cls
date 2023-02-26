@isTest
public class BatchUpdateAssetMembershipDocURLTest {
	
    static Id membershipRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
    @testsetup
    private static void setup(){
        
        /* endpoints */
		List<Endpoints__c> listOfEndpoint = new List<Endpoints__c>();

		Endpoints__c endPoint = new Endpoints__c();
		endPoint.name = 'For Membership Asset';
		endPoint.endpoint__c = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=90&deploy=4';
		listOfEndpoint.add(endPoint);

		Endpoints__c endPoint2 = new Endpoints__c();
		endPoint2.Name = 'For Product Details';
		endPoint2.Endpoint__c = 'https://4010327-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=41&deploy=1';
		endPoint2.Password__c = 'jYdpn8sp22F8C45b';
		endPoint2.User_Id__c = 'nsapi@linuxfoundation.org';
		endPoint2.Nlauth_Account__c = '4010327_SB1';
		listOfEndpoint.add(endPoint2);

		insert listOfEndpoint;
        
        Account account =  new Account(Name='Test Account #1',website = 'somewebsite.com', BillingStreet = 'street');
        insert account;
        
        Contact con = new Contact(LastName = 'Test Contact', AccountId = account.Id, Email = 'test@contact.com');
		insert con;
        Project__c prj = new Project__c(Name = 'testing11',Slug__c='test', Notifications_Group__c = 'test@test.com', Status__c = 'Planned', Category__c = 'Directed Fund', Subsidiary_ID__c = 8);
        insert prj;
        
        prj.Status__c = 'Active';
		prj.Funding__c = 'Funded';
        prj.Model__c = 'Membership';
		update prj;
        
        /* event */
		Event__c evt = new Event__c(Name = 'test Event Name', Category__c = 'Non-LF Event', Start_Date__c = System.today(), End_Date__c = System.today()+1, BillFromProject__c = prj.id);
		//insert evt;
        
        
        
        
    }
    
    @IsTest
	static void UpdateAssetMembershipDocURL_test(){
		Test.startTest();
       
		Account a = [SELECT Id
		             FROM Account
		             LIMIT 1];
		Project__c prj = [SELECT Id
		                  FROM Project__c
		                  LIMIT 1];
		Contact con = [SELECT Id, Email
		               FROM Contact
		               WHERE Name = 'Test Contact'
		               LIMIT 1];
		/*Event__c evt = [SELECT Id
		                FROM Event__c
		                LIMIT 1];
		*/
        
		Opportunity o = new Opportunity();
		OpportunityLineItem ol = new OpportunityLineItem();
		o.AccountId = a.Id;
		o.Name = 'test';
		o.StageName = '2. Discovery';
		o.Type = 'Existing Business';
		o.CloseDate = date.today();
		o.Bill_To_Account__c = a.Id;
		insert o;
		ID priceBookID = Test.getStandardPricebookId();
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
		Product_Details__c pd = new Product_Details__c();
		pd.Price__c = 56;
		pd.NS_Income_GL_Account__c = '290';
		pd.NS_Deferred_Revenue_Account__c = '284';
		pd.NS_Department__c = '10';
		pd.NS_Revenue_Schedule__c = '29';
		pd.Netsuite_Sync__c = false;
		pd.Duration__c = '45';
		pd.Description__c = 'Description_Test';
		pd.Tier__c = 'Test';
		pd.Netsuite_ID__c = '889955';
		pd.Project__c = prj.id;
		pd.Products__c = prod.id;
		insert pd;
		ol.OpportunityId = o.Id;
		ol.Quantity = 1;
		ol.UnitPrice = 2.00;
		ol.PricebookEntryId = standardPrice.Id;
		ol.start_date__c = Date.newInstance(2016, 8, 1);
		ol.end_date__c = date.today().addDays(2);
		ol.Prorate__c = true;
		ol.Technical_Contact__c = con.Id;
		ol.Representative_Voting_Contact__c = con.Id;
		ol.Marketing_Contact__c = con.Id;
		ol.Authorized_Signatory__c = con.Id;
		ol.Marketing_Contact_2__c = con.Id;
		ol.Marketing_Contact_3__c = con.Id;
		ol.Technical_Contact_2__c = con.Id;
		ol.Technical_Contact_3__c = con.Id;
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
		insert ol;
		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c objProjectRole = new Project_Role__c();
		objProjectRole.status__c = 'Active';
		objProjectRole.Contact__c = con.id;
		objProjectRole.Role__c = 'Representative/Voting Contact';
		objProjectRole.PrimaryContact__c = true;
		objProjectRole.Opportunity__c = o.Id;
		objProjectRole.Opportunity_Line_Item__c = ol.Id;
		projectRoles.add(objProjectRole);
		Project_Role__c objProjectRole1 = new Project_Role__c();
		objProjectRole1.status__c = 'Active';
		objProjectRole1.Contact__c = con.id;
		objProjectRole1.Role__c = 'Billing Contact';
		objProjectRole1.PrimaryContact__c = true;
		objProjectRole1.Opportunity__c = o.Id;
		objProjectRole1.Opportunity_Line_Item__c = ol.Id;
		projectRoles.add(objProjectRole1);
		Project_Role__c objProjectRole2 = new Project_Role__c();
		objProjectRole2.status__c = 'Active';
		objProjectRole2.Contact__c = con.id;
		objProjectRole2.Role__c = 'Marketing Contact 5';
		objProjectRole2.Opportunity__c = o.Id;
		objProjectRole2.Opportunity_Line_Item__c = ol.Id;
		projectRoles.add(objProjectRole2);
		insert projectRoles;
		OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = o.id, contactid = con.id, role = 'Membership Decision Maker', IsPrimary = True);
		insert ocr;
        
        Attachment attach=new Attachment();   	
        attach.Name='OpportunityNameContract-Fully Executed';
        Blob bodyBlob=Blob.valueOf('OpportunityNameContract');
        attach.body=bodyBlob;
        attach.parentId=o.id;
        insert attach;
        
		
        o.Membership_Doc_Download_URL__c = null;
		update o;
        
        
        
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Completed', dsfs__Opportunity__c = o.id);
		insert ds;
        
        o.StageName = 'Closed Won';
        update o;
        
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());
		
        opportunity opp = [select id, name,Membership_Doc_Download_URL__c,iswon from opportunity where id = :o.id ];
        
        system.debug('batchopp: ' + opp );
        Database.executebatch(new BatchUpdateAssetMembershipDocURL(''));
        
        list<asset> asst = [select id,OpportunityLineItem__c,UsageEndDate,Renewal_Opportunity_Created__c,order__c,NS_Entity_ID__c,NetSuite_ID__c,
                                       Display_Logo_On_Website__c, Press_Release_Announcement__c,Bill_To_Address__c,Bill_To_Account__c,CNCF_Level__c, Opportunity__c, AccountID ,
                                       Projects__r.Days_to_Deduct__c
                            from asset 
                            where opportunity__c = :o.id];
        
        
        opportunity renewalOpp = o.clone(false,true,false,false);
        renewalOpp.StageName = '2. Discovery';
		renewalOpp.Type = 'Renewal';
		renewalOpp.CloseDate = date.today();
        renewalOpp.ApplicationStatus__c = '';
        renewalOpp.Parent_Asset__c = asst[0].id;
        renewalOpp.Membership_Doc_Download_URL__c = '';
        insert renewalOpp;
        
        //RenewalClassForOpps ren = new RenewalClassForOpps();
            
        //List<Opportunity> renewalOpps = new List<Opportunity>();
        
        //Map<ID,Asset> updateAssets = new Map<ID,Asset>();
        
        //updateAssets = ren.setCheckboxOnAsset(asst);
            
        //renewalOpps = ren.createRenewalOpps(asst);
        
        //renewalOpps[0].Membership_Doc_Download_URL__c = '';
        
        //update renewalOpps;
                
        Database.executebatch(new BatchUpdateAssetMembershipDocURL2(''));
        
        Test.stopTest();
    }
    
     @IsTest
	static void UpdateAssetMembershipDocURL2_test(){
		Test.startTest();
       
		Account a = [SELECT Id
		             FROM Account
		             LIMIT 1];
		Project__c prj = [SELECT Id
		                  FROM Project__c
		                  LIMIT 1];
		Contact con = [SELECT Id, Email
		               FROM Contact
		               WHERE Name = 'Test Contact'
		               LIMIT 1];
		/*Event__c evt = [SELECT Id
		                FROM Event__c
		                LIMIT 1];
		*/
        
		Opportunity o = new Opportunity();
		OpportunityLineItem ol = new OpportunityLineItem();
		o.AccountId = a.Id;
		o.Name = 'test';
		o.StageName = '2. Discovery';
		o.Type = 'Existing Business';
		o.CloseDate = date.today();
		o.Bill_To_Account__c = a.Id;
		insert o;
		ID priceBookID = Test.getStandardPricebookId();
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
		Product_Details__c pd = new Product_Details__c();
		pd.Price__c = 56;
		pd.NS_Income_GL_Account__c = '290';
		pd.NS_Deferred_Revenue_Account__c = '284';
		pd.NS_Department__c = '10';
		pd.NS_Revenue_Schedule__c = '29';
		pd.Netsuite_Sync__c = false;
		pd.Duration__c = '45';
		pd.Description__c = 'Description_Test';
		pd.Tier__c = 'Test';
		pd.Netsuite_ID__c = '889955';
		pd.Project__c = prj.id;
		pd.Products__c = prod.id;
		insert pd;
		ol.OpportunityId = o.Id;
		ol.Quantity = 1;
		ol.UnitPrice = 2.00;
		ol.PricebookEntryId = standardPrice.Id;
		ol.start_date__c = Date.newInstance(2016, 8, 1);
		ol.end_date__c = date.today().addDays(2);
		ol.Prorate__c = true;
		ol.Technical_Contact__c = con.Id;
		ol.Representative_Voting_Contact__c = con.Id;
		ol.Marketing_Contact__c = con.Id;
		ol.Authorized_Signatory__c = con.Id;
		ol.Marketing_Contact_2__c = con.Id;
		ol.Marketing_Contact_3__c = con.Id;
		ol.Technical_Contact_2__c = con.Id;
		ol.Technical_Contact_3__c = con.Id;
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
		insert ol;
		List<Project_Role__c> projectRoles = new List<Project_Role__c>();
		Project_Role__c objProjectRole = new Project_Role__c();
		objProjectRole.status__c = 'Active';
		objProjectRole.Contact__c = con.id;
		objProjectRole.Role__c = 'Representative/Voting Contact';
		objProjectRole.PrimaryContact__c = true;
		objProjectRole.Opportunity__c = o.Id;
		objProjectRole.Opportunity_Line_Item__c = ol.Id;
		projectRoles.add(objProjectRole);
		Project_Role__c objProjectRole1 = new Project_Role__c();
		objProjectRole1.status__c = 'Active';
		objProjectRole1.Contact__c = con.id;
		objProjectRole1.Role__c = 'Billing Contact';
		objProjectRole1.PrimaryContact__c = true;
		objProjectRole1.Opportunity__c = o.Id;
		objProjectRole1.Opportunity_Line_Item__c = ol.Id;
		projectRoles.add(objProjectRole1);
		Project_Role__c objProjectRole2 = new Project_Role__c();
		objProjectRole2.status__c = 'Active';
		objProjectRole2.Contact__c = con.id;
		objProjectRole2.Role__c = 'Marketing Contact 5';
		objProjectRole2.Opportunity__c = o.Id;
		objProjectRole2.Opportunity_Line_Item__c = ol.Id;
		projectRoles.add(objProjectRole2);
		insert projectRoles;
		OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = o.id, contactid = con.id, role = 'Membership Decision Maker', IsPrimary = True);
		insert ocr;
        
        Attachment attach=new Attachment();   	
        attach.Name='OpportunityNameContract-Fully Executed';
        Blob bodyBlob=Blob.valueOf('OpportunityNameContract');
        attach.body=bodyBlob;
        attach.parentId=o.id;
        insert attach;
        
		
        //o.Membership_Doc_Download_URL__c = null;
		//update o;
        
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c = 'Completed', dsfs__Opportunity__c = o.id);
		insert ds;
        
        o.StageName = 'Closed Won';
        update o;
        
        Test.setMock(HttpCalloutMock.class, new CallOutToNetSuiteMockHttp());		
        
        
        list<asset> asst = [select id,OpportunityLineItem__c,UsageEndDate,Renewal_Opportunity_Created__c,order__c,NS_Entity_ID__c,NetSuite_ID__c,
                                       Display_Logo_On_Website__c, Press_Release_Announcement__c,Bill_To_Address__c,Bill_To_Account__c,CNCF_Level__c, Opportunity__c, AccountID ,
                                       Projects__r.Days_to_Deduct__c
                            from asset 
                            where opportunity__c = :o.id];
        
        
        opportunity renewalOpp = o.clone(false,true,false,false);
        renewalOpp.StageName = '2. Discovery';
		renewalOpp.Type = 'Renewal';
		renewalOpp.CloseDate = date.today();
        renewalOpp.ApplicationStatus__c = '';
        renewalOpp.Parent_Asset__c = asst[0].id;
        renewalOpp.Membership_Doc_Download_URL__c = '';
        insert renewalOpp;
        
        asset asset2 = asst[0].clone(false,true,false,false);
        asset2.Name = 'testasset';
        asset2.Opportunity__c = renewalopp.Id;
        insert asset2;
        
        //RenewalClassForOpps ren = new RenewalClassForOpps();
            
        //List<Opportunity> renewalOpps = new List<Opportunity>();
        
        //Map<ID,Asset> updateAssets = new Map<ID,Asset>();
        
        //updateAssets = ren.setCheckboxOnAsset(asst);
            
        //renewalOpps = ren.createRenewalOpps(asst);
        
        //renewalOpps[0].Membership_Doc_Download_URL__c = '';
        
        //update renewalOpps;
        //
        opportunity renewalOpp2 = o.clone(false,true,false,false);
        renewalOpp2.StageName = '2. Discovery';
		renewalOpp2.Type = 'Renewal';
		renewalOpp2.CloseDate = date.today();
        renewalOpp2.ApplicationStatus__c = '';
        renewalOpp2.Parent_Asset__c = asset2.id;
        renewalOpp2.Membership_Doc_Download_URL__c = '';
        insert renewalOpp2;
                
        Database.executebatch(new BatchUpdateAssetMembershipDocURL2(''));
        
        Test.stopTest();
    }
}