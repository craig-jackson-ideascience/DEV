////////// TEST CLASS - TestProductDetail_Trigger /////////

trigger ProductDetail_Trigger on Product_Details__c (before insert, after insert, after update) {
    
    ProductDetail_Handler handler = new ProductDetail_Handler();
    
    if(trigger.isBefore && trigger.isInsert){
        handler.beforeInsert(Trigger.New);
    }
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        handler.afterInsertUpdated(Trigger.New);
    }

}