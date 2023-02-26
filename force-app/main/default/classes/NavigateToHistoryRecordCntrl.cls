public class NavigateToHistoryRecordCntrl {
    public String HistoryVal{get;set;}
    public List<Asset> PurchaseHistoryRecord{get;set;}
    public List<OpportunityLineItem> OppLine{get;set;}
    public NavigateToHistoryRecordCntrl(){
        PurchaseHistoryRecord = new List<Asset>();
        OppLine = new List<OpportunityLineItem>(); 
        HistoryVal = apexpages.currentpage().getparameters().get('HistoryValue');
        system.debug('======HistoryVal'+HistoryVal);
    }
    public PageReference RedirectToHistoryRecord(){
        List<String>AllValues = new List<String>();
        AllValues = HistoryVal.split('-');
        String accountName = AllValues[0];
        system.debug('============values are '+accountName);
        String eventNameVal = AllValues[1];
         system.debug('============eventNameVal are '+eventNameVal);
        String eventName = eventNameVal.replace('plus','+');
        system.debug('============eventName are '+eventName);
        String productName = AllValues[2];
        String OppRec;
        if(HistoryVal.contains('Pending')){
         OppRec = AllValues[3];
        }
        system.debug('============values are '+productName);
        if(accountName!=null && eventName!=null && productName!=null && OppRec==null){
            PurchaseHistoryRecord = [SELECT Id,Name,Related_To__c,Product2.Name,Event__r.Name,Account.name  FROM Asset WHERE Account.name=:accountName AND Event__r.Name=:eventName AND Product2.Name=:productName limit 1];
        }
        if(accountName!=null && eventName!=null && productName!=null && OppRec!=null){
              OppLine = [SELECT id,OpportunityId,Opportunity.Account.name,Product2.Name,Event__r.Name FROM OpportunityLineItem WHERE Opportunity.Account.name=:accountName AND Event__r.Name=:eventName AND Product2.Name=:productName AND Opportunity.StageName!='Closed Won' AND Opportunity.StageName!='Closed Lost' limit 1];
         }
        system.debug('=======OppLine===='+OppLine);
        Id HistoryId;
        if(PurchaseHistoryRecord.size()>0)
            HistoryId = PurchaseHistoryRecord[0].Id;
        else if(OppLine.size()>0)
            HistoryId = OppLine[0].OpportunityId;
        PageReference p = new PageReference('/'+HistoryId);
        return p;
    }
}