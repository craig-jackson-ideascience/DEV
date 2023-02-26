@isTest
public class getFoundationRecordTest {

    @isTest
    public static void test(){
        Project__c obj = new Project__c(
        name='Test Project',
        category__c ='MemberFunded',
        Slug__c ='test');
        insert obj;
        string foundationId = obj.Id;
        getFoundationRecord.getFoundationName(foundationId);
    }
    
}