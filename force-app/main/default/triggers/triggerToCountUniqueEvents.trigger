trigger triggerToCountUniqueEvents on QuoteLineItem (after insert, after update,after delete) {
  set<id> quoteId=new set<id>();
  list<quote> RelatedQuoteLineItems;
  //map<id,string> uniqueEvents=new map<id,string>();
  list<Quote> QuoteToBeUpdate=new list<quote>();
  Set<String> UniqueEventname=new Set<String>();
  if(trigger.isInsert || trigger.isUpdate){
  for(QuoteLineItem QuoteItem:[select quoteid from quotelineitem where id in :trigger.new]){
    quoteId.add(QuoteItem.quoteId);
   }
  }
  if( trigger.isUpdate || trigger.isDelete){
  for(QuoteLineItem QuoteItem :trigger.old){
    quoteId.add(QuoteItem.quoteId);
   }
  }
  system.debug('setofids+++++++++'+quoteId);
  
  if(!quoteId.isEmpty()){
     RelatedQuoteLineItems=[select id,UniqueEvent__c,UniqueEventNames__c,(select id,event__c,event__r.name from QuoteLineItems) from quote where id in:quoteId];
  }  
  
  for(Quote quoteObj:RelatedQuoteLineItems){
    system.debug('entryinforlopp+++++++++');
    String id;
    integer i=0;
    integer lineitemsize=quoteObj.QuoteLineItems.size();
    system.debug('lineitemsize'+lineitemsize);
    for(QuoteLineItem ItemObj:quoteObj.QuoteLineItems){ 
      if(ItemObj.event__r.name != null){
      	UniqueEventname.add(ItemObj.event__r.name);	 
      }              
      if(ItemObj.event__c!=null && id==null){
       id=ItemObj.event__c;
       system.debug('null lopp first entry');  
      }else if(ItemObj.event__c!=null && id.contains(ItemObj.event__c) ){
        system.debug('2nd entry  entry');
        i++;        
      }
      else if(ItemObj.event__c==null){
        i++;
      }
      
    }
    System.debug('value of i+++++++++++'+i);
    if(!UniqueEventname.isEmpty()){
    	String EventName1='';
    	for(String EventName:UniqueEventname){    		    		
    		EventName1 += EventName+'\n';
    	} 
    	quoteObj.UniqueEventNames__c=EventName1;   	
    }
    if(UniqueEventname.isEmpty()){
      quoteObj.UniqueEventNames__c='';	
    }
    if(i>=lineitemsize-1){
      quoteObj.UniqueEvent__c=true;      
    }
    /*else if(i==lineitemsize-2 && trigger.isdelete){
      quoteObj.UniqueEvent__c=true;
      QuoteToBeUpdate.add(quoteObj);
    }*/
    else{
      quoteObj.UniqueEvent__c=false;      
    }
    System.debug(UniqueEventname+'@@@@@@@@@UniqueEventname');
    QuoteToBeUpdate.add(quoteObj);
  }
  try{
    if(!QuoteToBeUpdate.isEmpty()){
      update QuoteToBeUpdate;
    }    
  }catch(Exception e){
    System.debug(e);
  }  
    
}