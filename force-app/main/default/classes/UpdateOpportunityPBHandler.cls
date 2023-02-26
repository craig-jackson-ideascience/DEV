public class UpdateOpportunityPBHandler implements Queueable{
    public list<Opportunity> oppListToUpdateList;
    @InvocableMethod(label='updateOpportunityPBHandler' description='update Owner Id of Related opportunities')
    public static void updateOpportunityOwner(list<Project__c> prObjectRec){       
        //system.debug('prObjectRec::: => ' + prObjectRec);
        Id membershipRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        //system.debug('membershipRecordTypeId::::'+membershipRecordTypeId);
        
        list<id> acntIds=new list<id>();
        for(Project__c acntPrj:prObjectRec){ 
            acntIds.add(acntPrj.id);
        }
        
        list<OpportunityLineItem> oppLineItemLst= [select id,OpportunityId,Projects__r.Opportunity_Owner__c, Opportunity.isClosed,Opportunity.Type,
                                                   Projects__r.Renewal_Owner__c from OpportunityLineItem where Projects__c IN:acntIds and Opportunity.isClosed=false and Opportunity.RecordTypeId =: membershipRecordTypeId];
        system.debug('oppLineItemLst size()::: => ' + oppLineItemLst.size() +', oppLineItemLst ::: => ' + oppLineItemLst);
        set<id> oppIds=new set<id>();
        list<Opportunity> oppListToUpdate=new list<Opportunity>();
        for(OpportunityLineItem oliRec:oppLineItemLst){
            if(!oppIds.contains(oliRec.OpportunityId) ){ 
                if((oliRec.Opportunity.Type.contains('Renewal') && oliRec.Projects__r.Renewal_Owner__c == null)|| oliRec.Opportunity.Type == 'New Business'){
                    oppListToUpdate.add(new Opportunity(OwnerId=String.valueOf(oliRec.Projects__r.Opportunity_Owner__c).substring(0, 15),Id=oliRec.OpportunityId));
                    oppIds.add(oliRec.OpportunityId);
                }
                
            }
        }
        //system.debug('oppIds size()::: => ' + oppIds.size() +', oppIds ::: => ' + oppIds);
        //system.debug('oppListToUpdate size()::: => ' + oppListToUpdate.size() +', oppListToUpdate ::: => ' + oppListToUpdate);
        //system.debug('DATA::'+oppListToUpdate);
        UpdateOpportunityPBHandler PBHAndler= new UpdateOpportunityPBHandler(oppListToUpdate);
        ID jobID = System.enqueueJob(PBHAndler);
        //system.debug('jobID::'+jobID);
    }
    
    public UpdateOpportunityPBHandler(list<Opportunity> ooplist){
        this.oppListToUpdateList=ooplist;
    }
    
    public void execute(QueueableContext context) {
        //system.debug('oppListToUpdateList ::: ' + oppListToUpdateList);
        Database.SaveResult [] updateResult = Database.update(oppListToUpdateList, false);
        //system.debug('updateResult ::: ' + updateResult);
        for (Database.SaveResult r : updateResult){
            if (!r.isSuccess()){
                for (Database.Error e : r.getErrors()){ 
                    system.debug('\n ERRROR :::: '+e);
                }
            }
        }
    }
}