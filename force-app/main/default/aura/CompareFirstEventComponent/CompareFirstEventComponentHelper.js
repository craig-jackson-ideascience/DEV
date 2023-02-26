({
  //Method to get the Events for dropdown filter
  initHelper: function (component, event, helper) {

    var defaultSelected = [];
    defaultSelected.push(component.get('v.defaultSelected'));
    component.find("service").callApex(component, helper, "c.getAllEvents", {
      "defaultId": JSON.stringify(defaultSelected)
    }, this.initSuccess);
  },

  //Init Success
  initSuccess: function (component, returnValue, helper) {

    if (returnValue['Error'] != null) {
      helper.showToast('Error!', 'error', returnValue['Error']);
      component.set('v.hasError', true);
      component.set('v.showSpinner', false);
    } else {
      //Set Events filter
      if (returnValue['Events'] != null) {
        var options = returnValue['Events'];
        component.set("v.checkboxOptions", options);
        helper.setCheckboxOptions(component, event, helper);


      }
      //Set Registration Table
      if (returnValue['Details'] != null) {

        helper.registrationDetailsSuccess(component, returnValue['Details'], helper);
      }
    }
  },

  //Set CheckboxOptions by selecting one
  setCheckboxOptions: function (component, event, helper) {
    var options = component.get("v.checkboxOptions");
    var defaultSelected = component.get('v.defaultSelected');
    options.forEach(function (element) {
      if (element.value == defaultSelected) {
        element.selected = true;
      }
    });
    component.set("v.checkboxOptions", options);
  },

  //Method to call on change of event
  handleEventChangeHelper: function (component, event, helper) {
    var selectedSource = event.getParam("values");

    //if nothing is selected
    if (selectedSource.length == 0) {
      //then set the default value again
      helper.setCheckboxOptions(component, event, helper);
      selectedSource.push(component.get('v.defaultSelected'));
    }
    console.log('selectedSource ' + selectedSource);
    component.set("v.checkboxValues", selectedSource);
    component.find("service").callApex(component, helper, "c.getRegistrationDetails", {
      "eventIds": JSON.stringify(selectedSource)
    }, this.registrationDetailsSuccess);

  },

  //Registration Detail Table success
  registrationDetailsSuccess: function (component, returnValue, helper) {

    if (returnValue['Error'] != null) {
      helper.showToast('Error!', 'error', returnValue['Error']);
      component.set('v.hasError', true);
    } else {
      //Set Summary and Registration Table 
      var totalRegistrationString = component.get("v.totalRegistrationString");
      var lastRegDateString = component.get("v.lastRegDateString");
      var totalRegistration = returnValue[totalRegistrationString];
      var lastRegDate = returnValue[lastRegDateString];
      component.set("v.totalRegistration", totalRegistration);
      component.set("v.lastRegDate", lastRegDate);


      var records = JSON.parse(returnValue['Registration Details']);
      var registrationsDetails = [];
      for (var i = records.length - 1; i >= 0; i--) {
        if (i == 0 || i == 1) {
          records[i].bucket = records[i].bucket.replace("Weeks", "Week");
        }
        registrationsDetails.push(records[i]);
      }

      component.set("v.registrationTableList", registrationsDetails);
      console.log('tavle ' + component.get("v.registrationTableList"));

    }
    component.set('v.showSpinner', false);
  },

  //Method to Show Toast
  showToast: function (title, type, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      "title": title,
      "type": type,
      "message": message
    });
    toastEvent.fire();
  },
})