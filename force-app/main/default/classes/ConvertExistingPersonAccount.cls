public class ConvertExistingPersonAccount implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT ID,PersonContactId FROM ACCOUNT WHERE IsPersonAccount = true';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> accounts){
        Set<Id> personAccountIDs = new Set<Id>();
        List<Account> accountsToBeDeleted = new List<Account>();
        List<Account> accountToBeUpdated = new List<Account>();
        List<Contact> contactsToBeUpdated = new List<Contact>();
        for(Account account: accounts){
            personAccountIDs.add(account.Id);
        }
        Account businessAccount = [SELECT Id FROM Account WHERE Name =: Label.Lead_Conversion_Account LIMIT 1 ];
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId(); 

        Map<Id,Integer> oppCountMap = new Map<Id,Integer>();
        for (AggregateResult ar : [SELECT Count(ID),AccountID FROM opportunity WHERE AccountID IN:personAccountIDs GROUP BY AccountId]){
            oppCountMap.put((Id)ar.get('AccountID'),(Integer)ar.get('expr0'));
        }
         for(Account account: accounts){
             if((oppCountMap.containsKey(account.Id) && oppCountMap.get(account.Id) <= 0) || !oppCountMap.containsKey(account.Id)){
                 accountToBeUpdated.add(new Account(Id=account.Id,RecordTypeId = recordTypeId));
                 contactsToBeUpdated.add(new Contact(id = account.PersonContactId, AccountID = businessAccount.ID ));
                 accountsToBeDeleted.add(account);
             }
        }
        
        if(!accountToBeUpdated.IsEmpty()){
            update accountToBeUpdated;
            update contactsToBeUpdated;
            delete accountsToBeDeleted;
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}