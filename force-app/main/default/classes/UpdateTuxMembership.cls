public class UpdateTuxMembership implements Database.Batchable<sObject>{
        String query;
        Date becametuxMemberOn = System.now().Date().addYears(-3);
        public UpdateTuxMembership(){
            this.query = 'SELECT Id, TuxMember__c, Tux_ProgramStartDate__c, TuxRewards__c '+
                'FROM Contact '+
                'WHERE TuxMember__c = TRUE AND TuxRewards__c >= 500 AND Tux_ProgramStartDate__c =: becametuxMemberOn';
        }
        
        public UpdateTuxMembership(String query){
            this.query = query;        
        }
        
        public Database.QueryLocator start(Database.BatchableContext bc){
            return Database.getQueryLocator(query);
        }
        
        public void execute(Database.BatchableContext bc, List<Contact> conList){
            Map<Id, Contact> idVsCon = new Map<Id, Contact>();
            for(Contact conRec : conList) {
                conRec.TuxMember__c = FALSE;
                idVsCon.put(conRec.ID, conRec);
            }
            
            if(!idVsCon.isEmpty()) {
                //call method to update campaign member status as unenrolled
                setCampaignMemberStatusAsUnnrolled(idVsCon.keySet());
                update idVsCon.values();
            }
        }
        
        public void finish(Database.BatchableContext bc){
            
        }

        /**
         * setCampaignMemberStatusAsUnnrolled :  method to update campaign member status as unenrolled
         * @param  contactIdSet :
         */ 
        public static void setCampaignMemberStatusAsUnnrolled(Set<Id> contactIdSet){
            List<CampaignMember> cmList = [SELECT id, Status
                                           FROM CampaignMember
                                           WHERE CampaignId = :Label.Tux_Rewards_Campaign AND ContactId IN :contactIdSet];
            for (CampaignMember cm : cmList){
                cm.status = 'Unenrolled';
            }
            if (!cmList.isEmpty()){
                update cmList;
            }
        }
 }