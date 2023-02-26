/* 
 * TriggerHandler for CouponCode Trigger
 * Test Class - CouponCodeTH_Test
 */ 

public class CouponCodeTH implements ITriggerHandler {
    public static void BeforeInsert(List<SObject> triggerNew){
        //call before insert actions
        //Call Method to restrict insertion of duplicateCodes in a single transaction
        validateCouponCodeForDuplicate((List<Coupon_code__c>) triggerNew);
    }
    public static void BeforeUpdate(Map<id, SObject> newMap, Map<id, SObject> oldMap){}
    public static void BeforeDelete(Map<Id, Sobject> oldMap){}
    public static void AfterInsert(Map<id, SObject> newMap){}
    public static void AfterUpdate(Map<id, SObject> newMap, Map<id, SObject> oldMap){}
    public static void AfterDelete(Map<Id, Sobject> oldMap){}
    public static void AfterUnDelete(Map<id, SObject> newMap){}
    public Boolean IsDisabled(){
		return false;
	}
    
    /*Validation Rule -For Duplicate Coupon codes check with the existing Coupon Codes in system
     * Trigger-For Duplicate codes check in single transaction i.e they are yet not in system
     */ 
    //Call Method to restrict insertion of duplicateCodes in a single transaction
    public static void validateCouponCodeForDuplicate(List<Coupon_Code__c> newList){
        Set<String> couponCodesSet = new Set<String>();
        
        //Iterate
        for (Coupon_Code__c couponCodeObj : newList) {
            if(couponCodeObj.Name != null){
                //if set not contains the code then add it to set
                if(!couponCodesSet.contains(couponCodeObj.Name)){
                    couponCodesSet.add(couponCodeObj.Name);
                }else{
                    //if set contains the code that means it is a duplicate hence throw error
                    couponCodeObj.addError('This Coupon Code is already present.'); 
                }
            }
        }
    }
   
}