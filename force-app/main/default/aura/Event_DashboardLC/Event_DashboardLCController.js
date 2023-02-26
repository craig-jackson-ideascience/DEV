({
    //Init Method
    doInit : function (component, event, helper) {
        component.set("v.showSpinner", true);
        //helper.setComponent(component,component.get('v.selectedDashboardType'));
    },

    //Handle Change Method on radio button changed
    handleChange: function (component, event, helper) {
        var selectedType = event.getParam("value");
        console.log('selectedType '+selectedType);
       helper.setComponent(component,selectedType);
    }
})