public class CancelOrResendDocusignController {
	@AuraEnabled
    public static String getDocuSignStatus(Id opportunityId){
        List<dsfs__DocuSign_Status__c> docuSign = [SELECT Id,dsfs__Envelope_Status__c,dsfs__DocuSign_Envelope_ID__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Envelope_Status__c = 'Sent' 
                                                   AND dsfs__Opportunity__c =: opportunityId];
        
       return !docuSign.isEmpty() ? docuSign[0].dsfs__DocuSign_Envelope_ID__c : '';
       
    }
    
    @AuraEnabled
    public static String voidEnvelope(String envelopeId , String reason,Id opportunityId){
        
        HttpResponse response = DocusignAPI.voidEnvelope(envelopeId,reason);
        String responseString ='';
        if(response.getStatusCode() == 200){
            Opportunity opp = new Opportunity (Id=opportunityId,Contract_Sent_By__c=null);
            update opp;
            responseString = response.getStatus();
        }else{
            responseString = response.getBody();
        }
        return responseString;
    }
    
    @AuraEnabled
    public static String getEnvelopeId(Id opportunityId){
        List<dsfs__DocuSign_Status__c> docuSign = [SELECT Id,dsfs__Envelope_Status__c,dsfs__DocuSign_Envelope_ID__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Envelope_Status__c = 'Sent' 
                                                   AND dsfs__Opportunity__c =: opportunityId];
        return !docuSign.isEmpty() ? reSendEnvelope(docuSign[0].dsfs__DocuSign_Envelope_ID__c) : '';
    }
    
    private static String reSendEnvelope(String envelopeId){
        HttpResponse response = DocusignAPI.reSendEnvelope(envelopeId);
        return response.getStatusCode() == 200 ? response.getStatus() : response.getBody();
    }
    
}