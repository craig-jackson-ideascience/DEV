/**
 * UpdateSectorOnContact : Batch for Updating sector of Contact based on Account Sector.
 * Test Class - TestAccountTrigger - testUpdateSector Method
 * This is created because process builderwas giving error while updating bunch of contact at a time from dashboard
 * Hence Logic is moved to Batch
 */
public class UpdateSectorOnContact implements Database.Batchable<sObject>{
    public Set<Id> accountidSet = new Set<Id>();
    String industryAndSector;
    
    //Constructor
    public UpdateSectorOnContact(Set<Id> accountIdSet, String industryAndSector){
        this.accountidSet = accountidSet;
        this.industryAndSector = industryAndSector;
    }

    //Start of batch
    public Iterable<sObject> start(Database.BatchableContext bc){
        // collect the batches of records or objects to be passed to execute
        List<Contact> contactList = [SELECT Id, Account.Sector__c, Account.Industry
                                     FROM Contact
                                     WHERE AccountId IN:accountIdSet];


        return contactList;
    }

    //execute
    public void execute(Database.BatchableContext bc, List<Contact> records){
        // process each batch of records
        for (Contact contact : records){
            contact.Sector__c = String.isNotBlank(industryAndSector) ? industryAndSector : contact.Account.Sector__c;
            contact.Industry__c = String.isNotBlank(industryAndSector) ? industryAndSector : contact.Account.Industry;
        }
        update records;
    }

    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }

}