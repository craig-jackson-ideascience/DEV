@isTest
public class CurrentYearSpendOnAccountBatchTest {
    @isTest static void Test1(){
        List<Account> lstAccount= new List<Account>();
		List<Asset> lstAsset= new List<Asset>();
        for(Integer i=0 ;i<5;i++)
        {
          Account acc = new Account();
          acc.Name ='Test'+i;
          acc.Current_Year_Spend__c = 2000+i;
          lstAccount.add(acc);
        }
         insert lstAccount;
        for(Account acc:lstAccount){
            Asset a = new Asset();
          	a.Name ='Test Asset';
          	a.AccountId = acc.Id;
            a.PurchaseDate = Date.today() ;
            a.InstallDate = Date.today();
            a.Price = 15000;
            a.Number_of_Years_Required__c = 1;
          	lstAsset.add(a);
        }
        insert lstAsset;
         Test.startTest();
         CurrentYearSpendOnAccountBatch obj = new CurrentYearSpendOnAccountBatch();
         DataBase.executeBatch(obj);
         Test.stopTest();

        
    }
}