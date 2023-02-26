({
      /* get picklist events */
      getLastSevenDaysEvents: function (component, event, helper) {
        component.find("service").callApex(component, helper, "c.getLastSevenDaysEvents", {}, this.getLastSevenDaysEventsSuccess);
      },

      getLastSevenDaysEventsSuccess: function (component, returnValue, helper) {
        var eventNames = [];
        var defaultVal = {
          label: 'All',
          value: 'All'
        };
        eventNames.push(defaultVal);
        returnValue.forEach(rec => {
          var item = {
            label: rec.Name,
            value: rec.Name,
            /* selected: true */
          };
          eventNames.push(item);
        });
        component.set("v.eventNames", eventNames);
      },

      /* get week number */
      getCurrentWeekNumber: function (component, event, helper) {
        component.find("service").callApex(component, helper, "c.getWeekNumbers", {}, this.getCurrentWeekNumberSuccess);
      },

      getCurrentWeekNumberSuccess: function (component, returnValue, helper) {
        var weekVsDate = returnValue;
        var allWeeks = [];
        for (const week in weekVsDate) {
          var weekVsDateObj = {
            week: week,
            relatedDate: weekVsDate[week]
          };
          allWeeks.push(weekVsDateObj);
        }
        component.set("v.currentWeek", allWeeks);
      },

      /* get acitve sponsored events */
      getSelectedEvent: function (component, event, helper) {
        var selectedSource = event.getParam("values");
        if (selectedSource != null && selectedSource.length > 1 && selectedSource[0] == 'All') {
          selectedSource.splice(0, 1);
        }
        component.set("v.selectedEvents", selectedSource);
        component.find("service").callApex(component, helper, "c.getActiveSponsoredEvents", {
          listOfSelectedEvents: selectedSource
        }, this.getSelectedEventSuccess);
      },

      getSelectedEventSuccess: function (component, returnValue, helper) {
        component.set("v.listOfEventWrapper", returnValue);
        component.set("v.showSpinner", false);
      }
    })