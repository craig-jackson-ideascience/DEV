/********************************************************
 * Created by: Martand Atrey @ CloudRoute Solutions
 * Created Date: 14-10-2019.
 * Description: SendContractDocuSignExtension
 ********************************************************/
public with sharing class SendContractDocuSignExtension{
	Id oppId;

	public String redirectPreviewURL{ get; set; }

	public String envelopeId{ get; set; }

	public Boolean enableSend{ get; set; }

	public String authSignatoryEmail{ get; set; }

	public String pdfFileName{ get; set; }

	public Map<Id, OpportunityLineItem> oppLineItems;
	public SendContractDocuSignExtension(ApexPages.StandardController std){
		oppId = (Id)std.getId();
		System.debug(oppId + '====> oppId');
		enableSend = false;
	}

	public PageReference processDocusign(){
		oppLineItems = new Map<Id, OpportunityLineItem>([Select Id, Projects__r.Name, Name, Opportunity.AccountID, Product2.Name, Start_Date__c, End_Date__c
		                                                 From OpportunityLineItem
		                                                 WHERE opportunityId = :oppId AND Projects__r.Membership_Roles_Not_Required__c = false
		                                                 ORDER BY Projects__r.Name]);
		if (!oppLineItems.isEmpty()){
			//store all project roles for each oli
			Map<String, List<Project_Role__c>> oliVsProjectRole = new Map<String, List<Project_Role__c>>();

			//Get All Project Roles
			Map<String, Map<String, Project_Role__c>> oliWithProjectRole = new Map<String, Map<String, Project_Role__c>>();

			//GET EXISTING PROJECT ROLES FOR QUALIFIED OPPORTUNITY LINE ITEMS
			for (Project_Role__c pRole : [SELECT Id, Asset__c, Contact__c, Contact__r.Email, Role__c, Status__c, PrimaryContact__c, Start_Date__c, End_Date__c, Opportunity_Line_Item__c
			                              FROM Project_Role__c
			                              WHERE Opportunity_Line_Item__c != null AND Opportunity__c = :oppId AND contact__c != null AND Status__c != 'Inactive' AND (Role__c = 'Billing Contact' OR Role__c = 'Representative/Voting Contact' OR Role__c = 'Authorized Signatory')]){
				if (oliWithProjectRole.containsKey(pRole.Opportunity_Line_Item__c)){
					Map<String, Project_Role__c> mapOfProjectRole = oliWithProjectRole.get(pRole.Opportunity_Line_Item__c);
					mapOfProjectRole.put(pRole.Role__c, pRole);
					oliWithProjectRole.put(pRole.Opportunity_Line_Item__c, mapOfProjectRole);
				} else{
					Map<String, Project_Role__c> mapOfProjectRole = new Map<String, Project_Role__c>();
					mapOfProjectRole.put(pRole.Role__c, pRole);
					oliWithProjectRole.put(pRole.Opportunity_Line_Item__c, mapOfProjectRole);
				}
			}


			if (validateData(oppLineItems, oliWithProjectRole) && validateAuthorizedSignatory(oppLineItems, oliWithProjectRole)){
				Opportunity opp = [SELECT Id, Name, AccountId, StageName, Authorized_Signatory__c, Contract_Sent_By__c, Authorized_Signatory__r.EMail, (SELECT Id, dsfs__DocuSign_Envelope_ID__c, dsfs__Envelope_Status__c
				                                                                                                                                        FROM R00N80000002fD9vEAE
				                                                                                                                                        WHERE dsfs__Envelope_Status__c NOT IN('Voided','Declined')
				                                                                                                                                        ORDER BY CreatedDate desc)
				                   FROM Opportunity
				                   WHERE Id = :oppId];

				if (authSignatoryEmail != null && String.isNotBlank(authSignatoryEmail)){
					//authSignatoryEmail = opp.Authorized_Signatory__r.Email;
					List<dsfs__DocuSign_Status__c> docuSignStatuses = opp.R00N80000002fD9vEAE;
                    if (opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost'){
						System.debug('====> Opportunity is already Closed');
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Opportunity is already Closed'));
					} 
					else if (docuSignStatuses.size() > 0 && docuSignStatuses[0].dsfs__Envelope_Status__c == 'Sent'){
						System.debug('====> Already SEnt');
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Contract Already Sent'));

					} else if (docuSignStatuses.size() > 0 && docuSignStatuses[0].dsfs__Envelope_Status__c == 'Completed'){
						System.debug('====> Docusign is already Completed');
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Docusign is already Completed'));

					} else if (docuSignStatuses.size() > 0 && docuSignStatuses[0].dsfs__Envelope_Status__c != 'Declined'){
						System.debug('====> Docusign Found');
						pdfFileName = opp.Name + '_' + Date.today().format()+'.pdf';
						envelopeId = docuSignStatuses[0].dsfs__DocuSign_Envelope_ID__c;
						redirectPreviewURL = DocusignAPI.getPreviewURL(envelopeId);
						enableSend = (redirectPreviewURL != null);
						System.debug(enableSend + '====> previewSuccess');
						System.debug(redirectPreviewURL + '====> redirectURL');

					} else{
						// Added by @harshadk for the View Contract bug when the docusign is declined SOPS-556
						if (opp.Contract_Sent_By__c == null || docuSignStatuses.isEmpty()){
							System.debug('====> Send New Docusign');
							pdfFileName = opp.Name + '_' + Date.today().format()+'.pdf';
							envelopeId = DocusignAPI.createEnvelope(oppId);
							redirectPreviewURL = DocusignAPI.getPreviewURL(envelopeId);
							enableSend = (redirectPreviewURL != null);
							System.debug(redirectPreviewURL + '====> redirectURL');
						} else{
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Contract Already Sent'));
						}

					}
				} else{
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Authorized Signatory or Authorized Signatory Email cannot be blank.'));
				}
			}
		} else{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Either there are no opportunitylineitems or membershiproles are not associated with the lineitems'));
		}
		return null;
	}

	private void downloadDocusign(String envelopeId){
        System.debug('#--envelopeId--#' + envelopeId);
		if (envelopeId != null){
			HttpResponse response = DocusignAPI.getDocument(envelopeId);
			if (response.getStatusCode() == 200){
				ContentVersion contentVersion = new ContentVersion();
				contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
				contentVersion.PathOnClient = pdfFileName;
				contentVersion.Title = pdfFileName;
				contentVersion.VersionData = response.getBodyAsBlob();
				contentVersion.FirstPublishLocationId = oppId;
				insert contentVersion;
			}
		}
	}

	@RemoteAction
    public static String downloadDocumentToSystem(String envelopeId){
        HttpResponse response = DocusignAPI.getDocument(envelopeId);
		String base64Pdf = EncodingUtil.base64Encode(response.getBodyAsBlob());
        return base64Pdf;
    }

	private void updateOpportunityField(){
		Opportunity opportunity = new Opportunity(Id = oppId, Contract_Sent_By__c = UserInfo.getUserId());
		update opportunity;
	}

	public void sendDocuSign(){
		System.debug(envelopeId + '====> envelopeId' + ' ' + oppId);
		if (envelopeId != null){

			//INFO When the User Sends the Envelope and its already created then send the Current one. or if not created then send new
			HttpResponse response = DocusignAPI.sendEnvelope(envelopeId);
			System.debug(response + '====> response');
			if (response.getStatusCode() == 200){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Contract Sent'));
				downloadDocusign(envelopeId);
				updateOpportunityField();

			} else{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'There was an error sending document'));
			}

		}
	}

	public PageReference goToRecord(){
		return new PageReference('/' + oppId);
	}

	public void sendDS(){
		DocusignAPI.sendEnvelope(envelopeId);
	}

	private boolean validateData(Map<Id, OpportunityLineItem> oppLineItems, Map<String, Map<String, Project_Role__c>> oliWithProjectRoles){
		boolean isValid = true;
		System.debug('oli key set==>' + oliWithProjectRoles.keySet());
		//validate for each oli where it has 'Billing Contact' and 'Representative/Voting Contact' with email or not
		for (String oliId : oppLineItems.keySet()){
			System.debug(oliId);
			if (oppLineItems.get(oliId).Start_Date__c == null || oppLineItems.get(oliId).End_Date__c == null){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Start Date or End Date of opportunity product cannot be blank.'));
				isValid = false;
				break;
			} else{
				if (oliWithProjectRoles.containsKey(oliId)){
					Map<String, Project_Role__c> mapOfProjectRole = oliWithProjectRoles.get(oliId);
					if (mapOfProjectRole.containsKey('Billing Contact')){
						Project_Role__c pr = mapOfProjectRole.get('Billing Contact');
						if (pr.Contact__c == null || pr.Contact__r.Email == null){
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Billing Contact Required on Membership line item.'));
							isValid = false;
							break;
						}
					} else{
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Billing Contact Required on Membership line item.'));
						isValid = false;
						break;
					}
					if (oppLineItems.get(oliId).Product2.Name != 'Individual Membership'){
						if (mapOfProjectRole.containsKey('Representative/Voting Contact')){
							Project_Role__c pr = mapOfProjectRole.get('Representative/Voting Contact');
							if (pr.Contact__c == null || pr.Contact__r.Email == null){
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.Voting_Contact_Required));
								isValid = false;
								break;
							}
						} else{
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.Voting_Contact_Required));
							isValid = false;
							break;
						}
					}
				} else{
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'No Active Billing or Voting found for project ' + oppLineItems.get(oliId).Projects__r.Name));
					isValid = false;
					break;
				}
			}
		}
		return isValid;
	}

	private boolean validateAuthorizedSignatory(Map<Id, OpportunityLineItem> oppLineItems, Map<String, Map<String, Project_Role__c>> oliWithProjectRoles){
		boolean isValid = true;
		//validated for LF project
		for (String oliId : oliWithProjectRoles.keySet()){
			OpportunityLineItem oli = oppLineItems.get(oliId);
			System.debug(oli.projects__r.Name);
			if ((oppLineItems.keySet().size() > 1 && oli.projects__r.Name != 'The Linux Foundation') || oppLineItems.keySet().size() == 1){
				Map<String, Project_Role__c> mapOfProjectRole = oliWithProjectRoles.get(oliId);
				System.debug('found auth sig: ' + mapOfProjectRole.containsKey('Authorized Signatory'));
				if (mapOfProjectRole.containsKey('Authorized Signatory')){
					Project_Role__c pr = mapOfProjectRole.get('Authorized Signatory');
					if (pr.Contact__c == null || pr.Contact__r.Email == null){
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Authorized Signatory or Authorized Signatory Email Required on Membership line item.'));
						isValid = false;
						break;
					}
					if (pr.Contact__c != null || pr.Contact__r.Email != null){
						authSignatoryEmail = pr.Contact__r.Email;
					}
				} else{
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'No Authorized Signatory Found.'));
					isValid = false;
					break;
				}
			}
		}
		return isValid;
	}
}