@isTest
public class ProjectTriggerHandlerTest {

    @isTest
    static void createTestMethod(){

        Id MembershipOppId = [Select Id, Name From RecordType Where SobjectType = 'Opportunity' and Name='Membership'].Id;
        //testFactory.getAccount();
        //User objUser = testFactory.getUser();
        
        Account acc= new Account(Name='ABC');
        Contact con = new Contact(
        Email = 'standarduser123@testorg.com',
        FirstName = 'Hal', 
        Lastname = 'Jordan', 
        AccountId = acc.Id, 
        MailingCountry= 'United States');
        insert con ;
        
         UserRole rid = [SELECT ID,Name From UserRole where Name ='Business Operations Manager'][0];
        Profile Standardprofile = [Select Id from Profile where name = 'Standard User'];
         User objUser = new User(
                    ProfileId = Standardprofile.Id,
                    //userRoleId=rid.Id,
                    Username = UserInfo.getOrganizationId() + System.now().millisecond()+'@testorg.com',
                    Alias = 'green',
                    Email = 'standarduser123@testorg.com',
                    EmailEncodingKey = 'UTF-8',
                    Firstname = 'Hal',
                    Lastname = 'Jordan',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimeZoneSidKey = 'America/Los_Angeles');
            insert objUser;
      
        //Creating Project Record Id
        Project__c objProject = new Project__c ();
        objProject.Name = 'New Test Project 12';
        objProject.Status__c = 'Planned';
        objProject.Type__c = 'Membership';
        objProject.Manual_Status_Check__c = false; 
        objProject.Category__c ='Incorporated Entity';
        objProject.Days_to_Deduct__c = '30';
        objProject.Slug__c = 'testing';
        objProject.Business_Development_Manager__c = con.ID;
        insert objProject; 

        // Creating Account Record in Test Class 
        Account objAccount = new Account();
        objAccount.Name='Test Acnt Record' ;
        insert objAccount;
        
        // Create Opportunity Record
        Opportunity objOpportunity= new Opportunity(RecordTypeId=MembershipOppId,Name='Opportunity testing 1' , accountId=objAccount.Id , StageName='2. Discovery' ,Type='New Business', CloseDate=Date.today().addDays(4),Renewal_Opportunity_Closed__c='True' );
        insert objOpportunity;
        
        Opportunity objOpportunitytest= new Opportunity(RecordTypeId=MembershipOppId,Name='Opportunity testing 2' , accountId=objAccount.Id , StageName='2. Discovery' ,Type='Renewal', CloseDate=Date.today().addDays(4),Renewal_Opportunity_Closed__c='True');
        insert objOpportunitytest;
        // This is how we get the Standard PriceBook Id.  Prior to Summer '14, we needed
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 objprod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert objprod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = objprod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = objOpportunity.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 1 * pbEntry.UnitPrice,
            Projects__c = objProject.id
        );
        insert oli;
        
        OpportunityLineItem objoli = new OpportunityLineItem(
            OpportunityId = objOpportunitytest.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 1 * pbEntry.UnitPrice,
            Projects__c = objProject.id
        );
        insert objoli;
        
        objProject.Renewal_owner__c = objUser.Id;  
		objProject.Opportunity_Owner__c = objUser.Id;
        objProject.Program_Manager_U__c = objUser.Id;
        objProject.Status__c='Active';
         objProject.Days_to_Deduct__c = '90';
        update objProject;  
        
    }
    

}