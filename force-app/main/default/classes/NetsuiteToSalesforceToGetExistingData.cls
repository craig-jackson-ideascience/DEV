global class NetsuiteToSalesforceToGetExistingData implements Database.Batchable<sObject>, database.allowsCallouts{
	set <string> ids = new set <string> ();
	string query = '';
	public NetsuiteToSalesforceToGetExistingData (set <string> ids){
	 this.ids = ids;
	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		
		query = 'select id, NetSuite_ID__c  from Asset where id in: ids';
		return Database.getQueryLocator(query);
	} 
	
	global void execute(Database.BatchableContext BC, List<asset> scope) {	
        //list < asset > assetList = new list < asset >();
        //assetList.addAll(WrapperToGetSalesOrderDataForExisting.fillingInfo(ids));
		
		
		list<Endpoints__c> endPointObj = new list<Endpoints__c>([select name, endpoint__c, Password__c, User_Id__c   from Endpoints__c where name = 'To Get Sales Order Status From NS']);
            list<String> endPoints = new list <string>();
            String username = '';
            String password = '';
            if(!endPointObj.IsEmpty()){
                //for(string id : ids){
                    endPoints.add(endPointObj[0].endpoint__c + scope[0].NetSuite_ID__c );
                //}
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
                HttpResponse httpresp;
                if(!Test.isRunningTest()) 
                		httpresp = httpO.send(httpRequestObject);
                if(httpresp != null)
                		body = httpresp.getBody();
                system.debug('**getBody**'+body);
                  
                //if(!Test.isRunningTest()){
                list<WrapperToGetSalesOrderDataForExisting> insertAssetWrapper = (list<WrapperToGetSalesOrderDataForExisting>)JSON.deserialize('['+body+']' , list<WrapperToGetSalesOrderDataForExisting>.class);
                assetList.addAll(WrapperToGetSalesOrderDataForExisting.fillingInfo(insertAssetWrapper));
                system.debug('**assetList**'+assetList);
                //}
                
            }  
             if(assetList.size() > 0 ){
                update assetList;
            }
	}
	
	
   global void finish(Database.BatchableContext BC){
   }
	
    
}