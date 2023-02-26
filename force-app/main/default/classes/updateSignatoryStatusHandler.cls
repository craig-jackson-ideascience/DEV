public class updateSignatoryStatusHandler {
    
    public void insertUpdate(List<dsfs__DocuSign_Recipient_Status__c> lstDocR){
        set<Id> docStatusId = new set<Id>();
        map<Id,dsfs__DocuSign_Status__c> mapDocStatus = new map<Id,dsfs__DocuSign_Status__c>();
        for(dsfs__DocuSign_Recipient_Status__c obj  :lstDocR){
            docStatusId.add(obj.dsfs__Parent_Status_Record__c);
        }
       
        for(dsfs__DocuSign_Status__c objDoc: [Select id,Signatory_Status__c from dsfs__DocuSign_Status__c where id IN:docStatusId]){
            for(dsfs__DocuSign_Recipient_Status__c obj : [Select id,
                 Name,dsfs__Recipient_Status__c,
                 dsfs__DocuSign_Routing_Order__c 
                 from dsfs__DocuSign_Recipient_Status__c 
                 Where dsfs__Parent_Status_Record__r.id IN: docStatusId 
                 ORDER BY dsfs__DocuSign_Routing_Order__c ASC]){
                if(obj.dsfs__Recipient_Status__c != 'Completed'){
                    objDoc.Signatory_Status__c = obj.Name;
                    mapDocStatus.put(objDoc.id,objDoc);
                    break;
                }else{
                    objDoc.Signatory_Status__c ='Completed';
                    mapDocStatus.put(objDoc.id,objDoc);
                }
                
            }
        }
        update mapDocStatus.values();
    }  
}