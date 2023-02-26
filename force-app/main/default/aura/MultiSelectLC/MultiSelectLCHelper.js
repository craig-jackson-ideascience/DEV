({
      init: function (component) {

        // note, we get options and set options_
        // options_ is the private version and we use this from now on.
        // this is to allow us to sort the options array before rendering
        if (component.get("v.initialized")) {
          return;
        }
        component.set("v.initialized", true);

        var options = component.get("v.options");
        /*options.sort(function compare(a, b) {
      if (a.value == 'All') {
        return -1;
      } else if (a.value < b.value) {
        return -1;
      }
      if (a.value > b.value) {
        return 1;
      }
      return 0;
    });*/

        component.set("v.options_", options);
        var labels = this.getSelectedLabels(component);
        this.setInfoText(component, labels);

      },


      setInfoText: function (component, values) {
        var txt = values;
        if (values.length == 0) {
          component.set("v.infoText", txt);
        }
        if (values.length == 1) {
          component.set("v.infoText", values[0]);
        } else if (values.length > 1) {
          if (values.includes('All')) {
            component.set("v.infoText", 'All');
          } else {
            component.set("v.infoText", values);
          }
        } else if (component.get("v.isAllDifferent")) {
          component.set("v.infoText", 'All');
        }
      },

      getSelectedValues: function (component) {
        var options = component.get("v.options_");
        var values = [];
        options.forEach(function (element) {
          if (element.selected) {
            values.push(element.value);
          }
        });
        /* if (values.length > 1 && values[0] == 'All') {
          values.splice(0, 1);
          options[0].selected = false;
        } */

        return values;
      },

      getSelectedLabels: function (component) {
        var options = component.get("v.options_");
        var labels = [];
        options.forEach(function (element) {
          if (element.selected) {
            labels.push(element.label);
          }
        });
        return labels;
      },

      despatchSelectChangeEvent: function (component, values) {
        var compEvent = component.getEvent("selectChange");
        compEvent.setParams({"values": values});
        compEvent.fire();
      },

      setInputValue: function (component, event, helper) {
        var options = component.get("v.options");
        var values = [];
        var idx = component.get('v.auraidmodal');
        var wordSearch = document.getElementById(idx).value;
        options.forEach(function (element) {
          var str = element.label;
          if (str.toLowerCase().includes(wordSearch) || str.toUpperCase().includes(wordSearch)) {
            values.push(element);
          }
        });
        if (values != null && values.length > 0) {
          component.set("v.options_", values);
        }
      },

      closeDropdown: function (component, event, helper) {
        var mainDiv = component.find('main-div');
        $A.util.removeClass(mainDiv, 'slds-is-open');
      }
    })