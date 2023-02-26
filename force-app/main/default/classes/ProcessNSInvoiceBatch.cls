/*
 * This gets the invoices which were modified in current week.
 * If invoice is cancelled, cancel the asset
 * If invoice priority is set to category c, reopen existing opp and close lost any open renewals
 * Test Class - ProcessNSInvoiceBatch_Test Class
 */
public class ProcessNSInvoiceBatch implements Database.Batchable<InvoiceWrapperNS>, Database.AllowsCallouts,schedulable {

    public void execute(SchedulableContext sc)
    {
        Database.executebatch(new ProcessNSInvoiceBatch());
    }

    public Iterable <InvoiceWrapperNS> start(Database.BatchableContext BC) {
        return getInvoiceFromNetSuite();
    }

    public void execute(Database.BatchableContext BC, List<InvoiceWrapperNS> scope) {
        Set<String> categoryCIDs = new Set<string>();
        for (InvoiceWrapperNS wrapper : scope) {
            if(wrapper.columns.custbody_priority.name == 'Category C'){
                categoryCIDs.add(wrapper.columns.createdfrom.internalid);
            }
        }

        if(!categoryCIDs.IsEmpty()){
            reOpenOpportunity(categoryCIDs);
        }

    }

    public void finish(Database.BatchableContext BC) {

    }

    public static List<InvoiceWrapperNS> getInvoiceFromNetSuite(){
        List<InvoiceWrapperNS> invoiceWrapper = new List<InvoiceWrapperNS>();
        List<Endpoints__c> endPointObj = new List<Endpoints__c>([select name, endpoint__c,Nlauth_Account__c, Password__c, User_Id__c from Endpoints__c
        where name = 'For Invoice']);
        if(!endPointObj.isEmpty()){
            HttpResponse response = CallOutToNetSuiteForAsset.calloutToNetSuite(endPointObj[0], 'GET', '');
            System.debug('Response==>' + response.getBody());
            if(response.getBody() != 'null' && String.isNotBlank(response.getBody())){
                //replace invalid char
                String responseBody = response.getBody().replace('custbody_cancelled_','custbody_cancelled');
                invoiceWrapper = (List<InvoiceWrapperNS>) JSON.deserialize(responseBody, List<InvoiceWrapperNS>.class);
                invoiceWrapper = invoiceWrapper == null ? new List<InvoiceWrapperNS>() :invoiceWrapper;
            }
        }
        System.debug('Wrapper =>' + invoiceWrapper);
        return invoiceWrapper;
    }

    /*private static void cancelInvoice(Set<String> cancelledIDs){
        List<Asset> assetToBeUpdated = new List<Asset>();
        List<Asset> assets = getAssets(cancelledIDs);
        Set<Id> assetOppIds = new Set<Id>();
        Map<Id,List<Asset>> assetByOpp = new Map<Id,List<Asset>>();
        Set<Id> assetIds = new Set<Id>();
        for(Asset asset : assets){
            if(asset.Status != 'Invoice Cancelled'){
                asset.Status = 'Invoice Cancelled';
                asset.Cancellation_Date__c = Date.today();
                asset.Auto_Renew__c = false;
                asset.Cancellation_Reason__c ='Netsuite Invoice Cancelled';
                assetToBeUpdated.add(asset);
                assetOppIds.add(asset.Opportunity__c);
                assetIds.add(asset.Id);
                if(!assetByOpp.containsKey(asset.Opportunity__c)){
                    assetByOpp.put(asset.Opportunity__c,new List<Asset>());
                }
                assetByOpp.get(asset.Opportunity__c).add(asset);
            }
        }

        if(!assetIds.IsEmpty()){
            //close any open renewals
            List<Opportunity> renewalOpps = closeOpenRenewalOpportunity(assetIds,'No Decision / Non-Responsive');
            if(!renewalOpps.isEmpty()){
                update renewalOpps;
            }
        }

        //update assets
        if(!assetToBeUpdated.isEmpty()){
            update assetToBeUpdated;
        }

        //send notification email
        if(!assetByOpp.isEmpty()){
            sendNotification(assetByOpp);
        }
    }*/

    /*
     * If invoice priority is set to category c in netsuite, reopen the opp associated with asset.
     * Also close lost any open renewals
    */
    private static void reOpenOpportunity( Set<String> categoryCIDs){
        List<Opportunity> oppToBeUpdated = new List<Opportunity>();
        List<Asset> assets = getAssets(categoryCIDs);
        System.debug('assets '+assets);
        Set<Id> assetOppIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        List<Asset> assetsToBeUpdated = new List<Asset>();

        for(Asset asset : assets){
            if(asset.Opportunity__r.StageName != 'Stage 1' && (asset.Opportunity__r.Type == 'Renewal' || asset.Opportunity__r.Type == 'Renewal - Upgrade' || asset.Opportunity__r.Type == 'Renewal - Downgrade')){
                assetOppIds.add(asset.Opportunity__c);
                assetIds.add(asset.Id);
                if(asset.SalesOrderStatus__c != 'Closed'){ //Added by Tushar@cloudroute.in on 6 Oct 2020, #2012
                    asset.Status = 'At Risk';
                    asset.SalesOrderStatus__c= 'Open';
                    assetsToBeUpdated.add(asset);
                }
            }
        }
        if(!assetOppIds.IsEmpty()){
            //fetch opportunity associated with the current asset
            for(Opportunity opp : [SELECT Id,StageName,Record_Locked__c FROM Opportunity WHERE ID IN:assetOppIds]){
                opp.Record_Locked__c = false;
                opp.StageName ='Stage 1';
                oppToBeUpdated.add(opp);
            }
            //close any open renewals
            /*List<Opportunity> renewalOpps = closeOpenRenewalOpportunity(assetIds,'No Decision / Non-Responsive');
            if(!renewalOpps.isEmpty()){
                oppToBeUpdated.addAll(renewalOpps);
            }*/

            if(!oppToBeUpdated.IsEmpty()){
                update oppToBeUpdated;
                if(!assetsToBeUpdated.isEmpty()){
                   sendNotification(assetsToBeUpdated);
                }
            }
        }
        System.debug('##assetsToBeUpdated :'+assetsToBeUpdated);
        if(!assetsToBeUpdated.isEmpty()){
            update assetsToBeUpdated;
        }
    }


    /*
     *This will close any open renewals
    */
    private static List<Opportunity> closeOpenRenewalOpportunity(Set<Id> assetIds,String lostReason){
        List<Opportunity> oppToBeUpdated = new List<Opportunity>();
        for(Opportunity opp : [SELECT ID,StageName FROM Opportunity WHERE Parent_Asset__c IN:assetIds AND IsClosed = false]){
            opp.StageName ='Closed Lost';
            opp.Loss_Reason__c = lostReason ;
            opp.closeDate = Date.today();
            oppToBeUpdated.add(opp);
        }
        return oppToBeUpdated;
    }

    /*
     * Gets the assets based on netsuite Ids
    */
    private static List<Asset> getAssets(Set<string> netsuiteIds){
        // return null;
        return [SELECT ID,Name,Opportunity__c,Opportunity__r.StageName,Status,NetSuite_ID__c,Auto_Renew__c,Cancellation_Reason__c,
                Opportunity__r.Owner.Email,Opportunity__r.Owner.IsActive,Projects__r.Notifications_Group__c,Opportunity__r.Name,
                Projects__c ,Projects__r.Name,Opportunity__r.Type, SalesOrderStatus__c,
                Cancellation_Date__c FROM Asset WHERE NetSuite_ID__c IN:netsuiteIds AND Status NOT IN ('Invoice Cancelled', 'Expired', 'Associate Cancelled')];
    }

    private static void sendNotification(List<Asset> assets){
        Map<String,List<String>> opportunityOwnerByProjectManager = new Map<String,List<String>>();
        Map<Id,List<Asset>> assetByProject = new Map<Id,List<Asset>>();
        for(Asset asset:assets){
            if(asset.Projects__c != null){ // Add this check avoid error in toAddress Empty, by Tushar@cloudroute.in 9 Oct 2020 #2012
                if(!assetByProject.containsKey(asset.Projects__c)){
                    assetByProject.put(asset.Projects__c,new List<Asset>());
                }
                assetByProject.get(asset.Projects__c).add(asset);
            }
        }
        if(!assetByProject.IsEmpty()){
            //send notification
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Id orgWideEmailAddress = Utility.getOrgWideEmailAddress();
            for (String key : assetByProject.keySet()) {
                Asset a = assetByProject.get(key)[0];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String emailBody = 'Hi,';
                emailBody += '<p>Following Renewal Opportunities for '+a.Projects__r.Name;
                emailBody += ' is marked as \'At Risk\' by Finance.</p><br/>';
                for (Asset asset : assetByProject.get(key)) {
                    emailBody += ' <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + asset.Opportunity__c + '"> ' + asset.opportunity__r.Name + '</a> <br/>';
                }
                emailBody += ' <br/><br/>Please Followup with your Customer. <br/><br/>The Linux Foundation';


                List<String> toAddress = new List<String>();
                if(String.isNotBlank(a.Projects__r.Notifications_Group__c)){
                    toAddress.add(a.Projects__r.Notifications_Group__c);
                }else{
                    toAddress.add(a.Opportunity__r.Owner.Email);
                }



                email.setOrgWideEmailAddressId(orgWideEmailAddress);
                email.setHtmlBody(emailBody);
                email.setSubject('\'At Risk\' Renewals');
                email.setToAddresses(toAddress);
                emails.add(email);

            }
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
            }
            catch(Exception ex){
                System.debug('Error sending email=>' + ex.getMessage());
            }

        }
    }
}