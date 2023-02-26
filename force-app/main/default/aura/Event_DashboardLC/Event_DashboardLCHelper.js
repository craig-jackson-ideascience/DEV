({
  //Method to set flags for displaying componets
  setComponent: function (component, selectedType) {

    /*
    on selection of one - display that component and hide other two components
    */
    if (selectedType == 'Registrations') {
      component.set('v.isSponsorships', false);
      component.set('v.iscompareEvents', false);
      component.set('v.isRegistrations', true);


    } else if (selectedType == 'Sponsorships') {
      component.set('v.isRegistrations', false);
      component.set('v.iscompareEvents', false);
      component.set('v.isSponsorships', true);

    } else if (selectedType == 'Compare Events') {
      component.set('v.isRegistrations', false);
      component.set('v.isSponsorships', false);
      component.set('v.iscompareEvents', true);

    }
    component.set("v.showSpinner", false);
  }
})