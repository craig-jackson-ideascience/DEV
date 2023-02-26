({
  //Init
  doInit: function (component, event, helper) {
    component.set("v.showSpinner", true);
    helper.initHelper(component, event, helper);
  },
  //On change of Event
  handleEventChange: function (component, event, helper) {
    component.set("v.showSpinner", true);
    helper.handleEventChangeHelper(component, event, helper);
  }

})