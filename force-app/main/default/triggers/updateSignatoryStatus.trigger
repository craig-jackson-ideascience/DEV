trigger updateSignatoryStatus on dsfs__DocuSign_Recipient_Status__c (after insert,after update) {
    
    if( trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        if(Recursion.allowRecursion)
            return;
        Recursion.allowRecursion = true;
        updateSignatoryStatusHandler handler = new updateSignatoryStatusHandler();
        handler.insertUpdate(trigger.new);
    }
}