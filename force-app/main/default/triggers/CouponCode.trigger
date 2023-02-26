//Trigger for Coupon_Code__c Object
trigger CouponCode on Coupon_Code__c (before insert){
    TriggerDispatcher.run(new CouponCodeTH());
}