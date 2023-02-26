({
	doInitHelper: function (component, event, helper) {		
		component.find("service").callApex(component, helper, "c.getSalesOrderStatus", {
			"assetId": component.get('v.recordId')
		}, this.doInitHelperSuccess);
	},
	doInitHelperSuccess: function (component, success, helper) {
        if (success != "") {            			
            helper.showToast("Error", success);
        }else{
             helper.showToast("Success", "Asset updated successfully!!");
        }
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();

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