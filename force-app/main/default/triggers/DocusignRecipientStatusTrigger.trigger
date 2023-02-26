/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 30-10-2019.
 * Description: DocusignRecipientStatusTrigger
 ********************************************************/
trigger DocusignRecipientStatusTrigger on dsfs__DocuSign_Recipient_Status__c (after update, before update, after insert, before insert, after delete, before delete,after undelete) {
    TriggerDispatcher.Run(new DocusignRecipientStatusTriggerHanlder());

}