@isTest
private class triggerToCountUniqueEvents_test{
    static testMethod void Test1(){
        //get standard pricebook
        Id  standardPb = Test.getStandardPricebookId();   
        // create product
        Product2 prod = new Product2(Name='test1',Family='test', IsActive=true,Tax_Class__c='t');
        insert prod;   
        
        PricebookEntry pbe = new PricebookEntry (Product2Id=prod.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe;
        // create account
        Account acc = new Account(name='Account');
        insert acc;
        // create opportunity
        Opportunity opp = new Opportunity(AccountId=acc.id,Name='test Oppty',CloseDate=system.today(),stagename='2. Discovery');
        insert opp;
        // create quote
        Quote qt = new Quote(Name='test quote',OpportunityId=opp.id,pricebook2id=standardPb);
        insert qt;
        // create project
        Project__c project = new Project__c(
            Name = 'The Linux Foundation',       
            Status__c = 'Planned', 
            Funding__c ='Funded',
            Category__c = 'Incorporated Entity',    
            ProjectSector__c = 'Platforms',         
            Membership_Autorenew__c = 'Yes',       
            Start_Date__c = system.today() - 10,   
            Renewal_Type__c = 'Prorate',           
            Payment_Frequency__c = 'Annually',     
            Bill_From_Name__c = 'The Linux Foundation',            
            Email_From_Name__c = 'Accounts Receivable',            
            Bill_From_Address__c = '1 Letterman Drive, Suite D4700',                  
            Email_From_Address__c = 'accountsreceivable@linuxfoundation.org',            
            Bill_From_City__c = 'San Francisco',                   
            Bill_From_Phone__c = '+1 415-723-9709',               
            Bill_From_State__c = 'CA',                             
            Bill_From_Website__c = 'www.linuxfoundation.org',      
            Bill_From_Zip__c = '94129',                     
            Image_File_for_PDF__c = 'the_linux_foundation_pdf_logo.jpg',            
            Bill_From_Country__c = 'United States',                        
            Include_W9__c = true,                            
            Project_Code__c = 'LF',                         
            Type__c = 'Membership',                                                                                                                                               
            Billfrom_ID__c = 'bf98299e-6a68-0f85-236b-52a0a366caba',                                                                                                                  
            Manual_Status_Check__c = true,
            Slug__c = 'test',
            Model__c ='Membership'
        );
        insert project;
        // updating Project Status to Active
        project.Manual_Status_Check__c = false;
        project.Status__c ='Active';
        update project;
        // create event
        Event__c event = new Event__c(Event_Name__c = 'KubeCon',
                                      Name= 'KubeCon',   
                                      Status__c = 'Complete',                                                                                                                                                  
                                      Category__c = 'LF Event',                                                                                                                                                
                                      BillFromProject__c = project.id,                                                                                                                                 
                                      Start_Date__c = system.today() - 20,                                                                                                                               
                                      Capacity__c = 0,                                                                                                                                          
                                      End_Date__c = system.today() - 10,                                                                                                                             
                                      Registration_Source__c = 'RegOnline',                                                                                                                                           
                                      Event_Location_Name__c = 'Twitter HQ One 10th Street Expansion',                                                                                                     
                                      Event_Published__c = false,                                                                                                                                           
                                      Event_Location_Address__c = 'One 10th Street',                                                                                                                     
                                      Event_Location_City__c = 'San Francisco',                                                                                                                          
                                      Event_Location_State__c = 'California',                                                                                                                            
                                      Event_Location_Country__c = 'United States',                                                                                                                         
                                      Event_Location_Zip__c = '94103',                                                                                                                                    
                                      Embassy__c = 'US',                                                                                                                                               
                                      Cvent_Event_Is_Sandbox__c = false,                                                                                                                                     
                                      //Type__c = 'Email',                                                                                                                                                     
                                      Netsuite_Sync__c = false );
        insert event;
        // create quote
        Quote objquote=new Quote();
        objquote.Name='TestQuote';
        objquote.OpportunityID=opp.id;
        insert objquote;
        // create quoteline
        QuoteLineItem objquotelineitem=new QuoteLineItem();
        objquotelineitem.QuoteId=qt.id;
        objquotelineitem.Product2ID=prod.id;
        objquotelineitem.Quantity=2;
        objquotelineitem.UnitPrice=45.78;
        objquotelineitem.Event__c=event.id;
        objquotelineitem.PricebookEntryId=pbe.Id;
        insert objquotelineitem; 
       
        System.assert(event.Id != null, 'The Test Event did not insert properly');
    }
    
}