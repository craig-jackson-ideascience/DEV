trigger EnrollmentTrigger on Enrollment__c (before insert, before update,before delete,after delete, after insert,after update, after undelete) {
	EnrollmentTriggerHandler handler = new EnrollmentTriggerHandler();
	TriggerDispatcher.run(handler);
}