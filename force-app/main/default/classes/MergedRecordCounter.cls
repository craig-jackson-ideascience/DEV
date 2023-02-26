public class MergedRecordCounter implements Schedulable {
//All of these methods are imperfect, since Salesforce only creates one history
//record when three records are merged at once.  If only two records are merged
//at one time every time, then the count will be correct.  If three records are
//ever merged at one time, then the merge count for that object will be too low.

//These methods count the number of records merged in the past 18 months, since
//that's as long as Salesforce (currently) stores field history.

    public void execute(SchedulableContext SC){
        updateMergedAccountCount();
        updateMergedLeadCount();
        updateMergedContactCount();
    }
    
    public static void updateMergedAccountCount(){
        
		//update # Merged Accounts field
		List<AggregateResult> groupedResults = new List<AggregateResult>();
        groupedResults = [SELECT AccountId, COUNT(Id)
						  FROM AccountHistory
						  WHERE Field = 'accountMerged'
						  GROUP BY AccountId];
		
        Map<ID, Integer> accIDToNumMerged = new Map<ID, Integer>();
        
        //only proceed if any merged Accounts were found
        if(groupedResults.size() > 0){
            
            //populate map of each Account ID to how many Account History records it has
        	for(AggregateResult ar: groupedResults){
                accIDToNumMerged.put( (Id)ar.get('AccountId'), (Integer)ar.get('expr0') );
        	}
            
            //get list of Accounts from map
			List<Account> accs = new List<Account>();
			accs = [SELECT Merged_Accounts__c FROM Account WHERE Id IN :accIDToNumMerged.keySet()];
            
            //update merge count for those Accounts
            for(Account acc : accs){
                acc.Merged_Accounts__c = accIDToNumMerged.get(acc.Id);
            }
            update accs;
        }
        
        //clear out old values for # Merged Accounts field
		//on any Account not already updated
		List<Account> accsToReset = new List<Account>();
		accsToReset = [SELECT Merged_Accounts__c
                       FROM Account 
                       WHERE Merged_Accounts__c > 0
                       AND Id NOT IN :accIDToNumMerged.keySet()];

        if(accsToReset.size() > 0){
            for(Account acc : accsToReset){
                acc.Merged_Accounts__c = 0;
            }
            update accsToReset;
        }
        
    }
    
    public static void updateMergedLeadCount(){
        
		//update # Merged Leads field
		List<AggregateResult> groupedResults = new List<AggregateResult>();
        groupedResults = [SELECT LeadId, COUNT(Id)
						  FROM LeadHistory
						  WHERE Field = 'leadMerged'
						  GROUP BY LeadId];
		
        Map<ID, Integer> leadIDToNumMerged = new Map<ID, Integer>();
        
        //only proceed if any merged Leads were found
        if(groupedResults.size() > 0){
            
            //populate map of each Lead ID to how many Lead History records it has
        	for(AggregateResult ar: groupedResults){
                leadIDToNumMerged.put( (Id)ar.get('LeadId'), (Integer)ar.get('expr0') );
        	}
            
            //get list of Leads from map
			List<Lead> leads = new List<Lead>();
			leads = [SELECT Merged_Leads__c FROM Lead WHERE Id IN :leadIDToNumMerged.keySet()];
            
            //update merge count for those Leads
            for(Lead ld : leads){
                ld.Merged_Leads__c = leadIDToNumMerged.get(ld.Id);
            }
            update leads;
        }
        
        //clear out old values for # Merged Leads field
		//on any Lead not already updated
		List<Lead> leadsToReset = new List<Lead>();
		leadsToReset = [SELECT Merged_Leads__c
                        FROM Lead
                        WHERE Merged_Leads__c > 0
                        AND Id NOT IN :leadIDToNumMerged.keySet()];

        if(leadsToReset.size() > 0){
            for(Lead ld : leadsToReset){
                ld.Merged_Leads__c = 0;
            }
            update leadsToReset;
        }
        
    }
    
    public static void updateMergedContactCount(){
        
		//update # Merged Contacts field
		List<AggregateResult> groupedResults = new List<AggregateResult>();
        groupedResults = [SELECT ContactId, COUNT(Id)
						  FROM ContactHistory
						  WHERE Field = 'contactMerged'
						  GROUP BY ContactId];
		
        Map<ID, Integer> conIDToNumMerged = new Map<ID, Integer>();
        
        //only proceed if any merged Contacts were found
        if(groupedResults.size() > 0){
            
            //populate map of each Contact ID to how many Contact History records it has
        	for(AggregateResult ar: groupedResults){
                conIDToNumMerged.put( (Id)ar.get('ContactId'), (Integer)ar.get('expr0') );
        	}
            
            //get list of Contacts from map
			List<Contact> cons = new List<Contact>();
			cons = [SELECT Merged_Contacts__c FROM Contact WHERE Id IN :conIDToNumMerged.keySet()];
            
            //update merge count for those Contacts
            for(Contact con : cons){
                con.Merged_Contacts__c = conIDToNumMerged.get(con.Id);
            }
            update cons;
        }
        
        //clear out old values for # Merged Contacts field
		//on any Contact not already updated
		List<Contact> consToReset = new List<Contact>();
		consToReset = [SELECT Merged_Contacts__c
                        FROM Contact
                        WHERE Merged_Contacts__c > 0
                        AND Id NOT IN :conIDToNumMerged.keySet()];

        if(consToReset.size() > 0){
            for(Contact con : consToReset){
                con.Merged_Contacts__c = 0;
            }
            update consToReset;
        }
        
    }
    
}