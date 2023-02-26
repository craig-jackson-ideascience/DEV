@isTest
public class ScheduleAssetStatusUpdateTest {

    public static testmethod void test() {
    
        Account acc=new Account();
        acc.name='Testacc';
        insert acc;
        
        
        Contact con= new Contact();
        con.lastname = 'Test';
        con.accountid = acc.id;
        insert con; 
        
        Asset at=new Asset();
        at.name='test asset';
        at.contactid = con.id;
        at.accountid = acc.id;
        at.status='shipped';
        at.UsageEndDate=date.today().adddays(-20);
        insert at;
        
        ScheduleAssetStatusUpdate  sc=new ScheduleAssetStatusUpdate(); 
        sc.execute(null);
            
    }
    
}