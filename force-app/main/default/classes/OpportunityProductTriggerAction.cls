public Class OpportunityProductTriggerAction{
	/*
	 If Membership product is being added then
	 add free training product automatically
	 */
	/*
	 public void insertFreeTrainingProduct(List<OpportunityLineItem> newOli){

	 List<OpportunityLineItem> insertFreeTrainingProducts = new List<OpportunityLineItem>();
	 List<PricebookEntry> getFreeTrainingID = [SELECT id,UnitPrice,product2.family FROM PricebookEntry WHERE name=: System.label.Free_Training limit 1];
	 Set<ID> OpportunityParsed = new Set<ID>();
	 Set<ID> opportunityIDs = new Set<ID>();
	 Map<ID,Opportunity> oppWithFreeTrainingOli = new Map<ID,Opportunity>();

	 for(opportunityLineItem oli : newOli){
	 opportunityIDs.add(oli.Opportunityid);
	 }

	 System.debug('___opportunityIDs_____'+opportunityIDs);

	 if(!opportunityIDs.isEmpty() && opportunityIDs != null){
	 oppWithFreeTrainingOli = new Map<ID,Opportunity>([SELECT id,(SELECT id FROM OpportunityLineItems
	 WHERE product2.name =: System.label.Free_Training)
	 FROM Opportunity
	 WHERE id =: opportunityIDs]);

	 System.debug('___oppWithFreeTrainingOli_______'+oppWithFreeTrainingOli);
	 }

	 for(OpportunityLineItem oli : newOli){

	 System.debug('_______oppid_____'+oli.Opportunityid);

	 if(!OpportunityParsed.contains(oli.OpportunityId)){

	 OpportunityParsed.add(oli.OpportunityId);
	 System.debug('___project__'+oli.project__c+'_____'+'___oli____'+oppWithFreeTrainingOli.get(oli.OpportunityId).opportunitylineitems);

	 if(oli.project__C != '' && oli.project__C != null && oppWithFreeTrainingOli.get(oli.OpportunityId).opportunitylineitems.isEmpty()){
	 insertFreeTrainingProducts.add(new OpportunityLineItem(opportunityid=oli.Opportunityid,unitPrice=getFreeTrainingID[0].UnitPrice,
	 Quantity=1,PricebookEntryId=getFreeTrainingID[0].id,type__c=getFreeTrainingID[0].product2.family));
	 }
	 }
	 }

	 System.debug('___insertFreeTrainingProducts_____'+insertFreeTrainingProducts);

	 if(!insertFreeTrainingProducts.isEmpty() && insertFreeTrainingProducts != null){
	 insert insertFreeTrainingProducts;
	 }

	 }
	 */
	// Insert Notes under Oppportunity if Required Active LF Membership is TRUE on OLI
	/*Commented by Himani G.
	 public void noteInsert(List<OpportunityLineItem> newOli){

	 Note[] noteList = new Note[] {};

	 for(OpportunityLineItem ol: newOli) {


	 if (ol.Required_Active_LF_Membership__c == true)

	 {
	 Note n = new Note();
	 system.debug('__inside__' + ol.opportunityid);
	 n = new Note();
	 n.body = 'Active LF membership confirmed for account';
	 n.title = 'Active LF membership confirmed';

	 n.ParentId = ol.OpportunityId;
	 noteList.add(n);
	 }


	 }

	 insert noteList;

	 }*/
	public void updateOpportunityFields(List<OpportunityLineItem> newOli){

		Set<ID> opportunityIDs = new Set<ID>();
		Map<ID, Opportunity> OppFilteredToUpdate = new Map<ID, Opportunity>();
		Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();
		Map<Id, OpportunityLineItem> olis = new Map<Id, OpportunityLineItem>();

		system.debug('__newOli___' + newOli);

		olis = new Map<Id, OpportunityLineItem>([Select Id, Year__c, OpportunityId, Opportunity.Type, product_details__r.Start_Tier__c, product_details__r.End_Tier__c, Opportunity.Total_Products_under_Opportunity__c, Opportunity.First_Project_Event_Training_Name__c, Opportunity.First_Product_Name__c, Product2Id, Product2.Name, Training__c, Event__c, Projects__c, Type__c, Training__r.Name, Event__r.Name, Projects__r.Name, opportunity.Account.NumberofEmployees, opportunity.Product_Tier_Needs_Verification__c
		                                         FROM OpportunityLineItem
		                                         WHERE Id = :newOli]);

		if (!olis.isEmpty() && olis.size() > 0){

			for (OpportunityLineItem oli : olis.values()){

				if (oli.Opportunity.Total_Products_under_Opportunity__c == 0 && !oppsToUpdate.containsKey(oli.OpportunityId)){

					Opportunity op = new Opportunity(Id = oli.OpportunityId);
					op.First_Product_Name__c = oli.Product2.Name;

					if (oli.Projects__r.Name != null){
						op.First_Project_Event_Training_Name__c = oli.Projects__r.Name;
						op.First_Product_Year__c = String.valueOf(oli.year__c);
					} else if (oli.Training__r.Name != null)
						op.First_Project_Event_Training_Name__c = oli.Training__r.Name;
					else if (oli.Event__r.Name != null)
						op.First_Project_Event_Training_Name__c = oli.Event__r.Name;
					oppsToUpdate.put(oli.OpportunityId, op);

					system.debug('____oppsToUpdate____' + oppsToUpdate);
				}
				system.debug('oli.product_details__r.End_Tier__c: ' + oli.product_details__r.End_Tier__c);
				system.debug('oli.Opportunity.Account.NumberofEmployees: ' + oli.Opportunity.Account.NumberofEmployees);
				if (oli.Opportunity.Type == 'Renewal' && oli.Opportunity.Account.NumberofEmployees != null && oli.product_details__r.End_Tier__c != null){
					if (oli.opportunity.Account.NumberofEmployees > oli.product_details__r.End_Tier__c){
						Opportunity op = new Opportunity(Id = oli.OpportunityId);
						op.Product_Tier_Needs_Verification__c = true;

						if (oppsToUpdate.containsKey(oli.OpportunityId)){
							oppsToUpdate.get(oli.OpportunityId).Product_Tier_Needs_Verification__c = true;
						} else{
							oppsToUpdate.put(oli.OpportunityId, op);
						}
					}

				}
			}
		}

		if (!oppsToUpdate.isEmpty() && oppsToUpdate.size() > 0){
			system.debug('____entered___');
			update oppsToUpdate.values();
		}

		/* for(opportunityLineItem oli : newOli){
		 opportunityIDs.add(oli.Opportunityid);
		 }
		 */

		/*if(!opportunityIDs.isEmpty() && opportunityIDs != null){
		 OppFilteredToUpdate = new Map<ID,Opportunity>([SELECT Id, Name,Total_Products_under_Opportunity__c, Account.Name,Amount,First_Project_Event_Training_Name__c,First_Product_Name__c,(SELECT Id, OpportunityId, Product2Id,Product2.Name, Training__c, Event__c, Projects__c,Type__c,Training__r.Name, Event__r.Name, Projects__r.Name FROM OpportunityLineItems  order by createdDate limit 1) FROM Opportunity WHERE Id =: opportunityIDs and Opportunity.Total_Products_under_Opportunity__c=0]);
		 System.debug('___OppFilteredToUpdate_______'+OppFilteredToUpdate);

		 }
		 */

		//if(!OppFilteredToUpdate.isEmpty() && OppFilteredToUpdate != null){

		/*for(Opportunity opp: OppFilteredToUpdate.values()){
		 if(opp.First_Product_Name__c==null && opp.First_Project_Event_Training_Name__c==null){
		 opp.First_Product_Name__c= OppFilteredToUpdate.get(opp.id).OpportunityLineItems[0].Product2.Name;

		 if(opp.OpportunityLineItems[0].Projects__c !=null){
		 opp.First_Project_Event_Training_Name__c=OppFilteredToUpdate.get(opp.id).OpportunityLineItems[0].Projects__r.Name;
		 }
		 if(opp.OpportunityLineItems[0].Training__c !=null){
		 opp.First_Project_Event_Training_Name__c=OppFilteredToUpdate.get(opp.id).OpportunityLineItems[0].Training__r.Name;
		 }
		 if(opp.OpportunityLineItems[0].Event__c !=null){
		 opp.First_Project_Event_Training_Name__c=OppFilteredToUpdate.get(opp.id).OpportunityLineItems[0].Event__r.Name;
		 }

		 System.debug('___First_Product_Name__c___'+opp.First_Product_Name__c);
		 System.debug('___First_Project_Event_Training_Name__c_______'+opp.First_Project_Event_Training_Name__c);

		 oppsToUpdate.add(opp);

		 }
		 }

		 } */
	}

	public void updateOpportunityOwner(List<OpportunityLineItem> newOli){
		system.debug('Inside Update Owner');
		Set<ID> opportunityIDs = new Set<ID>();
		Map<Id, List<OpportunityLineItem>> oppItems = new Map<Id, List<OpportunityLineItem>>();
		List<Opportunity> updateOpportunity = new List<Opportunity>();
		LF_Membership_Owner__c lfOwners = LF_Membership_Owner__c.getOrgDefaults();

		for (opportunityLineItem oli : newOli){
			opportunityIDs.add(oli.Opportunityid);
		}
		List<OpportunityLineItem> oppLine = [Select Id, OpportunityId, Authorized_Signatory__c, Name, Project__c, Projects__c, Projects__r.Name, Projects__r.Opportunity_Owner__c, Projects__r.OwnerId, Opportunity.RecordType.Name, Opportunity.Type, Opportunity.Project_Name__r.Renewal_Owner__c, Projects__r.Program_Manager_U__c, Projects__r.Renewal_Owner__c, Opportunity.Project_Name__r.Opportunity_Owner__c, Opportunity.Project_Name__r.Program_Manager__c, Opportunity.Project_Name__r.Program_Manager_U__c, Opportunity.Parent_Asset__r.Opportunity__r.Total_Products_under_Opportunity__c, Opportunity.Parent_Asset__r.Opportunity__r.OwnerId, Product2.Name, Opportunity.Account.LF_Membership_Only__c, Opportunity.Parent_Asset__c, Opportunity.Parent_Asset__r.Opportunity__c, Opportunity.Parent_Asset__r.Opportunity__r.Project_Name__c, Opportunity.Parent_Asset__r.Opportunity__r.Project_Name__r.Renewal_Owner__c, Opportunity.Parent_Asset__r.Opportunity__r.Project_Name__r.Opportunity_Owner__c, Opportunity.Parent_Asset__r.Opportunity__r.Project_Name__r.Program_Manager_U__c, Projects__r.Disable_Automation_For_Opportunity_Owner__c, Opportunity.CreatedById
		                                     From OpportunityLineItem
		                                     WHERE OpportunityId IN :opportunityIDs];

		//Map of Opportunity Id and Line Items
		for (OpportunityLineItem oppItem : oppLine){
			if (!oppItems.containskey(oppItem.OpportunityId)){
				oppItems.put(oppItem.OpportunityId, new List<OpportunityLineItem>());
			}
			oppItems.get(oppItem.OpportunityId).add(oppItem);
		}

		Id ownerId;
		Id projectName;
		for (Id opportunityId : oppItems.keySet()){
			ownerId = null;
			projectName = null;
			for (OpportunityLineItem oli : oppItems.get(opportunityId)){
				if (oli.Opportunity.RecordType.Name == 'Membership' && oli.Opportunity.Type == 'New Business'){
					if (oli.Projects__c != null && oli.Projects__r.Disable_Automation_For_Opportunity_Owner__c && oli.Opportunity.CreatedById != Label.Linux_Foundation_User && oli.Projects__r.Name != 'The Linux Foundation'){
                        /* add current user as owner id(unless not join_now user) for projets where disable automation checkbox is checked */
						ownerId = UserInfo.getUserId();
                        projectName = oli.Projects__c;
						break;
					} else{
						if (oli.Projects__c != null && oli.Projects__r.Name != 'The Linux Foundation'){
							ownerId = oli.Projects__r.Opportunity_Owner__c != null ? oli.Projects__r.Opportunity_Owner__c : oli.Projects__r.OwnerId;
							projectName = oli.Projects__c;
							break;
						} else{
							ownerId = oli.Projects__r.Opportunity_Owner__c != null ? oli.Projects__r.Opportunity_Owner__c : oli.Projects__r.OwnerId;
							projectName = oli.Projects__c;
						}
					}
				} else if (oli.Opportunity.RecordType.Name == 'Membership' && oli.Opportunity.Type.contains('Renewal') && oli.Projects__c != null){

					projectName = oli.Projects__c;
					//if project name is LF
					if (oli.Projects__r.Name == 'The Linux Foundation'){
						//if platinum membership
						if (oli.Product2.Name.contains('Platinum')){
							ownerId = lfOwners.Platinum__c;
						} else if (oli.Product2.Name.contains('Associate')){
							ownerId = lfOwners.Associate__c;
						} else if (oli.Product2.Name.contains('Silver') || oli.Product2.Name.contains('Gold')){

							if (oli.Opportunity.Account.LF_Membership_Only__c || (oli.Opportunity.Parent_Asset__c != null && oli.Opportunity.Parent_Asset__r.Opportunity__c != null && oli.Opportunity.Parent_Asset__r.Opportunity__r.Total_Products_under_Opportunity__c == 1)){
								ownerId = oli.Product2.Name.contains('Silver') ? lfOwners.Silver__c : lfOwners.Gold__c;

							} else if (!oli.Opportunity.Account.LF_Membership_Only__c && oli.Opportunity.Parent_Asset__r.Opportunity__r.Total_Products_under_Opportunity__c > 1 && oli.Opportunity.Parent_Asset__c != null && oli.Opportunity.Parent_Asset__r.Opportunity__c != null && oli.Opportunity.Parent_Asset__r.Opportunity__r.Project_Name__c != null){
								if (oli.Opportunity.Parent_Asset__r.Opportunity__r.Project_Name__r.Renewal_Owner__c != null){
									ownerId = oli.Opportunity.Parent_Asset__r.Opportunity__r.Project_Name__r.Renewal_Owner__c;
								} else if (oli.Opportunity.Parent_Asset__r.Opportunity__r.Project_Name__r.Opportunity_Owner__c != null){
									ownerId = oli.Opportunity.Parent_Asset__r.Opportunity__r.Project_Name__r.Opportunity_Owner__c;
								} else if (oli.Opportunity.Parent_Asset__r.Opportunity__r.Project_Name__r.Program_Manager_U__c != null){
									ownerId = oli.Opportunity.Parent_Asset__r.Opportunity__r.Project_Name__r.Program_Manager_U__c;
								}
							}
						}
					}
					if (ownerId == null){
						if (oli.Projects__r.Renewal_Owner__c != null){
							ownerId = oli.Projects__r.Renewal_Owner__c;
						} else if (oli.Projects__r.Opportunity_Owner__c != null){
							ownerId = oli.Projects__r.Opportunity_Owner__c;
						} else if (oli.Projects__r.Program_Manager_U__c != null){
							ownerId = oli.Projects__r.Program_Manager_U__c;
						}
					}
				}

			}
			if (ownerId != null){
				Opportunity opp = new opportunity(id = opportunityId, ownerId = ownerId, Project_Name__c = projectName);
				updateOpportunity.add(opp);
			}
		}

		if (!updateOpportunity.isEmpty()){
			update updateOpportunity;
		}
	}
}