/*
 * Batch Class For One time updation of Status on Files -SOPS-291
 * Test Class = ConvertAttachmentToCVBatchTest
 */ 
public class ConvertAttachmentToCVBatch implements Database.Batchable<sObject>{
    
    //Instantiate variables
    Map<Id, Opportunity> opprtyMap = new Map<Id, Opportunity>();
    Public Map<String, List<Attachment>> accountProjVsAttchmntList = new Map<String, List<Attachment>>();
    String query;
    
    //Constructors
    public ConvertAttachmentToCVBatch(){}
    public ConvertAttachmentToCVBatch(String query){
        /*
          String query='select id,(SELECT Id,AccountId,Project_Name__c,Name 
                                              FROM Opportunities
                                              WHERE RecordType.Name='Membership' order by createddate desc) from Account ';
		*/
        this.query=query; 
       
    }
    
    //Start of Batch
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    //Execute of batch
    public void execute(Database.BatchableContext BC, List<Account> listOfAcount){
		Map<Id,Opportunity> opprtyMap = new Map<Id,Opportunity>();

		
		//Iterate and get the opportunity ids
		for(Account act : listOfAcount){
			if(!act.Opportunities.isEmpty()){
				for(Opportunity opp:act.Opportunities){
					opprtyMap.put(opp.id,opp);
				}
			}
		}
		if(!opprtyMap.isEmpty()){
			Map<String, List<Attachment>> accountProjVsAttchmntList = new Map<String, List<Attachment>>();
			//Retrieve Opportunity and its attachments
			List<Attachment> attachmentList =[SELECT Id,Name,Body,ParentId FROM Attachment 
			WHERE  ParentID IN: opprtyMap.keyset() order by createddate desc];
					for (Attachment a : attachmentList){
						if (a.Name.tolowercase().contains('executed') || 
						a.Name == opprtyMap.get(a.ParentId).Name){
							String key = opprtyMap.get(a.ParentId).AccountId +'-'
							+opprtyMap.get(a.ParentId).Project_Name__c;
							if(!accountProjVsAttchmntList.containsKey(key)){
								accountProjVsAttchmntList.put(key,new List<Attachment>());
							}
							accountProjVsAttchmntList.get(key).add(a);
						}
						
					}
					

			if(!accountProjVsAttchmntList.isEmpty()){
				System.debug('#--accountProjVsAttchmntList finish--#' + accountProjVsAttchmntList.keySet().size());
			   
				List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
			   //Iterate 
			   for(String key : accountProjVsAttchmntList.keySet()){
				   Integer count = 0;
				   System.debug('key '+key+' '+accountProjVsAttchmntList.get(key).size());
				   
				   //For all attachments create content version with latest as active and others as expired
				   for(Attachment attach : accountProjVsAttchmntList.get(key)){
					   ContentVersion contentVersion = new ContentVersion();
					   contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
					   contentVersion.PathOnClient = attach.Name+'.pdf';
					   contentVersion.Title = attach.Name+'.pdf';
					   contentVersion.VersionData = attach.Body;
					   contentVersion.FirstPublishLocationId = attach.ParentId; 
					   contentVersion.Show_in_Joinnow__c=True;
					   contentVersion.Status__c =count == 0 ? 'Active' : 'Expired';
					   System.debug('key '+attach.Name +'--- '+contentVersion);
					   contentVersionToInsert.add(contentVersion);
					   count +=1;
				   }
			   }
			   system.debug('contentVersionToInsert '+contentVersionToInsert.size());
			   if(!contentVersionToInsert.isEmpty()){
				   //insert
				   insert contentVersionToInsert;
				   
				   List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
				   
				   //Create ContentDistribution so we can get distributionpublicurl for documents
				   for(ContentVersion contVersion : contentVersionToInsert){
					   ContentDistribution cd = new ContentDistribution();
					   cd.Name = contVersion.Title.length() > 100 ? (contVersion.Title).substring(0,100)
                           : contVersion.Title;
					   cd.ContentVersionId = contVersion.Id;
					   cd.PreferencesAllowOriginalDownload = true;
					   cd.PreferencesAllowPDFDownload = true;
					   cd.PreferencesAllowViewInBrowser = true;
					   cd.PreferencesNotifyOnVisit = false;
					   contentDistributions.add(cd);
				   }
				   system.debug('contentDistributions '+contentDistributions);
				   if(!contentDistributions.isEmpty()){
					   //insert
					   insert contentDistributions;
				   }
				   
			   }
		   }
		}
        
    }
    
    //FInish of batch
    public void finish(Database.BatchableContext BC){
        
    }
}