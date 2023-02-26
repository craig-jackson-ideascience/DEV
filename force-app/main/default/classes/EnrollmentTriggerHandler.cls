public class EnrollmentTriggerHandler implements ITriggerHandler{
	public static void BeforeInsert(List<SObject> triggerNew){
		updateEnrollmentName((List<Enrollment__c>)triggerNew);
	}

	public void beforeUpdate(Map<id, SObject> newMap, Map<id, SObject> oldMap){
		updateStatusBasedOnExamStatus((Map<Id, Enrollment__c>)newMap, (Map<Id, Enrollment__c>)oldMap);
	}

	public static void BeforeDelete(Map<Id, Sobject> oldMap){
		//call before delete actions
	}

	public static void afterInsert(Map<Id, SObject> newMap){
		createPurchaseHistoryForPaidEnrollment((Map<Id, Enrollment__c>)newMap, null);
		updateTechnology((Map<Id, Enrollment__c>)newMap, null);
		addContactToCampaign((Map<Id, Enrollment__c>)newMap, null);
		addToTechnologyCampaign((List<Enrollment__c>)newMap.values(), null);
	}

	public static void AfterUpdate(Map<Id, SObject> newMap, Map<Id, Sobject> oldMap){
		updatePurchaseHistory((List<Enrollment__c>)newMap.values(), (Map<Id, Enrollment__c>)oldMap);
		updateTechnology((Map<Id, Enrollment__c>)newMap, (Map<Id, Enrollment__c>)oldMap);
		addContactToCampaign((Map<Id, Enrollment__c>)newMap, (Map<Id, Enrollment__c>)oldMap);
		createPurchaseHistoryForPaidEnrollment((Map<Id, Enrollment__c>)newMap, (Map<Id, Enrollment__c>)oldMap);
		updateStatusofNotStartedEnrollment((Map<Id, Enrollment__c>)newMap, (Map<Id, Enrollment__c>)oldMap);
		addToTechnologyCampaign((List<Enrollment__c>)newMap.values(), (Map<Id, Enrollment__c>)oldMap);
	}

	public static void AfterDelete(Map<Id, Sobject> oldMap){
	}

	public static void AfterUnDelete(Map<Id, Sobject> newMap){
	}

	public Boolean IsDisabled(){
		return false;
	}

	private static void updateEnrollmentName(List<Enrollment__c> triggerNew){
		Set<Id> productContactAndLeadIds = new Set<Id>();
		Set<Id> contactIdSet = new Set<Id>();
		Set<Id> leadIdSet = new Set<Id>();
		Set<string> productCodes = new Set<string>();
		Map<string, string> productCodeVsProductID = new Map<string, string>();

		for (Enrollment__c enrollment : triggerNew){
			if (!String.isBlank(enrollment.Ext_Product_Id__c) && enrollment.Product_Name__c == null){
				string extProductId = enrollment.Ext_Product_Id__c;
				extProductId = extProductId.substringBetween('+');
				system.debug('Product Code is ====>' + extProductId);
				if (!String.isBlank(extProductId)){
					productCodes.add(extProductId);
				}
			}
		}

		if (!productCodes.isEmpty()){
			for (Product2 productRec : [Select ID, ProductCode
			                            From Product2
			                            Where ProductCode IN :productCodes AND IsActive = TRUE]){
				if (!productCodeVsProductID.containsKey(productRec.ProductCode)){
					productCodeVsProductID.put(productRec.ProductCode, productRec.ID);
				}
			}
		}

		for (Enrollment__c enrollment : triggerNew){
			if (!String.isBlank(enrollment.Ext_Product_Id__c) && enrollment.Product_Name__c == null){
				string extProductId = enrollment.Ext_Product_Id__c;
				extProductId = extProductId.substringBetween('+');
				if (productCodeVsProductID.containsKey(extProductId)){
					enrollment.Product_Name__c = productCodeVsProductID.get(extProductId);
				}
			}
		}

		for (Enrollment__c enrollment : triggerNew){
			if (String.isBlank(enrollment.Name) && enrollment.Product_Name__c != null){
				productContactAndLeadIds.add(enrollment.Product_Name__c);
				if (enrollment.Contact_Name__c != null)
					contactIdSet.add(enrollment.Contact_Name__c);
				else if (enrollment.Lead_Name__c != null)
					leadIdSet.add(enrollment.Lead_Name__c);
				// productContactAndLeadIds.add(enrollment.Contact_Name__c != null ? enrollment.Contact_Name__c : enrollment.Lead_Name__c);
			}
		}

		if (!productContactAndLeadIds.isEmpty()){
			Map<Id, Product2> productNameById = new Map<Id, Product2>([SELECT Id, Name
			                                                           FROM Product2
			                                                           WHERE Id IN :productContactAndLeadIds]);
			Map<Id, Contact> contactNameById = new Map<Id, Contact>();
			Map<Id, Lead> leadNameById = new Map<Id, Lead>();
			if (!contactIdSet.isEmpty())
				contactNameById = new Map<Id, Contact>([SELECT Id, Name
				                                        FROM Contact
				                                        WHERE Id IN :contactIdSet]);
			if (!leadIdSet.isEmpty())
				leadNameById = new Map<Id, Lead>([SELECT Id, Name
				                                  FROM Lead
				                                  WHERE Id IN :leadIdSet]);
			for (Enrollment__c enrollment : triggerNew){
				//enrollment.Name = (enrollment.Contact_Name__c != null ? contactNameById.get(enrollment.Contact_Name__c).Name : leadNameById.get(enrollment.Lead_Name__c).Name) + ' ' + productNameById.get(enrollment.Product_Name__c).Name;
				if (enrollment.Product_Name__c != null){
					if (enrollment.Contact_Name__c != null){
						enrollment.Name = contactNameById.get(enrollment.Contact_Name__c).Name + ' ' + productNameById.get(enrollment.Product_Name__c).Name;
					} else if (enrollment.Lead_Name__c != null){
						enrollment.Name = leadNameById.get(enrollment.Lead_Name__c).Name + ' ' + productNameById.get(enrollment.Product_Name__c).Name;
					}
					enrollment.Name = enrollment.Name.length() > 80 ? enrollment.Name.substring(0, 80) : enrollment.Name;
				}
			}
		}
	}

	private static void createPurchaseHistoryForPaidEnrollment(Map<Id, Enrollment__c> newMap, Map<Id, Enrollment__c> oldMap){
		Set<Id> enrollmentIds = new Set<Id>();
		Set<Id> productIds = new Set<Id>();
		for (Enrollment__c enrollment : newMap.values()){
			if (((!enrollment.Is_free__c && enrollment.Source__c == 'Edx') && (oldMap == null || enrollment.Is_free__c != oldMap.get(enrollment.Id).Is_free__c)) || (!enrollment.Is_free__c && enrollment.Source__c == 'SugarCRM' && enrollment.Amount__c != 0 && oldMap == null)){
				enrollmentIds.add(enrollment.Id);
				productIds.add(enrollment.Product_Name__c);
			}
		}
		if (!enrollmentIds.isEmpty()){
			Map<Id, Decimal> productVsPrice = new Map<Id, Decimal>();
			List<PricebookEntry> pbEntries = [SELECT Id, Product2Id, Pricebook2Id, UnitPrice
			                                  FROM PricebookEntry
			                                  WHERE Pricebook2.Name = 'Standard Price Book' AND Product2Id IN :productIds];

			for (PricebookEntry pbEntry : pbEntries){
				productVsPrice.put(pbEntry.Product2Id, pbEntry.UnitPrice);
			}
			System.debug('create purchase');
			createPurchaseHistory(enrollmentIds, productVsPrice);
		}
	}

	public static void createPurchaseHistory(Set<Id> enrollmentIds, Map<Id, Decimal> productVsPrice){
		List<Asset> assets = new List<Asset>();
		List<Enrollment__c> enrollments = new List<Enrollment__c>();
		Map<String, Enrollment__c> enrollmentIdVsenrollmentMap = new Map<String, Enrollment__c>();
		Set<String> trainingNameSet = new Set<String>{'Edx Training', 'Certification', 'E-Learning', 'Instructor Led'};
		List<Training__c> traingingList = [SELECT Id, Name
		                                   FROM Training__c
		                                   WHERE Name IN :trainingNameSet];
		Map<String, Id> trainingNameVsId = new Map<String, Id>();
		for (Training__c training : traingingList){
			if (!trainingNameVsId.containsKey(training.Name))
				trainingNameVsId.put(training.Name, training.Id);
		}
		/* Id edxTrainingId = [SELECT Id FROM Training__c WHERE Name = 'Edx Training' limit 1].Id;
		 Id certificationTrainingId = [SELECT Id FROM Training__c WHERE Name = 'Certification' limit 1].Id;
		 Id eLearningTrainingId = [SELECT Id FROM Training__c WHERE Name = 'E-Learning' limit 1].Id;
		 Id instructorLedTrainingId = [SELECT Id FROM Training__c WHERE Name = 'Instructor Led' limit 1].Id;

		 Id edxRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('EdxTraining').getRecordTypeId();
		 Id individualRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Individual').getRecordTypeId();*/
		Set<String> developerNameSet = new Set<String>{'EdxTraining', 'Individual'};
		Map<String, Id> recordTypeNameVsId = new Map<String, Id>();
		List<RecordType> recordTypeList = [SELECT Id, DeveloperName
		                                   FROM RecordType
		                                   WHERE DeveloperName IN :developerNameSet AND sObjectType = 'Asset'];
		for (RecordType recordType : recordTypeList){
			if (!recordTypeNameVsId.containsKey(recordType.DeveloperName))
				recordTypeNameVsId.put(recordType.DeveloperName, recordType.Id);
		}
		List<Enrollment__c> paidEnrollments = [SELECT Id, Name, Contact_Name__c, Email__c, Enrollment_Date__c, Ext_Enrollment_Id__c, Product_Name__r.Type__c, Ext_Product_Id__c, Lead_Name__c, Lead_Name__r.Name, Product_Name__c, Product_Name__r.Name, Purchase_History__c, Contact_Name__r.Name, Contact_Name__r.IsPersonAccount, Contact_Name__r.AccountId, Source__c, Amount__c
		                                       FROM Enrollment__c
		                                       WHERE ID IN :enrollmentIds];
		for (Enrollment__c enrollment : paidEnrollments){
			Asset asset = new Asset();
			String name = enrollment.Contact_Name__c != null ? enrollment.Contact_Name__r.Name : enrollment.Lead_Name__r.Name;
			if (enrollment.Source__c == 'Edx'){
				asset.Name = name + '-' + 'edx' + '-' + enrollment.Product_Name__r.Name;
				asset.Training__c = trainingNameVsId.get('Edx Training');
				asset.RecordTypeId = recordTypeNameVsId.get('EdxTraining');
				asset.Price = productVsPrice.get(enrollment.Product_Name__c);
			} else if (enrollment.Source__c == 'SugarCRM'){
				asset.Name = name + '-' + enrollment.Product_Name__r.Name;
				asset.RecordTypeId = recordTypeNameVsId.get('Individual');
				asset.Price = enrollment.Amount__c;
				asset.Annual_Full_Price__c = enrollment.Amount__c;
				asset.Training__c = enrollment.Product_Name__r.Type__c == 'Certification' ? trainingNameVsId.get('Certification') : (enrollment.Product_Name__r.Type__c == 'E-Learning' ? trainingNameVsId.get('E-Learning') : trainingNameVsId.get('Instructor Led'));
			}

			if (enrollment.Contact_Name__r.IsPersonAccount){
				asset.AccountId = enrollment.Contact_Name__r.AccountId;
			}
			asset.ContactId = enrollment.Contact_Name__c;
			asset.Ext_Enrollment_Id__c = enrollment.Ext_Enrollment_Id__c;
			asset.Status = 'Purchased';
			asset.PurchaseDate = Date.valueOf(enrollment.Enrollment_Date__c);
			asset.InstallDate = Date.valueOf(enrollment.Enrollment_Date__c);
			asset.Quantity = 1;
			asset.Skip_NetSuite_Sync__c = true;
			asset.SalesOrderStatus__c = 'Not synced to Netsuite';
			asset.Product2Id = enrollment.Product_Name__c;
			asset.Auto_Renew__c = false;
			assets.add(asset);
			enrollmentIdVsenrollmentMap.put(asset.Ext_Enrollment_Id__c, enrollment);
		}
		if (!assets.isEmpty()){
			insert assets;
			for (Asset asset : assets){
				if (enrollmentIdVsenrollmentMap.containsKey(asset.Ext_Enrollment_Id__c)){
					enrollmentIdVsenrollmentMap.get(asset.Ext_Enrollment_Id__c).Purchase_History__c = asset.Id;
				}
			}
			if (!enrollmentIdVsenrollmentMap.isEmpty()){
				update enrollmentIdVsenrollmentMap.values();
			}
		}
	}

	private static void updatePurchaseHistory(List<Enrollment__c> enrollments, Map<Id, Enrollment__c> oldMap){
		List<Asset> assets = new List<Asset>();
		for (Enrollment__c enrollment : enrollments){
			if (enrollment.Contact_Name__c != null && oldMap.get(enrollment.Id).Contact_Name__c != enrollment.Contact_Name__c && enrollment.Purchase_History__c != null){
				assets.add(new Asset(Id = enrollment.Purchase_History__c, ContactId = enrollment.Contact_Name__c));
			}
		}
		if (!assets.IsEmpty()){
			update assets;
		}
	}

	private static void updateTechnology(Map<Id, Enrollment__c> newMap, Map<Id, Enrollment__c> oldMap){
		Enrollment__c oldEnrollment = new Enrollment__c();
		Set<Id> enrollmentIds = new Set<Id>();
		Map<Id, Contact> contactsToBeUpdated = new Map<Id, Contact>();
		Map<Id, Lead> leadsToBeUpdated = new Map<Id, Lead>();
		Boolean hasChange = false;
		for (Enrollment__c enrollment : newMap.values()){
			if (oldMap != null){
				oldEnrollment = oldMap.get(enrollment.Id);
			}
			if (oldMap == null || ((enrollment.Lead_Name__c != null && enrollment.Lead_Name__c != oldEnrollment.Lead_Name__c) || (enrollment.Contact_Name__c != null && enrollment.Contact_Name__c != oldEnrollment.Contact_Name__c))){
				enrollmentIds.add(enrollment.Id);
			}
		}
		if (!enrollmentIds.isEmpty()){
			for (Enrollment__c enrollment : [SELECT Id, Lead_Name__c, Lead_Name__r.Technology__c, Contact_Name__c, Contact_Name__r.Technology__c, Product_Name__r.Technology__c, Product_Name__c
			                                 FROM Enrollment__c
			                                 WHERE ID IN :enrollmentIds AND Product_Name__r.Technology__c != null]){
				List<String> productTechnology = enrollment.Product_Name__r.Technology__c.split(';');
				hasChange = false;
				//lead is not null
				if (enrollment.Lead_Name__c != null){
					String leadTechnology;
					//if it is already added to map
					if (leadsToBeUpdated.containsKey(enrollment.Lead_Name__c)){
						leadTechnology = leadsToBeUpdated.get(enrollment.Lead_Name__c).Technology__c;
					} else{
						leadTechnology = enrollment.Lead_Name__r.Technology__c == null ? '' : enrollment.Lead_Name__r.Technology__c;
					}
					//for existing lead if it doesn't end with ; add ;
					if (String.isNotEmpty(leadTechnology) && !leadTechnology.endsWith(';')){
						leadTechnology += ';';
					}
					for (String technology : productTechnology){
						if (!leadTechnology.contains(technology)){
							leadTechnology += technology + ';';
							hasChange = true;
						}
					}
					if (hasChange){
						leadsToBeUpdated.put(enrollment.Lead_Name__c, new Lead(Id = enrollment.Lead_Name__c, Technology__c = leadTechnology));
					}
				}
				//contact is not null
				if (enrollment.Contact_Name__c != null){
					String contactTechnology;
					//if it is already added to map
					if (contactsToBeUpdated.containsKey(enrollment.Contact_Name__c)){
						contactTechnology = contactsToBeUpdated.get(enrollment.Contact_Name__c).Technology__c;
					} else{
						contactTechnology = enrollment.Contact_Name__r.Technology__c == null ? '' : enrollment.Contact_Name__r.Technology__c;
					}
					//for existing contact if it doesn't end with ; add ;
					if (String.isNotEmpty(contactTechnology) && !contactTechnology.endsWith(';')){
						contactTechnology += ';';
					}
					for (String technology : productTechnology){
						if (!contactTechnology.contains(technology)){
							contactTechnology += technology + ';';
							hasChange = true;
						}
					}
					if (hasChange){
						contactsToBeUpdated.put(enrollment.Contact_Name__c, new Contact(Id = enrollment.Contact_Name__c, Technology__c = contactTechnology));
					}
				}
			}
			if (!contactsToBeUpdated.IsEmpty()){
				update contactsToBeUpdated.values();
			}
			if (!leadsToBeUpdated.IsEmpty()){
				update leadsToBeUpdated.values();
			}
		}
	}

	//method to add contact or lead of enrollment as campaignmember
	public static void addContactToCampaign(Map<Id, Enrollment__c> newMap, Map<Id, Enrollment__c> oldMap){
		Map<String, Map<String, List<Enrollment__c>>> parentCampaignVsproductCodeVsEnrollment = new Map<String, Map<String, List<Enrollment__c>>>();
		Map<String, Set<String>> parentCampaignVSProductCodes = new Map<String, Set<String>>();
		Set<String> productCodes = new Set<String>();
		Set<Id> leadContactIdSet = new Set<Id>();
		Map<String, List<Enrollment__c>> productCodeVsEnrollment = new Map<String, List<Enrollment__c>>();
		Map<Enrollment__c, String> enrollmentVsProductCode = new Map<Enrollment__c, String>();
		Set<String> parentCampaignNames = new Set<String>();
		//Iterate through each record
		for (Enrollment__c enrollment : newMap.values()){

			if ((enrollment.isBootcampbundle__c || enrollment.Parent_Product_Name__c != null) && (oldmap == null || ((oldMap.get(enrollment.Id).isBootcampbundle__c != enrollment.isBootcampbundle__c) || oldMap.get(enrollment.Id).Certification_AchievementDate__c != enrollment.Certification_AchievementDate__c || oldMap.get(enrollment.Id).Parent_Product_Name__c != enrollment.Parent_Product_Name__c || oldMap.get(enrollment.Id).Completion_Date__c != enrollment.Completion_Date__c || ((oldMap.get(enrollment.Id).Status__c != enrollment.Status__c) && enrollment.Status__c == 'Completed'))) && enrollment.Product_Code__c != null && enrollment.Enrollment_Date__c != null && (enrollment.Contact_Name__c != null || enrollment.Lead_Name__c != null)){

				//store parent product name
				String parentCampaignName = enrollment.Parent_Product_Name__c != null && enrollment.Is_Parent_Product_Bootcamp_Campaign__c ? enrollment.Parent_Product_Name__c : '';
				//if string is not blank
				if (String.isNotBlank(parentCampaignName)){

					//add parentCampaign and product codes to map
					if (!parentCampaignVSProductCodes.containsKey(parentCampaignName)){
						parentCampaignVSProductCodes.put(parentCampaignName, new Set<String>());
					}
					parentCampaignVSProductCodes.get(parentCampaignName).add(enrollment.Product_Code__c);

					productCodes.add('%' + enrollment.Product_Code__c + '%');
					String status = enrollment.Status__c == 'Completed' ? 'Completed' : 'Enrolled';

					//map to store enrollment and a key to get camapign based on it.
					enrollmentVsProductCode.put(enrollment, parentCampaignName + ' ' + enrollment.Product_Code__c + ' ' + status);

					if (enrollment.Contact_Name__c != null)
						leadContactIdSet.add(enrollment.Contact_Name__c);
					else if (enrollment.Lead_Name__c != null)
						leadContactIdSet.add(enrollment.Lead_Name__c);
				}
			}
		}


		System.debug('parentCampaignVSProductCodes ' + parentCampaignVSProductCodes);
		if (!parentCampaignVSProductCodes.isEmpty()){
			Map<String, CampaignMember> campaignMemberList = Utility.addCampaignMember(parentCampaignVSProductCodes, productCodes, enrollmentVsProductCode, leadContactIdSet);
			if (!campaignMemberList.isEmpty()){
				//upsert campaignmembers
				upsert campaignMemberList.values();
			}
		}
	}

	public static void updateStatusofNotStartedEnrollment(Map<Id, Enrollment__c> newMap, Map<Id, Enrollment__c> oldMap){
		Set<Id> productIds = new Set<Id>();
		Set<Id> contactIds = new Set<Id>();
		for (Enrollment__c enrollment : newMap.values()){
			if ((enrollment.Status__c == 'Completed' || enrollment.Status__c == 'Expired' || enrollment.Status__c == 'Revoked' || enrollment.Status__c == 'Not Certified') && enrollment.Status__c != oldMap.get(enrollment.Id).Status__c){
				productIds.add(enrollment.Product_Name__c);
				contactIds.add(enrollment.Contact_Name__c);
			}
		}
		if (!productIds.isEmpty()){
			List<String> statusList = new List<String>{'Not Started', 'Enrolled'};
			Map<String, Enrollment__c> existingEnrollmentByUserAndCourse = new Map<String, Enrollment__c>();
			for (Enrollment__c enrollment : [SELECT Id, Contact_Name__c, Product_Name__c, Status__c
			                                 FROM Enrollment__c
			                                 WHERE Status__c In :statusList AND Contact_Name__c IN :contactIds AND Product_Name__c IN :productIds
			                                 ORDER BY Enrollment_Date__c]){

				if (!existingEnrollmentByUserAndCourse.containsKey(enrollment.Contact_Name__c + ' ' + enrollment.Product_Name__c)){
					enrollment.Status__c = 'Enrolled';
					existingEnrollmentByUserAndCourse.put(enrollment.Contact_Name__c + ' ' + enrollment.Product_Name__c, enrollment);
				}

			}
			System.debug('existingEnrollmentByUserAndCourse' + existingEnrollmentByUserAndCourse);
			if (!existingEnrollmentByUserAndCourse.isEmpty()){
				update existingEnrollmentByUserAndCourse.values();
			}
		}
	}

	public static void updateStatusBasedOnExamStatus(Map<Id, Enrollment__c> newMap, Map<Id, Enrollment__c> oldMap){
		List<String> examStatusList = new List<String>{'Invalidated', 'Cancelled', 'No Pass'};
		for (Enrollment__c enrollment : newMap.values()){
			if (enrollment.Exam_Status__c != oldMap.get(enrollment.Id).Exam_Status__c){
				if (enrollment.Exam_Status__c == 'Pass')
					enrollment.Status__c = 'Completed';
				else if (examStatusList.contains(enrollment.Exam_Status__c))
					enrollment.Status__c = 'Not Certified';
			}
		}
	}

	private static void addToTechnologyCampaign(List<Enrollment__c> newEnrollments, Map<Id, Enrollment__c> oldMap){
		Set<Id> enrollmentIds = new Set<Id>();
		Set<Id> leadContactIdSet = new Set<Id>();
		for (Enrollment__c enrollment : newEnrollments){
			if (enrollment.Source__c != 'Edx' && enrollment.Product_Name__c != null && (oldMap == null || enrollment.Product_Name__c != oldMap.get(enrollment.Id).Product_Name__c)){
				enrollmentIds.add(enrollment.Id);
				if (enrollment.Contact_Name__c != null)
					leadContactIdSet.add(enrollment.Contact_Name__c);
				else if (enrollment.Lead_Name__c != null)
					leadContactIdSet.add(enrollment.Lead_Name__c);
			}
		}
		if (!enrollmentIds.IsEmpty()){
			List<Enrollment__c> enrollments = [SELECT Id, Product_Name__c, Product_Name__r.Technology__c, Contact_Name__c, Lead_Name__c
			                                   FROM Enrollment__c
			                                   WHERE ID IN :enrollmentIds AND Product_Name__r.Technology__c != null];

			Map<String, Id> campaignIdByTechnology = getTechnologyCampaigns();
			if (!campaignIdByTechnology.IsEmpty()){
				Set<Id> campaignIds = new Set<Id>(campaignIdByTechnology.values());
				List<CampaignMember> campaignMemberList = new List<CampaignMember>();
				Map<Id, Set<Id>> alreadyAddedMember = new Map<Id, Set<Id>>();
				/* for(Id campId : campaignIdByTechnology.values()){
				 campaignIds.add(campId);
				 }  */
				Map<Id, Map<Id, CampaignMember>> existingCampaignMembers = Utility.getExistingCampaignMembers(campaignIds, leadContactIdSet);
				for (Enrollment__c enrollment : enrollments){
					if (String.isNotBlank(enrollment.Product_Name__r.Technology__c)){
						Id enrollmentLeadContactId = enrollment.Contact_Name__c != null ? enrollment.Contact_Name__c : enrollment.Lead_Name__c;
						for (String technology : enrollment.Product_Name__r.Technology__c.split(';')){
							//for each technology check if campaign exists or not
							if (campaignIdByTechnology.containsKey(technology)){
								//if campaign exits and the lead or contact is not already added to campign add it
								Id campaignId = campaignIdByTechnology.get(technology);
								if ((!existingCampaignMembers.containsKey(campaignId) || !existingCampaignMembers.get(campaignId).containsKey(enrollmentLeadContactId)) && (!alreadyAddedMember.containsKey(campaignId) || !alreadyAddedMember.get(campaignId).contains(enrollmentLeadContactId))){
									//create campaign Member
									CampaignMember member = new CampaignMember();
									member.CampaignId = campaignId;
									if (String.isNotBlank(enrollment.Contact_Name__c)){
										member.ContactId = enrollment.Contact_Name__c;
									} else{
										member.LeadId = enrollment.Lead_Name__c;
									}
									campaignMemberList.add(member);
									if (!alreadyAddedMember.containsKey(campaignId)){
										alreadyAddedMember.put(campaignId, new Set<Id>());
									}
									alreadyAddedMember.get(campaignId).add(enrollmentLeadContactId);
								}
							}

						}
					}
				}

				if (!campaignMemberList.IsEmpty()){
					insert campaignMemberList;
				}
			}

		}
	}

	private static Map<String, Id> getTechnologyCampaigns(){
		Map<String, Id> campaignIdByTechnology = new Map<String, Id>();
		for (Campaign camp : [select Id, Name, Technology__c
		                      from Campaign
		                      WHERE Training_Technology_List__c = true AND LF_Training__c = true AND Type = 'Training' AND IsActive = true AND Technology__c != '']){
			campaignIdByTechnology.put(camp.Technology__c, camp.Id);
		}
		return campaignIdByTechnology;
	}
}