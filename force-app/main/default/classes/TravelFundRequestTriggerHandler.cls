public class TravelFundRequestTriggerHandler implements ITriggerHandler{
    public static void BeforeInsert(List<Sobject> triggerNew) {
        contactInsertIfEmailPresent((List<Travel_Fund_Request__c>) triggerNew);
        updatePreviousApprovals((List<Travel_Fund_Request__c>) triggerNew,null);
        populateRequestorKey((List<Travel_Fund_Request__c>) triggerNew);


    }

    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        //call before update actions
        updatePreviousApprovals((List<Travel_Fund_Request__c>)newMap.values(),(Map<Id, Travel_Fund_Request__c>)oldMap);
        populateRequestorKey((List<Travel_Fund_Request__c>)newMap.values());


    }
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    }

    public static void AfterInsert(Map<Id, SObject> newMap){
        //call onAfterInsert delete actions
        //RollUpTriggerHandler.rollupHelper((List<Travel_Fund_Request__c>)newMap.values());
        calculateRollupfields((Map<Id, Travel_Fund_Request__c>)newMap,null);
    }
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){
        //RollUpTriggerHandler.rollupHelper((List<Travel_Fund_Request__c>)newMap.values());
        congaComposerInvoke((Map<Id, Travel_Fund_Request__c>)newMap,(Map<Id, Travel_Fund_Request__c>)oldMap);
        calculateRollupfields((Map<Id, Travel_Fund_Request__c>)newMap,(Map<Id, Travel_Fund_Request__c>)oldMap);
        System.debug('Calling Add Beneficiary now ');
        AddBeneficiaryFromTravelFund((Map<Id, Travel_Fund_Request__c>) newMap,(Map<Id, Travel_Fund_Request__c>) oldMap);
    }

    public static void AfterDelete(Map<Id, Sobject> oldMap) {
        //RollUpTriggerHandler.rollupHelper((List<Travel_Fund_Request__c>)oldMap.values());
        calculateRollupfields(null,(Map<Id, Travel_Fund_Request__c>)oldMap);
    }


    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after undelete actions
        //RollUpTriggerHandler.rollupHelper((List<Travel_Fund_Request__c>)newMap.values());
        calculateRollupfields((Map<Id, Travel_Fund_Request__c>)newMap,null);
    }

    public Boolean IsDisabled(){
        return false;
    }

    public static void contactInsertIfEmailPresent(List<Travel_Fund_Request__c> triggerNew){

        ContactInsertUtilityClass uc = new ContactInsertUtilityClass();
        uc.contactInsert(triggerNew);
    }


    public static void updatePreviousApprovals(List<Travel_Fund_Request__c> triggerNew,  Map<Id, Travel_Fund_Request__c> oldMap){
/*
        Map<Id,List<Travel_Fund_Request__c>> mapOfContactVsTFR = new Map<Id,List<Travel_Fund_Request__c>>();
        for(Travel_Fund_Request__c tfr : triggerNew){
            if(oldMap == null || (oldMap != null && oldMap.get(tfr.id).Contact__c != tfr.Contact__c)){
                if(!mapOfContactVsTFR.containsKey(tfr.Contact__c)){
                    mapOfContactVsTFR.put(tfr.Contact__c,new List<Travel_Fund_Request__c>{tfr});
                }
                else{
                    mapOfContactVsTFR.get(tfr.Contact__c).add(tfr);
                }
            }
        }
        if(!mapOfContactVsTFR.IsEmpty()){

            List<Travel_Fund_Request__c> travelfundList = [Select Id, Status__c, Contact__c From Travel_Fund_Request__c
            WHERE (First_Approval__c = 'Yes')
            AND  Contact__c IN: mapOfContactVsTFR.keySet()];
            for(Travel_Fund_Request__c tf : travelfundList){

                for(Travel_Fund_Request__c trf : mapOfContactVsTFR.get(tf.Contact__c)){
                    trf.Previous_Approval__c = tf.Id;
                }
            }
        }
*/
        Map<Id,Travel_Fund_Request__c> mapOfContactVsTFR = new Map<Id,Travel_Fund_Request__c>();
        for(Travel_Fund_Request__c tfr : triggerNew){
            if(oldMap == null || (oldMap != null && oldMap.get(tfr.id).Contact__c != tfr.Contact__c)){
                if(!mapOfContactVsTFR.containsKey(tfr.Contact__c)){
                    mapOfContactVsTFR.put(tfr.Contact__c,null);
                }
            }
        }
		system.debug('Map of Contact vs TFR'+mapOfContactVsTFR);
        if(!mapOfContactVsTFR.IsEmpty()){
            List<Travel_Fund_Request__c> travelfundList = [Select Id, Status__c, Contact__c, CreatedDate From Travel_Fund_Request__c WHERE 
	    													Status__c IN ('Paid','Approved') 
            												AND Contact__c IN: mapOfContactVsTFR.keySet()
                                                            AND Approved_Date__c !=Null
	    													Order BY Contact__c,Approved_Date__c DESC];
            
            for(Travel_Fund_Request__c tf : travelfundList){
                if(mapOfContactVsTFR.get(tf.Contact__c) == null){
                    mapOfContactVsTFR.put(tf.Contact__c,tf);
                }
            }
		}
        system.debug('Map of Contact vs TFR after approved TFR query'+mapOfContactVsTFR);
   
        for(Travel_Fund_Request__c tf :triggerNew){
 			if(mapOfContactVsTFR.get(tf.Contact__c) != null){
				tf.Previous_Approval__c = mapOfContactVsTFR.get(tf.Contact__c).Id;
			}	
		}
    }

    public static void populateRequestorKey(List<Travel_Fund_Request__c> triggerNew){
        // respect existing value if e.g. the record was imported with one
        for(Travel_Fund_Request__c tfRequest :triggerNew){
            if(String.isBlank(tfRequest.Requestor_Key__c) || tfRequest.Requestor_Key__c == NULL) {
                System.debug('will generate a new Requestor_Key__c value');
                String salt = String.valueOf(System.now().getTime());
                Blob md5 = Crypto.generateDigest('MD5', Blob.valueOf(salt + tfRequest.Name));

                // to get the 32-char hash String, convert to hex
                String md5string = EncodingUtil.convertToHex(md5);
                System.debug('Hashed version of the md5 will be ' + md5string);

                tfRequest.Requestor_Key__c = md5string;
            }
        }
    }

    public static void congaComposerInvoke(Map<Id, Travel_Fund_Request__c> newMap, Map<Id, Travel_Fund_Request__c> oldMap){
        for(Travel_Fund_Request__c tfRequest:newMap.values()){
            if(oldMap.get(tfRequest.id).Status__c != tfRequest.Status__c) {
                System.debug('Travel_Fund_RequestTrigger found a change in the Status__c value');
                String newStatus = tfRequest.Status__c;
                System.debug('Travel_Fund_RequestTrigger found the new Status__c value to be ' + newStatus);

                if(newStatus == 'Expense Report Approved') {
                    System.debug('Travel_Fund_RequestTrigger because the new Status__c value is Expense Report Approved we will send an email');
                    System.debug('Travel_Fund_RequestTrigger has found the Event Name to be ' + tfRequest.Event__r.Name);
                    String templateId = 'a1Q41000004KJxt'; // default template ID
                    if(tfRequest.Event__r.Name == 'CNCF') {
                        templateId = 'a1Q41000004YRHP';
                    }
                    System.debug('Travel_Fund_RequestTrigger will be using the template with ID of ' + templateId);

                    /*Travel_Fund_RequestHelper helper = new Travel_Fund_RequestHelper();
                    helper.CongaComposerInvocation(tfRequest, templateId);*/
                }
            }
        }
    }
    public static void AddBeneficiaryFromTravelFund(Map<Id, Travel_Fund_Request__c> newMap, Map<Id, Travel_Fund_Request__c> oldMap) {
        list<Travel_Fund_Request__c> listToUpdate = new list<Travel_Fund_Request__c>();
        for(Travel_Fund_Request__c iterate : newMap.Values()) {
            if(iterate.Status__c == 'Request Approved - Waiting For Expense Report' && iterate.status__c != oldMap.get(iterate.Id).Status__c) {
                listToUpdate.add(iterate);
            }
        }
        if(listToUpdate.Size()>0) {
            System.enqueuejob(new AddBeneficiaryfromTravelFundHandler(listToUpdate));
        }
    }
    public static void calculateRollupfields(Map<Id, Travel_Fund_Request__c> newMap, Map<Id, Travel_Fund_Request__c> oldMap){
        system.debug('oldMap-->'+oldMap);
        system.debug('newMap-->'+newMap);
        List<Event__c> lstEvent = new List<Event__c>();
        set<Id> eventIds = new set<Id>();
        Decimal Total_Approved_Travel_Funds =0;
        Decimal Total_Paid_Travel_Funds = 0;
        map<Id,Event__c> mapEvent = new map<Id,Event__c>();
        Travel_Fund_Request__c oldTF = new Travel_Fund_Request__c();
        Travel_Fund_Request__c newTF = new Travel_Fund_Request__c();
        if(oldMap != null && newMap == null) {
            for(Travel_Fund_Request__c objTravelFund : oldMap.values()){
                system.debug('Inside old');
                eventIds.add(objTravelFund.Event__c);
                //oldTF = oldMap.get(objTravelFund.id);
            }
        }
        if(newMap != null){
            for(Travel_Fund_Request__c objTravelFund : newMap.values()){
                if(oldMap !=null){
                    oldTF = oldMap.get(objTravelFund.id);
                }
                if(oldTF.Expensify_Approved_Amount__c != objTravelFund.Expensify_Approved_Amount__c
                        ||oldTF.Expensify_Paid_Amount__c != objTravelFund.Expensify_Paid_Amount__c
                        ||oldTF.Amount_Approved__c != objTravelFund.Amount_Approved__c ){
                    system.debug('Inside New');
                    eventIds.add(objTravelFund.Event__c);
                }
            }
        }
        system.debug('eventIds--->'+eventIds);
        if(eventIds.size()>0){
            for(Travel_Fund_Request__c objTravelFund :[Select Event__r.id,Expensify_Approved_Amount__c,
                    Amount_Approved__c,Expensify_Paid_Amount__c,
                    Event__r.Total_Approved_Travel_Funds__c
            From Travel_Fund_Request__c Where Event__c IN:eventIds])
            {
                
                Event__c objEvent = new Event__c();
                objEvent.Id = objTravelFund.Event__r.id;
                //Total_Approved_Travel_Funds =0;
                //Total_Approved_Travel_Funds =0;
                if(objTravelFund.Expensify_Approved_Amount__c != 0 && objTravelFund.Expensify_Approved_Amount__c != null){
                    system.debug('Inside');
                    Total_Approved_Travel_Funds+=objTravelFund.Expensify_Approved_Amount__c;
                }else if(objTravelFund.Amount_Approved__c != 0 && objTravelFund.Amount_Approved__c != null){
                    Total_Approved_Travel_Funds+= objTravelFund.Amount_Approved__c;
                }
                if(objTravelFund.Expensify_Paid_Amount__c != 0 && objTravelFund.Expensify_Paid_Amount__c != null){
                    Total_Paid_Travel_Funds +=objTravelFund.Expensify_Paid_Amount__c;
                }
                objEvent.Total_Paid_Travel_Funds__c =Total_Paid_Travel_Funds;
                objEvent.Total_Approved_Travel_Funds__c = Total_Approved_Travel_Funds;
                lstEvent.add(objEvent);
                system.debug('');
            }
        }
        if(lstEvent.size()>0){
            mapEvent.putAll(lstEvent);
            update mapEvent.values();
        }
    }
}