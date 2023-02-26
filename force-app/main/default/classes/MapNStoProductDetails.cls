/////////// TEST CLASS - ////////////////

global with sharing class MapNStoProductDetails{
    @AuraEnabled
    WebService static Integer mappingMethod(Id recordId , String projectOrEvent){
    
        Id Id_var = Id.valueOf(recordId);
        Integer success_Var = 0;
        //Id DrcRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Directed Fund').getRecordTypeId();
        //Id IncRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Incorporated').getRecordTypeId();
        List<Product_Details__c> prodToUpdate = new List<Product_Details__c>();
        Event__c evnt = new Event__c();
        Project__c projct = new Project__c();
        project__c projToSync = new project__c ();
        List<OpportunityLineItem> olisToUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> associatedOLIs = new List<OpportunityLineItem>();
        Map<Id,Product_Details__c> proDetailMap = new Map<Id,Product_details__c>();
        List <Event__c> eventToupdate = new list <Event__c> ();
        String billFromProject = '';
        String billFromId = '';
        
        System.debug('_____PROJECTOREVENT___'+projectOrEvent);
        system.debug('------------- Id_var '+Id_var );
        
        if(projectOrEvent=='event'){
        
            evnt = [Select Id, NetSuite_Sync__c,Job_Code__c, NetSuite_Class__c, NS_Revenue_Schedule__c, NS_Deferred_Revenue_Account__c, NS_Department__c, NS_Income_GL_Account__c, 
                    BillFromProject__c, Manual_Status_Check__c, BillFromProject__r.name,(Select Id, Event__c, NetSuite_Class__c, Netsuite_Sync__c, NS_Deferred_Revenue_Account__c, 
                                                                                         NS_Department__c, NS_Income_GL_Account__c , NS_Revenue_Schedule__c , Netsuite_ID__c, 
                                                                                         Price__c, Subsidiary_ID__c, Products__c from Product_Details__r Where Status__c != 'Inactive') 
                    from Event__c where Id = :Id_Var]; 
            
            billFromId = evnt.BillFromProject__c;
            billFromProject = evnt.BillFromProject__r.name;
            system.debug('**job Code**'+evnt.Job_Code__c);
            if( evnt.NS_Deferred_Revenue_Account__c==null || evnt.NS_Department__c==null || evnt.NS_Income_GL_Account__c==null || evnt.BillFromProject__c==null ){
                
                success_Var = 2;
                System.debug('___IN___EVENT____SUCCESS___VAR'+success_Var);
            }
             for(product_details__c proObject : evnt.Product_Details__r){
                if(proObject.Netsuite_Sync__c == true && (proObject.Subsidiary_ID__c == null || proObject.NS_Income_GL_Account__c== null || proObject.NS_Deferred_Revenue_Account__c == null || proObject.NS_Department__c == null || proObject.NS_Revenue_Schedule__c == null || proObject.Products__c == null  )){
                     success_Var = 4;
                }
            }
            
            if(evnt.Product_Details__r.size()>0 && success_Var ==0 ){      
                for(Product_Details__c pd : evnt.Product_Details__r){
                    prodToUpdate.add(new Product_Details__c(Id=pd.Id , NetSuite_Class__c=evnt.NetSuite_Class__c , NS_Deferred_Revenue_Account__c=evnt.NS_Deferred_Revenue_Account__c , NS_Department__c=evnt.NS_Department__c , NS_Income_GL_Account__c = evnt.NS_Income_GL_Account__c, Job_Code__c = evnt.Job_Code__c , NS_Revenue_Schedule__c = evnt.NS_Revenue_Schedule__c ));
                }
               /* for(Event__c eventObj: evnt){
                        eventObj.NetSuite_Sync__c =  true;
                        eventToupdate.add(eventObj);
                }*/
            }
           
        }
        
        else if(projectOrEvent=='project'){


            projct = [
                    Select Id, name, NetSuite_Class__c, Category__c, Project_Code__c, Subsidiary_ID__c, NS_Deferred_Revenue_Account__c,
                            NS_Department__c, NS_Income_GL_Account__c,LF_Membership_Required__c, Manual_Status_Check__c,Job_Code__c, (
                            Select Id, NetSuite_Class__c, NS_Deferred_Revenue_Account__c, NS_Department__c, NS_Income_GL_Account__c,
                                    NS_Revenue_Schedule__c /*, Netsuite_ID__c*/, Job_Code__c
                            from Product_Details__r
                    )
                    from Project__c
                    where Id = :Id_Var
            ];
            system.debug('**projct**'+projct);
            billFromId = projct.id;
            billFromProject = projct.name;
            if(projct.LF_Membership_Required__c && (  projct.NS_Deferred_Revenue_Account__c==null || projct.NS_Department__c==null || projct.NS_Income_GL_Account__c==null || projct.Project_Code__c==null || projct.Subsidiary_ID__c==null ) ){
                
                success_Var = 2;
                System.debug('___IN___PROJECT____SUCCESS___VAR'+success_Var);
                System.debug('______DIRECTEDFUND____'+success_Var);
            
            
            }
            
            else if(projct.Category__c=='Incorporated Entity' ){
                if  (projct.NS_Deferred_Revenue_Account__c==null || projct.NS_Department__c==null || projct.Subsidiary_ID__c==null || projct.Project_Code__c==null ){
            
                    success_Var = 3;
                    System.debug('______INCORPORATED____'+success_Var);
                    System.debug('_____SUCCESSVAR____'+success_Var);
                }
                
                else{
                    for(Product_Details__c pd : projct.Product_Details__r){
                        if(/*pd.NetSuite_ID__c==null || pd.NS_Income_GL_Account__c == null ||*/ pd.NS_Revenue_Schedule__c == null){
                            success_Var = 3;
                            break;
                            System.debug('_____SUCCESSVAR__IN_PRODUCTDETAILS____'+success_Var);
                            
                        }
                    }
                    
                }
            }
            
            if( projct.Product_Details__r.size()>0 && success_Var ==0 ){
                for(Product_Details__c pd : projct.Product_Details__r){
                    if (projct.LF_Membership_Required__c) {
                        prodToUpdate.add(new Product_Details__c(Id = pd.Id, NetSuite_Class__c = projct.NetSuite_Class__c,
                                NS_Deferred_Revenue_Account__c = projct.NS_Deferred_Revenue_Account__c,
                                NS_Department__c = projct.NS_Department__c, NS_Income_GL_Account__c = projct.NS_Income_GL_Account__c,
                                Project_Code__c = projct.Project_Code__c, Job_Code__c = projct.Job_Code__c));
                        system.debug('I am In ');
                    }
                    
                    else if(projct.Category__c=='Incorporated Entity'){
                        prodToUpdate.add(new Product_Details__c(Id = pd.Id, NS_Deferred_Revenue_Account__c = projct.NS_Deferred_Revenue_Account__c,
                                NS_Department__c = projct.NS_Department__c, Project_Code__c = projct.Project_Code__c, Job_Code__c = projct.Job_Code__c));
                        system.debug('I am In ');
                    }
                }
            }
        }
        
        System.debug('___PROJECT____'+projct);
        System.debug('_____EVENT____'+evnt);       
        set <string> proIdSet = new set <string>();
        if(prodToUpdate!=null && prodToUpdate.size()>0){ 
            success_Var = 1;
            try{
                update prodToUpdate;
            }
              catch(exception e ){
                system.debug('**Exc**'+ e);
                string error = e.getMessage();
                if(error.contains('can not be blank while syncing with NetSuite')){
                    success_Var = 4;
                
                }
            
            }
            //Moved the creation of the set from here to inside the if state below.
            /*for( product_details__c proObj:prodToUpdate){
                proIdSet.add(proObj.id);
            }*/
            if(projectOrEvent == 'project'){
                projToSync = [
                        select id, Category__c,LF_Membership_Required__c
                        from Project__c
                        WHERE Id = :Id_Var
                ];
                system.debug('--------------- > projToSync '+projToSync );
            }
            /*if((projectOrEvent == 'event' && !Test.isRunningTest() ) ||  ( projectOrEvent == 'project' && projToSync.LF_Membership_Required__c && !Test.isRunningTest()) ) {*/
            if (projectOrEvent == 'event' || (projectOrEvent == 'project' && projToSync.LF_Membership_Required__c)) {
                system.debug('**I am in**');
                system.debug('**projectOrEvent**' + projectOrEvent);
                system.debug('**projToSync.Category__c**' + projToSync.Category__c);
                for (Product_Details__c proObj : prodToUpdate) {
                    proIdSet.add(proObj.id);
                }
                if(!Test.isRunningTest()){
                    Database.executeBatch(new BatchForProjectEvent (proIdSet), 1);
                    
                }
            }     
            
            if(projectOrEvent == 'event'){
                Event__c e = new Event__c(Id = Id_var,Status__c = 'Active', Manual_Status_Check__c=false, NetSuite_Sync__c = true);
                update e;
                
                proDetailMap = new Map<Id,Product_Details__c>([Select Id, NetSuite_Class__c, NS_Deferred_Revenue_Account__c, NS_Department__c, NS_Income_GL_Account__c , NS_Revenue_Schedule__c , Netsuite_ID__c from Product_Details__c where Event__c = :Id_var and Id In :prodToUpdate ]);
                
                associatedOLIs = [Select Id, Product_Details__c , OpportunityId , Opportunity.isClosed from OpportunityLineItem where Product_Details__c In : prodToUpdate and Event__c = :Id_var and Opportunity.isClosed=false]; 
            }
        
            else if(projectOrEvent == 'project'){
                Project__c prj = new Project__c(Id = Id_var,Status__c = 'Active' , Manual_Status_Check__c=false,Net_Suite_Sync_Custom1__c =True);
                update prj;
                
                proDetailMap = new Map<Id,Product_Details__c>([Select Id, NetSuite_Class__c, NS_Deferred_Revenue_Account__c, NS_Department__c, NS_Income_GL_Account__c , NS_Revenue_Schedule__c , Netsuite_ID__c from Product_Details__c where Project__c = :Id_var and Id In :prodToUpdate ]);
                
                associatedOLIs = [Select Id, Product_Details__c , OpportunityId , Opportunity.isClosed from OpportunityLineItem where Product_Details__c In : prodToUpdate and Projects__c = :Id_var and Opportunity.isClosed=false];
            }
             
        }
        
        system.debug('____associatedOLIs____'+associatedOLIs);
        system.debug('____proDetailMap____'+proDetailMap);
         


        if(associatedOLIs!=null && associatedOLIs.size()>0){
            
            for(OpportunityLineitem ol : associatedOLIs){
                if(proDetailMap.containsKey(ol.Product_Details__c)){
                    
                    Product_Details__c pd = new Product_Details__c();
                    pd = proDetailMap.get(ol.Product_Details__c);
                    
                     Map<String,String> mapForRevAccount=new Map<String,String>();
                    Schema.DescribeFieldResult fieldResult = Product_Details__c.NS_Deferred_Revenue_Account__c.getDescribe();
                    List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
                    
                    for( Schema.PicklistEntry v : values) {
                      mapForRevAccount.put(v.getValue(), v.getLabel());
                    }
                    
                    Map<String,String> mapForIncomeGLAccount=new Map<String,String>();
                    Schema.DescribeFieldResult fieldResult1 = Product_Details__c.NS_Income_GL_Account__c.getDescribe();
                    List<Schema.PicklistEntry> values1 = fieldResult1.getPicklistValues();
                    
                    for( Schema.PicklistEntry v : values1) {
                      mapForIncomeGLAccount.put(v.getValue(), v.getLabel());
                    }
                    
                    Map<String,String> mapForRevSchedule=new Map<String,String>();
                    Schema.DescribeFieldResult fieldResult2 = Product_Details__c.NS_Revenue_Schedule__c.getDescribe();
                    List<Schema.PicklistEntry> values2 = fieldResult2.getPicklistValues();
                    
                    for( Schema.PicklistEntry v : values2) {
                      mapForRevSchedule.put(v.getValue(), v.getLabel());
                    }
                    
                    Map<String,String> mapForDepartment=new Map<String,String>();
                    Schema.DescribeFieldResult fieldResult3 = Product_Details__c.NS_Department__c.getDescribe();
                    List<Schema.PicklistEntry> values3 = fieldResult3.getPicklistValues();
                    
                    for( Schema.PicklistEntry v : values3) {
                      mapForDepartment.put(v.getValue(), v.getLabel());
                    }
                    
                    olisToUpdate.add(new OpportunityLineItem(Id=ol.Id , NetSuite_Class__c = pd.NetSuite_Class__c, NetSuite_Department__c = mapForDepartment.get(pd.NS_Department__c), NetSuite_ID__c = pd.Netsuite_ID__c, NetSuite_Income_GL_Account__c = mapForIncomeGLAccount.get(pd.NS_Income_GL_Account__c), NetSuite_Revenue_Schedule__c = mapForRevSchedule.get(pd.NS_Revenue_Schedule__c), NetSuite_Deferred_Revenue_Account__c = mapForRevAccount.get(pd.NS_Deferred_Revenue_Account__c),
                                                             Project_Event_Status__c='Active', Billfrom_ID__c = billFromId ,
                                                             Bill_From__c = billFromProject ));
                    
                }
            }
        }
        
        system.debug('___olisToUpdate____'+olisToUpdate);
        
        if(olisToUpdate!=null && olisToUpdate.size()>0){
            update olisToUpdate;
        }
        
              
        return success_Var;
    }
    
    
    
    
    /*public static Integer mappingMethod(Id recordId , String projectOrEvent , String prodId){
    
        Id Id_var = Id.valueOf(recordId);
        Integer success_Var = 0;
        Id DrcRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Directed Fund').getRecordTypeId();
        Id IncRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Incorporated').getRecordTypeId();
        List<Product_Details__c> prodToUpdate = new List<Product_Details__c>();
        Event__c evnt = new Event__c();
        Project__c projct = new Project__c();
        List<OpportunityLineItem> olisToUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> associatedOLIs = new List<OpportunityLineItem>();
        Map<Id,Product_Details__c> proDetailMap = new Map<Id,Product_details__c>();
        List <Event__c> eventToupdate = new list <Event__c> ();
        
        System.debug('_____PROJECTOREVENT___'+projectOrEvent);
        
        if(projectOrEvent=='event'){
        
            evnt = [Select Id, NetSuite_Sync__c,Job_Code__c, NetSuite_Class__c, NS_Revenue_Schedule__c, NS_Deferred_Revenue_Account__c, NS_Department__c, NS_Income_GL_Account__c, BillFromProject__c, Manual_Status_Check__c, (Select Id, Event__c, NetSuite_Class__c, NS_Deferred_Revenue_Account__c, NS_Department__c, NS_Income_GL_Account__c , NS_Revenue_Schedule__c , Netsuite_ID__c from Product_Details__r WHERE ID=:prodId) from Event__c where Id = :Id_Var]; 

            if( evnt.NS_Deferred_Revenue_Account__c==null || evnt.NS_Department__c==null || evnt.NS_Income_GL_Account__c==null || evnt.BillFromProject__c==null ){
                
                success_Var = 2;
                System.debug('___IN___EVENT____SUCCESS___VAR'+success_Var);
            }
            
            if(evnt.Product_Details__r.size()>0 && success_Var ==0 ){      
                for(Product_Details__c pd : evnt.Product_Details__r){
                    prodToUpdate.add(new Product_Details__c(Id=pd.Id , NetSuite_Class__c=evnt.NetSuite_Class__c , NS_Deferred_Revenue_Account__c=evnt.NS_Deferred_Revenue_Account__c , NS_Department__c=evnt.NS_Department__c , NS_Income_GL_Account__c = evnt.NS_Income_GL_Account__c, Job_Code__c = evnt.Job_Code__c, NetSuite_Sync__c = true , NS_Revenue_Schedule__c = evnt.NS_Revenue_Schedule__c ));
                }
                for(Event__c eventObj: evnt){
                        eventObj.NetSuite_Sync__c =  true;
                        eventToupdate.add(eventObj);
                }
            }
            
            
        }
        
        else if(projectOrEvent=='project'){
            
              
            projct = [Select Id, NetSuite_Class__c,RecordtypeId,RecordType.Name, Project_Code__c, Subsidiary_ID__c, NS_Deferred_Revenue_Account__c, NS_Department__c, NS_Income_GL_Account__c, Manual_Status_Check__c,Job_Code__c, (Select Id, NetSuite_Class__c, NS_Deferred_Revenue_Account__c, NS_Department__c, NS_Income_GL_Account__c , NS_Revenue_Schedule__c , Netsuite_ID__c, Job_Code__c from Product_Details__r) from Project__c where Id = :Id_Var];
            
            if(projct.RecordTypeId==DrcRecordTypeId && (  projct.NS_Deferred_Revenue_Account__c==null || projct.NS_Department__c==null || projct.NS_Income_GL_Account__c==null || projct.Project_Code__c==null || projct.Subsidiary_ID__c==null ) ){
                
                success_Var = 2;
                System.debug('___IN___PROJECT____SUCCESS___VAR'+success_Var);
                System.debug('______DIRECTEDFUND____'+success_Var);
            
            
            }
            
            else if(projct.RecordTypeId==IncRecordTypeId ){
                if  (projct.NS_Deferred_Revenue_Account__c==null || projct.NS_Department__c==null || projct.Subsidiary_ID__c==null || projct.Project_Code__c==null ){
            
                    success_Var = 3;
                    System.debug('______INCORPORATED____'+success_Var);
                    System.debug('_____SUCCESSVAR____'+success_Var);
                }
                
                else{
                    for(Product_Details__c pd : projct.Product_Details__r){
                        if(pd.NetSuite_ID__c==null ||pd.NS_Income_GL_Account__c == null || pd.NS_Revenue_Schedule__c == null){
                            success_Var = 3;
                            break;
                            System.debug('_____SUCCESSVAR__IN_PRODUCTDETAILS____'+success_Var);
                            
                        }
                    }
                    
                }
            }
            
            if( projct.Product_Details__r.size()>0 && success_Var ==0 ){
                for(Product_Details__c pd : projct.Product_Details__r){
                    if(projct.Recordtype.name=='Directed Fund'){
                        prodToUpdate.add(new Product_Details__c(Id=pd.Id , NetSuite_Class__c=projct.NetSuite_Class__c , NS_Deferred_Revenue_Account__c=projct.NS_Deferred_Revenue_Account__c , NS_Department__c=projct.NS_Department__c , NS_Income_GL_Account__c = projct.NS_Income_GL_Account__c,  Project_Code__c =  projct.Project_Code__c, Job_Code__c = projct.Job_Code__c, NetSuite_Sync__c = true ));
                    }
                    
                    else if(projct.Recordtype.name=='Incorporated'){
                        prodToUpdate.add(new Product_Details__c(Id=pd.Id, NS_Deferred_Revenue_Account__c=projct.NS_Deferred_Revenue_Account__c, NS_Department__c=projct.NS_Department__c, Project_Code__c = projct.Project_Code__c, Job_Code__c = projct.Job_Code__c, NetSuite_Sync__c = true));
                        
                    }
                }
            }
        }
        
        System.debug('___PROJECT____'+projct);
        System.debug('_____EVENT____'+evnt);       
        set <string> proIdSet = new set <string>();
        if(prodToUpdate!=null && prodToUpdate.size()>0){ 
            success_Var = 1;
            try{
                update prodToUpdate;
            }
            catch(exception e ){
                system.debug('**Exc**'+ e);
                string error = e.getMessage();
                if(error.contains('can not be blank while syncing with NetSuite')){
                    success_Var = 4;
                
                }
            
            }
            system.debug('**Product Detail**'+prodToUpdate);
            for( product_details__c proObj:prodToUpdate){
                proIdSet.add(proObj.id);
            }
            Database.executeBatch( new BatchForProjectEvent (proIdSet) , 1);  
            
            if(projectOrEvent == 'event'){
                Event__c e = new Event__c(Id = Id_var,Status__c = 'Active', Manual_Status_Check__c=false, NetSuite_Sync__c = true);
                update e;
                
                proDetailMap = new Map<Id,Product_Details__c>([Select Id, NetSuite_Class__c, NS_Deferred_Revenue_Account__c, NS_Department__c, NS_Income_GL_Account__c , NS_Revenue_Schedule__c , Netsuite_ID__c from Product_Details__c where Event__c = :Id_var and Id In :prodToUpdate ]);
                
                associatedOLIs = [Select Id, Product_Details__c , OpportunityId , Opportunity.isClosed from OpportunityLineItem where Product_Details__c In : prodToUpdate and Event__c = :Id_var and Opportunity.isClosed=false]; 
            }
        
            else if(projectOrEvent == 'project'){
                Project__c prj = new Project__c(Id = Id_var,Status__c = 'Active' , Manual_Status_Check__c=false);
                update prj;
                
                proDetailMap = new Map<Id,Product_Details__c>([Select Id, NetSuite_Class__c, NS_Deferred_Revenue_Account__c, NS_Department__c, NS_Income_GL_Account__c , NS_Revenue_Schedule__c , Netsuite_ID__c from Product_Details__c where Project__c = :Id_var and Id In :prodToUpdate ]);
                
                associatedOLIs = [Select Id, Product_Details__c , OpportunityId , Opportunity.isClosed from OpportunityLineItem where Product_Details__c In : prodToUpdate and Projects__c = :Id_var and Opportunity.isClosed=false];
            }
             
        }
        
        system.debug('____associatedOLIs____'+associatedOLIs);
        system.debug('____proDetailMap____'+proDetailMap);
        
        if(associatedOLIs!=null && associatedOLIs.size()>0){
            
            for(OpportunityLineitem ol : associatedOLIs){
                if(proDetailMap.containsKey(ol.Product_Details__c)){
                    
                    Product_Details__c pd = new Product_Details__c();
                    pd = proDetailMap.get(ol.Product_Details__c);
                    
                    olisToUpdate.add(new OpportunityLineItem(Id=ol.Id , NetSuite_Class__c = pd.NetSuite_Class__c, NetSuite_Department__c = pd.NS_Department__c, NetSuite_ID__c = pd.Netsuite_ID__c, NetSuite_Income_GL_Account__c = pd.NS_Income_GL_Account__c, NetSuite_Revenue_Schedule__c = pd.NS_Revenue_Schedule__c, NetSuite_Deferred_Revenue_Account__c = pd.NS_Deferred_Revenue_Account__c, Project_Event_Status__c='Active'));
                    
                }
            }
        }
        
        system.debug('___olisToUpdate____'+olisToUpdate);
        
        if(olisToUpdate!=null && olisToUpdate.size()>0){
            update olisToUpdate;
        }
        
              
        return success_Var;
    }*/
}