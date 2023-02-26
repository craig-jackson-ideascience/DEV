public class campaignMemberTriggerHandler implements ITriggerHandler{
    
    //Static variables to pass from before event to after event for coupon code case
	public static Map<String,Coupon_Code__c> campaignLeadContactVsCouponMap = new Map<String,Coupon_Code__c>();
	public static Map<Id,Lead> leadListToUpdateCoupon = new Map<Id,Lead>();
	public static Map<Id,Contact> contactListToUpdateCoupon = new Map<Id,Contact>();
    
	public static void BeforeInsert(List<SObject> triggerNew){
        //Call method to populate coupon code on campaignmember if campaign has thirdpartycouponcode
		prepopulateCouponCode((List<CampaignMember>) triggerNew);
	}

	public void beforeUpdate(Map<id, SObject> newMap, Map<id, SObject> oldMap){
		evaluateMassDispositioning((Map<Id, CampaignMember>)newMap);
	}

	public static void BeforeDelete(Map<Id, Sobject> oldMap){
		//call before delete actions
	}

	public static void afterInsert(Map<Id, SObject> newMap){
		updateContactEmailOptOutClone((Map<Id, CampaignMember>)newMap, null);
		updateContactLeadTechnology((Map<Id, CampaignMember>)newMap, null);
		updateLeadOwner((Map<Id, CampaignMember>)newMap);
		//Call Method to update date sent field on coupon code if it is applied to the member
		updateCouponCodeWithDateSent();
        //updateContactEmailOptOut((Map<Id, CampaignMember>) newMap);
		
	}

	public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){
		updateContactEmailOptOutClone((Map<Id, CampaignMember>)newMap, (Map<Id, CampaignMember>)oldMap);
		updateContactLeadTechnology((Map<Id, CampaignMember>)newMap, (Map<Id, CampaignMember>)oldMap);
		//updateContactEmailOptOut((Map<Id, CampaignMember>) newMap);
		massDispositionCampaignMembers((Map<Id, CampaignMember>)newMap, (Map<Id, CampaignMember>)oldMap);
	}

	public static void AfterDelete(Map<Id, Sobject> oldMap){
	}

	public static void AfterUnDelete(Map<Id, Sobject> newMap){
	}

	public Boolean IsDisabled(){
		return TriggerStopper.stopTechnologyUpdate;
	}

    public static void updateContactLeadTechnology(Map<Id, CampaignMember> newMap, Map<Id, CampaignMember> oldMap){
		system.debug('Call Method');
		if (TriggerStopper.stopTechnologyUpdate)
			return;
		set<Id> setCampaignMemberIds = new set<Id>();
		set<Id> setContactIds = new set<Id>();
		set<Id> setLeadIds = new set<Id>();
		set<Id> setCampaignIds = new set<Id>();
		List<Lead> lstLead = new List<Lead>();
		List<Contact> lstContact = new List<Contact>();
		map<Id, Contact> mapContactUpdate = new map<Id, Contact>();
		map<Id, Lead> mapLeadUpdate = new map<Id, Lead>();
		string technology = '';
		List<string> lstString = new List<String>();
		List<String> lstStrLead = new List<String>();
		List<String> lstStrContact = new List<String>();
		Contact objContact = new Contact();
		Lead objLead = new Lead();
		CampaignMember oldCM = new CampaignMember();

		Integer cpuStart = Limits.getCpuTime();
		system.debug('Before for Loop--->' + cpuStart);

		for (CampaignMember objCampaignMember : newMap.values()){

			if (oldMap != null){
				oldCM = oldMap.get(objCampaignMember.id);
			}

			if (oldCM.CampaignId != objCampaignMember.CampaignId || oldCM.ContactId != objCampaignMember.ContactId || oldCM.LeadId != objCampaignMember.LeadId){

				setCampaignMemberIds.add(objCampaignMember.id);
				setContactIds.add(objCampaignMember.ContactId);
				setLeadIds.add(objCampaignMember.LeadId);
				setCampaignIds.add(objCampaignMember.CampaignId);
			}

		}

		map<Id, Campaign> mapCampaign = new map<Id, Campaign>([Select id, Technology__c, LF_Training__c, Type
		                                                       from Campaign
		                                                       where id IN :setCampaignIds AND Technology__c != null AND LF_Training__c = TRUE]);

		map<Id, Lead> mapLead = new Map<Id, Lead>();
		map<Id, Contact> mapContact = new Map<Id, Contact>();

		if (mapCampaign.size() > 0){

			if (!setContactIds.isEmpty())
				mapLead = new Map<Id, Lead>([Select id, Technology__c
				                             From Lead
				                             where id IN :setLeadIds]);
			if (!setContactIds.isEmpty())
				mapContact = new Map<Id, Contact>([Select id, Technology__c
				                                   From Contact
				                                   where id IN :setContactIds]);
			system.debug('Before for Loop--->' + cpuStart);

			For (CampaignMember objCampaignMember : newMap.values()){
				if (oldMap != null){
					oldCM = oldMap.get(objCampaignMember.id);
				}
				Campaign objCampaign = mapCampaign.get(objCampaignMember.CampaignId);
				if (objCampaign != null && (oldCM.CampaignId != objCampaignMember.CampaignId || oldCM.ContactId != objCampaignMember.ContactId || oldCM.LeadId != objCampaignMember.LeadId)){
					lstStrContact.clear();
					lstStrLead.clear();
					lstString.clear();
					if (objCampaignMember.CampaignId != null){
						lstString.add(objCampaign.Technology__c);
					}
					if (objCampaignMember.ContactId != null){
						if (mapContact.get(objCampaignMember.ContactId) != null){
							lstStrContact.add(objContact.Technology__c);
						}
					}
					if (objCampaignMember.leadId != null){
						if (mapLead.get(objCampaignMember.LeadId) != null){
							lstStrLead.add(objLead.Technology__c);
						}
					}
					if (objContact.id != null){
						lstContact.addALL(Utility.updateTechnologyOnContact(objContact, lstString, lstStrContact));
					}
					if (objLead.id != null){
						lstLead.addAll(Utility.updateLeadTechnology(objLead, lstString, lstStrLead));
					}
				}
			}

			system.debug('Cpu Time Consumed in loop' + (Limits.getCpuTime()-cpuStart));
			system.debug('Before DML=' + Limits.getCpuTime());

			if (lstLead.size() > 0){

				mapLeadUpdate.putAll(lstLead);
				system.debug('mapLeadUpdate-->' + mapLeadUpdate);
				update mapLeadUpdate.values();
			}
			if (lstContact.size() > 0){
				mapContactUpdate.putAll(lstContact);
				system.debug('mapContactUpdate-->' + mapContactUpdate);
				update mapContactUpdate.values();
			}
		}

		system.debug('CPU time consumed in DML=' + (Limits.getCpuTime()-cpuStart));
	}

	Public static void updateLeadOwner(Map<Id, CampaignMember> newMap){

		DateTime dT;
		Date CampaignDate;
		DateTime dT1;
		Date LeadDate;
		List<CampaignMember> lstCampaignMember = [Select id, LeadId, Campaign.OwnerId, Campaign.createddate, Lead.CreatedDate, Campaign.Project__c, Lead.country, Lead.Campaign_Member_Created__c
		                                          from CampaignMember
		                                          where Id IN :newMap.keyset()];
		//system.debug('lstCampaignMember-->'+lstCampaignMember);
		Map<Id, Lead> mapLead = new Map<Id, Lead>();
		Map<String, LeadCountry__c> mapCountry = new Map<string, LeadCountry__c>();
		List<LeadCountry__c> lstLeadCountry = [Select id, Name, Country__c, User__c
		                                       from LeadCountry__c];
		for (LeadCountry__c objLeadCountry : lstLeadCountry){
			mapCountry.put(objLeadCountry.Country__c, objLeadCountry);
		}
		for (CampaignMember objCampaignMember : lstCampaignMember){
			if (objCampaignMember.LeadId != Null && objCampaignMember.Lead.country != null){
				mapLead.put(objCampaignMember.LeadId, objCampaignMember.Lead);
				Lead objLead = mapLead.get(objCampaignMember.LeadId);
				LeadCountry__c objLeadCountry = mapCountry.get(objCampaignMember.Lead.country);
				//dT = objCampaignMember.Campaign.createddate;
				//CampaignDate = date.newinstance(dT.year(), dT.month(), dT.day());
				//dT1 = objCampaignMember.Lead.createddate;
				//LeadDate = date.newinstance(dT1.year(), dT1.month(), dT1.day());
				if (objCampaignMember.Lead.country != null && objCampaignMember.LeadId != Null && objCampaignMember.Campaign.Project__c != null && objCampaignMember.Lead.Campaign_Member_Created__c == false){
					if (objLeadCountry != null){
						if (objCampaignMember.Lead.country.contains(objLeadCountry.Country__c)){
							objLead.OwnerId = objLeadCountry.User__c;
							objLead.Campaign_Member_Created__c = true;
						}
					} else{
						objLead.OwnerId = objCampaignMember.Campaign.OwnerId;
						objLead.Campaign_Member_Created__c = true;
					}
				}
			}
		}
		if (mapLead != null){
			//system.debug('mapLead.values()--->'+mapLead.values());
			Update mapLead.values();
		}
	}

	/*
	 public static void updateContactEmailOptOut(Map<Id, CampaignMember> newMap) {

	 Map<Id, CampaignMember> updateCampaignMem = new Map<Id, CampaignMember>();
	 Map<Id, Contact> updateContacts = new Map<Id, Contact>();
	 Map<Id,CampaignMember> campIDVsCampMem = new Map<Id,CampaignMember> ([SELECT Application_Development__c,Status,CampaignId,Campaign.Name,Contact.HasOptedOutOfEmail,Campaign.Type,ContactId,Contact.Name
	 FROM CampaignMember
	 WHERE (Status != 'Unsubscribed' OR Contact.HasOptedOutOfEmail = TRUE )  AND Campaign.Type = 'Subscription Center' AND ContactId != NULL AND ID IN : newMap.keySet()]);

	 for(CampaignMember camp : campIDVsCampMem.Values()) {
	 if(camp.Contact.HasOptedOutOfEmail && camp.HasOptedOutOfEmail == false) {
	 Contact con = new Contact();
	 con.ID = camp.ContactID;
	 con.HasOptedOutOfEmail  = False;
	 updateContacts.put(con.ID, con);
	 }

	 if(camp.Status != 'Unsubscribed' && camp.HasOptedOutOfEmail == false) {
	 camp.Status = 'Unsubscribed';
	 updateCampaignMem.put(camp.ID, camp);
	 }
	 }


	 if(!updateContacts.isEmpty()) {
	 update updateContacts.Values();
	 }
	 System.debug('updateCampaignMem.Values()-->'+updateCampaignMem.Values());
	 if(!updateCampaignMem.isEmpty()) {
	 update updateCampaignMem.Values();
	 }
	 }
	 */
	//Added by pratik D
	public static void updateContactEmailOptOutClone(Map<Id, CampaignMember> newMap, Map<Id, CampaignMember> oldMap){

		if (RecursiveTriggerHandler.isFirstTime){
			RecursiveTriggerHandler.isFirstTime = false;
			set<Id> ContactIds = new set<Id>();
			set<Id> LeadIds = new set<Id>();
			Map<Id, Contact> updateContacts = new Map<Id, Contact>();
			Map<Id, Lead> updateLeads = new Map<Id, Lead>();
			CampaignMember objOldCM = new CampaignMember();
			for (CampaignMember objCampaignMember : [SELECT Id, ContactId, LeadId, Status
			                                         FROM CampaignMember
			                                         WHERE Id IN :newMap.keySet() AND Campaign.Type = 'Subscription Center' AND Campaign.IsActive = True AND Campaign.Add_to_Subscription_Center__c = True]){
				if (oldMap != Null){
					objOldCM = oldMap.get(objCampaignMember.Id);
				}
				if (objOldCM.Status != objCampaignMember.Status && objCampaignMember.ContactID != Null){
					ContactIds.add(objCampaignMember.ContactID);
				}
				if (objOldCM.Status != objCampaignMember.Status && objCampaignMember.LeadId != Null){
					LeadIds.add(objCampaignMember.LeadId);
				}
			}

			if (!ContactIds.isEmpty() || !LeadIds.isEmpty()){
				for (CampaignMember objCampaignMember : [SELECT Status, Contact.HasOptedOutOfEmail, ContactID, Lead.HasOptedOutOfEmail, LeadID
				                                         FROM CampaignMember
				                                         WHERE (ContactID IN :ContactIds OR LeadID IN :LeadIds) AND Campaign.type = 'Subscription Center' AND Campaign.IsActive = True AND Campaign.Add_to_Subscription_Center__c = True
				                                         FOR  UPDATE ]){
					if (objCampaignMember.Status == 'Subscribed'){
						if (objCampaignMember.ContactID != Null){
							Contact con1 = new Contact();
							con1 = updateContacts.get(objCampaignMember.ContactID);
							if (con1 != Null && con1.HasOptedOutOfEmail == true){
								con1.HasOptedOutOfEmail = false;
								updateContacts.put(con1.ID, con1);
							} else{
								Contact con = new Contact();
								con.ID = objCampaignMember.ContactID;
								con.HasOptedOutOfEmail = false;
								updateContacts.put(con.ID, con);
							}
						}
						if (objCampaignMember.LeadID != Null){
							Lead lead1 = new Lead();
							lead1 = updateLeads.get(objCampaignMember.LeadID);
							if (lead1 != Null && lead1.HasOptedOutOfEmail == true){
								lead1.HasOptedOutOfEmail = false;
								updateleads.put(lead1.ID, lead1);
							} else{
								Lead lead2 = new Lead();
								lead2.ID = objCampaignMember.LeadID;
								lead2.HasOptedOutOfEmail = false;
								updateLeads.put(lead2.ID, lead2);
							}
						}
					}

					if (objCampaignMember.Status == 'Unsubscribed'){
						if (objCampaignMember.ContactID != Null){
							Contact con1 = new Contact();
							con1 = updateContacts.get(objCampaignMember.ContactID);
							if (con1 == NULL){
								Contact con = new Contact();
								con.ID = objCampaignMember.ContactID;
								con.HasOptedOutOfEmail = true;
								updateContacts.put(con.ID, con);
							}
						}
						if (objCampaignMember.LeadID != Null){
							Lead lead1 = new Lead();
							lead1 = updateLeads.get(objCampaignMember.LeadID);
							if (lead1 == NULL){
								Lead lead2 = new Lead();
								lead2.ID = objCampaignMember.LeadID;
								lead2.HasOptedOutOfEmail = true;
								updateLeads.put(lead2.ID, lead2);
							}
						}
					}
				}
			}
			if (!updateContacts.isEmpty()){
				update updateContacts.Values();
			}
			if (!updateLeads.isEmpty()){
				update updateLeads.Values();
			}
		}
	}

	static List<ID> cmsToSkipMassDisposition = new List<ID>();
	public static void evaluateMassDispositioning(Map<Id, CampaignMember> newMap){
		for (CampaignMember cm : newMap.values()){

			if (cm.Skip_Mass_Disposition_Trigger__c == true){
				//add any CM who should not kick off mass dispositioning to static list
				cmsToSkipMassDisposition.add(cm.Id);

				//set flag on CM back to false so that the next status update on this record
				//initiated by a human will still kick off mass dispositioning as expected
				cm.Skip_Mass_Disposition_Trigger__c = false;
			}
		}
	}

	public static void massDispositionCampaignMembers(Map<Id, CampaignMember> newMap, Map<Id, CampaignMember> oldMap){
		Map<ID, Map<ID, String>> projectIDToContactIDToStatus = new Map<ID, Map<ID, String>>();
		Map<ID, Map<ID, String>> projectIDToLeadIDToStatus = new Map<ID, Map<ID, String>>();
		Set<ID> contactAndLeadIDs = new Set<ID>();
		List<String> dispositionStatuses = Label.Campaign_Disposition_Statuses.split('\\r?\\n');

		for (CampaignMember cm : newMap.values()){

			//determine which CMs in this batch qualify for mass-dispositioning,
			//i.e. they aren't in the static cmsToSkipMassDisposition list,
			//they're related to a Campaign where auto-dispositioning is allowed,
			//they're related to a Campaign that has a Project associated with it,
			//their Status is in the list of disposition statuses, and
			//their Status was just changed
			if (!cmsToSkipMassDisposition.contains(cm.Id) && cm.Auto_Disposition_Campaign__c == true && cm.MC_Project_ID__c != null && dispositionStatuses.contains(cm.Status) && cm.Status != oldMap.get(cm.Id).Status){

				if (cm.ContactId != null){
					contactAndLeadIDs.add(cm.ContactId);

					//add to projectIDToContactIDToStatus map
					if (projectIDToContactIDToStatus.get(cm.MC_Project_ID__c) == null){
						Map<ID, String> contactIDToStatus = new Map<ID, String>();
						contactIDToStatus.put(cm.ContactId, cm.Status);
						projectIDToContactIDToStatus.put(cm.MC_Project_ID__c, contactIDToStatus);
					} else{
						projectIDToContactIDToStatus.get(cm.MC_Project_ID__c).put(cm.ContactId, cm.Status);
					}

				} else if (cm.LeadId != null){
					contactAndLeadIDs.add(cm.LeadId);

					//add to projectIDToLeadIDToStatus map
					if (projectIDToLeadIDToStatus.get(cm.MC_Project_ID__c) == null){
						Map<ID, String> leadIDToStatus = new Map<ID, String>();
						leadIDToStatus.put(cm.LeadId, cm.Status);
						projectIDToLeadIDToStatus.put(cm.MC_Project_ID__c, leadIDToStatus);
					} else{
						projectIDToLeadIDToStatus.get(cm.MC_Project_ID__c).put(cm.LeadId, cm.Status);
					}
				}
			}
		}

		//if no CMs in this batch qualify for mass-dispositioning, return
		if (projectIDToContactIDToStatus.size() == 0 && projectIDToLeadIDToStatus.size() == 0){
			System.debug('no CMs in this batch qualify for mass-dispositioning');
			return;
		}

		//for any CMs that do qualify for mass-dispositioning, query other Campaign Members
		//related to the same Lead/Contact in other Campaigns where auto-dispositioning is
		//allowed, as long they are associated with the relevant project(s)
		//(exclude the CMs that actually kicked off this trigger from this query)
		List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
		cmsToUpdate = [SELECT Id, Status, CampaignId, MC_Project_ID__c, ContactId, LeadId
		               FROM CampaignMember
		               WHERE Campaign.Auto_Disposition_Allowed__c = true AND (ContactId IN :contactAndLeadIDs OR LeadId IN :contactAndLeadIDs) AND Id NOT IN :newMap.keySet() AND (MC_Project_ID__c IN :projectIDToContactIDToStatus.keySet() OR MC_Project_ID__c IN :projectIDToLeadIDToStatus.keySet())];

		//if no CMs to be updated were found, return
		if (cmsToUpdate.size() == 0){
			return;
		}

		//before we update the Campaign Member Statuses, we have to make sure the new
		//status value exists as a status for the relevant Campaigns
		//to that end, create set of Campaign IDs attached to the cmsToUpdate
		Set<ID> campaignIDs = new Set<ID>();
		for (CampaignMember cm : cmsToUpdate){
			campaignIDs.add(cm.CampaignId);
		}

		//and query the Statuses of those Campaigns
		List<CampaignMemberStatus> campaignStatuses = new List<CampaignMemberStatus>();
		campaignStatuses = [SELECT Label, CampaignId
		                    FROM CampaignMemberStatus
		                    WHERE CampaignId IN :campaignIDs];

		//now try updating the cmsToUpdate with their new status values
		//if the new status value doesn't exist for that CM's campaign, skip that CM
		List<CampaignMember> cmsWithNewStatus = new List<CampaignMember>();
		for (CampaignMember cm : cmsToUpdate){

			String newStatus = '';
			ID projectID = cm.MC_Project_ID__c;

			//get new Status from a CM in this batch
			if (cm.ContactId != null){
				//get new status for this Contact+Project from projectIDToContactIDToStatus
				if (projectIDToContactIDToStatus.get(projectID) != null){
					if (projectIDToContactIDToStatus.get(projectID).get(cm.ContactId) != null){
						newStatus += projectIDToContactIDToStatus.get(projectID).get(cm.ContactId);
					}
				}

			} else if (cm.LeadId != null){
				//get new status for this Lead+Project from projectIDToLeadIDToStatus
				if (projectIDToLeadIDToStatus.get(projectID) != null){
					if (projectIDToLeadIDToStatus.get(projectID).get(cm.LeadId) != null){
						newStatus += projectIDToLeadIDToStatus.get(projectID).get(cm.LeadId);
					}
				}
			}

			//only continue if new Status was found and it's not the same as the current status
			if (newStatus != '' && newStatus != cm.Status){

				//check to see if newStatus is a status available for this CM's campaign
				Boolean statusAvailable = false;
				for (CampaignMemberStatus status : campaignStatuses){
					if (cm.CampaignId == status.CampaignId){
						if (newStatus == status.Label){
							statusAvailable = true;
							break;
						}
					}
				}

				//if newStatus is available, add this CM to list with new Status value
				if (statusAvailable){
					cm.Status = newStatus;
					//also skip mass-dispositioning on it, since that would be redundant
					cm.Skip_Mass_Disposition_Trigger__c = true;
					cmsWithNewStatus.add(cm);
				}
			}
		}

		if (cmsWithNewStatus.size() > 0){
			update cmsWithNewStatus;
		}
	}

    //Method to populate coupon code on campaignmember if campaign has thirdpartycouponcode
    public static void prepopulateCouponCode(List<CampaignMember> campMemberList){
        Set<Id> campaignIdSet = new Set<Id>();
        //Iterate and get the campignIds
        for(CampaignMember campMember : campMemberList){
            campaignIdSet.add(campMember.campaignId);
        }
        System.debug('campaignIdSet '+campaignIdSet.size());
        if(!campaignIdSet.isEmpty()){
            
            //Retrieve the coupon code whose campaign has thirdpartychecked and datesent is null
            List<Coupon_Code__c> couponCodeList = [SELECT Id,Campaign_Name__c,Name FROM Coupon_Code__c 
                                                   WHERE Campaign_Name__c IN: campaignIdSet AND 
                                                   Campaign_Name__r.Thirdparty_Coupon__c = true AND 
                                                   Date_Sent__c = NULL AND
                                                   ( Expiration_Date__c = null OR Expiration_Date__c >= today)
                                                  ];
            Map<Id,List<Coupon_Code__c>> campaignIdVsCouponCodeId = new Map<Id,List<Coupon_Code__c>>();
            System.debug('couponCodeList '+couponCodeList.size());
            
            //Iterate and store CouponCodes against the campaign
            for(Coupon_Code__c couponCode : couponCodeList){
                if(!campaignIdVsCouponCodeId.containsKey(couponCode.Campaign_Name__c)){
                    campaignIdVsCouponCodeId.put(couponCode.Campaign_Name__c,new List<Coupon_Code__c>());
                    
                }campaignIdVsCouponCodeId.get(couponCode.Campaign_Name__c).add(couponCode);
            }
            
            if (!campaignIdVsCouponCodeId.isEmpty()) {
                Set<Id> couponCodeAssignedSet = new Set<Id>();
                //Iterate on campaignmembers
                for(CampaignMember campMember : campMemberList){
                    
                    //do coupon code exist
                    if(campaignIdVsCouponCodeId.containsKey(campMember.campaignId)){
                        
                        //Iterate on coupon codes
                        for(Coupon_Code__c couponCode : campaignIdVsCouponCodeId.get(campMember.campaignId)){
                            Id leadContactId = campMember.ContactId != null ? campMember.ContactId : campMember.LeadId ;
                            String key = campMember.CampaignId+'-'+leadContactId;
                            //If the coupon is assigned to the same campaignmember then get that 
                            //and if it is assigned to other then don't take that coupon again
                            
                            Coupon_Code__c currentCoupon = campaignLeadContactVsCouponMap.containsKey(key) ?
                                campaignLeadContactVsCouponMap.get(key) :
                            (!couponCodeAssignedSet.contains(couponCode.Id) ? couponCode : null);
                                
                                if(currentCoupon != null){
                                    //Assigned Coupon Code on campaign member
                                    campMember.Coupon_Code__c=currentCoupon.Name;
                                    couponCodeAssignedSet.add(currentCoupon.Id);
                                    //Assigned couponCode to Contact/Lead as well
                                    if(campMember.ContactId != null){
                                        contactListToUpdateCoupon.put(campMember.ContactId,new Contact(
                                            Id=campMember.ContactId,Coupon_Code__c=currentCoupon.Name));
                                    }else if(campMember.LeadId != null){
                                        leadListToUpdateCoupon.put(campMember.LeadId,new Lead(
                                            Id=campMember.LeadId,Coupon_Code__c=currentCoupon.Name));
                                    }
                                    
                                    currentCoupon.Date_Sent__c = System.today();
                                    campaignLeadContactVsCouponMap.put(key,currentCoupon);
                                    break;
                                }
                        }
                    }
                }
            }
        }
        
    }
    
    //Method to update date sent field on coupon code if it is applied to the member
    public static void updateCouponCodeWithDateSent(){
        
        //Update Coupon Code
        if(!campaignLeadContactVsCouponMap.isEmpty()){
            update campaignLeadContactVsCouponMap.values();
        }
        
        List<Sobject> contactLeadListToUpdate = new List<Sobject>();
        //Add lead with coupon code to the generic list
        if(!leadListToUpdateCoupon.isEmpty()){
            contactLeadListToUpdate.addAll(leadListToUpdateCoupon.values());
        }
        //Add contact with coupon code to the generic list
        if(!contactListToUpdateCoupon.isEmpty()){
            contactLeadListToUpdate.addAll(contactListToUpdateCoupon.values());
        }
        //if not empty then update
        if(!contactLeadListToUpdate.isEmpty()){
            update contactLeadListToUpdate;
        }
        
    }     
    
}