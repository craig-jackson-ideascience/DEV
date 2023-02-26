//Test Class- Covered from - Test_Utility,CventCalloutUtility_Test,EnrollmentToCampaignMemberBatchTest
public class Utility{
	public static Set<String> contactExternalIdSet = new Set<String>{'edx_user_id__c', 'TILBP__TIID__c', 'Username__c'};
	public static String linuxFoundationId{
		get{
			if (String.isBlank(linuxFoundationId)){
				linuxFoundationId = [SELECT ID
				                     FROM Project__c
				                     WHERE Name = 'The Linux Foundation'].Id;
			}
			return linuxFoundationId;
		}

		set;
	}

	public static String corporateRecordTypeId{
		get{
			if (String.isBlank(corporateRecordTypeId)){
				corporateRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Corporate Training').getRecordTypeId();
			}
			return corporateRecordTypeId;
		}

		set;
	}

	/**
	 * Get all the members' Email Address
	 *
	 * @param groupName
	 *
	 * @return list of email address
	 */
	public static List<String> getEmailAddresses(String groupName){
		Set<Id> userIds = new Set<Id>();
		List<String> mailToAddresses = new List<String>();
		Group grp = [SELECT (SELECT UserOrGroupId
		                     FROM GroupMembers)
		             FROM Group
		             WHERE DeveloperName = :groupName];
		for (GroupMember gm : grp.GroupMembers){
			userIds.add(gm.UserOrGroupId);
		}
		for (User user : [SELECT Email
		                  FROM User
		                  WHERE Id IN :userIds AND IsActive = true]){
			mailToAddresses.add(user.Email);
		}
		return mailToAddresses;
	}

	public static List<Contact> updateTechnologyOnContact(Contact objContact, List<String> sObjectTechnology, List<String> strlstContact){
		List<Contact> lstContact = new List<Contact>();
		system.debug('objContact--->' + objContact);
		if (sObjectTechnology != null){
			system.debug('Inside');
			string strContact = string.join(strlstContact, ';'); //Convert contact List of technology into single string
			string strsObject = string.join(sObjectTechnology, ';'); // Convert sObject List of technology into single string

			// For Contact Technology
			List<String> duplicateContactTechno = new List<String>(new Set<String>(strContact.split(';'))); //merge duplicate contact technology and add into List
			String uniqueContactTechno = String.join(duplicateContactTechno, ';'); // Unique value List convert into string

			//For sObject technology
			List<String> duplicatesObjectTechnology = new List<String>(new Set<String>(strsObject.split(';'))); //merge duplicate sObject technology and add into List
			String uniquesObjectTechnology = String.join(duplicatesObjectTechnology, ';'); // Unique value List convert into string

			//For find Unique value technology from Contact and sObject
			string duplicateContactTechnology = uniqueContactTechno + ';' + uniquesObjectTechnology; // Concat both technology
			List<String> duplicatesContactTechnology = new List<String>(new Set<String>(duplicateContactTechnology.split(';'))); // merge duplicate value
			string UniqueContactTechnology = String.join(duplicatesContactTechnology, ';'); // Find unique techonlogy for update on contact

			//For Update Contact with technology
			if (!uniqueContactTechno.contains(uniquesObjectTechnology)){
				if (objContact != null){
					objContact.Technology__c = UniqueContactTechnology;
					lstContact.add(objContact);

				}

			}
		}
		system.debug('lstContact' + lstContact);
		return lstContact;
	}

	public static List<Lead> updateLeadTechnology(Lead objLead, List<String> sObjectTechnology, List<String> strlstLead){
		List<Lead> lstLead = new List<Lead>();
		if (sObjectTechnology != null){
			string strLead = string.join(strlstLead, ';'); //Convert Lead List of technology into single string
			string strsObject = string.join(sObjectTechnology, ';'); // Convert sObject List of technology into single string

			//For lead Technology
			List<String> duplicateLeadTechno = new List<String>(new Set<String>(strLead.split(';')));  //merge duplicate Lead technology and add into List
			String uniqueLeadTechno = String.join(duplicateLeadTechno, ';'); // Unique value List convert into string

			//For sObject technology
			List<String> duplicatesObjectTechnology = new List<String>(new Set<String>(strsObject.split(';'))); //merge duplicate sObject technology and add into List
			String uniquesObjectTechnology = String.join(duplicatesObjectTechnology, ';'); // Unique value List convert into string

			//For find Unique value technology from Lead and sObject
			string duplicateLeadTechnology = uniqueLeadTechno + ';' + uniquesObjectTechnology; // Concat both technology
			List<String> duplicatesLeadTechnology = new List<String>(new Set<String>(duplicateLeadTechnology.split(';'))); // merge duplicate value
			string UniqueLeadTechnology = String.join(duplicatesLeadTechnology, ';'); // Find unique techonlogy for update on contact


			//For Update Lead with technology
			if (!uniqueLeadTechno.contains(uniquesObjectTechnology)){
				if (objLead != null){
					objLead.Technology__c = UniqueLeadTechnology;
					lstLead.add(objLead);

				}

			}
		}
		return lstLead;
	}

	public static List<String> getPickListValuesIntoList(String object_name, String field_name){
		List<String> values = new List<String>{};
		List<String> types = new List<String>{object_name};
		List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types);
		for (Schema.DescribeSobjectResult res : results){
			for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()){
				values.add(entry.getValue());
			}
		}
		return values;
	}

	public static Map<String, List<String>> getDependentPicklistValues(DescribeSObjectResult describeResult, string contrfieldApiName, string depfieldApiName){
		String controllingField = contrfieldApiName.toLowerCase();
		String dependentField = depfieldApiName.toLowerCase();

		Map<String, List<String>> objResults = new Map<String, List<String>>();

		//Schema.sObjectType objType = objDetail.getSObjectType();
		if (describeResult == null){
			return objResults;
		}

		Map<String, Schema.SObjectField> objFieldMap = describeResult.fields.getMap();

		if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
			return objResults;
		}

		Schema.SObjectField theField = objFieldMap.get(dependentField);
		Schema.SObjectField ctrlField = objFieldMap.get(controllingField);

		List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
		List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
		List<String> controllingValues = new List<String>();

		for (Schema.PicklistEntry ple : contrEntries){
			String label = ple.getLabel();
			objResults.put(label, new List<String>());
			controllingValues.add(label);
		}

		for (PicklistEntryWrapper plew : depEntries){
			String label = plew.label;
			String validForBits = base64ToBits(plew.validFor);
			for (Integer i = 0; i < validForBits.length(); i++){
				String bit = validForBits.mid(i, 1);
				if (bit == '1'){
					objResults.get(controllingValues.get(i)).add(label);
				}
			}
		}
		return objResults;
	}

	public static String decimalToBinary(Integer val){
		String bits = '';
		while (val > 0){
			Integer remainder = Math.mod(val, 2);
			val = Integer.valueOf(Math.floor(val / 2));
			bits = String.valueOf(remainder)+bits;
		}
		return bits;
	}

	public static String base64ToBits(String validFor){
		if (String.isEmpty(validFor))
			return '';
		String validForBits = '';

		for (Integer i = 0; i < validFor.length(); i++){
			String thisChar = validFor.mid(i, 1);
			Integer val = base64Chars.indexOf(thisChar);
			String bits = decimalToBinary(val).leftPad(6, '0');
			validForBits += bits;
		}

		return validForBits;
	}

	private static final String base64Chars = '' + 
											  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + 
											  'abcdefghijklmnopqrstuvwxyz' + 
											  '0123456789+/';
	private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs){
		return (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
	}

	/**
	 * getFieldNames : Returns the Map which contains the string - comma seperated field API names
	 *  and the List - field API names which are checkbox fields
	 * @param schemaFieldMap  the schema map from which we can get the field api names of the Schema and
	 Currently it is either the Lead or contact schemafieldMap.
	 */
	public Map<String, Object> getFieldNames(Map<String, Schema.SObjectField> schemaFieldMap){
		Map<String, Object> returnMap = new Map<String, Object>();
		List<String> checkBoxFieldsString = new List<String>();
		String objectFieldNames = 'SELECT ';
		for (Schema.sObjectField fieldName : schemaFieldMap.values()){
			if (fieldName.getDescribe().isUpdateable()){
				objectFieldNames += fieldName + ',';
				if (fieldName.getDescribe().getType() == Schema.DisplayType.Boolean){
					checkBoxFieldsString.add(fieldName.getDescribe().getName());
				}
			}

		}
		objectFieldNames = objectFieldNames.removeEnd(',');
		returnMap.put('CheckboxFields', checkBoxFieldsString);
		returnMap.put('FieldNames', objectFieldNames);
		return returnMap;
	}

	public static String getOrgWideEmailAddress(){
		return [SELECT ID
		        FROM OrgWideEmailAddress
		        WHERE Address = 'salesops@linuxfoundation.org'].Id;
	}

	public class PicklistEntryWrapper{
		public String active{ get; set; }

		public String defaultValue{ get; set; }

		public String label{ get; set; }

		public String value{ get; set; }

		public String validFor{ get; set; }

		public PicklistEntryWrapper(){
		}
	}

	//method to add campaign member
	public static Map<String, CampaignMember> addCampaignMember(Map<String, Set<String>> parentCampaignVSProductCodes, Set<String> productCodes, Map<Enrollment__c, String> enrollmentVsProductCode, Set<Id> leadContactIdSet){
		Map<String, CampaignMember> campaignMemberList = new Map<String, CampaignMember>();
		Set<Id> campaignIds = new Set<Id>();

		//get campaigns
		Map<String, Map<String, Campaign>> productCodeVsCampaignId = getCampaigns(parentCampaignVSProductCodes, productCodes, campaignIds);

		if (!productCodeVsCampaignId.IsEmpty()){

			//get existing campaign Members for the campaign
			Map<Id, Map<Id, CampaignMember>> existingMembersByCampaignId = getExistingCampaignMembers(campaignIds, leadContactIdSet);
			System.debug('existingMembersByCampaignId ' + existingMembersByCampaignId.size()+' ' + existingMembersByCampaignId);

			//for each enrollment process
			for (Enrollment__c enrollment : enrollmentVsProductCode.keyset()){
				String productCode = enrollmentVsProductCode.get(enrollment);
				if (productCodeVsCampaignId.containsKey(productCode)){
					Map<String, Campaign> campaignMap = productCodeVsCampaignId.get(productCode);

					for (String key : campaignMap.keySet()){
						List<String> dates = key.Split(' ');

						/**
						 * StartDate : dates[0] -  must not be null
						 * EndDate : dates[2] - If not null then check whether the enrollment date falls within startdate and enddate
						 * and if it is null then just add the member
						 */

						//since list's 0 and 2 element contains startdate and enddate
						if (String.isNotBlank(dates[0]) && ((dates.size() > 3 && Date.valueOf(dates[0]) <= enrollment.Enrollment_Date__c.Date() && Date.valueOf(dates[2]) >= enrollment.Enrollment_Date__c.Date()) || dates.size() == 3)){

							Campaign campaign = campaignMap.get(key);

							//get existing members
							Map<Id, CampaignMember> existingMembersById = new Map<Id, CampaignMember>();
							if (existingMembersByCampaignId.containsKey(campaign.Id)){
								existingMembersById = existingMembersByCampaignId.get(campaign.Id);
							}

							//get existing members of parent campaign
							Map<Id, CampaignMember> existingMembersOfParentCampaign = new Map<Id, CampaignMember>();
							if (existingMembersByCampaignId.containsKey(campaign.ParentId)){
								existingMembersOfParentCampaign = existingMembersByCampaignId.get(campaign.ParentId);
							}

							//add campaign member to both child and parent campaign
							CampaignMember member = new CampaignMember();
							CampaignMember memberOfParentCampaign = new CampaignMember();
							Id enrollmentLeadContactId;
							if (String.isNotBlank(enrollment.Contact_Name__c)){
								member.ContactId = enrollment.Contact_Name__c;
								memberOfParentCampaign.ContactId = enrollment.Contact_Name__c;
								enrollmentLeadContactId = enrollment.Contact_Name__c;
							} else{
								member.LeadId = enrollment.Lead_Name__c;
								memberOfParentCampaign.LeadId = enrollment.Lead_Name__c;
								enrollmentLeadContactId = enrollment.Lead_Name__c;
							}

							if (enrollment.Certification_AchievementDate__c <= Date.TODAY()){
								member.Status = 'Passed';
								memberOfParentCampaign.Status = 'Passed';
							} else if (enrollment.Completion_Date__c <= Date.TODAY()){
								member.Status = 'Completed';
								memberOfParentCampaign.Status = 'Completed';
							}

							//member of child campaign
							member.CampaignId = campaign.Id;
							if (existingMembersById.containsKey(enrollmentLeadContactId)){
								member.Id = existingMembersById.get(enrollmentLeadContactId).Id;
							}

							//member of parent campaign
							memberOfParentCampaign.CampaignId = campaign.ParentId;
							if (existingMembersOfParentCampaign.containsKey(enrollmentLeadContactId)){
								memberOfParentCampaign.Id = existingMembersOfParentCampaign.get(enrollmentLeadContactId).Id;
							}

							campaignMemberList.put(enrollmentLeadContactId + '_' + campaign.Id, member);
							campaignMemberList.put(enrollmentLeadContactId + '_' + campaign.ParentId, memberOfParentCampaign);

						}

					}
				}
			}


			System.debug('campaignMemberList' + campaignMemberList.size());

		}
		return campaignMemberList;
	}

	//method to getcampaign
	public static Map<String, Map<String, Campaign>> getCampaigns(Map<String, Set<String>> parentCampaignVSProductCodes, Set<String> productCodes, Set<Id> campaignIds){
		Map<String, Map<String, Campaign>> productCodeVsCampaign = new Map<String, Map<String, Campaign>>();

		for (Campaign campaign : [SELECT Id, Name, ParentId, Parent.Name, Parent.StartDate, Parent.EndDate, Parent.Product__c, Parent.is_Completed__c
		                          FROM Campaign
		                          WHERE Type = 'Training' AND IsActive = true AND Parent.Product__c IN :parentCampaignVSProductCodes.keyset() AND Name LIKE :productCodes]){

			if (parentCampaignVSProductCodes.containsKey(campaign.Parent.Product__c)){
				for (String productCode : parentCampaignVSProductCodes.get(campaign.Parent.Product__c)){
					//Create map of ProductcodeVsCampaign
					if (campaign.Name.Contains(productCode)){
						String status = campaign.Parent.is_Completed__c ? 'Completed' : 'Enrolled';

						if (!productCodeVsCampaign.containsKey(campaign.Parent.Product__c + ' ' + productCode + ' ' + status)){
							productCodeVsCampaign.put(campaign.Parent.Product__c + ' ' + productCode + ' ' + status, new Map<String, Campaign>());
						}

						productCodeVsCampaign.get(campaign.Parent.Product__c + ' ' + productCode + ' ' + status).put(campaign.Parent.StartDate + ' ' + campaign.Parent.EndDate, Campaign);
						campaignIds.add(Campaign.Id);
						campaignIds.add(Campaign.ParentId);
						break;
					}
				}
			}
		}
		return productCodeVsCampaign;
	}

	//method to get existing campaignmember of passed campaigns
	public static Map<Id, Map<Id, CampaignMember>> getExistingCampaignMembers(Set<Id> campaignIds, Set<Id> leadContactIdSet){
		Map<Id, Map<Id, CampaignMember>> campaignMembersById = new Map<Id, Map<Id, CampaignMember>>();
		for (CampaignMember member : [SELECT Id, CampaignId, Email, ContactId, LeadId, Status
		                              FROM CampaignMember
		                              WHERE CampaignId IN :campaignIds AND (ContactId IN :leadContactIdSet OR LeadId IN :leadContactIdSet)]){
			if (!campaignMembersById.containsKey(member.CampaignId)){
				campaignMembersById.put(member.CampaignId, new Map<Id, CampaignMember>());
			}
			Id leadContactId = member.ContactId != null ? member.ContactId : member.LeadId;
			campaignMembersById.get(member.CampaignId).put(leadContactId, member);
		}
		return campaignMembersById;
	}

	//method to get renewal Close Date
	public Date getRenewalCloseDate(Date endDate, Integer days){
		Date closeDate;
		Integer year = endDate.year();
		String monthAndDate = Label.Year_end_Renewal_date.substringAfter('-');
		System.debug('monthAndDate ' + monthAndDate);
		System.debug('days ' + days);
		Date renewalCloseDate = Date.valueOf(year + '-' + monthAndDate);
		

        if (Date.valueOf((year + '-11-19')) <= endDate && Date.valueOf((year + '-11-30')) >= endDate){
			closedate = renewalCloseDate - 1;

        } else if (Date.valueOf((year + '-12-01')) <= endDate && Date.valueOf((year + '-12-31')) >= endDate){
            closedate =  renewalCloseDate;
        }else{
            closedate = endDate - days;
        }
        
        return closedate;
	}

	public String getFieldTypeName(String objectApiName, String fieldApiName){
		return Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getType().name().toupperCase();
	}

	public Object typeCastFromString(String typeName, Object value){
		switch on typeName{

			when 'DATE'{
				// when block 1
				return Date.valueOf(value);
			}
			when 'BOOLEAN'{
				// when block 2
				return Boolean.valueOf(value);
			}
			when 'INTEGER'{
				// when block 3
				return Integer.valueOf(value);
			}
			when 'DOUBLE'{
				// default block, optional
				return Double.valueOf(value);
			}
			when 'STRING'{
				// default block, optional
				return String.valueOf(value);
			}
			when else{
				return value;
			}
		}
	}

	public void assignValuesToField(SObject sobjectInstance, String salesforceField, Object cventValue, String objectName){

		String typeName = getFieldTypeName(objectName, salesforceField);
		system.debug(!(cventValue instanceof String));
		Object fieldValue = typeName != 'STRING' || !(cventValue instanceof String) ? typeCastFromString(typeName, cventValue) : cventValue;
		sobjectInstance.put(salesforceField, fieldValue);
	}
}