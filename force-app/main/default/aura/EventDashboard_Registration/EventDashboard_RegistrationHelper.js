/**
 * Created by cloudroutesolutions on 24/03/21.
 */
({
    initHelper : function(component,event,helper) {
       var defaultSelected = [];
      defaultSelected.push(component.get('v.defaultSelected'));
        component.find("service")
        .callApex(component, helper,
            "c.getAllEvents",{
                 "defaultId": JSON.stringify(defaultSelected)
             },
            this.getAllEventsSuccess);


         component.find("service")
         .callApex(component, helper,
             "c.getRegistrationDetails",{
                  "defaultId": JSON.stringify(defaultSelected)
              },
             this.getRegistrationDetailsSuccess);
    },
    getAllEventsSuccess: function (component, returnValue, helper) {
        if(returnValue['Events'] != null){
            var options = [];
            var defaultVal = {
            label: 'All',
            value: 'All',
            selected: true
          };

            options.push(defaultVal);
            returnValue['Events'].forEach(rec => {
                var item = {
                  label: rec.label,
                  value: rec.value,
                };
                options.push(item);
              });

            console.log({options});
            var allEventId = [];
            options.forEach(function (element) {
                allEventId.push(element.value);
            });
            component.set("v.checkboxOptions", options);
            component.set("v.EventIds", options);
        }
    },
    getRegistrationDetailsSuccess: function (component, returnValue, helper) {
            if(returnValue['EventVsWeekVsRevenue'] != null){
                var eventIdVsName;
                if(returnValue['EventIdVsName'] != null){
                    eventIdVsName = returnValue['EventIdVsName'];
                    console.log({eventIdVsName});
                }
                var events = returnValue['EventVsWeekVsRevenue'];
                console.log({events});
                var eventTableList = [];

                for (const evet in events) {
                    var eventTableObj = {eventName: eventIdVsName[evet], eventId: evet};
                    console.log(evet);
                    var weeksVsRevenue = JSON.parse(JSON.stringify(events[evet]));
                    console.log(weeksVsRevenue);
                    var i=0;
                    for(const week in weeksVsRevenue){
                        console.log(week);

                        var rev = JSON.parse(JSON.stringify(weeksVsRevenue[week]));
                        //if(!allWeeks.includes(week)){
                            //allWeeks.push(week);
                        //}
                        if(i == 0){
                            eventTableObj.Revenue1 = rev;
                        }
                        if(i == 1){
                            eventTableObj.Revenue2 = rev;
                        }
                        console.log({eventTableObj});
                        i++;
                    }
                    eventTableList.push(eventTableObj);
                    console.log({eventTableList});
                }
                component.set("v.EventsValues", eventTableList);
                component.set("v.EventsValuesFiltered", eventTableList);

                var allWeeks = [];
                if(returnValue['YearWeeks'] != null){
                    var weekVsDate = returnValue['YearWeeks'];
                    for(const week in weekVsDate){
                        var weekVsDateObj = {week: week, relatedDate: weekVsDate[week]};
                        allWeeks.push(weekVsDateObj);
                    }
                }
                component.set("v.Weeks", allWeeks);
            }
            component.set("v.showSpinner", false);
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

        var getAllEventValues = component.get("v.EventsValues");

       /* var results = getAllEventValues.filter(row=>
            row.eventId == selectedSource
        );*/

        if(selectedSource.includes('All')){
            component.set("v.EventsValuesFiltered", getAllEventValues);
        }else{
            var results = getAllEventValues.filter(el => {
               return selectedSource.find(element => {
                  return element === el.eventId;
               });
            });
            component.set("v.EventsValuesFiltered", results);
        }

        /*component.find("service")
         .callApex(component, helper,
             "c.getRegistrationDetails",{
                  "defaultId": JSON.stringify(selectedSource)
              },
             this.getRegistrationDetailsSuccess);*/
      },

})