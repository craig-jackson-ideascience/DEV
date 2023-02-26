/*-********************************************************************************************************
* Name         : CallOutToNetSuiteTrigger
* @Author      : Akshaye Sharma(Akshaye@wiserspread.com)
* @Date        : 18-October-2017
* @Description : This trigger , invokes the integration.
* UPDATES
* Version          Developer                    Date                        Description
*-------------------------------------------------------------------------------------------
*     1.0           Akshaye                 18-October-2017                 Initial Creation 
****************************************************************************************************************/

trigger CallOutToNetSuiteTrigger on Product_Details__c (after insert,after update, before insert, before update) {
    
    
    //commented by piyush on 1st Novemeber
    /*if(trigger.isInsert){
        CallOutToNetSuiteWrapperForProduct.mapping(trigger.newMap.KeySet()); 
    }
    
    if(trigger.isUpdate){
    
       list<Product_Details__c> proList = new list <Product_Details__c>();
        
       //proList = [select Netsuite_Sync__c from Product_Details__c where id in: trigger.new];
       
       set<id> proId = new set <id> ();
        
       for(Product_Details__c proObj : trigger.new){
           if(trigger.oldMap.get(proObj.Id).Netsuite_Sync__c != proObj.Netsuite_Sync__c && proObj.Netsuite_Sync__c == True){
               proId.add(proObj.id);
           }    
       }
       system.debug('**proId**'+proId); 
       if(proId != null && !proId.isEmpty()){   
           CallOutToNetSuiteWrapperForProduct.mapping(proId); 
       }
    } */   
    if(!System.isFuture() && !System.isBatch()){
        if(trigger.isAfter && trigger.isUpdate){
           for(Product_Details__c proObj : Trigger.new){
               if(trigger.oldMap.get(proObj.id).Netsuite_Sync__c != proObj.Netsuite_Sync__c && proObj.Netsuite_Sync__c == True){
                   NSProductDetailHelper.mappingFromSFToNS(proObj.id , trigger.newMap);
                   
               }    
           
           }  
           
            
        }
        if(trigger.isAfter && trigger.isInsert){
           for(Product_Details__c proObj : Trigger.new){
               if( proObj.Netsuite_Sync__c == True){
                   NSProductDetailHelper.mappingFromSFToNS(proObj.id , trigger.newMap);
                   
               }    
           
           }  
           
            
        }
        /*if(trigger.isAfter && trigger.isInsert){
            
            list<Product_Details__c> proList = new list <Product_Details__c>();
            list<Product_Details__c> proListToUdpate = new list <Product_Details__c>();
            proList = [select Netsuite_Sync__c, Event__r.Netsuite_Sync__c from Product_Details__c where id in: trigger.new];
            for(Product_Details__c proObj : proList){
                if(proObj.Event__r.Netsuite_Sync__c == True){
                    
                    //NSProductDetailHelper.mappingFromSFToNS(trigger.new[0].id , trigger.newMap);
                    proObj.Netsuite_Sync__c = true;
                    proListToUdpate.add(proObj);
                    
                }
            }   
            if(proListToUdpate.size() > 0 ){
                update proListToUdpate;
                
            
            }   
        } */ 
      if(trigger.isBefore && trigger.isUpdate){
        
            for(Product_Details__c proObj : Trigger.new){
                if(trigger.oldMap.get(proObj.id).Netsuite_Sync__c != proObj.Netsuite_Sync__c && proObj.Netsuite_Sync__c == True && (proObj.Price__c == null)){ 
                   Trigger.newmap.get(proObj.id).addError('Price Can Not Be Blank While Syncing with NetSuite');  
                  
                } 
                if(trigger.oldMap.get(proObj.id).Netsuite_Sync__c != proObj.Netsuite_Sync__c && proObj.Netsuite_Sync__c == True && (proObj.Subsidiary_ID__c == null)){
                
                    Trigger.newmap.get(proObj.id).addError('Subsidiary ID Can Not Be Blank While Syncing with NetSuite');  
                
                
                }
                if(trigger.oldMap.get(proObj.id).Netsuite_Sync__c != proObj.Netsuite_Sync__c && proObj.Netsuite_Sync__c == True && (proObj.NS_Income_GL_Account__c == null)){
                
                    Trigger.newmap.get(proObj.id).addError('NS Income GL Account Can Not Be Blank While Syncing with NetSuite');  
                
                
                }
                if(trigger.oldMap.get(proObj.id).Netsuite_Sync__c != proObj.Netsuite_Sync__c && proObj.Netsuite_Sync__c == True && (proObj.NS_Deferred_Revenue_Account__c == null)){
                
                    Trigger.newmap.get(proObj.id).addError('NS Deferred Revenue Account Can Not Be Blank While Syncing with NetSuite');  
                
                
                }
                
                if(trigger.oldMap.get(proObj.id).Netsuite_Sync__c != proObj.Netsuite_Sync__c && proObj.Netsuite_Sync__c == True && (proObj.NS_Revenue_Schedule__c == null)){
                
                    Trigger.newmap.get(proObj.id).addError('NS Revenue Schedule Can Not Be Blank While Syncing with NetSuite');  
                
                
                }
                
                if(trigger.oldMap.get(proObj.id).Netsuite_Sync__c != proObj.Netsuite_Sync__c && proObj.Netsuite_Sync__c == True && (proObj.Products__c == null)){
                
                    Trigger.newmap.get(proObj.id).addError('Product Can Not Be Blank While Syncing with NetSuite');  
                
                
                }

            
            }
        
        }  
        
         if(trigger.isBefore && trigger.isInsert){
        
            for(Product_Details__c proObj : Trigger.new){
                if(proObj.Netsuite_Sync__c == True && (proObj.Price__c == null)){ 
                   proObj.addError('Price Can Not Be Blank');  
                  
                } 
                 if(proObj.Netsuite_Sync__c == True && (proObj.Products__c == null)){
                
                    proObj.addError('Product Can Not Be Blank');  
                
                
                }
                /*if(Trigger.newmap.get(proObj.id).Netsuite_Sync__c == True && (proObj.Subsidiary_ID__c == null)){
                
                    Trigger.newmap.get(proObj.id).addError('Subsidiary ID Can Not Be Blank While Syncing with NetSuite');  
                
                
                }
                if(Trigger.newmap.get(proObj.id).Netsuite_Sync__c == True && (proObj.NS_Income_GL_Account__c == null)){
                
                    Trigger.newmap.get(proObj.id).addError('NS Income GL Account Can Not Be Blank While Syncing with NetSuite');  
                
                
                }
                if(Trigger.newmap.get(proObj.id).Netsuite_Sync__c == True && (proObj.NS_Deferred_Revenue_Account__c == null)){
                
                    Trigger.newmap.get(proObj.id).addError('NS Deferred Revenue Account Can Not Be Blank While Syncing with NetSuite');  
                
                
                }
                
                if(Trigger.newmap.get(proObj.id).Netsuite_Sync__c == True && (proObj.NS_Revenue_Schedule__c == null)){
                
                    Trigger.newmap.get(proObj.id).addError('NS Revenue Schedule Can Not Be Blank While Syncing with NetSuite');  
                
                
                }
                
                if(Trigger.newmap.get(proObj.id).Netsuite_Sync__c == True && (proObj.Products__c == null)){
                
                    Trigger.newmap.get(proObj.id).addError('Product Can Not Be Blank While Syncing with NetSuite');  
                
                
                }*/

            
            }
        
        }  
    }
    
  }