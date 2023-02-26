@isTest
public class ProjectRoleTriggerHandlerTest {
    @isTest static void updateProjectTeam(){
        Account acc1 = new Account(Name = 'Test account' , website = 'testing123.com1');
        insert acc1;
        
        Contact contact = new Contact();
        contact.LastName = 'Test Contact 1';
        contact.Email = 'testcontact1@noreply.com';
        insert contact;
        
        Asset asset = new Asset();
        asset.Name = 'Test Asset';
        asset.Number_of_Years_Required__c = 2;
        asset.AccountId = acc1.Id;
        insert asset;
        
        Project_Role__c projectrole = New Project_Role__c();
        projectrole.Contact__c = contact.Id;
        projectrole.Asset__c = asset.Id;
        projectrole.Role__c = 'Marketing Contact';
        insert projectrole;
        System.assertEquals(1, [SELECT Count() FROM Project_Role__c WHERE Role__c = 'Marketing Contact']);
    }
    
    @isTest static void updateProjectTeam2(){
        Account acc1 = new Account(Name = 'Test account' , website = 'www.noreply.com');
        insert acc1;
        
        Contact contact = new Contact();
        contact.LastName = 'Test Contact 1';
        contact.Email = 'testcontact1@noreply.com';
        contact.AccountId = acc1.Id ;
        insert contact;
        
        Contact contact1 = new Contact();
        contact1.LastName = 'Test Contact 2';
        contact1.Email = 'testcontact2@gmail.com';
        contact1.AccountId = acc1.Id ;
        insert contact1;
        
        Alternate_Email__c ae1 = new Alternate_Email__c();
        ae1.Alternate_Email_Address__c ='testcontact2@noreply.com';
        ae1.Contact_Name__c = contact1.Id;
        ae1.Active__c = true;
        insert ae1;
        
        Asset asset = new Asset();
        asset.Name = 'Test Asset';
        asset.Number_of_Years_Required__c = 2;
        asset.AccountId = acc1.Id;
        insert asset;
        
        Project_Role__c projectrole = New Project_Role__c();
        projectrole.Contact__c = contact.Id;
        projectrole.Asset__c = asset.Id;
        projectrole.Role__c = 'Marketing Contact';
        insert projectrole;
        
        Project_Role__c projectrole1 = New Project_Role__c();
        projectrole1.Contact__c = contact1.Id;
        projectrole1.Asset__c = asset.Id;
        projectrole1.Role__c = 'PO Contact';
        insert projectrole1;
        
        System.assertEquals('testcontact2@noreply.com', [SELECT Alternate_Email__r.Alternate_Email_Address__c FROM Project_Role__c WHERE Role__c = 'PO Contact'].Alternate_Email__r.Alternate_Email_Address__c);
        System.assertEquals(1, [SELECT Count() FROM Project_Role__c WHERE Role__c = 'Marketing Contact']);
        Project_Role__c role = [Select ID,Role__c From Project_Role__c Where ID =: projectrole.Id];
        role.Role__c ='Technical Contact';
        Update role;
        List<Project_Role__c> deleteList = new List<Project_Role__c>();
        List<Project_Role__c> projectroles = [Select Id From Project_Role__c];
        for(Project_Role__c prjtrole : projectroles){
            
            deleteList.add(prjtrole);
        }
        delete deleteList;
        undelete deleteList;
    }
    
    @IsTest static void testSaveProjectRolesRenewal(){
        Test.startTest();
        Account acc = TestDataUtils.createAccount('free training Account');
        
        Contact con = TestDataUtils.createContact('test','linuxtest',acc.Id);
        Contact con1 = TestDataUtils.createContact('test','linuxtest1',acc.Id);
        
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
        asset.OpportunityLineItem__c = oppProdID.Id;
        asset.Status = 'Active';
        update asset;
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
        
        List<Project_Role__c> projectRoles = new List<Project_Role__c>();
        Project_Role__c objProjectRole = new Project_Role__c();
        objProjectRole.status__c ='Active';
        objProjectRole.Contact__c = con.id;
        objProjectRole.Role__c ='Billing Contact';
        objProjectRole.Opportunity__c = opp.Id;
        objProjectRole.Asset__c = asset.Id;
        objProjectRole.Opportunity_Line_Item__c = oppProdID.Id;
        objProjectRole.PrimaryContact__c = true;
        projectRoles.add(objProjectRole);
        
        Project_Role__c objProjectRole1 = new Project_Role__c();
        objProjectRole1.status__c ='Active';
        objProjectRole1.Contact__c = con.id;
        objProjectRole1.Role__c ='Representative/Voting Contact';
        objProjectRole1.Opportunity__c = opp.Id;
        objProjectRole.Asset__c = asset.Id;
        objProjectRole1.Opportunity_Line_Item__c = oppProdID.Id;
        projectRoles.add(objProjectRole1);
        
        Project_Role__c objProjectRole4 = new Project_Role__c();
        objProjectRole4.status__c ='Active';
        objProjectRole4.Contact__c = con.id;
        objProjectRole4.Role__c ='Authorized Signatory';
        objProjectRole4.Opportunity__c = opp.Id;
        objProjectRole4.Asset__c = asset.Id;
        objProjectRole4.Opportunity_Line_Item__c = oppProdID.Id;
        objProjectRole4.PrimaryContact__c = true;
        projectRoles.add(objProjectRole4);
        insert projectRoles;
        projectRoles.clear();
        Project_Role__c objProjectRole2 = new Project_Role__c();
        objProjectRole2.status__c ='Active';
        objProjectRole2.Contact__c = con.id;
        objProjectRole2.Type__c ='Renewal';
        objProjectRole2.Role__c ='Billing Contact';
        objProjectRole2.Opportunity__c = renewOpp.Id;
        objProjectRole2.Opportunity_Line_Item__c = renewOppItem.Id;
        projectRoles.add(objProjectRole2);
        
        Project_Role__c objProjectRole3 = new Project_Role__c();
        objProjectRole3.status__c ='Active';
        objProjectRole3.Contact__c = con1.id;
        objProjectRole2.Type__c ='Renewal';
        objProjectRole3.Role__c ='Technical Contact';
        objProjectRole3.Opportunity__c = renewOpp.Id;
        objProjectRole3.Opportunity_Line_Item__c = renewOppItem.Id;
        projectRoles.add(objProjectRole3);
        
        insert projectRoles;
        Test.stopTest();
        
    }
    
    
    /*
@isTest static void updateSendDate_Test(){
Id oppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();


Project_Role_Map__c customSetting_role = new Project_Role_Map__c(Name = 'Technical Contact' , Api_Name__c = 'Technical_Contact__c');
insert customSetting_role;

Account acc = new Account(Name = 'Test account' , billingStreet = 'street' , billingCountry = 'brasil');
insert acc;

Contact con = new Contact(LastName = 'Test Contact' , AccountId=acc.Id,email='test@gmail.com');
insert con;

Opportunity oppt= new Opportunity(Name='Opportunity testing 1' , recordTypeId = oppRecId, accountId=acc.Id , StageName='2. Discovery' ,Type='Renewal', CloseDate=Date.today().addDays(4),Renewal_Opportunity_Closed__c='True' );
insert oppt;

Id pricebookId = Test.getStandardPricebookId();
PriceBook2 pbk = new PriceBook2(Name = 'testBook',isActive =true);
insert pbk; 

Product2 prod = new Product2(Name = 'TestP',productcode='test', Family = 'Membership');
insert prod;

PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId,Product2Id=prod.ID,isActive=true,unitPrice=34);
insert standardPbe;

PriceBookEntry pbe=new PriceBookEntry(PriceBook2Id=pbk.Id,isActive=true,Product2Id=prod.ID,unitPrice=20.0,useStandardPrice=false);
insert pbe;

Project__c project1= new Project__c(Name='LF Networking',Type__c='Membership',Category__c='Directed Fund',Status__c='Planned', Subsidiary_ID__c = 8);
insert project1;

Product_Details__c proDetail= new Product_Details__c(Netsuite_ID__c = '1111' , Project__c = project1.id , Products__c = prod.id);
insert proDetail;  

OpportunityLineItem oli= new OpportunityLineItem(Billing_Contact__c = con.id,Product_Details__c = proDetail.id , OpportunityId = oppt.Id, Quantity=2,
Renewal_type__c='Prorate', Projects__c = project1.Id, unitPrice = 20,PriceBookEntryId = pbe.ID,
start_date__c=date.today(),end_date__c=date.today().addDays(2) , Number_of_years_required__c=1 , order__c=1 , 
Representative_Voting_Contact__c=con.Id, Skip_NetSuite_Sync__c=FALSE,Send_Date__c=date.today());    
insert oli;

OpportunityContactRole ocr = new OpportunityContactRole(opportunityid=oppt.id,contactid=con.id,role='Decision Maker');
insert ocr;

oppt.StageName= 'Closed Won';
update oppt;             

system.debug('___project1__'+project1);

List<Asset> asst= [SELECT id,OpportunityLineItem__c,UsageEndDate,Renewal_Opportunity_Created__c FROM Asset];
System.debug('___asst__'+asst);

system.debug('____asst[0].Id___'+asst[0].Id);

Project_Role__c role = new Project_Role__c(Asset__c = asst[0].Id , Contact__c = con.Id , Role__c = 'Technical Contact');
insert role;

system.debug('____role____'+role);
System.assertEquals(date.today(), [SELECT Send_Date__c,Contact__r.Name FROM Project_Role__c WHERE Contact__r.Name = 'Test Contact' limit 1].Send_Date__c);
}*/
    
}