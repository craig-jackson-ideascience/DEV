public Class AccountTriggerHandler implements ITriggerHandler{
    AccountTriggerAction action = new AccountTriggerAction();
    public static Set<Id> deleteAlternateEmails = new Set<Id>();
    public void BeforeInsert(List<SObject> triggerNew){
        
        // action.updateWebsite((List<Account>)triggerNew, NULL);
    }
    
    public void beforeUpdate(Map<id, SObject> newAccount, Map<id, SObject> oldAccount){
        action.updateOldOwnersEmail((Map<id, Account>)newAccount, (Map<id, Account>)oldAccount);
        AccountTriggerAction.updateSectorAccount((Map<id, Account>)newAccount, (Map<id, Account>)oldAccount);
        // action.updateWebsite((List<Account>)newAccount.Values(), (Map<id,Account>)oldAccount);
    }
    
    public static void BeforeDelete(Map<Id, Sobject> oldMap){
        //call before delete actions
        getAlternateEmailsToBeDeleted((List<Account>)oldMap.Values());
    }
    
    public static void afterInsert(Map<Id, SObject> newMap){
        System.debug('in after insert');
        //createOrUpdateAlternateEmail((Map<Id, Account>)newMap,null);
    }
    
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){
        //createOrUpdateAlternateEmail((Map<Id, Account>)newMap,(Map<Id, Account>)oldMap);
        //Call Method to update address obj for an Account
        updateAddressObjForAccount((Map<Id, Account>)newMap, (Map<Id, Account>)oldMap);
        updateEmployeeCountNeedVerified((Map<Id, Account>)newMap, (Map<Id, Account>)oldMap);
        AccountTriggerAction.updateSectorIndustryOnContact((Map<id, Account>)newMap, (Map<id, Account>)oldMap);
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap){
        AccountTriggerAction.deleteAlternateEmail((List<Account>)oldMap.values(), deleteAlternateEmails);
    }
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap){
        //call after undelete actions
    }
    
    public Boolean IsDisabled(){
        return false;
    }
    
    /*
public static void createOrUpdateAlternateEmail(Map<Id, Account> newMap,Map<Id, Account> oldMap){
List<Alternate_Email__c> alternateEmailList = new List<Alternate_Email__c>();
Set<String> alternateEmailSet = new Set<String>();
for(Account acc : newMap.values()){
if(((String.isNotBlank(acc.PersonEmail) && acc.IsPersonAccount) && (oldMap == null || (oldMap != null  && oldMap.get(acc.id).PersonEmail != acc.PersonEmail)))){
alternateEmailSet.add(acc.PersonEmail);
}
}
if(!alternateEmailSet.IsEmpty()){
List<Alternate_Email__c> alternateEmails = [SELECT Alternate_Email_Address__c FROM Alternate_Email__c
WHERE Alternate_Email_Address__c IN : alternateEmailSet];
Set<String> emailSet = new Set<String>();
for(Alternate_Email__c altEmail :alternateEmails){
emailSet.add(altEmail.Alternate_Email_Address__c);
}
for(Account acc : newMap.values()){
if(!emailSet.contains(acc.PersonEmail)){
Alternate_Email__c altEmail = new Alternate_Email__c();
altEmail.Alternate_Email_Address__c = acc.PersonEmail;
altEmail.Primary_Email__c = true;
altEmail.Active__c = true;
altEmail.Contact_Name__c = acc.PersonContactId;
alternateEmailList.add(altEmail);
}
}
if(!alternateEmailList.isEmpty()){
insert alternateEmailList;
}
}
}
*/
    private static void getAlternateEmailsToBeDeleted(List<Account> accounts){
        deleteAlternateEmails.clear();
        for (Alternate_Email__c alternateEmail : [SELECT Id
                                                  FROM Alternate_Email__c
                                                  WHERE contact_name__r.AccountId IN:accounts]){
                                                      deleteAlternateEmails.add(alternateEmail.Id);
                                                  }
    }
    
    public static void updateAddressObjForAccount(Map<Id, Account> newMap, Map<Id, Account> oldMap){
        Map<Id, String> IdVsAddress = new Map<Id, String>();
        
        //Iterate over old values
        for (Account accnt : oldMap.values()){
            
            //if the billing address is changed
            if (newMap.get(accnt.Id).Name != accnt.Name || newMap.get(accnt.Id).BillingStreet != accnt.BillingStreet || newMap.get(accnt.Id).BillingCity != accnt.BillingCity || newMap.get(accnt.Id).BillingState != accnt.BillingState || newMap.get(accnt.Id).BillingPostalCode != accnt.BillingPostalCode || newMap.get(accnt.Id).BillingCountry != accnt.BillingCountry){
                //Storing the billing address in the form which is stored on address record
                String oldBillingAddress = (!String.isBlank(accnt.BillingStreet) ? accnt.BillingStreet + ' ' : '') + '<br>' + (!String.isBlank(accnt.BillingCity) ? accnt.BillingCity + ', ' : '') + (!String.isBlank(accnt.BillingState) ? accnt.BillingState + ' ' : '') + (!String.isBlank(accnt.BillingPostalCode) ? accnt.BillingPostalCode : '') + '<br>' + (!String.isBlank(accnt.BillingCountry) ? accnt.BillingCountry : '');
                
                IdVsAddress.put(accnt.Id, oldBillingAddress);
            }
        }
        System.debug('IdVsAddress ' + IdVsAddress);
        //if map is not empty
        if (!IdVsAddress.isEmpty()){
            List<Address__c> addressToUpdate = new List<Address__c>();
            
            //Retrieve the Account records with its associated address records
            List<Account> accountList = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, (SELECT Id, Address__c
                                                                                                                                        FROM Addresses__r)
                                         FROM Account 
                                         WHERE Id IN:IdVsAddress.keySet() AND BillingCity != null AND BillingState != null AND BillingPostalCode != null];
            System.debug('accountList ' + accountList);
            
            //Iterate over the list
            for (Account acc : accountList){
                
                //if it has any address record associated with it
                if (acc.Addresses__r.size() > 0){
                    
                    //if the oldAddress of account matches with address record's address then update the address record with new address of account
                    for (Address__c addr : acc.Addresses__r){
                        if (IdVsAddress.containsKey(acc.Id) && IdVsAddress.get(acc.Id) == addr.Address__c){
                            Address__c addrss = new Address__c(Id = addr.Id);
                            String billToNameString = (acc.Name + (String.isNotBlank(acc.BillingCountry) ? ' - ' + acc.BillingCountry : '')).length() >= 80 ? (acc.Name + (String.isNotBlank(acc.BillingCountry) ? ' - ' + acc.BillingCountry : '')).subString(0, 80) : (acc.Name + (String.isNotBlank(acc.BillingCountry) ? ' - ' + acc.BillingCountry : ''));
                                addrss.Name = billToNameString;
                            addrss.Street__c = !String.isBlank(acc.BillingStreet) ? acc.BillingStreet : '';
                            addrss.City__c = acc.BillingCity;
                            addrss.State__c = acc.BillingState;
                            addrss.Zip_Postal_Code__c = acc.BillingPostalCode;
                            addrss.Country__c = !String.isBlank(acc.BillingCountry) ? acc.BillingCountry : '';
                            addressToUpdate.add(addrss);
                            break;
                        }
                    }
                }
            }
            System.debug('addressToUpdate ' + addressToUpdate);
            
            //update the address records
            if (!addressToUpdate.isEmpty()){
                update addressToUpdate;
            }
        }
    }
    
    public static void updateEmployeeCountNeedVerified(Map<Id, Account> newMap, Map<Id, Account> oldMap){
        Id idMembershipOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership').getRecordTypeId();
        set<Id> setAccountIds = new set<Id>();
        set<Id> setEmployeeCountNeedVerified = new set<Id>();
        set<Id> setOpportunityIds = new set<Id>();
        map<Id, Opportunity> mapOpportunity = new map<Id, Opportunity>();
        map<Id, Account> mapAccount = new map<Id, Account>();
        map<Id, List<Product_Details__c>> mapProject_ProductDetails = new map<Id, List<Product_Details__c>>();
        List<Opportunity> listOppstoUpdate = new List<Opportunity>();
        string joinnowEmployees;
        
        for (Account objAccount : newMap.values()){
            
            if (oldMap.get(objAccount.id).No_Of_Employess__c != objAccount.No_Of_Employess__c){
                setAccountIds.add(objAccount.id);
                mapAccount.put(objAccount.id, objAccount);
                //
                if (objAccount.No_Of_Employess__c != null && objAccount.No_Of_Employess__c != ''){
                    joinnowEmployees = objAccount.No_Of_Employess__c;
                } else{
                    joinnowEmployees = '';
                }
                
                system.debug('jn1: ' + objAccount.No_Of_Employess__c);
                system.debug('jn2: ' + joinnowEmployees);
                
                if (joinnowEmployees.contains(',')){
                    joinnowEmployees = joinnowEmployees.replace(',', '');
                }
                
                if (!joinnowEmployees.isNumeric()){
                    joinnowEmployees = '';
                }
                
                if (joinnowEmployees != null && joinnowEmployees != ''){
                    if (objAccount.NumberOfEmployees != Integer.valueOf(joinnowEmployees)){
                        setEmployeeCountNeedVerified.add(objAccount.Id);
                    }
                }
                
            }
        }
        
        if (setAccountIds.size() > 0 && !setEmployeeCountNeedVerified.isEmpty()){
            for (Opportunity objOpportunity : [Select id, accountId, Employee_Count_Needs_Verified__c, Product_Tier_Needs_Verification__c, Company_Type_Needs_Verified__c, Account.No_Of_Employess__c, Type, recordtypeid
                                               from Opportunity
                                               where AccountId IN:setEmployeeCountNeedVerified AND isClosed = false AND Hold__c != true and Type != 'Renewal' AND recordTypeid = :idMembershipOpp]){
                                                   
                                                   
                                                   objOpportunity.Employee_Count_Needs_Verified__c = true;
                                                   
                                                   
                                                   listOppstoUpdate.add(objOpportunity);
                                                   
                                                   //mapOpportunity.put(objOpportunity.Id,objOpportunity);
                                                   //setOpportunityIds.add(objOpportunity.Id);
                                               }
            
            /*system.debug('setOpportunityIds-->'+setOpportunityIds);
for(OpportunityLineItem objOpportunityProduct : [Select OpportunityId,Projects__c,Product2Id,Start_Tier__c,End_Tier__c, Opportunity.AccountId, Opportunity.Account.No_Of_Employess__c from OpportunityLineItem Where OpportunityId IN:setOpportunityIds]){
Opportunity objOpportunity = mapOpportunity.get(objOpportunityProduct.OpportunityId);
String jnEmployees = objOpportunity.account.No_Of_Employess__c;
jnEmployees = jnEmployees.replace(',','');
if (!jnEmployees.isNumeric()) {
jnEmployees = '';
}
if (jnEmployees != null && jnEmployees != '') {
if(objOpportunityProduct.Start_Tier__c < Integer.valueOf(jnEmployees) && objOpportunityProduct.End_Tier__c < Integer.valueOf(jnEmployees)  && objOpportunityProduct.End_Tier__c != null ){
objOpportunity.Product_Tier_Needs_Verification__c = true;
}
}

if (!listOppstoUpdate.contains(objOpportunity)) {
listOppstoUpdate.add(objOpportunity);
}
}*/
            
            if (listOppstoUpdate.size() > 0){
                try{
                    update listOppstoUpdate;
                } catch (DmlException e){
                    system.debug('Account Trigger Handler Error in Updating Related Opportunity Tier Verification: ' + e.getMessage());
                }
            }
            system.debug('mapOpportunity--->' + mapOpportunity.values());
        }
    }
    
}