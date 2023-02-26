public class HLAllMemberContact {
    public string AccountTeamName {get;set;}
    public string ProjectName {get;set;}
    public string UserName {get;set;}
    Public List<String> selectedFieldsList {get;set;}
    public Integer OffsetSize = 0;
    private Integer QueryLimit = 1000;
    List<Project_Role__c> lstProjectRole = new List<Project_Role__c>();
    List<AccountTeamMember> lstATM = new list<AccountTeamMember>();
    public List<WrapperClass> lstwrap{get;set;}
    public HLAllMemberContact(){
        getProjectRole();
    }
    public class WrapperClass{
        Public String Account{get;set;}
        public string AccountId {get;set;}
        Public String Product{get;set;}
        Public String Industry {get;set;}
        Public string city{get;set;}
        Public string State{get;set;}
        Public String Country{get;set;}
        Public string role{get;set;}
        Public String Name{get;set;}
        Public String Email{get;set;}
        Public String Title {get;set;}
        Public string CreatedDate{get;set;}
        Public string PHName{get;set;}
        Public string PHId {get;set;}
        Public String SaleStatus{get;set;}
        Public string MemberName{get;set;}
        Public string MemberRole{get;set;}
	}
    Public void getProjectRole(){
        set<id> setAccIds = new set<id>();
        List<String> lstAccRole = new List<String>();
        List<AccountTeamMember> lstATS = new List<AccountTeamMember>();
        set<string> setName = new set<string>();
        lstATM = new list<AccountTeamMember>();
        lstwrap =new List<WrapperClass>();
        Map<string,AccountTeamMember> mapAccount = new Map<string,AccountTeamMember>();
        set<Id> setIds= new Set<Id>();
        List<string> strids = new List<String>();
        Id proId;
        if(ProjectName != null && ProjectName != ''){
            String strProjectName = projectName.substringBetween('[', ']');
            strProjectName=strProjectName.remove(' ');
            strids = strProjectName.split(',');
            projectName=strProjectName;
            if(strProjectName !=''){
                for(String s :strids){
                    proId=s.substring(0,15);
                    setIds.add(proId);  
                }
            }
        }
        set<Id> setUserIds= new Set<Id>();
        List<string> strList = new List<String>();
        Id UserId;
        if(UserName != null && UserName != ''){
            String strUserName = UserName.substringBetween('[', ']');
            strUserName=strUserName.remove(' ');
            strList = strUserName.split(',');
            UserName=strUserName;
            if(strUserName !=''){
                for(String s :strList){
                    UserId=s.substring(0,15);
                    setUserIds.add(UserId);  
                }
            }
        }
        system.debug('setUserIds-->'+setUserIds);
        system.debug('AccountTeam-->'+AccountTeamName);
        if(AccountTeamName != null && AccountTeamName != '[]'){
        system.debug('Inside');
        String strTeamRole = AccountTeamName.substringBetween('[', ']');
            //strTeamRole = strTeamRole.re;
            system.debug('strTeamRole-->'+strTeamRole);
        lstAccRole= strTeamRole.split(', ');
        accountTeamName = string.join(lstAccRole,',');
         }
        system.debug('lstAccRole-->'+lstAccRole);
        string quaryATM ='Select AccountId,User.Name,TeamMemberRole From AccountTeamMember';
        if(!lstAccRole.isEmpty()){
            system.debug('Inside');
        quaryATM += ' Where TeamMemberRole IN:lstAccRole';
        }
        if(!setUserIds.isEmpty() && lstAccRole.isEmpty()){
            system.debug('Inside user');
        quaryATM += ' Where UserId IN:setUserIds';
        }
        if(!setUserIds.isEmpty() && !lstAccRole.isEmpty()){
            system.debug('Inside both');
        quaryATM += ' AND UserId IN:setUserIds';
        }
        system.debug('quaryATM-->'+quaryATM);
        lstATM=Database.query(quaryATM);
        system.debug('lstATM-->'+lstATM);
        lstProjectRole = new List<Project_Role__c>();
        
        for(AccountTeamMember objAccountTeamMember : lstATM){
            setAccIds.add(objAccountTeamMember.AccountId);  
            mapAccount.put(objAccountTeamMember.AccountId,objAccountTeamMember);
        }
        
        system.debug('mapAccouunt-->'+mapAccount.values());
        system.debug('setAccIds-->'+setAccIds);
        string quary = 'Select id,Asset__c,Asset__r.AccountId,Asset__r.Account.Name,Asset__r.Product2.Name,Asset__r.Account.Industry,Contact__r.Account.BillingCity,Contact__r.Account.BillingState,Contact__r.Account.BillingCountry,';
        quary +='Role__c,Contact__r.Name,Contact__r.Email,Contact__r.Title,CreatedDate,Asset__r.Name,Asset__r.SalesOrderStatus__c From Project_Role__c Where (Asset__r.Status =\'Purchased\' OR  Asset__r.Status =\'Active\')';      
        if(setIds.isEmpty()){
         quary += ' AND Asset__r.AccountId IN:setAccIds LIMIT:QueryLimit offset :OffsetSize';  
        }
        if(!setIds.isEmpty()){
            quary +=' AND Asset__r.AccountId IN:setAccIds AND Asset__r.Projects__c IN:setIds LIMIT:QueryLimit offset :OffsetSize';
        }
        lstProjectRole=Database.query(quary);
        system.debug('lstProjectRole-->'+lstProjectRole);
        for(Project_role__c objPR : lstProjectRole){
           AccountTeamMember objATM = mapAccount.get(objPR.Asset__r.AccountId);
           WrapperClass objWrapClass = new WrapperClass();
           objWrapClass.Account = objPR.Asset__r.Account.Name;
            objWrapClass.AccountId =objPR.Asset__r.AccountId;
           objWrapClass.PHId = objPR.Asset__c; 
           objWrapClass.Product = objPR.Asset__r.Product2.Name; 
           objWrapClass.Industry = objPR.Asset__r.Account.Industry; 
           objWrapClass.city =  objPR.Contact__r.Account.BillingCity; 
           objWrapClass.State = objPR.Contact__r.Account.BillingState; 
           objWrapClass.Country = objPR.Contact__r.Account.BillingCountry;
           objWrapClass.Role = objPR.Role__c;
           objWrapClass.Name = objPR.Contact__r.Name;
           objWrapClass.Email = objPR.Contact__r.Email;
           objWrapClass.Title = objPR.Contact__r.Title;
           objWrapClass.CreatedDate = objPR.CreatedDate.format();
           objWrapClass.PHName = objPR.Asset__r.Name;
           objWrapClass.SaleStatus = objPR.Asset__r.SalesOrderStatus__c;
            if(objATM != Null){
           objWrapClass.MemberName = objATM.User.Name;
           objWrapClass.MemberRole = objATM.TeamMemberRole;
            }
           lstwrap.add(objWrapClass);
        }
    }
    Public List<Selectoption> getselectedAccountTeam(){
            List<Selectoption> lstAccountTeam = new List<selectoption>();
        	for(Team_Role__c objAT : [Select id,Name from Team_Role__c]){
            lstAccountTeam.add(new selectoption(objAT.Name,objAT.Name));
            }
            return lstAccountTeam; 
        }
    Public List<Selectoption> getselectedProject(){
        List<Selectoption> lstProject = new List<selectoption>();
        for(Project__c objProject :[SELECT id,name FROM Project__c]){
            lstProject.add(new selectoption(objProject.id,objProject.name));
        }
        return lstProject; 
    }
    Public List<Selectoption> getselectedUser(){
        List<Selectoption> lstUser = new List<selectoption>();
        for(User objUser :[SELECT id,name FROM user]){
            lstUser.add(new selectoption(objUser.id,objUser.name));
        }
        return lstUser; 
    }
    public PageReference Next() {
        
        OffsetSize += QueryLimit;
        getProjectRole();
        return null;
    }
    
    public PageReference Previous() {
        
        OffsetSize -= QueryLimit;
        getProjectRole();
        return null;
    }
    Public PageReference ExportToExcel(){
        selectedFieldsList = New List<string>();
        
        selectedFieldsList.add('Account'); 
        selectedFieldsList.add('Product'); 
        selectedFieldsList.add('Industry');
        selectedFieldsList.add('City'); 
        selectedFieldsList.add('State');
        selectedFieldsList.add('Country');
        selectedFieldsList.add('Role');
        selectedFieldsList.add('Name'); 
        selectedFieldsList.add('Email'); 
        selectedFieldsList.add('Title');
        selectedFieldsList.add('CreatedDate'); 
        selectedFieldsList.add('PHName');
        selectedFieldsList.add('SaleStatus');
        selectedFieldsList.add('MemberName');
        selectedFieldsList.add('MemberRole');
        PageReference pgRef = New Pagereference('/apex'+'/ExportHLMemberReport');
        pgRef.setRedirect(false); 
        return pgRef;
    }
}