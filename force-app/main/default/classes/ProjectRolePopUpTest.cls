/**
 * Created by cloudroute on 08/10/20.
 */

@IsTest
private class ProjectRolePopUpTest {

    @TestSetup static void createTestData(){
        Account acc = TestDataUtils.createAccount('free training Account');

        Contact con = TestDataUtils.createContact('test','linuxtest',acc.Id);

        //Create New Business
        Opportunity opp = TestDataUtils.createOpenOpportunity(acc.id,'free training opp','2. Discovery');
        opp.Type = 'New Business';
        update opp;

        //INSERT MEMBERSHIP PRODUCT
        Product2 prod = TestDataUtils.createProduct('hyperledger','description',6,'Membership');

        PricebookEntry pbid = TestDataUtils.createPriceBookEntryID(prod.id);

        Project__c project= TestDataUtils.createProject(true,'The Linux Foundation','Event','Subproject','Planned');

        OpportunityLineItem oppProdID = TestDataUtils.createOpportunityProduct(opp.id,pbid.id);
        oppProdID.Projects__c = project.Id;
        oppProdID.Technical_Contact__c = con.Id;
        oppProdID.Marketing_Contact__c = con.Id;
        oppProdID.Press_Contact__c = con.Id;
        oppProdID.Legal_Contact__c = con.Id;
        oppProdID.PO_Contact__c = con.Id;
        oppProdID.Authorized_Signatory__c = con.Id;
        update oppProdID;

        //Create renewal Opp
        Asset asset = TestDataUtils.createAsset(true,'ABC Asset 2',acc.id,prod.Id,'Purchased');

        Opportunity renewOpp = TestDataUtils.createOpenOpportunity(acc.id,'free training opp','2. Discovery');
        renewOpp.Type = 'Renewal';
        renewOpp.Parent_Asset__c = asset.Id;
        update renewOpp;

        OpportunityLineItem renewOppItem = TestDataUtils.createOpportunityProduct(renewOpp.id,pbid.id);
        renewOppItem.Projects__c = project.Id;
        renewOppItem.Billing_Contact2__c = con.Id;
        renewOppItem.Billing_Contact3__c = con.Id;
        renewOppItem.Marketing_Contact_2__c = con.Id;
        renewOppItem.Marketing_Contact_3__c = con.Id;
        renewOppItem.Technical_Contact_2__c = con.Id;
        renewOppItem.Technical_Contact_3__c = con.Id;
        renewOppItem.Sponsorship_Contact__c = con.Id;
        update renewOppItem;

        asset.OpportunityLineItem__c = renewOppItem.Id;
        update asset;

        List<Project_Role__c> projectRoles = new List<Project_Role__c>();
        Project_Role__c objProjectRole = new Project_Role__c();
        objProjectRole.status__c ='Active';
        objProjectRole.Contact__c = con.id;
        objProjectRole.Role__c ='Billing Contact';
        objProjectRole.Opportunity__c = opp.Id;
        objProjectRole.Opportunity_Line_Item__c = oppProdID.Id;
        objProjectRole.PrimaryContact__c = true;
        projectRoles.add(objProjectRole);

        Project_Role__c objProjectRole1 = new Project_Role__c();
        objProjectRole1.status__c ='Active';
        objProjectRole1.Contact__c = con.id;
        objProjectRole1.Role__c ='Representative/Voting Contact';
        objProjectRole1.Opportunity__c = opp.Id;
        objProjectRole1.Opportunity_Line_Item__c = oppProdID.Id;
        projectRoles.add(objProjectRole1);

        Project_Role__c objProjectRole2 = new Project_Role__c();
        objProjectRole2.status__c ='Active';
        objProjectRole2.Contact__c = con.id;
        objProjectRole2.Role__c ='Billing Contact';
        objProjectRole2.Opportunity__c = renewOpp.Id;
        objProjectRole2.Opportunity_Line_Item__c = renewOppItem.Id;
        projectRoles.add(objProjectRole2);

        Project_Role__c objProjectRole3 = new Project_Role__c();
        objProjectRole3.status__c ='Active';
        objProjectRole3.Contact__c = con.id;
        objProjectRole3.Role__c ='Representative/Voting Contact';
        objProjectRole3.Opportunity__c = renewOpp.Id;
        objProjectRole3.Opportunity_Line_Item__c = renewOppItem.Id;
        projectRoles.add(objProjectRole3);

        insert projectRoles;

    }

    @IsTest static void testGetOpportunity(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Type = 'New Business'];
        Test.startTest();
        Opportunity o = ProjectRolePopUp.getOpportunityDetails(opp.Id);
        Test.stopTest();
        System.assertEquals(false,o.IsWon);
    }

    @IsTest static void testGetOpportunityLineItems(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Type = 'New Business'];
        Test.startTest();
        List<OpportunityLineItem> oli = ProjectRolePopUp.getOpportunityLineItem(opp.Id);
        Test.stopTest();
        System.assertEquals(null,[SELECT Id,Marketing_Contact_3__c FROM OpportunityLineItem WHERE Id =: oli[0].Id].Marketing_Contact_3__c);
    }

    @IsTest static void testFetchProjectRoles(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Type = 'New Business'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Opportunity.Type = 'New Business'];
        Test.startTest();
        Opportunity opportunity = ProjectRolePopUp.getOpportunityDetails(opp.Id);
        List<Project_role__c> pRole = ProjectRolePopUp.fetchProjectRole(opp.Id, oli.Id, JSON.serialize(opportunity));
        Test.stopTest();
        System.debug('##pRole :'+pRole.size());
    }

    @IsTest static void testSaveProjectRoles(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Type = 'New Business'];
        Test.startTest();
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Opportunity.Type = 'New Business'];
        Contact con = [SELECT Id FROM Contact];

        List<Project_Role__c> projectRoles = [SELECT Id, Contact__c FROM Project_Role__c];

        //Project Roles Wrapper
        List<ProjectRolePopUp.ProjectRoleWrapper> wrapperList = new List<ProjectRolePopUp.ProjectRoleWrapper>();
        for(Project_Role__c pr: projectRoles){
            ProjectRolePopUp.ProjectRoleWrapper wrap = new ProjectRolePopUp.ProjectRoleWrapper();
            wrap.isOld = 'true';
            wrap.contactName = pr.Contact__c;
            wrap.pr = pr;
            wrapperList.add(wrap);
        }
        //Add one new role
        ProjectRolePopUp.ProjectRoleWrapper wrap1 = new ProjectRolePopUp.ProjectRoleWrapper();
        wrap1.isOld = 'false';
        wrap1.contactName = con.Id;
        wrap1.pr = new Project_Role__c(Role__c = 'Technical Contact', Status__c = '');
        wrapperList.add(wrap1);
        Opportunity opportunity = ProjectRolePopUp.getOpportunityDetails(opp.Id);
        ProjectRolePopUp.saveProjectRoles(opp.Id,JSON.serialize(wrapperList),oli.Id,JSON.serialize(opportunity));
        Test.stopTest();
    }

    @IsTest static void testSaveProjectRoles2(){
        Account acc = [SELECT id from Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact];

        Opportunity opp = TestDataUtils.createOpenOpportunity(acc.id,'free training opp','2. Discovery');
        opp.Type = 'New Business';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Alternate Funding').getRecordTypeId();
        update opp;

        //INSERT MEMBERSHIP PRODUCT
        Product2 prod = TestDataUtils.createProduct('Donation','description',6,'Alternate Funding');

        PricebookEntry pbid = TestDataUtils.createPriceBookEntryID(prod.id);

        Project__c project= TestDataUtils.createProject(false,'Donation','','Subproject','Planned');
        project.slug__c = 'test_donation';
        insert project;

        OpportunityLineItem oppProdID = TestDataUtils.createOpportunityProduct(opp.id,pbid.id);
        oppProdID.Projects__c = project.Id;
        oppProdID.Type__c = 'Alternate Funding';
        update oppProdID;

        List<Project_Role__c> projectRoles = [SELECT Id, Contact__c FROM Project_Role__c];

        //Project Roles Wrapper
        List<ProjectRolePopUp.ProjectRoleWrapper> wrapperList = new List<ProjectRolePopUp.ProjectRoleWrapper>();
        for(Project_Role__c pr: projectRoles){
            ProjectRolePopUp.ProjectRoleWrapper wrap = new ProjectRolePopUp.ProjectRoleWrapper();
            wrap.isOld = 'true';
            wrap.contactName = pr.Contact__c;
            wrap.pr = pr;
            wrapperList.add(wrap);
        }
        //Add one new role
        ProjectRolePopUp.ProjectRoleWrapper wrap1 = new ProjectRolePopUp.ProjectRoleWrapper();
        wrap1.isOld = 'false';
        wrap1.contactName = con.Id;
        wrap1.pr = new Project_Role__c(Role__c = 'Billing Contact', Status__c = 'Active', PrimaryContact__c=true);
        wrapperList.add(wrap1);
        Test.startTest();
        Opportunity opportunity = ProjectRolePopUp.getOpportunityDetails(opp.Id);
        ProjectRolePopUp.saveProjectRoles(opp.Id,JSON.serialize(wrapperList),oppProdID.Id,JSON.serialize(opportunity));
        Test.stopTest();
    }

    @IsTest static void testGetPicklistValues(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Type = 'New Business'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Opportunity.Type = 'New Business'];
        Test.startTest();
        ProjectRolePopUp.getRole(oli.Id);
        ProjectRolePopUp.getStatus();
        Test.stopTest();
    }

    @IsTest static void testGetOpportunityRenewal(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Type = 'Renewal'];
        Test.startTest();
        ProjectRolePopUp.getOpportunityDetails(opp.Id);
        Test.stopTest();
    }

    @IsTest static void testGetOpportunityLineItemsRenewal(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Type = 'Renewal'];
        Test.startTest();
        ProjectRolePopUp.getOpportunityLineItem(opp.Id);
        Test.stopTest();
    }

    @IsTest static void testFetchProjectRolesRenewal(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Type = 'Renewal'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Opportunity.Type = 'Renewal'];
        Test.startTest();
        Opportunity opportunity = ProjectRolePopUp.getOpportunityDetails(opp.Id);
        ProjectRolePopUp.fetchProjectRole(opp.Id, oli.Id, JSON.serialize(opportunity));
        Test.stopTest();
        List<Project_Role__c> roles = [SELECT Id from Project_Role__c WHERE Opportunity__c =: opportunity.Id];
        delete roles;
        ProjectRolePopUp.fetchProjectRole(opp.Id, oli.Id, JSON.serialize(opportunity));
    }

    @IsTest static void testSaveProjectRolesRenewal(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Type = 'Renewal'];
        Test.startTest();
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Opportunity.Type = 'Renewal'];
        Contact con = [SELECT Id FROM Contact];

        List<Project_Role__c> projectRoles = [SELECT Id, Contact__c FROM Project_Role__c];

        //Project Roles Wrapper
        List<ProjectRolePopUp.ProjectRoleWrapper> wrapperList = new List<ProjectRolePopUp.ProjectRoleWrapper>();
        for(Project_Role__c pr: projectRoles){
            ProjectRolePopUp.ProjectRoleWrapper wrap = new ProjectRolePopUp.ProjectRoleWrapper();
            wrap.isOld = 'true';
            wrap.contactName = pr.Contact__c;
            wrap.pr = pr;
            wrapperList.add(wrap);
        }
        //Add one new role
        ProjectRolePopUp.ProjectRoleWrapper wrap1 = new ProjectRolePopUp.ProjectRoleWrapper();
        wrap1.isOld = 'false';
        wrap1.contactName = con.Id;
        wrap1.pr = new Project_Role__c(Role__c = 'Billing_Contact2__c', Status__c = '');
        wrapperList.add(wrap1);
        Opportunity opportunity = ProjectRolePopUp.getOpportunityDetails(opp.Id);
        ProjectRolePopUp.checkForRenewal(oli.Id);
        ProjectRolePopUp.saveProjectRoles(opp.Id,JSON.serialize(wrapperList),oli.Id,JSON.serialize(opportunity));
        Test.stopTest();

    }
    @isTest
    private static void testCopyProjectLineItem() {
        // Test data setup
     //INSERT MEMBERSHIP PRODUCT
     Product2 prod = TestDataUtils.createProduct('Test','description',3,'Membership');

     PricebookEntry pbid = TestDataUtils.createPriceBookEntryID(prod.id);
     Opportunity opp = [SELECT Id FROM Opportunity WHERE Type = 'New Business'];
     OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Opportunity.Type = 'New Business'];
       
     Project__c project = [SELECT Id  FROM Project__c LIMIT 1];

     OpportunityLineItem oppProdID = TestDataUtils.createOpportunityProduct(opp.id,pbid.id);
        oppProdID.Projects__c = project.Id;
        update oppProdID;

        // Actual test
        Test.startTest();
        ProjectRolePopUp.copyProjectRoleToLineItem(oli.Id,opp.Id);
        Test.stopTest();
    
        // Asserts
    }
}