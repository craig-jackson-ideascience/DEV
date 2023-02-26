public class CancelMembershipReport {
    static List<Asset> lstCancelledMembership ;
    static List<OpportunityLineItem> lstOLI ;
    Public List<String> selectedFieldsList {get;set;}
    static map<Id,OppAssetWrapper> mapOppAssetWrapper = new map<Id,OppAssetWrapper>();
    public Date startDate {get;set;}
    public Date EndDate {get;set;}
    public string projectName {get;set;}
    static set<Id> ids = new set<Id>();
    
    public List<OppAssetWrapper> lstwrap{get;set;}
    public CancelMembershipReport(){
        
        projectName = '';
        getAsset();
        
    }
    public class OppAssetWrapper{
        Public String Account{get;set;}
        Public id AccountId;
        Public String Country{get;set;}
        Public String Product {get;set;}
        Public string Canceldate{get;set;}
        Public string Joindate{get;set;}
        Public String CancelReason{get;set;}
        Public Decimal Amount{get;set;}
        Public string Voting{get;set;}
        Public string Marketing{get;set;}
        Public string Technical{get;set;}
        Public String ProjectName{get;set;}
        Public String VCorporateEmail{get;set;}
        Public String TCorporateEmail{get;set;}
        Public String MCorporateEmail{get;set;}
    }
    
    public void getAsset(){
          set<Id> setIds= new Set<Id>();
          List<string> strids = new List<String>();
         Id proId;
        map<id,OpportunityLineItem> mapOpportunityLineItem = new map<id,OpportunityLineItem>();
        if(projectName != ''){
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
        DateTime SD= startDate;
        DateTime ED = EndDate;
        string proName = '%'+projectName + '%';
        String strStartDate='';
        String strEndDate='';
        if(SD != null){
            strStartDate = SD.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        }
            if(ED != null){
                strEndDate = ED.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            }
        lstCancelledMembership = new List<Asset>();
        lstOLI = new List<OpportunityLineItem>();
        lstwrap =new List<OppAssetWrapper>();
        
        string queryOpp ='Select id,Opportunity.AccountId,Opportunity.Name,Opportunity.Account.name,Projects__r.Name,TotalPrice,Opportunity.CloseDate,Opportunity.Loss_Reason__c,Opportunity.Account.Billingcountry,Opportunity.Amount,Opportunity.StageName,AgreementDate__c,Product2.Name,UnitPrice,Related_To__c from OpportunityLineItem '+
        'where Opportunity.type LIKE \'Renewal%\'  AND Opportunity.StageName=\'Closed Lost\' AND Opportunity.RecordType.Name=\'Membership\'AND Opportunity.Loss_Reason__c !=\'Reissued\'';
        system.debug('setIds-->'+setIds);
        system.debug('strStartDate-->'+strStartDate);
        system.debug('strEndDate-->'+strEndDate	);
        if(!setIds.isEmpty() && strStartDate != '' && strEndDate != ''){
            system.debug('Inside All');
            queryOpp += ' AND (Projects__c IN:setIds AND Opportunity.CreatedDate >'+strStartDate +'AND Opportunity.CreatedDate <'+ strEndDate+')';
        }
        if(strStartDate != '' && setIds.isEmpty()){
            queryOpp +=' AND Opportunity.CreatedDate >'+strStartDate;
        }
        if(strEndDate != '' && setIds.isEmpty()){
            queryOpp +=' AND Opportunity.CreatedDate <'+strEndDate;
        }
        if(!setIds.isEmpty() && strStartDate == '' && strEndDate == ''){
            queryOpp +=' AND Projects__c IN:setIds order by Opportunity.CreatedDate DESC';
        }
        
        lstOLI = Database.query(queryOpp);
         map<Id,Asset> mapAsset = new Map<Id,Asset>();
         set<Id> AccountIds = new set<Id>();
        for(OpportunityLineItem objOpportunity :lstOLI){
            AccountIds.add(objOpportunity.Opportunity.AccountId);
            
            if(!mapOpportunityLineItem.containsKey(objOpportunity.Opportunity.AccountId)){
                
               mapOpportunityLineItem.put(objOpportunity.Opportunity.AccountId,objOpportunity); 
            }
        }
        system.debug('');
        String query ='Select id,AccountId,Account.Name,PurchaseDate,Annual_Full_Price__c,Product2.Name,Opportunity__r.Name,Account.BillingCountry,Cancellation_Date__c,Cancellation_Reason__c,Opportunity__r.Amount,Opportunity__r.StageName,';
        query +='Status,Projects__r.name,(Select Contact__r.Name,Role__c,Corporate_Email__c from Project_Roles__r where (Role__c =\'Marketing Contact\' OR Role__c =\'Representative/Voting Contact\' OR Role__c =\'Technical Contact\')) from Asset Where ((Status =\'Invoice Cancelled\') OR (Opportunity__r.StageName =\'Closed Won\' AND Status =\'Invoice Cancelled\')'; 
        query +=  ' OR (Opportunity__r.StageName =\'Closed Won\' AND Status =\'Active\' AND Auto_Renew__c = false) OR ((Status =\'Active\' OR Status =\'Expired\') AND Auto_Renew__c = false)) AND ProductFamily =\'Membership\' AND Opportunity__r.Loss_Reason__c !=\'Reissued\' AND Cancellation_Reason__c !=\'Reissued\'';
        
        if(!setIds.isEmpty() && strStartDate != '' && strEndDate != ''){
            system.debug('Inside All');
            query += ' AND (Projects__c IN:setIds AND Opportunity__r.CreatedDate >'+strStartDate +'AND Opportunity__r.CreatedDate <'+ strEndDate+')';
        }
        if(!setIds.isEmpty() && strStartDate == '' && strEndDate == ''){
            query +=' AND (Projects__c IN:setIds ) order by CreatedDate ASC ';
        }
        if(strStartDate != '' && setIds.isEmpty()){
            query +=' AND (Opportunity__r.CreatedDate >'+strStartDate+')';
        }
        if(strEndDate != '' && setIds.isEmpty()){
            query +=' AND (Opportunity__r.CreatedDate <'+strEndDate+')';
        }
        
        lstCancelledMembership = Database.query(Query);
        for(Asset objAsset :lstCancelledMembership){
            if(!mapAsset.containsKey(objAsset.AccountId)){
                if(mapOpportunityLineItem.get(objAsset.AccountId)!=null){
                    if(mapOpportunityLineItem.get(objAsset.AccountId).Opportunity.CloseDate<objAsset.Cancellation_Date__c){
                        mapOpportunityLineItem.remove(objAsset.AccountId);
                        mapAsset.put(objAsset.AccountId,objAsset);
                    }

                }else{
                    mapAsset.put(objAsset.AccountId,objAsset);
                }
                
            }
        }
        set<Id> Opportunityids = new set<Id>();
        for(OpportunityLineItem objOpportunity :mapOpportunityLineItem.values()){
            Opportunityids.add(objOpportunity.OpportunityId);
            OppAssetWrapper objWrap = new OppAssetWrapper();
            objWrap.Product =objOpportunity.Product2.Name;
            objWrap.ProjectName =objOpportunity.Projects__r.Name;
            objWrap.AccountId = objOpportunity.Opportunity.AccountID;
            if(objOpportunity.AgreementDate__c != null){
                objWrap.Joindate =objOpportunity.AgreementDate__c.format();
            }
             objWrap.Amount =objOpportunity.UnitPrice;
            
            objWrap.Account =objOpportunity.Opportunity.Account.name;
            objWrap.Country =objOpportunity.Opportunity.Account.Billingcountry;
            objWrap.CancelReason = objOpportunity.Opportunity.Loss_Reason__c;
            if(objOpportunity.Opportunity.CloseDate != null){
                objWrap.Canceldate = objOpportunity.Opportunity.CloseDate.format();
            }
            mapOppAssetWrapper.put(objOpportunity.Opportunity.AccountId,objWrap);
        }
        set<Id> usedIds = new set<Id>();
        for(Opportunity objOpportunity :[Select id,AccountId,(Select Contact__r.Name,Role__c,Corporate_Email__c from Project_Roles__r where (Role__c ='Marketing Contact' OR Role__c ='Representative/Voting Contact' OR Role__c ='Technical Contact')AND Status__c ='Active') from Opportunity where Id IN:Opportunityids]){
            OppAssetWrapper objWrap = mapOppAssetWrapper.get(objOpportunity.AccountID);
            for(Project_Role__c objPR : objOpportunity.Project_Roles__r){
                if(mapOppAssetWrapper.containsKey(objOpportunity.AccountId)){
                    if(objPR.Role__c =='Representative/Voting Contact'){
                        usedIds.add(objOpportunity.id);
                        objWrap.Voting = objPR.Contact__r.name;
                        objWrap.VCorporateEmail = objPR.Corporate_Email__c;
                    }else
                        if(objPR.Role__c =='Marketing Contact'){
                            objWrap.Marketing =objPR.Contact__r.name;
                            objWrap.MCorporateEmail = objPR.Corporate_Email__c;
                        }else if(objPR.Role__c =='Technical Contact'){
                            objWrap.Technical =objPR.Contact__r.name;
                            objWrap.TCorporateEmail = objPR.Corporate_Email__c;
                        }
                }
            }
            mapOppAssetWrapper.put(objOpportunity.AccountId,objWrap);
        }
         //code for contact role 
         for(Opportunity objOpportunity :[Select id,AccountId,(Select Contact.Name,Role from OpportunityContactRoles where IsPrimary=true) from Opportunity where Id IN:Opportunityids]){
            OppAssetWrapper objWrap = mapOppAssetWrapper.get(objOpportunity.AccountID);
            for(OpportunityContactRole objOCR : objOpportunity.OpportunityContactRoles){
                if(mapOppAssetWrapper.containsKey(objOpportunity.AccountId) && !usedIds.contains(objOpportunity.id)){
                    objWrap.Voting = objOCR.Contact.name;
                }
            }
            lstwrap.add(objWrap);
        }
        
        for(Asset objAsset :mapAsset.values()){
            OppAssetWrapper objWrap = new OppAssetWrapper(); 
            objWrap.Account =objAsset.Account.name;
            objWrap.ProjectName =objAsset.Projects__r.name;
            objWrap.Product =objAsset.Product2.Name;
            objWrap.Country =objAsset.Account.Billingcountry;
            if(objAsset.Cancellation_Date__c !=null){
                objWrap.Canceldate =objAsset.Cancellation_Date__c.format();
            }
            objWrap.CancelReason =objAsset.Cancellation_Reason__c;
            objWrap.Amount =objAsset.Annual_Full_Price__c;
            if(objAsset.PurchaseDate !=null){
                objWrap.Joindate = objAsset.PurchaseDate.format();
            }
            for(Project_Role__c objPR : objAsset.Project_Roles__r){
              if(objPR.Role__c =='Representative/Voting Contact'){
                objWrap.Voting = objPR.Contact__r.name;
                  objWrap.VCorporateEmail = objPR.Corporate_Email__c;
              }else
                if(objPR.Role__c =='Marketing Contact'){
              objWrap.Marketing =objPR.Contact__r.name;
                    objWrap.MCorporateEmail = objPR.Corporate_Email__c;
                }else if(objPR.Role__c =='Technical Contact'){
              objWrap.Technical =objPR.Contact__r.name; 
                    objWrap.TCorporateEmail = objPR.Corporate_Email__c;
                }
            }
            lstwrap.add(objWrap);
        }
        
    }
    Public List<Selectoption> getselectedProject(){
        List<Selectoption> lstProject = new List<selectoption>();
        for(Project__c objProject :[SELECT id,name FROM Project__c]){
            lstProject.add(new selectoption(objProject.id,objProject.name));
        }
        return lstProject; 
    } 
    Public PageReference ExportToExcel(){
        selectedFieldsList = New List<string>();
        
        selectedFieldsList.add('Account'); 
        selectedFieldsList.add('Canceldate'); 
        selectedFieldsList.add('CancelReason');
        selectedFieldsList.add('Joindate'); 
        selectedFieldsList.add('Product');
        selectedFieldsList.add('Country');
        selectedFieldsList.add('Amount');
        selectedFieldsList.add('Voting');
        selectedFieldsList.add('Marketing');
        selectedFieldsList.add('Technical');
        
        PageReference pgRef = New Pagereference('/apex'+'/ExportCancellMembershipReport');
        pgRef.setRedirect(false); 
        return pgRef;
    }
    
}