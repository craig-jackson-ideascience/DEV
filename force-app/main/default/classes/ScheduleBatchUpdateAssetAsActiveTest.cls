@isTest
public class ScheduleBatchUpdateAssetAsActiveTest {

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
        at.UsageEndDate = system.Today()+10;
        at.InstallDate = system.Today()-10;
        at.status='Purchased';
        at.InstallDate=date.today();
        insert at;
        
        ScheduleBatchUpdateAssetAsActive sc = new ScheduleBatchUpdateAssetAsActive(); 
        sc.execute(null);
        
        BatchReplaceAssetStatus obj2 =  new BatchReplaceAssetStatus(NULL);
        DataBase.executeBatch(obj2); 
        
        BatchReplaceAssetStatus obj21 =  new BatchReplaceAssetStatus('SELECT id,InstallDate,status,UsageEndDate,Product2.Family FROM Asset');
        DataBase.executeBatch(obj21); 
        
        BatchUpdateAssetAsActive obj23= new BatchUpdateAssetAsActive('SELECT id,InstallDate,status,UsageEndDate,Product2.Family FROM Asset');
        DataBase.executeBatch(obj23); 
    }
    
}