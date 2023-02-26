public class MemberReadoutBatch implements Database.Batchable<Sobject>,Schedulable {
    
    public Set<String> setOfStatus = new set<String>();
    public Set<String> setOfRoles = new set<String>();
    
    //Schedule 's Execute method to call batch
    public void execute(SchedulableContext sc){
        Database.executeBatch(new MemberReadoutBatch(),1);
    }

    public MemberReadoutBatch(){
        setOfStatus = new Set<String>(Label.Readout_PurchaseHistoryStatus.split(';'));
       
    }
    
    public  Database.QueryLocator start(Database.BatchableContext BC){

        //Query Metadata which stored the projects and campaignid
        return Database.getQueryLocator([Select Id, Roles__c,Project_Id__c, Campaign_Id__c From Member_Readout_Campaign__mdt]);
    }
    
    public void execute(Database.BatchableContext BC, List<Member_Readout_Campaign__mdt> scope ){
        system.debug('scope '+scope.size());
       ID projectId = scope[0].Project_Id__c;
       Id campaignId = scope[0].Campaign_Id__c;
       setOfRoles = new Set<String>(scope[0].Roles__c.split(';'));

       //Retrieve the projectroles of the projectid
        String query = 'SELECT Contact__c,count(ID) FROM Project_Role__c WHERE '+
        'Asset__r.Projects__c = :projectId'+
        ' AND Asset__r.Status IN :setOfStatus AND Role__c IN :setOfRoles AND '+
        'Email_Opt_Out__c = false AND Status__c != \'Inactive\' Group by Contact__c';
        system.debug('query '+query);

        Set<Id> setOfContactId = new Set<Id>();
        List<CampaignMember> listOfCampMemberToInsert = new List<CampaignMember>();
        List<AggregateResult> projectRolesList = database.query(query);

        system.debug(projectRolesList.size());
        for (AggregateResult aggrResult : projectRolesList){
            CampaignMember campaignMember = new CampaignMember();
            campaignMember.ContactId = (Id)aggrResult.get('Contact__c');
            campaignMember.CampaignId = campaignId;
            setOfContactId.add((Id)aggrResult.get('Contact__c'));
            listOfCampMemberToInsert.add(campaignMember);
        }

        //Insert
        if (!listOfCampMemberToInsert.isEmpty()){
            List<Database.SaveResult> saveResults = Database.insert(listOfCampMemberToInsert, false);
            System.debug('#--saveResults--#' + saveResults);
        }
        
        //Retrieve members which do not have active membership roles so delete them
        List<CampaignMember> listOfMemberToDelete = [SELECT Id
                                                     FROM CampaignMember
                                                     WHERE CampaignId = :campaignId AND 
                                                     ContactId NOT IN :setOfContactId AND ContactId != null];

         //Delete
        if (!listOfMemberToDelete.isEmpty()){
            System.debug('#--delete--#' + listOfMemberToDelete);
            delete listOfMemberToDelete;
        }
      
    }
    
    public void finish(Database.BatchableContext info){ 
    }
    
}