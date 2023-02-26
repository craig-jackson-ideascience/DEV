/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 09-10-2019.
 * Description: AlternateEmailValidatorBatch
 ********************************************************/
public class AlternateEmailValidatorBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    List<Id> alternateEmailIds;
    String whereCondition = '';

    public AlternateEmailValidatorBatch() {
        this.alternateEmailIds = new List<Id>();
    }

    public AlternateEmailValidatorBatch(String whereCondition) {
        this.alternateEmailIds = new List<Id>();
        this.whereCondition = whereCondition;
    }


    public AlternateEmailValidatorBatch(List<Id> alternateEmailIds) {
        this.alternateEmailIds = alternateEmailIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryString = 'SELECT ID, Alternate_Email_Address__c,Verified__c,Email_Verified__c FROM Alternate_Email__c ' + (alternateEmailIds.size() > 0 ? ' WHERE Id IN :alternateEmailIds ' : whereCondition);
        system.debug(queryString);
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Alternate_Email__c> alternateEmailstoUpdate = new List<Alternate_Email__c>();

        try {
            System.debug('Scope:' + scope);
            for (sObject obj : scope) {
                Alternate_Email__c alternate_email = (Alternate_Email__c) obj;
                MailBoxWrapper wrap = EmailValidator.validate(alternate_email.Alternate_Email_Address__c);
                if (wrap != null && wrap.smtp_check != null) {
                    System.debug('wrap: ' + wrap);
                    alternateEmailstoUpdate.add(new Alternate_Email__c(Id = alternate_email.Id, Verified__c = wrap.smtp_check, Date_Verified__c = System.now()));
                } else if (wrap != null) {
                    alternateEmailstoUpdate.add(new Alternate_Email__c(Id = alternate_email.Id, Email_Validation_Error__c = String.valueOf(wrap)));
                }
            }
            System.debug(alternateEmailstoUpdate + '====> alternateEmailstoUpdate');
            if (alternateEmailstoUpdate.size() > 0) Database.update(alternateEmailstoUpdate, false);

        } catch (Exception e) {
            System.debug('Exception: ' + e + ', Message: ' + e.getMessage() + ', Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext bc) {

    }

}