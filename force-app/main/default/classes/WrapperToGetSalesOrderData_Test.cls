@isTest
private class WrapperToGetSalesOrderData_Test {
    static testMethod void testWrapper1(){
        
       // String json='[{"id":"21170","recordtype":"salesorder","columns":{"mainline":"*","type":{"name":"Sales Order","internalid":"SalesOrd"},"entity":{"name":"Eldarion, Inc. - LF","internalid":"7825"},"account":{"name":"Sales Orders","internalid":"123"},"amount":5000,"custbody_fully_paid":true,"department":{"name":"Sales","internalid":"10"},"datecreated":"5/19/2016 10:25 am","custbody_primary_email":"billing@eldarion.com"}},{"id":"21170","recordtype":"salesorder","columns":{"mainline":"&nbsp;","type":{"name":"Sales Order","internalid":"SalesOrd"},"entity":{"name":"Eldarion, Inc. - LF","internalid":"7825"},"account":{"name":"4115 Membership Dues : Silver Membership","internalid":"292"},"memo":"2015 Linux Foundation Silver Membership (total employee size 0-99) - Linux Foundation Silver Membership Annual Dues","amount":5000,"custbody_fully_paid":true,"department":{"name":"Sales","internalid":"10"},"datecreated":"5/19/2016 10:25 am","item":{"name":"Membership : 2015 LF Silver Membership (total emp size 0-99)","internalid":"87"},"custbody_primary_email":"billing@eldarion.com"}}]';
        //WrapperToGetSalesOrderData obj= WrapperToGetSalesOrderData.parse(json);
        //WrapperToGetSalesOrderData acc =  (WrapperToGetSalesOrderData)JSON.deserialize(json , WrapperToGetSalesOrderData.class);
        String json = '[{'+
        '   "id": "21170",'+
        '   "recordtype": "salesorder",'+
        '   "columns": {'+
        '       "mainline": "*",'+
        '       "type": {'+
        '           "name": "Sales Order",'+
        '           "internalid": "SalesOrd"'+
        '       },'+
        '       "entity": {'+
        '           "name": "Eldarion, Inc. - LF",'+
        '           "internalid": "7825"'+
        '       },'+
        '       "account": {'+
        '           "name": "Sales Orders",'+
        '           "internalid": "123"'+
        '       },'+
        '       "amount": 5000,'+
        '       "custbody_fully_paid": true,'+
        '       "department": {'+
        '           "name": "Sales",'+
        '           "internalid": "10"'+
        '       },'+
        '       "datecreated": "5/19/2016 10:25 am",'+
        '       "custbody_primary_email": "billing@eldarion.com"'+
        '   }'+
        '}, {'+
        '   "id": "21170",'+
        '   "recordtype": "salesorder",'+
        '   "columns": {'+
        '       "mainline": "&nbsp;",'+
        '       "type": {'+
        '           "name": "Sales Order",'+
        '           "internalid": "SalesOrd"'+
        '       },'+
        '       "entity": {'+
        '           "name": "Eldarion, Inc. - LF",'+
        '           "internalid": "7825"'+
        '       },'+
        '       "account": {'+
        '           "name": "4115 Membership Dues : Silver Membership",'+
        '           "internalid": "292"'+
        '       },'+
        '       "memo": "2015 Linux Foundation Silver Membership (total employee size 0-99) - Linux Foundation Silver Membership Annual Dues",'+
        '       "amount": 5000,'+
        '       "custbody_fully_paid": true,'+
        '       "department": {'+
        '           "name": "Sales",'+
        '           "internalid": "10"'+
        '       },'+
        '       "datecreated": "5/19/2016 10:25 am",'+
        '       "item": {'+
        '           "name": "Membership : 2015 LF Silver Membership (total emp size 0-99)",'+
        '           "internalid": "87"'+
        '       },'+
        '       "custbody_primary_email": "billing@eldarion.com"'+
        '   }'+
        '}]';
        
         // WrapperToGetSalesOrderData obj =parse(json);        //list<WrapperToGetSalesOrderData> insertAssetWrapper = (list<WrapperToGetSalesOrderData>)JSON.deserialize('[{"id":"21170","recordtype":"salesorder","columns":{"mainline":"*","type":{"name":"Sales Order","internalid":"SalesOrd"},"entity":{"name":"Eldarion, Inc. - LF","internalid":"7825"},"account":{"name":"Sales Orders","internalid":"123"},"amount":5000,"custbody_fully_paid":true,"department":{"name":"Sales","internalid":"10"},"datecreated":"5/19/2016 10:25 am","custbody_primary_email":"billing@eldarion.com"}},{"id":"21170","recordtype":"salesorder","columns":{"mainline":"&nbsp;","type":{"name":"Sales Order","internalid":"SalesOrd"},"entity":{"name":"Eldarion, Inc. - LF","internalid":"7825"},"account":{"name":"4115 Membership Dues : Silver Membership","internalid":"292"},"memo":"2015 Linux Foundation Silver Membership (total employee size 0-99) - Linux Foundation Silver Membership Annual Dues","amount":5000,"custbody_fully_paid":true,"department":{"name":"Sales","internalid":"10"},"datecreated":"5/19/2016 10:25 am","item":{"name":"Membership : 2015 LF Silver Membership (total emp size 0-99)","internalid":"87"},"custbody_primary_email":"billing@eldarion.com"}}]' , list<WrapperToGetSalesOrderData>.class);
        
    }
    public static testmethod void unittest1(){
    
        String json1 = '[{'+
        '   "id": "21170",'+
        '   "recordtype": "salesorder",'+
        '   "columns": {'+
        '       "mainline": "*",'+
        '       "type": {'+
        '           "name": "Sales Order",'+
        '           "internalid": "SalesOrd"'+
        '       },'+
        '       "entity": {'+
        '           "name": "Eldarion, Inc. - LF",'+
        '           "internalid": "7825"'+
        '       },'+
        '       "account": {'+
        '           "name": "Sales Orders",'+
        '           "internalid": "123"'+
        '       },'+
        '       "amount": 5000,'+
        '       "custbody_fully_paid": true,'+
        '       "department": {'+
        '           "name": "Sales",'+
        '           "internalid": "10"'+
        '       },'+
        '       "datecreated": "5/19/2016 10:25 am",'+
        '       "custbody_primary_email": "billing@eldarion.com"'+
        '   }'+
        '}, {'+
        '   "id": "21170",'+
        '   "recordtype": "salesorder",'+
        '   "columns": {'+
        '       "mainline": "&nbsp;",'+
        '       "type": {'+
        '           "name": "Sales Order",'+
        '           "internalid": "SalesOrd"'+
        '       },'+
        '       "entity": {'+
        '           "name": "Eldarion, Inc. - LF",'+
        '           "internalid": "7825"'+
        '       },'+
        '       "account": {'+
        '           "name": "4115 Membership Dues : Silver Membership",'+
        '           "internalid": "292"'+
        '       },'+
        '       "memo": "2015 Linux Foundation Silver Membership (total employee size 0-99) - Linux Foundation Silver Membership Annual Dues",'+
        '       "amount": 5000,'+
        '       "custbody_fully_paid": true,'+
        '       "department": {'+
        '           "name": "Sales",'+
        '           "internalid": "10"'+
        '       },'+
        '       "datecreated": "5/19/2016 10:25 am",'+
        '       "item": {'+
        '           "name": "Membership : 2015 LF Silver Membership (total emp size 0-99)",'+
        '           "internalid": "87"'+
        '       },'+
        '       "custbody_primary_email": "billing@eldarion.com"'+
        '   }'+
        '}]';
        
        list<WrapperToGetSalesOrderData> wrapList = new list<WrapperToGetSalesOrderData>();
        //WrapperToGetSalesOrderData.cls_entity entityClass = new WrapperToGetSalesOrderData.cls_entity();
       // entityClass.internalid = '9560';
        //entityClass.name = 'Samsung Electronics America, Inc. - LF';
        
        
        WrapperToGetSalesOrderData warpObj = new WrapperToGetSalesOrderData();
        //warpObj.custbody_tlf_needs_upload_to_portal = true;
        //warpObj.entity = entityClass;
        
        
        wrapList.add(warpObj);
        //WrapperToGetSalesOrderData.fillingInfo(wrapList);
        
        set<string> assetSet = new set <string>();
        Account acc = new Account();
        acc.Name = 'TEST ACC';
        insert acc;
        Asset assetObj = new Asset ();
        assetObj.Name = 'Test';
        assetObj.Number_of_Years_Required__c = 1;
        assetObj.AccountID = acc.id;
        assetObj.NetSuite_ID__c ='21170';
        insert assetObj;
        
        assetSet.add(assetObj.id);
       
         
         list< WrapperForGettingSalesOrder > insertAssetWrapper = (list< WrapperForGettingSalesOrder >)JSON.deserialize(json1 , list< WrapperForGettingSalesOrder >.class);
          WrapperToGetSalesOrderData.fillingInfo(insertAssetWrapper);
    }
    
}