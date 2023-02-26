public class ProductDetail_Handler{
    
    ProductDetail_Action action = new ProductDetail_Action();
    
    public void beforeInsert(List<Product_Details__c> incomingProductDetails){
    
        // When Product Detail is inserted in association with Project/Event/Training object, 
        // then fetch netsuite detail from associated Project/Event/Training
        // and update netsuite fields on Product Detail object
        action.populateNetSuiteFields(incomingProductDetails);
    }
     public void afterInsertUpdated(List<Product_Details__c> productDetails){
            
        action.sendEmailtoEvents(productDetails);
    }
}