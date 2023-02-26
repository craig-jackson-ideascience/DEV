/*
 LastModified By             ModifiedDate            Methods                                                 Against
 ========================================================================================================================
 Kalyani Chiluveri             18-May-2020`          populateLastPurchaseDate                            SFDC - 1288
 */
public class AssetTriggerHandler implements ITriggerHandler{
	public static void BeforeInsert(List<SObject> newList){
		//call before insert actions
		createOrUpdateMembership((List<Asset>)newList, null);
		//getMembershipDocURL((List<Asset>) newList, null);
	}

	public static void BeforeUpdate(Map<Id, Sobject> newMap, Map<Id, Sobject> oldMap){
		//call before update actions
		//handles if Asset was modified in a way that means the current Membership will no longer be associated with it
		updateOrDeleteMembership((List<Asset>)newMap.values(), (Map<ID, Asset>)oldMap, false);
		//handles if Asset was modified in a way that means it will now have a different Membership associated with it
		createOrUpdateMembership((List<Asset>)newMap.values(), (Map<ID, Asset>)oldMap);
	}

	public static void BeforeDelete(Map<Id, Sobject> oldMap){
		//call before delete actions
	}

	public static void AfterInsert(Map<Id, SObject> newMap){
		//call onAfterInsert delete actions
		updateLFMembership((List<Asset>)newMap.values(), null);
		//To update current year Price
		//updateCurrentYearSpend(newMap);
		populateLastPurchaseDate((List<Asset>)newMap.values());
		// updateCommunityDates((Map<Id, Asset>)newMap, null);
	}

	public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){
		updateLFMembership((List<Asset>)newMap.values(), (Map<id, Asset>)oldMap);
		//This Method is used to remove or adding value in Account.Project Memberships Fields
		updateAccountProjectField((List<Asset>)newMap.values(), (Map<id, Asset>)oldMap);
		//To update current year Price
		//updateCurrentYearSpend(newMap);
		//This method is used to update the Send_to_Groups_io__c checkbox when PurchaseHistory Status = Active
		updateProjectRoles((Map<Id, Asset>)newMap, (Map<Id, Asset>)oldMap);
		// updateCommunityDates((Map<Id, Asset>)newMap, (Map<Id, Asset>)oldMap);
		setOpportunityToClosedLost((List<Asset>)newMap.values(), (Map<Id, Asset>)oldMap);
		//
		//CurrentYearRevenueHandler.updateCurrentYearRevenue((map<Id, Asset>)newMap, (map<Id, Asset>)oldMap);
		//Call Method to add Contact of asset to SFDC Campaign
		addContactsToSFDCCampaign((Map<Id, Asset>)newMap, (Map<Id, Asset>)oldMap);

		//Call method to expired the document on opportunity if purchase history is expired
		updateFilesIfMembrshipExpired((Map<Id, Asset>)newMap, (Map<Id, Asset>)oldMap);
	}

	public static void AfterDelete(Map<Id, Sobject> oldMap){
		updateLFMembership(null, (Map<id, Asset>)oldMap);
		//This Method is used to remove value from Account.Project Memberships Fields if it is active
		deleteAccountProjectField(null, (Map<id, Asset>)oldMap);
		//To update current year Price
		//updateCurrentYearSpend(oldMap);
		updateOrDeleteMembership(new List<Asset>(), (Map<id, Asset>)oldMap, true);
	}

	public static void AfterUnDelete(Map<Id, Sobject> newMap){
		//call after undelete actions
	}

	public static boolean IsDisabled(){
		return null;
	}

	//This Method is used to remove value from Account.Project Memberships Fields if it is active
	public static void deleteAccountProjectField(List<Asset> newList, Map<Id, Asset> oldMap){
		set<id> inactiveaccountIDs = new set<id>();
		for (Asset asset : oldMap.values()){
			if (asset.status == 'Active'){
				inactiveaccountIDs.add(asset.AccountID);
			}
		}
		//Calling Inactive Asset
		if (inactiveaccountIDs.size() > 0)
			inactiveAccountUpdate(inactiveaccountIDs);
	}

	public static void updateLFMembership(List<Asset> newList, Map<Id, Asset> oldMap){
		List<Asset> listofActiveAsset = new List<Asset>();
		set<ID> accountIdsofLF = new set<ID>();
		set<ID> accountIdsnotofLF = new set<ID>();
		set<ID> accountIds = new set<ID>();
		List<Account> updateAccount = new List<Account>();
		List<Account> ListOfAccountUpdate = new List<Account>();
		LF_Membership_Only__c obj = LF_Membership_Only__c.getOrgDefaults();
		Boolean updateAsset = obj.Update_Asset__c;
		system.debug('#-updateAsset-#' + updateAsset);
		if (newList != Null){
			for (Asset asst : newList){
				if ((oldMap == Null) || updateAsset || (oldMap != null && ((asst.AccountId != oldMap.get(asst.Id).AccountId && asst.AccountId != null) || (asst.Projects__c != oldMap.get(asst.Id).Projects__c && asst.Projects__c != null) || (asst.Status != oldMap.get(asst.Id).Status && asst.Status != null)))){
					if (asst.AccountId != null){
						accountIds.add(asst.AccountId);
					}
				}
			}

		} else{
			for (Asset asst : oldMap.values()){
				if (asst.AccountId != null){
					accountIds.add(asst.AccountId);
				}
			}
		}

		if (!accountIds.isEmpty()){
			//Aggergate Query to get Account of Linux Foundation
			List<AggregateResult> resultLinuxFoundation = [SELECT AccountId, COUNT(Id)countId
			                                               FROM Asset
			                                               WHERE AccountId IN :AccountIds AND Account.Name != :Label.Lead_Conversion_Account AND Projects__c != null AND Projects__r.Name = 'The Linux Foundation' AND RecordType.Name = 'Corporate' AND Status IN ('Active', 'Purchased')
			                                               GROUP BY AccountId];

			//Adding List of Linux Foundation project Account in Set
			if (!resultLinuxFoundation.isEmpty()){
				for (AggregateResult Lf : resultLinuxFoundation){
					accountIdsofLF.add((Id) Lf.get('AccountId'));
				}
			}
			System.debug('listof AggregateResult' + resultLinuxFoundation);
			System.debug('accountIds==>' + accountIds);
			//Aggregate Query to get Account where Project is not of type Linux Foundation
			List<AggregateResult> notLinuxFoundation = [SELECT AccountId, COUNT(Id)countId
			                                            FROM Asset
			                                            WHERE AccountId IN :accountIds AND Account.Name != :Label.Lead_Conversion_Account AND Projects__c != null AND Projects__r.Name != 'The Linux Foundation' AND RecordType.Name = 'Corporate' AND Status IN ('Active', 'Purchased')
			                                            GROUP BY AccountId];

			//Adding List of Non Linux Foundation project Account in Set
			if (!notLinuxFoundation.isEmpty()){
				for (AggregateResult nlf : notLinuxFoundation){
					accountIdsnotofLF.add((Id) nlf.get('AccountId'));
				}
			}
			System.debug('notLinuxFoundation ' + notLinuxFoundation);

			//For loop on Account with Linux Foundation

			for (Id accId : accountIdsofLF){
				if (!accountIdsnotofLF.contains(accId)){
					updateAccount.add(new Account(id = accId, LF_Membership_Only__c = true));
				} else{
					updateAccount.add(new Account(id = accId, LF_Membership_Only__c = false));
				}
			}

			//Removing Accounts of Linux Foundtion Project when status changed other than Active or Purchased
			for (id acc : accountIds){
				if (!accountIdsofLF.contains(acc)){
					updateAccount.add(new Account(id = acc, LF_Membership_Only__c = false));
					System.debug('Account update' + updateAccount);
				}
			}

			//Update Account's LF_Membership_Only__c
			if (!updateAccount.isEmpty()){
				System.debug('updateAccount' + updateAccount);
				update updateAccount;
			}
		}
	}

	//This Method is used to remove or adding value in Account.Project Memberships Fields
	public static void updateAccountProjectField(List<Asset> newList, Map<Id, Asset> oldMap){
		set<id> inactiveaccountIDs = new set<id>();
		set<id> activeaccountIDs = new set<id>();
		Map<id, set<Id>> activeaccountMap = new Map<id, set<Id>>();
		BulkUpdateSetting__c bulkSetting = BulkUpdateSetting__c.getOrgDefaults();
		set<id> projectsIDs = new set<id>();
		List<asset> assetList = new list<asset>();
		for (Asset asset : newList){
			if ((bulkSetting.AssetTriggerBulk__c || oldMap.get(asset.id).status != asset.status) && asset.AccountID != null && asset.Projects__c != null){
				if (asset.status != 'Active'){
					inactiveaccountIDs.add(asset.AccountID);
				} else{
					if (!activeaccountMap.containsKey(asset.AccountID))
						activeaccountMap.put(asset.AccountID, new set<Id>());
					activeaccountMap.get(asset.AccountID).add(asset.Projects__c);

				}

			}
		}

		/*if(projectsIDs.size() > 0){
		 Map<id,Project__c> projectMap = new Map<id,Project__c>([select id,name from Project__c where id in:projectsIDs]);
		 if(assetList.size() > 0){
		 for(Asset asset : assetList){
		 if(asset.AccountId != null){
		 if(!activeaccountMap.containsKey(asset.AccountID)){
		 activeaccountMap.put(asset.AccountID,new set<String>{projectMap.get(asset.Projects__c).Name});
		 }else{
		 system.debug('#-activeaccountMap-#'+activeaccountMap);
		 system.debug('#-asset.Project__c-#'+asset.Project__c);
		 activeaccountMap.get(asset.AccountID).add(projectMap.get(asset.Projects__c).Name);
		 }
		 }
		 }
		 }
		 }*/
		if (!inactiveaccountIDs.isEmpty())
			inactiveAccountUpdate(inactiveaccountIDs);
		if (!activeaccountMap.isEmpty())
			activeAccountUpdate(activeaccountMap);
	}

	public static void inactiveAccountUpdate(set<id> AccountId){
		List<Asset> assetList = [Select id, status, Projects__c, AccountId, projects__r.Name
		                         from Asset
		                         where AccountId in :AccountId AND Account.Name != :Label.Lead_Conversion_Account AND Projects__c != null];
		set<String> ProjectSetString = new set<String>();
		Map<id, List<asset>> AccountProjectCountMap = new Map<id, List<asset>>();
		for (Asset asset : assetList){
			if (!AccountProjectCountMap.containsKey(asset.accountID))
				AccountProjectCountMap.put(asset.accountID, new List<Asset>());
			AccountProjectCountMap.get(asset.accountID).add(asset);
		}
		if (!AccountProjectCountMap.isEmpty()){
			//Calling Method to update Account
			inactiveAccountUpdateDelete(AccountProjectCountMap);
		}
	}

	//This Method is used to update a account if status is active of asset
	public static void inactiveAccountUpdateDelete(Map<id, List<asset>> AccountIdMap){
		List<Account> accountList = [Select id, Project_Memberships__c
		                             from Account
		                             where id in :AccountIdMap.keyset()];
		for (Account account : accountList){
			String temp = '';
			for (Asset asset : AccountIdMap.get(account.id)){
				if (asset.status == 'Active')
					temp += asset.projects__c + ';';
			}
			system.debug('#+=#' + temp);
			if (temp != Null){
				account.Project_Memberships__c = temp;
			}
		}
		update accountList;
	}

	//This Method is used to update a account if status is active of asset
	public static void activeAccountUpdate(Map<id, set<Id>> accountIdMap){
		List<Account> accountList = [Select id, Project_Memberships__c
		                             from Account
		                             where id in :AccountIdMap.keyset() AND Account.Name != :Label.Lead_Conversion_Account];
		for (Account account : accountList){
			String blanktemp = '';
			String notblanktemp = '';
			for (Id projectId : accountIdMap.get(account.id)){
				system.debug('#--#' + projectId);
				if (projectId != null && account.Project_Memberships__c != null && !account.Project_Memberships__c.contains(projectId)){
					notblanktemp += projectId + ';';
				} else{
					blanktemp += projectId + ';';
				}
			}
			system.debug('#--#' + account.Project_Memberships__c);
			if (account.Project_Memberships__c == null){
				account.Project_Memberships__c = blanktemp;
			} else{
				account.Project_Memberships__c += ';' + notblanktemp;
			}

		}
		if (!accountList.isEmpty())
			update accountList;
	}

	//This method is used to update the Send_to_Groups_io__c checkbox when PurchaseHistory Status = Active
	/*public static void updateProjectRoles(Map<Id, Asset> newMap, Map<Id, Asset> oldMap){
	 List<String> assetIds = new List<String>();
	 List<String> projectIds = new List<String>();
	 Map<Id, String> mapContactProjectRole = new Map<Id, String>();
	 Map<String, String> mapCampaignMemberRole = new Map<String, String>();
	 List<Project_Role__c> updProjectRoles = new List<Project_Role__c>();

	 for(Asset asset : newMap.values()){
	 assetIds.add(asset.id);
	 if(asset.Projects__c != null){
	 projectIds.add(asset.Projects__c);
	 }
	 }

	 List<Project_Role__c> lstProjectRoles = [Select Id, Contact__c, Send_to_Groups_io__c, Role__c, Asset__c from Project_Role__c where Asset__r.id IN :assetIds];
	 system.debug('lstProjectRoles....'+lstProjectRoles);
	 for(Project_Role__c pro : lstProjectRoles){
	 if(pro.Role__c == 'Representative/Voting Contact'){
	 mapCampaignMemberRole.put(pro.Role__c, 'Voting Contact');
	 }
	 else{
	 mapCampaignMemberRole.put(pro.Role__c, pro.Role__c);
	 }
	 }
	 system.debug('mapCampaignMemberRole....'+mapCampaignMemberRole);

	 List<CampaignMember> campaignMembers = [Select Campaign.Type, Campaign.Project__c, Subscription__c, Project_Role_Subscriptions__c, ContactId from CampaignMember where Campaign.Project__c IN : projectIds AND Campaign.Type = 'Web Form - Join Now' AND Subscription__c = 'Subscribe'];
	 system.debug('campaignMembers....'+campaignMembers);

	 if(!campaignMembers.isEmpty()){
	 for(CampaignMember cp : campaignMembers){
	 mapContactProjectRole.put(cp.ContactId, cp.Project_Role_Subscriptions__c);
	 }
	 system.debug('mapContactProjectRole....'+mapContactProjectRole);

	 for (Asset asset: newMap.values()) {
	 if(newMap.get(asset.Id).Status <> oldMap.get(asset.Id).Status && newMap.get(asset.Id).Status == 'Active'){
	 for(Project_Role__c pr : lstProjectRoles){
	 if(pr.Asset__c == asset.id && mapContactProjectRole.get(pr.Contact__c).contains(mapCampaignMemberRole.get(pr.Role__c))){
	 pr.Send_to_Groups_io__c = true;
	 updProjectRoles.add(pr);
	 }
	 }
	 }
	 }


	 if(!updProjectRoles.isEmpty()){
	 update updProjectRoles;
	 }
	 }
	 } */
	//Now this method is used for send notification when PurchaseHistory Status = Active
	public static void updateProjectRoles(Map<Id, Asset> newMap, Map<Id, Asset> oldMap){

		for (Asset a : newMap.values()){
			if (a.Status == 'Active' && a.Status != oldMap.get(a.Id).Status && a.Product_Family__c == 'Membership' && !System.IsBatch() && !System.isFuture()){
				notificationService.getAccessToken(a.Id);
			}
		}
	}

	/*
	 Date            :   12 - May - 2020
	 Developer Name  :   Kalyani Chiluveri
	 Description     :   Last Purchase Date on Account get updated whenever an asset is created under that account.
	 & Same will not work for Individual No - Account.
	 Param           :   List<Asset> list of newly created assets.
	 */
	public static void populateLastPurchaseDate(List<Asset> newList){
		Map<Id, Account> updateAccountMap = new Map<Id, Account>();
		for (Asset asset : newList){
			if (asset.AccountId != null && !((asset.AccountId).equals(Label.JoinNowIndividual_DefaultAccount))){
				Account account = new Account();
				account.ID = asset.AccountId;
				account.LastPurchaseDate__c = asset.CreatedDate.date();
				updateAccountMap.put(account.Id, account);
			}
		}
		if (!updateAccountMap.IsEmpty()){
			update updateAccountMap.values();
		}
	}
/*
	public static void updateCommunityDates(Map<Id, Asset> newMap, Map<Id, Asset> oldMap){
		Map<String, Project_Role__c> projConIdVsProjRoles = new Map<String, Project_Role__c>();
		list<asset> assetRecs = newMap.values();
		Id corporateRTID = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
		Map<Id, Community__c> idVsCommunities = new Map<Id, Community__c>();
		Map<Id, Asset> assetIdVsAssets = new Map<Id, Asset>();
		map<string, asset> mapMembAssets = new map<string, asset>();
		Set<ID> conIds = new Set<ID>();
		Set<ID> accountIds = new Set<ID>();
		set<ID> projectIds = new Set<ID>();
		set<id> platinumProductIDs = new Set<id>(new map<id, product2>([select id
		                                                                from product2
		                                                                where name like '%Platinum%']).keySet());

		//Only perform this logic if Install Date or Usage End Date is changed && Status = 'Active' or if Status is changed from Purchased to Active
		for (Asset assetRec : assetRecs){
			if (oldmap != null){

				if (assetRec.Status != 'Active' || (assetRec.InstallDate == oldMap.get(assetRec.Id).InstallDate && assetRec.UsageEndDate == oldMap.get(assetRec.Id).UsageEndDate && oldMap.get(assetRec.Id).Status == assetRec.Status)){
					continue;
				}
			}

			if (assetRec.Status == 'Active' && assetRec.AccountId != null && assetRec.Projects__c != null && assetRec.Product2Id != null && assetRec.Product_Family__c == 'Membership' && assetRec.RecordTypeId == corporateRTID){
				assetIdVsAssets.Put(assetRec.ID, assetRec);
				mapMembAssets.put(string.valueOf(assetRec.AccountId) + string.valueOf(assetRec.Projects__c), assetRec);
				accountIds.add(assetRec.AccountId);
				projectIds.add(assetRec.Projects__c);
				system.debug('accountids and projectids: ' + accountids);
			}
		}


		if (!assetIdVsAssets.isEmpty()){
			System.debug('assetIdVsAssets ==>' + assetIdVsAssets);

			//Refactored this to grab voting end date from  latest active Asset/Purchase history where Account and Project match Community Account and Project
			//because Community Roles are not always going to have corresponding Project Roles for the related Contact.
			//Previously, the contact needed a corresponding Project Role to decide which Community Roles needed to be updated

			//SOPS-417 Fix Bad Term Dates changed query to Where statement below
			//SS-258 Voting End Date on Collaborations
			List<Community__c> lstOfCommunities = [SELECT Id, Voting_End_Date__c, Project_Name__c, Project_Name__r.Name, Votind_Start_Date__c, Contact_Name__c, Collaboration_Name__c, AccountId__c, Appointed_By__c
			                                       FROM Community__c
			                                       where Collaboration_Type__c = 'Board' AND Contact_Name__c != null and status__c = 'Active' and AccountId__c IN :accountIds and Project_Name__c IN :projectIds];


			System.debug('lstOfCommunities ===>' + lstOfCommunities);
			for (Community__c communityRec : lstOfCommunities){
				boolean updateFlag = false;
				if (mapMembAssets.containsKey(string.valueOf(communityRec.AccountId__c) + string.valueOf(communityRec.Project_Name__c))){
					//Change Appointed by to Membership Entitlement if Membership Asset Tier = platinum member
					//Per Nirav in SOPS-871 Committee Data Automation in Salesforce
					if (platinumProductIDs.contains(mapMembAssets.get(string.valueOf(communityRec.AccountId__c) + string.valueOf(communityRec.Project_Name__c)).Product2Id) && communityRec.Appointed_By__c != 'Membership Entitlement'){
						communityRec.Appointed_By__c = 'Membership Entitlement';
						updateFlag = True;
					}

					if (communityRec.Appointed_By__c == 'Membership Entitlement'){
						//Only Update Voting Start date if NULL in case the Contact has been a voting member throughout previous memberships.
						if (communityRec.votind_start_date__c == null){
							communityRec.Votind_Start_Date__c = mapMembAssets.get(string.valueOf(communityRec.AccountId__c) + string.valueOf(communityRec.Project_Name__c)).InstallDate;
						}
						communityRec.Voting_End_Date__c = mapMembAssets.get(string.valueOf(communityRec.AccountId__c) + string.valueOf(communityRec.Project_Name__c)).UsageEndDate;
						updateFlag = true;
					}
				}
				if (updateFlag == true){
					idVsCommunities.put(communityRec.Id, communityRec);
				}
			}
			System.debug('idVsCommunities===>' + idVsCommunities);
			if (!idVsCommunities.isEmpty()){
				update idVsCommunities.values();
			}
		}
	}
*/
	private static void setOpportunityToClosedLost(List<Asset> assets, Map<Id, Asset> oldAssetMap){
		Set<Id> opportunityIds = new Set<Id>();
		List<Opportunity> oppToBeUpdated = new List<Opportunity>();
		Boolean isCancelled = true;
		String cancellationReason;
		for (Asset asset : assets){
			if (asset.Opportunity__c != null && (asset.Status == 'Invoice Cancelled' || asset.Status == 'Associate Cancelled') && asset.Status != oldAssetMap.get(asset.Id).Status){
				opportunityIds.add(asset.Opportunity__c);
			}
		}
		if (!opportunityIds.isEmpty()){
			for (Opportunity opp : [SELECT Id, (SELECT Id, Status, Cancellation_Reason__c
			                                    FROM Asset__r)
			                        FROM Opportunity 
			                        WHERE ID IN :opportunityIds]){
				isCancelled = true;
				for (Asset asset : opp.Asset__r){
					if (asset.Status == 'Invoice Cancelled' || asset.Status == 'Associate Cancelled'){
						isCancelled = true;
						cancellationReason = String.isNotBlank(asset.Cancellation_Reason__c) ? asset.Cancellation_Reason__c : 'Invoice Cancelled';
					} 
				}
				if (isCancelled){
					oppToBeUpdated.add(new Opportunity(Id = opp.Id, StageName = 'Closed Lost', Record_Locked__c = false, Loss_Reason__c = cancellationReason));
				}
			}
			if (!oppToBeUpdated.isEmpty()){
				update oppToBeUpdated;
			}
		}
	}

	public static void createOrUpdateMembership(List<Asset> newList, Map<Id, Asset> oldMap){
		//get corporate record type ID
		Id corporateRTID = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();

		//determine if any Assets passed into this method meet any criteria to run this method
		Set<ID> relevantAssets = new Set<ID>();
		for (Asset ph : newList){

			//first determine if this is a membership Asset with all necessary fields
			if (ph.AccountId != null && ph.Projects__c != null && ph.Product2Id != null && ph.Product_Family__c == 'Membership' && ph.RecordTypeId == corporateRTID){

				//if this is a new membership Asset
				if (oldMap == null){
					relevantAssets.add(ph.Id);
					System.debug('new membership Asset');

					//if this is an existing membership Asset and its Account was changed
				} else if (ph.AccountId != oldMap.get(ph.Id).AccountId){
					relevantAssets.add(ph.Id);
					System.debug('Account was changed');

					//if this is an existing membership Asset and its Project was changed
				} else if (ph.Projects__c != oldMap.get(ph.Id).Projects__c){
					relevantAssets.add(ph.Id);
					System.debug('Project was changed');

					//if this is an existing membership Asset and its Status was changed
					//from Invoice Cancelled to something else
				} else if (ph.Status != 'Invoice Cancelled' && ph.Status != 'Associate Cancelled' && (oldMap.get(ph.Id).Status == 'Invoice Cancelled' || oldMap.get(ph.Id).Status == 'Associate Cancelled')){
					relevantAssets.add(ph.Id);
					System.debug('Status was changed from Invoice Cancelled to something else');
				}
			}
		}

		//if no Assets passed into this method meet any of the criteria above, exit method
		if (relevantAssets.size() == 0){
			System.debug('no relevant assets were found for createOrUpdateMembership');
			return;
		}

		//get Accounts and Projects of relevant Assets
		Set<Id> accounts = new Set<ID>();
		Set<Id> projects = new Set<ID>();
		for (Asset ph : newList){
			if (relevantAssets.contains(ph.Id)){
				accounts.add(ph.AccountId);
				projects.add(ph.Projects__c);
			}
		}

		//get all existing memberships for the Accounts and Projects of the relevant Assets
		List<Membership__c> memberships = new List<Membership__c>();
		memberships = [SELECT Account__c, Project__c, Start_Date__c, End_Date__c, Product__c, Annual_Price__c
		               FROM Membership__c
		               WHERE Account__c IN :accounts AND Project__c IN :projects];

		//loop through relevant Assets
		Map<Asset, Membership__c> assetToMembership = new Map<Asset, Membership__c>();
		for (Asset ph : newList){
			if (relevantAssets.contains(ph.Id)){

				//look for existing membership record for this Account+Project
				Membership__c existingMembership = null;
				for (Membership__c memb : memberships){
					if (memb.Account__c == ph.AccountId && memb.Project__c == ph.Projects__c){
						existingMembership = memb;
						break;
					}
				}

				//if existing membership record was found, update it and associate Asset w/ it
				if (existingMembership != null){
					if (ph.UsageEndDate > existingMembership.End_Date__c){
						existingMembership.End_Date__c = ph.UsageEndDate;
						existingMembership.Product__c = ph.Product2Id;
						existingMembership.Annual_Price__c = ph.Annual_Full_Price__c;
					}
					if (ph.InstallDate < existingMembership.Start_Date__c){
						existingMembership.Start_Date__c = ph.InstallDate;
					}

					/* if (existingMembership.Start_Date__c.daysBetween(existingMembership.End_Date__c) > 1){
						existingMembership.Start_Date__c = ph.InstallDate;
					} */

					assetToMembership.put(ph, existingMembership);

					//if existing membership record wasn't found, create it and associate Asset w/ it
				} else{
					Membership__c newMembership = new Membership__c();
					newMembership.Account__c = ph.AccountId;
					newMembership.Project__c = ph.Projects__c;
					newMembership.Start_Date__c = ph.InstallDate;
					newMembership.End_Date__c = ph.UsageEndDate;
					newMembership.Product__c = ph.Product2Id;
					newMembership.Annual_Price__c = ph.Annual_Full_Price__c;
					newMembership.CurrencyIsoCode = ph.CurrencyIsoCode;


					assetToMembership.put(ph, newMembership);
				}
			}
		}

		//insert new membership records and update existing ones
		upsert assetToMembership.values();

		//update Assets with correct Membership
		for (Asset ph : assetToMembership.keySet()){
			ph.Membership__c = assetToMembership.get(ph).Id;
		}
	}

	public static void updateOrDeleteMembership(List<Asset> newList, Map<Id, Asset> oldMap, Boolean isDelete){
		//determine if any DELETED Assets passed into this method have Memberships associated with them
		//if they do, get Membership IDs from them
		Set<Id> membershipIDs = new Set<Id>();
		if (isDelete){
			for (Asset ph : oldMap.values()){
				if (ph.Membership__c != null){
					System.debug('deleted membership asset');
					membershipIDs.add(ph.Membership__c);
				}
			}
		}

		//determine if any UPDATED Assets passed into this method meet the criteria to run this method
		//if they do, get Membership IDs from them
		List<Asset> updatedAssets = new List<Asset>();
		for (Asset ph : newList){

			//first check to see if Asset has a Membership associated with it
			if (ph.Membership__c != null){

				//if Account or Project on Asset changed
				if (ph.AccountId != oldMap.get(ph.Id).AccountId || ph.Projects__c != oldMap.get(ph.Id).Projects__c){
					//get Membership ID from it
					System.debug('Account or Project of this asset changed');
					membershipIDs.add(ph.Membership__c);
				}

				//if Install Date, Usage End Date, Product, or Annual Full Price on Asset changed
				if (ph.InstallDate != oldMap.get(ph.Id).InstallDate || ph.UsageEndDate != oldMap.get(ph.Id).UsageEndDate || ph.Product2Id != oldMap.get(ph.Id).Product2Id || ph.Annual_Full_Price__c != oldMap.get(ph.Id).Annual_Full_Price__c){
					//get Membership ID from it, and add it to Set for later
					System.debug('Product, Price, or Date of this asset changed');
					membershipIDs.add(ph.Membership__c);
					updatedAssets.add(ph);
				}

				//if Status of Asset changed to Invoice Cancelled
				if (ph.Status == 'Invoice Cancelled' || ph.Status == 'Associate Cancelled'){
					//get Membership ID from it, but also remove Membership from it
					System.debug('status of this asset was changed to Invoice Cancelled');
					membershipIDs.add(ph.Membership__c);
					ph.Membership__c = null;
				}
			}
		}

		//only proceed if at least one Membership ID was collected
		if (membershipIDs.size() == 0){
			System.debug('no relevant assets were found for updateOrDeleteMembership');
			return;
		}

		//prep Asset data to ultimately accomplish these three goals:
		//1) get the earliest Install Date from any Asset attached to each Membership collected
		//2) get the latest Usage End Date from any Asset attached to each Membership collected, as
		//   well as the Product and Annual Full Price from the Asset with the latest Usage End Date
		//3) get a Set of Membership IDs that have ANY Assets attached, so that we can later delete
		//   the Memberships that have NO Assets attached

		//first, query assets related to Memberships collected that aren't in newList or oldMap
		List<Asset> assets = new List<Asset>();
		assets = [SELECT Id, InstallDate, UsageEndDate, Product2Id, Annual_Full_Price__c, Membership__c
		          FROM Asset
		          WHERE Membership__c IN :membershipIDs AND Id NOT IN :newList AND Id NOT IN :oldMap.keySet()];

		//then, add assets that had Install Date, Usage End Date, Product, or Annual Full Price updated
		//to that list of Assets
		//this way, we'll get the new changes of those Assets even though they haven't been committed yet
		assets.addAll(updatedAssets);

		//we now have all Asset data needed to get updated data for Memberships (the three goals above),
		//so create maps to store that updated data and run loop to collect it
		Map<ID, Date> membIDWithUpdatedStartDate = new Map<ID, Date>();
		Map<ID, Date> membIDWithUpdatedEndDate = new Map<ID, Date>();
		Map<ID, ID> membIDWithUpdatedProduct = new Map<ID, ID>();
		Map<ID, Decimal> membIDWithUpdatedAnnualPrice = new Map<ID, Decimal>();
		Set<ID> membIDsWithAssetAttached = new Set<ID>();

		for (Asset ph : assets){
			//if Membership attached to this Asset isn't in membIDWithUpdatedStartDate map yet,
			//or if Membership attached to this Asset IS in membIDWithUpdatedStartDate map but
			//the Install Date of this Asset is earlier than the date stored in that map
			if (!membIDWithUpdatedStartDate.containsKey(ph.Membership__c) || (membIDWithUpdatedStartDate.containsKey(ph.Membership__c) && ph.InstallDate < membIDWithUpdatedStartDate.get(ph.Membership__c))){
				//then update map with the Install Date from this Asset for the attached Membership
				membIDWithUpdatedStartDate.put(ph.Membership__c, ph.InstallDate);
			}

			//if Membership attached to this Asset isn't in membIDWithUpdatedEndDate map yet,
			//or if Membership attached to this Asset IS in membIDWithUpdatedEndDate map but
			//the Usage End Date of this Asset is later than the date stored in that map
			if (!membIDWithUpdatedEndDate.containsKey(ph.Membership__c) || (membIDWithUpdatedEndDate.containsKey(ph.Membership__c) && ph.UsageEndDate > membIDWithUpdatedEndDate.get(ph.Membership__c))){
				//then update all maps that need data from the latest Asset for the attached Membership
				membIDWithUpdatedEndDate.put(ph.Membership__c, ph.UsageEndDate);
				membIDWithUpdatedProduct.put(ph.Membership__c, ph.Product2Id);
				membIDWithUpdatedAnnualPrice.put(ph.Membership__c, ph.Annual_Full_Price__c);
			}

			//add attached Membership to set of Memberships that have at least one Asset attached
			membIDsWithAssetAttached.add(ph.Membership__c);
		}

		//get Membership records from Membership IDs collected
		List<Membership__c> memberships = new List<Membership__c>();
		memberships = [SELECT Start_Date__c, End_Date__c, Product__c, Annual_Price__c
		               FROM Membership__c
		               WHERE Id IN :membershipIDs];

		//check each Membership to see if it still has at least one Asset attached
		List<ID> membershipIDsToUpdate = new List<ID>();
		List<Membership__c> membershipsToDelete = new List<Membership__c>();
		for (Membership__c memb : memberships){
			if (membIDsWithAssetAttached.contains(memb.Id)){
				//Membership still has at least one Asset attached, so add it to list to be updated
				membershipIDsToUpdate.add(memb.Id);
			} else{
				//Membership has no Assets attached, so add it to list to be deleted
				membershipsToDelete.add(memb);
			}
		}

		//if any Memberships need to be updated,
		if (membershipIDsToUpdate.size() > 0){
			//get updated Membership data from maps
			for (Membership__c memb : memberships){
				if (membershipIDsToUpdate.contains(memb.Id)){
					memb.Start_Date__c = membIDWithUpdatedStartDate.get(memb.Id);
					memb.End_Date__c = membIDWithUpdatedEndDate.get(memb.Id);
					memb.Annual_Price__c = membIDWithUpdatedAnnualPrice.get(memb.Id);
					memb.Product__c = membIDWithUpdatedProduct.get(memb.Id);
				}
			}
			update memberships;
		}

		//if any Memberships need to be deleted, delete Memberships
		if (membershipsToDelete.size() > 0){
			delete membershipsToDelete;
		}
	}

	/*Method to get Membership Document Download URL
	 public static void getMembershipDocURL(List<Asset> newList, Map<Id, Asset> oldMap){
	 //get corporate record type ID
	 Id corporateRTID = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();

	 set<id> setMembershipOpps = new set<id>();

	 for(asset purchhist : newList){

	 //first determine if this is a membership Asset with all necessary fields
	 if (purchhist.AccountId != null && purchhist.Projects__c != null && purchhist.Product2Id != null && purchhist.Product_Family__c == 'Membership' && purchhist.Opportunity__c != null && purchhist.RecordTypeId == corporateRTID){

	 setMembershipOpps.add(purchhist.Opportunity__c);

	 }
	 }

	 //find contentdistribution record of membership document using opportunity id
	 //Note: fully executed membership documents are the only documents that have a contentdistribution record
	 list<contentdistribution> cds = [select id, name, ContentDocumentId, ContentVersionId, ContentDownloadUrl, contentversion.firstpublishlocationid
	 from contentdistribution
	 where contentversion.firstpublishlocationid in :setMembershipOpps] ;

	 map<string,string> oppvsDLURL = new map<string,string>();
	 if(!cds.isEmpty()){
	 for(contentdistribution cd : cds ) {
	 if(cd.ContentDownloadUrl != null ){
	 oppvsDLURL.put(string.valueOf(cd.contentversion.firstpublishlocationid), cd.ContentDownloadUrl);
	 }
	 }
	 }

	 //populate asset.membershipdocURL
	 for(asset ph : newList){

	 if(ph.AccountId != null && ph.Projects__c != null && ph.Product2Id != null && ph.Product_Family__c == 'Membership' && ph.Opportunity__c != null && ph.RecordTypeId == corporateRTID){
	 if(oppvsDLURL.containsKey(string.valueOf(ph.Opportunity__c))){
	 ph.Membership_Doc_Download_URL__c = oppvsDLURL.get(string.valueOf(ph.Opportunity__c));
	 }
	 }



	 }
	 }
	 */
	//Method to add Contact to campaign
	public static void addContactsToSFDCCampaign(Map<Id, Asset> newMap, Map<Id, Asset> oldMap){

		//Initialize variable
		Set<Id> projectIdSet = new Set<id>();
		Set<Id> productIdSet = new Set<id>();
		Set<Id> contactIds = new Set<Id>();
		List<Asset> assetList = new List<Asset>();

		//Project and Product List that to be considered
		List<Id> renewalProdIdSet = Label.Renewal_Product_List.split(';');
		List<Id> renewalProjIdSet = Label.Renewal_Project_List.split(';');

		//Iterate
		for (Asset ast : newMap.values()){
			//If Auto Renew is Changed and is of either LF Individual Supporter or OpenJS Individual participant membership
			if (ast.Auto_Renew__c != oldMap.get(ast.Id).Auto_Renew__c && ast.Status == 'Active' && ast.ContactId != null && !ast.Auto_Renew__c && renewalProjIdSet.contains(ast.Projects__c) && renewalProdIdSet.contains(ast.Product2Id)){

				assetList.add(ast);
				projectIdSet.add(ast.Projects__c);
				productIdSet.add(ast.Product2Id);
				contactIds.add(ast.ContactID);
			}
		}
		if (!assetList.isEmpty()){

			//Retrieve metadata
			Map<String, Id> renewalMetadataMap = new Map<String, Id>();
			List<Renewal_Campaign_Automation__mdt> renewalMetadata = [SELECT ProductId__c, ProjectId__c, CampaignId__c, Auto_Renew__c
			                                                          FROM Renewal_Campaign_Automation__mdt
			                                                          WHERE Called_From__c = 'Trigger' AND ProductId__c IN :productIdSet AND ProjectId__c IN :projectIdSet];
			//Iterate and create map
			for (Renewal_Campaign_Automation__mdt renewMdt : renewalMetadata){
				String key = renewMdt.ProjectId__c + '-' + renewMdt.ProductId__c + '-' + renewMdt.Auto_Renew__c;
				renewalMetadataMap.put(key, renewMdt.CampaignId__c);
			}

			//Call method to add members to respective campaigns
			addCampaignMember(assetList, renewalMetadataMap, contactIds);
		}
	}

	//method to add members to respective campaigns
	public static void addCampaignMember(List<Asset> assets, Map<String, Id> renewalMetadataMap, Set<Id> contactIds){
		List<CampaignMember> newCampaignMembers = new List<CampaignMember>();

		//get contactIds to fetch existing campaignMembers
		Map<Id, Map<Id, CampaignMember>> existingMembers = Utility.getExistingCampaignMembers(new Set<Id>(renewalMetadataMap.values()), contactIds);
		//Iterate
		for (Asset asset : assets){

			//Create key to check in metadata
			String key = asset.Projects__c + '-' + asset.Product2Id + '-' + asset.Auto_Renew__c;

			//if exist
			if (renewalMetadataMap.containsKey(key)){
				Id campaignId = renewalMetadataMap.get(key);
				Map<Id, CampaignMember> existingCampaignMembers = new Map<Id, CampaignMember>();

				//Get existing members for that campaign
				if (existingMembers.containsKey(campaignId)){
					existingCampaignMembers = existingMembers.get(campaignId);
				}

				//Instantiate campaign member
				CampaignMember cm = new CampaignMember();
				cm.Start_Date__c = asset.InstallDate;
				cm.End_Date__c = asset.UsageEndDate;
				cm.Payment_Id__c = asset.External_Payment_Id__c;
				if (!existingCampaignMembers.containsKey(asset.ContactId)){
					cm.ContactId = asset.contactId;
					cm.CampaignId = campaignId;
				} else{
					cm.Id = existingCampaignMembers.get(asset.ContactId).Id;
				}
				newCampaignMembers.add(cm);
			}

		}

		if (!newCampaignMembers.isEmpty()){
			//upsert
			upsert newCampaignMembers;
		}
	}

	//Method to expired the document on opportunity if purchase history is expired
	public static void updateFilesIfMembrshipExpired(Map<Id, Asset> newMap, Map<Id, Asset> oldMap){
		//insiantiate variables
		Set<Id> oppIdSet = new Set<Id>();
		Map<Id, Id> accountProjectMap = new Map<Id, Id>();
		set<String> accountprojectset = new set<string>();
		set<Id> accountIdset = new set<Id>();
		set<Id> projectIdset = new set<Id>();

		//Iterate
		for (Asset newAsset : newMap.values()){
			//if is of membership asset and it is expired
			if (newAsset.AccountId != null && newAsset.Projects__c != null && newAsset.Product_Family__c == 'Membership' && newAsset.status == 'Expired' && newAsset.Renewal_Opportunity_Created__c == false && newAsset.Opportunity__c != null && newAsset.status != oldMap.get(newAsset.Id).status && newAsset.accountid != Label.Individual_No_Account){
				accountIdset.add(newAsset.AccountId);
				projectIdset.add(newAsset.Projects__c);
				accountprojectset.add(newAsset.AccountId + '-' + newAsset.Projects__c);
			}
		}

		if (!accountprojectset.isEmpty()){
			//get all the opportunities of the account and project of asset
			List<Opportunity> oppList = [SELECT Id, AccountId, Project_Name__c, (SELECT ContentDocumentId, LinkedEntityId
			                                                                     FROM ContentDocumentLinks)
			                             FROM Opportunity 
			                             WHERE AccountId IN :accountIdset AND Project_Name__c IN :projectIdset];
			Set<Id> contentDocumentIdSet = new Set<id>();

			//iterate on opportunity
			for (Opportunity opp : oppList){
				string key = opp.accountid + '-' + opp.Project_Name__c;
				//if specified account and project 's opportunity is then get all its documentids
				if (accountprojectset.contains(key)){
					if (!opp.ContentDocumentLinks.isEmpty()){
						for (ContentDocumentLink contentDocument : opp.ContentDocumentLinks){
							contentDocumentIdSet.add(contentDocument.ContentDocumentId);
						}
					}
				}
			}

			if (!contentDocumentIdSet.isEmpty()){

				//retrive all content version for expiring
				List<ContentVersion> contentVersionList = [SELECT Id
				                                           FROM ContentVersion
				                                           WHERE ContentDocumentId IN :contentDocumentIdSet and Status__c != 'Expired' AND Title Like '%Executed%'];

				//iterate and expire
				if (!contentVersionList.isempty()){
					for (ContentVersion conVersion : contentVersionList){
						conVersion.Status__c = 'Expired';
					}
					//update
					update contentVersionList;
				}
			}
		}
	}
}