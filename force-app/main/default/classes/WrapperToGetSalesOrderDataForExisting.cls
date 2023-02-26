public with sharing class WrapperToGetSalesOrderDataForExisting {
     //public boolean custbody_tlf_needs_upload_to_portal;
   // public cls_orderstatus orderstatus;
    //public String custbody_additional_email_1;  //Test@gmail.com
    //public String trandate; //11/2/2017
    //public cls_billaddresslist billaddresslist;
    //public String custbody_additional_email_2;  //Test@gmail.com
    //public String memo; //Testing Memo
    //public boolean tobeprinted;
    //public cls_billcountry billcountry;
    //public boolean ccapproved;
    //public boolean custbody_processed_by_sugar;
    //public cls_terms terms;
    //public String billingaddress_text;  //Samsung Electronics America, Inc. 85 Challenger Rd.  Ridgefield Park NJ 07660 United States
    public String id;   //529009
    public String tranid;   //SO3453
    public String recordtype;   //salesorder
    public boolean custbody_fully_paid;
    //public boolean tobeemailed;
    //public cls_item[] item;
    //public boolean custbody_tlf_transaction_uploaded;
    //public String billaddress;  //Samsung Electronics America, Inc. 85 Challenger Rd.  Ridgefield Park NJ 07660 United States
    /*public cls_subsidiary subsidiary;
    public boolean ccispurchasecardbin;
    public boolean isrecurringpayment;
    public Integer subtotal;    //1212121
    public String billaddr1;    //85 Challenger Rd.
    public cls_job job;
    public String custbody_primary_email;   //Test@gmail.com
    public String otherrefnum;  //1212121
    public String createddate;  //11/2/2017 9:35 am
    public String revenuestatus;    //A
    public Integer deferredrevenue; //0 
    public String billzip;  //07660
    public cls_billingaddress billingaddress;
    public boolean tobefaxed;
    public Integer total;   //1212121
    public Integer recognizedrevenue;   //0
    public String recordtype;   //salesorder
    public boolean ccprocessaspurchasecard;
    public cls_department department;
    public cls_class class1;
    public String tranid;   //SO3453
    public String lastmodifieddate; //11/2/2017 9:35 am
    public cls_billingschedule[] billingschedule;
    public String billstate;    //NJ
    public String billaddressee;    //Samsung Electronics America, Inc.
    public String saleseffectivedate;   //11/2/2017
    public cls_customform customform;
    public boolean getauth;
    public cls_location location;
    public cls_entity entity;
    public String billcity; //Ridgefield Park
    class cls_orderstatus {
        public String internalid;   //A
        public String name; //Pending Approval
    }
    class cls_billaddresslist {
        public String internalid;   //10712
        public String name; //SugarCRM Address
    }
    class cls_billcountry {
        public String internalid;   //US
        public String name; //United States
    }
    class cls_terms {
        public String internalid;   //2
        public String name; //Net 30
    }
    class cls_item {
        public cls_item item;
        public String internalid;   //87
        public String name; //Membership : 2015 LF Silver Membership (total emp size 0-99)
        public String quantity; //1
        public String revrecenddate;    //11/2/2017
        public cls_revrecschedule revrecschedule;
        public String revrecstartdate;  //11/2/2017
    }
    class cls_department {
        public String internalid;   //2
        public String name; //Events
    }
    class cls_revrecschedule {
        public String internalid;   //6
        public String name; //Straight Line
    }
    class cls_subsidiary {
        public String internalid;   //1
        public String name; //The Linux Foundation
    }
    class cls_job {
        public String internalid;   //88367
        public String name; //Test
    }
    class cls_billingaddress {
        public String zip;  //07660
        public cls_country country;
        public String addressee;    //Samsung Electronics America, Inc.
        public String city; //Ridgefield Park
        public String addr1;    //85 Challenger Rd.
        public cls_dropdownstate dropdownstate;
        public String state;    //NJ
        //public boolean override;
        public String addrtext; //Samsung Electronics America, Inc. 85 Challenger Rd. Ridgefield Park NJ 07660 United States
    }
    class cls_country {
        public String internalid;   //US
        public String name; //United States
    }
    class cls_dropdownstate {
        public String internalid;   //NJ
        public String name; //New Jersey
    }
    class cls_class {
        public String internalid;   //572
        public String name; //Project Events
    }
    class cls_billingschedule {
        public Integer billamount;  //1212121
        public String billdate; //11/2/2017
    }
    class cls_customform {
        public String internalid;   //108
        public String name; //Linux Sales Order
    }
    class cls_location {
        public String internalid;   //21
        public String name; //Project Events
    }
    class cls_entity {
        public String internalid;   //9560
        public String name; //Samsung Electronics America, Inc. - LF
    }*/
    public static list<Asset> fillingInfo(list<WrapperToGetSalesOrderDataForExisting> wrapList){
    //public static list<Asset> fillingInfo(set<string>ids){
        list<Asset> assetList = new list <Asset>();
        set<string> assetIdSet = new set <string>();
        map<string , string > assetIdvsSalesOrderMap = new map <string , string>();
        map<string , boolean > assetIdvsSalesOrderMap1 = new map <string , boolean>();
       // system.debug('**wrapList--'+wrapList);
       
        for(WrapperToGetSalesOrderDataForExisting wrap : wrapList){
            if(wrap.recordtype == 'salesorder'){
                /*Asset asset = new Asset();
                asset.name = 'Created BY NS TEST';
                if(wrap.memo != null)
                    asset.memo__c =  wrap.memo;
                //if(wrap.Project_Code__c != null)  
                //  asset.Project_Code__c = wrap.Project_Code__c;
                if(wrap.entity != null)
                    asset.NS_Entity_ID__c   = wrap.entity.internalid;
                if(wrap.subsidiary != null)
                    //asset.SubsidiaryID__c = wrap.subsidiary.internalid;
                if(wrap.terms != null)  
                    asset.PaymentTerms__c = wrap.terms.name;
                if(wrap.otherrefnum != null)    
                    asset.PO_Number__c = wrap.otherrefnum;
                if(wrap.department != null)
                    asset.NetSuite_Department__c = wrap.department.name;
                if(wrap.id != null)
                    asset.NetSuite_ID__c = wrap.id; 
                
                assetList.add(asset);       
                
                
                system.debug('**Id**'+asset.id);*/
                
                //assetIdSet.add(wrap.id);
                assetIdvsSalesOrderMap.put(wrap.id,wrap.tranid);
                assetIdvsSalesOrderMap1.put(wrap.id , wrap.custbody_fully_paid);
                 system.debug('**assetIdvsSalesOrderMap**'+assetIdvsSalesOrderMap); 
            }
        }
        
        list<Asset> assetListToUpdate = [select SalesOrderStatus__c,SalesOrderNumber__c,NetSuite_ID__c from asset where NetSuite_ID__c IN: assetIdvsSalesOrderMap.keySet()];
        //list<Asset> assetListToUpdate = [select SalesOrderStatus__c,SalesOrderNumber__c,NetSuite_ID__c from asset where NetSuite_ID__c IN:ids];
        for(asset assetObj : assetListToUpdate){
            system.debug('***'+assetIdvsSalesOrderMap + ' ***'+assetIdvsSalesOrderMap.get(assetObj.NetSuite_ID__c));
            if(assetIdvsSalesOrderMap1.containsKey(assetObj.NetSuite_ID__c) && assetIdvsSalesOrderMap1.get(assetObj.NetSuite_ID__c)){
                assetObj.SalesOrderStatus__c = 'Closed';
            }else{
                //Added by Tushar@cloudroute.in on 6 Oct 2020, #2012
                if(assetObj.SalesOrderStatus__c != 'At Risk')
                    assetObj.SalesOrderStatus__c = 'Open';
            }
            assetObj.SalesOrderNumber__c = assetIdvsSalesOrderMap.get(assetObj.NetSuite_ID__c) ;
            assetList.add(assetObj);    
        
        }
        system.debug('**assetList--'+assetList);
        //if(assetList.size() > 0){
         return assetList;
        
        //}
        
        //system.debug('**Id**'+assetList[0].id);
    }
    
    
}