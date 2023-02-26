@isTest
public class AddOpportunityProductControllerTest {
    public static testMethod void testMyControllerMembership() {
        User u = TestDataUtils.createUser(true,'TestUser');
        System.runAs(u) {
            Account acc =  TestDataUtils.createAccount(true,'Test Account');   
            Opportunity oppt = TestDataUtils.createOpenOpportunity(true,acc.Id,'New Deal Test','2. Discovery');
            Profile_by_allowed_Opportunity_Type__c pb =TestDataUtils.createProfileAllowedOpportunityType (true,'System Administrator','Test Setting');
            Product2 prod = TestDataUtils.createProduct(true,'Laptop X200','Test Product',true,'Membership');
            PricebookEntry pbEntry = TestDataUtils.createPriceBookEntryID(true,prod.Id);
			         
            Project__c project= TestDataUtils.createProject(true,'test Project','Membership','Subproject','Planned');
            project.status__c='Active';
            project.Manual_Status_Check__c=false;
            project.LF_Membership_Required__c = true;
            update project;
            Product_Details__c pd=TestDataUtils.createProductDetail(false,project.Id,null,null,prod.Id);
            pd.status__c='Active';
            insert pd;
            OpportunityLineItem oli = TestDataUtils.createOpportunityProduct(true,oppt.Id,pbEntry.Id);
            AddOpportunityProductController.getOpportunityTypes([SELECT ID,Name From Opportunity WHERE Name='New Deal Test'].ID);
            System.Assert(AddOpportunityProductController.getProductCategoriesAndProjects('Membership', '') != null);
            //System.Assert(AddOpportunityProductController.getProjectCategory([SELECT Id,Name From Project__c WHERE Name='test Project'].Name) != null);
            System.Assert(AddOpportunityProductController.getProducts('Membership','',[SELECT Id,Name From Project__c WHERE Name='test Project'].Name,'USD')!= null);
            //System.assertEquals('Laptop X200', (AddOpportunityProductController.getProducts('Membership','',[SELECT Id,Name From Project__c WHERE Name='test Project'].Name)[0].productName  ));
            //List<NewOpportunityProductController.ProductDetailsWrapper> productWrapper = AddOpportunityProductController.getProducts('Membership','',[SELECT Id,Name From Project__c WHERE Name='test Project'].Name);
            //productWrapper[0].selected = true;
           // productWrapper[0].productPrice=500;
           // string jsonwrapper = JSON.serialize(productWrapper);
            //AddOpportunityProductController.insertProducts('Membership',[SELECT ID,Name From Opportunity WHERE Name='New Deal Test'].ID,jsonwrapper);
        }	
    }
    
    public static testMethod void testMyControllerEvent() {
        User u = TestDataUtils.createUser(true,'TestUser');
        System.runAs(u) {
            Account acc =  TestDataUtils.createAccount(true,'Test Account');   
            Opportunity oppt = TestDataUtils.createOpenOpportunity(true,acc.Id,'New Deal Test','2. Discovery');
            Profile_by_allowed_Opportunity_Type__c pb =TestDataUtils.createProfileAllowedOpportunityType (true,'Test Setting', 'System Administrator');
            Product2 prod = TestDataUtils.createProduct(true,'Laptop X200','Test Product Event',true,'Event');
            PricebookEntry pbEntry = TestDataUtils.createPriceBookEntryID(true,prod.Id);           
            Project__c project= TestDataUtils.createProject(true,'The Linux Foundation','Event','Subproject','Planned');
            project.status__c='Active';
            project.Manual_Status_Check__c=false;
            project.LF_Membership_Required__c = true;
            update project;
            Event__c event= TestDataUtils.createEvent(false,'Test Event 999','Event',project.Id,'Project Event','Active');
            insert event;
            Product_Details__c pd=TestDataUtils.createProductDetail(false,null,event.Id,null,prod.Id);
            pd.Tier__c='Gold';
            pd.Sub_Category__c='EventSponsorship';
            pd.Price__c = 1000;
            insert pd;
            Training__c tc =TestDataUtils.createTraining(true,'Test Training','Event','Android Development Training','Active');
            OpportunityLineItem oli = TestDataUtils.createOpportunityProduct(true,oppt.Id,pbEntry.Id);
            System.Assert(AddOpportunityProductController.getProductCategoriesAndProjects('Event', 'Project Event') != null);
            System.Assert(AddOpportunityProductController.getProducts('Event','Project Event','Test Event 999','USD')!= null);
            System.assertEquals('Laptop X200', (AddOpportunityProductController.getProducts('Event','Project Event','Test Event 999','USD')[0].productName));
            List<NewOpportunityProductController.ProductDetailsWrapper> productWrapper = AddOpportunityProductController.getProducts('Event','Project Event','Test Event 999','USD');
            System.debug('productWrapper :'+productWrapper);
            for(NewOpportunityProductController.ProductDetailsWrapper wrap : productWrapper){
                wrap.selected = true;
                wrap.productPrice=500;
            }
            /*productWrapper[0].selected = true;
            productWrapper[0].productPrice=500;*/
            string jsonwrapper = JSON.serialize(productWrapper);
            AddOpportunityProductController.insertProducts('Event',[SELECT ID,Name From Opportunity WHERE Name='New Deal Test'].ID,jsonwrapper);
            
        }
    }
    
    public static testMethod void testMyControllerTraining() {
        
        User u = TestDataUtils.createUser(true,'TestUser');
        System.runAs(u) {
            Account acc =  TestDataUtils.createAccount(true,'Test Account');   
            Opportunity oppt = TestDataUtils.createOpenOpportunity(true,acc.Id,'New Deal Test','2. Discovery');
            Profile_by_allowed_Opportunity_Type__c pb =TestDataUtils.createProfileAllowedOpportunityType (true,'Test Setting', 'System Administrator');
            Product2 prod = TestDataUtils.createProduct(true,'Laptop X200','Test Product Training',true,'Training');
            PricebookEntry pbEntry = TestDataUtils.createPriceBookEntryID(true,prod.Id);
            Project__c project= TestDataUtils.createProject(true,'The Linux Foundation','Event','Subproject','Planned');
            project.status__c='Active';
            project.Manual_Status_Check__c=false;
            project.LF_Membership_Required__c = true;
            update project;
            Event__c event= TestDataUtils.createEvent(false,'Test Event 888','Event',project.Id,'Project Event','Active');
            insert event;
            Training__c tc =TestDataUtils.createTraining(true,'Test Training','Training','Android Development Training','Active');
            Product_Details__c pd=TestDataUtils.createProductDetail(false,null,null,tc.Id,prod.Id);
            pd.Tier__c='Gold';
            //pd.Sub_Category__c='Event Sponsorship';
            pd.Sub_Category__c='EventSponsorship';
            insert pd;
            
            OpportunityLineItem oli = TestDataUtils.createOpportunityProduct(true,oppt.Id,pbEntry.Id);
            System.Assert(AddOpportunityProductController.getProductCategoriesAndProjects('Training', '') != null);
            System.Assert(AddOpportunityProductController.getProducts('Training','Test Training','','USD')!= null);
            //System.assertEquals('Laptop X200', (AddOpportunityProductController.getProducts('Training','Test Training','')[0].productName));
            List<NewOpportunityProductController.ProductDetailsWrapper> productWrapper = AddOpportunityProductController.getProducts('Training','Test Training','','USD');
            System.debug('productWrapper :'+productWrapper);
            for(NewOpportunityProductController.ProductDetailsWrapper wrap : productWrapper){
                wrap.selected = true;
                wrap.productPrice=500;
            }
            /*productWrapper[0].selected = true;
            productWrapper[0].productPrice=500;*/
            string jsonwrapper = JSON.serialize(productWrapper);
            AddOpportunityProductController.insertProducts('Training',[SELECT ID,Name From Opportunity WHERE Name='New Deal Test'].ID,jsonwrapper);
            
        }
    }
    
    @isTest
    public static void insertSubscriptionProducts_test() {
        Test.startTest();
        User u = TestDataUtils.createUser(true,'TestUser');
        System.runAs(u) {
            Account acc =  TestDataUtils.createAccount(true,'Test Account');   
            Opportunity oppt = TestDataUtils.createOpenOpportunity(true,acc.Id,'New Deal Test','2. Discovery');
            oppt.CloseDate = Date.today();
            update oppt;
            Profile_by_allowed_Opportunity_Type__c pb =TestDataUtils.createProfileAllowedOpportunityType (true,'Test Setting', 'System Administrator');
            Product2 prod = TestDataUtils.createProduct(true,'Laptop X200','Test Product Event',true,'Event');
            Product2 prod1 = TestDataUtils.createProduct(true,'Certification','Test Product Event',true,'Event');
            Product2 prod2 = TestDataUtils.createProduct(true,'E-Learning','Test Product Event',true,'Event');
            PricebookEntry pbEntry = TestDataUtils.createPriceBookEntryID(true,prod.Id); 
            PricebookEntry pbEntry2 = TestDataUtils.createPriceBookEntryID(true,prod1.Id); 
            PricebookEntry pbEntry3 = TestDataUtils.createPriceBookEntryID(true,prod2.Id); 
            Project__c project= TestDataUtils.createProject(true,'The Linux Foundation','Event','Subproject','Planned');
            project.status__c='Active';
            project.Manual_Status_Check__c=false;
            project.LF_Membership_Required__c = true;
            update project;
            Event__c event= TestDataUtils.createEvent(false,'Test Event 999','Event',project.Id,'Project Event','Active');
            insert event;
            Product_Details__c pd=TestDataUtils.createProductDetail(false,null,event.Id,null,prod.Id);
            pd.Tier__c='Gold';
            pd.Sub_Category__c='EventSponsorship';
            pd.Price__c = 1000;
            insert pd;
            
            Product_Details__c pd2=TestDataUtils.createProductDetail(false,null,event.Id,null,prod1.Id);
            pd2.Price__c = 1000;
            insert pd2;
            Product_Details__c pd3=TestDataUtils.createProductDetail(false,null,event.Id,null,prod2.Id);
            pd3.Price__c = 1000;
            insert pd3;
            Training__c tc =TestDataUtils.createTraining(true,'Test Training','Event','Android Development Training','Active');
            OpportunityLineItem oli = TestDataUtils.createOpportunityProduct(true,oppt.Id,pbEntry.Id);
            System.Assert(AddOpportunityProductController.getProductCategoriesAndProjects('Event', 'Project Event') != null);
            System.Assert(AddOpportunityProductController.getProducts('Event','Project Event','Test Event 999','USD')!= null);
            System.assertEquals('Laptop X200', (AddOpportunityProductController.getProducts('Event','Project Event','Test Event 999','USD')[0].productName));
            List<NewOpportunityProductController.ProductDetailsWrapper> productWrapper = AddOpportunityProductController.getProducts('Event','Project Event','Test Event 999','USD');
            System.debug('productWrapper :'+productWrapper);
            for(NewOpportunityProductController.ProductDetailsWrapper wrap : productWrapper){
                wrap.selected = true;
                wrap.productPrice=500;
            }
            /*productWrapper[0].selected = true;
            productWrapper[0].productPrice=500;*/
            string jsonwrapper = JSON.serialize(productWrapper);
            System.debug('jsonwrapper'+jsonwrapper);
            AddOpportunityProductController.insertSubscriptionProducts(2,500,oppt.Id,jsonwrapper,'Bundle');
            Test.stopTest();
            //System.assertEquals(oppt.CloseDate, [SELECT Id,Product2.Name,Start_Date__c FROM OpportunityLineItem where OpportunityId =:oppt.Id AND Product2.Name = 'Certification'][0].Start_Date__c);
        }
    }
    
}