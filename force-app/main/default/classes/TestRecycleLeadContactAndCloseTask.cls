@isTest
public class TestRecycleLeadContactAndCloseTask{

    static testmethod void test(){
        
        List<Task> taskList = new List<Task>();
        
        Account account1=new Account(Name='Account Company',billingstate='Arizona',website='www.test.com');
        insert account1;
         
        Lead l1 = new Lead(LastName='Lead1', Company='Lead1 Company', LeadSource='Content',email='test234@test.com');
        insert l1;
        
        Contact c1 = new Contact(LastName='Test Contact' , AccountId = account1.Id);
        insert c1;
        
        taskList.add(new Task(Subject='Test task Subject1' , WhoId = l1.Id));
        taskList.add(new Task(Subject='Test task Subject2' , WhoId = c1.Id));
        insert taskList;
        
        RecycleLeadContactAndCloseTask.recycleAndClose(taskList[0].Id , l1.Id);
        RecycleLeadContactAndCloseTask.recycleAndClose(taskList[1].Id , c1.Id);
       
    }
    

}