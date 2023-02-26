@istest
public class BatchUpdateContactTest {
    @testSetup static void setup(){
        
        Account acc1 = new Account(Name = 'Test account' , website = 'testing1.com');
        insert acc1;
        
        Account acc2 = new Account(Name =  'LF Anonymous', website = 'testing.com');
        insert acc2;
        Contact con = new Contact(LastName = 'testCon', email = 'test@testing1.com');
        insert con;
        con.AccountId = null;
        update con;
        Contact con1 = new Contact(LastName = 'testCon1', email = 'test@gmail.com');
        insert con1;
        con1.AccountId = null;
        update con1;

    }

    static testMethod void createContactwithDomain(){
        System.assertEquals(2,[Select Count() From Contact WHERE AccountID=null]);
        Test.startTest();
        Database.executeBatch(new BatchUpdateContactAccount());
        Test.stopTest();
        System.assertEquals(2,[Select Count() From Contact WHERE AccountID!=null]);
    }
    
    
}