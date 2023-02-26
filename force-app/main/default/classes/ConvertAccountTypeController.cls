public  without sharing class ConvertAccountTypeController {
    public String bussinessAccountID{get;set;}
    public boolean selectedVal{get;set;}
    public string recordTypeId{get;set;}
    public Account account {get;set;}
    
    public ConvertAccountTypeController(ApexPages.StandardController controller){
        if (!Test.isRunningTest()){
              controller.addFields(new List<String> {'PersonContactId'} );
        }
        this.account = (Account)controller.getRecord();
        selectedVal =false;
        recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company_Account').getRecordTypeId(); 
        
    }
    public pageReference mergeAccount(){
        Integer opportunity = [Select Count() From Opportunity WHERE AccountId =:account.Id ];
        
        if(String.isNotBlank(bussinessAccountID)){
            if(opportunity > 0){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'The selected Person Account has its related opportunities, hence it cannot be merged'));
                return null;
            }else{
                updateAccountRecordType(account.Id);
                Contact contact = new Contact(id = account.PersonContactId, AccountID = bussinessAccountID );
                update contact;
                delete account;
                PageReference ref = new PageReference('/'+bussinessAccountID);
                return ref;
            } 
        }else{
            updateAccountRecordType(account.Id);
            PageReference ref = new PageReference('/'+account.Id);
            return ref;
        }
    }
    public pageReference closeVf(){
        PageReference ref = new PageReference('/'+account.Id);
        return ref;
    }
    
    private Account updateAccountRecordType(string accountID){
        Account account = new Account();
        account.Id = accountID;
        account.RecordTypeId = recordTypeId;
        update account;
        return account;
        
    }
    
    
    
    
    
}