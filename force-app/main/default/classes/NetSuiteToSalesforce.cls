global class NetSuiteToSalesforce implements Database.Batchable<WrapperForGettingSalesOrder>, database.allowsCallouts{

    global iterable<WrapperForGettingSalesOrder> start(Database.BatchableContext BC){
            
           
      //Authorizing into Netsuite And Sending Data
   
            list<Endpoints__c> endPointObj = new list<Endpoints__c>([select name, endpoint__c, Password__c, User_Id__c   from Endpoints__c where name = 'To Get Sales Order ID From NS']);
            String endPoint = '';
            String username = '';
            String password = '';
            if(!endPointObj.IsEmpty()){
                endPoint = endPointObj[0].endpoint__c;
                username = endPointObj[0].User_Id__c;
                password = endPointObj[0].Password__c;
            }    
           
            HttpRequest httpRequestObject = new HttpRequest();
            httpRequestObject.setMethod('GET');
            httpRequestObject.setTimeout(119990);
            //httpRequestObject.setBody(bodyTes);
            
            
            String autharizationHeadr = '';
            /*if(Label.IsProduction.equalsIgnoreCase('Yes')){
                autharizationHeadr= 'NLAuth nlauth_account='+Label.Netsuite_Production_Account+',nlauth_e-mail='+Label.Netsuite_Production_Username+',nlauth_signature='+Label.Netsuite_Production_Password;
            
            }*/
           // else{
                autharizationHeadr= 'NLAuth nlauth_signature='+password+',nlauth_email='+username+',nlauth_account=4010327';
            
            //}
            
            system.debug(autharizationHeadr);
            httpRequestObject.setHeader('Content-Type','application/json');   
            system.debug('**autharizationHeadr**'+autharizationHeadr);
            
            httpRequestObject.setHeader('Authorization',autharizationHeadr);
            httpRequestObject.setEndpoint(endPoint);
            Http httpO = new Http();
            HttpResponse httpresp = httpO.send(httpRequestObject);
            string body = httpresp.getBody();
            system.debug('**getBody**'+body);
            
            
            list<WrapperForGettingSalesOrder> insertAssetWrapper = (list<WrapperForGettingSalesOrder>)JSON.deserialize(body , list<WrapperForGettingSalesOrder>.class); 
            if(insertAssetWrapper != null){
                return insertAssetWrapper;             
             }else{
                 list<WrapperForGettingSalesOrder> newInsertAssetWrapper = new list<WrapperForGettingSalesOrder>();
                 return newInsertAssetWrapper;
             }
            
    
    }
    global void execute(Database.BatchableContext BC, List<WrapperForGettingSalesOrder> scope) {
            
            set <String> ids = new set <string>();
            for(WrapperForGettingSalesOrder wrapList : scope){
                ids.add(wrapList.id);
            }
            list < asset > assetList = new list < asset >();
            assetList.addAll(WrapperToGetSalesOrderData.fillingInfo(scope));
            /*list<Endpoints__c> endPointObj = new list<Endpoints__c>([select name, endpoint__c, Password__c, User_Id__c   from Endpoints__c where name = 'To Get Sales Order Status From NS']);
            list<String> endPoints = new list <string>();
            String username = '';
            String password = '';
            if(!endPointObj.IsEmpty()){
                for(string id : ids){
                    endPoints.add(endPointObj[0].endpoint__c + id );
                }
                username = endPointObj[0].User_Id__c;
                password = endPointObj[0].Password__c;
            }    
            string body = '';
            list < asset > assetList = new list < asset >();
            for(string endpoint : endpoints){
                HttpRequest httpRequestObject = new HttpRequest();
                httpRequestObject.setMethod('GET');
                httpRequestObject.setTimeout(119990);
               // httpRequestObject.setBody(body);
                
                String autharizationHeadr = '';
                /*if(Label.IsProduction.equalsIgnoreCase('Yes')){
                    autharizationHeadr= 'NLAuth nlauth_account='+Label.Netsuite_Production_Account+',nlauth_e-mail='+Label.Netsuite_Production_Username+',nlauth_signature='+Label.Netsuite_Production_Password;
                
                }
               // else{
                    autharizationHeadr= 'NLAuth nlauth_signature='+password+',nlauth_email='+username+',nlauth_account=4010327';
                
                //}
                
               
                system.debug(autharizationHeadr);
                httpRequestObject.setHeader('Content-Type','application/json');   
                system.debug('**autharizationHeadr**'+autharizationHeadr);
                
                httpRequestObject.setHeader('Authorization',autharizationHeadr);
                httpRequestObject.setEndpoint(endPoint);
                Http httpO = new Http(); 
                HttpResponse httpresp = httpO.send(httpRequestObject);
                body = httpresp.getBody();
                system.debug('**getBody**'+body);
                  
                if(!Test.isRunningTest()){
                list<WrapperToGetSalesOrderData> insertAssetWrapper = (list<WrapperToGetSalesOrderData>)JSON.deserialize('['+body+']' , list<WrapperToGetSalesOrderData>.class);
                assetList.addAll(WrapperToGetSalesOrderData.fillingInfo(insertAssetWrapper));
                system.debug('**assetList**'+assetList);
                }
                
            }  */  
           
            if(assetList.size() > 0 ){
                update assetList;
            }
           
          
                        
    
    }
      global void finish(Database.BatchableContext BC) {
        
    }

    
}