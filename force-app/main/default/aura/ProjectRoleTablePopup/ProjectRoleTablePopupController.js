/**
 * Updated by Tushar@cloudroute.in on 25/09/20.
 */
({
	doInit: function (component, event, helper) {
		helper.getOpportunity(component);
		helper.loadProductTab(component);
		/*helper.getRolePicklist(component, event);*/
		helper.getStatusPicklist(component, event);

	},

	handleActive: function (cmp, event, helper) {
		var tab = event.getSource();
		cmp.set("v.activeLineItemID", tab.get('v.id'));
		cmp.set("v.isLoading", true);
		cmp.set("v.isEditModeOn", false);
		cmp.set("v.ProjectRoleList", []);

		//Added by Priyesh @CloudRoute, getRolePicklist method moved here from doInit to get the current oli id
		var itemID = cmp.get("v.activeLineItemID");
		console.log({
			itemID
		});
		helper.getRolePicklist(cmp, event, itemID);
		var currOpp = cmp.get("v.opp");
		if (currOpp.IsClosed) {
			helper.checkForRenewal(cmp, event, itemID);
		}
		helper.loadRecords(cmp);
	},

	addProjectRole: function (component, event, helper) {
		component.set("v.isEditModeOn", true);
		component.set("v.ContactName", '');
		helper.addProjectRoleHelper(component, event, helper);
	},

	removeProjectRole: function (component, event, helper) {
		helper.removeProjectRoleHelper(component, event, helper);
	},

	SaveProjectRoles: function (component, event, helper) {
		//first update old values from datatable
		if (!$A.util.isUndefinedOrNull(component.get("v.data")) && Array.isArray(component.get("v.data")) && component.get("v.data").length) {
			var dataTableId = component.find('datatableId');
			console.log('dataTableId-->', dataTableId);
			dataTableId.Save();
		} else {
			console.log('From Add Pr Call');
			helper.SaveProjectRolesHelper(component, event, helper);
		}
	},

	CancelRecord: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},

	parentPress: function (cmp, event, helper) {
		var objChild = cmp.find('datatableId');
		var isChange = objChild.get('v.changed');
		var copyLink = objChild.get('v.CopyLink');
		var contactName = objChild.get('v.ContactName');
		var contactId = objChild.get('v.ContactId');
		console.log('contactId-->' + contactId);
		console.log('CopyLink-->' + copyLink);
		console.log('##changed :', isChange);
		console.log('Records-->' + objChild.get('v.data'));
		if (cmp.get('v.showAddRow')) { /*Checked ShowAddRow condition, this will restrict user to not change details after closed won*/
			cmp.set("v.isEditModeOn", isChange);
		}
		var copyLink1 = cmp.get("v.copyContact");
		if (copyLink == true) {
			cmp.set("v.ContactName", contactName);
			cmp.set("v.isEditModeOn", true);
			cmp.set("v.ContactId", contactId);
			cmp.set("v.copyContact", copyLink);
			cmp.set("v.copyLink", true);

			helper.addProjectRoleHelper(cmp, event, helper);
		}
	},

	saveTableRecords: function (component, event, helper) {
		var recordsData = event.getParam("recordsString");
		var dataRecord = JSON.parse(recordsData);
		var tableAuraId = event.getParam("tableAuraId");
		var data = component.get("v.data");
		console.log('data inside table popup', data);
		for (var i = 0; i < dataRecord.length; i++) {
			for (var j = 0; j < data.length; j++) {
				if (dataRecord[i].id == data[j].Id) {
					if (dataRecord[i].Status__c) {
						data[j].Status__c = dataRecord[i].Status__c;
					}
					if (dataRecord[i].PrimaryContact__c != undefined) {
						data[j].PrimaryContact__c = dataRecord[i].PrimaryContact__c;
					}
				}
			}
		}
		component.set('v.data', data);
		console.log('From Datatable Call :', JSON.stringify(data));
		helper.SaveProjectRolesHelper(component, event, helper);
	},
            
    //Old Method to Copy ProjectRoles .Kept in class for referring in future if any issue causes due to the new method
	/*handleClick: function (component, event, helper) {


		var OpportunityId = component.get("v.opportunityLineItemList");
		if (OpportunityId[0].Id == component.get("v.activeLineItemID")) {
			var action = component.get("c.insertCopiedProjectRole");
			action.setParams({
				"newoppLineId": OpportunityId[1].Id,
				"oppId": component.get("v.recordId"),
				"oldoppLineId": OpportunityId[0].Id,
			})
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "Success!",
						"message": "Copied Membership Role inserted successfully !",
						"type": "success"
					});
					toastEvent.fire();
					component.set("v.selectedTabId", OpportunityId[1].Id);
				}
			});
			$A.enqueueAction(action);

		} else {
			var action = component.get("c.insertCopiedProjectRole");
			action.setParams({
				"newoppLineId": OpportunityId[0].Id,
				"oppId": component.get("v.recordId"),
				"oldoppLineId": OpportunityId[1].Id,
			})
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "Success!",
						"message": "Copied Membership Role inserted successfully !",
						"type": "success"
					});
					toastEvent.fire();
					component.set("v.selectedTabId", OpportunityId[0].Id);
				}
			});
			$A.enqueueAction(action);
		}


	},
     */       
    //Method to copy ProjectRoles from linetem to all lineitems of the opportunity        
	copyProjectRoleController: function (component, event, helper) {
		helper.copyProjectRoleHelper(component, event, helper);
	},
	tabSelected: function (component, event, helper) {

	}
})