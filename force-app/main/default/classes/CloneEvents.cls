//////////// TEST CLASS - CloneEvents_Test ////////////////

global with sharing class CloneEvents{
    @AuraEnabled
    WebService static String clone_method(Id evtId){
    
        //Id evnt_Id = Id.valueOf(evtId);
        String clonedEvt_Id;
        Event__c eventRecordToClone = new Event__c();
        Event__c clonedEvent = new Event__c();
        List<Product_Details__c> clonedProdDetailList = new List<Product_Details__c>();
        
        // FETCH ALL FIELD FROM EVENT
        Map<String, Schema.SObjectField> schemaFieldMapEVENT = Schema.SObjectType.Event__c.fields.getMap();
        List<String> listOfEventFieldNames = new List<String>();
        for(String sso : schemaFieldMapEVENT.keyset()){
           listOfEventFieldNames.add(sso);
        }
        String eventFieldNames = String.join(listOfEventFieldNames,',');
        // FETCH ALL FIELD FROM PRODUCT DETAIL
        Map<String, Schema.SObjectField> schemaFieldMapProductDetail = Schema.SObjectType.Product_Details__c.fields.getMap();
        List<String> listOfproDetailFieldNames = new List<String>();
        for(String sso : schemaFieldMapProductDetail.keyset()){
           listOfproDetailFieldNames.add(sso);
        }
        
        String proDetailFieldNames = String.join(listOfproDetailFieldNames, ',');
        String qury;                                                                         
        
        qury = 'SELECT '+ eventFieldNames + ' , (Select '+ proDetailFieldNames +' FROM Product_Details__r WHERE Status__c != \'Inactive\') FROM Event__c WHERE Id = :evtId';
        
        system.debug('____qury___'+qury);
        
        if(qury!=null || qury!='')
            eventRecordToClone = Database.query(qury);
            
        system.debug('___eventRecordToClone____'+eventRecordToClone);
        
        try{
            if(eventRecordToClone!=null){
                clonedEvent = eventRecordToClone.clone(false, false, false, false);
                clonedEvent.Event_Name__c = eventRecordToClone.Event_Name__c + ' - Clone';
                clonedEvent.Name = eventRecordToClone.Name + ' - Clone';  
                clonedEvent.Status__c = 'Planned';    
                clonedEvent.Netsuite_Sync__c=False;   
                clonedEvent.NetSuite_Class__c='';
                clonedEvent.Job_Code__c='';
                clonedEvent.NS_Department__c='';
                clonedEvent.NS_Deferred_Revenue_Account__c='';
                clonedEvent.NS_Income_GL_Account__c='';
                clonedEvent.NS_Revenue_Schedule__c='';
                clonedEvent.Sugar_Event_ID__c = null;
                clonedEvent.Email_Sent__c = false;
                //don't copy any fields that starts with Cvent_Event_
                for(string fieldName : schemaFieldMapEVENT.keyset()){
                    system.debug('Processing record '+fieldName );                    
                    if(fieldName.startsWithIgnoreCase('Cvent_Event_') && schemaFieldMapEVENT.get(fieldName).getDescribe().isUpdateable())
                    {
                        if(schemaFieldMapEVENT.get(fieldName).getDescribe().getType() == Schema.DisplayType.BOOLEAN)
                            clonedEvent.put(fieldName,false);
                        else
                         clonedEvent.put(fieldName,null);
                    }
                   
                }
            }                               
            
            system.debug('__before___clonedEvent___'+clonedEvent);
            insert clonedEvent;
            system.debug('__after___clonedEvent___'+clonedEvent);
            
            if(eventRecordToClone.Product_Details__r.size()>0){
                for(Product_Details__c pd : eventRecordToClone.Product_Details__r){
                    Product_Details__c clonedProd = new Product_Details__c();
                    clonedProd = pd.clone(false,false,false,false);
                    clonedProd.Event__c = clonedEvent.Id;
                    clonedProd.Status__c = 'Inactive';
                    clonedProd.NetSuite_Error__c= '';
                    clonedProd.NetSuite_Class__c= '';
                    clonedProd.Job_Code__c= '';
                    clonedProd.NS_Department__c= '';
                    clonedProd.NS_Deferred_Revenue_Account__c= '';
                    clonedProd.NS_Income_GL_Account__c= '';
                    clonedProd.NS_Revenue_Schedule__c= '';
                    clonedProd.NetSuite_Name_Override__c= '';
                    clonedProd.Tax_Class__c= '';
                    clonedProd.Netsuite_ID__c= '';
                    clonedProd.Skip_60_Char_Limit__c = true;
                    clonedProd.NetSuite_Sync__c=False;
                    clonedProdDetailList.add(clonedProd);
                }
            }
            
            if(clonedProdDetailList!=null && clonedProdDetailList.size()>0)
                insert clonedProdDetailList;
                
            system.debug('____clonedProdDetailList____'+clonedProdDetailList);
            system.debug('____clonedEvent__Id___'+clonedEvent.Id);
        }
        Catch(Exception ae){ 
            system.debug('In exception' + ae.getMessage()); 
              clonedEvt_Id  = ae.getMessage();
            return clonedEvt_Id;
        }        
        clonedEvt_Id= String.valueOf(clonedEvent.Id);
            
        return clonedEvt_Id;
    }
    
}