public class Project_Action{    
    
    public void validateNetSuiteFieldsBeforeApproval( Map<Id,Project__c> newMap ,Map<Id,Project__c> oldMap){
        
      /*  Id directedProjectId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Directed Fund').getRecordTypeId();
        Id incorporatedProjectId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Incorporated').getRecordTypeId();
        
        System.debug('___directedProjectId___'+directedProjectId+'____incorporatedProjectId____'+incorporatedProjectId);
        
        //Set<Id> filteredProjects = new Set<Id>();
        Map<Id,Project__c> filteredProjects = new Map<Id,Project__c>();
        List<product_details__c> associatedProductDetails = new List<product_details__c>();
        List<Project__c> incorporatedProjects = new List<Project__c>();
        
        for(Project__c p : newMap.values()){
            system.debug('____p__RecordTypeId__'+p.RecordTypeId);
            if( p.Status__c=='Active' && p.Status__c != oldMap.get(p.Id).Status__c){
                if(p.RecordTypeId==directedProjectId && ( p.NS_Deferred_Revenue_Account__c==null || p.NS_Department__c==null || p.NS_Income_GL_Account__c==null || p.Netsuite_Item__c==null || p.NS_Class__c==null ) ){
                    p.Status__c.addError('Can not approve unless Netsuite fields are populated');
                }
                else if(p.RecordTypeId==incorporatedProjectId){
                    incorporatedProjects.add(p);
                }
            }
        }
        
        system.debug('____incorporatedProjects____'+incorporatedProjects);
        
        if(incorporatedProjects!=null && incorporatedProjects.size()>0){
            associatedProductDetails.addAll([Select Id , Project__c ,  NS_Deferred_Revenue_Account__c , NS_Department__c , NS_Income_GL_Account__c , NS_Class__c , NetSuite_Revenue_Schedule__c , Netsuite_ID__c from Product_Details__c where Project__c In : incorporatedProjects]);
        }
        
        system.debug('____associatedProductDetails____'+associatedProductDetails);
        
        if(associatedProductDetails!=null && associatedProductDetails.size()>0){
            for(Product_Details__c pd : associatedProductDetails){
                if(!filteredProjects.containsKey(pd.Project__c) && ( pd.NS_Deferred_Revenue_Account__c==null || pd.NS_Department__c==null || pd.NS_Income_GL_Account__c==null || pd.NS_Class__c==null || pd.NetSuite_Revenue_Schedule__c==null || pd.Netsuite_ID__c==null) )
                    filteredProjects.put(pd.Project__c , newMap.get(pd.Project__c));
            }
        }
        
        system.debug('____filteredProjects____'+filteredProjects);
        
        if(filteredProjects!=null && filteredProjects.size()>0){
            for(Project__c proj : filteredProjects.values()){
                system.debug('___proj__'+proj);
                //Project__c proj = new Project__c(Id=pId);
                proj.Status__c.addError('Populate Netsuite fields on associated product details in order to approve this project');
            }
        }
        
        */
    }
    
    
    public void updateProductDetailsForApprovedProjects(Map<Id,Project__c> oldMap , Map<Id,Project__c> newMap){
        
      /*  system.debug('___called__updateProductDetailsForApprovedProjects_');
        
        List<Id> filteredProjectIds = new List<Id>();
        List<Product_Details__c> associatedProductDetails = new List<Product_Details__c>();
        List<Product_Details__c> updateProductDetails = new List<Product_Details__c>();
        
        Id directedProjectId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Directed Fund').getRecordTypeId();
        Id incorporatedProjectId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Incorporated').getRecordTypeId();
        
        system.debug('___directedProjectId___'+directedProjectId);
        
        for(Project__c p : newMap.values()){
            
            system.debug('___for_loop__1___'+p.Status__c+''+oldMap.get(p.Id).Status__c);
            //p.RecordTypeId== directedProjectId && 
            if(p.Status__c=='Active' && p.Status__c != oldMap.get(p.Id).Status__c){
                
                system.debug('__entered__first__if___');
                
                if(p.RecordTypeId==incorporatedProjectId || (p.RecordTypeId== directedProjectId && p.NS_Deferred_Revenue_Account__c!=null && p.NS_Department__c!=null && p.NS_Income_GL_Account__c!=null && p.Netsuite_Item__c!=null && p.NS_Class__c!=null ) ){
                    system.debug('___entered___second__if__');
                    filteredProjectIds.add(p.Id);
                }
            }
        }
        
        system.debug('___filteredProjectIds___'+filteredProjectIds);
        
        if(filteredProjectIds!=null && filteredProjectIds.size()>0)
            associatedProductDetails = new List<Product_Details__c>([Select Id , Project__c , Project__r.RecordTypeId from product_details__c where Project__c In : filteredProjectIds]);
        
        system.debug('__associatedProductDetails___'+associatedProductDetails);
            
        if(associatedProductDetails!=null && associatedProductDetails.size()>0){
            
            for(Product_Details__c pd : associatedProductDetails){
                
                if(newMap.containsKey(pd.Project__c)){
                    
                    Product_Details__c prod = new Product_Details__c();
                    prod.Id = pd.Id;
                    prod.Status__c = newMap.get(pd.Project__c).Status__c; 
                    if(prod.Project__r.RecordTypeId==directedProjectId){
                        prod.NS_Class__c = newMap.get(pd.Project__c).NS_Class__c;
                        prod.NS_Department__c = newMap.get(pd.Project__c).NS_Department__c ;
                        prod.NS_Deferred_Revenue_Account__c = newMap.get(pd.Project__c).NS_Deferred_Revenue_Account__c ;
                        prod.NS_Income_GL_Account__c = newMap.get(pd.Project__c).NS_Income_GL_Account__c ;                    
                    }
                    
                    updateProductDetails.add(prod);
                }
            }
        }
        
        system.debug('___updateProductDetails___'+updateProductDetails);
        
        if(updateProductDetails!=null && updateProductDetails.size()>0)
            update updateProductDetails;
        
        */
    }
    
    //This will update ed user and program manger field depending on contact value populated
    public void updateEDAndProgramManagerUser(List<Project__c> projects){
        Set<Id> contactIds = new Set<Id>();
        Map<String,Id> contactIdByEmail = new Map<String,Id>();
        Map<Id,Id> contactIdByUserId = new Map<Id,Id>(); //stores the contact id against the user ID
        for(Project__c project : projects){
            if(project.Program_Manager__c != null){
                contactIds.add(project.Program_Manager__c );
            }
            if(project.Executive_Director__c != null){
                 contactIds.add(project.Executive_Director__c );
            }
            if(project.Business_Development_Manager__c != null){
                contactIds.add(project.Business_Development_Manager__c);
            }
        }
        
        if(!contactIds.isEmpty()){
            for(Contact contact : [SELECT Id,Email FROM Contact Where ID IN:contactIds]){
                contactIdByEmail.put(contact.Email,contact.Id);
            }
            
            //get the users basis the contacts
            for(User user : [SELECT ID,Email FROM User WHERE Email IN: contactIdByEmail.keySet()]){
                if(contactIdByEmail.containsKey(user.Email)){
                    contactIdByUserId.put(contactIdByEmail.get(user.Email),user.Id);
                }
            }
        }
        
        //update the values
        for(Project__c project : projects){
            //map the fields
            String pmValue =  contactIdByUserId.containsKey(project.Program_Manager__c) ? contactIdByUserId.get(project.Program_Manager__c) : null;
            String edValue = contactIdByUserId.containsKey(project.Executive_Director__c) ? contactIdByUserId.get(project.Executive_Director__c) : null;
            String bdmValue = contactIdByUserId.containsKey(project.Business_Development_Manager__c) ? contactIdByUserId.get(project.Business_Development_Manager__c) : null;
           if(pmValue != project.Program_Manager_U__c){
                project.Program_Manager_U__c = pmValue;
            }
            if(edValue != project.Executive_Director_U__c){
                project.Executive_Director_U__c = edValue;
            }
            if(bdmValue != project.Business_Development_Manager_U__c){
                project.Business_Development_Manager_U__c = bdmValue;
            }
        }
    }
    
    
}