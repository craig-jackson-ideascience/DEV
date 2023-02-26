//Test Class For - CouponCodeTH Class
@isTest
public class CouponCodeTH_Test {
    
    //Method to create testdata
    @testSetup
    public static void createTestData(){
        //project
        Project__c project= new Project__c(Name='TestProject', Category__c = 'Directed fund', Slug__c='testproj');
        insert project;
        
        //campaign
        Campaign C1 = new Campaign();
        C1.Name ='Test Subscription Center';
        C1.Description ='Test for Email Opt Out';
        C1.Project__c = project.Id;
        C1.Type ='Subscription Center';
        C1.Status ='In Progress';
        C1.StartDate = Date.today();
        C1.IsActive = true;
        C1.Add_to_Subscription_Center__c = true;
        C1.Technology__c ='System Administration';
        insert C1;
        
        CampaignMemberStatus ms1= new CampaignMemberStatus();
        ms1.CampaignId = C1.Id;
        ms1.Label = 'Subscribed';
        ms1.SortOrder = 3;
        insert ms1;
        
        CampaignMemberStatus ms2 = new CampaignMemberStatus();
        ms2.CampaignId = C1.Id;
        ms2.Label = 'Unsubscribed';
        ms2.SortOrder = 4;
        insert ms2;
    }
    
    //Test Method for validateCouponCodeForDuplicate
    @isTest private static void validateCouponCodeForDuplicate_Test(){
        Campaign campaign = [SELECT Id FROM Campaign LIMIT 1];
        campaign.Thirdparty_Coupon__c = true;
        update campaign;
        
        List<Coupon_Code__c> couponCodeList = new List<Coupon_Code__c>();
        for(Integer i=0;i<=1;i++){
            Coupon_Code__c couponCode = new Coupon_Code__c(Name='TestCoupon123',
                                                           Expiration_Date__c=System.today()+1,
                                                           Campaign_Name__c=campaign.Id);
            couponCodeList.add(couponCode);
        }
        Test.startTest();
        try{
            Database.insert(couponCodeList,false);
        }catch(Exception e){
            
        }
        
        Test.StopTest();
        
        System.assertEquals(1,[SELECT Id FROM Coupon_Code__c 
                               WHERE Campaign_name__c=:campaign.Id].size());
    }
    
    /*Test Method for other methods of trigger handler class as there coverage is based on events 
     * and for now we only have before insert event for couponcode trigger hence covering the other methods in this way
    */
    @isTest
    public static void otherMethods_Test(){
        Map<id, SObject> newMap = new Map<id, SObject>();
        Map<id, SObject> oldMap = new Map<id, SObject>();
        CouponCodeTH.BeforeUpdate(newMap,oldMap);
        CouponCodeTH.BeforeDelete(oldMap);
        CouponCodeTH.AfterInsert(newMap);
        CouponCodeTH.AfterUpdate(newMap,oldMap);
        CouponCodeTH.AfterDelete(oldMap);
        CouponCodeTH.AfterUnDelete(newMap);
    }
    
}