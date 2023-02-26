/**
 * Updated by Tushar@cloudroute.in on 25/09/20.
 */
({
	getOpportunity: function (component) {
		var action = component.get("c.getOpportunityDetails");
		action.setParams({
			"recordId": component.get("v.recordId")
		})
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
				component.set("v.opp", result);
				if (result.RecordType && result.RecordType.DeveloperName && result.RecordType.DeveloperName == 'Alternate_Funding') {
					component.set("v.isVotingRequired", false);
				}
				console.log('##IsClosed :', result.IsClosed);
				/*if(result.IsClosed){
				    component.set("v.showAddRow",false);
				}*/
			}
		});
		$A.enqueueAction(action);
	},

	/*Added by Priyesh @CloudRoute to show/hide the add option*/
	checkForRenewal: function (component, event, itemID) {
		var action = component.get("c.checkForRenewal");
		action.setParams({
			"oliId": itemID
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
				console.log('##IsClosed :', result);
				component.set("v.showAddRow", result);
			}
		});
		$A.enqueueAction(action);
	},

	loadProductTab: function (component) {
		var action = component.get("c.getOpportunityLineItem");
		var recordId = component.get("v.recordId");
		action.setParams({
			"recordId": recordId
		});
		action.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				var allRecords = response.getReturnValue();
				component.set("v.opportunityLineItemList", allRecords);
				if (allRecords.length > 1) {
					component.set("v.SecondOppId", true);
				}
			} else {
				var errors = response.getError();
				var message = "Error: Unknown error";
				if (errors && Array.isArray(errors) && errors.length > 0)
					message = "Error: " + errors[0].message;
				component.set("v.error", message);
				console.log("Error: " + message);
			}
		});
		$A.enqueueAction(action);
	},

	getRolePicklist: function (component, event, itemID) {
		var action = component.get("c.getRole");
		action.setParams({
			"oliId": itemID
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
				var roleMap = [];
				for (var key in result) {
					roleMap.push({
						key: key,
						value: result[key]
					});
				}
				console.log('##roleMap :', JSON.stringify(roleMap));
				component.set("v.RoleMap", roleMap);
				console.log('##RoleMap :', JSON.stringify(component.get("v.RoleMap")));
			}
		});
		$A.enqueueAction(action);
	},

	getStatusPicklist: function (component, event) {
		var action = component.get("c.getStatus");
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
				component.set("v.StatusMapForInlineEdit", result);
				console.log('##StatusMap :', JSON.stringify(component.get("v.StatusMapForInlineEdit")));

				var statusMap = [];
				for (var key in result) {
					statusMap.push({
						key: key,
						value: result[key]
					});
				}
				console.log('##StatusMap :', JSON.stringify(statusMap));
				component.set("v.StatusMap", statusMap);
			}
		});
		$A.enqueueAction(action);
	},

	loadRecords: function (component) {
		console.log('Inside-->load records helper');
		var action = component.get("c.fetchProjectRole");
		var recordId = component.get("v.recordId");
		var itemID = component.get("v.activeLineItemID");
		console.log('##itemID :', itemID);
		console.log('##recordId :', recordId);
		action.setParams({
			"recordId": recordId,
			"lineItemID": itemID,
			"oppRecord": JSON.stringify(component.get("v.opp"))
		});
		action.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				/*set columns*/
				//get status picklist values
				var statusOptions = component.get('v.StatusMapForInlineEdit');
				console.log('##statusOptions :', statusOptions);
				var types = [];
				Object.entries(statusOptions).forEach(([key, value]) => types.push({
					label: key,
					value: value
				}));
				console.log('##types :', types);

				var cols = [{
						label: "Name",
						fieldName: "accountLink",
						type: "link",
						sortable: true,
						resizable: true,
						attributes: {
							label: {
								fieldName: "Name"
							},
							title: "Click to View(New Window)",
							target: "_blank"
						}
					},

					{
						label: "Contact",
						fieldName: "contactLink",
						type: "link",
						sortable: true,
						resizable: true,
						attributes: {
							label: {
								fieldName: "Contact_Name__c"
							},
							title: "Click to View(New Window)",
							target: "_blank"
						}
					},

					{
						label: "Corporate Email",
						fieldName: "Corporate_Email__c",
						type: "text",
						sortable: true,
						resizable: true
					},

					{
						label: "Account",
						fieldName: "accountRecordLink",
						type: "link",
						sortable: true,
						resizable: true,
						attributes: {
							label: {
								fieldName: "Account"
							},
							title: {
								fieldName: 'Account'
							},
							target: "_blank"
						}
					},

					/*{label: "Contact", fieldName: "Contact_Name__c", type:"text", sortable: true},*/
					//Added by Priyesh @CloudRoute to make the contact column clickable
					{
						label: "Role",
						fieldName: "Role__c",
						type: "text",
						sortable: true
					},
					{
						label: "Start Date",
						fieldName: "Start_Date__c",
						type: "date",
						sortable: true
					},
					{
						label: "End Date",
						fieldName: "End_Date__c",
						type: "date",
						sortable: true,
						editable: true
					},
					{
						label: "Primary Contact",
						fieldName: "PrimaryContact__c",
						type: "checkbox",
						sortable: true,
						editable: true
					}, //Modified By Priyesh @Cloudroute
					{
						label: "Board Member",
						fieldName: "BoardMember__c",
						type: "checkbox",
						sortable: true
					},
					{
						label: "Status",
						fieldName: "Status__c",
						editable: true,
						type: "picklist",
						selectOptions: types,
						default: "Active"
					},
					{
						label: "",
						fieldName: " ",
						type: "percent"
					},
				];
				component.set("v.columns", cols);
				/* Process records */
				var allRecords = response.getReturnValue();
				console.log('All record is--->', allRecords);
				if (allRecords == null) {
					component.set("v.isLoading", false);
					$A.get("e.force:closeQuickAction").fire();
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "No Project Roles!",
						"type": "error",
						"message": "Select Renewal opportunity",
					});
					toastEvent.fire();
				} else {
					console.log('Size of records is ', allRecords.length);
					console.log('All records is ', allRecords);
					var memberAccountMissing = false;
					/*allRecords.forEach(function(record){
					    record.accountLink = '/'+record.Id;
					});*/
					allRecords.forEach(rec => {
					    console.log('rec.Account__c', rec.Account__c );
						rec.accountLink = '/' + rec.Id;
						rec.accountRecordLink = '/' + rec.Account__c;
						rec.contactLink = '/' + rec.Contact__c; //Added by Priyesh @CloudRoute to make the contact column clickable
						if(rec.Account__c){
						    rec.Account = rec.Account__r.Name;
                        }else{
                            memberAccountMissing = true;
                        }
					});
					if(memberAccountMissing){
                        var toastEvent = $A.get("e.force:showToast");
                		toastEvent.setParams({
                            "mode" : 'sticky',
                			"title": 'Error!',
                			"type": 'error',
                			"message": 'Error: One or more of the related Membership Roles does not have an Account selected in the "Membership.Account field". Please select an Account for this field and try the "Membership Roles" button again. '
                		});
                		toastEvent.fire();
                		var removeRecords = null;
                        component.set("v.data", removeRecords);

     }else{
					component.set("v.data", allRecords);
					}
					component.set("v.isLoading", false);
				}
			} else {
				var errors = response.getError();
				var message = "Error: Unknown error";
				if (errors && Array.isArray(errors) && errors.length > 0)
					message = "Error: " + errors[0].message;
				component.set("v.error", message);
				console.log("Error: ", message);


			}
		});
		$A.enqueueAction(action);
	},

	addProjectRoleHelper: function (component, event, helper) {
		var oppLineId = component.get('v.activeLineItemID');
		var wrapInstance = {
			'contactName': null,
			'pr': {
				'sobjectType': 'Project_Role__c',
				'Opportunity_Line_Item__c': oppLineId
			},
			'isOld': false
		};
		console.log('##wrapInstance :', wrapInstance);
		var prWrapperInstance = JSON.parse(JSON.stringify(wrapInstance));
		var projectRoleList = component.get("v.ProjectRoleList") || [];
		console.log('##projectRoleList :', projectRoleList);
		//Add New PR Record
		projectRoleList.push(prWrapperInstance);
		console.log('##projectRoleList  after:', projectRoleList);
		component.set("v.ProjectRoleList", projectRoleList);

	},

	removeProjectRoleHelper: function (component, event, helper) {
		//Get the Project list
		var ProjectRoleList = component.get("v.ProjectRoleList");
		//Get the target object
		var selectedItem = event.currentTarget;
		console.log('selectedItem-->' + selectedItem);
		//Get the selected item index
		var index = selectedItem.dataset.record;
		ProjectRoleList.splice(index, 1);
		component.set("v.ProjectRoleList", ProjectRoleList);
	},

	SaveProjectRolesHelper: function (component, event, helper) {
		//combine both list
		var allProjectRoles = [];
		var oldProjectRoles = component.get("v.data");
		if (!$A.util.isUndefinedOrNull(oldProjectRoles)) {
			for (var i = 0; i < oldProjectRoles.length; i++) {
				var wrapInstance = {
					'contactName': null,
					'pr': oldProjectRoles[i],
					'isOld': true
				};
				console.log('##wrapInstance :', wrapInstance);
				var prWrapperInstance = JSON.parse(JSON.stringify(wrapInstance));
				allProjectRoles.push(prWrapperInstance);
			}
		}

		var newProjectRoles = component.get("v.ProjectRoleList");
		if (!$A.util.isUndefinedOrNull(newProjectRoles)) {
			allProjectRoles.push.apply(allProjectRoles, JSON.parse(JSON.stringify(newProjectRoles)));
		}

		console.log('##allProjectRoles :', allProjectRoles.length);

		if (!$A.util.isUndefinedOrNull(allProjectRoles)) {
			if (this.lookupValidation(component, allProjectRoles)) { //Check Contact is selected
				if (this.checkSingleRoleValidation(component, allProjectRoles)) { //Check there is no duplicate role
					var isValidMsg = this.checkVotingAndBillingMinCount(component, allProjectRoles);
					if (isValidMsg == '') { //Check there is at-least one Active Billing and Voting Contact
						var isValidMsg = this.checkPrimaryRoleValidation(component, allProjectRoles);
						console.log('isValidMsg' + isValidMsg == '');
						if (isValidMsg == '') {
							component.set('v.isLoading', true);
							var action = component.get("c.saveProjectRoles");
							var recordId = component.get("v.recordId");
							var itemID = component.get("v.activeLineItemID");
							var prRoleList = allProjectRoles; //component.get("v.ProjectRoleList");

							prRoleList.forEach(function (record) {
								if (record.isOld == false) {
									console.log('##record.contactName :', record.contactName);
									record.contactName = (record.contactName).Id;
									console.log('##record.contactName after:', record.contactName);
									console.log('##record.pr after:', JSON.stringify(record.pr));
								}
							});

							action.setParams({
								"recordId": recordId,
								"pRoles": JSON.stringify(prRoleList),
								"lineItemID": itemID,
								"oppRecord": JSON.stringify(component.get("v.opp"))
							});

							action.setCallback(this, function (response) {
								var state = response.getState();
								console.log('11111');
								if (state === "SUCCESS") {
									component.set('v.isLoading', false);
									//If success then clear the list and call load records.
									component.set('v.ProjectRoleList', []);
									component.set('v.isEditModeOn', false);
									this.loadRecords(component);
								}
							});
							$A.enqueueAction(action);
						} else {
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								title: 'Error',
								message: 'One Primary ' + isValidMsg + ' is required/allowed',
								duration: '6000',
								key: 'info_alt',
								type: 'error',
								mode: 'pester'
							});
							toastEvent.fire();
						}
					} else {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							title: 'Error',
							message: 'Please add Active Primary ' + isValidMsg,
							duration: '6000',
							key: 'info_alt',
							type: 'error',
							mode: 'pester'
						});
						toastEvent.fire();
					}
				} else {
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: 'Error',
						message: 'Contact Role is already active',
						duration: '6000',
						key: 'info_alt',
						type: 'error',
						mode: 'pester'
					});
					toastEvent.fire();
				}
			} else {
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: 'Error',
					message: 'Required fields are missing : Contact.  ',
					duration: '6000',
					key: 'info_alt',
					type: 'error',
					mode: 'pester'
				});
				toastEvent.fire();
			}
		}
	},

	lookupValidation: function (component, prList) {
		var isValid = true;
		console.log('prList :', prList);
		for (var indexVar = 0; indexVar < prList.length; indexVar++) {
			console.log('##prList[indexVar] :', prList[indexVar].contactName);
			if (!$A.util.isUndefinedOrNull(prList[indexVar].contactName) && prList[indexVar].isOld == false) {
				isValid = true;
			} else if (prList[indexVar].isOld == false) {
				isValid = false;
				break;
			}
		}
		console.log('isValid :', isValid);
		return isValid;
	},

	checkSingleRoleValidation: function (component, prList) {
		console.log('Called role Validation');
		var isValid = true;
		//var allProjectRoles = component.get("v.ProjectRoleList");
		console.log('prList :', prList);
		for (var indexVar = 0; indexVar < prList.length; indexVar++) {
			if (!prList[indexVar].pr.Status__c || prList[indexVar].pr.Status__c === 'Active') {
				var data = prList,
					term = prList[indexVar].pr.Role__c,
					results = data,
					regex;
				console.log('##term :', term);
				console.log('##data :', data);
				console.log('##prList Contact :', JSON.stringify(prList[indexVar]));
				results = data.filter(row => row.pr.Role__c === term && (!row.pr.Status__c || row.pr.Status__c === 'Active') &&
					((row.isOld ? row.pr.Contact__c : row.contactName.Id) == (prList[indexVar].isOld ? prList[indexVar].pr.Contact__c : prList[indexVar].contactName.Id)));
				/*if(term == 'Billing Contact' || term == 'Technical Contact' || term == 'Marketing Contact'){
				    results = data.filter(row=>row.pr.Role__c === term
				     && (!row.pr.Status__c || row.pr.Status__c === 'Active')
				     && ((row.isOld ? row.pr.Contact__c : row.contactName.Id) == (prList[indexVar].isOld ? prList[indexVar].pr.Contact__c : prList[indexVar].contactName.Id)));
				}else{
				   results = data.filter(row=>row.pr.Role__c === term && (!row.pr.Status__c || row.pr.Status__c === 'Active'));
				}*/
				console.log('##results 1:', JSON.stringify(results));
				if (results && results.length > 1) {
					isValid = false;
					break;
				} else {
					isValid = true;
				}
			}
		}
		console.log('isValid :', isValid);
		return isValid;
	},

	checkPrimaryRoleValidation: function (component, prList) {
		console.log('Called primary role Validation');
		var isValid = '';
		console.log('prList :', prList);

		//check whether Primary Billing is added or not
		var billResult = prList.filter(row => row.pr.Role__c === 'Billing Contact' && (!row.pr.Status__c || row.pr.Status__c === 'Active') && row.pr.PrimaryContact__c == true);
		if (billResult && (billResult.length == 0 || billResult.length > 1)) {
			isValid = 'Billing Contact'
		} else {
			for (var indexVar = 0; indexVar < prList.length; indexVar++) {
				if (!prList[indexVar].pr.Status__c || prList[indexVar].pr.Status__c === 'Active') {
					var data = prList,
						term = prList[indexVar].pr.Role__c,
						results = data,
						regex;
					console.log('##term :', term);
					/*console.log('##data :',data);
					console.log('##prList Contact :',JSON.stringify(prList[indexVar]));*/
					var individualRoleResult = data.filter(row => row.pr.Role__c === term && (!row.pr.Status__c || row.pr.Status__c === 'Active'));
					if (individualRoleResult && individualRoleResult.length > 0) {
						console.log('Contact found..', individualRoleResult);
						//if added then check for Primary is added or not
						var individualRoleValid = individualRoleResult.filter(row => row.pr.PrimaryContact__c == true);
						if (individualRoleValid && (individualRoleValid.length == 0 || individualRoleValid.length > 1)) {
							console.log('Primary Contact did not found..');
							console.log('individualRoleValid--', individualRoleValid);
							isValid = term;
							break;
						}
					}
					console.log('##results 1:', JSON.stringify(results));
					/*if(results && results.length > 1){
					    isValid = false;
					    break;
					}else{
					   isValid = true;
					}*/
				}
			}
		}
		/* var data = prList;

		 //first check whether Marketing role is added or not
		 var marketingResult = data.filter(row=>row.pr.Role__c === 'Marketing Contact' && (!row.pr.Status__c || row.pr.Status__c === 'Active'));
		 if(marketingResult && marketingResult.length > 0){
		     console.log('Marketing Contact found..', marketingResult);
		     //if added then check for Primary is added or not
		     var marketingResultValid = marketingResult.filter(row=>row.pr.PrimaryContact__c == true);
		     if(marketingResultValid && (marketingResultValid.length == 0 || marketingResultValid.length > 1)){
		         console.log('Primary Marketing Contact did not found..');
		         isValid = 'Marketing Contact';
		     }
		 }

		 //first check whether Technical role is added or not
		 var technicalResult = data.filter(row=>row.pr.Role__c === 'Technical Contact' && (!row.pr.Status__c || row.pr.Status__c === 'Active'));
		 if(technicalResult && technicalResult.length > 0){
		     console.log('Primary Technical Contact found..',technicalResult);
		     //if added then check for Primary is added or not
		     var technicalResultValid = technicalResult.filter(row=>row.pr.PrimaryContact__c == true);
		     if(technicalResultValid && (technicalResultValid.length == 0 || technicalResultValid.length > 1)){
		         console.log('Primary Technical Contact did not found..');
		         isValid = 'Technical Contact';
		     }
		 }*/


		console.log('isValid :', isValid);
		return isValid;
	},

	checkVotingAndBillingMinCount: function (component, prList) {
		console.log('Called active Billing and Voting Contact Validation');
		var isValid = '';
		console.log('prList active roles:', prList);
		var data = prList,
			results = data,
			regex;
		console.log('results==>', results);
		//Added by Priyesh @CloudRoute to check primary billing contact (PrimaryContact__c)
		results = data.filter(row => (!row.pr.Status__c || row.pr.Status__c === 'Active' || row.pr.Status__c === '') && (row.pr.Role__c === 'Billing Contact' && row.pr.PrimaryContact__c));
		if (results && results.length == 0) {
			isValid = 'Billing Contact';
		}
		var votingRequired = component.get("v.isVotingRequired");
		console.log({
			votingRequired
		});
		if (votingRequired && isValid == '') {
			results = data.filter(row => (!row.pr.Status__c || row.pr.Status__c === 'Active' || row.pr.Status__c === '') && (row.pr.Role__c === 'Representative/Voting Contact' && row.pr.PrimaryContact__c));
			if (results && results.length == 0) {
				isValid = 'Voting Contact';
			}
		}
		console.log('##results activeRoles:', JSON.stringify(results));
		/*if(results && results.length == 0){
		    isValid = false;
		}else{
		   isValid = true;
		}*/
		console.log('isValid :', isValid);
		return isValid;
	},
            
    //Method to copy ProjectRoles from linetem to all lineitems of the opportunity
	copyProjectRoleHelper: function (component, event, helper) {
		component.set('v.isLoading', true);
		var action = component.get("c.copyProjectRoleToLineItem");
		action.setParams({
			"activeLineItemId": component.get("v.activeLineItemID"),
			"oppId": component.get("v.recordId")
		})
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set('v.isLoading', false);
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Success!",
					"message": "Copied Membership Role inserted successfully !",
					"type": "success"
				});
				toastEvent.fire();
				component.set("v.selectedTabId", component.get("v.activeLineItemID"));
			}
		});
		$A.enqueueAction(action);
	}
})