public class CreateAlternateEmailBatch implements Database.Batchable<sObject> ,Schedulable {
    public String objectName;
    public String fieldName;
    public String andClause;
    public CreateAlternateEmailBatch(String objectName){
        this.objectName = objectName;
        if(objectName == 'Lead'){
            fieldName = 'Lead_Name__c';
            andClause = 'AND IsConverted = false AND Email != null';
        }
        else If(objectName == 'Contact'){
            fieldName = 'Contact_Name__c';
            andClause = 'AND Email != null';
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'SELECT Id,Email FROM ' + objectName + ' WHERE Id NOT IN (SELECT ' + fieldName + ' FROM Alternate_Email__c )' + andClause;
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope)
    {
        List<Alternate_Email__c> alternateEmailList = new List<Alternate_Email__c>();
        for(sObject obj: scope)
        {
            if((String)obj.get('Email') != ''){
                ALternate_Email__c alternateEmail = new Alternate_Email__c();
                alternateEmail.Alternate_Email_Address__c = (String)obj.get('Email');
                alternateEmail.put(fieldName,(String)obj.get('Id'));
                alternateEmail.Primary_Email__c = True;
                alternateEmail.Active__c = True;
                alternateEmailList.add(alternateEmail);
            }
        }
        Database.SaveResult[] resultList = Database.insert(alternateEmailList,false);
        for(Database.SaveResult result : resultList){
            if (result.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted  ' + result.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : result.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        
    }
    public void execute(SchedulableContext sc)
    {
        CreateAlternateEmailBatch alternateEmailbatch = new CreateAlternateEmailBatch(objectName);
        database.executebatch(alternateEmailbatch);
    }
    
    public void finish(Database.BatchableContext bc)
    {
        
    }
}