({
    doInIt: function(component, event, helper) {
        if(component.get('v.sObjectName') == 'Project__c'){
            component.set("v.showRecordTypeModal", true);
            helper.fetchListOfRecordTypes(component,event,helper);
        }else{
            helper.createRecordOther(component,event,helper);
        }
    },

    createRecord : function(component,event,helper) {
        helper.createRecordProject(component,event,helper);
    },

    closeModal: function(component, event, helper) {
         // set "showRecordTypeModal" attribute to false for hide/close model box
         $A.get("e.force:closeQuickAction").fire();
         component.set("v.showRecordTypeModal", false);
      },

      openModal: function(component, event, helper) {
         // set "showRecordTypeModal" attribute to true to show model box
         component.set("v.showRecordTypeModal", true);
      },
})