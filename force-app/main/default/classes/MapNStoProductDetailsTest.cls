@isTest
public Class MapNStoProductDetailsTest{
    
    public static testMethod void  mappingMethodTest(){
          
        //Id DrcRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Directed Fund').getRecordTypeId();
        //Id IncRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Incorporated').getRecordTypeId();
        List<Product_Details__c> proDetailsList = new List<Product_Details__c>();
        List<Project__c> projList = new List<Project__c>();
        List<Product2> prodList = new List<Product2>();
        List<Event__c> evtList = new List<Event__c>();
        
      /*  NS_Revenue_Schedule_Mapping__c cusSet=new NS_Revenue_Schedule_Mapping__c();
                                       cusSet.name='Directed Fund';
                                       cusSet.Netsuite_ID__c=29;
                                       insert cusSet;
        NS_Income_GL_Account__c glAcc=new NS_Income_GL_Account__c();
                                glAcc.Id__c='290';
                                glAcc.NS_Income_GL_Account_Value__c= 'Membership Dues : Platinum Membership'; 
                                insert glAcc;
        NS_Deferred_Revenue_Account__c defAcc=new NS_Deferred_Revenue_Account__c();
                                       defAcc.Netsuite_ID__c='284';
                                       defAcc.Label_Name__c='Deferred Revenue : Deferred Revenue - Other' ;  
                                       insert defAcc; 
        Department_Mapping__c  depNet =new Department_Mapping__c   (); 
                                     depNet.Netsuite_ID__c=10;
                                     depNet.name='Sales';
                                     insert depNet ; */
                                     
        Endpoints__c endPoint = new Endpoints__c();
        endPoint.name = 'For Product Details';
        endPoint.endpoint__c     = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=11';   
        insert endPoint;                             
                                   
      
        Product2 proObj = new Product2 ();
        proObj.Name = 'Test';
        proObj.IsActive = True;
        proObj.ProductCode = 'Test';
        proObj.Family = 'Membership';
        insert proObj;

        Project__c parentProject = new Project__c(Name = 'The Linux Foundation',Category__c = 'Incorporated Entity', slug__c = 'testlinux');
        insert parentProject;
        
        parentProject.Status__c ='Active';
        parentProject.Funding__c ='Funded';
        parentProject.Model__c ='Membership';
        parentProject.Manual_Status_Check__c= false;
        update parentProject;

        Project__c proj1 = TestDataUtils.createProject(false,'test Project 1','Membership','Subproject','Planned');
        //proj1.RecordTypeId=IncRecordTypeId;
        //proj1.Subsidiary_ID__c = 26373;
        proj1.Subsidiary_ID__c = 1;
        proj1.Category__c = 'Incorporated Entity';
        proj1.Project_Code__c = 'P-232';
        proj1.NS_Department__c='10';
        proj1.NS_Deferred_Revenue_Account__c='282';
        projList.add(proj1);

        Project__c proj2 = TestDataUtils.createProject(false,'test Project 2','Membership','Subproject','Planned');
        proj2.Subsidiary_ID__c = 1;
        proj2.Category__c = 'Subproject';
        //proj2.LF_Membership_Required__c = true;
        proj2.Parent_Project__c = parentProject.Id;
        proj2.Model__c = 'Membership';
        proj2.slug__c ='testproject2';
        projList.add(proj2);

        Project__c proj3 = TestDataUtils.createProject(false,'test Project 3','Membership','Subproject','Planned');
        proj3.Subsidiary_ID__c = 1;
        //proj3.RecordTypeId=DrcRecordTypeId;
        proj3.Category__c = 'Subproject';
        proj3.Parent_Project__c = parentProject.Id;
        proj3.Model__c = 'Membership';
        proj3.slug__c ='testproject3';
        projList.add(proj3);
        
        insert projList;
        
        System.debug('debug :'+[SELECT LF_Membership_Required__c FROM PROJECT__C WHERE CATEGORY__C = 'Subproject']);
        

        
        system.debug('____projList____'+projList);
        
        
        prodList.add(TestDataUtils.createProduct(false,'Laptop X200','Test Product Event',true,'Membership'));
        prodList.add(TestDataUtils.createProduct(false,'Laptop X200','Test Product Event',true,'Event'));
        prodList.add(TestDataUtils.createProduct(false,'Laptop X200','Test Product Event',true,'Event'));
        prodList.add(TestDataUtils.createProduct(false,'Laptop X200','Test Product Event',true,'Membership'));
        insert prodList;
        
        system.debug('____prodList____'+prodList);
        
        Event__c event= TestDataUtils.createEvent(false,'Test Event 999','Event','Project Event','Active');
        event.BillFromProject__c =parentProject.id;
        evtList.add(event);
        
        Event__c event2= TestDataUtils.createEvent(false,'Test Event 888','Event','Project Event','Active'); 
        event2.NetSuite_Class__c='Training : Certification';
        event2.NS_Department__c='10'; 
        event2.NS_Income_GL_Account__c='171'; 
        event2.NS_Deferred_Revenue_Account__c='284';       
        event2.BillFromProject__c=parentProject.id;
        evtList.add(event2);
        
        insert evtList;
        
        system.debug('____evtList____'+evtList);
        
        Product_Details__c pd1 =TestDataUtils.createProductDetail(false,projList[0].Id,null,null,prodList[0].Id);
        pd1.NetSuite_Class__c='Training : Certification';
        pd1.NS_Income_GL_Account__c='171';
        pd1.NS_Revenue_Schedule__c = '29';
        pd1.NS_Deferred_Revenue_Account__c  = '284';
        pd1.price__c = 11;
        pd1.Products__c = proObj.id;
        proDetailsList.add(pd1);
        
        Product_Details__c pd2 = TestDataUtils.createProductDetail(false,null,evtList[0].Id,null,prodList[1].Id);
        pd2.Sub_Category__c='EventSponsorship';
        pd1.NS_Income_GL_Account__c='171';
        pd1.NS_Revenue_Schedule__c = '29';
        pd1.NS_Deferred_Revenue_Account__c  = '284';
        pd1.price__c = 11;
        pd1.Products__c = proObj.id;
        proDetailsList.add(pd2);
        
        Product_Details__c pd3=TestDataUtils.createProductDetail(false,null,evtList[1].Id,null,prodList[2].Id);
        pd3.Sub_Category__c='EventSponsorship';
        pd3.NetSuite_Class__c='Training : Certification'; 
        pd3.NS_Department__c='10'; 
        pd3.NS_Income_GL_Account__c='171'; 
        pd1.NS_Revenue_Schedule__c = '29';
        pd3.price__c = 11;
        pd1.Products__c = proObj.id;
        proDetailsList.add(pd3);
        
        Product_Details__c pd4 =TestDataUtils.createProductDetail(false,projList[2].Id,null,null,prodList[3].Id);        
        pd4.NS_Deferred_Revenue_Account__c='282';
        pd4.NS_Department__c='10'; 
        pd4.NetSuite_Class__c=NULL;
        pd4.NS_Income_GL_Account__c= '171';
        pd1.NS_Revenue_Schedule__c = '29';
        pd1.price__c = 11;
        pd1.Products__c = proObj.id;
        proDetailsList.add(pd4);
        
        insert proDetailsList;
        
        system.debug('____proDetailsList____'+proDetailsList);
        
        System.debug('____product_details___'+[select id from product_details__c where project__c=:projList[0].id]);   
        
        List<Project__c> proj = [Select Id, (Select Id from Product_Details__r) from Project__c where Id=:projList[0].id];

        system.debug('___innner_product___'+proj[0].Product_Details__r);
        
        Account acc = TestDataUtils.createAccount(true,'Test Account');
        
        Opportunity op = TestDataUtils.createOpenOpportunity(true,acc.Id, 'Test Opportunity' , '2. Discovery' );
        
        /* PriceBookEntry pbe = TestDataUtils.createPriceBookEntryID(true, prodList[0].Id);
        
        OpportunityLineItem ol = TestDataUtils.createOpportunityProduct(false,op.Id,pbe.Id);
        ol.Projects__c = projList[0].id ;
        ol.Product_Details__c = proDetailsList[0].Id;
        insert ol;
        
        */
        
        PriceBookEntry pbe2 = TestDataUtils.createPriceBookEntryID(true, prodList[1].Id);
        
        OpportunityLineItem ol2 = TestDataUtils.createOpportunityProduct(false,op.Id,pbe2.Id);
        ol2.Event__c = evtList[1].id ;
        ol2.Product_Details__c = proDetailsList[2].Id;
        insert ol2;
        
        //system.debug('____ol____'+ol);
        system.debug('____ol2___'+ol2);
        
        MapNStoProductDetails.mappingMethod(projList[0].id,'Project');   
        
        system.debug('____first___finished____');
        
        MapNStoProductDetails.mappingMethod(evtList[0].id,'event');

        system.debug('____second___finished____');

        MapNStoProductDetails.mappingMethod(evtList[1].id,'event');
        
        system.debug('____third___finished____');
 
        MapNStoProductDetails.mappingMethod(projList[2].id,'project');
        
        system.debug('____fourth___finished____');
          
        projList[2].NetSuite_Class__c='Training : Certification';
        projList[2].NS_Department__c=NULL; 
        projList[2].NS_Income_GL_Account__c='171'; 
        projList[2].NS_Deferred_Revenue_Account__c=Null;
        projList[2].Project_Code__c='105 - CODE';
        update projList[2];
        
        system.debug('____updated___proj___'+projList[2]);
          
        MapNStoProductDetails.mappingMethod(projList[2].id,'project');           
        
        system.debug('____fifth___finished____');
        
        projList[2].NS_Department__c='10'; 
        projList[2].NS_Deferred_Revenue_Account__c='284';
        update projList[2];
        
        system.debug('____updated___Proj2____'+projList[2]);
          
        MapNStoProductDetails.mappingMethod(projList[2].id,'project');
        
        system.debug('____sixth___finished____');
  
    }
}