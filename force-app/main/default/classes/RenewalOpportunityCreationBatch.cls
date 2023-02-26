/*
THIS BATCH WOULD RUN EVERYDAY AND
AFTER 60 DAYS OF MEMBERSHIP ASSETS CREATION
CREATE RENEWAL OPPORTUNITY FOR THEM
*/
global class RenewalOpportunityCreationBatch Implements Database.Batchable<sObject>, Database.Stateful{

    public String qry;
    public Integer day = 05;
    public Integer month = 09;
    public Integer customDate = 15;
    public Map<ID,Asset> updateAssets = new Map<ID,Asset>();
    public Map<id,Opportunity> updateOpportunityStages = new Map<id,Opportunity>();

    public String emailErrorString  = '<table border="1" style="border-collapse: collapse;">' +
            '<tr><td>Object Id</td>' +
            '<td>Error Message</td>' +
            '<td>Status Code </td></tr>';
    public  Boolean hasError = false;
    public RenewalOpportunityCreationBatch (){}
    public RenewalOpportunityCreationBatch (Integer day,String query,Integer month,Integer customDate){
        if(day != null){
            this.day = day ;
        }
        if(query != null){
            qry = query;
        }
        if(month != null){
            this.month = month ;
        }
        if(customDate != null){
            this.customDate = customDate;
        }
    }
    public RenewalOpportunityCreationBatch (String query){
        if(query != null){
            qry = query;
        }
    }

    global Database.QueryLocator start(database.batchablecontext BC){
        String pastDate =String.valueOf(Date.today().addDays(-day));
        system.debug('-----'+pastDate);
        if(String.isBlank(qry)){
            Date fifteenSeptDate = Date.newInstance(Date.today().year(), month, customDate);
            system.debug('fifteenSeptDate '+fifteenSeptDate);
            qry = 'SELECT id,OpportunityLineItem__c,UsageEndDate,Renewal_Opportunity_Created__c ,Bill_To_Address__c,Bill_To_Account__c,'+
                    'order__c, NS_Entity_ID__c,NetSuite_Id__c,Display_Logo_On_Website__c,Press_Release_Announcement__c,CNCF_Level__c,'+
                    'Opportunity__c,AccountID,Projects__r.Days_to_Deduct__c FROM Asset WHERE Renewal_Opportunity_Created__c = FALSE and Auto_Renew__c = TRUE '+
                    ' and CALENDAR_YEAR(CreatedDate) >= 2019  and Projects__c!=null and '+
                    'Opportunity__c !=null AND Opportunity__r.StageName !=\'Stage 1\' and Status !=\'Invoice Cancelled\' AND Status != \'Associate Cancelled\'';
            if(Date.today() >= fifteenSeptDate){
                qry +=' and (DAY_ONLY(convertTimezone(CreatedDate)) <='+pastDate+' OR UsageEndDate = THIS_YEAR)';
            }else{
                qry +=' and DAY_ONLY(convertTimezone(CreatedDate)) <='+pastDate;
            }
        }
        system.debug('__qry____'+qry);

        return Database.getQueryLocator(qry);

    }

    global void execute(Database.BatchableContext BC, List<Asset> scope){
        set<Asset> assetList = new set<Asset>();
        system.debug('-scope-'+scope.size()+' '+scope);
        try{

            list<Database.SaveResult> updateAssetsresults = new list<Database.SaveResult>();
            list<Database.SaveResult> updateOpportunityStagesresults = new list<Database.SaveResult>();

            List<Opportunity> renewalOpps = new List<Opportunity>();

            RenewalClassForOpps ren = new RenewalClassForOpps();

            system.debug('____scope___size___'+scope.size());

            updateAssets = ren.setCheckboxOnAsset(scope);
            system.debug('#==='+updateAssets);
            system.debug('--updateAssets-'+updateAssets);
            system.debug('--Before renewalOpps--');
            renewalOpps = ren.createRenewalOpps(scope);
            system.debug('--After renewalOpps--');
            Map<Id,String> parentAssetIdVsRenewalOppName = new Map<Id,String>();
            if(renewalOpps!=null && renewalOpps.size()>0){
                updateOpportunityStages = ren.updateOppStageForRenewalOpps(renewalOpps);
                parentAssetIdVsRenewalOppName=ren.getParentAssetVsRenewalNameMap(renewalOpps);
                //ren.createTasksForRenewalOpps(renewalOpps); //commented task creation
            }

            Integer i = 0; //For Update Asset Error Count
            Integer j = 0; //For Update Opportunity Error Count

            updateOpportunityStagesresults = Database.update(updateAssets.values(),false);
            system.debug('----'+updateOpportunityStages.values());

            updateAssetsresults = Database.update(updateOpportunityStages.values(),false);
            system.debug('---updateAssetsresults--'+updateAssetsresults);
            system.debug('---updateOpportunityStages--'+updateOpportunityStages);
            /*Asset Error Result Loop*/
            if(updateAssetsresults != null && updateAssetsresults.size() > 0){
                errorString(updateAssetsresults,updateAssets.values());
            }
            /*Asset Error Result Loop END*/

            /*Opportunity Error Result Loop*/
            if(updateOpportunityStagesresults != null && updateOpportunityStagesresults.size() > 0){
                errorString(updateOpportunityStagesresults,updateOpportunityStages.values());
            }
            /*Opportunity Error Result Loop END*/
            system.debug('--updateAssets-'+updateAssets.values());
            list<Asset> assetListTemp = new list<Asset>();
            for(Asset asset : updateAssets.values()){
                asset.Renewal_Opportunity_Created__c = true;
                asset.Marked_for_Renewal_Processing__c = false;
                asset.Renewal_Opportunity_Name__c = parentAssetIdVsRenewalOppName.containsKey(asset.Id)?
                    parentAssetIdVsRenewalOppName.get(asset.Id):'';
            }
            if(Test.isRunningTest() && RenewalBatchUtility.isError) throw new NullPointerException();

            if(Test.isRunningTest()) {
                throw new NullPointerException();
            }
            system.debug('----'+assetListTemp);
            //assetList.addAll(assetListTemp);
            system.debug('----'+assetList);
        }
        catch(Exception e){
            system.debug('---'+e.getMessage()+'----'+e.getLineNumber());
            list<String> errorStringList =  new list<String>();
            errorStringList = e.getMessage().split(';-;');
            if(errorStringList.size() > 0){
                system.Debug('-errorStringList--'+errorStringList.size());
                String error1 = errorStringList.size()< 2 ? '' : errorStringList[1];
                String error2 = errorStringList.size() < 3 ? '' : errorStringList[2];
                emailErrorString += '<tr><td style="color:red;">' + error1  + '</td>' +
                        '<td style="color:red;">' + errorStringList[0] + '</td>' +
                        '<td style="color:red;">' + error2 + '</td>' +
                        '</tr>';
                hasError = true;
            }
        }
        finally{
            system.debug('-- updateAssets.values()---'+ updateAssets);
            if(updateAssets.values().size() > 0){
                update updateAssets.values();
            }
        }

    }

    global void finish(Database.BatchableContext info){
        /*Sending Error Message to given Label: RenewalOpportunityBatchClassErrorSendingEmail*/
        system.debug('-updateOpportunityStagesresults-'+updateOpportunityStages.values());
        system.debug('-updateAssets-'+updateAssets.values());
        system.debug('-----'+emailErrorString);
        Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>();
        /*Sending Email Start*/
        if(hasError){
            Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(orgWideEmailAddress);
            mail.setToAddresses(new List<String>{label.RenewalOpportunityBatchClassErrorSendingEmail});
            mail.setSubject('Batch Error');
            mail.setHtmlBody(emailErrorString);
            emails.add(mail);
            system.debug('------'+emails);
            if(emails.size() > 0){
                Messaging.sendEmail(emails);
            }
        }
        /*Sending Email End*/
    }

    private void errorString(List<Database.SaveResult> saveResult,List<sobject> updatedList){

        Integer i = 0;
        for (Database.SaveResult sr : saveResult) {
            for(Database.Error err : sr.getErrors()){
                emailErrorString += '<tr><td>' + updatedList[i].get('id') + '</td>' +
                        '<td>' + err.getMessage() + '</td>' +
                        '<td>' + err.getStatusCode() + '</td>' +
                        '</tr>';
                hasError = true;
            }
            i++;
        }
    }
}