/*
    Name : AssetToSalesOrderHelper
    Description : This is helper class to create JSON for different record type
    Author  = Piyush Kalra(piyush@wiserspread.com)
    Date - 30th Oct
*/  

public with sharing class AssetToSalesOrderHelper {
    
    public static list <OpportunityLineItem> oppList = new list <OpportunityLineItem>();
    
    
    public static string createJSONFromMemeberShipAsset(Set<String> assetId , String opportunityId , map<id , Opportunity>  triggerNewMap){
        
            system.debug('I am in this');
            //map<String , DepartmentForAssetMapping__c> departmentAssetMapping = DepartmentForAssetMapping__c.getAll();
            //map<String, String > departmentAssetMapping = new map <String, String>();
            /*List < Department_Mapping__c > depMap = new list<Department_Mapping__c>();
            depMap = [select name , Netsuite_ID__c from Department_Mapping__c];
            for(Department_Mapping__c depMapping : depMap){
               departmentAssetMapping.put(depMapping.name, String.ValueOF(depMapping.Netsuite_ID__c));
            }*/
            //map<String , PaymentTermsMappingForAsset__c> paymentTermAssetMapping = PaymentTermsMappingForAsset__c.getAll();
            //map<String, Assets_Mapping__c> assetMapping = Assets_Mapping__c.getAll();
            map<String , String> paymentTermAssetMapping =  new map<String , String>() ;
            
            List < Payment_Terms_Mapping__c  > termsMap = new List < Payment_Terms_Mapping__c  >();
            termsMap = [select name , Netsuite_ID__c from Payment_Terms_Mapping__c];
            for(Payment_Terms_Mapping__c payTerms : termsMap){
                paymentTermAssetMapping.put(payTerms.name , string.ValueOf(payTerms.Netsuite_ID__c));    
            
            }
             oppList = [SELECT id  ,opportunity.account.BillingCountry,opportunity.recordtype.name, opportunity.Bill_To_Account__r.name , opportunity.Bill_To_Account__c ,  
                    opportunity.account.name,opportunity.Bill_To_Account__r.BillingState, opportunity.Bill_To_Account__r.BillingStreet,opportunity.Bill_To_Account__r.BillingCity,opportunity.Bill_To_Account__r.BillingPostalCode,opportunity.Bill_To_Account__r.BillingCountry, opportunity.account.BillingState , 
                    opportunity.account.BillingStreet, opportunity.account.BillingCity, opportunity.account.BillingPostalCode, Product_Details__r.training__c,
                    Product_Details__c , Product_Details__r.event__r.BillFromProject__r.Subsidiary_ID__c , Product_Details__r.event__r.BillFromProject__r.project_code__c ,
                    Product_Details__r.project__r.Subsidiary_ID__c  , Product_Details__r.project__r.project_code__c ,
						Billing_Contact__r.email  ,PO_Number__c, Billing_Contact2__r.email ,Billing_Contact3__r.email , description__C,Product_Details__r.NS_Department__c,Product_Details__r.Netsuite_ID__c, Product_Details__r.Subsidiary_ID__c,NetSuite_Class__c
                    from OpportunityLineItem  
                    where opportunityid =:opportunityid AND Skip_NetSuite_Sync__c = FALSE];
        Map<Id,OpportunityLineItem> oppLineItemIdVsOpportunityLineItem = new Map<Id,OpportunityLineItem>(oppList);
            
					
            AssetMemberWrapper accWrapper = new AssetMemberWrapper();
            List<Asset> assetList = new list<asset>();    
            assetList = [SELECT id , Projects__r.Project_Code__c ,opportunity__r.PAL_INVOICE__c, memo__c ,name ,Projects__c, NetSuite_Department__c , NS_Entity_ID__c , AccountId ,Bill_To_Account__c,
                                     PaymentTerms__c,PO_Number__c ,Bill_From_ID__r.Project_Code__c, Bill_To_Account__r.Name,opportunity__r.Corporate_Training_Bundle__c,
                                     quantity , price , installdate , usageenddate ,OpportunityLineItem__c,Bill_To_Account__r.billingstate,Bill_To_Account__r.billingcity,Bill_To_Account__r.billingcountry,Bill_To_Account__r.billingpostalcode,Bill_To_Account__r.billingstreet,
                                     netsuite_class__c , opportunity__c, opportunity__r.Opportunity_Link__c,Account.name,Account.billingstate,Account.billingcity,Account.billingcountry,Account.billingpostalcode,Account.billingstreet , NetSuite_Location__c,
                         			 Bill_To_Address__c,Bill_To_Address__r.Name,Bill_To_Address__r.Street__c,Bill_To_Address__r.City__c,Bill_To_Address__r.State__c,Bill_To_Address__r.Zip_Postal_Code__c,Bill_To_Address__r.Country__c,
                         (SELECT Id,Contact__c,Contact__r.Email,PrimaryContact__c from Project_Roles__r 
                          WHERE Role__c='Billing Contact' AND Status__c='Active' ORDER BY createddate ASC) 
                         FROM Asset WHERE ID IN :assetId AND Skip_NetSuite_Sync__c = FALSE];
           List<Object> mainJsonArray = new List<Object>();
             
            /*List<OpportunityLineItem> oppitemList = new List<OpportunityLineItem>();
            oppItemList = [SELECT id , name , Billing_Contact__r.email  ,PO_Number__c, Billing_Contact2__r.email ,Billing_Contact3__r.email , description__C,Product_Details__r.NS_Department__c,Product_Details__r.Netsuite_ID__c, Product_Details__r.Subsidiary_ID__c,NetSuite_Class__c FROM OpportunityLineItem WHERE opportunityid=:opportunityId AND Skip_NetSuite_Sync__c = FALSE];
            for(OpportunityLineItem oli : oppItemList){
                oppLineItemIdVsOpportunityLineItem.put(oli.id , oli);
            }*/
            for(Asset assetObject : assetList){
                map<String , Object> jsonMappingObject = new map<String , Object>();
                string netsuiteId = '';
                system.debug('**assetObject**'+assetObject);
                if(assetObject.opportunity__r.Opportunity_Link__c != null){
                    jsonMappingObject.put('custbody_sugar_reference' ,  assetObject.opportunity__r.Opportunity_Link__c);
                }
                
                if( assetObject.opportunity__r.PAL_INVOICE__c == True){
                        jsonMappingObject.put('custbody_pal_invoice', 'T');
                        jsonMappingObject.put('custbody_additional_email_3',Label.Additional_email_address3);
                }
                else if(assetObject.opportunity__r.PAL_INVOICE__c == False){
                        jsonMappingObject.put('custbody_pal_invoice', 'F');
                
                }
                System.debug('Corp Training bundle==>'+assetObject.opportunity__r.Corporate_Training_Bundle__c );
                if(assetObject.opportunity__r.Corporate_Training_Bundle__c)
                {
                    jsonMappingObject.put('custbody_corp_training_bundle_', 'T');
                    
                }else{
                    jsonMappingObject.put('custbody_corp_training_bundle_', 'F');
                }
                /* if(assetObject.Bill_To_Account__c != null){
                            system.debug('---assetObject.Bill_To_Account__c--'+assetObject.Bill_To_Account__c);
                            system.debug('----assetObject.Projects__r.Project_Code__c--'+assetObject.Projects__r.Project_Code__c);
                        list <Account_And_Project__c> accProList = new list <Account_And_Project__c>(); 
                        //accProList = [select id, Account__c, Project__c, Subsidiary_ID__c , Netssuite_ID__c from Account_And_Project__c where Account__c =: assetObject.Bill_To_Account__c AND Project__c =:assetObject.Projects__c];
                        accProList = [select id, Account__c, Project__c, Subsidiary_ID__c , Netssuite_ID__c from Account_And_Project__c where Account__c =: assetObject.Bill_To_Account__c AND Project__r.Project_Code__c =:assetObject.Projects__r.Project_Code__c];
                        if(accProList != null && !accProList.isEmpty()){
                            jsonMappingObject.put('entity' ,  accProList[0].Netssuite_ID__c);
                        
                        }else{
                            String netsuiteBody = creatingMember(assetObject.Bill_To_Account__c , triggerNewMap , opportunityid , true , true);
                            accWrapper.accId = assetObject.Bill_To_Account__c;
                            accWrapper.accJson = netsuiteBody;
                        }
                          
                        
                        
                        
                        
                
                     
                }
                
                else*/ if(assetObject.AccountId != null ){
                        list <Account_And_Project__c> accProList = new list <Account_And_Project__c>(); 
                        system.debug('---assetObject.AccountId--'+assetObject.AccountId);
                        system.debug('--assetObject.Projects__r.Project_Code__c--'+assetObject.Projects__r.Project_Code__c);
                        //accProList = [select id, Account__c, Project__c, Subsidiary_ID__c , Netssuite_ID__c from Account_And_Project__c where Account__c =: assetObject.AccountId AND Project__c =:assetObject.Projects__c];
                        accProList = [select id, Account__c, Project__c, Subsidiary_ID__c , Netssuite_ID__c from Account_And_Project__c where Account__c =: assetObject.accountID AND Project__r.Project_Code__c =:assetObject.Projects__r.Project_Code__c];
                    OpportunityLineItem opportunitylineitem = oppLineItemIdVsOpportunityLineItem.get(assetObject.OpportunityLineItem__c);   
                    if(accProList != null && !accProList.isEmpty()){
                            jsonMappingObject.put('entity' ,  accProList[0].Netssuite_ID__c);
                            String netsuiteBody = creatingMember(assetObject.AccountId , triggerNewMap , opportunityid , true , false ,accProList[0].Netssuite_ID__c,opportunitylineitem);
                             accWrapper.accId = assetObject.AccountId;
                             accWrapper.accJson = netsuiteBody;
                        }else{
                             String netsuiteBody = creatingMember(assetObject.AccountId , triggerNewMap , opportunityid , true , false , null,opportunitylineitem); 
                             accWrapper.accId = assetObject.AccountId;
                             accWrapper.accJson = netsuiteBody;
                        }
                        
                           
                        
                }
               
                
                jsonMappingObject.put('Project_Code__c' , assetObject.Bill_From_ID__r.Project_Code__c);
                if(assetObject.memo__c != null){
                    if(assetObject.memo__c.length() < 999){
                        jsonMappingObject.put('memo' , assetObject.memo__c);
                    }else{
                        triggerNewMap.get(opportunityid).addError('This <a href="/"'+assetObject.id+'"> assetObject.id </a> memo cant be more than 999 chars ');
                    }
                }
                //jsonMappingObject.put('class' , assetObject.NetSuite_Class__c);
                jsonMappingObject.put('location' , assetObject.NetSuite_Location__c);
                  
       
        		String billToAddress = getBillingAddress(assetObject);
        
                /*if(departmentAssetMapping != null && departmentAssetMapping.containsKey(assetObject.NetSuite_Department__c)){
                    jsonMappingObject.put('department' , departmentAssetMapping.get(assetObject.NetSuite_Department__c));
                }*/
               // OpportunityLineItem oli = oppLineItemIdVsOpportunityLineItem.get(assetObject.OpportunityLineItem__c);
               
                if(netsuiteId != ''){
                      //  jsonMappingObject.put('entity' ,  netsuiteId);
                }
                if(paymentTermAssetMapping != null && paymentTermAssetMapping.containsKey(assetObject.PaymentTerms__c)){
                    jsonMappingObject.put('terms' , paymentTermAssetMapping.get(assetObject.PaymentTerms__c));
                }
                
                
                
                jsonMappingObject.put('recordtype' , 'salesorder');
                system.debug('**billToAddress'+billToAddress);
                 if(billToAddress != ''){
                        jsonMappingObject.put('billaddress' , billToAddress);
                }else{
                        triggerNewMap.get(opportunityid).addError('Account Billing Address incomplete' , false);
                }
                map<String , Object> salesLineItemMapping = new Map<String , Object>();
                List<Object> itemList = new List<Object>();
                map<String , Object> salesLineItem = new map<String , Object>();
                OpportunityLineItem oli = oppLineItemIdVsOpportunityLineItem.get(assetObject.OpportunityLineItem__c);
                system.debug(oli.Product_Details__r);
                if(oli.Product_Details__c != null && oli.Product_Details__r.Netsuite_ID__c != null){
                    salesLineItem.put('item' , oli.Product_Details__r.Netsuite_ID__c);
                }else{
                        system.debug('**ProDetail**'+oli.Product_Details__c);
                        // mpoer to remove conditions on this ASAP 2018-07-03
                        // if(Test.IsRunningTest()){
                            triggerNewMap.get(opportunityid).addError('This <a href="/'+oli.Product_Details__c+'">Product Detail netsuiteId </a> cant be blank ' , false);                          
                        // }
                    return null;
                }
                if(oli.Product_Details__r.NS_Department__c != null ){
                   jsonMappingObject.put('department' ,oli.Product_Details__r.NS_Department__c);        
               
                }
                salesLineItem.put('price' , 1);
                system.debug(oli.Product_Details__r.Subsidiary_ID__c);
                if(oli.Product_Details__c != null && oli.Product_Details__r.Subsidiary_ID__c != null){
                    jsonMappingObject.put('subsidiary' ,oli.Product_Details__r.Subsidiary_ID__c);
                }else{
                    triggerNewMap.get(opportunityid).addError('This <a href="/'+oli.Product_Details__c+'">Product Detail </a> subsidiary cant be blank ' , false);
                
                }    
                //Retrieving Billing Contacts from membership roles
                if(!assetObject.Project_Roles__r.isEmpty()){
                    for(Project_Role__c pRole : assetObject.Project_Roles__r){
                        if(pRole.PrimaryContact__c && !jsonMappingObject.containsKey('custbody_primary_email')){
                            jsonMappingObject.put('custbody_primary_email' , pRole.contact__r.email);
                        }else if(!pRole.PrimaryContact__c){
                            if(!jsonMappingObject.containsKey('custbody_additional_email_1')){
                                jsonMappingObject.put('custbody_additional_email_1' , pRole.contact__r.email);
                            }else if(!jsonMappingObject.containsKey('custbody_additional_email_2')){
                                jsonMappingObject.put('custbody_additional_email_2' , pRole.contact__r.email);
                            }
                        }
                    }
                }
               /*if(oli.billing_contact__c != null){
                    jsonMappingObject.put('custbody_primary_email' , oli.billing_contact__r.email);
                }
                if(oli.billing_contact2__c != null){
                    jsonMappingObject.put('custbody_additional_email_1' , oli.billing_contact2__r.email);
                }
                if(oli.billing_contact3__c != null){
                    jsonMappingObject.put('custbody_additional_email_2' , oli.billing_contact3__r.email);
                }
*/

                if(oli.Po_number__c != null && oli.po_number__c != ''){
                    jsonMappingObject.put('otherrefnum' , oli.PO_Number__c);
                }/*else{
                    triggerNewMap.get(opportunityid).addError('This <a href="/'+oli.id+'">Opportunity Line Item</a> PO Number  cant be blank ' , false);
                }*/
                
                
                salesLineItem.put('quantity' , 1);
                if(oli.description__c != null){ 
                
                    if(oli.description__c.length() < 4000)
                        salesLineItem.put('description' , oli.description__c);
                    else{
                         triggerNewMap.get(opportunityid).addError('This <a href="/"'+oli.id+'"> oli.id </a> description cant be more than 4000 chars ' , false);
                    }
                }
                
                salesLineItem.put('amount' , assetObject.price);
                
                if(assetObject.installdate != null){
                    String startDate = assetObject.installdate.month() + '/' + assetObject.installdate.day() + '/' + assetObject.installdate.year(); 
                    salesLineItem.put('revrecstartdate' , startDate);
                }else{
                    
                    triggerNewMap.get(opportunityId).addError('<a href="/'+oli.id + '"'+'>Start Date</a> cant be null' , false);
                
                }
                if(assetObject.usageenddate != null){
                    String endDate = assetObject.usageenddate.month() + '/' + assetObject.usageenddate.day() + '/' + assetObject.usageenddate.year(); 
                    salesLineItem.put('revrecenddate' , endDate);
                }else{
                   
                    triggerNewMap.get(opportunityId).addError('<a href="/'+oli.id + '"'+'>End Date</a> cant be null' , false);
                }
                system.debug(salesLineItem);
                itemList.add(salesLineItem);
                jsonMappingObject.put('items' ,  itemList);
                mainJsonArray.add(jsonMappingObject);   
            }
            accWrapper.jsonBody = JSON.serialize(mainJsonArray);
            system.debug(JSON.serialize(accWrapper));
            return JSON.serialize(accWrapper);   
                
        }
            
            
    
    public static String createJSONFromOtherThanMemeberShipAsset(String assetId , String opportunityId , map<id , Opportunity>  triggerNewMap){
       
        system.debug('**assetId'+ assetId);
        if(assetId != null && !String.isBlank(assetId)){    
            //map<String , DepartmentForAssetMapping__c> departmentAssetMapping = DepartmentForAssetMapping__c.getAll();
            
            /*map<String, String > departmentAssetMapping = new map <String, String>();
            List < Department_Mapping__c > depMap = [select name , Netsuite_ID__c from Department_Mapping__c];
            for(Department_Mapping__c depMapping : depMap){
               departmentAssetMapping.put(depMapping.name, String.ValueOF(depMapping.Netsuite_ID__c));
            }*/
            //map<String , PaymentTermsMappingForAsset__c> paymentTermAssetMapping = PaymentTermsMappingForAsset__c.getAll();
            //map<String, Assets_Mapping__c> assetMapping = Assets_Mapping__c.getAll();
            map<String , String> paymentTermAssetMapping =  new map<String , String>() ;
            
            List < Payment_Terms_Mapping__c  > termsMap = [select name , Netsuite_ID__c from Payment_Terms_Mapping__c];
            for(Payment_Terms_Mapping__c payTerms : termsMap){
                paymentTermAssetMapping.put(payTerms.name , string.ValueOf(payTerms.Netsuite_ID__c));    
            
            }
            
            Asset assetObject =[SELECT id , Projects__r.Project_Code__c,memo__c ,opportunity__r.PAL_INVOICE__c,name ,Projects__c, NetSuite_Department__c,AccountId ,Bill_To_Account__c,event__r.BillFromProject__c, NS_Entity_ID__c , 
                                     PaymentTerms__c,PO_Number__c ,Bill_From_ID__r.Project_Code__c, Bill_To_Account__r.Name,Bill_To_Account__r.billingstate,Bill_To_Account__r.billingcity,Bill_To_Account__r.billingcountry,Bill_To_Account__r.billingpostalcode,Bill_To_Account__r.billingstreet,
                                     quantity , price , installdate , usageenddate ,OpportunityLineItem__c,Event__r.BillFromProject__r.Project_Code__c,opportunity__r.Corporate_Training_Bundle__c,
                                     netsuite_class__c , opportunity__c ,opportunity__r.Opportunity_Link__c,NetSuite_Location__c,Account.name,Account.billingstate,Account.billingcity,Account.billingcountry,Account.billingpostalcode,Account.billingstreet,
                                	 Bill_To_Address__c,Bill_To_Address__r.Name,Bill_To_Address__r.Street__c,Bill_To_Address__r.City__c,Bill_To_Address__r.State__c,
                                	 Bill_To_Address__r.Zip_Postal_Code__c,Bill_To_Address__r.Country__c,Training__c FROM Asset WHERE ID = :assetId];
            //list <Asset> assetList = [SELECT id, price,quantity from asset where opportunity__c =: opportunityId]; 
           
            
            oppList = [SELECT id ,opportunity.account.BillingCountry,opportunity.recordtype.name, opportunity.Bill_To_Account__r.name , opportunity.Bill_To_Account__c ,  
                        opportunity.account.name,opportunity.Bill_To_Account__r.BillingState, opportunity.Bill_To_Account__r.BillingStreet,opportunity.Bill_To_Account__r.BillingCity,opportunity.Bill_To_Account__r.BillingPostalCode,opportunity.Bill_To_Account__r.BillingCountry, opportunity.account.BillingState , 
                        opportunity.account.BillingStreet, opportunity.account.BillingCity, opportunity.account.BillingPostalCode, Product_Details__r.training__c,
                        Product_Details__c , Product_Details__r.event__r.BillFromProject__r.Subsidiary_ID__c , Product_Details__r.event__r.BillFromProject__r.project_code__c ,
                        Product_Details__r.project__r.Subsidiary_ID__c  , Product_Details__r.project__r.project_code__c 
                        from OpportunityLineItem  
                        where opportunityid =:opportunityid AND Skip_NetSuite_Sync__c = FALSE];   
  
        map<Id , OpportunityLineItem> oppLineItemIdVsOpportunityLineItem = new map<Id , OpportunityLineItem>(oppList);
       		String billToAddress = getBillingAddress(assetObject);
            
            map<String , Object> jsonMappingObject = new map<String , Object>();
            string accountType = '';
            string netsuiteId = '';
          /*  if(assetObject.Bill_To_Account__c != null && assetObject.Bill_To_Account__r.Netsuite_ID__c != null){
                    netsuiteId = assetObject.Bill_To_Account__r.Netsuite_ID__c;
            }else if(assetObject.Bill_To_Account__c != null && assetObject.Bill_To_Account__r.Netsuite_ID__c == null){
                    accountType = 'Bill To';
                    jsonMappingObject.put('syncBillAccount' , assetObject.Bill_To_Account__c);
                     jsonMappingObject.put('accId' , assetObject.Bill_To_Account__c);
                    netsuiteId = creatingMember(assetObject.Bill_To_Account__c , triggernewmap , opportunitYid , );
            }else if(assetObject.AccountId != null && assetObject.Account.Netsuite_ID__c != null){
                    netsuiteId = assetObject.Account.Netsuite_ID__c;
            }else if(assetObject.AccountId != null && assetObject.Account.Netsuite_ID__c == null){
                    accountType = 'Account';
                    String netsuiteBody = creatingMember(assetObject.AccountId , triggernewmap , opportunityId);
                    jsonMappingObject.put('syncAccount' , netsuiteBody);
                    jsonMappingObject.put('accId' , assetObject.AccountId);
            }*/
            
            /*if(assetObject.Bill_To_Account__c != null){
                            system.debug('---assetObject.Bill_To_Account__c--'+assetObject.Bill_To_Account__c);
                            system.debug('----assetObject.Projects__r.Project_Code__c--'+assetObject.Projects__r.Project_Code__c);
                        list <Account_And_Project__c> accProList = new list <Account_And_Project__c>(); 
                        //accProList = [select id, Account__c, Project__c, Subsidiary_ID__c , Netssuite_ID__c from Account_And_Project__c where Account__c =: assetObject.Bill_To_Account__c AND Project__c =:assetObject.event__r.BillFromProject__c];
                        accProList = [select id, Account__c, Project__c, Subsidiary_ID__c , Netssuite_ID__c from Account_And_Project__c where Account__c =: assetObject.Bill_To_Account__c AND Project__r.Project_Code__c =:assetObject.Event__r.BillFromProject__r.Project_Code__c];
                        if(accProList != null && !accProList.isEmpty()){
                            jsonMappingObject.put('entity' ,  accProList[0].Netssuite_ID__c);
                        
                        }else{
                            String netsuiteBody = creatingMember(assetObject.Bill_To_Account__c , triggerNewMap , opportunityid , false , true);
                            jsonMappingObject.put('syncAccount' , netsuiteBody);
                            jsonMappingObject.put('accId' , assetObject.Bill_To_Account__c);
                        }
                          
                        
                        
                        
                        
                
                     
             }
            else*/ if(assetObject.AccountId != null ){
                        list <Account_And_Project__c> accProList = new list <Account_And_Project__c>(); 
                        system.debug('---assetObject.AccountId--'+assetObject.AccountId);
                        system.debug('--assetObject.Projects__r.Project_Code__c--'+assetObject.Projects__r.Project_Code__c);                		
                        //accProList = [select id, Account__c, Project__c, Subsidiary_ID__c , Netssuite_ID__c from Account_And_Project__c where Account__c =: assetObject.AccountId AND Project__c =:assetObject.event__r.BillFromProject__c];
                String projectCode = assetObject.Training__c != null ? 'LF' : assetObject.Event__r.BillFromProject__r.Project_Code__c;        
                accProList = [select id, Account__c, Project__c, Subsidiary_ID__c , Netssuite_ID__c from Account_And_Project__c where Account__c =: assetObject.AccountId AND 
                              Project__r.Project_Code__c =:projectCode];
                        system.debug(accProList);
                 OpportunityLineItem opportunitylineitem = oppLineItemIdVsOpportunityLineItem.get(assetObject.OpportunityLineItem__c);   
                   
                        if(accProList != null && !accProList.isEmpty()){
                            jsonMappingObject.put('entity' ,  accProList[0].Netssuite_ID__c);
                            
                            String netsuiteBody = creatingMember(assetObject.AccountId , triggerNewMap , opportunityid , false , false , accProList[0].Netssuite_ID__c,opportunitylineitem);
                             jsonMappingObject.put('syncAccount' , netsuiteBody);
                             jsonMappingObject.put('accId' , assetObject.AccountId);
                        }else{
                             String netsuiteBody = creatingMember(assetObject.AccountId , triggerNewMap , opportunityid , false , false , null,opportunitylineitem);
                             jsonMappingObject.put('syncAccount' , netsuiteBody);
                             jsonMappingObject.put('accId' , assetObject.AccountId);
                        }
                        
                           
                        
                }
            
            system.debug('**netsuiteId--'+netsuiteId);
            /*if(netsuiteId == ''){
                    if(accountType == 'Bill To'){
                        Account billAccount = [Select Netsuite_ID__c from Account where Id =: assetObject.Bill_To_Account__c];
                        netsuiteId = billAccount.Netsuite_ID__c;
                    }else if(accountType == 'Account'){
                        Account account = [Select Netsuite_ID__c from Account where Id =: assetObject.AccountId];
                        netsuiteId = account.Netsuite_ID__c;
                    }
            }*/
            jsonMappingObject.put('Project_Code__c' , assetObject.Bill_From_ID__r.Project_Code__c);
            if(assetObject.opportunity__r.Corporate_Training_Bundle__c)
            {
                jsonMappingObject.put('custbody_corp_training_bundle_', 'T');
                
            }else{
                jsonMappingObject.put('custbody_corp_training_bundle_', 'F');
            }
            //jsonMappingObject.put('memo' , assetObject.memo__c);
            //jsonMappingObject.put('class' , assetObject.NetSuite_Class__c);
            jsonMappingObject.put('location' , assetObject.NetSuite_Location__c);
            //jsonMappingObject.put('billingaddress_text' ,assetObject.Account.billingcity );
            system.debug('**billToAddress'+billToAddress);
             if(billToAddress != ''){
                        jsonMappingObject.put('billaddress' , billToAddress);
            }else{
                    triggerNewMap.get(opportunityid).addError('Account Billing Address incomplete' , false);
            }
            /*if(departmentAssetMapping != null && departmentAssetMapping.containsKey(assetObject.NetSuite_Department__c)){
                jsonMappingObject.put('department' , departmentAssetMapping.get(assetObject.NetSuite_Department__c));
            }*/
           
            //jsonMappingObject.put('entity' ,  assetObject.NS_Entity_ID__c);
            if(paymentTermAssetMapping != null && paymentTermAssetMapping.containsKey(assetObject.PaymentTerms__c)){
                jsonMappingObject.put('terms' , paymentTermAssetMapping.get(assetObject.PaymentTerms__c));
            }
            system.debug('**1*'+jsonMappingObject);
            jsonMappingObject.put('recordtype' , 'salesorder');
            List<Object> itemList = new List<Object>();
            map<String , Object> salesLineItemMapping = new Map<String , Object>();
            List<OpportunityLineItem> oppitemList = new List<OpportunityLineItem>();
            oppItemList = [SELECT quantity,Start_Date__c,End_Date__c, id ,Opportunity.RecordType.name,Training__r.StartDateTime__c,Training__r.End_DateTime__c,Product_Details__r.Subsidiary_ID__c, 
                           name , NetSuite_Invoice_Memo__c,TotalPrice,event__r.End_Date__c ,Product_Details__r.NS_Department__c, event__r.Start_Date__c, description__C,PO_Number__c,
                           Product_Details__r.Netsuite_ID__c , billing_contact3__r.email , billing_contact2__r.email , billing_contact__r.email  
                           FROM OpportunityLineItem WHERE opportunityid=:assetObject.Opportunity__c AND Skip_NetSuite_Sync__c = FALSE];
            list <OpportunityLineItem> oppItemListToCheckMemo = new list<OpportunityLineItem>();
            oppItemListToCheckMemo = [Select NetSuite_Invoice_Memo__c From OpportunityLineItem WHERE opportunityid=:assetObject.Opportunity__c And NetSuite_Invoice_Memo__c!= null order by createddate desc limit 1];
            
            if(oppItemListToCheckMemo.size() != 0){
                    jsonMappingObject.put('memo' , oppItemListToCheckMemo[0].NetSuite_Invoice_Memo__c);
            }
                 
            
            for(OpportunityLineItem oli : oppItemList){
                system.debug(oli);
               
                if(oli.Product_Details__r.NS_Department__c != null ){
                        jsonMappingObject.put('department' ,oli.Product_Details__r.NS_Department__c);        
             
                } 
                map<String , Object> salesLineItem = new map<String , Object>();
                if(oli.Product_Details__c != null && oli.Product_Details__r.Netsuite_ID__c != null){
                    salesLineItem.put('item' , oli.Product_Details__r.Netsuite_ID__c);
                    system.debug('**Product_Details__r.Netsuite_ID__c**'+oli.Product_Details__r.Netsuite_ID__c);
                }else{
                    // mpoer to remove conditions on this ASAP 2018-07-03
                    // if(Test.IsRunningTest()){
                        triggerNewMap.get(opportunityid).addError('This <a href="/'+oli.Product_Details__c+'">Product Detail netsuiteId </a> cant be blank ' , false);                          
                    // }
                }
                //salesLineItem.put('item' , '199');
                salesLineItem.put('price' , 1);
                if(oli.billing_contact__c != null && !jsonMappingObject.containsKey('custbody_primary_email')){
                    jsonMappingObject.put('custbody_primary_email' , oli.billing_contact__r.email);
                }
                if(!jsonMappingObject.containsKey('otherrefnum')){
                    if(oli.Po_number__c != null && oli.po_number__c != ''){
                    jsonMappingObject.put('otherrefnum' , oli.PO_Number__c);
                }/*else{
                    triggerNewMap.get(opportunityid).addError('This <a href="/'+oli.id+'">Opportunity Line Item</a> Po Number  cant be blank ' , false);
                }*/
                }
                if(oli.billing_contact2__c != null && !jsonMappingObject.containsKey('custbody_additional_email_1')){
                    jsonMappingObject.put('custbody_additional_email_1' , oli.billing_contact2__r.email);
                }
                if(oli.billing_contact3__c != null && !jsonMappingObject.containsKey('custbody_additional_email_2')){
                    jsonMappingObject.put('custbody_additional_email_2' , oli.billing_contact3__r.email);
                }
                if(oli.Opportunity.recordType.name == 'Event' && oli.Product_Details__c != null && oli.Product_Details__r.Subsidiary_ID__c != null ){
                    jsonMappingObject.put('subsidiary' ,oli.Product_Details__r.Subsidiary_ID__c);
                }else if (oli.Opportunity.recordType.name.containsIgnoreCase('Training') && oli.Product_Details__c != null ){
                        jsonMappingObject.put('subsidiary' ,'1');
                
                }
                else{
                    triggerNewMap.get(opportunityid).addError('This <a href="/'+oli.Product_Details__c+'">Product Detail </a> subsidiary cant be blank ', false);
                
                }  
               // jsonMappingObject.put('subsidiary' ,'1');
                //jsonMappingObject.put('department' , '1');
                if(netsuiteId != ''){
                        jsonMappingObject.put('entity' ,netsuiteId);
                }
                if(assetObject.opportunity__r.Opportunity_Link__c != null){
                    jsonMappingObject.put('custbody_sugar_reference' ,  assetObject.opportunity__r.Opportunity_Link__c);
                }
                 if( assetObject.opportunity__r.PAL_INVOICE__c == True){
                        jsonMappingObject.put('custbody_pal_invoice', 'T');
                        jsonMappingObject.put('custbody_additional_email_3',Label.Additional_email_address3);
                }
                else if(assetObject.opportunity__r.PAL_INVOICE__c == False){
                        jsonMappingObject.put('custbody_pal_invoice', 'F');
                
                }
                system.debug('***'+jsonMappingObject);
                salesLineItem.put('quantity' , 1);
                if(oli.description__c != null){
                    if(oli.description__c.length() < 4000)
                        salesLineItem.put('description' , oli.description__c);
                    else{
                         triggerNewMap.get(opportunityid).addError('This <a href="/"'+oli.id+'"> oli.id </a> description cant be more than 4000 chars ');
                    }
                }
                salesLineItem.put('amount' , oli.TotalPrice);
                if(oli.Opportunity.recordType.name == 'Event' && oli != null && oli.event__c != null && oli.event__r.Start_Date__c != null){
                    String startDate = oli.event__r.Start_Date__c.month()  + '/'+ oli.event__r.Start_Date__c.day() + '/' + oli.event__r.Start_Date__c.year(); 
                    salesLineItem.put('revrecstartdate' , startDate);
                }else if (oli.Opportunity.recordType.name.containsIgnoreCase('Training') && oli != null && oli.Training__c != null && (oli.Training__r.StartDateTime__c != null || oli.Start_Date__c != null)){
                    DateTime startDateTime = oli.Start_Date__c!= null ? oli.Start_Date__c : oli.Training__r.StartDateTime__c;
                        String startDate = string.valueOf(startDateTime.month()) + '/' + string.valueOf(startDateTime.day()) + '/' + string.valueOf(startDateTime.year());
                    salesLineItem.put('revrecstartdate' , startDate);
                }else{
                    triggerNewMap.get(opportunityId).addError('Start Date cant be null', false);
                    system.debug('**RecordType**'+oli.Opportunity.recordType.name);
                
                }
                if(oli.Opportunity.recordType.name == 'Event' && oli != null && oli.event__c != null && oli.event__r.End_Date__c != null){
                    String endDate = oli.event__r.End_Date__c.month() + '/' +oli.event__r.End_Date__c.day() + '/'  + oli.event__r.End_Date__c.year(); 
                    salesLineItem.put('revrecenddate' , endDate);
                }else if(oli.Opportunity.recordType.Name.containsIgnoreCase('Training') && oli != null && oli.Training__c != null && (oli.Training__r.End_DateTime__c != null || oli.End_Date__c != null)){
                    DateTime endDateTime = oli.End_Date__c!= null ? oli.End_Date__c : oli.Training__r.End_DateTime__c;
                    String endDate = String.ValueOf(endDateTime.month()) + '/' + String.ValueOf(endDateTime.day()) + '/'  + String.ValueOf(endDateTime.year()); 
                    salesLineItem.put('revrecenddate' , endDate);
                }else{
                        system.debug('**RecordType**'+oli.Opportunity.recordType.name);
                    triggerNewMap.get(opportunityId).addError('End Date cant be null' , false);
                
                }
                
                itemList.add(salesLineItem);
                
            }
            jsonMappingObject.put('items' ,  itemList);
            system.debug(JSON.serialize(jsonMappingObject));
            return JSON.serialize(jsonMappingObject);
            system.debug(assetObject);
            
        }
        return null;
    }
    
     public static string creatingMember( string accId , map<id , Opportunity>  triggerNewMap , String opportunityid , boolean member , boolean isBill  , String isEntityIdPresent,OpportunityLineItem opportunitylineitem){
        
        /*list <OpportunityLineItem> oppList = new list <OpportunityLineItem>();
        
        oppList = [SELECT id ,opportunity.account.BillingCountry,opportunity.recordtype.name, opportunity.Bill_To_Account__r.name , opportunity.Bill_To_Account__c ,  
                    opportunity.account.name,opportunity.Bill_To_Account__r.BillingState, opportunity.Bill_To_Account__r.BillingStreet,opportunity.Bill_To_Account__r.BillingCity,opportunity.Bill_To_Account__r.BillingPostalCode,opportunity.Bill_To_Account__r.BillingCountry, opportunity.account.BillingState , 
                    opportunity.account.BillingStreet, opportunity.account.BillingCity, opportunity.account.BillingPostalCode, Product_Details__r.training__c,
                    Product_Details__c , Product_Details__r.event__r.BillFromProject__r.Subsidiary_ID__c , Product_Details__r.event__r.BillFromProject__r.project_code__c ,
                    Product_Details__r.project__r.Subsidiary_ID__c  , Product_Details__r.project__r.project_code__c 
                    from OpportunityLineItem  
                    where opportunityid =:opportunityid];*/  
          system.debug('**oppList**'+oppList);
        String name = '';
        
        map<string , string> memberMapping = new map<string , string>();
        if(isEntityIdPresent != null){
            memberMapping.put('id' , isEntityIdPresent);
        }
        if(member){
            if(!isBill){
                    //if(oppList[0].opportunity.recordType.name == 'Membership'){
                    name = opportunitylineitem.opportunity.account.name  + ' - ' +  opportunitylineitem.Product_Details__r.project__r.project_code__c; 
                    if(opportunitylineitem.opportunity.account.name.length() <=80){
                        memberMapping.put('companyname', opportunitylineitem.opportunity.account.name );
                    }
                    else{
                        memberMapping.put('companyname', opportunitylineitem.opportunity.account.name.substring(0 , 80) );
                    }
                           
                    if(name != null && name.length() < 80){
                        memberMapping.put('entityid', name ); 
                    }else{
                        name = opportunitylineitem.opportunity.account.name.substring(0 , 70)  + ' - ' +  opportunitylineitem.Product_Details__r.project__r.project_code__c; 
                        memberMapping.put('entityid', name); 
                    }
                   
                    if( opportunitylineitem.Product_Details__r != null && opportunitylineitem.Product_Details__r.project__r != null && opportunitylineitem.Product_Details__r.project__r.Subsidiary_ID__c != null){
                        memberMapping.put('subsidiary',String.valueOF(opportunitylineitem.Product_Details__r.project__r.Subsidiary_ID__c));
                    }else{
                        triggerNewMap.get(opportunityId).addError('<a href="/'+opportunitylineitem.Product_Details__r.project__c + '"'+'>Projects Subsidiary ID</a> cant be null', false);
                    }
                    /*}else if(oppList[0].opportunity.recordType.name == 'Training'){
                        name = oppList[0].opportunity.account.name  + ' - ' +  'LF'; 
                            memberMapping.put('companyname', oppList[0].opportunity.account.name );     
                      if(name != null && name.length() < 80){
                        memberMapping.put('entityid', name ); 
                    }else{ 
                        name = oppList[0].opportunity.account.name.substring(0 , 70)  + ' - ' +  'LF'; 
                        memberMapping.put('entityid', name); 
                    }
                   
                    if(!oppList.isEmpty() && oppList[0].Product_Details__r != null && oppList[0].Product_Details__r.training__c != null ){
                        memberMapping.put('subsidiary','1');
                    }
                    }*/
            }/*else{
                name = oppList[0].opportunity.Bill_To_Account__r.name  + ' - ' +  oppList[0].Product_Details__r.project__r.project_code__c; 
                memberMapping.put('companyname', oppList[0].opportunity.Bill_To_Account__r.name ); 
                if(name != null && name.length() < 80){
                    memberMapping.put('entityid', name ); 
                }else{
                    name = oppList[0].opportunity.Bill_To_Account__r.name.substring(0 , 70)  + ' - ' +  oppList[0].Product_Details__r.project__r.project_code__c; 
                    memberMapping.put('entityid', name); 
                }
               
                if(!oppList.isEmpty() && oppList[0].Product_Details__r != null && oppList[0].Product_Details__r.project__r != null && oppList[0].Product_Details__r.project__r.Subsidiary_ID__c != null){
                    memberMapping.put('subsidiary',String.valueOF(oppList[0].Product_Details__r.project__r.Subsidiary_ID__c));
                }else{
                    triggerNewMap.get(opportunityId).addError('<a href="/'+oppList[0].id + '"'+'>Projects Subsidiary ID</a> cant be null', false);
                }
            }*/
        }else{
            
            if(!isBill){
                    if(oppList[0].opportunity.recordType.name == 'Event'){
                    memberMapping.put('companyname', oppList[0].opportunity.account.name ); 
                    name = oppList[0].opportunity.account.name  + ' - ' +  oppList[0].Product_Details__r.event__r.BillFromProject__r.project_code__c; 
                    if(name != null && name.length() < 80){
                        memberMapping.put('entityid', name ); 
                    }else{
                        name = oppList[0].opportunity.account.name.substring(0 , 70)  + ' - ' +  oppList[0].Product_Details__r.event__r.BillFromProject__r.project_code__c; 
                        memberMapping.put('entityid', name); 
                    }
                    if(!oppList.isEmpty() && oppList[0].opportunity.recordType.Name =='Event' && oppList[0].Product_Details__r != null && oppList[0].Product_Details__r.event__r.BillFromProject__r != null && oppList[0].Product_Details__r.event__r.BillFromProject__r.Subsidiary_ID__c != null){
                        memberMapping.put('subsidiary',String.valueOF(oppList[0].Product_Details__r.event__r.BillFromProject__r.Subsidiary_ID__c));
                    }/*else if(!oppList.isEmpty() && oppList[0].opportunity.recordType.Name =='Training' && oppList[0].Product_Details__r != null && oppList[0].Product_Details__r.training__c != null){
                            memberMapping.put('subsidiary','1');
                    
                    }*/else{
                            triggerNewMap.get(opportunityId).addError('<a href="/'+oppList[0].Product_Details__r.event__r.BillFromProject__c + '"'+'>Events Bill From Project Subsidiary ID</a> cant be null', false);
                    }
                    } else if(oppList[0].opportunity.recordType.Name.containsIgnoreCase('Training')){
                        name = oppList[0].opportunity.account.name  + ' - ' +  'LF'; 
                            memberMapping.put('companyname', oppList[0].opportunity.account.name );     
                      if(name != null && name.length() < 80){
                        memberMapping.put('entityid', name ); 
                    }else{
                        name = oppList[0].opportunity.account.name.substring(0 , 70)  + ' - ' +  'LF'; 
                        memberMapping.put('entityid', name); 
                    }
                   
                    if(!oppList.isEmpty() && oppList[0].Product_Details__r != null && oppList[0].Product_Details__r.training__c != null ){
                        memberMapping.put('subsidiary','1');
                    }
                    }
                    
            }/*else{
                     memberMapping.put('companyname', oppList[0].opportunity.Bill_To_Account__r.name ); 
                     name = oppList[0].opportunity.Bill_To_Account__r.name  + ' - ' +  oppList[0].Product_Details__r.event__r.BillFromProject__r.project_code__c; 
                    if(name != null && name.length() < 80){
                        memberMapping.put('entityid', name ); 
                    }else{
                        name = oppList[0].opportunity.Bill_To_Account__r.name.substring(0 , 70)  + ' - ' +  oppList[0].Product_Details__r.event__r.BillFromProject__r.project_code__c; 
                        memberMapping.put('entityid', name); 
                    }
                   
                    if(!oppList.isEmpty() && oppList[0].Product_Details__r != null && oppList[0].Product_Details__r.event__r.BillFromProject__r != null && oppList[0].Product_Details__r.event__r.BillFromProject__r.Subsidiary_ID__c != null){
                        memberMapping.put('subsidiary',String.valueOF(oppList[0].Product_Details__r.event__r.BillFromProject__r.Subsidiary_ID__c));
                    }else{
                        triggerNewMap.get(opportunityId).addError('<a href="/'+oppList[0].id + '"'+'>Events Bill From Project Subsidiary ID</a> cant be null', false);
                    }
            
            }*/
        }     
       /* else{
            triggerNewMap.get(opportunityId).addError('Account And Projects cant be null');
        }*/
       
           
        String convertedCountry = ''; 
        
        system.debug('**oppList[0].opportunity.account.BillingCountry'+oppList[0]);       
        if(oppList[0].opportunity.account.BillingCountry != null ){
            
            convertedCountry = convertingCountry(oppList[0].opportunity.account.BillingCountry, false);
            system.debug('**convertedCountry'+convertedCountry);       
                  
            system.debug('**convertedCountry1**'+convertedCountry);   
        }                  
        
        system.debug('**convertedCountry**'+convertedCountry);                                                           
        
        /*if(isBill){
                if(oppList[0].opportunity.Bill_To_Account__r.BillingCountry != null ){
                    String convertingCountry = mapForInputCountry.get(oppList[0].opportunity.Bill_To_Account__r.BillingCountry.tolowerCase()) ;
                    system.debug('**convertingCountry'+convertingCountry);         
                    convertedCountry = mapForCountryConverting.get(convertingCountry);
                    system.debug('**convertedCountry'+convertedCountry);       
                    //countryToSend =   mapForActualCountryCodes.get(convertedCountry); 
                    //system.debug('**countryToSend'+countryToSend);            
                }                                                                     
                memberMapping.put('recordtype','customer');
                memberMapping.put('url',null);
                memberMapping.put('phone',null);  
                memberMapping.put('addr1',string.valueOf(oppList[0].opportunity.Bill_To_Account__r.BillingStreet));  
                memberMapping.put('city',oppList[0].opportunity.Bill_To_Account__r.BillingCity);  
                memberMapping.put('zip',oppList[0].opportunity.Bill_To_Account__r.BillingPostalCode);  
                memberMapping.put('state',oppList[0].opportunity.Bill_To_Account__r.BillingState);  
                memberMapping.put('country', convertedCountry);
        
        }
        
        else if(!isBill){
                if(oppList[0].opportunity.account.BillingCountry != null ){
                    String convertingCountry = mapForInputCountry.get(oppList[0].opportunity.account.BillingCountry.tolowerCase()) ;
                    system.debug('**convertingCountry'+convertingCountry);         
                    convertedCountry = mapForCountryConverting.get(convertingCountry);
                    system.debug('**convertedCountry'+convertedCountry);       
                    //countryToSend =   mapForActualCountryCodes.get(convertedCountry); 
                    //system.debug('**countryToSend'+countryToSend);            
            }  */                                                                   
            memberMapping.put('recordtype','customer');
            memberMapping.put('url',null);
            memberMapping.put('phone',null);
            /*if(oppList[0].opportunity.account.BillingStreet == null ){
                    triggerNewMap.get(opportunityId).addError('Account Billing Address incomplete', false);
            }else{*/
                if(oppList[0].opportunity.account.BillingStreet != null ){
                  memberMapping.put('addr1',string.valueOf(oppList[0].opportunity.account.BillingStreet));  
                } 
                else{
                  memberMapping.put('addr1','');
                } 
                if(oppList[0].opportunity.account.BillingCity != null ){
                    memberMapping.put('city',oppList[0].opportunity.account.BillingCity);
                } 
                else{
                    memberMapping.put('city','');
                }
                if(oppList[0].opportunity.account.BillingPostalCode != null ){
                    memberMapping.put('zip',oppList[0].opportunity.account.BillingPostalCode);  
                } 
                else{
                    memberMapping.put('zip','');  
                }
                if(oppList[0].opportunity.account.BillingState != null ){
                    memberMapping.put('state',oppList[0].opportunity.account.BillingState.length() > 30 ? oppList[0].opportunity.account.BillingState.substring(0,30)
                                      : oppList[0].opportunity.account.BillingState);
                } 
                else{
                    memberMapping.put('state','');
                }
                system.debug('**convertedCountry'+convertedCountry);
                if(convertedCountry != null ){
                     memberMapping.put('country', convertedCountry);
                } 
                else{
                     memberMapping.put('country', '');
                }
           // }    
              
              
            
              
           
        //}    
         
        
        //memberMapping.put('attention',name);  
        //memberMapping.put('country',oppList[0].);  
      
       string accountId = '';//CallOutToNetSuiteForAsset.callOutToNetForAccount( 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=11' , 'POST' ,JSON.serialize(memberMapping)  , accId);
        system.debug('**accountId--'+accountId);
        return JSON.serialize(memberMapping);
    }
    public static string convertingCountry(string country , boolean checkMethod){
            map<string,string> mapForInputCountry = new map<string,string>();
            if (country != null && checkMethod == true){
                mapForInputCountry.put('bolivia','Bolivia');
            }else{
                mapForInputCountry.put('bolivia','Bolivia (Plurinational State of)');
            }
        mapForInputCountry.put('bosnia/herzegovina','Bosnia and Herzegovina');
        mapForInputCountry.put('brasil','Brazil');
        mapForInputCountry.put('brazil','Brazil');
        if (country != null && checkMethod == true){
                mapForInputCountry.put('china','China');
        }
        else{
                mapForInputCountry.put('china','People\'s Republic of China');
        }
        if (country != null && checkMethod == true){
                mapForInputCountry.put('people\'s republic of china','China');
        }
        else{
                mapForInputCountry.put('people\'s republic of china','People\'s Republic of China');
        }
        
        if (country != null && checkMethod == true){
                mapForInputCountry.put('china, peoples republic of','China');
        }else {
                mapForInputCountry.put('china, peoples republic of','People\'s Republic of China'); 
        }
        if (country != null && checkMethod == true){
                mapForInputCountry.put('cote d&#039;ivoire','Cote d\'Ivoire');
        }else {
                mapForInputCountry.put('cote d&#039;ivoire','Côte d\'Ivoire');
        }
        if (country != null && checkMethod == true){        
                mapForInputCountry.put('côte d’ivoire','Cote d\'Ivoire');
        }else {
                mapForInputCountry.put('côte d’ivoire','Côte d\'Ivoire');
        }
        mapForInputCountry.put('hong kong s.a.r., china','Hong Kong');
        mapForInputCountry.put('iran','Iran (Islamic Republic of)');
        mapForInputCountry.put('iran, islamic republic of','Iran (Islamic Republic of)');
        mapForInputCountry.put('kazakstan','Kazakhstan');
        if (country != null && checkMethod == true){    
                mapForInputCountry.put('korea','Korea, Republic of');
        }else{
                mapForInputCountry.put('korea','Korea (Republic of)');
        }if (country != null && checkMethod == true){   
                mapForInputCountry.put('korea, republic of','Korea, Republic of');
        }else{
                mapForInputCountry.put('korea, republic of','Korea (Republic of)');
        }
        if (country != null && checkMethod == true){    
                mapForInputCountry.put('korea, south','Korea, Republic of');
        }else{
                mapForInputCountry.put('korea, south','Korea (Republic of)');   
        }
        mapForInputCountry.put('lao people&#039;s democratic republic','Lao People\'s Democratic Republic');
        mapForInputCountry.put('laos','Lao People\'s Democratic Republic');
        mapForInputCountry.put('libyan arab jamahiriya','Libya');
        if (country != null && checkMethod == true){    
                mapForInputCountry.put('macau','Macau');
        }else{
                mapForInputCountry.put('macau','Macao');
        }
        if(country != null && checkMethod == true){
                mapForInputCountry.put('macedonia','Macedonia');
        }else{
                mapForInputCountry.put('macedonia','Macedonia (the former Yugoslav Republic of)');  
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('moldova','Moldova, Republic of');
        }else{
                mapForInputCountry.put('moldova','Moldova (Republic of)');
        }
        if(country != null && checkMethod == true){
                mapForInputCountry.put('moldova, republic of','Moldova, Republic of');
        }else{
                mapForInputCountry.put('moldova, republic of','Moldova (Republic of)');
        }
        mapForInputCountry.put('netherlands antilles','Netherlands');
        if(country != null && checkMethod == true){
                mapForInputCountry.put('p.r. china','China');
        }else{
                mapForInputCountry.put('p.r. china','People\'s Republic of China');
        }
        if(country != null && checkMethod == true){
                mapForInputCountry.put('palestinian territory','State of Palestine');
        }else{
                mapForInputCountry.put('palestinian territory','Palestine, State of');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('p.r.china','China');
        }else{
                mapForInputCountry.put('p.r.china','People\'s Republic of China');
        }
        if(country != null && checkMethod == true){
                mapForInputCountry.put('pr china','China');
        }else{
                mapForInputCountry.put('pr china','People\'s Republic of China');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('prc china','China');
        }else{
                mapForInputCountry.put('prc china','People\'s Republic of China');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('republic of korea','Korea, Republic of');
        }else{
                mapForInputCountry.put('republic of korea','Korea (Republic of)');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('republic of south korea','Korea, Republic of');
        }else{
                mapForInputCountry.put('republic of south korea','Korea (Republic of)');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('roc','Taiwan');
        }else{
                mapForInputCountry.put('roc','Taiwan, Province of China[a]');           
        }
        mapForInputCountry.put('russia','Russian Federation');
        if(country != null && checkMethod == true){
                mapForInputCountry.put('slovakia (slovak republic)','Slovak Republic');
        }else{
                mapForInputCountry.put('slovakia (slovak republic)','Slovakia');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('south korea','Korea, Republic of');
        }else{
                mapForInputCountry.put('south korea','Korea (Republic of)');
        }
        mapForInputCountry.put('syria','Syrian Arab Republic');
        if(country != null && checkMethod == true){
                mapForInputCountry.put('taiwan roc','Taiwan');
        }else{
                mapForInputCountry.put('taiwan roc','Taiwan, Province of China[a]');
        } if(country != null && checkMethod == true){
                mapForInputCountry.put('taiwan','Taiwan');
        }else{
                mapForInputCountry.put('taiwan','Taiwan, Province of China[a]');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('tanzania','Tanzania');
        }else{
                mapForInputCountry.put('tanzania','Tanzania, United Republic of');
        }
        mapForInputCountry.put('the netherlands','Netherlands');
        if(country != null && checkMethod == true){
                mapForInputCountry.put('u.s.','United States');
        }else{
                mapForInputCountry.put('u.s.','United States of America');
        } if(country != null && checkMethod == true){
                mapForInputCountry.put('u.s.a.','United States');
        }else{
                mapForInputCountry.put('u.s.a.','United States of America');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('uk','United Kingdom');
        }else{
                mapForInputCountry.put('uk','United Kingdom of Great Britain and Northern Ireland');    
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('united kingdom','United Kingdom');
        }else{
                mapForInputCountry.put('united kingdom','United Kingdom of Great Britain and Northern Ireland');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('united states','United States');
        }else{
                mapForInputCountry.put('united states','United States of America');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('us','United States');
        }else{
                mapForInputCountry.put('us','United States of America');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('usa','United States');
        }else{
                mapForInputCountry.put('usa','United States of America');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('venezuela','Venezuela');
        }else{
                mapForInputCountry.put('venezuela','Venezuela (Bolivarian Republic of)');
        }if(country != null && checkMethod == true){
                mapForInputCountry.put('vietnam','Vietnam');
        }else{
                mapForInputCountry.put('vietnam','Viet Nam');
        }
        mapForInputCountry.put('afghanistan','Afghanistan');
        mapForInputCountry.put('åland islands','Åland Islands');
        mapForInputCountry.put('albania','Albania');
        mapForInputCountry.put('algeria','Algeria');
        mapForInputCountry.put('american samoa','American Samoa');
        mapForInputCountry.put('andorra','Andorra');
        mapForInputCountry.put('angola','Angola');
        mapForInputCountry.put('anguilla','Anguilla');
        mapForInputCountry.put('antarctica','Antarctica');
        mapForInputCountry.put('antigua and barbuda','Antigua and Barbuda');
        mapForInputCountry.put('argentina','Argentina');
        mapForInputCountry.put('armenia','Armenia');
        mapForInputCountry.put('aruba','Aruba');
        mapForInputCountry.put('australia','Australia');
        mapForInputCountry.put('austria','Austria');
        mapForInputCountry.put('azerbaijan','Azerbaijan');
        mapForInputCountry.put('bahamas','Bahamas');
        mapForInputCountry.put('bahrain','Bahrain');
        mapForInputCountry.put('bangladesh','Bangladesh');
        mapForInputCountry.put('barbados','Barbados');
        mapForInputCountry.put('belarus','Belarus');
        mapForInputCountry.put('belgium','Belgium');
        mapForInputCountry.put('belize','Belize');
        mapForInputCountry.put('benin','Benin');
        mapForInputCountry.put('bermuda','Bermuda');
        mapForInputCountry.put('bhutan','Bhutan');
        mapForInputCountry.put('bonaire, sint eustatius and saba','Bonaire, Sint Eustatius and Saba');
        mapForInputCountry.put('botswana','Botswana');
        mapForInputCountry.put('bouvet island','Bouvet Island');
        mapForInputCountry.put('british indian ocean territory','British Indian Ocean Territory');
        mapForInputCountry.put('brunei darussalam','Brunei Darussalam');
        mapForInputCountry.put('bulgaria','Bulgaria');
        mapForInputCountry.put('burkina faso','Burkina Faso');
        mapForInputCountry.put('burundi','Burundi');
        mapForInputCountry.put('cabo verde','Cabo Verde');
        mapForInputCountry.put('cameroon','Cameroon');
        mapForInputCountry.put('canada','Canada');
        mapForInputCountry.put('cayman islands','Cayman Islands');
        mapForInputCountry.put('central african republic','Central African Republic');
        mapForInputCountry.put('chad','Chad');
        mapForInputCountry.put('chile','Chile');
        mapForInputCountry.put('christmas island','Christmas Island');
        mapForInputCountry.put('cocos (keeling) islands','Cocos (Keeling) Islands');
        mapForInputCountry.put('colombia','Colombia');
        mapForInputCountry.put('comoros','Comoros');
        if(country != null && checkMethod == true){
                mapForInputCountry.put('congo','Congo');
        }else{
                mapForInputCountry.put('congo','Congo, Democratic Republic of');
        }
        if(country != null && checkMethod == true){
                mapForInputCountry.put('congo (democratic republic of the)','Congo, Democratic Republic of');
        }else{
                mapForInputCountry.put('congo (democratic republic of the)','Congo (Democratic Republic of the)');
        }
        mapForInputCountry.put('cook islands','Cook Islands');
        mapForInputCountry.put('costa rica','Costa Rica');
        mapForInputCountry.put('croatia','Croatia');
        mapForInputCountry.put('cuba','Cuba');
        mapForInputCountry.put('cyprus','Cyprus');
        mapForInputCountry.put('czech republic','Czech Republic');
        mapForInputCountry.put('denmark','Denmark');
        mapForInputCountry.put('djibouti','Djibouti');
        mapForInputCountry.put('dominica','Dominica');
        mapForInputCountry.put('dominican republic','Dominican Republic');
        mapForInputCountry.put('ecuador','Ecuador');
        mapForInputCountry.put('egypt','Egypt');
        mapForInputCountry.put('el salvador','El Salvador');
        mapForInputCountry.put('equatorial guinea','Equatorial Guinea');
        mapForInputCountry.put('eritrea','Eritrea');
        mapForInputCountry.put('estonia','Estonia');
        mapForInputCountry.put('ethiopia','Ethiopia');
        mapForInputCountry.put('falkland islands (malvinas)','Falkland Islands (Malvinas)');
        mapForInputCountry.put('faroe islands','Faroe Islands');
        mapForInputCountry.put('fiji','Fiji');
        mapForInputCountry.put('finland','Finland');
        mapForInputCountry.put('france','France');
        mapForInputCountry.put('french guiana','French Guiana');
        mapForInputCountry.put('french polynesia','French Polynesia');
        mapForInputCountry.put('french southern territories','French Southern Territories');
        mapForInputCountry.put('gabon','Gabon');
        mapForInputCountry.put('gambia','Gambia');
        mapForInputCountry.put('georgia','Georgia');
        mapForInputCountry.put('germany','Germany');
        mapForInputCountry.put('ghana','Ghana');
        mapForInputCountry.put('gibraltar','Gibraltar');
        mapForInputCountry.put('greece','Greece');
        mapForInputCountry.put('greenland','Greenland');
        mapForInputCountry.put('grenada','Grenada');
        mapForInputCountry.put('guadeloupe','Guadeloupe');
        mapForInputCountry.put('guam','Guam');
        mapForInputCountry.put('guatemala','Guatemala');
        mapForInputCountry.put('guernsey','Guernsey');
        mapForInputCountry.put('guinea','Guinea');
        mapForInputCountry.put('guinea-Bissau','Guinea-Bissau');
        mapForInputCountry.put('guyana','Guyana');
        mapForInputCountry.put('haiti','Haiti');
        if(country != null && checkMethod == true){
                mapForInputCountry.put('heard island and mcdonald islands','Heard and McDonald Islands');
        }else{
                mapForInputCountry.put('heard island and mcdonald islands','Heard Island and McDonald Islands');
        }
        if(country != null && checkMethod == true){
                mapForInputCountry.put('holy see','Holy See (City Vatican State)');
            }else{
                mapForInputCountry.put('holy see','Holy See');
        }
        mapForInputCountry.put('honduras','Honduras');
        mapForInputCountry.put('hungary','Hungary');
        mapForInputCountry.put('iceland','Iceland');
        mapForInputCountry.put('india','India');
        mapForInputCountry.put('indonesia','Indonesia');
        mapForInputCountry.put('iraq','Iraq');
        mapForInputCountry.put('ireland','Ireland');
        mapForInputCountry.put('isle of man',' Isle of Man');
        mapForInputCountry.put('israel','Israel');
        mapForInputCountry.put('italy','Italy');
        mapForInputCountry.put('jamaica','Jamaica');
        mapForInputCountry.put('japan','Japan');
        mapForInputCountry.put('jersey','Jersey');
        mapForInputCountry.put('jordan','Jordan');
        mapForInputCountry.put('kenya','Kenya');
        mapForInputCountry.put('kiribati','Kiribati');
        mapForInputCountry.put('kuwait','Kuwait');
        mapForInputCountry.put('korea (democratic people\'s republic of)','Korea (Democratic People\'s Republic of)');
        mapForInputCountry.put('zimbabwe','Zimbabwe');
        mapForInputCountry.put('zambia','Zambia');
        mapForInputCountry.put('yemen','Yemen');
        mapForInputCountry.put('western sahara','Western Sahara');
        mapForInputCountry.put('wallis and futuna','Wallis and Futuna');
        if(country != null && checkMethod == true){
                mapForInputCountry.put('virgin islands (u.s.)','Virgin Islands (USA)');
        }else{
                mapForInputCountry.put('virgin islands (u.s.)','Virgin Islands (U.S.)');
        }
        mapForInputCountry.put('virgin islands (british)','Virgin Islands (British)');
        mapForInputCountry.put('vanuatu','Vanuatu');
        mapForInputCountry.put('uzbekistan','Uzbekistan');
        mapForInputCountry.put('uruguay','Uruguay');
        if(country != null && checkMethod == true){
                mapForInputCountry.put('united states minor outlying islands','US Minor Outlying Islands');
        }else{
                mapForInputCountry.put('united states minor outlying islands','United States Minor Outlying Islands');
        }
        mapForInputCountry.put('united arab emirates','United Arab Emirates');
        mapForInputCountry.put('ukraine','Ukraine');
        mapForInputCountry.put('uganda','Uganda');
        mapForInputCountry.put('tuvalu','Tuvalu');
        mapForInputCountry.put('turks and caicos islands','Turks and Caicos Islands');
        mapForInputCountry.put('turkmenistan','Turkmenistan');
        mapForInputCountry.put('turkey','Turkey');
        mapForInputCountry.put('tunisia','Tunisia');
        mapForInputCountry.put('trinidad and tobago','Trinidad and Tobago');
         mapForInputCountry.put('tonga','Tonga');
         mapForInputCountry.put('tokelau','Tokelau');
         mapForInputCountry.put('togo','Togo');
         mapForInputCountry.put('timor-leste','Timor-Leste');
         mapForInputCountry.put('thailand','Thailand');
         mapForInputCountry.put('tajikistan','Tajikistan');
         mapForInputCountry.put('switzerland','Switzerland');
         mapForInputCountry.put('sweden','Sweden');
         mapForInputCountry.put('swaziland','Swaziland');
         if(country != null && checkMethod == true){
            mapForInputCountry.put('svalbard and jan mayen','South Georgia');
         }else{
            mapForInputCountry.put('svalbard and jan mayen','Svalbard and Jan Mayen');
         }
         mapForInputCountry.put('suriname','Suriname');
         mapForInputCountry.put('sudan','Sudan');
         mapForInputCountry.put('sri Lanka','Sri Lanka');
         mapForInputCountry.put('spain','Spain');
         mapForInputCountry.put('south sudan','South Sudan');
         if(country != null && checkMethod == true){
            mapForInputCountry.put('south georgia and the south sandwich islands','South Georgia');
         }else{
            mapForInputCountry.put('south georgia and the south sandwich islands','South Georgia and the South Sandwich Islands');
         }
         mapForInputCountry.put('south africa','South Africa');
         mapForInputCountry.put('somalia','Somalia');
         mapForInputCountry.put('solomon islands','Solomon Islands');
         mapForInputCountry.put('slovenia','Slovenia');
         mapForInputCountry.put('sint maarten (dutch part)','Sint Maarten (Dutch part)');
         mapForInputCountry.put('singapore','Singapore');
         mapForInputCountry.put('sierra leone','Sierra Leone');
         mapForInputCountry.put('seychelles','Seychelles');
         mapForInputCountry.put('serbia','Serbia');
         mapForInputCountry.put('senegal','Senegal');
         mapForInputCountry.put('saudi arabia','Saudi Arabia');
         mapForInputCountry.put('sao tome and principe','Sao Tome and Principe');
         mapForInputCountry.put('san marino','San Marino');
         mapForInputCountry.put('samoa','Samoa');
         mapForInputCountry.put('saint vincent and the grenadines','Saint Vincent and the Grenadines');
         mapForInputCountry.put('saint pierre and miquelon','Saint Pierre and Miquelon');
         mapForInputCountry.put('saint martin (french part)','Saint Martin (French part)');
         mapForInputCountry.put('saint lucia','Saint Lucia');
         mapForInputCountry.put('saint kitts and nevis','Saint Kitts and Nevis');
         if(country != null && checkMethod == true){
            mapForInputCountry.put('saint helena, ascension and tristan da cunha','Saint Helena');
         }else{
            mapForInputCountry.put('saint helena, ascension and tristan da cunha','Saint Helena, Ascension and Tristan da Cunha');
         }
         mapForInputCountry.put('saint barthélemy','Saint Barthélemy');
         mapForInputCountry.put('rwanda','Rwanda');
         mapForInputCountry.put('romania','Romania');
         mapForInputCountry.put('réunion','Réunion');
         mapForInputCountry.put('qatar','Qatar');
         mapForInputCountry.put('puerto rico','Puerto Rico');
         mapForInputCountry.put('portugal','Portugal');
         mapForInputCountry.put('poland','Poland');
         mapForInputCountry.put('pitcairn','Pitcairn');
         mapForInputCountry.put('philippines','Philippines');
         mapForInputCountry.put('peru','Peru');
         mapForInputCountry.put('paraguay','Paraguay');
         mapForInputCountry.put('papua new guinea','Papua New Guinea');
         mapForInputCountry.put('panama','Panama');
         mapForInputCountry.put('palau','Palau');
         mapForInputCountry.put('pakistan','Pakistan');
         mapForInputCountry.put('oman','Oman');
         mapForInputCountry.put('norway','Norway');
         mapForInputCountry.put('northern mariana islands','Northern Mariana Islands');
         mapForInputCountry.put('norfolk island','Norfolk Island');
         mapForInputCountry.put('niue','Niue');
         mapForInputCountry.put('nigeria','Nigeria');
         mapForInputCountry.put('niger','Niger');
         mapForInputCountry.put('nicaragua','Nicaragua');
         mapForInputCountry.put('new Zealand','New Zealand');
         mapForInputCountry.put('new caledonia','New Caledonia');
         mapForInputCountry.put('nepal','Nepal');
         mapForInputCountry.put('nauru','Nauru');
         mapForInputCountry.put('namibia','Namibia');
         mapForInputCountry.put('myanmar','Myanmar');
         mapForInputCountry.put('mozambique','Mozambique');
         mapForInputCountry.put('morocco','Morocco');
         mapForInputCountry.put('montserrat','Montserrat');
         mapForInputCountry.put('montenegro','Montenegro');
         mapForInputCountry.put('mongolia','Mongolia');
         mapForInputCountry.put('monaco','Monaco');
         if(country != null && checkMethod == true){
            mapForInputCountry.put('micronesia (federated states of)','Micronesia, Federal State of');
         }else{
            mapForInputCountry.put('micronesia (federated states of)','Micronesia (Federated States of)');
         } 
         mapForInputCountry.put('mexico','Mexico');
         mapForInputCountry.put('mayotte','Mayotte');
         mapForInputCountry.put('mauritius','Mauritius');
         mapForInputCountry.put('mauritania','Mauritania');
         mapForInputCountry.put('martinique','Martinique');
         mapForInputCountry.put('marshall islands','Marshall Islands');
         mapForInputCountry.put('malta','Malta');
         mapForInputCountry.put('mali','Mali');
         mapForInputCountry.put('maldives','Maldives');
         mapForInputCountry.put('malaysia','Malaysia');
         mapForInputCountry.put('malawi','Malawi');
         mapForInputCountry.put('madagascar','Madagascar');
         mapForInputCountry.put('luxembourg','Luxembourg');
         mapForInputCountry.put('lithuania','Lithuania');
         mapForInputCountry.put('liechtenstein','Liechtenstein');
         mapForInputCountry.put('liberia','Liberia');
         mapForInputCountry.put('lesotho','Lesotho');
         mapForInputCountry.put('lebanon','Lebanon');
         mapForInputCountry.put('latvia','Latvia');
         mapForInputCountry.put('kyrgyzstan','Kyrgyzstan');

       


 
                    
                    
        
        map<string,string> mapForCountryConverting = new map <string,string>();
        mapForCountryConverting.put('Afghanistan','AF');
        mapForCountryConverting.put('Åland Islands','AX');
        mapForCountryConverting.put('Albania','AL');
        mapForCountryConverting.put('Algeria','DZ');
        mapForCountryConverting.put('American Samoa','AS');
        mapForCountryConverting.put('Andorra','AD');
        mapForCountryConverting.put('Angola','AO');
        mapForCountryConverting.put('Anguilla','AI');
        mapForCountryConverting.put('Antarctica','AQ');
        mapForCountryConverting.put('Antigua and Barbuda','AG');
        mapForCountryConverting.put('Argentina','AR');
        mapForCountryConverting.put('Armenia','AM');
        mapForCountryConverting.put('Aruba','AW');
        mapForCountryConverting.put('Australia','AU');
        mapForCountryConverting.put('Austria','AT');
        mapForCountryConverting.put('Azerbaijan','AZ');
        mapForCountryConverting.put('Bahamas','BS');
        mapForCountryConverting.put('Bahrain','BH');
        mapForCountryConverting.put('Bangladesh','BD');
        mapForCountryConverting.put('Barbados','BB');
        mapForCountryConverting.put('Belarus' , 'BY');
        mapForCountryConverting.put('Belgium','BE');
        mapForCountryConverting.put('Belize','BZ');
        mapForCountryConverting.put('Benin','BJ');
        mapForCountryConverting.put('Bermuda','BM');
        mapForCountryConverting.put('Bhutan','BT');
        mapForCountryConverting.put('Bolivia (Plurinational State of)','BO');
        mapForCountryConverting.put('Bonaire, Sint Eustatius and Saba','BQ');
        mapForCountryConverting.put('Bosnia and Herzegovina','BA');
        mapForCountryConverting.put('Botswana','BW');
        mapForCountryConverting.put('Bouvet Island','BV');
        mapForCountryConverting.put('Brazil','BR');
        mapForCountryConverting.put('British Indian Ocean Territory','IO');
        mapForCountryConverting.put('Brunei Darussalam','BN');
        mapForCountryConverting.put('Bulgaria','BG');
        mapForCountryConverting.put('Burkina Faso','BF');
        mapForCountryConverting.put('Burundi','BI');
        mapForCountryConverting.put('Cabo Verde','CV');
        mapForCountryConverting.put('Cambodia','KH');
        mapForCountryConverting.put('Cameroon','CM');
        mapForCountryConverting.put('Canada','CA');
        mapForCountryConverting.put('Cayman Islands','KY');
        mapForCountryConverting.put('Central African Republic','CF');
        mapForCountryConverting.put('Chad','TD');
        mapForCountryConverting.put('Chile','CL');
        mapForCountryConverting.put('People\'s Republic of China','CN');
        mapForCountryConverting.put('Christmas Island','CX');
        mapForCountryConverting.put('Cocos (Keeling) Islands','CC');
        mapForCountryConverting.put('Colombia','CO');
        mapForCountryConverting.put('Comoros','KM');
        mapForCountryConverting.put('Congo','CG');
        mapForCountryConverting.put('Congo (Democratic Republic of the)','CD');
        mapForCountryConverting.put('Cook Islands','CK');
        mapForCountryConverting.put('Costa Rica','CR');
        mapForCountryConverting.put('Côte d\'Ivoire','CI');
        mapForCountryConverting.put('Croatia','HR');
        mapForCountryConverting.put('Cuba','CU');
        mapForCountryConverting.put('Curaçao','CW');
        mapForCountryConverting.put('Cyprus','CY');
        mapForCountryConverting.put('Czech Republic','CZ');
        mapForCountryConverting.put('Denmark','DK');
        mapForCountryConverting.put('Djibouti','DJ');
        mapForCountryConverting.put('Dominica','DM');
        mapForCountryConverting.put('Dominican Republic','DO');
        mapForCountryConverting.put('Ecuador','EC');
        mapForCountryConverting.put('Egypt','EG');
        mapForCountryConverting.put('El Salvador','SV');
        mapForCountryConverting.put('Equatorial Guinea','GQ');
        mapForCountryConverting.put('Eritrea','ER');
        mapForCountryConverting.put('Estonia','EE');
        mapForCountryConverting.put('Ethiopia','ET');
        mapForCountryConverting.put('Falkland Islands (Malvinas)','FK');
        mapForCountryConverting.put('Faroe Islands','FO');
        mapForCountryConverting.put('Fiji','FJ');
        mapForCountryConverting.put('Finland','FI');
        mapForCountryConverting.put('France','FR');
        mapForCountryConverting.put('French Guiana','GF');
        mapForCountryConverting.put('French Polynesia','PF');
        mapForCountryConverting.put('French Southern Territories','TF');
        mapForCountryConverting.put('Gabon','GA');
        mapForCountryConverting.put('Gambia','GM');
        mapForCountryConverting.put('Georgia','GE');
        mapForCountryConverting.put('Germany','DE');
        mapForCountryConverting.put('Ghana','GH');
        mapForCountryConverting.put('Gibraltar','GI');
        mapForCountryConverting.put('Greece','GR');
        mapForCountryConverting.put('Greenland','GL');
        mapForCountryConverting.put('Grenada','GD');
        mapForCountryConverting.put('Guadeloupe','GP');
        mapForCountryConverting.put('Guam','GU');
        mapForCountryConverting.put('Guatemala','GT');
        mapForCountryConverting.put('Guernsey','GG');
        mapForCountryConverting.put('Guinea','GN');
        mapForCountryConverting.put('Guinea-Bissau','GW');
        mapForCountryConverting.put('Guyana','GY');
        mapForCountryConverting.put('Haiti','HT');
        mapForCountryConverting.put('Heard Island and McDonald Islands','HM');
        mapForCountryConverting.put('Holy See','VA');
        mapForCountryConverting.put('Honduras','HN');
        mapForCountryConverting.put('Hong Kong','HK');
        mapForCountryConverting.put('Hungary','HU');
        mapForCountryConverting.put('Iceland','IS');
        mapForCountryConverting.put('India','IN');
        mapForCountryConverting.put('Indonesia','ID');
        mapForCountryConverting.put('Iran (Islamic Republic of)','IR');
        mapForCountryConverting.put('Iraq','IQ');
        mapForCountryConverting.put('Ireland','IE');
        mapForCountryConverting.put('Isle of Man','IM');
        mapForCountryConverting.put('Israel','IL');
        mapForCountryConverting.put('Italy','IT');
        mapForCountryConverting.put('Jamaica','JM');
        mapForCountryConverting.put('Japan','JP');
        mapForCountryConverting.put('Jersey','JE');
        mapForCountryConverting.put('Jordan','JO');
        mapForCountryConverting.put('Kazakhstan','KZ');
        mapForCountryConverting.put('Kenya','KE');
        mapForCountryConverting.put('Kiribati','KI');
        mapForCountryConverting.put('Korea (Democratic People\'s Republic of)','KP');
        mapForCountryConverting.put('Korea (Republic of)','KR');
        mapForCountryConverting.put('Kuwait','KW');
        mapForCountryConverting.put('Kyrgyzstan','KG');
        mapForCountryConverting.put('Lao People\'s Democratic Republic','LA');
        mapForCountryConverting.put('Latvia','LV');
        mapForCountryConverting.put('Lebanon','LB');
        mapForCountryConverting.put('Lesotho','LS');
        mapForCountryConverting.put('Liberia','LR');
        mapForCountryConverting.put('Libya','LY');
        mapForCountryConverting.put('Liechtenstein','LI');
        mapForCountryConverting.put('Lithuania','LT');
        mapForCountryConverting.put('Luxembourg','LU');
        mapForCountryConverting.put('Macao','MO');
        mapForCountryConverting.put('Macedonia (the former Yugoslav Republic of)','MK');
        mapForCountryConverting.put('Madagascar','MG');
        mapForCountryConverting.put('Malawi','MW');
        mapForCountryConverting.put('Malaysia','MY');
        mapForCountryConverting.put('Maldives','MV');
        mapForCountryConverting.put('Mali','ML');
        mapForCountryConverting.put('Malta','MT');
        mapForCountryConverting.put('Marshall Islands','MH');
        mapForCountryConverting.put('Martinique','MQ');
        mapForCountryConverting.put('Mauritania','MR');
        mapForCountryConverting.put('Mauritius','MU');
        mapForCountryConverting.put('Mayotte','YT');
        mapForCountryConverting.put('Mexico','MX');
        mapForCountryConverting.put('Micronesia (Federated States of)','FM');
        mapForCountryConverting.put('Moldova (Republic of)','MD');
        mapForCountryConverting.put('Monaco','MC');
        mapForCountryConverting.put('Mongolia','MN');
        mapForCountryConverting.put('Montenegro','ME');
        mapForCountryConverting.put('Montserrat','MS');
        mapForCountryConverting.put('Morocco','MA');
        mapForCountryConverting.put('Mozambique','MZ');
        mapForCountryConverting.put('Myanmar','MM');
        mapForCountryConverting.put('Namibia','NA');
        mapForCountryConverting.put('Nauru','NR');
        mapForCountryConverting.put('Nepal','NP');
        mapForCountryConverting.put('Netherlands','NL');
        mapForCountryConverting.put('New Caledonia','NC');
        mapForCountryConverting.put('New Zealand','NZ');
        mapForCountryConverting.put('Nicaragua','NI');
        mapForCountryConverting.put('Niger','NE');
        mapForCountryConverting.put('Nigeria','NG');
        mapForCountryConverting.put('Niue','NU');
        mapForCountryConverting.put('Norfolk Island','NF');
        mapForCountryConverting.put('Northern Mariana Islands','MP');
        mapForCountryConverting.put('Norway','NO');
        mapForCountryConverting.put('Oman','OM');
        mapForCountryConverting.put('Pakistan','PK');
        mapForCountryConverting.put('Palau','PW');
        mapForCountryConverting.put('Palestine, State of','PS');
        mapForCountryConverting.put('Panama','PA');
        mapForCountryConverting.put('Papua New Guinea','PG');
        mapForCountryConverting.put('Paraguay','PY');
        mapForCountryConverting.put('Peru','PE');
        mapForCountryConverting.put('Philippines','PH');
        mapForCountryConverting.put('Pitcairn','PN');
        mapForCountryConverting.put('Poland','PL');
        mapForCountryConverting.put('Portugal','PT');
        mapForCountryConverting.put('Puerto Rico','PR');
        mapForCountryConverting.put('Qatar','QA');
        mapForCountryConverting.put('Réunion','RE');
        mapForCountryConverting.put('Romania','RO');
        mapForCountryConverting.put('Russian Federation','RU');
        mapForCountryConverting.put('Rwanda','RW');
        mapForCountryConverting.put('Saint Barthélemy','BL');
        mapForCountryConverting.put('Saint Helena, Ascension and Tristan da Cunha','SH');
        mapForCountryConverting.put('Saint Kitts and Nevis','KN');
        mapForCountryConverting.put('Saint Lucia','LC');
        mapForCountryConverting.put('Saint Martin (French part)','MF');
        mapForCountryConverting.put('Saint Pierre and Miquelon','PM');
        mapForCountryConverting.put('Saint Vincent and the Grenadines','VC');
        mapForCountryConverting.put('Samoa','WS');
        mapForCountryConverting.put('San Marino','SM');
        mapForCountryConverting.put('Sao Tome and Principe','ST');
        mapForCountryConverting.put('Saudi Arabia','SA');
        mapForCountryConverting.put('Senegal','SN');
        mapForCountryConverting.put('Serbia','RS');
        mapForCountryConverting.put('Seychelles','SC');
        mapForCountryConverting.put('Sierra Leone','SL');
        mapForCountryConverting.put('Singapore','SG');
        mapForCountryConverting.put('Sint Maarten (Dutch part)','SX');
        mapForCountryConverting.put('Slovakia','SK');
        mapForCountryConverting.put('Slovenia','SI');
        mapForCountryConverting.put('Solomon Islands','SB');
        mapForCountryConverting.put('Somalia','SO');
        mapForCountryConverting.put('South Africa','ZA');
        mapForCountryConverting.put('South Georgia and the South Sandwich Islands','GS');
        mapForCountryConverting.put('South Sudan','SS');
        mapForCountryConverting.put('Spain','ES');
        mapForCountryConverting.put('Sri Lanka','LK');
        mapForCountryConverting.put('Sudan','SD');
        mapForCountryConverting.put('Suriname','SR');
        mapForCountryConverting.put('Svalbard and Jan Mayen','SJ');
        mapForCountryConverting.put('Swaziland','SZ');
        mapForCountryConverting.put('Sweden','SE');
        mapForCountryConverting.put('Switzerland','CH');
        mapForCountryConverting.put('Syrian Arab Republic','SY');
        mapForCountryConverting.put('Taiwan, Province of China[a]','TW');
        mapForCountryConverting.put('Tajikistan','TJ');
        mapForCountryConverting.put('Tanzania, United Republic of','TZ');
        mapForCountryConverting.put('Thailand','TH');
        mapForCountryConverting.put('Timor-Leste','TL');
        mapForCountryConverting.put('Togo','TG');
        mapForCountryConverting.put('Tokelau','TK');
        mapForCountryConverting.put('Tonga','TO');
        mapForCountryConverting.put('Trinidad and Tobago','TT');
        mapForCountryConverting.put('Tunisia','TN');
        mapForCountryConverting.put('Turkey','TR');
        mapForCountryConverting.put('Turkmenistan','TM');
        mapForCountryConverting.put('Turks and Caicos Islands','TC');
        mapForCountryConverting.put('Tuvalu','TV');
        mapForCountryConverting.put('Uganda','UG');
        mapForCountryConverting.put('Ukraine','UA');
        mapForCountryConverting.put('United Arab Emirates','AE');
        mapForCountryConverting.put('United Kingdom of Great Britain and Northern Ireland','GB');
        mapForCountryConverting.put('United States of America','US');
        mapForCountryConverting.put('United States Minor Outlying Islands','UM');
        mapForCountryConverting.put('Uruguay','UY');
        mapForCountryConverting.put('Uzbekistan','UZ');
        mapForCountryConverting.put('Vanuatu','VU');
        mapForCountryConverting.put('Venezuela (Bolivarian Republic of)','VE');
        mapForCountryConverting.put('Viet Nam','VN');
        mapForCountryConverting.put('Virgin Islands (British)','VG');
        mapForCountryConverting.put('Virgin Islands (U.S.)','VI');
        mapForCountryConverting.put('Wallis and Futuna','WF');
        mapForCountryConverting.put('Western Sahara','EH');
        mapForCountryConverting.put('Yemen','YE');
        mapForCountryConverting.put('Zambia','ZM');
        mapForCountryConverting.put('Zimbabwe','ZW');
        if(country != null && checkMethod == false){
                String convertingCountry = mapForInputCountry.get(country.tolowerCase()) ;
                String convertedCountry = mapForCountryConverting.get(convertingCountry);
                return convertedCountry;
        }
        else if (country != null && checkMethod == true){
                String convertedCountry = mapForInputCountry.get(country.toLowercase());
                return convertedCountry;
        }
        return null;
        
            
    
    }
    
    /*
	* This method is used to determine billing address.
	*/
    public static string getBillingAddress(Asset assetObject) {
        String street = '';
        String city = '';
        String state = '';
        String postalCode = '';
        String checkCountry = '';
        String countryConverted = '';
        String billToAddress ='';
        string billToName = '';
        //check if bill to address is populated
        if (assetObject.Bill_To_Address__c != null) {
            countryConverted = convertingCountry(assetObject.Bill_To_Address__r.Country__c, true);           
            street = assetObject.Bill_To_Address__r.Street__c != null ? assetObject.Bill_To_Address__r.Street__c : '' ;
            city = assetObject.Bill_To_Address__r.City__c != null ? assetObject.Bill_To_Address__r.City__c : '' ;
            state = assetObject.Bill_To_Address__r.State__c != null ? assetObject.Bill_To_Address__r.State__c : '' ;
            postalCode = assetObject.Bill_To_Address__r.Zip_Postal_Code__c != null ? assetObject.Bill_To_Address__r.Zip_Postal_Code__c : '' ;
            checkCountry = countryConverted != null ? countryConverted.capitalize() : '' ;
            billToName = assetObject.Bill_To_Address__r.Name;
        } else if (assetObject.Bill_To_Account__c != null && assetObject.Bill_To_Account__r.Name != null) { //check if bill to account is populated
            countryConverted = convertingCountry(assetObject.Bill_To_Account__r.billingCountry, true);         
            street = assetObject.Bill_To_Account__r.billingstreet != null ? assetObject.Bill_To_Account__r.billingstreet : '' ;
            city = assetObject.Bill_To_Account__r.billingcity != null ? assetObject.Bill_To_Account__r.billingcity : '' ;
            state = assetObject.Bill_To_Account__r.billingstate != null ? assetObject.Bill_To_Account__r.billingstate : '' ;
            postalCode = assetObject.Bill_To_Account__r.billingPostalCode != null ? assetObject.Bill_To_Account__r.billingPostalCode : '' ;
            checkCountry = countryConverted != null ? countryConverted.capitalize() : '' ;
            billToName = assetObject.Bill_To_Account__r.Name;
        } else if (assetObject.AccountId != null && assetObject.Account.Name != null) { //check if account is populated
            system.debug('**assetObject.Account.billingCountry**' + assetObject.Account.billingCountry);
            countryConverted = convertingCountry(assetObject.Account.billingCountry, true);
            street = assetObject.Account.billingstreet != null ? assetObject.Account.billingstreet : '' ;
            city = assetObject.Account.billingcity != null ? assetObject.Account.billingcity : '' ;
            state = assetObject.Account.billingstate != null ? assetObject.Account.billingstate : '' ;
            postalCode = assetObject.Account.billingPostalCode != null ? assetObject.Account.billingPostalCode : '' ;
            checkCountry = countryConverted != null ? countryConverted.capitalize() : '' ;
            billToName = assetObject.Account.Name;
            System.debug('street+++++++++' + street);
            System.debug('city+++++++++' + city);
            System.debug('Postalcode+++++++++' + Postalcode);
            System.debug('state+++++++++' + state);
            System.debug('checkCountry+++++++++' + checkCountry);
            
        }
        billToAddress = street == '' ? '' : billToName + '\n' + street + '\n' + city + ' ' + state + ' ' + PostalCode + '\n' + checkCountry;
        return billToAddress;
    }
    public class AssetMemberWrapper{
    
        public string jsonBody; 
        public String accId;
        public String accJson;
    }
    
    
}