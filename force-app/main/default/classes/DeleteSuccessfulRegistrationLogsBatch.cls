/**
 * DeleteSuccessfulRegistrationLogsBatch : Batch Class deleting the Successful cvent Registration Log recordsafter 7 days
 * Database.executeBatch(new DeleteSuccessfulRegistrationLogsBatch());
 * Batch need to be scheduled for daily
 */
public class DeleteSuccessfulRegistrationLogsBatch implements Database.Batchable<sObject>, Schedulable{
	String query = '';
	public Date sevenDaysPast = System.today().addDays(-7);

    //Constructor
	public DeleteSuccessfulRegistrationLogsBatch(){}
	public DeleteSuccessfulRegistrationLogsBatch(String query){
        if(String.isNotBlank(query)){
            this.query = query;
        }       
	}

	//Schedule 's Execute method to call batch
	public void execute(SchedulableContext sc){
		Database.executeBatch(new DeleteSuccessfulRegistrationLogsBatch());
	}

    //Start of Batch
	public Database.QueryLocator start(Database.BatchableContext BC){

		if (String.isEmpty(query)){
            //Retrieve the Cvent_Registration_Log__c record which are marked as Successfully_Processed__c and whose last modified date is more then the seven days back
			query = 'SELECT Id FROM Cvent_Registration_Log__c WHERE Retrieved__c != null AND Successfully_Processed__c = true AND Day_Only(LastModifiedDate) <=: sevenDaysPast';
		}
		System.debug('query ' + query);
		return Database.getQueryLocator(query);
	}

    //Execute of Batch
	public void execute(Database.BatchableContext BC, List<sObject> scope){
		//Delete the log records
        delete scope;
	}

    //Finish of Batch
	public void finish(Database.BatchableContext BC){
	}
}