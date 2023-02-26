@isTest//(SeeAllData=true)
public class NewOpportunityProductControllerTest {
    
    public static testMethod void testMyControllerMembership() {
        
        
        User u = TestDataUtils.createUser(false, 'TestUser');
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Admin Custom'];
        u.ProfileId = p.Id;
        insert u;
        
        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            
            PageReference pg = Page.NewOpportunityProduct;
            Test.setCurrentPage(pg);
            
            Account acc =  TestDataUtils.createAccount(true,'Test Account');   
            Opportunity oppt = TestDataUtils.createOpenOpportunity(true,acc.Id,'New Deal Test','2. Discovery');
            Profile_by_allowed_Opportunity_Type__c pb =TestDataUtils.createProfileAllowedOpportunityType (true,'System Admin Custom','Test Setting');
            Product2 prod = TestDataUtils.createProduct(true,'Laptop X200','Test Product',true,'Membership');
            prod.IsActive = true;
            update prod;
            PricebookEntry pbEntry = TestDataUtils.createPriceBookEntryID(true,prod.Id);
			         
            Project__c project= TestDataUtils.createProject(true,'test Project','Membership','Subproject','Planned');
            project.status__c='Active';
            project.Type__c = 'Membership';
            project.Category__c = 'Subproject';
            project.Model__c = 'Membership';
            project.LF_Membership_Required__c = true;
            project.Manual_Status_Check__c=false;
            update project;
            
            Product_Details__c pd=TestDataUtils.createProductDetail(false,project.Id,null,null,prod.Id);
            pd.status__c='Active';
            pd.Price__c = 6000;
            insert pd;
            
            OpportunityLineItem oli = TestDataUtils.createOpportunityProduct(true,oppt.Id,pbEntry.Id);
            System.currentPageReference().getParameters().put('id', oppt.Id);
            ApexPages.StandardController ssc = new ApexPages.StandardController(oppt);
            NewOpportunityProductController controller = new NewOpportunityProductController(ssc);
            
            controller.selectedType='Membership';
            controller.selectedCategory='Subproject';
            controller.selectedProject='test Project';
            controller.opportunityID=oppt.id;
           
            //controller.selectedProduct=prod.id;
            //controller.selectedTier='Linux Foundation';
            controller.getOpportunityTypes();
            controller.getProductCategories();
            //controller.getProjectSubcategory();
            
            controller.getProjectsOrEvents();
            controller.callProductDetails();
            //controller.fetchProductDetails();
            if( controller.prodDetailWrapper.size()>0){
            controller.prodDetailWrapper[0].selected=true; 
            controller.prodDetailWrapper[0].productPrice=500;
            }
            controller.Cancel();
            controller.Submit(); 
                
            
                }
    }
     public static testMethod void testMyControllerEvent() {
        
        User u = TestDataUtils.createUser(true,'TestUser');
        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            
            PageReference pg = Page.NewOpportunityProduct;
            Test.setCurrentPage(pg);
            Account acc =  TestDataUtils.createAccount(true,'Test Account');   
            Opportunity oppt = TestDataUtils.createOpenOpportunity(true,acc.Id,'New Deal Test','2. Discovery');
            Profile_by_allowed_Opportunity_Type__c pb =TestDataUtils.createProfileAllowedOpportunityType (true,'Test Setting', 'System Administrator');
            Product2 prod = TestDataUtils.createProduct(true,'Laptop X200','Test Product Event',true,'Event');
            PricebookEntry pbEntry = TestDataUtils.createPriceBookEntryID(true,prod.Id);           
            Project__c project= TestDataUtils.createProject(true,'The Linux Foundation','Event','Subproject','Planned');
            project.status__c='Active';
            project.Manual_Status_Check__c=false;
            project.LF_Membership_Required__c = true;
            project.Model__c = 'Membership';
            project.Funding__c='Funded';
            update project;
            Event__c event= TestDataUtils.createEvent(false,'Test Event 999','Event',project.ID,'Project Event','Active');
            insert event;
            Product_Details__c pd=TestDataUtils.createProductDetail(false,null,event.Id,null,prod.Id);
            pd.Tier__c='Gold';
           // pd.Sub_Category__c='Event Sponsorship';
            pd.Sub_Category__c='EventSponsorship';
            insert pd;
            pd.Status__c = 'Active';
            update pd;
            Training__c tc =TestDataUtils.createTraining(true,'Test Training','Event','Android Development Training','Active');
            OpportunityLineItem oli = TestDataUtils.createOpportunityProduct(true,oppt.Id,pbEntry.Id);
            
            System.currentPageReference().getParameters().put('id', oppt.Id);
            
            ApexPages.StandardController ssc = new ApexPages.StandardController(oppt);
            NewOpportunityProductController controller = new NewOpportunityProductController(ssc);
            controller.selectedType='Event';
            controller.selectedCategory='Linux Foundation';
            //controller.selectedSubCategory='Event Sponsorship';
            controller.selectedSubCategory='EventSponsorship';
            controller.selectedProject='Test Event';
            controller.selectedProduct=prod.id;
            controller.opportunityID=oppt.id;
            //controller.getOpportunityTypes();
            controller.getProductCategories();
            //controller.getProjectSubcategory();
            
            controller.getProjectsOrEvents();
            controller.callProductDetails();
            //controller.fetchProductDetails();
            
            //NewOpportunityProductController.ProductDetailsWrapper tw= new NewOpportunityProductController.ProductDetailsWrapper(pd.id,'Laptop X200','test describe','','50',499','12',400,prod.id);
            if( controller.prodDetailWrapper.size()>0){
            controller.prodDetailWrapper[0].selected=true; 
            controller.prodDetailWrapper[0].productPrice=500;
            System.debug('>>>>   '+controller.prodDetailWrapper);
            }
            controller.Cancel();
            controller.Submit(); 
                
            
                }
    }
    public static testMethod void testMyControllerTraining() {
        
        User u = TestDataUtils.createUser(true,'TestUser');
        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            
            PageReference pg = Page.NewOpportunityProduct;
            Test.setCurrentPage(pg);
            
            Account acc =  TestDataUtils.createAccount(true,'Test Account');   
            Opportunity oppt = TestDataUtils.createOpenOpportunity(true,acc.Id,'New Deal Test','2. Discovery');
            Profile_by_allowed_Opportunity_Type__c pb =TestDataUtils.createProfileAllowedOpportunityType (true,'Test Setting', 'System Administrator');
            Product2 prod = TestDataUtils.createProduct(true,'Laptop X200','Test Product Training',true,'Training');
            PricebookEntry pbEntry = TestDataUtils.createPriceBookEntryID(true,prod.Id);
            Project__c project= TestDataUtils.createProject(true,'The Linux Foundation','Event','Subproject','Planned');
            project.status__c='Active';
            project.Manual_Status_Check__c=false;
            project.Model__c = 'Membership';
            project.LF_Membership_Required__c = true;
            project.Funding__c='Funded';
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

            System.currentPageReference().getParameters().put('id', oppt.Id);
           // NewOpportunityProductController.ProductDetailsWrapper pdw=new NewOpportunityProductController.ProductDetailsWrapper(pd.id,pd.Products__r.name,pd.Description__c,pd.Tier__c,pd.Start_Tier__c,pd.End_Tier__c,pd.Price__c,pd.products__c);
            //pdw.selected=true;
            
          
          
            ApexPages.StandardController ssc = new ApexPages.StandardController(oppt);
            NewOpportunityProductController controller = new NewOpportunityProductController(ssc);
            controller.selectedType='Training';
            controller.selectedCategory='Test Training';
            controller.opportunityID=oppt.id;
            //controller.selectedSubCategory='EventSponsorship';
            //controller.selectedProject='Test Event';
            //controller.selectedProduct=prod.id;
            //controller.selectedTier='Linux Foundation';
            //controller.getOpportunityTypes();
            controller.getProductCategories();
            //controller.getProjectSubcategory();
            
            controller.getProjectsOrEvents();
            controller.callProductDetails();
            //controller.fetchProductDetails();
            
            //controller.trainWrapper[0].selected=true; 
            //controller.trainWrapper[0].productPrice=400;
           
            controller.Cancel();
            controller.Submit(); 
                
            
        }
    }
}