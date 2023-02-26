public class BatchUpdateContactAccount implements Database.Batchable<Sobject>{
    public string query ='';
    public BatchUpdateContactAccount(){
        
    }
    
    public BatchUpdateContactAccount(string query){
        this.query = query;
    }

    public  Database.QueryLocator start(Database.BatchableContext BC){
        if(string.isEmpty(query)){
        	query ='Select Id,AccountId,Email from Contact where AccountID = null';
        }
        system.debug('Query----' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC,List<Contact> scope ){
        String lfAnonymous =System.Label.LF_Anonymous;
		List<Contact> updateContact = new List<Contact>();        
        ID lfAccount = [Select ID , Name From Account WHERE Name = :lfAnonymous Limit 1].Id;
        Map<String,Id> mapOfDomains = new Map<string,Id>();
        Set<String> setOfDomains = new Set<String>();
        for(Contact con: scope){
            if(con.Email != null)
            {
                String splitEmail = con.Email.substringBetween('@','.');
                setOfDomains.add(splitEmail.toLowerCase());
            }
        }
        
          //Query only those Accounts where website Domain name matches with set of Contact Domain
            String accountQuery = 'select name,website,id from account where ';
            for(string val : setOfDomains){
                accountQuery = accountQuery+' website like '+'\'%'+val+'%\''+' OR';
            }
            accountQuery = AccountQuery.removeEnd('OR');
            accountQuery = accountQuery+' ORDER BY Website';
        
            //Adding Account ID and Domain Name in the Map
            for(Account acc: Database.query(accountQuery)){
                String accDomain = acc.website.replace('www.','');
                String accDomain2 = accDomain.replace('http://','');
                String accDomain3 = accDomain2.replace('https://','');
                String accDomain4 = accDomain3.replace('http://www.','');
                
                if(!mapOfDomains.containskey(accDomain4)){
                    mapOfDomains.put(accDomain4.tolowercase(),acc.id);
                }
            }
        for(Contact cont : scope){
            cont.AccountId =lfAccount;
            if(!mapofDomains.isEmpty()){
                for(string domainname: mapofDomains.keyset()){
                    if(domainname.startsWith(cont.Email.substringBetween('@','.'))){
                        cont.AccountId = mapofDomains.get(domainname);
                        break;
                    }
                }
            }
            updateContact.add(cont);
        }
        
        if(!updateContact.isEmpty()){
            update updateContact;
        }
    }
    
     public void finish(Database.BatchableContext info){
       
     } 
}