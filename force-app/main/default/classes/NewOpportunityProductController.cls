/*
    THIS CLASS IS RUNNING BEHIND THE OVER-RIDDEN VIEW OF OPPORTUNITY PRODUCT CREATION
*/
Public Class NewOpportunityProductController{

    public String currentUserProfile;
    public String selectedType {get;set;}
    public String selectedCategory {get;set;}
    public String selectedProject {get;set;}
    public String selectedCurrency {get;set;}

    public String selectedSubCategory {get;set;}
    public String selectedProduct {get;set;}
    public String selectedTier {get;set;}
    public String selectedDescription {get;set;}
    public String selectedPrice {get;set;}
    public Boolean renderTier {get;set;}
    public List<ProductDetailsWrapper> prodDetailWrapper {get;set;}
    public ID opportunityID;   
    public Boolean displayError {get;set;}
    
    /*
    CONSTRUCTOR FOR INITIALIZATION
    */
    public NewOpportunityProductController(ApexPages.StandardController controller) {
               
        System.debug('____Recordtype___'+[SELECT id,name FROM Recordtype where sobjecttype='Opportunity']);
        
        prodDetailWrapper = new List<ProductDetailsWrapper>();
        opportunityID = apexpages.currentpage().getparameters().get('id');
        
        Opportunity op = new Opportunity();
        op = [Select Id,AccountID,Account.IsPersonAccount , StageName,RecordType.Name , isWon ,CurrencyIsoCode, pricebook2id from Opportunity where Id = :opportunityID];
        system.debug(op);
        
        //set the type basis opportunity recordtype
        selectedType = op.RecordType.Name;
        displayError = op.isWon;
        selectedCurrency = op.CurrencyIsoCode;
        System.debug('____opportunityID_________'+opportunityID);
        currentUserProfile = [SELECT id,name FROM Profile WHERE id=:userinfo.getProfileId() limit 1].name;
    }
    
    /* 
    GET ALL THE AVAILABLE OPPORTUNITY TYPES FROM THE CUSTOM SETTING
    */    
    Public List<SelectOption> getOpportunityTypes(){
        selectedDescription='';
        selectedPrice='';
        List<SelectOption> options = new List<SelectOption>();   
        System.debug('currentUserProfile :'+currentUserProfile);
        List<String> allowesType = getAllowedTypes(currentUserProfile);
        System.debug('allowesType :'+allowesType);
        options.add(new SelectOption('--None--','--None--'));
        for(String types : allowesType){
            options.add(new SelectOption(types,types));
        }
        
        return options;            
    }
    
    //METHOD THAT GETS ALLOWED OPPORTUNITY TYPES BASED ON CURRENT PROFILE
    public static List<String> getAllowedTypes(String currentUserProfile){
        System.debug('currentUserProfile: '+currentUserProfile);
         //GET TYPES ACCORDING TO PROFILE FROM CUSTOM SETTING
        Map<String, Profile_by_allowed_Opportunity_Type__c> profileByOpportunityCreationType = Profile_by_allowed_Opportunity_Type__c.getAll();
        System.debug('profileByOpportunityCreationType : '+profileByOpportunityCreationType);
        if(profileByOpportunityCreationType.containsKey(currentUserProfile)){
            System.debug('INSIDE CONTAINS KEY ');
            Profile_by_allowed_Opportunity_Type__c pao = profileByOpportunityCreationType.get(currentUserProfile);
            List<String> allowesType = pao.Allowed_Opportunity_Type__c.split(';');
            return allowesType;
        }else{
            return null;
        }
        
    }
    /* 
    PREPARE A LIST OF AVAILABLE PRODUCT CATEGORIES BASED ON CHOSEN TYPE WHETHER EVENT OR TRAINING
    */
    Public List<SelectOption> getProductCategories(){
        
        selectedDescription='';
        selectedPrice='';
        
        List<SelectOption> options = new List<SelectOption>();   
        AggregateResult[] groupedResults = getGroupedProductCategories(selectedType);
        System.debug('groupedResults :'+groupedResults);
        if(groupedResults != null){
            options.add(new SelectOption('--None--','--None--'));
            //GET ALLOWED TYPES HERE
            for(AggregateResult ar : groupedResults){
            
                String categ = String.valueOf(ar.get('Category__c'));
                options.add(new SelectOption(categ,categ));
            }
        }else{
            options.add(new SelectOption('--None--','--None--'));
        }
        return options;            
    }
    
    //THIS METHOD GETS GROUPED PRODUCT CATEGORIES
    public static AggregateResult[] getGroupedProductCategories(String selectedType){
        AggregateResult[] groupedResults;
        if(selectedType != null){

            if(selectedType == 'Event'){
                groupedResults = [SELECT Category__c FROM event__C WHERE (Status__c='Active' or Status__c='Planned') AND Category__c != null GROUP BY Category__c];   
            }
            
            if(selectedType == 'Training'){
                groupedResults = [SELECT Category__c FROM Training__c WHERE Status__c='Active' AND Category__c != null GROUP BY Category__c];   
            }
        } 
        return groupedResults;
    }
    /*
        PREAPARE A LIST OF PRODUCT SUB-CATEGORIES FOR EVENT TYPE
    */
    /*Public List<SelectOption> getProjectSubcategory(){
        
        System.debug('___subcategory_method_called___');
        
        List<SelectOption> options = new List<SelectOption>();   
        AggregateResult[] groupedResults;
                
        if(selectedType != null && selectedType == 'Event'){
            groupedResults = [SELECT Sub_Category__c FROM Product_Details__c WHERE Event__r.Status__c='Active' AND Event__c != null 
                            AND Event__r.Category__C =: selectedCategory AND Sub_Category__c != null GROUP BY Sub_Category__c ];
        }
        
        if(groupedResults != null){  
            options.add(new SelectOption('--None--','--None--'));
            System.debug('____groupedResults___'+groupedResults.size());
            //GET ALLOWED TYPES HERE
            for(AggregateResult ar : groupedResults){
                
                System.debug('___name_____'+ar.get('Sub_Category__c'));
                String subCategoryName = String.valueOf(ar.get('Sub_Category__c'));
                options.add(new SelectOption(subCategoryName,subCategoryName));
            }
        }else{
            options.add(new SelectOption('--None--','--None--'));
        }
        
        return options;
    }
    */
    
    /*
    FETCH PROJECTS/EVENTS/TRAINING BASED ON SELECTED TYPES AND CATEGORIES
    */
    Public List<SelectOption> getProjectsOrEvents(){
        System.debug('___Project_method_called___');
        List<SelectOption> options = new List<SelectOption>();   
        AggregateResult[] groupedResults = getGroupedProjectsOrEvents(selectedType,selectedCategory);
        System.debug('groupedResults :'+groupedResults);
        options.add(new SelectOption('--None--','--None--'));
        if(groupedResults != null){
            //GET ALLOWED TYPES HERE
            for(AggregateResult ar : groupedResults){
                
                System.debug('___name_____'+ar.get('Name'));
                String projectName = String.valueOf(ar.get('Name'));
                options.add(new SelectOption(projectName,projectName));
            }
        }
        return options;            
    }
    
    //THIS METHOD GETS GROUPED PROJECTS AND EVENTS
    public static AggregateResult[] getGroupedProjectsOrEvents(String selectedType,String selectedCategory){
        AggregateResult[] groupedResults;   
        if(selectedType != null){
            if(selectedType == 'Membership'){
                System.debug('_Inside__Memberhsip_');
                groupedResults = [SELECT Project__r.Name FROM Product_Details__c WHERE  
                                  (Project__r.Status__c='Active' or Project__r.Status__c='Planned') AND Project__r.Model__c INCLUDES('Membership') AND
                                  Products__r.IsActive = true AND Status__c = 'Active' GROUP BY Project__r.Name];   
            }else if(selectedType == 'Alternate Funding'){
                System.debug('_Inside__Funding_');
                Id recordTypeId = Schema.SObjectType.Product_Details__c.getRecordTypeInfosByDeveloperName().get('Alternate_Funding').getRecordTypeId();
                groupedResults = [SELECT Project__r.Name FROM Product_Details__c WHERE
                                  (Project__r.Status__c='Active' or Project__r.Status__c='Planned') AND RecordTypeId =: recordTypeId AND
                                  Products__r.IsActive = true AND Status__c = 'Active' GROUP BY Project__r.Name];
            }else if(selectedType == 'Event'){
                System.debug('_Inside__Event');
                groupedResults = [SELECT Event__r.Name FROM Product_Details__c WHERE 
                                  (Event__r.Status__c='Active' or Event__r.Status__c='Planned')
                                  AND Event__r.Category__c=:selectedCategory AND Products__r.IsActive = true 
                                  AND Status__c = 'Active'  GROUP BY Event__r.Name];   
            }            
        }
        return groupedResults;
        
    }
        
    
    /*****************CALL PRODUCT DETAILS METHOD*****************/
    Public void callProductDetails(){
        fetchProductDetails();
    }
    
    /*****************GET PRODUCT DETAILS ALONG WITH NAME, TIER, PRICE AND DESCRIPTION*****************/
    Public void fetchProductDetails(){
        
        prodDetailWrapper = getProdDetailWrapper(selectedType,selectedCategory,selectedProject,selectedCurrency);
    }
    public static List<ProductDetailsWrapper> getProdDetailWrapper(String selectedType,String selectedCategory,String selectedProject,String selectedCurrency){
        List<ProductDetailsWrapper> prodWrap = new List<ProductDetailsWrapper>();
        //trainWrapper = new List<TrainingWrapper>();
        
        System.debug('___I_am_called___');
        List<Product_details__c> prodDetails = new List<Product_details__c>();
        List<Product_details__c> trainingDetails = new List<Product_details__c>();
        
        System.debug('___I_am_called_with__'+selectedType+selectedCategory+selectedProject);
        
        if(selectedType != null){
        
            /*******************GET THE DATA*************************/
            System.debug('selectedCurrency' + selectedCurrency);
            if(selectedType == 'Membership'){
                prodDetails = [SELECT products__c,Products__r.name,Description__c,Tier__c,Start_Tier__c,End_Tier__c,Price__c,
                                NetSuite_Class__c, NS_Department__c, NS_Income_GL_Account__c, NS_Revenue_Schedule__c, NS_Deferred_Revenue_Account__c, Renewal_Type__c,
                                Netsuite_ID__c,project__c,Event__C,duration__c,Training__c , Number_of_Years_Required__c,Products__r.Type__c 
                                    FROM Product_details__c 
                                    WHERE Products__r.isactive=true AND status__c = 'Active' AND (Project__r.Status__c='Active' OR Project__r.Status__c='Planned') AND 
                                    Project__r.Model__c INCLUDES('Membership') AND Project__r.name=: selectedProject AND CurrencyIsoCode =: selectedCurrency]; 
            }else if(selectedType == 'Alternate Funding'){
                Id recordTypeId = Schema.SObjectType.Product_Details__c.getRecordTypeInfosByDeveloperName().get('Alternate_Funding').getRecordTypeId();
                prodDetails = [SELECT products__c,Products__r.name,Description__c,Tier__c,Start_Tier__c,End_Tier__c,Price__c,
                                NetSuite_Class__c, NS_Department__c, NS_Income_GL_Account__c, NS_Revenue_Schedule__c, NS_Deferred_Revenue_Account__c, Renewal_Type__c,
                                Netsuite_ID__c,project__c,Event__C,duration__c,Training__c , Number_of_Years_Required__c,Products__r.Type__c
                                    FROM Product_details__c
                                    WHERE Products__r.isactive=true AND status__c = 'Active' AND (Project__r.Status__c='Active' OR Project__r.Status__c='Planned') AND
                                    RecordTypeId =: recordTypeId AND Project__r.name=: selectedProject];
            }
            else if(selectedType == 'Event'){
                prodDetails = [SELECT Name, products__c,Products__r.name,Description__c,Tier__c,Start_Tier__c,End_Tier__c,Price__c,
                                NetSuite_Class__c, NS_Department__c, NS_Income_GL_Account__c, NS_Revenue_Schedule__c, NS_Deferred_Revenue_Account__c, Renewal_Type__c,
                                Netsuite_ID__c,project__c,Event__C,Duration__c,Training__c , Number_of_Years_Required__c,Products__r.Type__c 
                                    FROM Product_details__c 
                                    WHERE Products__r.isactive=true AND status__c = 'Active' AND (Event__r.Status__c='Active' OR Event__r.Status__c='Planned') AND Event__r.Category__C=:selectedCategory /*AND Sub_Category__c=:selectedsubCategory*/ AND Event__r.name=: selectedProject]; 
            }
            else if(selectedType == 'Training'){
                prodDetails = [SELECT products__c,Products__r.name,Products__r.Type__c,Description__c,Tier__c,Start_Tier__c,End_Tier__c,Price__c,
                                NetSuite_Class__c, NS_Department__c, NS_Income_GL_Account__c, NS_Revenue_Schedule__c, NS_Deferred_Revenue_Account__c,Renewal_Type__c,
                                Netsuite_ID__c,project__c,Event__C,duration__c,Training__c , Number_of_Years_Required__c,Products__r.StockKeepingUnit,
                               Training__r.Name,Training__r.StartDateTime__c,Training__r.Category__C
                                    FROM Product_details__c
                                    WHERE Products__r.isactive=true AND status__c = 'Active' AND Training__r.Status__c = 'Active' AND Training__r.Category__C=:selectedCategory]; 
            }
            
            System.debug('____proddetails____'+prodDetails);
            
            /*******************PREPARE THE WRAPPER*************************/
            if(prodDetails != null && !prodDetails.isEmpty()){
                system.debug('___inside_proddetails____');
                prodWrap.addAll(getProductDetailsWrapper(prodDetails));
            }
           
        }
         return prodWrap;
    }
    
    private static List<ProductDetailsWrapper> getProductDetailsWrapper(List<Product_details__c> prodDetails){
        List<ProductDetailsWrapper> wrapper = new List<ProductDetailsWrapper>();
        for(Product_details__c prod : prodDetails){
            ProductDetailsWrapper prodWrapper =new ProductDetailsWrapper(prod.id,prod.Products__r.name,prod.Description__c,prod.Tier__c,prod.Start_Tier__c,prod.End_Tier__c,
                                                  prod.Price__c,prod.duration__c,prod.products__c,prod.NetSuite_Class__c,prod.NS_Department__c,prod.NetSuite_ID__c,
                                                  prod.NS_Income_GL_Account__c,prod.NS_Revenue_Schedule__c , prod.NS_Deferred_Revenue_Account__c, prod.Number_of_Years_Required__c  
                                                  ,prod.project__c,prod.Event__c,prod.Training__c, prod.Renewal_type__c,prod.Products__r.Type__c == 'Bundle');
            if(prod.Training__c != null){
                prodWrapper.trainingName = prod.Training__r.Name;
                prodWrapper.productCode = prod.Products__r.StockKeepingUnit;
                prodWrapper.startDate = prod.Training__r.Category__C == 'Instructor-Led' && prod.Training__r.StartDateTime__c != null ?
                    prod.Training__r.StartDateTime__c.date():null;
            }
            if(prod.Event__c != null){
                prodWrapper.productDetailName = prod.Name;
            }

            wrapper.add(prodWrapper);
        }
        return wrapper;
    }
    /*************************CANCEL OLI CREATION**************************/
    public PageReference Cancel(){
        
        return new PageReference('/'+opportunityID);
    }
    
    /*************************SUBMIT OLI FOR CREATION**************************/
    public PageReference Submit(){
        insertOpportunityProducts(selectedType,prodDetailWrapper,opportunityID);
        return new PageReference('/'+opportunityID);
    } 
    public static void insertOpportunityProducts(String selectedType,List<ProductDetailsWrapper> prodDetailWrapper,String opportunityID){
        system.debug('______'+selectedType);
        //system.debug('______'+selectedCategory);
        //system.debug('______'+selectedProject);
        system.debug('___prodDetailWrapper___'+prodDetailWrapper);
        //system.debug('___trainWrapper___'+trainWrapper);
        
        Set<ID> productID = new Set<ID>();
        Set<ID> projectID = new Set<ID>();
        Set<ID> eventID = new Set<ID>();
        Set<ID> trainingID = new Set<ID>();
        Map<ID,ID> productIDtoPricebookEntryID = new Map<ID,ID>();
        List<Opportunitylineitem> oliToBeInserted = new List<Opportunitylineitem>();
        Map<id,Product2> productMap;
        Map<id,Project__c> projectMap;
        Map<id,Event__c> eventMap;
        Map<id,Training__c> trainingMap;
        Set<Id> bundles = new Set<Id>();
        Set<ID> bundledProducts = new Set<Id>();
        /**************IF OPPORTUNITY TYPE IS MEMBERSHIP OR EVENT*************/
        if(prodDetailWrapper != null && !prodDetailWrapper.isEmpty()){
            
            system.debug('___prodDetailWrapper____'+prodDetailWrapper);
            for(ProductDetailsWrapper pd : prodDetailWrapper){
                if(pd.selected == true){
                    productID.add(pd.productID);
                    if(pd.projID != null)
                        projectID.add(pd.projID);
                    if(pd.eventID != null)
                        eventID.add(pd.eventID);
                    if(pd.trainingID !=null)
                        trainingID.add(pd.trainingID);
                    if(pd.isBundle)
                        bundles.add(pd.productID);
                }
            }
            System.debug('bubndles=>' +bundles);
            //if it is a bundle,get bundled items
            if(!bundles.isEmpty()){
                for(Bundle_Product__c product : [SELECT Product__c from Bundle_Product__c WHERE Bundle__c IN:bundles]){
                    productID.add(product.Product__c);
                    bundledProducts.add(product.Product__c);
                }
             List<Product_details__c> productDetails = [SELECT products__c,Products__r.name,Products__r.Type__c,Description__c,Tier__c,Start_Tier__c,End_Tier__c,Price__c,
                                NetSuite_Class__c, NS_Department__c, NS_Income_GL_Account__c, NS_Revenue_Schedule__c, NS_Deferred_Revenue_Account__c,Renewal_Type__c,
                                Netsuite_ID__c,project__c,Event__C,duration__c,Training__c , Number_of_Years_Required__c
                                    FROM Product_details__c
                                    WHERE products__c IN:bundledProducts AND Products__r.isactive=true AND status__c = 'Active'];
                if(!productDetails.isEmpty()){
                    for(ProductDetailsWrapper wrapper :getProductDetailsWrapper(productDetails)){
                         wrapper.selected = true;
                    prodDetailWrapper.add(wrapper);
                    }
                }
            }
            string priceBookId;
           
            
            list<Opportunity> oppListForPriceBook = [select pricebook2Id,CurrencyIsoCode,Billing_Contact__c from Opportunity Where ID = : opportunityID];
            system.debug(oppListForPricebook);
             for(Opportunity oppObj : oppListForPriceBook){
                 if(oppObj.pricebook2Id != null){
                     priceBookId = oppObj.pricebook2Id;
                 }
                 
             }
            
            if(productID != null && !productID.isEmpty()){
                String currencyIsoCode = oppListForPriceBook[0].CurrencyIsoCode;
                String query = 'SELECT id,product2id,Pricebook2Id FROM PricebookEntry WHERE product2id IN:productID AND CurrencyISoCode =: currencyIsoCode  AND ISActive = TRUE ';
                query += priceBookId != null ?  'AND Pricebook2Id =: priceBookId' : 'AND pricebook2.isStandard=true';
                List<PricebookEntry> pricebookEntryList =Database.query(query);
                for(PricebookEntry pbe : pricebookEntryList){
                    productIDtoPricebookEntryID.put(pbe.product2id,pbe.id);
                }   
                /* if(priceBookId != null){
                     for(PricebookEntry pbe : [SELECT id,product2id,Pricebook2Id FROM PricebookEntry WHERE product2id IN:productID AND Pricebook2Id =: priceBookId  AND CurrencyISoCode =: oppListForPriceBook[0].CurrencyIsoCode AND ISActive = TRUE]){
                        productIDtoPricebookEntryID.put(pbe.product2id,pbe.id);
                    }   
                }else{
                    for(PricebookEntry pbe : [SELECT id,product2id,Pricebook2Id FROM PricebookEntry WHERE product2id IN:productID and pricebook2.isStandard=true  AND CurrencyISoCode =: oppListForPriceBook[0].CurrencyIsoCode AND ISActive = TRUE]){
                        productIDtoPricebookEntryID.put(pbe.product2id,pbe.id);
                    }
                } */
                
                productMap = new Map<Id,Product2>([SELECT id,tax_class__c FROM Product2 WHERE id =: productID]);
            }
            
            if(projectID != null && !projectID.isEmpty()){
                projectMap = new Map<ID,Project__C>([SELECT id,name,Membership_Roles_Not_Required__c,Status__c,Payment_Frequency__c, Category__c,LF_Membership_Required__c FROM Project__c WHERE id=: projectID]);
            }
            if(eventID != null && !eventID.isEmpty()){
                eventMap = new Map<ID,Event__c>([SELECT id,Start_date__c,Status__c,name,End_date__c,BillFromProject__c FROM Event__c WHERE id=: eventID]);
            }
            if(trainingID !=null && !trainingID.isEmpty()){
                trainingMap = new Map<ID,Training__c>([Select id,name,Category__c,Status__c,StartDateTime__c,End_DateTime__c FROM Training__c WHERE id=:trainingID]);
            } 
            
            system.debug('*prodDetailWrapper*'+prodDetailWrapper);
            for(ProductDetailsWrapper pd : prodDetailWrapper){
                system.debug('pocessing detail==>'+pd.productName);
                if(pd.selected == true && productIDtoPricebookEntryID.get(pd.productID) != null){
                    
                    System.debug('____id____'+pd.productID);
                    System.debug('___pd_____'+pd);
                    
                    Opportunitylineitem oli = new Opportunitylineitem();
                    
                    //POPULATE STANDARD FIELDS
                    oli.Opportunityid = opportunityID;
                    oli.UnitPrice = pd.productPrice;
                    oli.Quantity = 1;
                    system.debug('**productIDtoPricebookEntryID.get(pd.productID)**'+productIDtoPricebookEntryID.get(pd.productID));
                    oli.PricebookEntryId = productIDtoPricebookEntryID.get(pd.productID);
                    
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
                                        
                    //POPULATE CUSTOM FIELDS
                    oli.Product_Details__c = pd.productDetailID;
                    oli.description__c = pd.productDescription;
                    oli.End_Tier__c = pd.productEndTier;
                    oli.NetSuite_Class__c = pd.NetSuiteClass;
                    oli.NetSuite_Department__c =mapForDepartment.get(pd.NetSuiteDepartment);
                    oli.NetSuite_ID__c = pd.NetSuiteID;
                    oli.NetSuite_Income_GL_Account__c = mapForIncomeGLAccount.get(pd.NetSuiteIncomeGLAccount);
                    oli.NetSuite_Revenue_Schedule__c =mapForRevSchedule.get(pd.NetSuiteRevenueSchedule);
                    oli.NetSuite_Deferred_Revenue_Account__c = mapForRevAccount.get(pd.NetSuiteDeferredRevenueAccount);
                    //FIXME - Add NetSuite Location to PD -> OLI mapping

                    if(pd.NumberYearsRequired != null)
                        oli.Number_of_Years_Required__c = Integer.valueOf(pd.NumberYearsRequired);
                    
                    //PROJECT LOOKUP
                    oli.Projects__c = pd.projID;
                    oli.Renewal_type__c = pd.renewalType;
                    
                    //TRAINING LOOKUP
                    oli.Training__c = pd.trainingID;
                    
                    //EVENT LOOKUP
                    oli.Event__c = pd.eventID;
                    
                    oli.Skip_NetSuite_Sync__c = pd.isBundle;
                    
                    //FOR TRAINING
                    oli.Duration__c = pd.productDuration;
                    System.debug('___project__id__'+pd.projID);
                    System.debug('__projMap___'+projectMap);
                    
                    //POPULATE SPECIFIC FIELDS BASED ON PROJECT
                    if(pd.projID != null && projectMap.containsKey(pd.projID)){
                        oli.Project__c = projectMap.get(pd.projID).name;
                        oli.Project_Event_Status__c = projectMap.get(pd.projID).status__c;
                        System.debug('_____PROJECT_EVENT___STATUS'+projectMap.get(pd.projID).status__c);
                        //oli.Bill_From__c = string.valueOf(projectMap.get(pd.projID).id);
                        oli.PaymentFrequency__c = projectMap.get(pd.projID).Payment_Frequency__c;
                        
                        //IF MEMBERSHIP IS OF TYPE DIRECTED FUNDS
                        if(projectMap.get(pd.projID).LF_Membership_Required__c)
                            oli.Required_Active_LF_Membership__c = true;

                        if(projectMap.get(pd.projID).Membership_Roles_Not_Required__c){
                            oli.Skip_NetSuite_Sync__c = true;
                        }
                    }
                    
                    //POPULATE SPECIFIC FIELDS BASED ON EVENT
                    if(pd.eventID != null && eventMap.containsKey(pd.eventID)){
                        oli.Events__c = eventMap.get(pd.eventID).name;
                        oli.Project_Event_Status__c = eventMap.get(pd.eventID).status__c;
                        oli.Start_date__c = eventMap.get(pd.eventID).Start_date__c;
                        oli.end_date__c = eventMap.get(pd.eventID).end_date__c;
                        oli.Billfrom_ID__c= string.ValueOf(eventMap.get(pd.eventID).BillFromProject__c);

                    }
                    
                    //POPULATE SPECIFIC FIELDS BASED ON TRAINING
                    if(pd.trainingID != null && trainingmap.containsKey(pd.trainingID)){
                        oli.Trainings__c = trainingmap.get(pd.trainingID).name;
                        oli.Bill_From__c = 'The Linux Foundation';
                        oli.Billfrom_ID__c = Utility.linuxFoundationId;
						oli.Billing_Contact__c = oppListForPriceBook[0].Billing_Contact__c;
                        System.debug('_______TRAININGNAME____'+oli.Trainings__c);
                        
       					//if training category is Instructor-Led, it will populate the start and End Date of training
                        if(trainingmap.get(pd.trainingID).Category__c == 'Instructor-Led'){
                            oli.Start_Date__c = trainingmap.get(pd.trainingID).StartDateTime__c.date();
                            oli.End_Date__c = trainingmap.get(pd.trainingID).End_DateTime__c.date();
                        }
                    }
                    
                    oli.Start_Tier__c = pd.productStartTier;
                    oli.Tax_Class__c = productMap.get(pd.productID).tax_class__c;
                    oli.Tier__c = pd.productTier;
                    //oli.year__c = String.valueOf(productMap.get(pd.productID).year__c);
                    //oli.year__c = productMap.get(pd.productID).year__c;
                    oli.type__c=selectedType;
                    oliToBeInserted.add(oli);
                    System.debug('____OLI TO BE INSERTED LIST_____'+oliToBeInserted);
                    
                }
            }
            System.debug('___oliToBeInserted__before_insert______'+oliToBeInserted);   
            if(oliToBeInserted !=null && !oliToBeInserted.isEmpty())
                insert oliToBeInserted;
            
            System.debug('___oliToBeInserted________'+oliToBeInserted);  
        }
    }
    /******************WRAPPER CLASS***************/
    Public Class ProductDetailsWrapper{
    
        @AuraEnabled public String productDetailID               {get;set;}
        @AuraEnabled public String productDetailName               {get;set;}
        @AuraEnabled public String productName                   {get;set;}
        @AuraEnabled public String productDescription            {get;set;}
        @AuraEnabled public String productTier                   {get;set;}
        @AuraEnabled public Decimal productStartTier             {get;set;}
        @AuraEnabled public Decimal productEndTier               {get;set;}
        @AuraEnabled public Decimal productPrice                 {get;set;}
        @AuraEnabled public String productDuration               {get;set;}
        @AuraEnabled public Boolean selected                     {get;set;}
        @AuraEnabled public ID productID                         {get;set;}
        @AuraEnabled public String NetSuiteClass                 {get;set;}
        @AuraEnabled public String NetSuiteDepartment            {get;set;}
        @AuraEnabled public String NetSuiteID                    {get;set;}
        @AuraEnabled public String NetSuiteIncomeGLAccount       {get;set;}
        @AuraEnabled public String NetSuiteRevenueSchedule       {get;set;}
        @AuraEnabled public String NetSuiteDeferredRevenueAccount {get;set;}
        @AuraEnabled public String NumberYearsRequired           {get;set;}
        @AuraEnabled public ID projID                            {get;set;}
        @AuraEnabled public ID eventID                           {get;set;}
        @AuraEnabled public ID trainingID                        {get;set;}
        @AuraEnabled public String renewalType                   {get;set;}
        @AuraEnabled public Boolean isBundle					 {get;set;}
        @AuraEnabled public String trainingName                   {get;set;}
        @AuraEnabled public String productCode                   {get;set;}
        @AuraEnabled public Date startDate                       {get;set;}
        
        
        public ProductDetailsWrapper(ID prodDetailID,String prodname,String prodDesc,String prodTier,Decimal startTier,Decimal endTier,
                Decimal prodPrice,String duration, ID prodID,String NetSuiteCls,String NetSuiteDpt,String NsID,String NetSuiteIncomeGLAcc,
                String NetSuiteRevenueSch,String NetSuiteDeferredRevenue,String yearsrequired,ID project,ID event,ID trainID,String renwlType,Boolean isBundle){

        
            productDetailID = prodDetailID;
            selected = false;
            productPrice = prodPrice;
            productDuration = duration;
            productEndTier = endTier;
            productStartTier = startTier;
            productTier = prodTier;
            productDescription = prodDesc;
            productName = prodname;
            productID = prodID;
            NetSuiteClass = NetSuiteCls;
            NetSuiteDepartment = NetSuiteDpt;
            NetSuiteID = NsID;
            NetSuiteIncomeGLAccount = NetSuiteIncomeGLAcc;
            NetSuiteRevenueSchedule = NetSuiteRevenueSch;
            NetSuiteDeferredRevenueAccount = NetSuiteDeferredRevenue;
            NumberYearsRequired = yearsrequired;
            projID = project;
            eventID = event;
            trainingID = trainID;
            renewalType = renwlType;
            this.isBundle = isBundle;
        }
    }
    
   
}