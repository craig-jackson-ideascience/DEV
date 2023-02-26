public class EMSSalesOrderHelper {    
    
    public static Endpoints__c settings{
        get{
            if(settings == null){
                List<Endpoints__c> endPointObj = new List<Endpoints__c>([select name, endpoint__c, Password__c, User_Id__c, Nlauth_Account__c from Endpoints__c where name = 'For Other than Membership Asset']);         
                settings = endPointObj[0];
            }
            return settings;
        }
        set;
    }

    public Boolean createEMSSalesOrder(Id recordId){
        Boolean isSuccess = false;
        try{
        List<Endpoints__c> endPointObj = new List<Endpoints__c>([select name, endpoint__c, Password__c, User_Id__c, Nlauth_Account__c from Endpoints__c where name = 'For Other than Membership Asset']);         
        if(!endPointObj.IsEmpty()){
            EMS__c ems = [SELECT ID,NetSuite_ID__c,Bill_To_Account__c,Salesorder_Number__c,Event__r.BillFromProject__c,NetSuite_Error__c FROM EMS__c WHERE Id =: recordId];            
            String body = createSalesOrderJSON(recordId); // create json body 
            body = createAccountInNetSuite(body);// create account
            if(String.isNotEmpty(body)){
                HttpResponse response = CallOutToNetSuiteForAsset.calloutToNetSuite(settings, 'POST', body); //creates sales order
                System.debug('Response ==>' + response.getBody());
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                    WrapperToGetSalesOrderData salesOrderWrapper = (WrapperToGetSalesOrderData)JSON.deserialize(response.getBody() , WrapperToGetSalesOrderData.class);
                    WrapperToGetSalesOrderData wrap = salesOrderWrapper;
                    ems.NetSuite_ID__c = wrap.id;
                    ems.Salesorder_Number__c = wrap.tranid;
                    ems.NetSuite_Error__c ='';
                    ems.Sync_to_Netsuite__c = true;
                    isSuccess = true;
                }else{
                    //update error message
                    ems.NetSuite_Error__c ='NetSuite Sync Failed to work for EMS:' + response.getBody();
                }
                update ems;
                Map<String , Object> jsonBody = (Map<String , Object>)JSON.deserializeUntyped(body);
                if(jsonBody.containsKey('entity')){                
                    Account_And_Project__c apa = new Account_And_Project__c();
                    apa.Account__c  = ems.Bill_To_Account__c;
                    apa.Project__c =  ems.Event__r.BillFromProject__c;
                    apa.Netssuite_ID__c = (String)jsonBody.get('entity');
                    upsert apa Netssuite_ID__c;
                }

            }
        }
        }
        catch (Exception ex){
            
        }
        return isSuccess;
    }
    
    private String createAccountInNetSuite(String body){   
        List<Endpoints__c> endPointObj = new List<Endpoints__c>([select name, endpoint__c, Password__c, User_Id__c, Nlauth_Account__c from Endpoints__c where name = 'For Product Details']);         
        Map<String , Object> jsonBody = (Map<String , Object>)JSON.deserializeUntyped(body);
        if(jsonBody != null && jsonBody.containsKey('syncAccount')){
            String accountBodyInString = String.valueOf(jsonBody.get('syncAccount')); 
            system.debug('Account Body==>' +accountBodyInString);
            HttpResponse response = CallOutToNetSuiteForAsset.calloutToNetSuite(endPointObj[0], 'POST', accountBodyInString);           
            if(response.getStatusCode() != 200){
                //there is an error creating account return blank account
                return '';
            }else{
                jsonBody.remove('syncAccount');                
                jsonBody.put('entity' , response.getBody().replaceAll('"' , ''));
                body = JSON.serialize(jsonBody);
            }
        }
        
        return body;        
    }
    
    public String createSalesOrderJSON(Id recordId) {
        List<Object> mainJsonArray = new List<Object>();

        EMS__c ems = [
                SELECT Id,NS_Department__c,Product__c,Description__c, Contact__r.Email,NS_Class__c,
                        Amount__c,Bill_To_Account__c,Bill_To_Account__r.Billingstreet,Bill_To_Account__r.Billingcity,Bill_From__r.Project_Code__c,
                        Bill_To_Account__r.billingstate, Bill_To_Account__r.billingPostalCode, Bill_To_Account__r.billingCountry, StartDate__c,
                        Bill_To_Account__r.Name,Bill_From__r.Subsidiary_ID__c,Jobcode__c,EMS_Link__c
                FROM EMS__c
                WHERE ID = :recordId
        ];

        Map<String, Object> jsonMappingObject = new Map<String, Object>();
        List<Account_And_Project__c> accProList = [
                select id, Account__c, Project__c, Subsidiary_ID__c, Netssuite_ID__c
                from Account_And_Project__c
                where Account__c = :ems.Bill_To_Account__c AND Project__r.Project_Code__c = :ems.Bill_From__r.Project_Code__c
        ];

        jsonMappingObject.put('subsidiary',ems.Bill_From__r.Subsidiary_ID__c); // 1
        jsonMappingObject.put('Project_Code__c',ems.Bill_From__r.Project_Code__c); // check if this is needed //LF
        jsonMappingObject.put('billaddress', getBillToAddress(ems));
        jsonMappingObject.put('location' , ems.Jobcode__c);
        jsonMappingObject.put('class' , ems.NS_Class__c);
        jsonMappingObject.put('recordtype', 'salesorder');
        jsonMappingObject.put('department', ems.NS_Department__c);
        jsonMappingObject.put('custbody_primary_email', ems.Contact__r.email);
        jsonMappingObject.put('custbody_sugar_reference' , ems.EMS_Link__c);
       
        //accProList = new List<Account_And_Project__c>();//added to solve sync issue on sandox
        if (!accProList.isEmpty()) {
            jsonMappingObject.put('entity', accProList[0].Netssuite_ID__c); // bill to account details
            String netsuiteBody = creatingMember(ems, accProList[0].Netssuite_ID__c);
            jsonMappingObject.put('syncAccount', netsuiteBody);
        } else {
            String netsuiteBody = creatingMember(ems, null);
            jsonMappingObject.put('syncAccount', netsuiteBody);
        }        
        jsonMappingObject.put('items', buildSalesItem(ems));

        String jsonString = JSON.serialize(jsonMappingObject);       
        return jsonString;
    }



    public  string creatingMember(EMS__c ems, String isEntityIdPresent) {
        Map<String, String> memberMapping = new Map<String, String>();
        if (isEntityIdPresent != null) {
            memberMapping.put('id', isEntityIdPresent);
        }
        //ems.Event__r.BillFromProject__r.Project_Code__c;
        memberMapping.put('companyname', ems.Bill_To_Account__r.Name);
        String name = ems.Bill_To_Account__r.Name + '-LF' ;
        if (name.length() > 80) {         
            name = ems.Bill_To_Account__r.Name.substring(0, 70) + ' - LF';// + ems.Event__r.BillFromProject__r.project_code__c;
        }
        if (isEntityIdPresent == null){
            memberMapping.put('entityid', name);
        }
        
        memberMapping.put('subsidiary', String.valueOf(ems.Bill_From__r.Subsidiary_ID__c));       
        memberMapping.put('recordtype', 'customer');
        memberMapping.put('url', null);
        memberMapping.put('phone', null);
        
        String billingStreet = ems.Bill_To_Account__r.BillingStreet != null ? ems.Bill_To_Account__r.BillingStreet : '';
        memberMapping.put('addr1',billingStreet);  
        
        String billingCity = ems.Bill_To_Account__r.BillingCity != null ? ems.Bill_To_Account__r.BillingCity : '';
        memberMapping.put('city',billingCity);  
        
        String billingPostalCode = ems.Bill_To_Account__r.BillingPostalCode != null ? ems.Bill_To_Account__r.BillingPostalCode : '';
        memberMapping.put('zip',billingPostalCode);  
        
        String billingState = ems.Bill_To_Account__r.BillingState != null ? ems.Bill_To_Account__r.BillingState : '';
        memberMapping.put('state',billingState);  
        
        String billingCountry = ems.Bill_To_Account__r.billingCountry != null ? AssetToSalesOrderHelper.convertingCountry( ems.Bill_To_Account__r.billingCountry, false) : '';
        memberMapping.put('country',billingCountry); 
        
        return JSON.serialize(memberMapping);
    }

    private List<Object> buildSalesItem(EMS__c ems) {
        List<Object> itemList = new List<Object>();
        Map<String, Object> salesLineItem = new map<String, Object>();
        salesLineItem.put('item', ems.Product__c);
        salesLineItem.put('price', 1);
        salesLineItem.put('description', ems.Description__c);
        salesLineItem.put('amount', ems.Amount__c);
        salesLineItem.put('quantity', 1);
        salesLineItem.put('job',ems.Jobcode__c);
        String startDate = ems.StartDate__c.month()  + '/'+ ems.StartDate__c.day() + '/' + ems.StartDate__c.year(); 
        salesLineItem.put('revrecstartdate', startDate);
        salesLineItem.put('revrecenddate', startDate);
        itemList.add(salesLineItem);
        return itemList;
    }

    private String getBillToAddress(EMS__c ems) {
        String billToAddress = '';
        if (ems.Bill_To_Account__c != null) {
            String convertedCountry = '', country = '';            
            convertedCountry = AssetToSalesOrderHelper.convertingCountry(ems.Bill_To_Account__r.billingCountry, true);            
            if (convertedCountry != null) {
                country = convertedCountry.capitalize();
            }
            String street = ems.Bill_To_Account__r.billingstreet != null ? ems.Bill_To_Account__r.billingstreet : '' ;
            String city = ems.Bill_To_Account__r.billingcity != null ? ems.Bill_To_Account__r.billingcity : '' ;
            String state = ems.Bill_To_Account__r.billingstate != null ? ems.Bill_To_Account__r.billingstate : '' ;
            String Postalcode = ems.Bill_To_Account__r.billingPostalCode != null ? ems.Bill_To_Account__r.billingPostalCode : '' ;
            String checkCountry = country != null ? country : '' ;
            if (String.isNotEmpty(street)) {
                billToAddress = ems.Bill_To_Account__r.Name + '\n' + street + '\n' + city + ' ' + state + ' ' + PostalCode + '\n' + checkCountry;
            }
        }       
        return billToAddress;
    }
}