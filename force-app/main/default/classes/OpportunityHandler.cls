public class OpportunityHandler implements ITriggerHandler {
    
    OpportunityAction action = new OpportunityAction();
    public static Automation_Enabled__c enabled = Automation_Enabled__c.getOrgDefaults();
    //This will handle before delete event
    public void beforeDelete(Map<Id, SObject> oldMap) {
        
    }
    
    //This method will handle before insert method
    public void beforeInsert(List<SObject> newItems) {
        action.addTermsToAgreement((List<Opportunity>) newItems,null);
    }
    
    //This method will handle before update event
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        System.debug('Opp Before Update');
        //check if opp product is added before closed wom
        action.validateIfProductIsAdded((Map<Id, Opportunity>) oldMap,(List<Opportunity>) newMap.values());
        //action.validateIfActiveStatus()    
        action.pushOpportunity((List<Opportunity>) newMap.values(), (Map<Id, Opportunity>) oldMap);
        action.addTermsToAgreement((List<Opportunity>) newMap.values(),(Map<Id, Opportunity>) oldMap);
        /*When Opportunity is Closed Update Opportunity Closed Date and Opportunity Line Item Start Date And End Date*/
        action.updateOppCloseDateAndInstallDate((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
        
        /*When Opportunity is Closed Update Training Opportunity Line Item Start Date And End Date*/
        action.updateStartAndEndDate((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
        
        //SOPS-46 Updates Opp.Application Status Field when Opportunity.Stage is changed to Closed Lost or Closed Won
        action.updateApplicationStatusField((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
        
        /*This method validate that requires a contract be attached to an opportunity before it can be closed won. */
        action.validateBeforeClosedWon((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
        
        //This method restrict the opportunity if its products description is null and it is getting closed won
        action.validateOpportunityProductToRestrictOppsToClosedWon((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
        
        /*This method throws error if Opportunity being updated is Closed won and Locked*/
        action.restrictUpdatingLockedOpps((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
        
        /* This method locks the opportunity if its stage is updated to closed won */
        action.filterClosedOppsToLock((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
        
        /*Check if start date and end date is null for membership types of opps */
        action.validateDateClosedWon((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
        
        //This method validates synced quote before closing,also checks if billing contact is populated or not
        action.validateTrainingOpportunity((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
    }
    
    public void afterInsert(Map<Id, SObject> newMap) {
        //action.addDefaultContactRole((Map<Id, Opportunity>) newMap);        
        
        //Call Method to create address record for the account and billtoaccount associated with opportunity
        action.createAddressObjForAccount((Map<Id, Opportunity>) newMap,null);
        
        //call create asset trigger
        action.createAssetOnClosedWon((List<Opportunity>) newMap.values(),null);
        APIRequestLog.upsertApiLogs(null, newMap, 'Opportunity', 'INSERT');
    }
    
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        action.updateInvoiceMemoForMembershipLineItems((Map<Id, Opportunity>) newMap, (Map<Id, Opportunity>) oldMap);
        action.updateInvoiceMemoForTrainingProduct((Map<Id, Opportunity>) newMap,(Map<Id, Opportunity>) oldMap);
        action.addBillingContact((List<Opportunity>) newMap.values(),(Map<Id, Opportunity>) oldMap); 
        
        //Method to check skip netsuite if issccPay checkbox is checked
        action.checkSkipNSSyncOnProducts((List<Opportunity>) newMap.values(), (Map<Id, Opportunity>) oldMap);

        //(Only for Corporate Training Opportunity)##If the training field on opportunity is not blank, it will update the relatedto and product detail of its opportunity products
        //action.updateTrainingAndProductDetails((Map<Id, Opportunity>) newMap,(Map<Id, Opportunity>) oldMap);
                
        //Call Method to create address record for the account and billtoaccount associated with opportunity
        action.createAddressObjForAccount((Map<Id, Opportunity>) newMap,(Map<Id, Opportunity>) oldMap);
        /*This method restricts the update of opportunity stage from "Discovery" to other if there is no Opportunity Contact Role associated with role - Billing Contact */
        action.restrictOppStageUpdateWithoutOCRs((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
        
        /*This method Create a task for Opportunity Owner that Renewal Opportunity is not Closed */
        //action.createTaskForOpenRenewalOpportunity((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
        //call create asset trigger
        action.createAssetOnClosedWon((List<Opportunity>) newMap.values(),(Map<Id, Opportunity>) oldMap);
        /* This method locks the opportunity if its stage is updated to closed won */
        //action.filterClosedOppsToLock(oldMap , newMap);
       
         
      
        //call method when syncedquoteid is changed or the fields on opp is changed when syncedquoteid != null
        action.oppSyncMethod((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
		//call method to send Closed Lost Email Notification
        action.sendClosedLostEmailNotification((Map<Id, Opportunity>) oldMap, (Map<Id, Opportunity>) newMap);
        
        APIRequestLog.upsertApiLogs(oldMap, newMap, 'Opportunity', 'UPDATE');
    
    }
    
    public void afterDelete(Map<Id, SObject> oldMap) {
        
    }
    
    public void afterUndelete(Map<Id, SObject> newMap) {
        
    }
    
    public Boolean IsDisabled() {
        System.debug(TriggerStopper.stopOpp + '====> TriggerStopper.stopOpp');        
        return TriggerStopper.stopOpp || (!Test.isRunningTest() &&!enabled.Opportunity__c);
    }
    
}