/********************************************************
* Created by: Pratik D 
* Created Date: 28-APR-2020.
* Description: AddressTrigger
* JIRA - SFDC-1230
********************************************************/

trigger AddressTrigger on Address__c (before insert, before update,before delete, after insert,after update, after delete, after undelete) {
    system.debug('>>>>>>>>');
    AddressTriggerHandler handler = new AddressTriggerHandler();
    TriggerDispatcher.Run(handler);
}