public Class AccountTriggerAction{
    
    // When Owner of an account is updated, Old_Owner Email field is populated with email id of old owner so that workflow can fire an email alert on this email id
    public void updateOldOwnersEmail(Map<id, Account> newAccount, Map<id, Account> oldAccount){

        system.debug('___updateAccount___');
        List<id> userList = new List<ID>();
        List<Account> accountToUpdate = new List<Account>();

        for (Account acc : newAccount.values()){
            if (acc.ownerId != null && acc.ownerId != oldAccount.get(acc.ID).ownerId){
                userList.add(oldAccount.get(acc.ID).ownerId);
                accountToUpdate.add(acc);
                system.debug('___Account___');

            }
        }
        if (!userList.IsEmpty()){
            Map<ID, User> userMap = new Map<ID, User>([SELECT Id, Name, Email
                                                       FROM User
                                                       where id in:userList]);

            System.debug('>>>>>userMap' + userMap);

            for (Account accs : accountToUpdate){
                system.debug('>>>@@' + oldAccount.get(accs.ID).ownerId);
                accs.Owner_Email__c = userMap.get(oldAccount.get(accs.ID).ownerId).Email;
                System.debug('>>>>>Owner_Email__c' + accs.Owner_Email__c);
            }
        }
    }

    public static void deleteAlternateEmail(List<Account> accounts, Set<Id> alternateEmails){
        Set<Id> winningAccountIdList = new Set<Id>();
        for (Account account : accounts){
            if (account.MasterRecordId != null)
                winningAccountIdList.add(account.MasterRecordId);
        }
        String query = 'SELECT ID FROM Alternate_Email__c WHERE Id IN:alternateEmails';
        if (!winningAccountIdList.IsEmpty()){
            query += ' AND Contact_Name__r.AccountId NOT IN:winningAccountIdList';
        }
        List<Alternate_Email__c> deleteList = Database.query(query);
        if (deleteList.size() > 0)
            delete deleteList;
    }

    /* method to Update Contact's Sector/industry based on condition
     * Logic of process builder to trigger as PB was giving error on bulk records
     * */
    public static void updateSectorIndustryOnContact(Map<Id, Account> newMap, Map<Id, Account> oldMap){
        Set<Id> accountidSet = new Set<Id>();
        Set<Id> proffesionalServiceAccountIdsSet = new Set<Id>();

        for (Account account : newMap.values()){
            if (account.Industry != 'Professional Services' && 
                                 account.id != label.Individual_No_Account && String.isNotBlank(account.Sector__c) && String.isNotBlank(account.Industry) && (account.Industry != oldMap.get(account.id).Industry || account.Sector__c != oldMap.get(account.id).Sector__c)){
                accountidSet.add(account.id);
            }
            if (account.Industry == 'Professional Services' && 
                                 account.id != label.Individual_No_Account && account.Industry != oldmap.get(account.id).Industry){
                proffesionalServiceAccountIdsSet.add(account.Id);
            }
        }
        if (!accountidSet.isEmpty() && !System.isBatch() && !System.isFuture()){
            Database.executeBatch(new UpdateSectorOnContact(accountidSet,null));
            //updateContactSectorIndustry(accountidSet,null);
        }
        if (!proffesionalServiceAccountIdsSet.isEmpty() && !System.isBatch() && !System.isFuture()){
            Database.executeBatch(new UpdateSectorOnContact(proffesionalServiceAccountIdsSet,'Professional Services'));
           // updateContactSectorIndustry(proffesionalServiceAccountIdsSet,'Professional Services');
    
        }
    }

    /*Method to update account sector to professional services if insutry = professional and sector = industrials
     */
    public static void updateSectorAccount(Map<Id, Account> newMap, Map<Id, Account> oldMap){
        for (Account account : newMap.values()){
            if (account.Industry == 'Professional Services' && 
                                    account.id != label.Individual_No_Account && account.Sector__c == 'Industrials' && 
                                    (account.Industry != oldmap.get(account.id).Industry || account.Sector__c != oldmap.get(account.id).Sector__c)){
                account.Sector__c = 'Professional Services';
            }
        }
    }

}