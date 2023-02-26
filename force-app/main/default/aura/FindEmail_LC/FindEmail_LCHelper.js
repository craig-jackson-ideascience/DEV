({
    /**
     * Method to find the contact based on email
     */
    findContactHelper: function (component, event, helper) {
        component.set('v.showSpinner', true);
        var emailAddress = component.get("v.emailAddress")
        if (!$A.util.isUndefinedOrNull(emailAddress) && !$A.util.isEmpty(emailAddress)) {
            component.set("v.emptyMailAddress", false);
            component.find("service").callApex(component, helper, "c.findContactFromEmail", {
                    "email": emailAddress
                },
                this.contactFoundSucess);
        } else {
            component.set("v.emptyMailAddress", true);
            component.set('v.showSpinner', false);
        }

    },

    /**
     * Success Method
     */
    contactFoundSucess: function (component, returnValue, helper) {
        console.log(returnValue);
        if (!$A.util.isUndefinedOrNull(returnValue) && !$A.util.isEmpty(returnValue)) {
            if (returnValue != 'Error') {
                helper.populateContactLookup(component, returnValue);
            } else {
                component.set('v.showSpinner', false);
                helper.showToast('Error', 'error', 'There was an error in fetching the contact,Please contact the System Administrator.');
            }

        } else {
            component.set("v.showContactLookup", false);
            component.set("v.noContactFound", true);
            component.set('v.showSpinner', false);
        }

    },

    /**
     * Method for populating the contactlookup
     */
    populateContactLookup: function (component, returnValue) {
        component.set("v.contactId", returnValue);
        component.set("v.noContactFound", false);
        component.set("v.showContactLookup", true);
        component.set("v.showContactModal", false);
        component.set('v.showSpinner', false);
    },

    /**
     * Method for displaying the toast message
     */
    showToast: function (title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }
})