/********************************************************
 * Created by: CloudRoute @ CloudRoute Solutions
 * Created Date: 17/03/20.
 * Description: APIRequestLogTest
 ********************************************************/
@isTest
public class APIRequestLogTest {

    @isTest
    public static void ApiRequestLog_Test(){
        Id requestId = APIRequestLog.createApiRequestlog('Body', 'source');
        ApiRequestLog.updateApiRequestLog(requestId, 'Error Message');
    }
    
    
    
    @isTest
    public static void ApiRequestLog_Test1(){
        
        
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc1=new Account();
        acc1.RecordTypeId=recordTypeId;
        acc1.P_O_Required__c=false;
        acc1.FirstName = 'TestPersonAccountFirst';
        acc1.LastName = 'TestPersonAccountLast';
        acc1.PersonEmail = 'test1@user.com';
        acc1.P_O_Required__c=false;
        insert acc1;
        
        ApiRequestLog.upsertApiLogs(null, new Map<id, sObject>{acc1.ID => acc1}, 'Account', 'INSERT');
        
        API_Request__c log = [Select id from API_Request__c where ObjectName__c = 'Account' and Record_Id__c =: acc1.id limit 1];
        ApiRequestLog.updateApiLog((String)log.ID, String.valueof(acc1), String.valueof(acc1));
        
    }
    
    @isTest
    public static void ApiRequestLog_Test2(){
        
        
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc1=new Account();
        acc1.RecordTypeId=recordTypeId;
        acc1.P_O_Required__c=false;
        acc1.FirstName = 'TestPersonAccountFirst';
        acc1.LastName = 'TestPersonAccountLast';
        acc1.PersonEmail = 'test1@user.com';
        acc1.P_O_Required__c=false;
        insert acc1;
        
         API_Request__c obj = new API_Request__c();
         obj.After_Update__c = JSON.serialize(acc1);
         obj.Before_Update__c =  JSON.serialize(acc1);
         obj.Record_Id__c = acc1.ID;
         obj.ObjectName__c = 'Account';
         insert obj;
        
        ApiRequestLog.upsertApiLogs(new Map<id, sObject>{acc1.ID => acc1}, new Map<id, sObject>{acc1.ID => acc1}, 'Account', 'UPDATE');
        
      }
      
    @isTest
    public static void ApiRequestLog_Test3(){
    
    
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc1=new Account();
        acc1.RecordTypeId=recordTypeId;
        acc1.P_O_Required__c=false;
        acc1.FirstName = 'TestPersonAccountFirst';
        acc1.LastName = 'TestPersonAccountLast';
        acc1.PersonEmail = 'test1@user.com';
        acc1.P_O_Required__c=false;
        insert acc1;
        
        Account acc2=new Account();
        acc2.RecordTypeId=recordTypeId;
        acc2.P_O_Required__c=false;
        acc2.FirstName = 'TestPersonAccountFirst';
        acc2.LastName = 'TestPersonAccountLast';
        acc2.PersonEmail = 'test2@user.com';
        acc2.P_O_Required__c=false;
        insert acc2;
        
        API_Request__c obj = new API_Request__c();
        obj.After_Update__c = JSON.serialize(acc1);
        obj.Before_Update__c =  JSON.serialize(acc1);
        obj.Record_Id__c = acc2.ID;
        obj.ObjectName__c = 'Account';
        insert obj;
        
        ApiRequestLog.upsertApiLogs(new Map<id, sObject>{acc2.ID => acc2}, new Map<id, sObject>{acc1.ID => acc1}, 'Account', 'UPDATE');
        
    }
    
  
}