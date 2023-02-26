public class AddOpportunityProductController {
    public static final String LABEL = 'label';
    public static final String VALUE = 'value';
    
    //THIS METHOD GETS THE OPPORTUNITY TYPES BASED ON THE PROFILE
    @AuraEnabled
    public static Map<String, String> getOpportunityTypes(String opportunityId){
        System.debug('opportunityId :'+opportunityId);
        Opportunity opportunity = [Select Id,AccountID,CurrencyIsoCode,Account.IsPersonAccount , StageName,RecordType.Name , isWon , Pricebook2id from Opportunity WHERE Id = :opportunityId];
        System.debug('opportunity :'+opportunity);
        String currentUserProfile = [SELECT id,name FROM Profile WHERE id=:userinfo.getProfileId() limit 1].name;
        System.debug('currentUserProfile :'+currentUserProfile);
        Map<String, String> responseMap = new Map<string,string>();
        responseMap.put('OpportunityTypes', JSON.serialize(getOpportunityTypesHelper(currentUserProfile)));
        system.debug('responseMap--->'+responseMap);
        responseMap.put('OpportunityRecordType',opportunity.RecordType.Name.toLowerCase().contains('training') ? 'Training':opportunity.RecordType.Name);
        String isWon = opportunity.IsWon ? 'true' : 'false';
        responseMap.put('isWon',isWon);
        responseMap.put('Currency',opportunity.CurrencyIsoCode);

        return responseMap; 
    }
    
    //HELPER METHOD FOR getOpportunityTypes
    private static List<Map<String, String>> getOpportunityTypesHelper(String currentUserProfile){
        List<Map<String, String>> opportunityTypes = new List<Map<String, String>>();
        //Get Allowed Opportunity Types
        List<String> allowedType = NewOpportunityProductController.getAllowedTypes(currentUserProfile);
        opportunityTypes.add(new Map<String, String> {LABEL => '--None--', VALUE => '--None--'});
        for(String types : allowedType){
            opportunityTypes.add(new Map<String, String> {LABEL => types, VALUE => types});
        }
        return opportunityTypes;
    }
    
    //THIS METHODS GETS PRODUCT CATEGORIES AND PROJECT/EVENTS BASED ON THE SELECTED PRODUCT TYPE
    @AuraEnabled
    public static Map<String,String> getProductCategoriesAndProjects(String selectedProductType,String selectedProductCategory){
        Map<String, String> responseMap = new Map<string,string>();
        responseMap.put('ProductCategories', JSON.serialize(getProductCategories(selectedProductType)));
        responseMap.put('ProjectsOrEvents', JSON.serialize(getProjectsOrEvents(selectedProductType,selectedProductCategory)));
        return responseMap;
    }
    
    //HELPER METHOD FOR GETTING PRODUCT CATEGORIES BASED ON SELECTED PRODUCT TYPE
    private static List<Map<String,String>> getProductCategories(String selectedProductType){
        System.debug('Product Categories selectedProductType :'+selectedProductType);
        List<Map<String, String>> productCategories = new List<Map<String, String>>();
        AggregateResult[] groupedResults = NewOpportunityProductController.getGroupedProductCategories(selectedProductType);
        System.debug('groupedResults :'+groupedResults);
        productCategories.add(new Map<String, String> {LABEL => '--None--', VALUE => '--None--'});
        if(groupedResults != null && groupedResults.size()>0){
            for(AggregateResult ar : groupedResults){
                String category = String.valueOf(ar.get('Category__c'));
                productCategories.add(new Map<String, String> {LABEL => category, VALUE => category});
            }
        }
        System.debug('productCategories :'+productCategories);
        return productCategories;
    }
    
    //HELPER METHOD FOR GETTING PROJECTS OR EVENTS BASED ON SELECTED PRODUCT TYPE
    private static List<Map<String,String>> getProjectsOrEvents(String selectedProductType,String selectedProductCategory){
        System.debug('ProjectsOrEvents selectedProductType:'+selectedProductType);
        System.debug('ProjectsOrEvents selectedProductCategory:'+selectedProductCategory);
        List<Map<String, String>> projectsOrEvents = new List<Map<String, String>>();
        AggregateResult[] groupedResults = NewOpportunityProductController.getGroupedProjectsOrEvents(selectedProductType,selectedProductCategory);
        System.debug('ProjectsOrEvents groupedResults :'+groupedResults);
        projectsOrEvents.add(new Map<String, String> {LABEL => '--None--', VALUE => '--None--'});
        if(groupedResults != null && groupedResults.size()>0){
            for(AggregateResult ar : groupedResults){
                String name = String.valueOf(ar.get('Name'));
                projectsOrEvents.add(new Map<String, String> {LABEL => name, VALUE => name});
            }
        }
        System.debug('projectsOrEvents :'+projectsOrEvents);
        return projectsOrEvents;
    }
    
    //THIS METHOD RETURNS PRODUCT DETAIL WRAPPER
    @AuraEnabled
    public static List<NewOpportunityProductController.ProductDetailsWrapper> getProducts(String selectedProductType,String selectedProductCategory,String selectedProjectOrEvent,String selectedCurrency){
        System.debug('selectedProductType :'+selectedProductType);
        System.debug('selectedProductCategory :'+selectedProductCategory);
        System.debug('selectedProjectOrEvent :'+selectedProjectOrEvent);
        return NewOpportunityProductController.getProdDetailWrapper(selectedProductType,selectedProductCategory,selectedProjectOrEvent,selectedCurrency);
    }
    
    //THIS METHOD INSERTS PRODUCTS
    @AuraEnabled
    public static void insertProducts(String selectedProductType,String opportunityId,String productDetailWrapperJSON){
        System.debug('selectedProductType :'+selectedProductType);
        System.debug('opportunityId :'+opportunityId);
        System.debug('productDetailWrapperJSON :'+productDetailWrapperJSON);
        List<NewOpportunityProductController.ProductDetailsWrapper> productDetailWrapper = (List<NewOpportunityProductController.ProductDetailsWrapper>)JSON.deserialize(productDetailWrapperJSON, List<NewOpportunityProductController.ProductDetailsWrapper>.class);
        NewOpportunityProductController.insertOpportunityProducts(selectedProductType,productDetailWrapper,opportunityId);
    }
    
    //THIS METHOD RETURNS RECORD TYPE ID OF THE SELECTED PROJECT
    @AuraEnabled
    public static string getProjectCategory(String selectedProjectOrEvent){
        String query = 'SELECT id,name,Category__c FROM Project__c WHERE name in (\'' + selectedProjectOrEvent+ '\')';
        List<Project__c> projects = Database.query(query);
        return projects[0].Category__c;
    }
    
    @AuraEnabled
    public static void insertSubscriptionProducts(Integer noOfCertification,Decimal OppAmount,Id opportunityID,String productDetailWrapperJSON,String selectedCategory/*,Date endDate*/){  // commented SFDC-1827      
        System.debug('opportunityId :'+opportunityId);
        System.debug('productDetailWrapperJSON :'+productDetailWrapperJSON);
        List<NewOpportunityProductController.ProductDetailsWrapper> productDetailWrapper = (List<NewOpportunityProductController.ProductDetailsWrapper>)JSON.deserialize(productDetailWrapperJSON, List<NewOpportunityProductController.ProductDetailsWrapper>.class);
        AddSubscriptionController.addSubscriptionProducts(noOfCertification,OppAmount,opportunityID,productDetailWrapper,selectedCategory/*,endDate*/);
    }
    
}