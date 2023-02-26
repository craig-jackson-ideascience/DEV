@IsTest
public class AssetTriggerHandlerTest {
    @TestSetup static void setup(){
        Asset ast =  TestFactory.getAsset();
        Account acc = TestFactory.getAccount();
        Project__c testProject =TestFactory.getProject();
        Project__c proj = new Project__c(Name = 'The Linux Foundation',Category__c = 'Incorporated Entity', Slug__c = 'test_slug');
        insert proj;
        Campaign camp = TestFactory.getCampaign();
        Contact con = TestFactory.getContact();
        
    }

    @IsTest
    static void UpdateAsset(){
        
        Project__c Project = [SELECT Id, Name FROM Project__c WHERE Name ='The Linux Foundation'];
         Asset ast = [SELECT Id,Name,Projects__r.Name,Projects__c,OpportunityLineItem__c, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState,
                                   Account.BillingPostalCode, Account.BillingCountry,Contact.Name,Contact.Email,Projects__r.OwnerId,Product2.Family,Opportunity__c,ContactId
                                   FROM Asset WHERE Name = 'TEstcreateasset'];
       
        ast.Projects__c = Project.Id;
        //ast.Project__c = Project.Name;
        update ast;
        
        Account acc = [SELECT Id,LF_Membership_Only__c FROM Account WHERE Name = 'Test IssueAcc'];
        System.assertEquals(true, acc.LF_Membership_Only__c);
        
        ast.Status = 'Expired';
        update ast;
        Account acc1 = [SELECT Id,LF_Membership_Only__c FROM Account WHERE Name = 'Test IssueAcc'];
        System.assertEquals(false, acc1.LF_Membership_Only__c);
        ast.Status = 'Active';
        update ast;          
        
        Asset asst = [SELECT Id, Status FROM Asset WHERE Id =: ast.Id];
        delete ast;

    }
    @isTest
    static void UpdateAssetToInvoiceCancelled(){
        
        Project__c Project = [SELECT Id, Name FROM Project__c WHERE Name ='The Linux Foundation'];
         Asset ast = [SELECT Id,Name,Projects__r.Name,Projects__c,OpportunityLineItem__c, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState,
                                   Account.BillingPostalCode, Account.BillingCountry,Contact.Name,Contact.Email,Projects__r.OwnerId,Product2.Family,Opportunity__c,ContactId
                                   FROM Asset WHERE Name = 'TEstcreateasset'];
        id oppid = ast.Opportunity__c;
        
        Contact Con = [SELECT Id, FirstName, LastName, AccountId FROM Contact
        WHERE Email = 'hal.jordan@example.com' LIMIT 1];
        
       
        
        opportunity opp = [SELECT Id, Billing_Contact__c
                              FROM Opportunity
                              where id = :oppid];
        
        opp.Billing_Contact__c = Con.Id;
        update opp;
        
        /* opportunity contact role */
		OpportunityContactRole ocr = new OpportunityContactRole(Opportunityid = opp.id, Contactid=opp.Billing_Contact__c, Role = 'Membership Decision Maker', IsPrimary = true);
        insert ocr;
        
        ast.Projects__c = Project.Id;
        //ast.Project__c = Project.Name;
        update ast;
        
        Account acc = [SELECT Id,LF_Membership_Only__c FROM Account WHERE Name = 'Test IssueAcc'];
        System.assertEquals(true, acc.LF_Membership_Only__c);
        
        ast.status = 'Invoice Cancelled';
        ast.Cancellation_Reason__c = 'Invoice Cancelled';
        ast.Cancellation_Date__c = system.today();
        update ast;  

    }

    @IsTest
    static void insertAsset(){
         Account acc = [SELECT Id,LF_Membership_Only__c FROM Account WHERE Name = 'Test IssueAcc'];
         Project__c Project1 = [SELECT Id, Name FROM Project__c WHERE Name ='The Linux Foundation'];
         Project__c Project = [SELECT Id, Name FROM Project__c WHERE Name ='Test Project'];
        Asset asst = new Asset(Name = 'TEstcreateasset',AccountId = acc.Id,
                               Projects__c = Project.Id , Status = 'Active'
                              );
        
        insert asst;
        
        Account acc1 = [SELECT Id,LF_Membership_Only__c FROM Account WHERE Name = 'Test IssueAcc'];
        System.assertEquals(false, acc1.LF_Membership_Only__c);
        
         Asset asst1 = new Asset(Name = 'TEstcreateasset',AccountId = acc.Id,
                               Projects__c = Project1.Id , Status = 'Active'
                              );
        insert asst1;
        
        Account acct = [SELECT Id,LF_Membership_Only__c FROM Account WHERE Id =: acc.Id];
         System.assertEquals(false, acct.LF_Membership_Only__c);

    }

    @IsTest
    static void updateProjectRoles(){
        
        Project__c Project = [SELECT Id, Name FROM Project__c WHERE Name ='The Linux Foundation'];
        //Added for updateProjectRoles method
        Campaign cmp = [SELECT Id, Name FROM Campaign WHERE Name ='TestCampaign' LIMIT 1];
        cmp.Project__c = Project.Id;
        cmp.Type = 'Web Form - Join Now';
        update cmp;
        Asset ast1 = new Asset();
        Asset ast = [SELECT Id,Name,Projects__r.Name,Projects__c,OpportunityLineItem__c, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState,
                                   Account.BillingPostalCode, Account.BillingCountry,Contact.Name,Contact.Email,Projects__r.OwnerId,Product2.Family
                                   FROM Asset WHERE Name = 'TEstcreateasset'];
        ast.Projects__c = Project.Id;
        //ast.Project__c = Project.Name;
        ast1 = ast;
        ast1.Status ='Purchased';
        update ast1;
        update ast;
        
        Account acc = [SELECT Id,LF_Membership_Only__c FROM Account WHERE Name = 'Test IssueAcc'];
        System.assertEquals(true, acc.LF_Membership_Only__c);
        
        Contact con1 = [SELECT Id,AccountId FROM Contact WHERE Name = 'Hal Jordan' LIMIT 1];
        Contact con2 = new Contact();
        con2.LastName = 'Phil';
        con2.FirstName ='Wright';
        con2.AccountId = acc.Id;
        insert con2;
        
        System.assertEquals(acc.Id, con1.AccountId);
        
        CampaignMember cmpMember1 = new CampaignMember(Subscription__c = 'Subscribe',Project_Role_Subscriptions__c = 'Voting Contact', CampaignId = cmp.Id, ContactId = con1.Id);
        insert cmpMember1;
        CampaignMember cmpMember2 = new CampaignMember(Subscription__c = 'Subscribe',Project_Role_Subscriptions__c = 'Voting Contact', CampaignId = cmp.Id, ContactId = con2.Id);
        insert cmpMember2;
        
        Project_Role__c projRole1 = new Project_Role__c(Contact__c = con1.Id, Role__c = 'Representative/Voting Contact', Asset__c = ast.Id);
        insert projRole1;
        Project_Role__c projRole2 = new Project_Role__c(Contact__c = con2.Id, Role__c = 'Representative/Voting Contact', Asset__c = ast.Id,Send_to_Groups_io__c=true);
        insert projRole2;
        
        ast.Status = 'Expired';
        //update ast;
        
        Account acc1 = [SELECT Id,LF_Membership_Only__c FROM Account WHERE Name = 'Test IssueAcc'];
        //System.assertEquals(false, acc1.LF_Membership_Only__c);
        
        ast.Status = 'Active';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new getAccessTokenCalloutMock());
        update ast;
        Test.stopTest();
             
    }
    @IsTest
    static void sendNotificationTest(){
        Project__c Project = [SELECT Id, Name FROM Project__c WHERE Name ='The Linux Foundation'];
        //Added for updateProjectRoles method
        Campaign cmp = [SELECT Id, Name FROM Campaign WHERE Name ='TestCampaign' LIMIT 1];
        cmp.Project__c = Project.Id;
        cmp.Type = 'Web Form - Join Now';
        update cmp;
        //Asset ast1 = new Asset();
        Asset ast = [SELECT Id,Name,Projects__r.Name,Projects__c,OpportunityLineItem__c, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState,
                                   Account.BillingPostalCode, Account.BillingCountry,Contact.Name,Contact.Email,Projects__r.OwnerId,Product2.Family
                                   FROM Asset WHERE Name = 'TEstcreateasset'];
        ast.Projects__c = Project.Id;
        //ast.Project__c = Project.Name;
        //ast1 = ast;
        //ast1.Status ='Purchased';
        //update ast1;
        update ast;
        
        Account acc = [SELECT Id,LF_Membership_Only__c FROM Account WHERE Name = 'Test IssueAcc'];
        System.assertEquals(true, acc.LF_Membership_Only__c);
        
        Contact con1 = [SELECT Id,Email,AccountId FROM Contact WHERE Name = 'Hal Jordan' LIMIT 1];
        Contact con2 = new Contact();
        con2.LastName = 'Phil';
        con2.FirstName ='Wright';
        con2.Email ='Wright@test.com';
        con2.AccountId = acc.Id;
        insert con2;
        
        System.assertEquals(acc.Id, con1.AccountId);
        
        CampaignMember cmpMember1 = new CampaignMember(Subscription__c = 'Subscribe',Project_Role_Subscriptions__c = 'Voting Contact', CampaignId = cmp.Id, ContactId = con1.Id);
        insert cmpMember1;
        CampaignMember cmpMember2 = new CampaignMember(Subscription__c = 'Subscribe',Project_Role_Subscriptions__c = 'Voting Contact', CampaignId = cmp.Id, ContactId = con2.Id);
        insert cmpMember2;
        
        Project_Role__c projRole1 = new Project_Role__c(Contact__c = con1.Id, Role__c = 'Representative/Voting Contact', Asset__c = ast.Id,Send_to_Groups_io__c=false);
        insert projRole1;
        Project_Role__c projRole2 = new Project_Role__c(Contact__c = con2.Id, Role__c = 'Representative/Voting Contact', Asset__c = ast.Id,Send_to_Groups_io__c=true);
        insert projRole2;
        
        //ast.Status = 'Expired';
        //update ast;
        
        //Account acc1 = [SELECT Id,LF_Membership_Only__c FROM Account WHERE Name = 'Test IssueAcc'];
        //System.assertEquals(false, acc1.LF_Membership_Only__c);
        List<Project_Role__c> projectRoleList = [SELECT Id, Contact__r.Name, Asset__c, Notification_Status__c, Asset__r.Projects__c, Send_to_Groups_io__c, ProjectName__c, ContactEmail__c, toLabel(Role__c)
                                                     FROM Project_Role__c ];
        String access_token ='eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlJFWTNSVGcyTT';
        
        
        Test.setMock(HttpCalloutMock.class, new sendNotificationRequestCallOut());
        Test.startTest();
        NotificationService.sendNotificationRequest(access_token, projectRoleList);
        Test.stopTest();
    }
    @IsTest
    static void sendNotificationTestError(){
        Project__c Project = [SELECT Id, Name FROM Project__c WHERE Name ='The Linux Foundation'];
        //Added for updateProjectRoles method
        Campaign cmp = [SELECT Id, Name FROM Campaign WHERE Name ='TestCampaign' LIMIT 1];
        cmp.Project__c = Project.Id;
        cmp.Type = 'Web Form - Join Now';
        update cmp;
        //Asset ast1 = new Asset();
        Asset ast = [SELECT Id,Name,Projects__r.Name,Projects__c,OpportunityLineItem__c, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState,
                                   Account.BillingPostalCode, Account.BillingCountry,Contact.Name,Contact.Email,Projects__r.OwnerId,Product2.Family
                                   FROM Asset WHERE Name = 'TEstcreateasset'];
        ast.Projects__c = Project.Id;
        //ast.Project__c = Project.Name;
        //ast1 = ast;
        //ast1.Status ='Purchased';
        //update ast1;
        update ast;
        
        Account acc = [SELECT Id,LF_Membership_Only__c FROM Account WHERE Name = 'Test IssueAcc'];
        System.assertEquals(true, acc.LF_Membership_Only__c);
        
        Contact con1 = [SELECT Id,Email,AccountId FROM Contact WHERE Name = 'Hal Jordan' LIMIT 1];
        Contact con2 = new Contact();
        con2.LastName = 'Phil';
        con2.FirstName ='Wright';
        con2.Email ='Wright@test.com';
        con2.AccountId = acc.Id;
        insert con2;
        
        System.assertEquals(acc.Id, con1.AccountId);
        
        CampaignMember cmpMember1 = new CampaignMember(Subscription__c = 'Subscribe',Project_Role_Subscriptions__c = 'Voting Contact', CampaignId = cmp.Id, ContactId = con1.Id);
        insert cmpMember1;
        CampaignMember cmpMember2 = new CampaignMember(Subscription__c = 'Subscribe',Project_Role_Subscriptions__c = 'Voting Contact', CampaignId = cmp.Id, ContactId = con2.Id);
        insert cmpMember2;
        
        Project_Role__c projRole1 = new Project_Role__c(Contact__c = con1.Id, Role__c = 'Representative/Voting Contact', Asset__c = ast.Id,Send_to_Groups_io__c=false);
        insert projRole1;
        Project_Role__c projRole2 = new Project_Role__c(Contact__c = con2.Id, Role__c = 'Representative/Voting Contact', Asset__c = ast.Id,Send_to_Groups_io__c=true);
        insert projRole2;
        
        //ast.Status = 'Expired';
        //update ast;
        
        //Account acc1 = [SELECT Id,LF_Membership_Only__c FROM Account WHERE Name = 'Test IssueAcc'];
        //System.assertEquals(false, acc1.LF_Membership_Only__c);
        List<Project_Role__c> projectRoleList = [SELECT Id, Contact__r.Name, Asset__c, Notification_Status__c, Asset__r.Projects__c, Send_to_Groups_io__c, ProjectName__c, ContactEmail__c, toLabel(Role__c)
                                                     FROM Project_Role__c ];
        String access_token ='eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlJFWTNSVGcyTT';
        
        
        Test.setMock(HttpCalloutMock.class, new sendNotificationRequestCallOut('Error'));
        Test.startTest();
        NotificationService.sendNotificationRequest(access_token, projectRoleList);
        Test.stopTest();
    }
    
    //tests createOrUpdateMembership and updateOrDeleteMembership
    @IsTest static void testMembershipMethods(){
        //setup test data
        Id corporateRTID = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        
        Account acc = [SELECT Id FROM Account];
        Project__c proj = [SELECT Id FROM Project__c WHERE Name = 'The Linux Foundation'];
        Product2 prod = TestFactory.getProduct2();
        
        prod.Family = 'Membership';
        update prod;
        
        //insert first asset to create membership record
        Asset asst = new Asset();
        asst.Name = 'Test corporate asset 1';
        asst.RecordTypeId = corporateRTID;
        asst.AccountId = acc.Id;
        asst.Projects__c = proj.Id;
        asst.Product2Id = prod.Id;
        asst.Skip_NetSuite_Sync__c = true;
        asst.Annual_Full_Price__c = 50000;
        asst.InstallDate = Date.newInstance(2018, 1, 1);
        asst.UsageEndDate = Date.newInstance(2018, 12, 31);
        insert asst;
        
        //insert second asset to update membership record
        Asset asst2 = new Asset();
        asst2.Name = 'Test corporate asset 2';
        asst2.RecordTypeId = corporateRTID;
        asst2.AccountId = acc.Id;
        asst2.Projects__c = proj.Id;
        asst2.Product2Id = prod.Id;
        asst2.Skip_NetSuite_Sync__c = true;
        asst2.Annual_Full_Price__c = 90000;
        asst2.InstallDate = Date.newInstance(2019, 1, 1);
        asst2.UsageEndDate = Date.newInstance(2019, 12, 31);
        insert asst2;

        //cancel second asset to update membership record
        asst2.Status = 'Invoice Cancelled';
        asst2.Cancellation_Date__c = Date.today();
        asst2.Cancellation_Reason__c = 'Other';
        update asst2;
        
        //cancel first asset to delete membership record
        asst.Status = 'Invoice Cancelled';
        asst.Cancellation_Date__c = Date.today();
        asst.Cancellation_Reason__c = 'Other';
        update asst;
        
        asst.status='Active';
		asst.Cancellation_Date__c = null;
        asst.Cancellation_Reason__c = '';  
        update asst;
    }
    @IsTest static void testUpdateCommunityDates(){
      //setup test data
      Id corporateRTID = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
      
      Account acc = [SELECT Id FROM Account];
      Project__c proj = [SELECT Id FROM Project__c WHERE Name = 'The Linux Foundation'];
      Product2 prod = TestFactory.getProduct2();
      
      prod.Family = 'Membership';
      update prod;
      
      Asset asst = new Asset();
      asst.Name = 'Test corporate asset 1';
      asst.RecordTypeId = corporateRTID;
      asst.AccountId = acc.Id;
      asst.Projects__c = proj.Id;
      asst.Product2Id = prod.Id;
      asst.Skip_NetSuite_Sync__c = true;
      asst.Annual_Full_Price__c = 50000;
      asst.InstallDate = Date.newInstance(2018, 1, 1);
      asst.UsageEndDate = Date.newInstance(2018, 12, 31);
      asst.Status = 'Active';
      insert asst;


      Contact con = new Contact();
      con.LastName = 'Phil';
      con.FirstName ='Wright';
      con.Email ='Wright@test.com';
      con.AccountId = acc.Id;
      insert con;

      Contact con2 = new Contact();
      con2.LastName = 'Phil';
      con2.FirstName ='Wright';
      con2.Email ='Wright1@test.com';
      con2.AccountId = acc.Id;
      insert con2;

      Project_Role__c projRole = new Project_Role__c();
      projRole.Contact__c = con.Id;
      projRole.Role__c = 'Representative/Voting Contact';
      projRole.Asset__c = asst.Id;
      projRole.Start_Date__c = Date.newInstance(2020, 01, 01);
      projRole.End_Date__c =Date.newInstance(2020, 12, 31);
      projRole.PrimaryContact__c = true;
      insert projRole;

      Project_Role__c projRole2 = new Project_Role__c();
      projRole2.Contact__c = con2.Id;
      projRole2.Role__c = 'Representative/Voting Contact';
      projRole2.Asset__c = asst.Id;
      projRole2.Start_Date__c = Date.newInstance(2020, 01, 01);
      projRole2.End_Date__c = Date.newInstance(2020, 12, 31);
      projRole2.PrimaryContact__c = true;
      insert projRole2;

      update asst;  
    }
    
    @IsTest
    public static void testData(){
        Asset ast = [SELECT Id,Opportunity__c,Projects__c FROM Asset LIMIT 1];
        Opportunity opp = new Opportunity(Id=ast.Opportunity__c,Project_Name__c=ast.Projects__c);
        update opp;
        ContentVersion contVer = new ContentVersion();
		contVer.Title = 'TestFullyexecuted';
		contVer.PathOnClient = 'test';
		contVer.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
		contVer.FirstPublishLocationId = ast.Opportunity__c;
		insert contVer;
        ast.Status = 'Expired';
        update ast;
    }
}