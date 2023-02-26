public class TravelFundLineItemHandler {

    public void afterInsert(Map<id,Travel_Fund_Request_Line_Item__c> oldMap,Map<id,Travel_Fund_Request_Line_Item__c> newMap){
        insertUpdateMeth(null,newMap);
    }
    
    public void afterUpdate(Map<id,Travel_Fund_Request_Line_Item__c> oldMap,Map<id,Travel_Fund_Request_Line_Item__c> newMap){
        insertUpdateMeth(oldMap,newMap);
    }
    
    public void insertUpdateMeth(Map<id,Travel_Fund_Request_Line_Item__c> oldMap,Map<id,Travel_Fund_Request_Line_Item__c> newMap){
        set<id> fundRequestLineId = new set<id>();
        for(Travel_Fund_Request_Line_Item__c fundRequest : newMap.values()){
        if(fundRequest.Line_Status__c != null && (oldMap == null || (oldMap != null && fundRequest.Line_Status__c != oldMap.get(fundRequest.Id).Line_Status__c ))){
            fundRequestLineId.add(fundRequest.Travel_Fund_Request__c);
        }
        }
        travelLineItemUpdate(fundRequestLineId);
    }
    public void onAfterDelete(Map<id,Travel_Fund_Request_Line_Item__c> oldMap){
        set<id> fundRequestLineId = new set<id>();
        for(Travel_Fund_Request_Line_Item__c fundRequest : oldMap.values()){
            fundRequestLineId.add(fundRequest.Travel_Fund_Request__c);
        }
            travelLineItemUpdate(fundRequestLineId);
    }
    
    public void travelLineItemUpdate(set<id> fundRequestIds){
        List<Travel_Fund_Request__c> fundRequestList = [select id ,(select id,Line_Status__c,Travel_Fund_Request__c from Travel_Fund_Request_Line_Items__r) from Travel_Fund_Request__c where id in:fundRequestIds ] ;
        list<Travel_Fund_Request__c> updateValueFundRequest = new list<Travel_Fund_Request__c>();
        
        for(Travel_Fund_Request__c travelFundRequest : fundRequestList){
            if(checkRejectedStatus(travelFundRequest.Travel_Fund_Request_Line_Items__r))
            {
                travelFundRequest.Status__c = 'Rejected';
                updateValueFundRequest.add(travelFundRequest);
            }else if(checkPartiallyApprovedStatus(travelFundRequest.Travel_Fund_Request_Line_Items__r)){
                travelFundRequest.Status__c = 'Partially Approved';
                updateValueFundRequest.add(travelFundRequest);
            }
            
        }
        system.debug('@@data@@@ ' +updateValueFundRequest);
        if(updateValueFundRequest.size() > 0){
            update updateValueFundRequest;
        }
    }
    
    private boolean checkRejectedStatus(List<Travel_Fund_Request_Line_Item__c> fundRequestLineItem){
        boolean isRejected = true;
        for(Travel_Fund_Request_Line_Item__c item : fundRequestLineItem){
            if(item.Line_Status__c != 'Rejected')
            {
                isRejected = false;
                break;
            }
        }
        return isRejected;
    }
    
    private boolean checkPartiallyApprovedStatus(List<Travel_Fund_Request_Line_Item__c> fundRequestLineItem){
        boolean partiallyApproved = true;
        Integer approvedCount = 0;
        Integer rejectedCount = 0;
        for(Travel_Fund_Request_Line_Item__c item : fundRequestLineItem){
            system.debug('Line status ' + item.Line_Status__c);
            if(item.Line_Status__c != 'Rejected' && item.Line_Status__c != 'Approved')
            {
                partiallyApproved = false;
                break;
            }else
            {
                if(item.Line_Status__c == 'Rejected')
                    rejectedCount +=1;
                else if(item.Line_Status__c == 'Approved')
                    approvedCount +=1;
            }
        }
        system.debug('Partially Approved ' + partiallyApproved);
         system.debug('Rejected Count ' + rejectedCount);
        if(rejectedCount <= 0) //if no rejected
             partiallyApproved = false;
        return partiallyApproved;
    }
}