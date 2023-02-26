public class CampaignMemberRecordLogTriggerHandler implements ITriggerHandler{
    static List<CampaignMember> cm = new List<CampaignMember>();
    static  Map<String,Alternate_Email__c> emailVsAlternateEmail = new Map<String,Alternate_Email__c>();
    static List<String>cmemails = new List<String>();
    static Set<String> emailset =  new Set<String>();
    static Map<String,Id> campNameVsId = new  Map<String,Id>();
    static Map<Id,Campaign> campaignMap = new  Map<Id,Campaign>();
    static Set<ID> ContactandLeadID = new Set<Id>();
    
    public static void BeforeInsert(List<Sobject> triggerNew) {
        
    }
    
    public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap) {
        
    }
    public static void BeforeDelete(Map<Id, Sobject> oldMap) {
        //call before delete actions
    }
    
    public static void AfterInsert(Map<Id, SObject> newMap) {
        //method to parse records
        parseRecords((List<Campaign_Member_Record_Log__c>) newMap.values());
    }
    public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap) {
        
        
    }
    
    public static void AfterDelete(Map<Id, Sobject> oldMap) {
    }
    
    
    public static void AfterUnDelete(Map<Id, Sobject> newMap) {
        //call after undelete actions
    }
    
    public Boolean IsDisabled() {
        return false;
    }
    
    //method to parse records
    private static void parseRecords(List<Campaign_Member_Record_Log__c> records){
        
        //initialize variable
        Map<Id,Campaign_Member_Record_Log__c> recordsToUpdate = new Map<Id,Campaign_Member_Record_Log__c>();
        List<Campaign_Member_Record_Log__c> recordsToDelete = new List<Campaign_Member_Record_Log__c>();
        Set<String> campaignset = new Set<String>();
        Map<String,String> emailVscamp = new Map<String,String>();
        Map<String,String> emailVsnotes = new Map<String,String>(); 
        Map<String,Campaign_Member_Record_Log__c> emailVsValues = new Map<String,Campaign_Member_Record_Log__c>(); 
        Map<String,set<String>> campVsemail = new Map<String,set<String>>();
        List<Lead> InserLeadList = new list<Lead> ();
        Map<String,Lead> emailVsLead = new Map<String,Lead>();
        Map<string, set<ID>> cmMap = new Map<string, set<ID>>();
        Map<String,CampaignMember> emailVsCampMember = new Map<String,CampaignMember>();
        List<CampaignMember> campmember = new List<CampaignMember>();
        Map<String,String> emailVSErrors = new Map<String,String>(); 
        
        //iterate through records
        for(Campaign_Member_Record_Log__c record: records){
            //if campaign name is noy null
            if(record.Campaign_Name__c != null){
                campaignset.add(record.Campaign_Name__c);
            }
            
            //if email is not null
            if(record.Email_Address__c != null){
                emailSet.add(record.Email_Address__c.tolowercase());
            }
        }
        System.debug('campaignset '+campaignset);
        System.debug('emailSet '+emailSet);
        
        //Find Alternate Email
        if(!emailSet.isEmpty()){
            getAlternateEmail(emailSet); 
        }
        
        //Get Campaign ID 
        if(campaignset.size() > 0){
            getCampaign(campaignset);
        }
          
        //iterate through records
                for(Campaign_Member_Record_Log__c record: records){
                    //map email Vs record
                    emailVsValues.put(record.Email_Address__c+' '+record.Campaign_Name__c,record);
                    
                    //proceed if particular email is not in salesforce
                  if(record.Email_Address__c != null && emailset.contains(record.Email_Address__c)){                       
                      
                       Set<String> campaignEmails = new Set<String>();
            //map of campaignname Vs Email
            if(campVsemail.containskey(record.Campaign_Name__c)){
                campaignEmails=campVsemail.get(record.Campaign_Name__c);
                
            }
            campaignEmails.add(record.Email_Address__c);
            campVsemail.put(record.Campaign_Name__c,campaignEmails);
            

                      //get lead instance for insertion
                       Lead ld = getLeadInstance(record);
                       if(String.isNotEmpty(ld.email)){
                           emailVsLead.put(ld.email,ld);
                       }
                   }
                }
         System.debug('campVsemail '+campVsemail);
        
        //Get all existing campaign members of campaigns
        if(campNameVsId.values().size() > 0){
            //retrieve campaign member
            campmember  = [Select ID,ContactId, Contact.Email,Email,Comments__c,Membership__c,Newsletter__c,
                           Lead.Email,LeadId,Campaign.Name,CampaignId FROM CampaignMember 
                           WHERE CampaignId IN: campNameVsId.values() 
                           AND (ContactId IN: ContactandLeadID OR leadID IN :ContactandLeadID)]; 
            
            if(!campmember.isEmpty()){
                for(CampaignMember cmp : campmember)
                {
                    emailVsCampMember.put(cmp.Email,cmp);
                    Id LeadContactId=cmp.ContactId != null?cmp.ContactId:cmp.LeadId;
                    Set<Id> memberIdSet = new Set<Id>();
                    if(cmMap.containskey(cmp.Campaign.Name)){
                        memberIdSet = cmMap.get(cmp.Campaign.Name);
                    }
                    memberIdSet.add(LeadContactId);
                    cmMap.put(cmp.Campaign.Name,memberIdSet);
                }
            }
            
        }
        System.debug('campmember '+campmember.size());
        
        //For Campaign Alternate Email
            if(!emailVsAlternateEmail.keySet().isEmpty()){
            for(Campaign_Member_Record_Log__c record: records){
                if(record.Email_Address__c != null){
                    addCampaignMemperforAlternateEmail(record,emailVsCampMember,cmMap);
                }
                }
            }
        
            
            //Insert Lead 
            Database.SaveResult[] srList = Database.insert(emailVsLead.values(), false);
            integer i=0;
            for(Database.SaveResult sr : srList){
                if(!sr.isSuccess() && sr.getErrors() != null){
                    for( Database.Error err :  sr.getErrors()){
                        Lead lead = emailVsLead.values()[i];
                        emailVSErrors.put(lead.email,string.valueOf(err.getMessage()));
                        }
                    }
                i++;
                }
                
        //loop for the newly inserted lead to be added as campaign member
        for( String camp :campVsemail.keyset()){
                for(String leademail : campVsemail.get(camp)){
                    CampaignMember newCamp = new CampaignMember();
                    newCamp.CampaignId = campNameVsId.get(camp);
                    newCamp.LeadId = emailVsLead.get(leademail).id;
                    String key = leademail.tolowercase()+' '+camp;
                    if(emailVsValues.containskey(key)){
                        Campaign_Member_Record_Log__c recordValues=emailVsValues.get(key);
                        newCamp.Comments__c = recordValues.Notes__c;
                        newCamp.Membership__c =recordValues.MemberShip__c;
                        newCamp.Newsletter__c =recordValues.Newsletter__c;
                    }
                       if(newCamp.CampaignId != null){
                        cm.add(newCamp);
                        cmemails.add(leademail);
                       }
                    system.debug('newCamp '+newCamp);
                }
                
            }
            
            //Add Campaignmember 
            System.debug('cm '+cm.size());
            if(!cm.isEmpty()){
				List<Database.UpsertResult> srcamp = Database.upsert(cm, CampaignMember.Fields.Id, false);
                Integer j = 0;
                for(Database.UpsertResult sr : srcamp){
                    if(!sr.isSuccess() && sr.getErrors() != null){
                        for( Database.Error err :  sr.getErrors()){
                            String key = cmemails[j]+' '+campaignMap.get(cm[j].CampaignId).Name;
                               if(emailVsValues.containsKey(key)){
                                   
                                   Campaign_Member_Record_Log__c record =  new Campaign_Member_Record_Log__c(Id=emailVsValues.get(key).Id);
                                       record.Error_Message__c = 'Error while upserting Campaign Member of email - '+
                                cmemails[j]+' '+
                                +string.valueOf(err.getMessage());
                            recordsToUpdate.put(emailVsValues.get(key).Id,record);
                                   
                               }
                        }
                    }
                    j++;
                }
            }
        
        //loop to record to delete or update
         for(Campaign_Member_Record_Log__c record: records){
             if(emailVSErrors.containsKey(record.Email_Address__c)){
                               recordsToUpdate.put(record.Id,
                                                new Campaign_Member_Record_Log__c(
                                Id=record.Id, Status__c='Error',
                            Error_Message__c  =emailVSErrors.get(record.Email_Address__c)));
                           }else if(!recordsToUpdate.containsKey(record.Id) && 
                       !recordsToDelete.contains(new Campaign_Member_Record_Log__c(Id=record.Id))){
                           
                           if(!campNameVsId.containsKey(record.Campaign_Name__c)){
                               
                               recordsToUpdate.put(record.Id,
                                                new Campaign_Member_Record_Log__c(
                                Id=record.Id, Status__c='Error',
                            Error_Message__c  ='Campaign not Found '));
                               
                           }else if(record.Email_Address__c == null){
                               recordsToUpdate.put(record.Id,
                                                new Campaign_Member_Record_Log__c(
                                Id=record.Id, Status__c='Error',
                            Error_Message__c  ='Email address is null '));
                               
                           }else if(record.Error_Message__c == null){
                               recordsToDelete.add(new Campaign_Member_Record_Log__c(Id=record.Id));
                           }
                       }
                }
        System.debug('recordsToUpdate '+recordsToUpdate.size()+' '+recordsToUpdate);
        //update the records with error messgae
        if(!recordsToUpdate.isEmpty()){
            update recordsToUpdate.values();
        }
        
        //delete if no errors
        if(!recordsToDelete.isEmpty()){
            System.debug('recordsToDelete '+recordsToDelete.size());
            delete recordsToDelete;
        }
  
    }
    
    //method to get alternate email
    private static void getAlternateEmail(set<String> Emails){
        for(Alternate_Email__c alt:[SELECT Id, Alternate_Email_Address__c,Contact_Name__c, Lead_Name__c,Lead_Name__r.Id,Contact_Name__r.Id 
                                    FROM Alternate_Email__c 
                                    WHERE Alternate_Email_Address__c IN:Emails 
                                    ]){
                                        emailVsAlternateEmail.put(alt.Alternate_Email_Address__c,alt);
                                        if(alt.Contact_Name__r.Id != null){
                                            ContactandLeadID.add(alt.Contact_Name__r.Id);
                                        }
                                        if(alt.Lead_Name__r.Id != null){
                                            ContactandLeadID.add(alt.Lead_Name__r.Id);
                                        }
                                        emailset.remove(alt.Alternate_Email_Address__c.tolowercase());
                                    }
        
    }
    
    //method to get lead instance
     private static Lead getLeadInstance(Campaign_Member_Record_Log__c record){
                Lead lead = new Lead();
        
        lead.FirstName =record?.First_Name__c ;
        lead.LastName = record.Last_Name__c != null ?  record.Last_Name__c : '[[Unknown]]';
        lead.Email = record.Email_Address__c != null ? record.Email_Address__c.tolowercase() : '';
        lead.Company = record.Company__c != null ? record.Company__c : '';
        lead.Title = record.Job_Title__c != null ? record.Job_Title__c : '';
        lead.Street =record.Street__c != null  ? record.Street__c : '';
        lead.City =  record.City__c != null  ? record.City__c : '';
        lead.State =  record.State__c != null ? record.State__c : '';
        lead.PostalCode = record.Zip__c != null ? record.Zip__c : '';
        lead.Country =record.Country__c != null ? record.Country__c  : '';
        lead.LinkedIn_ID__c =record.Linkedin_Id__c != null ? record.Linkedin_Id__c : '';
        lead.GitHub_ID__c =record.Github_Id__c != null ? record.Github_Id__c : '';
        lead.Phone = record.Phone__c != null ? record.Phone__c : '';
        lead.Industry =record.Industry__c != null ? record.Industry__c : '';
        lead.LeadSource  =record.Lead_Source__c != null ? record.Lead_Source__c : '';
        lead.Lead_Source_Detail_p__c = record.Lead_Source_Detail__c != null ? record.Lead_Source_Detail__c : '';
        
        return lead;
     }
    
    //method to get campaign
    public static void getCampaign(Set<String> campaignset){
        List<Campaign> campaignList =[Select Id, Name From Campaign WHERE Name IN: campaignset];
        if(!campaignList.isEmpty()){
            campaignMap= new Map<Id,Campaign>(campaignList);
        for( Campaign Camp :campaignList) {
            campNameVsId.put(camp.Name, camp.id);
        }
    }
    }
    
    //method to add campaign member for existing lead/contact Or to update existing campaign member
   public static void addCampaignMemperforAlternateEmail(Campaign_Member_Record_Log__c record,Map<String,CampaignMember> emailVsCampMember,
    Map<string, set<ID>> cmMap){
        String Email = record.Email_Address__c.tolowercase();
        String CampaignName = record.Campaign_Name__c;
        
        if(  emailVsAlternateEmail.containsKey(Email)){
            CampaignMember newCM = new CampaignMember();
            //If Contact Or Lead is not in Campaign Member then add the Lead or Contact in Campaign Member  
            if(CampaignName != null && 
               (cmMap.get(CampaignName) == null ||(cmMap.get(CampaignName) != null && 
                                                   ((emailVsAlternateEmail.get(Email).Contact_Name__c != null && !cmMap.get(CampaignName).contains(emailVsAlternateEmail.get(Email).Contact_Name__c))
                                                    ||(emailVsAlternateEmail.get(Email).Lead_Name__c != null && !cmMap.get(CampaignName).contains(emailVsAlternateEmail.get(Email).Lead_Name__c))
                                                   )))) { 
                                                       newCM.CampaignId = campNameVsId.get(CampaignName);
                                                       if(emailVsAlternateEmail.get(Email).Contact_Name__c != null ) newCm.put('ContactId',emailVsAlternateEmail.get(Email).Contact_Name__c);
                                                       if(emailVsAlternateEmail.get(Email).Lead_Name__c != null) newCm.put('LeadID',emailVsAlternateEmail.get(Email).Lead_Name__c) ;
                                                       newCm.Comments__c = record.Notes__c;
                                                       newcm.Membership__c =record.Membership__c;
                                                       newcm.Newsletter__c =record.Newsletter__c;
                                                   }
            //existing campaign member updation
            if(emailVsCampMember.containsKey(Email)){
                String newComments = record.Notes__c;
                String newMembership =record.Membership__c;
                String newNewsLetter =record.Newsletter__c;
                
                if(emailVsCampMember.get(Email).Comments__c != newComments){
                    newCM.Id = emailVsCampMember.get(Email).Id;
                    newCm.Comments__c = newComments;
                }
                if(emailVsCampMember.get(Email).Membership__c != newMembership){
                    newCM.Id = emailVsCampMember.get(Email).Id;
                    newCm.Membership__c = newMembership;
                }
                if(emailVsCampMember.get(Email).Newsletter__c != newNewsLetter){
                    newCM.Id = emailVsCampMember.get(Email).Id;
                    newCm.Newsletter__c = newNewsLetter;
                }
            }
            if(newCM.CampaignId != null || newCM.Id != null){
                cm.add(newCM);
                cmemails.add(Email);
            }
        }

    }
}