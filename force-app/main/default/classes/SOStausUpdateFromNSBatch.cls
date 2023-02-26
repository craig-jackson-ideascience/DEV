public class SOStausUpdateFromNSBatch implements Database.Batchable<SalesOrderDataWrapper>, Database.AllowsCallouts,schedulable {
    String objectName;
    
    public SOStausUpdateFromNSBatch(String objectName){
        this.objectName = objectName;
    }
    
    public void execute(SchedulableContext sc)
    {
        SOStausUpdateFromNSBatch batchSchedule = new SOStausUpdateFromNSBatch(objectName);
        Database.executebatch(batchSchedule);
    }

    public Iterable <SalesOrderDataWrapper> start(Database.BatchableContext BC) {
        return getSalesOrderFromNetSuite();
    }
    
    public void execute(Database.BatchableContext BC, List<SalesOrderDataWrapper> scope) {
        Set<String> ids = new Set<string>();
        for (SalesOrderDataWrapper wrapper : scope) {
            ids.add(wrapper.id);
        }
        List <sObject> sObjects = new List <sObject>();
        sObjects.addAll(SalesOrderDataWrapper.fillingInfo(scope,objectName));

        if (sObjects.size() > 0) {
            update sObjects;
        }
    }

    public void finish(Database.BatchableContext BC) {

    }
    
    private List<SalesOrderDataWrapper> getSalesOrderFromNetSuite(){
        List<SalesOrderDataWrapper> salesOrderWrapper = new List<SalesOrderDataWrapper>();
        List<Endpoints__c> endPointObj = new List<Endpoints__c>([select name, endpoint__c,Nlauth_Account__c, Password__c, User_Id__c from Endpoints__c where name = 'To Get Sales Order ID From NS']);
        if(!endPointObj.isEmpty()){
            HttpResponse response = CallOutToNetSuiteForAsset.calloutToNetSuite(endPointObj[0], 'GET', '');
            System.debug('Response==>' + response.getBody());
            if(response.getBody() != null && String.isNotEmpty(response.getBody())){
                 salesOrderWrapper = (List<SalesOrderDataWrapper>) JSON.deserialize(response.getBody(), List<SalesOrderDataWrapper>.class);
            }
        }
        //Modified by Priyesh @CloudrouteSolutions, added null condition because batch throws error "Start did not return a valid iterable object." when salesOrderWrapper is NULL
        if(salesOrderWrapper != null) {
            System.debug('salesOrderWrapper is not null: ' + salesOrderWrapper);
            return salesOrderWrapper;
        }else{
            System.debug('salesOrderWrapper is null: ');
            List<SalesOrderDataWrapper> salesOrderWrapperEmpty = new List<SalesOrderDataWrapper>();
            return salesOrderWrapperEmpty;
        }
    }
}