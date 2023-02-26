/*
    Name : NSProductDetailHelper
    Author : Piyush Kalra(piyush@wiserspread.com)
    Date : 1st Nov 
    Description : This class is used to map with fields with product details to non inventory item in NS 
*/


public class NSProductDetailHelper {
    
   
   // Method for mapping and giving back JSON 
   public static void mappingFromSFToNS(String productDetailId , Map<Id , Product_Details__c> newMapFromTrigger){
       
       if(productDetailId != null && !String.isBlank(productDetailId)){
           
           
           
           /*
               These custom setting/Objects are used to get NS id from drop down or free form fields on Product Detail 
           */
           
         
         
           
           
           //Fetching the productDetailObject
           Product_Details__c productDetailObject = [SELECT id ,recordType.name,Netsuite_ID__c, NetSuite_Name_Override__c, Description__c , Project__r.Project_Code__c , NS_Item_Name__c,
                                                     NS_Income_GL_Account__c , NS_Deferred_Revenue_Account__c  , NS_Department__c , 
                                                   NetSuite_Class__c,Job_Code__c ,NS_Revenue_Schedule__c,Subsidiary_ID__c FROM Product_Details__c WHERE ID =:productDetailId];
           
           //JSON map used for populating
           map<String , String> jsonMapToBeRequestBody = new map<String , String>();   
           
           
           
           // HardCoded mappings will be used always 
           jsonMapToBeRequestBody.put('recordtype','NonInventorySaleItem');
           jsonMapToBeRequestBody.put('taxschedule','1');
           if(productDetailObject.Netsuite_ID__c != null &&productDetailObject.Netsuite_ID__c != ''){
               jsonMapToBeRequestBody.put('id',productDetailObject.Netsuite_ID__c);
           }
           
           //getting from fields now
           //jsonMapToBeRequestBody.put('Description' , productDetailObject.description__c);
          
           
           if(productDetailObject.Job_Code__c != null){
               jsonMapToBeRequestBody.put('location' , productDetailObject.Job_Code__c);
           
           }
           
           if(productDetailObject.NetSuite_Class__c != null){
               jsonMapToBeRequestBody.put('class' , productDetailObject.NetSuite_Class__c);
           
           }else if(productDetailObject.NetSuite_Class__c != null && productDetailObject.NetSuite_Class__c != ''){
               //throw an error 
               newMapFromTrigger.get(productDetailId).NetSuite_Class__c.addError('Didnt match with Netsuite Label Name');
           }
           
           
        
             if(productDetailObject.NS_Revenue_Schedule__c !=null){
               jsonMapToBeRequestBody.put('revrecschedule' ,productDetailObject.NS_Revenue_Schedule__c);
           }else{
               newMapFromTrigger.get(productDetailId).NS_Revenue_Schedule__c.addError('Didnt match with Netsuite Label Name');
           }
           
           
               
           if(productDetailObject.NS_Deferred_Revenue_Account__c !=null){
               jsonMapToBeRequestBody.put('deferredrevenueaccount' ,productDetailObject.NS_Deferred_Revenue_Account__c);
           }else{
               // Throw an error on NS_Deferred Revenue FIeld 
               newMapFromTrigger.get(productDetailId).NS_Deferred_Revenue_Account__c.addError('Didnt match with Netsuite Label Name');
           }
          // system.debug(MappingForNSDepartment);
           system.debug(productDetailObject.NS_Department__c);
           if(  productDetailObject.NS_Department__c != null && productDetailObject.NS_Department__c != 'Training (Linux Labs)'){
                 jsonMapToBeRequestBody.put('department' ,productDetailObject.NS_Department__c);        
               
             }else{
               // Throw an error on NS_Department__c FIeld 
               newMapFromTrigger.get(productDetailId).NS_Department__c.addError('Didnt match with Netsuite Label Name');
             }
           
             if(productDetailObject.NS_Income_GL_Account__c != null){   
               jsonMapToBeRequestBody.put('incomeaccount' ,productDetailObject.NS_Income_GL_Account__c );
             }else{
               // Throw an error on NS_Income_GL_Account__c FIeld 
               newMapFromTrigger.get(productDetailId).NS_Income_GL_Account__c.addError('Didnt match with Netsuite Label Name');
             }
          // system.debug('**MappingForSubsidiaryId**'+MappingForSubsidiaryId);
          //system.debug('**MappingForSubsidiaryId.get(productDetailObject.Subsidiary__c)**'+ MappingForSubsidiaryId.get(productDetailObject.Subsidiary__c));
           /*if(!MappingForSubsidiaryId.isEmpty() && MappingForSubsidiaryId.containsKey(productDetailObject.Subsidiary__c)  && MappingForSubsidiaryId.get(productDetailObject.Subsidiary__c) != null){
           
                   jsonMapToBeRequestBody.put('subsidiary' , MappingForSubsidiaryId.get(productDetailObject.Subsidiary__c));
           }*/
           if(productDetailObject.Subsidiary_ID__c != null && productDetailObject.recordType.Name == 'Training'){
                   jsonMapToBeRequestBody.put('subsidiary' , '1');
           
           }else {
           
           		jsonMapToBeRequestBody.put('subsidiary' , string.valueOf(productDetailObject.Subsidiary_ID__c));
           
           }
           
           
           /*else{
               // Throw an error on Subsidiary_ID__c FIeld 
               newMapFromTrigger.get(productDetailId).Subsidiary__c.addError('Didnt match with Netsuite Label Name');
           }*/ 
            /*if(productDetailObject != null && productDetailObject.NS_Item_name__c != null && productDetailObject.NS_Item_name__c.length() <= 60){
	               jsonMapToBeRequestBody.put('itemid' , productDetailObject.NS_Item_Name__c);
	           }else{
	               if(productDetailObject.NetSuite_Name_Override__c != null && productDetailObject.NetSuite_Name_Override__c != ''){
	                   jsonMapToBeRequestBody.put('itemid' , productDetailObject.NetSuite_Name_Override__c);
	               }else{
	                    //productDetailObject.NetSuite_Error__c ='This field cant be blank because name field is more than 60 characters';
	                    
	                    //isSuccess = true;
	               }
	           }*/
	            if(productDetailObject.NetSuite_Name_Override__c != null && productDetailObject.NetSuite_Name_Override__c != ''){
	                   jsonMapToBeRequestBody.put('itemid' , productDetailObject.NetSuite_Name_Override__c);
	               } else if(productDetailObject != null && productDetailObject.NS_Item_name__c != null && productDetailObject.NS_Item_name__c.length() <= 180){
	               jsonMapToBeRequestBody.put('itemid' , productDetailObject.NS_Item_Name__c);
	               }else {
	                    //productDetailObject[0].NetSuite_Error__c ='NetSuite Name OverRide field cant be blank because name field is more than 60 characters';
	                    newMapFromTrigger.get(productDetailId).NetSuite_Name_Override__c.addError('This field cant be blank because name field is more than 180 characters');
	                    //isSuccess = true;
	               }
	
           
           system.debug(JSON.serialize(jsonMapToBeRequestBody));
           CallOutToNetSuite.callingCallOutToNet(JSON.serialize(jsonMapToBeRequestBody) , productDetailId);
           
           
       }
       
   }
   
    public static void mappingFromSFToNSThroughBatch(String productDetailId){
		//if(!System.isBatch()){	       
	       boolean isSuccess = false;
	       if(productDetailId != null && !String.isBlank(productDetailId)){
	           
	           
	         
	           
	           //Fetching the productDetailObject
	           list<Product_Details__c> productDetailObject = [SELECT id ,Netsuite_ID__c, NetSuite_Name_Override__c, Description__c , Project__r.Project_Code__c , NS_Item_Name__c,
	                                                     NS_Income_GL_Account__c , NS_Deferred_Revenue_Account__c  , NS_Department__c , 
	                                                   NetSuite_Class__c, NetSuite_Error__c ,Job_Code__c ,NS_Revenue_Schedule__c,Subsidiary_ID__c FROM Product_Details__c WHERE ID =:productDetailId];
	           
	           //JSON map used for populating
	           map<String , String> jsonMapToBeRequestBody = new map<String , String>();   
	           
	           
	           
	           // HardCoded mappings will be used always 
	           jsonMapToBeRequestBody.put('recordtype','NonInventorySaleItem');
	           jsonMapToBeRequestBody.put('taxschedule','1');
	           if(productDetailObject[0].Netsuite_ID__c != null &&productDetailObject[0].Netsuite_ID__c != ''){
	               jsonMapToBeRequestBody.put('id',productDetailObject[0].Netsuite_ID__c);
	           }
	           
	           //getting from fields now
	           //jsonMapToBeRequestBody.put('Description' , productDetailObject.description__c);
	          
	           
	           if(productDetailObject[0].Job_Code__c != null){
	               jsonMapToBeRequestBody.put('location' , productDetailObject[0].Job_Code__c);
	           
	           }
	           if(productDetailObject[0].NetSuite_Class__c != null){
	               jsonMapToBeRequestBody.put('class' , productDetailObject[0].NetSuite_Class__c);
	           
	           }else if(productDetailObject[0].NetSuite_Class__c != null && productDetailObject[0].NetSuite_Class__c != ''){
	               //throw an error 
	               productDetailObject[0].NetSuite_Error__c = 'Didnt match with Netsuite Label Name';
	               isSuccess = true;
	           }
	           
	           
	         
	             if(productDetailObject[0].NS_Revenue_Schedule__c !=null){
	               jsonMapToBeRequestBody.put('revrecschedule' ,productDetailObject[0].NS_Revenue_Schedule__c);
	           }else{
	               productDetailObject[0].NetSuite_Error__c = 'Didnt match with Netsuite Label Name';
	               isSuccess = true;
	           }
	           
	          
	                 if(productDetailObject[0].NS_Deferred_Revenue_Account__c !=null){
	                jsonMapToBeRequestBody.put('deferredrevenueaccount' ,productDetailObject[0].NS_Deferred_Revenue_Account__c);
	           }else{
	               // Throw an error on NS_Deferred Revenue FIeld 
	               productDetailObject[0].NetSuite_Error__c = 'Didnt match with Netsuite Label Name';
	               isSuccess = true;
	           }
	           //system.debug(MappingForNSDepartment);
	           system.debug(productDetailObject[0].NS_Department__c);
	           if (productDetailObject[0].NS_Department__c != null && productDetailObject[0].NS_Department__c != 'Training (Linux Labs)'){
	               jsonMapToBeRequestBody.put('department' , productDetailObject[0].NS_Department__c );   
	           }
	           else{
	               // Throw an error on NS_Department__c FIeld 
	               productDetailObject[0].NetSuite_Error__c = 'Didnt match with Netsuite Label Name';
	               isSuccess = true;
	           }
	          
	             if(productDetailObject[0].NS_Income_GL_Account__c != null){  
	               jsonMapToBeRequestBody.put('incomeaccount' , productDetailObject[0].NS_Income_GL_Account__c );
	           }else{
	               // Throw an error on NS_Income_GL_Account__c FIeld 
	               productDetailObject[0].NetSuite_Error__c = 'Didnt match with Netsuite Label Name';
	               isSuccess = true;
	           }
	          // system.debug('**MappingForSubsidiaryId**'+MappingForSubsidiaryId);
	           //system.debug('**MappingForSubsidiaryId.get(productDetailObject.Subsidiary__c)**'+ MappingForSubsidiaryId.get(productDetailObject.Subsidiary__c));
	         
	           if(productDetailObject[0].Subsidiary_ID__c != null){
	                   jsonMapToBeRequestBody.put('subsidiary' , string.valueOf(productDetailObject[0].Subsidiary_ID__c));
	           
	           }
	          
	          
	          
	               if(productDetailObject[0].NetSuite_Name_Override__c != null && productDetailObject[0].NetSuite_Name_Override__c != ''){
	                   jsonMapToBeRequestBody.put('itemid' , productDetailObject[0].NetSuite_Name_Override__c);
	               } else if(productDetailObject != null && productDetailObject[0].NS_Item_name__c != null && productDetailObject[0].NS_Item_name__c.length() <= 60){
	               jsonMapToBeRequestBody.put('itemid' , productDetailObject[0].NS_Item_Name__c);
	               }else {
	                    productDetailObject[0].NetSuite_Error__c ='NetSuite Name OverRide field cant be blank because name field is more than 60 characters';
	                    isSuccess = true;
	               }
	           
	           system.debug(JSON.serialize(jsonMapToBeRequestBody));
	           CallOutToNetSuite.callingCallOutToNetForBatch(JSON.serialize(jsonMapToBeRequestBody) , productDetailId);
	            if(isSuccess = true){
	               update productDetailObject[0];
	           
	           }
	           
	       }
	       
	  // }
	}
}