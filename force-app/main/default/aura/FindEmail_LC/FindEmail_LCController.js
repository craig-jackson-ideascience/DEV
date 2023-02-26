({
    /**
     * Method to find the contact based on email
     */
    findContact: function (component, event, helper) {
        helper.findContactHelper(component, event, helper);
    },

    /**
     * Method to OPen the new contact creation modal
     */
    openContactModal: function (component, event, helper) {
        component.set("v.showContactModal", true);
        component.set('v.showSpinner', true);
    },

    /**
     * Method for populating the contact ookup on successful creation of contact
     */
    handleContactSuccess: function (component, event, helper) {
        component.set('v.showSpinner', true);
        helper.populateContactLookup(component, event.getParam("response").id);
    },

    /**
     * Method to close the contact modal
     */
    handleCancel: function (component, event, helper) {
        component.set('v.showContactModal', false);
    },

    /**
     * Method to display the find contact button
     */
    showFindButton: function (component, event, helper) {
        component.set('v.showContactLookup', false);
        component.set('v.showContactModal', false);
        component.set('v.noContactFound', false);
    },

    /**
     * Method for displaying the error
     */
    handleError: function (component, event, helper) {
        component.set('v.showSpinner', false);
        event.getParam("output").fieldErrors;
    },

    /**
     * Method on load of recordeditform
     */
    handleLoad: function (component, event, helper) {
        component.set('v.showSpinner', false);
    },
})