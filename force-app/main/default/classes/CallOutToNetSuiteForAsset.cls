/*-********************************************************************************************************
* Name         : CallOutToNetSuiteForAsset
* @Author      : Akshaye Sharma(Akshaye@wiserspread.com)
* @Date        : 24-October-2017
* @Description : This apex class does Authorization To NetSuite And Send Data To Netsuite.  
* UPDATES
* Version          Developer                    Date                        Description
*-------------------------------------------------------------------------------------------
*     1.0           Akshaye                 24-October-2017                 Initial Creation 
Test Class - TestOpportunityTrigger and CallOutToNetSuiteForAssetTest (Covered From two test classes)
****************************************************************************************************************/


public with sharing class CallOutToNetSuiteForAsset {


    @future(callout=true)
    public static void callingCallOutToNet(string jsonForNetsuite, String endPoint, set<string> idSet) {


        callOutToNetForMemberAsset(endPoint, 'POST', jsonForNetsuite, idSet);
    }


    //Authorizing into Netsuite And Sending Data
    public static void callOutToNetForMemberAsset(String endPoint, String methodName, string bodyTes, set<string> ids) {
        list<Endpoints__c> endPointList = new list<Endpoints__c>([select name, endpoint__c, Password__c, User_Id__c, Nlauth_Account__c from Endpoints__c where name = 'For Product Details']);
        string endpointForCallOut = '';
        string username = '';
        string password = '';
        string Nlauth_Account = '';
        if (!endPointList.isEmpty()) {
            endpointForCallOut = endPointList[0].endpoint__c;
            username = endPointList[0].User_Id__c;
            password = endPointList[0].Password__c;
            Nlauth_Account = endPointList[0].Nlauth_Account__c;
        }
        String accId = '';
        String subSdiaryId = '';
        // CallOutToNetSuiteWrapperForProduct temObj = CallOutToNetSuiteWrapperForProduct.parse(acc); 
        //string body = JSON.serialize(temObj) ;
        if (bodyTes != null && bodyTes != '') {

            AssetToSalesOrderHelper.AssetMemberWrapper acc = (AssetToSalesOrderHelper.AssetMemberWrapper) JSON.deserialize(bodyTes, AssetToSalesOrderHelper.AssetMemberWrapper.class);

            if (acc != null && acc.accId != null) {
                String accountBodyInString = String.valueOf(acc.accJson);
                ErrorWrapperForAccountNetsuite error = CallOutToNetSuiteForAsset.callOutToNetForAccount(endpointForCallOut, 'POST', accountBodyInString, accId);
                if (error.statuscode != 200) {
                    List<Asset> assetList = new List<Asset>();
                    for (Asset assetO : [SELECT NetSuite_Error__c,netsuite_id__c,SalesOrderNumber__c FROM Asset WHERE ID IN:ids]) {
                        assetO.NetSuite_Error__c = 'NetSuite sync. failed to work for the Account' + error.body;
                        assetList.add(assetO);
                    }
                    if (!assetList.isEmpty()) {
                        update assetList;
                        return;
                    }

                } else {
                    subSdiaryId = error.body;
                }
                accId = acc.accId;
                List<Object> objLi = (List<Object>) JSON.deserializeUntyped(acc.JsonBody);
                for (Object o : objLi) {
                    Map<String, Object> oj = (Map<string, Object>) o;
                    oj.put('entity', subSdiaryId);
                }
                acc.jsonBody = JSON.serialize(objLi);
            }

            // CallOutToNetSuiteWrapperForProduct temObj = CallOutToNetSuiteWrapperForProduct.parse(acc); 
            //string body = JSON.serialize(temObj) ;
            system.debug(bodyTes);
            system.debug(acc.jsonBody);
            HttpRequest httpRequestObject = new HttpRequest();
            httpRequestObject.setMethod(methodName);
            httpRequestObject.setTimeout(119990);
            httpRequestObject.setBody(acc.jsonBody);


            String autharizationHeadr = '';
            /*if(Label.IsProduction.equalsIgnoreCase('Yes')){
                autharizationHeadr= 'NLAuth nlauth_account='+Label.Netsuite_Production_Account+',nlauth_e-mail='+Label.Netsuite_Production_Username+',nlauth_signature='+Label.Netsuite_Production_Password;
            
            }*/
            // else{
            autharizationHeadr = 'NLAuth nlauth_signature=' + password + ',nlauth_email=' + username + ',nlauth_account=' + Nlauth_Account;

            //}

            system.debug(autharizationHeadr);
            httpRequestObject.setHeader('Content-Type', 'application/json');
            system.debug('**autharizationHeadr**' + autharizationHeadr);

            httpRequestObject.setHeader('Authorization', autharizationHeadr);
            httpRequestObject.setEndpoint(endPoint);
            system.debug('Endpoint is ==>'+endPoint);
            Http httpO = new Http();
            HttpResponse httpresp = new HttpResponse();

            boolean makeCallout = false;
            list <asset> assetList = [select opportunity__r.Amount from asset where id in:Ids];

            for (asset assetObj : assetList) {
                system.debug('**assetObj.opportunity__r.Amount' + assetObj.opportunity__r.Amount);
                if (assetObj.opportunity__r.Amount <= 0) {
                    makeCallout = true;
                    return;
                }
            }
            system.debug('**makeCallout' + makeCallout);
            if (makeCallout == false) {
                httpresp = httpO.send(httpRequestObject);
            }
            system.debug(httpresp.getBody());
            string body = httpresp.getBody();
            list <asset> assetListToUpdate = new list <asset>();
            if (httpResp.getStatusCode() == 200 || httpResp.getStatusCode() == 201) {
                system.debug('Body is ====>'+body);
                list<WrapperToGetSalesOrderData> insertAssetWrapper = (list<WrapperToGetSalesOrderData>) JSON.deserialize(body, list<WrapperToGetSalesOrderData>.class);
                System.debug('SalesOrderResult==>' + insertAssetWrapper);
                //assetList.addAll(WrapperToGetSalesOrderData.fillingInfo(insertAssetWrapper));
                integer i = 0;
                for (Asset assetO : [SELECT NetSuite_Error__c,netsuite_id__c,SalesOrderNumber__c FROM Asset WHERE ID IN:ids]) {
                    WrapperToGetSalesOrderData wrap = insertAssetWrapper.get(i);
                    assetO.netsuite_id__c = wrap.id;
                    assetO.SalesOrderNumber__c = wrap.tranid;
                    assetO.SalesOrderStatus__c ='Open';
                    i++;
                    assetListToUpdate.add(assetO);
                }
                if (!assetListToUpdate.isEmpty() && assetListToUpdate.size() > 0) {
                    update assetListToUpdate;
                }

            } else {
                for (Asset assetO : [SELECT NetSuite_Error__c,netsuite_id__c,SalesOrderNumber__c FROM Asset WHERE ID IN:ids]) {
                    assetO.NetSuite_Error__c = 'NetSuite Sync Failed to work for the account sync around line 132:' + httpresp.getBody();
                    assetListToUpdate.add(assetO);
                }
                if (!assetListToUpdate.isEmpty()) {
                    update assetListToUpdate;
                }

            }
            // }
            if (accId != '') {
                List<Asset> asstList = [SELECT netsuite_id__c, Bill_From_ID__c FROM Asset WHERE ID = :ids];

                if (asstList != null && !asstList.isEmpty()) {
                    Account_And_Project__c apa = new Account_And_Project__c();
                    apa.Account__c = accId;
                    apa.Project__c = asstList[0].Bill_From_ID__c;
                    apa.Netssuite_ID__c = subSdiaryId;
                    upsert apa Netssuite_ID__c;


                }

            }


        }
    }

    /* @Future(callout=true)
    public static void callOutToNet(String endPoint ,String methodName,string bodyTes,set<id> ids){
            
                
           // CallOutToNetSuiteWrapperForProduct temObj = CallOutToNetSuiteWrapperForProduct.parse(acc); 
            //string body = JSON.serialize(temObj) ;
            system.debug(bodyTes);
            HttpRequest httpRequestObject = new HttpRequest();
            httpRequestObject.setMethod(methodName);
            httpRequestObject.setTimeout(119990);
            httpRequestObject.setBody(bodyTes);
            
            
            String autharizationHeadr = '';
            if(Label.IsProduction.equalsIgnoreCase('Yes')){
                autharizationHeadr= 'NLAuth nlauth_account='+Label.Netsuite_Production_Account+',nlauth_e-mail='+Label.Netsuite_Production_Username+',nlauth_signature='+Label.Netsuite_Production_Password;
            
            }
           // else{
                autharizationHeadr= 'NLAuth nlauth_signature=Wiserspread1!,nlauth_email=sfcontractor@linuxfoundation.org,nlauth_account=4010327';
            
            //}
            
            system.debug(autharizationHeadr);
            httpRequestObject.setHeader('Content-Type','application/json');   
            system.debug('**autharizationHeadr**'+autharizationHeadr);
            
            httpRequestObject.setHeader('Authorization',autharizationHeadr);
            httpRequestObject.setEndpoint(endPoint);
            Http httpO = new Http();
            HttpResponse httpresp = new HttpResponse();
            if (!Test.isRunningTest())
                    httpresp = httpO.send(httpRequestObject);
            system.debug('**getBody**'+httpresp.getBody());
            integer i = 0;
            if(httpResp != null && httpResp.getStatusCode() == 200){
                for(Asset assetO : [SELECT netsuite_id__c FROM Asset WHERE ID IN:ids]){
                    assetO.netsuite_id__c = httpResp.getBody().replaceAll('"' , '').split(',')[i];
                    i++;
                    update assetO;
                }
            }
             
          
            
            
    }*/


    @future(callout=true)
    public static void callOutToNet(String endPoint, String methodName, string bodyTes, String ids, set<id> assetsIds) {
        list<Endpoints__c> endPointList = new list<Endpoints__c>([select name, endpoint__c, Password__c, User_Id__c, Nlauth_Account__c from Endpoints__c where name = 'For Product Details']);
        string endpointForCallOut = '';
        string username = '';
        string password = '';
        string Nlauth_Account = '';
        if (!endPointList.isEmpty()) {
            endpointForCallOut = endPointList[0].endpoint__c;
            username = endPointList[0].User_Id__c;
            password = endPointList[0].Password__c;
            Nlauth_Account = endPointList[0].Nlauth_Account__c;
        }
        String accId = '';
        String subSdiaryId = '';
        // CallOutToNetSuiteWrapperForProduct temObj = CallOutToNetSuiteWrapperForProduct.parse(acc); 
        //string body = JSON.serialize(temObj) ;
        if (bodyTes != null && bodyTes != '') {

            map<String, Object> jsonBody = (map<String, Object>) JSON.deserializeUntyped(bodyTes);
            if (jsonBody != null && jsonBody.containsKey('syncAccount')) {
                String accountBodyInString = String.valueOf(jsonBody.get('syncAccount'));

                accId = String.valueOf(jsonBody.get('accId'));
                ErrorWrapperForAccountNetsuite error = CallOutToNetSuiteForAsset.callOutToNetForAccount(endpointForCallOut, 'POST', accountBodyInString, accId);               
                if (error.statuscode != 200) {

                    list <asset> assetList = [select opportunity__r.Amount, NetSuite_Error__c from asset where id = :Ids];
                    assetList[0].NetSuite_Error__c = 'NetSuite Sync Failed on line 235' + error.body;
                    update assetList[0];
                    return;

                } else {
                    subSdiaryId = error.body;

                }
                jsonBody.remove('syncAccount');
                jsonBody.remove('accId');
                jsonBody.put('entity', subSdiaryId);
                bodyTes = JSON.serialize(jsonBody);
            }/* else if (jsonBody != null && jsonBody.containsKey('syncBillAccount')) {
                String accountBodyInString = String.valueOf(jsonBody.get('syncBillAccount'));


                accId = String.valueOf(jsonBody.get('accId'));
                ErrorWrapperForAccountNetsuite error = CallOutToNetSuiteForAsset.callOutToNetForAccount(endpointForCallOut, 'POST', accountBodyInString, accId);
                if (error.statuscode != 200) {

                    list <asset> assetList = [select opportunity__r.Amount, NetSuite_Error__c from asset where id = :Ids];
                    assetList[0].NetSuite_Error__c = 'NetSuite sync. failed on line 256' + error.body;
                    update assetList[0];
                    return;

                } else {
                    subSdiaryId = error.body;

                }
                jsonBody.remove('syncBillAccount');
                jsonBody.remove('accId');
                jsonBody.put('entity', subSdiaryId);
                bodyTes = JSON.serialize(jsonBody);
            }*/
        }

        system.debug(bodyTes);
        HttpRequest httpRequestObject = new HttpRequest();
        httpRequestObject.setMethod(methodName);
        httpRequestObject.setTimeout(119990);
        httpRequestObject.setBody(bodyTes);


        String autharizationHeadr = '';
        /*if(Label.IsProduction.equalsIgnoreCase('Yes')){
            autharizationHeadr= 'NLAuth nlauth_account='+Label.Netsuite_Production_Account+',nlauth_e-mail='+Label.Netsuite_Production_Username+',nlauth_signature='+Label.Netsuite_Production_Password;
        
        }*/
        // else{
        autharizationHeadr = 'NLAuth nlauth_signature=' + password + ',nlauth_email=' + username + ',nlauth_account=' + Nlauth_Account;

        //}

        system.debug(autharizationHeadr);
        httpRequestObject.setHeader('Content-Type', 'application/json');
        system.debug('**autharizationHeadr**' + autharizationHeadr);

        httpRequestObject.setHeader('Authorization', autharizationHeadr);
        httpRequestObject.setEndpoint(endPoint);
        Http httpO = new Http();
        HttpResponse httpresp = new HttpResponse();


        boolean makeCallout = false;
        list <asset> assetList = [select opportunity__r.Amount from asset where id = :Ids];
        for (asset assetObj : assetList) {
            if (assetObj.opportunity__r.Amount <= 0) {
                makeCallout = true;
                return;
            }
        }
        if (makeCallout == false ) {
            httpresp = httpO.send(httpRequestObject);
        }
        system.debug('**getBody now**' + httpresp.getBody());
        string body = httpresp.getBody();
        list <asset> assetListToUpdate = new list <asset>();
        WrapperToGetSalesOrderData insertAssetWrapper = (WrapperToGetSalesOrderData) JSON.deserialize(body, WrapperToGetSalesOrderData.class);
        System.debug('Netsuite response of sales Order==>' + insertAssetWrapper);
        integer i = 0;
        //if(httpResp != null && httpResp.getStatusCode() == 200){
        for (Asset assetO : [SELECT NetSuite_Error__c,netsuite_id__c,SalesOrderNumber__c FROM Asset WHERE ID IN:assetsIds AND Skip_NetSuite_Sync__c = FALSE]) {
            //assetO.netsuite_id__c = httpResp.getBody().replaceAll('"' , '').split(',')[i];
            if (httpresp.getStatusCode() != 200 && httpresp.getStatusCode() != 201) {
                assetO.NetSuite_Error__c = 'NetSuite sync. failed attempting to create the sales order' + httpresp.getBody();
                assetListToUpdate.add(assetO);
            } else {
                assetO.netsuite_id__c = insertAssetWrapper.id;
                assetO.SalesOrderNumber__c = insertAssetWrapper.tranid;
                assetO.SalesOrderStatus__c ='Open';
                i++;
                assetListToUpdate.add(assetO);
            }
            if (!assetListToUpdate.isEmpty() && assetListToUpdate.size() > 0) {
                update assetListToUpdate;
            }
        }
        //}
        if (accId != '') {
            List<Asset> asstList = [SELECT netsuite_id__c, Event__c, Event__r.BillFromProject__c,Training__c,Bill_from_ID__c FROM Asset WHERE ID = :ids];

            if (asstList != null && !asstList.isEmpty()) {
                Account_And_Project__c apa = new Account_And_Project__c();                
                apa.Account__c = accId;
                apa.Project__c = asstList[0].Training__c != null ? asstList[0].Bill_from_ID__c : asstList[0].Event__r.BillFromProject__c;
                apa.Netssuite_ID__c = subSdiaryId;
                upsert apa Netssuite_ID__c;


            }

        }


    }

    public static ErrorWrapperForAccountNetsuite callOutToNetForAccount(String endPoint, String methodName, string body, String ids) {
        List<Endpoints__c> endPointList = [select name, endpoint__c, Password__c, User_Id__c,Nlauth_Account__c from Endpoints__c where name = 'For Product Details'];

        string username = '';
        string password = '';
        string Nlauth_Account = '';
        if (!endPointList.isEmpty()) {

            username = endPointList[0].User_Id__c;
            password = endPointList[0].Password__c;
            Nlauth_Account = endPointList[0].Nlauth_Account__c;
        }

		HttpResponse httpresp = calloutToNetSuite(endPointList[0],methodName,body);
        
            
        // CallOutToNetSuiteWrapperForProduct temObj = CallOutToNetSuiteWrapperForProduct.parse(acc); 
        //string body = JSON.serialize(temObj) ;
        /*system.debug(body);
        HttpRequest httpRequestObject = new HttpRequest();
        httpRequestObject.setMethod(methodName);
        httpRequestObject.setTimeout(119990);
        httpRequestObject.setBody(body);

        String authorizationHeader = 'NLAuth nlauth_signature=' + password + ',nlauth_email=' + username + ',nlauth_account=' + Nlauth_Account;

        httpRequestObject.setHeader('Content-Type', 'application/json');
        httpRequestObject.setHeader('Authorization', authorizationHeader);
        httpRequestObject.setEndpoint(endPoint);
        Http httpO = new Http();
        HttpResponse httpresp = new HttpResponse();
        if (!Test.isRunningTest())
            httpresp = httpO.send(httpRequestObject);
        system.debug('**getBody**' + httpresp.getBody());
        string responseBody = httpresp.getBody();
        integer i = 0;*/
        if (httpResp != null && httpResp.getStatusCode() == 200) {
            List<Account> accList = new List<Account>();
            /*  for(Account acc : [SELECT netsuite_id__c FROM Account WHERE ID =:ids]){
acc.netsuite_id__c = httpResp.getBody().replaceAll('"' , '');
accList.add(acc);
}
update accList;*/
            ErrorWrapperForAccountNetsuite errorWrapper = new ErrorWrapperForAccountNetsuite(httpResp.getBody().replaceAll('"', ''), httpResp.getStatusCode());
            return errorWrapper;
        } else {

            ErrorWrapperForAccountNetsuite errorWrapper = new ErrorWrapperForAccountNetsuite(httpResp.getBody(), httpResp.getStatusCode());
            return errorWrapper;
        }

        return null;

    }

    /*
     * This is generic method for making netsuite callouts
	*/
    public static HttpResponse calloutToNetSuite(Endpoints__c settings, String methodName, string body) {
        HttpRequest httpRequestObject = new HttpRequest();
        httpRequestObject.setMethod(methodName);
        httpRequestObject.setTimeout(119990);
        if(String.isNotBlank(body)){
            httpRequestObject.setBody(body);
        }
        

        String authorizationHeader = 'NLAuth nlauth_signature=' + settings.Password__c + ',nlauth_email=' + settings.User_Id__c + ',nlauth_account=' + settings.Nlauth_Account__c;

        httpRequestObject.setHeader('Content-Type', 'application/json');
        httpRequestObject.setHeader('Authorization', authorizationHeader);
        httpRequestObject.setEndpoint(settings.Endpoint__c);
        Http http = new Http();
        HttpResponse httpResponse = http.send(httpRequestObject);
        return httpResponse;
    }

}