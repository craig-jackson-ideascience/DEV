@isTest
public class TestFactory {
    
    @isTest 
    public static Account getAccount(){
        List<Account> lstAcc = new List<Account>([SELECT Id, Name, phone, Website, BillingCity, BillingStreet, BillingPostalCode, BillingCountry
                                                  FROM Account
                                                  WHERE Website = 'example.com'
                                                  LIMIT 1]);
        if(!lstAcc.isEmpty()){
            return lstAcc[0];
        } else {
            Account acc = new Account(Name = 'Test IssueAcc', Phone = '11111',Website = 'example.com', BillingCity = 'Littleton',
                                      BillingState = 'Colorado', BillingPostalCode = '80120', BillingCountry = 'United States',
                                      BillingStreet = '1601-1649 W Weaver Ave');
            insert acc;
            return acc;
        }  
        
    }
    
    
     @isTest
    public static Contact getContact(){

        Account acc = TestFactory.getAccount();
        List<Contact> lstContact = [SELECT Id, FirstName, LastName, AccountId FROM Contact
        WHERE Email = 'hal.jordan@example.com' LIMIT 1];
        if(!lstContact.isEmpty()){
            return lstContact[0];
        } else {

            Contact objContact = new Contact(FirstName = 'Hal', Lastname = 'Jordan', AccountId = acc.Id, MailingCountry= 'United States',
                    Email = 'hal.jordan@example.com');
            Insert objContact;
            return objContact;
        }
    }
    
    @isTest
    public static User getUser(){
	List<User> lstUser = new List<User>();
        User objUser = new User();
        lstUser = [SELECT Id, Username, Alias, Email, FirstName, LastName, LocaleSidKey,
                        TimeZoneSidKey, LanguageLocaleKey
                        FROM User
                        WHERE Email = 'standarduser123@testorg.com'
                        LIMIT 1];

        if(!lstUser.isEmpty()){
            system.debug('exisitng user'+lstUser[0]);
            objUser = lstUser[0];
        }else{
            Profile Standardprofile = [Select Id from Profile where name = 'Standard User'];
            objUser = new User(
                    ProfileId = Standardprofile.Id,
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
        }
        return objUser;
    }
    
    @isTest
    public static Opportunity getOpportunity(){ 
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Opportunity oppt = new Opportunity();
        lstOpportunity = [SELECT Id, Name 
                        FROM Opportunity
                        WHERE Name = 'Opportunity testing 1'
                        LIMIT 1];
        
       
        if(!lstOpportunity.isEmpty()){
            system.debug('exisitng user'+lstOpportunity[0]);
            oppt = lstOpportunity[0];
        }else{
             Account acc = TestFactory.getAccount();
      		oppt = new Opportunity (Name='Opportunity testing 1' , accountId=acc.Id , StageName='2. Discovery' , CloseDate=Date.today().addDays(4) );
        insert oppt;
        }
    	
        
        return oppt;
    }
    
    @isTest
    public static PriceBook2 getPricebook(){ 
        List<PriceBook2> lstPriceBook2 = new List<PriceBook2>();
        PriceBook2 pbk = new PriceBook2();
        lstPriceBook2 = [Select Id, Name From PriceBook2 Where name = 'testBook' ];
        
        if(!lstPriceBook2.isEmpty()){
            system.debug('exisitng user'+lstPriceBook2[0]);
            pbk = lstPriceBook2[0];
        }else{
            pbk = new PriceBook2(Name = 'testBook',isActive =true);
            insert pbk; 
        }
     
        return pbk;
    }
    
    @isTest
    public static Product2 getProduct2(){
         List<Product2> lstProduct2 = new List<Product2>();
        Product2 prod = new Product2();
        lstProduct2 = [Select Id, Name,isActive  From Product2 Where name = 'TestP'];
        
        if(!lstProduct2.isEmpty()){
           prod =  lstProduct2[0];
        }else{
            prod = new Product2(Name = 'TestP',productcode='test', Family='Membership',isActive = true);
        insert prod; 
        }
        
		return prod;     
    }
    
    @isTest
    public static PriceBookEntry getPriceBookEntry(){
        PriceBook2 pbk = TestFactory.getPricebook();
        Product2 prod = TestFactory.getProduct2();
       
       	Id pricebookId = Test.getStandardPricebookId();
       
        PriceBookEntry standardPbe = new PriceBookEntry(PriceBook2Id = pricebookId,Product2Id=prod.ID,isActive=true,unitPrice=34);
        insert standardPbe;
                
        PriceBookEntry pbe=new PriceBookEntry(PriceBook2Id=pbk.Id,isActive=true,Product2Id=prod.ID,unitPrice=20.0,useStandardPrice=false);
        insert pbe;
        
        return pbe;
    }
    
    @isTest
    public static OpportunityLineItem getOpportunityLineItem(){
        Opportunity oppt = TestFactory.getOpportunity();
        PriceBookEntry pbe = TestFactory.getPriceBookEntry(); 
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id,Quantity =2, unitPrice = 20,PriceBookEntryId = pbe.ID);    
        insert oli;
        
        return oli;
    }
    
     @isTest
    public static Project__c getProject(){
         List<Project__c> lstProject = new List<Project__c>();
        Project__c proj = new Project__c();
        lstProject = [SELECT Id, Name 
                        FROM Project__c
                        WHERE Name = 'Test Project'
                        LIMIT 1];
        
       
        if(!lstProject.isEmpty()){
            system.debug('exisitng user'+lstProject[0]);
            proj = lstProject[0];
        }else{
        User standard = TestFactory.getUser();
      proj = new Project__c(Name = 'Test Project',Category__c = 'Incorporated Entity',ownerid  = standard.ID, slug__c = 'testproj');
        Insert proj;
        }
        
        return proj;
    }
    
    @isTest
    public static Asset getAsset(){
        Project__c proj  = TestFactory.getProject();
        Opportunity oppt = TestFactory.getOpportunity();
        Product2 prod = TestFactory.getProduct2();
        Account acc = TestFactory.getAccount();
        OpportunityLineItem oli = TestFactory.getOpportunityLineItem();
        
        Asset asst = new Asset(Name = 'TEstcreateasset',AccountId = acc.ID, Projects__c = proj.ID ,
         Status = 'Active', UsageEndDate = system.today(), Number_of_Years_Required__c = 1,Opportunity__c = oppt.ID, 
         OpportunityLineItem__c = oli.id,Auto_Renew__c = TRUE,Product2Id = prod.ID);
        insert asst;

        return asst;
    }
    
    @isTest
    public static Campaign getCampaign(){
        Campaign camp = new Campaign(
            Name = 'TestCampaign',
            IsActive = true,                                                   
            Status = 'In Progress',                                         
            Description = 'TestCampaign'           
        );
        insert camp;
        
        return camp;
    }

    @istest
    public static Lead getLead(){
        Lead lead = new Lead(
            LastName = 'testing',
            Company = 'Test',                         
            Status = 'Unqualified',                        
            Title = 'PM',                                    
            Email = 'testingabc@test.com',                   
            Industry = 'Software'                      
        );
        insert lead;
        return lead;
    }
    
    @istest
    public static List<CampaignMember> getCampaignMember(){
        List<CampaignMember> camplist = new List<CampaignMember>();
        //Contact Campaign Member
        CampaignMember campmember = new CampaignMember(
            CampaignId =  TestFactory.getCampaign().id,   // Campaign
            ContactId = TestFactory.getContact().id         // contact
                     );
        
         camplist.add(campmember);
        //Lead Campaign Member
         CampaignMember campmember2 = new CampaignMember(
            CampaignId =  TestFactory.getCampaign().id,   // Campaign
            LeadId = TestFactory.getLead().id         // contact
                     );
        camplist.add(campmember2);
      
        insert camplist;
        return camplist;
    }
    
    


}