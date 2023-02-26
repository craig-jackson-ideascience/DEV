public class AddSubscriptionController {
    
    @AuraEnabled
    public static void addSubscriptionProducts(Integer noOfCertification,Decimal OppAmount,Id opportunityID,List<NewOpportunityProductController.ProductDetailsWrapper> prodDetailWrapper,String selectedCategory/*,Date endDate*/){
        Decimal CertificationAmount = 0;
        Decimal ELearningAmount =0;
        Decimal InstructorLedAmount =0;
        Integer quantity = 1;
        Integer eLearningQuantity = 1;
        if(selectedCategory == 'Subscription'){
            CertificationAmount = 200*noOfCertification ;
            quantity = noOfCertification;
            ELearningAmount = OppAmount-CertificationAmount;
        }
        system.debug('SelectedCategory=>' + selectedCategory);
        Map<Id,Set<String>> productCategoryByBundle = new Map<Id,Set<String>>();
        Opportunity opp = [SELECT Id,CloseDate,Billing_Contact__c FROM Opportunity WHERE ID=:opportunityID];
        List<OpportunityLineItem> items = new List<OpportunityLineItem>();
        Map<String,Product_Details__c> productDetailsByName =productDetailHelper(prodDetailWrapper);
        if(selectedCategory == 'Bundle'){
            productCategoryByBundle = checkBundleProducts(prodDetailWrapper);
        }
        System.debug('productDetailsByName' + productCategoryByBundle);
        String parentId = ''; 
        String parentName = '';
        Boolean IsFutureProductAdded = false;
        for(NewOpportunityProductController.ProductDetailsWrapper wrapper : prodDetailWrapper){
            if(wrapper.selected){
                //Added by priyesh @cloudroute to check whether Future Training product is added
                IsFutureProductAdded = wrapper.productName.contains('Future') && !IsFutureProductAdded ? true : false;

                parentId =wrapper.productID;
                parentName=wrapper.productName;
                items.add(oppLineItemHelper(opp,productDetailsByName.get(wrapper.productName),0,wrapper.productName,1,'',true/*,endDate*/));
            }
        }
        System.debug('Parent=>'+ parentId);
        if(selectedCategory == 'Bundle'){
            Set<String> productTypes = productCategoryByBundle.containskey((Id)parentId) ? productCategoryByBundle.get((Id)parentId) : new Set<String>();
            System.debug('Product Types=>'+ productTypes);
            System.debug('IsFutureProductAdded: ' + IsFutureProductAdded);
            //Added by priyesh @cloudroute to divide amount by 3 if Future Training product is added
            if(IsFutureProductAdded){
                CertificationAmount =  OppAmount/3;
                ELearningAmount = OppAmount/3;
                InstructorLedAmount = OppAmount/3;
            }else if(productTypes.contains('Certification') && productTypes.contains('E-Learning') ){
                CertificationAmount =  OppAmount/2;
                ELearningAmount = OppAmount/2;
            }else if(productTypes.contains('Certification')){
                CertificationAmount =  OppAmount;
            }else if(productTypes.contains('E-Learning')){
                ELearningAmount = OppAmount;
            }else{
                CertificationAmount =  OppAmount/2;
                ELearningAmount = OppAmount/2; 
            }
        }
        if(selectedCategory == 'Subscription' || CertificationAmount !=0){
            OpportunityLineItem oppLineItem = oppLineItemHelper(opp,productDetailsByName.get('Certification'),CertificationAmount,'Certification',quantity,parentId,false/*,endDate*/);
            if(selectedCategory == 'Bundle'){
                oppLineItem.description__c =productDetailsByName.get(parentName).Products__r.Corporate_Product_Description__c;
            }
            items.add(oppLineItem);
        }
        if(selectedCategory == 'Subscription' || ELearningAmount !=0){
             OpportunityLineItem oppLineItem = oppLineItemHelper(opp,productDetailsByName.get('E-Learning'),ELearningAmount,'E-Learning',eLearningQuantity,parentId,false/*,endDate*/);
            if(selectedCategory == 'Bundle'){
                oppLineItem.description__c =productDetailsByName.get(parentName).Products__r.Corporate_Product_Description__c;
            }
            items.add(oppLineItem);
        }
        //Added by priyesh @cloudroute to add the Instructor-Led product if Future Training is added
        if(IsFutureProductAdded && selectedCategory == 'Bundle' && InstructorLedAmount !=0){
             OpportunityLineItem oppLineItem = oppLineItemHelper(opp,productDetailsByName.get('Instructor-Led'),InstructorLedAmount,'Instructor-Led',quantity,parentId,false/*,endDate*/);
            oppLineItem.description__c =productDetailsByName.get(parentName).Products__r.Corporate_Product_Description__c;
            System.debug('oppLineItem for Future prod IL: ' + oppLineItem);
            items.add(oppLineItem);
        }
        insert items;
        
    }    
    
    //this checks what type of products does bundle has
    private static  Map<Id,Set<String>> checkBundleProducts(List<NewOpportunityProductController.ProductDetailsWrapper> prodDetailWrapper){
        Set<Id> bundleIds = new Set<Id>();
        for(NewOpportunityProductController.ProductDetailsWrapper wrapper : prodDetailWrapper){
            System.debug('wrapper: ' + wrapper);
            if(wrapper.selected){
                bundleIds.add(wrapper.productID);
            }
        }
        Map<Id,Set<String>> productCategoryByBundle = new Map<Id,Set<String>>();
        System.debug('bundleIds: ' + bundleIds);
        for(Bundle_Product__c bundleProduct : [SELECT Id,Product__c,Product__r.Type__c,Bundle__c FROM Bundle_Product__c WHERE Bundle__c=:bundleIds]){
            System.debug('bundleProduct: ' + bundleProduct);
            if(!productCategoryByBundle.containsKey(bundleProduct.Bundle__c)){
                productCategoryByBundle.put(bundleProduct.Bundle__c,new Set<String>());
            }
            productCategoryByBundle.get(bundleProduct.Bundle__c).add(bundleProduct.Product__r.Type__c);
        }
        return productCategoryByBundle;
    }
    
    private static Map<String,Product_Details__c> productDetailHelper( List<NewOpportunityProductController.ProductDetailsWrapper> prodDetailWrapper){
        Set<Id> trainingIDs = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Map<String,Product_Details__c> productDetailsByName = new Map<String,Product_Details__c>();
        for(NewOpportunityProductController.ProductDetailsWrapper wrapper : prodDetailWrapper){
            System.debug('wrapper PD: ' + wrapper);
            if(wrapper.selected){
                trainingIDs.add(wrapper.trainingID);
                productIds.add(wrapper.productDetailID);
            }
        }        
        if(!trainingIDs.isEmpty()){
            productDetailsByName =getProductDetails(trainingIDs,productIds);
        }
        return productDetailsByName;
    }
    
     private static Map<String,Product_Details__c> getProductDetails(Set<Id> trainingId,Set<Id> productDetailID){
        Map<String,Product_Details__c> productDetailsByName = new Map<String,Product_Details__c>();
        List<Product_Details__c> productDetails = [SELECT ID,Training__c,Training__r.Name,Products__c,Products__r.Name,
                                                   Products__r.Corporate_Product_Description__c,Description__c,
                                                   NetSuite_Class__c,NS_Department__c,NS_Income_GL_Account__c,NS_Deferred_Revenue_Account__c,
                                                   NS_Revenue_Schedule__c,Netsuite_ID__c,Price__c FROM Product_Details__c
                                                   WHERE Training__c =:trainingId AND (ID IN:productDetailID OR Products__r.Name IN ('E-Learning','Certification','Instructor-Led'))];
        for(Product_Details__c prodDetail : productDetails){
            System.debug('prodDetail: ' + prodDetail);
            productDetailsByName.put(prodDetail.Products__r.Name,prodDetail);
        }
        
        return productDetailsByName;
    }
    
    private static OpportunityLineItem oppLineItemHelper(Opportunity opp,Product_Details__c productDetail,Decimal Amount,String productName,Integer quantity,String prodDetail,Boolean skip/*,Date endDate*/){
        System.debug('productName: ' + productName);
        System.debug('productDetail: ' + productDetail);
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.Opportunityid = opp.Id;
        oppLineItem.TotalPrice = Amount;
        oppLineItem.Quantity = quantity;
        oppLineItem.Billing_Contact__c = opp.Billing_Contact__c;
        oppLineItem.PricebookEntryId = [SELECT ID FROM PriceBookEntry WHERE PRODuct2.Name = :productName LIMIT 1].ID;
        oppLineItem.Product_Details__c = productDetail.Id;
        oppLineItem.description__c =productDetail.Description__c;        
        oppLineItem.NetSuite_Class__c =productDetail.NetSuite_Class__c;
        oppLineItem.NetSuite_Department__c =productDetail.NS_Department__c;
        oppLineItem.NetSuite_ID__c =productDetail.Netsuite_ID__c;
        oppLineItem.NetSuite_Income_GL_Account__c = productDetail.NS_Income_GL_Account__c;
        oppLineItem.NetSuite_Revenue_Schedule__c = productDetail.NS_Revenue_Schedule__c;
        oppLineItem.NetSuite_Deferred_Revenue_Account__c = productDetail.NS_Deferred_Revenue_Account__c;
        oppLineItem.Training__c = productDetail.Training__c;
        oppLineItem.Bill_From__c = 'The Linux Foundation';
        oppLineItem.Billfrom_ID__c = Utility.linuxFoundationId;
        oppLineItem.Trainings__c = productDetail.Training__r.name;
        //oppLineItem.Start_Date__c = opp.CloseDate;
        //oppLineItem.End_Date__c = endDate;
        oppLineItem.Skip_NetSuite_Sync__c = skip;
        oppLineItem.Type__c = 'Training';
        if(String.isNotBlank(prodDetail))
            oppLineItem.Parent_Product__c = prodDetail;

        System.debug('oppLineItem: ' + oppLineItem);
        return oppLineItem;
    }
    
}