@isTest
public class updateSignatoryStatusTest {
    @isTest
    public static void test1(){
        dsfs__DocuSign_Status__c  dsfs = new dsfs__DocuSign_Status__c(
            dsfs__Envelope_Status__c = 'Completed',
            dsfs__DocuSign_Envelope_ID__c = '1001A123-1234-5678-1D84-F8D44652A382',
            dsfs__Subject__c = 'Document for eSignature');
        insert dsfs;
        
        dsfs__DocuSign_Recipient_Status__c objdocuRsign = new dsfs__DocuSign_Recipient_Status__c();
        objdocuRsign.dsfs__Parent_Status_Record__c = dsfs.ID;
        objdocuRsign.dsfs__DocuSign_Recipient_Id__c = '1234';
        objdocuRsign.Name = 'Test';
        objdocuRsign.dsfs__Date_Signed__c = System.Today();
        insert objdocuRsign ;
        
        updateSignatoryStatusHandler objclass = new updateSignatoryStatusHandler();
    }
    
}