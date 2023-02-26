@istest
public class EmailUtilityTest {
    
      @testSetup static void setup(){

        User standard = TestFactory.getUser();

        Opportunity oppt= TestFactory.getOpportunity();
        
        //Asset ass =  TestFactory.getAsset();
          
        //Contact con = TestFactory.getContact();
    }
    
    
    static testMethod void EmailUtilitydetail(){
      
        User userdetail = [Select ID, email From User Where email ='standarduser123@testorg.com'];
        System.debug('userdetail' +userdetail);
        // MyProjectsReportEmailHandler.temporaryOwnerID = new list<id>{userdetail.Id};
        
        Test.startTest();
            Database.executeBatch(new EmailUtility('MyProjectsReportEmailHandler'));
        Test.stopTest();

            
            }
    
     static testMethod void sendEmailHelper(){
      
        User userdetail = [Select ID, email From User Where email ='standarduser123@testorg.com'];
        System.debug('userdetail' +userdetail);
        Account acc = TestDataUtils.createAccount('free training Account');

        Contact con = TestDataUtils.createContact('test','linuxtest',acc.Id);
        // MyProjectsReportEmailHandler.temporaryOwnerID = new list<id>{userdetail.Id};
             
         SendEmailWrapper sndemailwrap = new SendEmailWrapper();
         sndemailwrap.body = 'test';
         sndemailwrap.subject = 'TESTSUBJECT';
         sndemailwrap.whatId = '123456789101112';
         
         User standard = TestFactory.getUser();
        
         Opportunity oppt= TestFactory.getOpportunity();
         oppt.OwnerId = standard.id;
         update oppt;
         
         Asset ass =  TestFactory.getAsset();
         ass.UsageEndDate = ass.UsageEndDate.addDays(2);
         ass.OwnerId = standard.Id;
         update ass;
         
         oppt.Parent_Asset__c =ass.id;
         update oppt;
                 
         Map<string,object> params = new Map<string,object>();
         params.put('id',oppt.OwnerId);
         
         SendEmailWrapper.SendEmailContactWrapper sendEmailCntctWrap = new SendEmailWrapper.SendEmailContactWrapper(userdetail.id,new Set<Id>{con.id},params);
         list<SendEmailWrapper.SendEmailContactWrapper>	 sendEmailContactWrapper = new list<SendEmailWrapper.SendEmailContactWrapper>{sendEmailCntctWrap};
         Test.startTest();
         Database.executeBatch(new EmailUtility(sndemailwrap,sendEmailContactWrapper,'MyProjectsReportEmailHandler'));
         EmailUtility cb = new EmailUtility();
         List<SendEmailWrapper.SendEmailContactWrapper> ql = cb.start(null);
		 cb.execute(null,sendEmailContactWrapper);
		 cb.Finish(null);
         String CRON_EXP = '00 14 * * * ?';
         EmailUtility sq = new EmailUtility(sndemailwrap,sendEmailContactWrapper,'MyProjectsReportEmailHandler');
         String jobId = System.schedule('Schedule test',CRON_EXP, sq);
         Test.stopTest();
         
         
     }
    
}