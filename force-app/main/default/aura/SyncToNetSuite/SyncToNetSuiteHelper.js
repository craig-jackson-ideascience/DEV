/**
 * Created by Martand Atrey on 12-11-2019.
 */
({
	doInitHelper: function (component, event, helper) {
		console.log('SOBJECT-->' + component.get('v.sObjectName'));
		console.log('recordId-->' + component.get('v.recordId'));
		component.find("service").callApex(component, helper, "c.checkObjectType", {
			"recordId": component.get('v.recordId'),"sObjectName": component.get('v.sObjectName')
		}, this.doInitHelperSuccess);
	},
	doInitHelperSuccess: function (component, success, helper) {
		if (!$A.util.isUndefinedOrNull(success)) {
            var response = JSON.parse(success);
			var content = response.message;
            var type = response.isSuccess ? "Success" :  "Error";			
			helper.showToast(type, content);
			$A.get("e.force:closeQuickAction").fire();
			$A.get("e.force:refreshView").fire();
		}

	},
	showToast: function (type, message) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": type,
			"type": type,
			"message": message
		});
		toastEvent.fire();
	}
})