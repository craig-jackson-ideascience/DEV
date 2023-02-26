({
    doInitHelper: function(component, event, helper) {
        console.log('SOBJECT-->' + component.get('v.sObjectName'));
        console.log('recordId-->'+component.get('v.recordId'));
        var object = component.get('v.sObjectName') === "Project__c" ? 'project' : 'event';
        component.set('v.object',object);
        component.find("service").callApex(component, helper, "c.mappingMethod", {
             "recordId" : component.get('v.recordId'),
             "projectOrEvent" : object
        }, this.doInitHelperSuccess);
    },
    doInitHelperSuccess: function(component, success, helper) {
         if(!$A.util.isUndefinedOrNull(success)){
             var content;
             var type = "error";
            switch (success) {
                case 0:
                    content = "No Associated Product Detail Record!";
                    break;
                case 1:
                    content = "Netsuite Fields mapped Successfully!!";
                    type="success";
                    break;
                case 2:
                    content = component.get('v.object')==='project'?"Please Make Sure all the Netsuite Fields, Project Code and Subsidiary Id are populated!" :
                    "Please make sure that following Fields are Populated - NS Deferred Revenue Account, NS Income GL Account, NS Department, BillFromProject";
                    break;
                case 3:
                    content = "To Proceed kindly populate NS Deferred Revenue Account , NS Department, Subsidiary Id, Project Code on Project & NS Revenue Schedule on all the Product Details";
            }
            helper.showToast('Code '+component.get('v.object'),type,content);
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }

})