public class APIRequestLog {

    public static Boolean alreadyLogged = FALSE;

    public static String createApiRequestlog(String requestbody, String source) {
        API_Request__c apiRequestObj = new API_Request__c();
        apiRequestObj.Source__c = source;
        apiRequestObj.Request_Body__c = requestbody;
        apiRequestObj.Status__c = 'Success';

        insert apiRequestObj;
        return apiRequestObj.Id;

    }
    
    public static void updateApiLog(String apiId, String beforeUpdate, String afterUpdate) {
        API_Request__c apiRequestObj = new API_Request__c();
        apiRequestObj.Id = apiId;
        apiRequestObj.Before_Update__c = beforeUpdate;
        apiRequestObj.After_Update__c = afterUpdate;
        update apiRequestObj;
    }

    public static void updateApiRequestLog(String apiId, String errortext) {
        API_Request__c apiRequestObj = new API_Request__c();
        apiRequestObj.Id = apiId;
        apiRequestObj.Status__c = 'Error';
        apiRequestObj.Error__c = errortext;

        update apiRequestObj;
    }

    public static void upsertApiLogs(Map<Id, sObject> oldMap, Map<Id, sObject> newMap, String objectName, String Operation) {
        if(!alreadyLogged) {
            alreadyLogged = TRUE;
            Map<Id, API_Request__c>  oppIdVsLog = new Map<Id, API_Request__c>();
            Map<Id, API_Request__c>  apiLogs = new Map<Id, API_Request__c>([Select Id, After_Update__c,Before_Update__c,Record_Id__c,ObjectName__c FROM API_Request__c WHERE ObjectName__c =: objectName AND Record_Id__c IN : newMap.keySet()]); 
            List<API_Request__c> upsertRecs = new List<API_Request__c>();
            if(!apiLogs.isEmpty()) {
                for(API_Request__c logRec :  apiLogs.Values()){
                    oppIdVsLog.put(logRec.Record_Id__c, logRec);
                }
            }

            for(sObject objRec : newMap.values()) {
                if((Operation == 'INSERT' && oppIdVsLog.isEmpty()) || (!oppIdVsLog.isEmpty() && !oppIdVsLog.containskey((ID) objRec.get('Id')))) {
                    API_Request__c obj = new API_Request__c();
                    obj.Before_Update__c =  JSON.serialize(objRec);
                    obj.After_Update__c = JSON.serialize(objRec);
                    obj.Record_Id__c =  (ID) objRec.get('Id');
                    obj.ObjectName__c = objectName;
                    upsertRecs.add(obj);
                }
                else if((!oppIdVsLog.isEMpty() && oppIdVsLog.containskey((ID) objRec.get('Id')))){
                    API_Request__c obj = (API_Request__c) oppIdVsLog.get((Id) objRec.get('Id'));
                    obj.After_Update__c = JSON.serialize(objRec);
                    obj.Before_Update__c =  JSON.serialize(oldMap.get((Id) objRec.get('Id')));
                    upsertRecs.add(obj);
                }
                else if(Operation == 'UPDATE' && (!oppIdVsLog.containskey((ID) objRec.get('Id')))) {
                    API_Request__c obj = new API_Request__c();
                    obj.After_Update__c = JSON.serialize(objRec);
                    obj.Before_Update__c =  JSON.serialize(oldMap.get((Id) objRec.get('Id')));
                    obj.Record_Id__c = (ID) objRec.get('Id');
                    obj.ObjectName__c = objectName;
                    upsertRecs.add(obj);
                }  
                
            }
            if(!upsertRecs.isEmpty()){
                upsert upsertRecs;
            }
        }
        
    }

}