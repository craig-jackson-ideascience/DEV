global with sharing class WrapperForGettingSalesOrder {
  public string id;
  public string recordtype;
  public Columns columns;
  public class Columns{
      public boolean custbody_fully_paid;
  }
  
  /*public static void fillingInfo(list<WrapperForGettingSalesOrder> wrapList){
    list<Asset> assetList = new list <Asset>();
    set<string> idSet = new set <string>();
    system.debug('**wrapList--'+wrapList);  
    for(WrapperForGettingSalesOrder wrap : wrapList){
      if(wrap.recordtype == 'salesorder'){
        
        idSet.add(wrap.id);
      }
    }
    system.debug('**idSet**'+idSet);
    Endpoints__c endPointCustSet = [select name, endpoint__c from Endpoints__c where name = 'To Get Sales Order ID From NS'];
    for(string ids :idSet ){
      string endpoint = endPointCustSet.endpoint__c+ids;
      
      assetList.addall(NetSuiteToSalesforce.callOutToNetToGetRecord(endpoint,'GET'));  
    }
     
     update assetList; 
    
    }*/
  }