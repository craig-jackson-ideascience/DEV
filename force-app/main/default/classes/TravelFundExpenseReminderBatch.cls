/************************
*created on @1-06-2020 
*by @cloudroute solutions
*************************/
public class TravelFundExpenseReminderBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        Date d= System.Date.today().addDays(-1);
        String queryString = 'Select Id, Name, TFREmail__c, Status__c, Event__r.TravelFund_End_Date__c, Event__r.Name, Event__r.Accept_Travel_Fund__c, ' 
            + ' Event__r.Expensify_Policy_ID__c  from Travel_Fund_Request__c where Status__c =\'Request Approved - Waiting For Expense Report\' '
            + ' AND Expensify_ID__c = null AND Event__r.Accept_Travel_Fund__c != null AND Event__r.Expensify_Policy_ID__c != null '
            + ' AND Event__r.End_Date__c = :d ';
        return Database.getQueryLocator(queryString);
    }
    public void execute(Database.BatchableContext BC,List<Travel_Fund_Request__c> scope) {
        list<Messaging.SingleEmailMessage> emailMessageList=new list<Messaging.SingleEmailMessage>();
        for(Travel_Fund_Request__c tfr: scope) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] {tfr.TFREmail__c};
            message.subject = 'Expense Report still not received for [' + tfr.Event__r.Name + ']';
            message.plaintextbody= 'Expense report for the Travel Fund Request with Name'+ tfr.Name +' has yet not been received';
            emailMessageList.add(message);
        }
        Messaging.SingleEmailMessage[] messages = emailMessageList;
        System.debug(messages);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '+ results[0].errors[0].message);
        }      
    }
    public void finish(Database.BatchableContext BC){
        System.debug('Records Processed');
    }
    
}