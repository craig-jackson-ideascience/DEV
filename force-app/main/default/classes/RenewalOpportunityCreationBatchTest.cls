@isTest
public class RenewalOpportunityCreationBatchTest 
{
    @testsetup
    static void setup(){
        Account acc = new Account(Name = 'Test account' , billingStreet = 'street', billingCountry = 'brasil');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact' , AccountId=acc.Id,email='test@gmail.com');
        insert con;
        
        Opportunity oppt= new Opportunity(Name='Opportunity testing 1' , accountId=acc.Id , StageName='2. Discovery' ,Type='Renewal',
                                          CloseDate=Date.today().addDays(4),Renewal_Opportunity_Closed__c='True' );
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
        
        Project__c project1= new Project__c(Name='LF Networking',Type__c='Membership',Category__c='Subproject',Status__c='Planned', Subsidiary_ID__c = 8, slug__c = 'lfnetwork');
        insert project1;
        
        Product_Details__c proDetail= new Product_Details__c(Netsuite_ID__c = '1111' , Project__c = project1.id , Products__c = prod.id , Price__c = 100, Description__c = 'Test Product Description');
        insert proDetail;
        
        OpportunityLineItem oli= new OpportunityLineItem(Billing_Contact__c = con.id,Representative_Voting_Contact__c = con.id,Authorized_Signatory__c = con.Id,Projects__c =project1.id, Product_Details__c = proDetail.id, OpportunityId = oppt.Id,Quantity =2,
                                                         unitPrice = 20,PriceBookEntryId = pbe.ID,start_date__c=date.today(),end_date__c=date.today().addDays(2) ,
                                                         Number_of_years_required__c=1 , order__c=1, NetSuite_ID__c='14823',NS_Entity_ID__c='18765',Renewal_type__c = 'Prorate');
        insert oli;
        
        OpportunityContactRole ocr = new OpportunityContactRole(opportunityid=oppt.id,contactid=con.id,role='Decision Maker');
        insert ocr;
        
        List<Asset> assetList = new List<Asset>();
        /*Asset assetObj = new Asset(Name='Test Asset',Projects__c = oli.Projects__c,usageenddate = oli.end_date__c,Auto_Renew__c = TRUE,Renewal_Opportunity_Created__c = FALSE,
                                   CNCF_Level__c = oli.CNCF_Level__c, Press_Release_Announcement__c= oli.No_Press_Release_Announcement__c,Display_Logo_On_Website__c = oli.Display_Logo_On_Website__c,
                                   NetSuite_Id__c = oli.NetSuite_Id__c,NS_Entity_ID__c=oli.NS_Entity_ID__c,order__c=oli.order__c,Bill_To_Account__c = oli.Opportunity.Bill_To_Account__c,
                                   Bill_To_Address__c = oli.Opportunity.Bill_To_Address__c,OpportunityLineItem__c = oli.id,Opportunity__c=oppt.Id);
        assetList.add(assetObj);*/
         Asset assetObj2 = new Asset(Name='Test Asset',Projects__c = oli.Projects__c,usageenddate = Date.newInstance(System.today().year(), 12, 05),Auto_Renew__c = TRUE,Renewal_Opportunity_Created__c = FALSE,
                                   CNCF_Level__c = oli.CNCF_Level__c, Press_Release_Announcement__c= oli.No_Press_Release_Announcement__c,Display_Logo_On_Website__c = oli.Display_Logo_On_Website__c,
                                   NetSuite_Id__c = oli.NetSuite_Id__c,NS_Entity_ID__c=oli.NS_Entity_ID__c,order__c=oli.order__c,Bill_To_Account__c = oli.Opportunity.Bill_To_Account__c,
                                   Bill_To_Address__c = oli.Opportunity.Bill_To_Address__c,OpportunityLineItem__c = oli.id,Opportunity__c=oppt.Id);
       assetList.add(assetObj2);
        insert assetList;
        List<Project_Role__c> projectRoles = new List<Project_Role__c>();
        Project_Role__c objProjectRole = new Project_Role__c();
        objProjectRole.status__c ='Active';
        objProjectRole.Contact__c = con.id;
        objProjectRole.Role__c ='Billing Contact';
        objProjectRole.PrimaryContact__c=true;
        objProjectRole.Asset__c = assetList[0].Id;
        projectRoles.add(objProjectRole);

        Project_Role__c objProjectRole1 = new Project_Role__c();
        objProjectRole1.status__c ='Active';
        objProjectRole1.Contact__c = con.id;
        objProjectRole1.Role__c ='Representative/Voting Contact';
        objProjectRole1.PrimaryContact__c=true;
        objProjectRole1.Asset__c = assetList[0].Id;
        projectRoles.add(objProjectRole1);

        Project_Role__c objProjectRole2 = new Project_Role__c();
        objProjectRole2.status__c ='Active';
        objProjectRole2.Contact__c = con.id;
        objProjectRole2.Role__c ='Technical Contact';
        objProjectRole2.Asset__c = assetList[0].Id;
        objProjectRole2.PrimaryContact__c=true;
        projectRoles.add(objProjectRole2);

        Project_Role__c objProjectRole3 = new Project_Role__c();
        objProjectRole3.status__c ='Active';
        objProjectRole3.Contact__c = con.id;
        objProjectRole3.Role__c ='Marketing Contact';
        objProjectRole3.PrimaryContact__c=true;
        objProjectRole3.Asset__c = assetList[0].Id;
        projectRoles.add(objProjectRole3);

        Project_Role__c objProjectRole4 = new Project_Role__c();
        objProjectRole4.status__c ='Active';
        objProjectRole4.Contact__c = con.id;
        objProjectRole4.Role__c ='Press Contact';
        objProjectRole4.PrimaryContact__c=true;
        objProjectRole4.Asset__c = assetList[0].Id;
        projectRoles.add(objProjectRole4);

        Project_Role__c objProjectRole5 = new Project_Role__c();
        objProjectRole5.status__c ='Active';
        objProjectRole5.Contact__c = con.id;
        objProjectRole5.Role__c ='Legal Contact';
        objProjectRole5.PrimaryContact__c=true;
      objProjectRole5.Asset__c = assetList[0].Id;
        projectRoles.add(objProjectRole5);
        
        insert projectRoles;
        List<Asset> asst= [SELECT id,OpportunityLineItem__c,UsageEndDate,Renewal_Opportunity_Created__c, NetSuite_ID__c, NS_Entity_ID__c FROM Asset];
        System.debug('___asst__'+asst);      
       
    }
    @IsTest
    private static void testBatchApex() {
        Test.startTest();
        String pastDate =String.valueOf(Date.today());
        System.debug(pastDate);        
        String qry = 'SELECT id,OpportunityLineItem__c,UsageEndDate,Renewal_Opportunity_Created__c ,Bill_To_Address__c,Bill_To_Account__c,'+
            'order__c, NS_Entity_ID__c,NetSuite_Id__c,Display_Logo_On_Website__c,Press_Release_Announcement__c,CNCF_Level__c,'+
            'Opportunity__c,Projects__r.Days_to_Deduct__c,AccountID FROM Asset WHERE Renewal_Opportunity_Created__c = FALSE and Auto_Renew__c = TRUE '+
            'and DAY_ONLY(convertTimezone(CreatedDate)) <='+pastDate+'  and Projects__c!=null and '+
            'Opportunity__c !=null and Status !=\'Invoice Cancelled\'';
        
        system.debug('__qry____'+qry);
        Database.executebatch(new RenewalOpportunityCreationBatch(qry));    
        Test.stopTest();
        List<Asset> assetList = [Select Id from Asset where Renewal_Opportunity_Created__c = true AND Renewal_Opportunity_Created__c = true];
        System.assertEquals(1, assetList.size());
    }
    
    @IsTest
    private static void testScheduleBatchApex() {
        Test.startTest();
        ScheduleRenewalOpportunityCreationBatch sc=new ScheduleRenewalOpportunityCreationBatch();
        sc.execute(null);
        Test.stopTest();
        
    }
}