public class ContactInsertUtilityClass {
    public void contactInsert(List<sObject> triggerNew){
        Map<Schema.SObjectType,String> mapOfSoobjectvsEmailField = new Map<Schema.SObjectType,String>{Travel_Fund_Request__c.sObjectType => 'TFREmail__c',
            Visa_Request__c.sObjectType => 'ContactEmail__c'};
                
                Set<String> emailSet = new Set<String>();
        
        for(SObject sObj : triggerNew){
            String emailField = (String)sObj.get(mapOfSoobjectvsEmailField.get(sObj.getSObjectType()));
            System.debug('sObj.get(\'Contact__c\')'+sObj.get('Contact__c'));
            if(emailField != null && emailField != '' && sObj.get('Contact__c') == null){
                emailSet.add(emailField);
            }
        }
        System.debug('emailSet---->'+emailSet.size());
        if(!emailSet.isEmpty()){
            System.debug('#no contact populated');
            Map<String,Id> emailVsId = new Map<String,Id>();
            List<Alternate_Email__c> alternateEmailToActivate = new List<Alternate_Email__c>();
            for(Alternate_Email__c a:[SELECT Id, Alternate_Email_Address__c,Contact_Name__c, Lead_Name__c, Active__c FROM Alternate_Email__c WHERE Alternate_Email_Address__c IN: emailSet]){
                if(a.Contact_Name__c != null){
                    emailVsId.put(a.Alternate_Email_Address__c,a.Contact_Name__c); 
                }
                else if(a.Lead_Name__c != null){
                    emailVsId.put(a.Alternate_Email_Address__c,a.Lead_Name__c);
                }
                if (!a.Active__c) {
                    a.Active__c = true;
                    alternateEmailToActivate.add(a);
                }
            }
            
            if(!alternateEmailToActivate.isEmpty()){
                SObjectAccessDecision alternateEmailSecurityDecision = Security.stripInaccessible(AccessType.UPDATABLE, alternateEmailToActivate);
                update alternateEmailSecurityDecision.getRecords();
            }
            
            List<Contact> contactList = new List<Contact>(); 
            Map<String,Id> emailVsContactId = new Map<String,Id>();
            Map<id,String> leadIdVsEmail = new Map<id,String>();
            List<Id> leadList = new List<Id>();
            
            List<Database.LeadConvert> convertedList = new List<Database.LeadConvert>();
            List<Lead> leadsToConvert = new List<Lead>();

            for(SObject sObj : triggerNew){
                String emailField = (String)sObj.get(mapOfSoobjectvsEmailField.get(sObj.getSObjectType()));
                if(emailVsId.containsKey(emailField)){
                    system.debug('in if');
                    String recId = String.valueOf(emailVsId.get(emailField));
                    system.debug('recId' + recId);
                    if(recId.startsWith('003')){
                        sObj.put('Contact__c',recId);
                    }
                    else if(recId.startsWith('00Q')){
                        Lead l = new Lead();
                        l.Id = recId;
                        l.Convert_Lead__c = true;
                        leadsToConvert.add(l);
                        leadIdVsEmail.put(recId,emailField);   
                    }
                }
                else{
                    system.debug('in else');
                    if(sObj.get('LastName__c') != null && sObj.get('LastName__c') != '' && emailField != '' && emailField != null){
                        Contact con = new Contact();
                        con.FirstName = (String)sObj.get('FirstName__c');
                        con.LastName = (String)sObj.get('LastName__c');
                        con.Email = (String)sObj.get(mapOfSoobjectvsEmailField.get(sObj.getSObjectType()));
                        con.Title = (String)sObj.get('Title__c');
                        con.OtherPhone = (String)sObj.get('Office_phone__c');
                        con.MailingStreet = (String)sObj.get('mailing_Address1__c');
                        con.MailingCity = (String)sObj.get('City__c');
                        con.MailingState = (String)sObj.get('State__c');
                        con.MailingPostalCode = (String)sObj.get('Zipcode__c');
                        con.MailingCountry = (String)sObj.get('Country__c');
                        con.Birthdate = (Date)sObj.get('DateofBirth__c');
                        contactList.add(con);
                    }
                    
                }
            }
            
            if(contactList.size()>0){
                insert contactList;
            }

            if (!leadsToConvert.isEmpty()) {
                update leadsToConvert;

                for (Lead l : [SELECT Id, ConvertedContactId FROM Lead WHERE Id IN :leadsToConvert]) {
                    if(leadIdVsEmail.containsKey(l.Id)) {
                        emailVsContactId.put(leadIdVsEmail.get(l.Id), l.ConvertedContactId);
                    }
                }
            }

            for(Contact c: contactList){
                emailVsContactId.put(c.Email,c.Id);
            }
            
            Map<String,SObject> emailVsSObjectMap = new Map<String,SObject>();
            for(SObject sObj : triggerNew){
                String emailField = (String)sObj.get(mapOfSoobjectvsEmailField.get(sObj.getSObjectType()));
                emailVsSObjectMap.put(emailField,sObj);
                if(emailVsContactId.containsKey(emailField)){
                    sObj.put('Contact__c',emailVsContactId.get(emailField));
                }
            }
            
            List<Alternate_Email__c> alternateEMAILList = [SELECT Id,Alternate_Email_Address__c,Contact_Name__r.Title,Contact_Name__r.OtherPhone,Contact_Name__r.MailingStreet,
                                                           Contact_Name__r.MailingCity,Contact_Name__r.MailingState,Contact_Name__r.MailingCountry,Contact_Name__r.Birthdate, Contact_Name__r.LastName, Contact_Name__r.FirstName
                                                           FROM Alternate_Email__c WHERE Alternate_Email_Address__c IN: emailVsId.keySet()];
            system.debug('alternateEMAILList'+alternateEMAILList);
            System.debug('emailVsSObjectMap'+emailVsSObjectMap);
            List<Contact> updatedContactList = new List<Contact>();
            
            for(Alternate_Email__c ae : alternateEMAILList){
                Boolean flag = false;
                Contact c = new Contact();
                c.Id = ae.Contact_Name__c;
                System.debug('--->c.Id'+c.Id);
                if(emailVsSObjectMap.containsKey(ae.Alternate_Email_Address__c)){
                    if(ae.Contact_Name__r.Title == null){
                        c.Title = (String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('Title__c');
                        flag = true;
                    }
                    
                    if(ae.Contact_Name__r.OtherPhone == null){
                        c.OtherPhone = (String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('Office_phone__c');
                        flag = true;
                    }
                    
                    if(ae.Contact_Name__r.MailingStreet == null){
                        c.MailingStreet = (String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('mailing_Address1__c');
                        flag = true;
                    }
                    
                    if(ae.Contact_Name__r.MailingCity == null){
                        c.MailingCity = (String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('City__c');
                        flag = true;
                    }
                    if(ae.Contact_Name__r.MailingState == null){
                        c.MailingState = (String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('State__c');
                        flag = true;
                    }
                    if(ae.Contact_Name__r.MailingCountry == null){
                        c.MailingCountry = (String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('Country__c');
                        flag = true;
                    }
                    if(ae.Contact_Name__r.Birthdate == null){
                        c.Birthdate = (Date)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('DateofBirth__c');
                        flag = true;
                    }
                    if((String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('FirstName__c') != ''
                       && (String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('FirstName__c') != Null
                       && (String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('FirstName__c') != ae.Contact_Name__r.FirstName){
                           c.FirstName = (String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('FirstName__c');
                           flag = true;
                       }
                    if((String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('LastName__c') != ''
                       && (String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('LastName__c') != Null
                       && (String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('LastName__c') != ae.Contact_Name__r.LastName){
                           c.LastName = (String)emailVsSObjectMap.get(ae.Alternate_Email_Address__c).get('LastName__c');
                           flag = true;
                       }
                    
                }
                if(flag){
                    updatedContactList.add(c); 
                }
            }
            if(!updatedContactList.IsEmpty()){
                update updatedContactList;
            }
        }
    }
}