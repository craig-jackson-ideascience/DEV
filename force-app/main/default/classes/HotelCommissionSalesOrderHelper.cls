public class HotelCommissionSalesOrderHelper {
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
    public Boolean createHotelCommissionSalesOrder(Id recordId){
        Boolean isSuccess = false;
        try{
            List<Endpoints__c> endPointObj = new List<Endpoints__c>([select name, endpoint__c, Password__c, User_Id__c, Nlauth_Account__c from Endpoints__c where name = 'For Other than Membership Asset']);         
            if(!endPointObj.IsEmpty()){
                Hotel_Commissions__c hotelCommissions = [SELECT ID,Bill_to_Account__c,Salesorder_Status__c,Salesorder_Number__c,
                                                         NetSuite_ID__c,NetSuite_Error__c,Sync_to_Netsuite__c
                                                         FROM Hotel_Commissions__c WHERE Id =: recordId];            
                String body = createSalesOrderJSON(recordId); // create json body 
                body = createAccountInNetSuite(body);// create account
                if(String.isNotEmpty(body)){
                    HttpResponse response = CallOutToNetSuiteForAsset.calloutToNetSuite(settings, 'POST', body); //creates sales order
                    if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                        WrapperToGetSalesOrderData salesOrderWrapper = (WrapperToGetSalesOrderData)JSON.deserialize(response.getBody() , WrapperToGetSalesOrderData.class);
                        WrapperToGetSalesOrderData wrap = salesOrderWrapper;
                        hotelCommissions.NetSuite_ID__c = wrap.id;
                        hotelCommissions.Salesorder_Number__c = wrap.tranid;
                        hotelCommissions.NetSuite_Error__c ='';
                        hotelCommissions.Sync_to_Netsuite__c = true;
                        isSuccess = true;
                    }else{
                        //update error message
                        hotelCommissions.NetSuite_Error__c ='NetSuite Sync Failed to work for Hotel Commissions:' + response.getBody();
                    }
                    update hotelCommissions;
                    Map<String , Object> jsonBody = (Map<String , Object>)JSON.deserializeUntyped(body);
                    if(jsonBody.containsKey('entity')){                
                        Account_And_Project__c apa = new Account_And_Project__c();
                        apa.Account__c  = hotelCommissions.Bill_To_Account__c;
                        apa.Project__c =  [SELECT ID,NAME FROM Project__c WHERE NAME='The Linux Foundation'][0].Id;//harcode to linux foundation project
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
        Hotel_Commissions__c hotelCommissions = [
            SELECT Id,NS_Department__c,Product__c,Product_Description__c, Bill_to_Contact__r.Email,
            Amount__c,Bill_To_Account__c,Bill_To_Account__r.Billingstreet,Bill_To_Account__r.Billingcity,
            Bill_To_Account__r.billingstate, Bill_To_Account__r.billingPostalCode, Bill_To_Account__r.billingCountry, Start_Date__c,End_Date__c,
            Bill_To_Account__r.Name,SubsidiaryId__c,NS_Invoice_Memo__c,Bill_to_Contact_2__c,Bill_to_Contact_2__r.Email,Bill_to_Contact_3__c,
            Bill_to_Contact_3__r.Email,Hotel_Commission_Link__c
            FROM Hotel_Commissions__c
            WHERE ID = :recordId
        ];
        
        List<Account_And_Project__c> accProList = [
            select id, Account__c, Project__c, Subsidiary_ID__c, Netssuite_ID__c
            from Account_And_Project__c
            where Account__c = :hotelCommissions.Bill_To_Account__c AND Project__r.Project_Code__c = 'LF'
        ];
        
        Map<String, Object> jsonMappingObject = new Map<String, Object>();
        
        
        jsonMappingObject.put('subsidiary',hotelCommissions.SubsidiaryId__c); // 1
        jsonMappingObject.put('Project_Code__c','LF'); // check if this is needed //LF
        jsonMappingObject.put('billaddress', getBillToAddress(hotelCommissions));
        jsonMappingObject.put('recordtype', 'salesorder');
        jsonMappingObject.put('custbody_primary_email', hotelCommissions.Bill_to_Contact__r.email);
        jsonMappingObject.put('department', hotelCommissions.NS_Department__c);
        jsonMappingObject.put('custbody_sugar_reference' , hotelCommissions.Hotel_Commission_Link__c);
        if(hotelCommissions.NS_Invoice_Memo__c != null){
            if(hotelCommissions.NS_Invoice_Memo__c.length() < 999){
                jsonMappingObject.put('memo' , hotelCommissions.NS_Invoice_Memo__c);
            }
        }
        if(hotelCommissions.Bill_to_Contact_2__c != null){
            jsonMappingObject.put('custbody_additional_email_1' , hotelCommissions.Bill_to_Contact_2__r.email);
        }
        if(hotelCommissions.Bill_to_Contact_3__c != null){
            jsonMappingObject.put('custbody_additional_email_2' , hotelCommissions.Bill_to_Contact_3__r.email);
        }
        if (!accProList.isEmpty()) {
            jsonMappingObject.put('entity', accProList[0].Netssuite_ID__c); // bill to account details
            String netsuiteBody = creatingMember(hotelCommissions, accProList[0].Netssuite_ID__c);
            jsonMappingObject.put('syncAccount', netsuiteBody);
        } else {
            String netsuiteBody = creatingMember(hotelCommissions, null);
            jsonMappingObject.put('syncAccount', netsuiteBody);
        }        
        jsonMappingObject.put('items', buildSalesItem(hotelCommissions));
        String jsonString = JSON.serialize(jsonMappingObject);        
        return jsonString;
    }
    
    public  string creatingMember(Hotel_Commissions__c hotelCommissions, String isEntityIdPresent) {
        Map<String, String> memberMapping = new Map<String, String>();
        if (isEntityIdPresent != null) {
            memberMapping.put('id', isEntityIdPresent);
        }
        memberMapping.put('companyname', hotelCommissions.Bill_To_Account__r.Name);
        String name = hotelCommissions.Bill_To_Account__r.Name + '-LF' ;
        if (name.length() > 80) {         
            name = hotelCommissions.Bill_To_Account__r.Name.substring(0, 70) + ' - LF';// + ems.Event__r.BillFromProject__r.project_code__c;
        }
        memberMapping.put('entityid', name);
        memberMapping.put('subsidiary', String.valueOf(hotelCommissions.SubsidiaryId__c));       
        memberMapping.put('recordtype', 'customer');
        memberMapping.put('url', null);
        memberMapping.put('phone', null);
        
        String billingStreet = hotelCommissions.Bill_To_Account__r.BillingStreet != null ? hotelCommissions.Bill_To_Account__r.BillingStreet : '';
        memberMapping.put('addr1',billingStreet);  
        
        String billingCity = hotelCommissions.Bill_To_Account__r.BillingCity != null ? hotelCommissions.Bill_To_Account__r.BillingCity : '';
        memberMapping.put('city',billingCity);  
        
        String billingPostalCode = hotelCommissions.Bill_To_Account__r.BillingPostalCode != null ? hotelCommissions.Bill_To_Account__r.BillingPostalCode : '';
        memberMapping.put('zip',billingPostalCode);  
        
        String billingState = hotelCommissions.Bill_To_Account__r.BillingState != null ? hotelCommissions.Bill_To_Account__r.BillingState : '';
        memberMapping.put('state',billingState);  
        
        String billingCountry = hotelCommissions.Bill_To_Account__r.billingCountry != null ? AssetToSalesOrderHelper.convertingCountry( hotelCommissions.Bill_To_Account__r.billingCountry, false) : '';
        memberMapping.put('country',billingCountry); 
        
        return JSON.serialize(memberMapping);
    }
    
    private List<Object> buildSalesItem(Hotel_Commissions__c hotelCommissions) {
        List<Object> itemList = new List<Object>();
        Map<String, Object> salesLineItem = new map<String, Object>();
        salesLineItem.put('item', hotelCommissions.Product__c);
        salesLineItem.put('price', 1);
        salesLineItem.put('description', hotelCommissions.Product_Description__c);
        salesLineItem.put('amount', hotelCommissions.Amount__c);
        salesLineItem.put('quantity', 1);        
        String startDate = hotelCommissions.Start_Date__c.month()  + '/'+ hotelCommissions.Start_Date__c.day() + '/' + hotelCommissions.Start_Date__c.year();
        String endDate = hotelCommissions.End_Date__c.month()  + '/'+ hotelCommissions.End_Date__c.day() + '/' + hotelCommissions.End_Date__c.year();
        salesLineItem.put('revrecstartdate', startDate);
        salesLineItem.put('revrecenddate', startDate);
        itemList.add(salesLineItem);
        return itemList;
        
    }
    
    private String getBillToAddress(Hotel_Commissions__c hotelCommissions) {
        String billToAddress = '';
        if (hotelCommissions.Bill_To_Account__c != null) {
            String convertedCountry = '', country = '';            
            convertedCountry = AssetToSalesOrderHelper.convertingCountry(hotelCommissions.Bill_To_Account__r.billingCountry, true);            
            if (convertedCountry != null) {
                country = convertedCountry.capitalize();
            }
            String street = hotelCommissions.Bill_To_Account__r.billingstreet != null ? hotelCommissions.Bill_To_Account__r.billingstreet : '' ;
            String city = hotelCommissions.Bill_To_Account__r.billingcity != null ? hotelCommissions.Bill_To_Account__r.billingcity : '' ;
            String state = hotelCommissions.Bill_To_Account__r.billingstate != null ? hotelCommissions.Bill_To_Account__r.billingstate : '' ;
            String Postalcode = hotelCommissions.Bill_To_Account__r.billingPostalCode != null ? hotelCommissions.Bill_To_Account__r.billingPostalCode : '' ;
            String checkCountry = country != null ? country : '' ;
            if (String.isNotEmpty(street)) {
                billToAddress = hotelCommissions.Bill_To_Account__r.Name + '\n' + street + '\n' + city + ' ' + state + ' ' + PostalCode + '\n' + checkCountry;
            }
        }       
        return billToAddress;
    }
}