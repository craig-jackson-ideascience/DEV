public class MyProjectsReportController {
    private string ownerId;
    public Map<id,OpportunityLineItem> opportunityLineItemsMap{get;set;}
    public Map<Id, Project_Role__c> oliIdVsProjectRoles;
    public Map<id,list<Asset>> projectName;
    Map<id,boolean> projectNameMap = new Map<id,boolean>();
    public list<Asset> assets;
    
    
    public MyProjectsReportController(){
        this('00541000007libo');
    }
    
    public MyProjectsReportController(string ownerId){
        this.OwnerId = ownerId;
       /*list<asset> assets = getAssetDetails();
        if(assets != null && !assets.isEmpty())
        sendEmailWithAttachment(csvGenerate(assets));
        system.debug('----'+this.OwnerId);*/
    }
    
    public list<asset> getAssetDetails(){
       set<id> opportunityID = new set<id>();
       Map<id, OpportunityLineItem> opportunityLineItemMap= new Map<id, OpportunityLineItem>();
         opportunityLineItemsMap = new Map<id,OpportunityLineItem>();
        projectName = new Map<id,list<Asset>>();
        oliIdVsProjectRoles = new Map<Id, Project_Role__c>();
        
       assets = [Select ID,Name,Opportunity__r.OwnerId,InstallDate,UsageEndDate,Price,Opportunity__c,Bill_To_Account__r.Name,Product2.ID,Product2.Name,Projects__r.Name,
                     Projects__c,OpportunityLineItem__c, Account.Name,Account.P_O_Required__c, Account.BillingStreet, Account.BillingCity, Account.BillingState,
                     Account.BillingPostalCode, Account.BillingCountry,Contact.Name,Contact.Email,Bill_To_Account__c,(select id,StageName,Name from Opportunities__r)
                      from Asset Where UsageEndDate = NEXT_N_DAYS:60 AND Product2.Family='Membership' 
                      AND Auto_Renew__c = true and Opportunity__r.OwnerId=: ownerId order by Projects__r.Name];
        
        System.debug('asset list' +assets[0].Opportunity__r.OwnerId);
        system.debug('asset list owner id: ' + ownerId);
        
        
        for(Asset assest : assets){
            projectNameMap.put(assest.Projects__c,false);
            if(assest.Opportunities__r.size() > 0){
                for(Opportunity oppor : assest.Opportunities__r){
                	opportunityID.add(oppor.id); 
                }
            }
        }
        if(opportunityID.size() > 0){
            
            list<opportunityLineItem> oliList = [select id,Start_Date__c,End_Date__c,OpportunityId,
                                                 TotalPrice,Description__c from opportunityLineItem
                                                 where OpportunityId in:opportunityID];
            if(oliList.size() > 0){
               Set<Id> oliIds = new Set<Id>();
                for(opportunityLineItem oli: oliList){
                    if(oli.OpportunityId != null && !opportunityLineItemsMap.containsKey(oli.OpportunityId))
                        opportunityLineItemsMap.put(oli.OpportunityId,oli);

                    oliIds.add(oli.Id);
                }
                //Added by Priyesh @Cloudoroute to fetch the billing contact from Membership roles instead of oli
                for(Project_Role__c billingRole : [
                        SELECT Id, Contact__r.Name, Contact__r.Email, Opportunity_Line_Item__c
                        FROM Project_Role__c
                        WHERE Opportunity_Line_Item__c IN:oliIds AND Role__c = 'Billing Contact' AND Status__c = 'Active' AND PrimaryContact__c = TRUE
                ]) {
                        if(!oliIdVsProjectRoles.containsKey(billingRole.Opportunity_Line_Item__c)){
                            oliIdVsProjectRoles.put(billingRole.Opportunity_Line_Item__c, billingRole);
                        }
                }

            } 
        }
        if(assets != null && assets.size() > 0){
            return assets; 
        }
        else{
            return null;
        }

    }
    public blob csvGenerate(list<Asset> assets){
        String header = 'Account Name, Account Billing Address , Product Name, Purchase History Name, Install Date, Usage End Date, Price, Opportunity Name, Start Date,  End Date,  Description, Total Price,Contact Full Name,Contact Email \n';
        String finalstr = header;
         String s = line(new String[] {
               format('Project Name'),
                format('Account Name'),
                format('Account PO Required'),   
                format('Account Billing Address'),
                format('Billing Account Override:Account Name'),
                format('Product Name'),    
                format('Purchase History Name'),
                format('Install Date'),
                format('Usage End Date'),
                format('Price'),
                format('Opportunity Name'),
                format('Start Date'),
                format('End Date'),  
                format('Description'),
                format('Total Price'), 
                format('Contact Full Name'),
                format('Contact Email'),
                format('Stage')   
                });
        if(assets.size() > 0){
           for (Asset assest : assets) {
               Map<id,boolean> projectNameOppporMap = new Map<id,boolean>();
           // system.debug('---'+opportunityLineItemsMap.get(assest.OpportunityLineItem__c).TotalPrice); projectNameMap
            
            if(projectNameMap.get(assest.Projects__c) == true){
                if(assest.Opportunities__r.size() > 0){
                    system.debug('---1IF--');
                    for(Opportunity oppor : assest.Opportunities__r){
                        
                        s += csvFormat(assest,null,oppor);	
                    }  
                }
                else{
                      system.debug('---2ELSE--');
                    s += csvFormat(assest,null);	
                }
            }
            else{
                System.debug('assest.Opportunities__r:: ' + assest.Opportunities__r);
                if(assest.Opportunities__r.size() > 0){
                    
                    for(Opportunity oppor : assest.Opportunities__r){
                        if(projectNameOppporMap.containsKey(assest.Projects__c) && projectNameOppporMap.get(assest.Projects__c) == true){
                             system.debug('---1IF--');
                           s += csvFormat(assest,null,oppor);
                        }
                        else{
                             system.debug('---2ELSE--');
                            s += csvFormat(assest,assest.Projects__r.Name,oppor); 
                            projectNameOppporMap.put(assest.Projects__c,true); 
                        }
                    }  
                }
                else{
                     system.debug('---3ELSE--');
                     s += csvFormat(assest,assest.Projects__r.Name);
                     	
                }
                projectNameMap.put(assest.Projects__c,true);
                
            }
            
           /* s += line(new String[] {
                    format(assest.Account.Name),
                    format(temp),
                    format(assest.Product2.Name),
                    format(assest.Name),
                    format(assest.InstallDate),
                    format(assest.UsageEndDate),
                   format(assest.Price),  
                    format(assest.Opportunity__r.Name),
                    format(opportunityLineItemsMap.get(assest.OpportunityLineItem__c).Start_Date__c),
                    format(opportunityLineItemsMap.get(assest.OpportunityLineItem__c).End_Date__c),
                    format(opportunityLineItemsMap.get(assest.OpportunityLineItem__c).Description__c), 
                    
                    format(opportunityLineItemsMap.get(assest.OpportunityLineItem__c).TotalPrice),
                    format(assest.Contact.Name),
                    format(assest.Contact.Email)    
                    }); */
            system.debug('---'+s);
        } 
        }
        
       
        system.debug('---'+s);
        Blob csvBlob = Blob.valueOf(s);
        system.debug('----'+csvBlob);
        return csvBlob;
    }
     private String line(String[] cells) {
        return String.join(cells, ',') + '\n';
    }
    private String format(Date d)    {
        return d != null ? d.format().escapeCsv() : '""';
    }
    private String format(String s) {
        String temp = s != null ?  s.escapeCsv() : '""';
            system.debug('---'+temp);
          return temp;
        
    }
    private String format(Decimal d, Integer scale) {
        return d != null ? String.valueOf(d.setScale(scale)) : '';
    }
    private String format(Decimal d) {
        return format(d, 2);
    }
     private String format(boolean d) {
         String temp;
         if(d != null && d == true){
             temp = 'TRUE';
             
         }
         else{
             temp = 'FALSE';
         }
         return temp;
    }
  /*  private void sendEmailWithAttachment(Blob csvContent){
        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();//Create csv attachment
        system.debug('add csv file attachment');     
        blob csvBlob = csvContent; //updatedEntities
        string csvname= 'UpdatedEntityrecords.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);  
        csvAttc.setContentType('text/csv');  
        //Create Email      
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'yatish.salian@cloudroute.in'}; 
            String[] ccAddresses = new list<string> {'snehal@cloudroute.in'}; 
                
        email.setSenderDisplayName('Entity records Equation status Batch job');
        email.setSubject('Entity records Equation status updated');       
        
        email.setToAddresses( toAddresses );
        email.setCcAddresses( ccAddresses );
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});    
        email.setPlainTextBody('THis is Testing');      
        
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }  */
   /* private string AddEscapeSequenceInCsvField(string ValueToEscape)       
    {
        if(ValueToEscape != null){
           if (ValueToEscape.contains(','))
            {
                system.debug('-----'+'\"' + ValueToEscape + '\"');
                return '\"' + ValueToEscape + '\"';
            } else{
                return ValueToEscape;
            }   
        }
        return null;
    }*/
    private String csvFormat(Asset assest,String ProjectName){
        String temp = getAddress(assest.Account.BillingStreet,assest.Account.BillingCity,assest.Account.BillingState,assest.Account.BillingPostalCode,assest.Account.BillingCountry);
        system.debug('=temp='+temp);   
        String billFromAccount = assest.Bill_To_Account__c != null ?assest.Bill_To_Account__r.Name:'';
        String lineFormat =  line(new String[] {
                           	   	format(ProjectName),
                               	format(assest.Account.Name),
                                format(assest.Account.P_O_Required__c),
                                format(temp),
                                format(billFromAccount),    
                                format(assest.Product2.Name),
                                format(assest.Name),
                                format(assest.InstallDate),
                                format(assest.UsageEndDate),
                                format(assest.Price),  
                                format(assest.Opportunities__r.size() > 0 ? assest.Opportunities__r[0].Name : ''),
                                format(assest.Opportunities__r.size() > 0 ? (opportunityLineItemsMap.containsKey(assest.Opportunities__r[0].id) ? opportunityLineItemsMap.get(assest.Opportunities__r[0].id).Start_Date__c : NULL) : NULL),
                                format(assest.Opportunities__r.size() > 0 ? (opportunityLineItemsMap.containsKey(assest.Opportunities__r[0].id)?opportunityLineItemsMap.get(assest.Opportunities__r[0].id).End_Date__c : NULL): NULL),
                                format(assest.Opportunities__r.size() > 0 ? (opportunityLineItemsMap.containsKey(assest.Opportunities__r[0].id)?opportunityLineItemsMap.get(assest.Opportunities__r[0].id).Description__c : NULL): NULL),
                                format(assest.Opportunities__r.size() > 0 ? (opportunityLineItemsMap.containsKey(assest.Opportunities__r[0].id)?opportunityLineItemsMap.get(assest.Opportunities__r[0].id).TotalPrice : NULL): NULL),
                                format(assest.Opportunities__r.size() > 0 ? (opportunityLineItemsMap.containsKey(assest.Opportunities__r[0].id) && oliIdVsProjectRoles.containsKey(opportunityLineItemsMap.get(assest.Opportunities__r[0].id).Id) ? oliIdVsProjectRoles.get(opportunityLineItemsMap.get(assest.Opportunities__r[0].id).Id).Contact__r.Name : NULL): NULL), //Added by Priyesh @Cloudoroute to fetch the billing contact from Membership roles instead of oli
                                format(assest.Opportunities__r.size() > 0 ? (opportunityLineItemsMap.containsKey(assest.Opportunities__r[0].id) && oliIdVsProjectRoles.containsKey(opportunityLineItemsMap.get(assest.Opportunities__r[0].id).Id) ? oliIdVsProjectRoles.get(opportunityLineItemsMap.get(assest.Opportunities__r[0].id).Id).Contact__r.Email : NULL): NULL), //Added by Priyesh @Cloudoroute to fetch the billing contact from Membership roles instead of oli
                                format(assest.Opportunities__r.size() > 0 ? assest.Opportunities__r[0].StageName : '')
                                });
        system.debug('---lineFormat---'+lineFormat);
        return lineFormat ;
    }    
    
     private String csvFormat(Asset assest,String ProjectName,Opportunity oppor){
         String temp = getAddress(assest.Account.BillingStreet,assest.Account.BillingCity,assest.Account.BillingState,assest.Account.BillingPostalCode,assest.Account.BillingCountry);
         system.debug('=temp='+temp);   
        String billFromAccount = assest.Bill_To_Account__c != null ?assest.Bill_To_Account__r.Name:'';
        String lineFormat =  line(new String[] {
                           	   	format(ProjectName),
                               	format(assest.Account.Name),
                                format(assest.Account.P_O_Required__c),
                                format(temp),
                                format(billFromAccount),    
                                format(assest.Product2.Name),
                                format(assest.Name),
                                format(assest.InstallDate),
                                format(assest.UsageEndDate),
                                format(assest.Price),  
                                format(oppor.Name),
                                format(opportunityLineItemsMap.containsKey(oppor.id) ? opportunityLineItemsMap.get(oppor.id).Start_Date__c : NULL),
                                format(opportunityLineItemsMap.containsKey(oppor.id)?opportunityLineItemsMap.get(oppor.id).End_Date__c : NULL),
                                format(opportunityLineItemsMap.containsKey(oppor.id)?opportunityLineItemsMap.get(oppor.id).Description__c : NULL),
                                format(opportunityLineItemsMap.containsKey(oppor.id)?opportunityLineItemsMap.get(oppor.id).TotalPrice : NULL),
                                format(opportunityLineItemsMap.containsKey(oppor.id) && oliIdVsProjectRoles.containsKey(opportunityLineItemsMap.get(oppor.id).Id) ? oliIdVsProjectRoles.get(opportunityLineItemsMap.get(oppor.id).Id).Contact__r.Name : NULL),//Added by Priyesh @Cloudoroute to fetch the billing contact from Membership roles instead of oli
                                format(opportunityLineItemsMap.containsKey(oppor.id) && oliIdVsProjectRoles.containsKey(opportunityLineItemsMap.get(oppor.id).Id) ? oliIdVsProjectRoles.get(opportunityLineItemsMap.get(oppor.id).Id).Contact__r.Email : NULL),//Added by Priyesh @Cloudoroute to fetch the billing contact from Membership roles instead of oli
                                format(oppor.StageName)
                                });
        return lineFormat ;
     }
    
    private String getAddress(String street, String city,String state,String postalCode, String country){
        String address = '';
        if(street != null && street != ''){
            address +=  street+' ,';
            system.debug('---street---'+street);
        }
        if(city != null && city != ''){
			address +=  city+' ,'; 
            system.debug('---city---'+city);
        }
        if(state != null && state != ''){
			address +=  state+' ,';  
            system.debug('---state---'+state);
        }
        if(postalCode != null && postalCode != ''){
			address +=  postalCode+' ,';  
            system.debug('---postalCode---'+postalCode);
        }
        if(country != null && country != ''){
			address +=  country+' ,';   
             system.debug('---country---'+country);
        }
        system.debug('---address---'+address);
        address = address.removeEnd(',');
        return address;
        
    }
}