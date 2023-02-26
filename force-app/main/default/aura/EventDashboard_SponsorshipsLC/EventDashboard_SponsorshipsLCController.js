({
      doInit: function (component, event, helper) {
        component.set("v.showSpinner", true);
        helper.getLastSevenDaysEvents(component, event, helper);
        helper.getSelectedEvent(component, event, helper);
        helper.getCurrentWeekNumber(component, event, helper);
      },

      handleEventNameChange: function (component, event, helper) {
        component.set("v.showSpinner", true);
        helper.getSelectedEvent(component, event, helper);
      }
    })