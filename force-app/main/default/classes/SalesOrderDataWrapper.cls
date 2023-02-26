public class SalesOrderDataWrapper {
    
    public String id;
    public String recordtype;
    public Columns columns;
    
    public class Columns {
        public boolean custbody_fully_paid;
    }
    
    public static List<sObject> fillingInfo(List<SalesOrderDataWrapper> wrapperList,String objectName) { 
        System.debug('wrapperList'+wrapperList);
        Map<String, SalesOrderDataWrapper > netsuiteIdVsWrapperMap = new Map<String, SalesOrderDataWrapper>();
        List<sObject> updatedList = new List<sObject>();
        for (SalesOrderDataWrapper wrapper : wrapperList) {
            netsuiteIdVsWrapperMap.put(wrapper.id, wrapper);
        }
        Set<String> netSuiteIds = netsuiteIdVsWrapperMap.keyset();
        String query = 'SELECT SalesOrder_Status__c,Salesorder_Number__c,NetSuite_ID__c FROM '+
        				objectName + ' where NetSuite_ID__c IN:netSuiteIds';
        
        System.debug('Query==>' + query);
        //List<sObject> sObjects = Database.query(query);
        for(Sobject obj : Database.query(query)){
            String netSuiteId = (String)obj.get('NetSuite_ID__c');
            if (netsuiteIdVsWrapperMap.containsKey(netSuiteId) && netsuiteIdVsWrapperMap.get(netSuiteId) != null &&
                netsuiteIdVsWrapperMap.get(netSuiteId).columns != null && netsuiteIdVsWrapperMap.get(netSuiteId).columns.custbody_fully_paid) {
                    obj.put('SalesOrder_Status__c','Closed');                   
                } else {
                    obj.put('SalesOrder_Status__c','Open');
                }
            updatedList.add(obj);
        }
        return updatedList;
    }
    
    
}