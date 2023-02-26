/*-********************************************************************************************************
* Name         : CallOutToNetSuite
* @Author      : Akshaye Sharma(Akshaye@wiserspread.com)
* @Date        : 17-October-2017
* @Description : This apex class does Authorization To NetSuite And Send Data To Netsuite.  
* UPDATES
* Version          Developer                    Date                        Description
*-------------------------------------------------------------------------------------------
*     1.0           Akshaye                 17-October-2017                 Initial Creation 
****************************************************************************************************************/


public with sharing class CallOutToNetSuite {
    
    
    
    //Calling callOutToNet Method
    /*public static void callingCallOutToNet(string jsonForNetsuite , set<id> ids ){ 
        
        
        calloutToNet('https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl?script=86&deploy=11' , 'POST',jsonForNetsuite,ids);
    }
    */ public static void callingCallOutToNetForBatch(string jsonForNetsuite , String id ){ 
        
        set<Id> idSet = new Set<Id>();
        idSet.add(id);
        list<Endpoints__c> endPoint = new list<Endpoints__c>([select name, endpoint__c from Endpoints__c where name = 'For Product Details']);
        if(!endPoint.IsEmpty()){
            system.debug('**endPoint**'+ endPoint[0]);
            //if(!test.isRunningtest()){
                callOutToNetForBatch( endPoint[0].endpoint__c, 'POST',jsonForNetsuite,idSet);
            //}
        }else{
            system.debug('**no endPoint**'+ endPoint);
        }
    }
    
        public static void callOutToNetForBatch(String endPoint ,String methodName,string bodyTes,set<id> ids){
            
                
           // CallOutToNetSuiteWrapperForProduct temObj = CallOutToNetSuiteWrapperForProduct.parse(acc);  
            //string body = JSON.serialize(temObj) ;
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
            list<Endpoints__c> endPointList = new list<Endpoints__c>([select name, endpoint__c, Password__c, User_Id__c, Nlauth_Account__c from Endpoints__c where name = 'For Product Details']);   
            string username = '';
            string password = '';
            string Nlauth_Account = '';
            if(!endPointList.IsEmpty()){
                username = endPointList[0].User_Id__c;
                password = endPointList[0].Password__c;
                Nlauth_Account = endPointList[0].Nlauth_Account__c;
            }    
            autharizationHeadr= 'NLAuth nlauth_signature='+password+',nlauth_email='+username+',nlauth_account='+Nlauth_Account;
            //}
            
            system.debug(autharizationHeadr);
            httpRequestObject.setHeader('Content-Type','application/json');   
            system.debug('**autharizationHeadr**'+autharizationHeadr);
            
            httpRequestObject.setHeader('Authorization',autharizationHeadr);
            httpRequestObject.setEndpoint(endPoint);
            Http httpO = new Http();
            HttpResponse httpresp= new HttpResponse();
            //if(!Test.isRunningTest())
                     httpresp = httpO.send(httpRequestObject);
            system.debug('**getBody**'+httpresp.getBody());
            system.debug('**code**'+httpresp.getStatusCode());
            system.debug('**resp**'+httpresp);
            list <Product_Details__c> proList = [select Netsuite_ID__c ,NetSuite_Error__c from Product_Details__c where id in:ids ];
             
          
           list<Product_Details__c> proListToUpdate = new list <Product_Details__c>(); 
            
            
            for(Product_Details__c proObj : proList){
                    //for(CallOutToNetSuiteWrapperForProduct proWrapper : wrapper){
                         try{
                             
                             
                             if(httpresp.getStatusCode() != 200 && httpresp.getStatusCode() != 201 ){
                                
                               proObj.NetSuite_Error__c = httpresp.getBody(); 
                               proListToUpdate.add(proObj);
                            }
                            
                            else{
                            
                                    
                                    proObj.NetSuite_Error__c = ''; 
                                    proObj.Netsuite_ID__c = httpresp.getBody().replaceAll('"' , '');
                                    proListToUpdate.add(proObj);
                            }
                    
                     }
                    catch(System.CalloutException e) {
                       
                    }
                    
                    //}
            }
           try{      
        
           update proListToUpdate;
           } 
           catch(System.CalloutException e) {
                       
           } 
    }
    
    
     //Calling callOutToNet Method
    public static void callingCallOutToNet(string jsonForNetsuite , String id ){ 
        
        set<Id> idSet = new Set<Id>();
        idSet.add(id);
        list<Endpoints__c> endPoint = new list<Endpoints__c>([select name, endpoint__c from Endpoints__c where name = 'For Product Details']);
        if(!endPoint.IsEmpty()){
            system.debug('**endPoint**'+ endPoint[0]);
            //if(!test.isRunningtest()){
                calloutToNet( endPoint[0].endpoint__c, 'POST',jsonForNetsuite,idSet);
            //}
        }else{
            system.debug('**no endPoint**'+ endPoint);
        }
    }
    
    //Authorizing into Netsuite And Sending Data
    @Future(callout=true)
    public static void callOutToNet(String endPoint ,String methodName,string bodyTes,set<id> ids){
            
                
           // CallOutToNetSuiteWrapperForProduct temObj = CallOutToNetSuiteWrapperForProduct.parse(acc);  
            //string body = JSON.serialize(temObj) ;
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
            list<Endpoints__c> endPointList = new list<Endpoints__c>([select name, endpoint__c, Password__c, User_Id__c, Nlauth_Account__c from Endpoints__c where name = 'For Product Details']);   
            string username = '';
            string password = '';
            string Nlauth_Account ='';
            if(!endPointList.IsEmpty()){
                username = endPointList[0].User_Id__c;
                password = endPointList[0].Password__c;
                Nlauth_Account = endPointList[0].Nlauth_Account__c;
            }    
            autharizationHeadr= 'NLAuth nlauth_signature='+password+',nlauth_email='+username+',nlauth_account='+Nlauth_Account;
            //autharizationHeadr= 'NLAuth nlauth_account=4010327,nlauth_email='+username +',nlauth_signature='+password;

            
            //}
            
            system.debug(autharizationHeadr);
            httpRequestObject.setHeader('Content-Type','application/json');   
            system.debug('**autharizationHeadr**'+autharizationHeadr);
            
            httpRequestObject.setHeader('Authorization',autharizationHeadr);
            httpRequestObject.setEndpoint(endPoint);
            Http httpO = new Http();
            HttpResponse httpresp= new HttpResponse();
            //if(!Test.isRunningTest())
                     httpresp = httpO.send(httpRequestObject);
            system.debug('**getBody**'+httpresp.getBody());
            list <Product_Details__c> proList = [select Netsuite_ID__c ,NetSuite_Error__c from Product_Details__c where id in:ids ];
             
          
           list<Product_Details__c> proListToUpdate = new list <Product_Details__c>(); 
            
            
            for(Product_Details__c proObj : proList){
                    //for(CallOutToNetSuiteWrapperForProduct proWrapper : wrapper){
                         try{
                             
                             
                             if(httpresp.getStatusCode() != 200 && httpresp.getStatusCode() != 201 ){
                                
                               proObj.NetSuite_Error__c = httpresp.getBody(); 
                               proListToUpdate.add(proObj);
                            }
                            
                            else{
                            
                                    
                                    proObj.NetSuite_Error__c = ''; 
                                    proObj.Netsuite_ID__c = httpresp.getBody().replaceAll('"' , '');
                                    proListToUpdate.add(proObj);
                            }
                    
                     }
                    catch(System.CalloutException e) {
                       
                    }
                    
                    //}
            }
           try{      
        
           update proListToUpdate;
           } 
           catch(System.CalloutException e) {
                       
           } 
    }

}