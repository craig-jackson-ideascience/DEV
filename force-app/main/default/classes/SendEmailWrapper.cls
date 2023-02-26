public with sharing class SendEmailWrapper {
    
    public Set<Id> attachmentID{get;set;}
    public List<Id> contacts {get;set;}
    public string subject{get;set;}
    public string body{get;set;}
    public string templateId {get;set;}
    public string whatId {get;set;}

    public class SendEmailContactWrapper
    {
        public Id recordIdSet{get;set;}
        public Set<Id> contactIds {get;set;}
        public Map<string,object> params {get;set;}

        public SendEmailContactWrapper(Id recordIdSet,Set<Id> contactIds,Map<string,object> params)
        {
            this.recordIdSet = recordIdSet;
            this.contactIds = contactIds;
            this.params = params;
        }
    }

}