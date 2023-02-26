({
      deselectValue: function (component, event, helper) {
        var options = component.get("v.options_");

        // shift key ADDS to the list (unless clicking on a previously selected item)
        // also, shift key does not close the dropdown (uses mouse out to do that)

        options.forEach(function (element) {

          element.selected = selected == "true" ? false : true;

        });


      },

      reInit: function (component, event, helper) {
        component.set("v.initialized", false);
        helper.init(component);
      },

      init: function (component, event, helper) {
        helper.init(component);
        /* helper.windowClick = function (e) {
            if (e.target.toString().includes('HTMLDivElement')) { //If its normal div element, close drodown
                helper.closeDropdown(component);
                //document.removeEventListener('click', helper.windowClick); //Remove event listner so that it doesn't interfere in other clicks in remaining document
            } else {
                //do nothing, helper methods will handle click of icon
            }
        }
        document.addEventListener('click', helper.windowClick); */
        /* helper.windowClick = function (e) {
            if (e.target.toString().includes('HTMLDivElement')) { //If its normal div element, close drodown
                helper.closeDropdown(component);
                document.removeEventListener('click', helper.windowClick); //Remove event listner so that it doesn't interfere in other clicks in remaining document
            } else {
                //do nothing, helper methods will handle click of icon
            }
        }
        document.addEventListener('click', helper.windowClick); */
        /* component.closeMenu = $A.getCallback(function() {
            if (component.isValid()) {
                

                helper.closeDropdown(component);

            } else {
                window.removeEventListener('click', component.closeMenu);
            }
        });

        window.addEventListener('click', component.closeMenu); */
      },

      handleClick: function (component, event, helper) {
        event.stopPropagation();
        var mainDiv = component.find('main-div');
        $A.util.toggleClass(mainDiv, 'slds-is-open');
        var options = component.get("v.options");
        component.set("v.options_", options);
        var labels = helper.getSelectedLabels(component);
        helper.setInfoText(component, labels);
      },

      handleSelection: function (component, event, helper) {
        event.stopPropagation();
        var item = event.currentTarget;

        if (item && item.dataset) {
          var value = item.dataset.value;
          var selected = item.dataset.selected;

          var options = component.get("v.options_");

          // shift key ADDS to the list (unless clicking on a previously selected item)
          // also, shift key does not close the dropdown (uses mouse out to do that)
          // if (event.shiftKey) {
          console.log('-INSIDE SHIFT CLICK-');
          var allSelected = false;
          options.forEach(function (element) {
            if (! component.get("v.isSingleSelect")) {
              if (value != 'All') {
                if (element.value == 'All') {
                  element.selected = false
                }
                if (element.value == value) {
                  element.selected = selected == "true" ? false : true;
                }
              } else {
                allSelected = selected == "true" ? false : true;
                element.selected = allSelected;
              }
            } else {
              if (element.value == value) {
                element.selected = selected == "true" ? false : true;
              } else if (element.selected) {
                element.selected = false;
              }

            }
          });
          // }
          /*else {
          console.log('-Not INSIDE SHIFT CLICK-');
        options.forEach(function(element) {
          if (element.value == value) {
            element.selected = selected == "true" ? false : true;
          } else {
            element.selected = false;
          }
        });
        //var mainDiv = component.find('main-div');
        //$A.util.removeClass(mainDiv, 'slds-is-open');
      }*/
          component.set("v.options_", options);
          var values = helper.getSelectedValues(component);

          component.set("v.selectedItems", values);

          var labels = helper.getSelectedLabels(component);
          if (values.length == 0 && component.get("v.isAllDifferent")) {
            labels.push('All');
          }

          helper.setInfoText(component, labels);
          if (component.get("v.isSingleSelect") && ! component.get("v.showApplyButton")) {
            helper.despatchSelectChangeEvent(component, values);
          }

        }
      },

      hanldeFocusOut: function (component, event, helper) { // if(!component.get("v.showApplyButton")){
        console.log('#Mouse Leave--#');
        component.set("v.dropdownOver", false);
        var mainDiv = component.find('main-div');
        $A.util.removeClass(mainDiv, 'slds-is-open');
        // }
      },
      /* hanldeFocusOut: function (component, event, helper) {
      //  if(!component.get("v.showApplyButton")){
        console.log('#Mouse Leave--#');
        component.set("v.dropdownOver", false);
        var mainDiv = component.find('main-div');
        $A.util.removeClass(mainDiv, 'slds-is-open');
       // }
    }, */
      handleMouseEnter: function (component, event, helper) {
        console.log('Mouse Enter');
        document.getElementById('focusId').focus();
        component.set("v.dropdownOver", true);
      },

      handleMouseOutButton: function (component, event, helper) {
        console.log('MOuse Enter Out');
        document.getElementById('focusId').focus();
        window.setTimeout($A.getCallback(function () { // console.log('timeout:');
          if (component.isValid()) {
            // console.log('In If:');
            // if dropdown over, user has hovered over the dropdown, so don't close.
            if (component.get("v.dropdownOver")) { // console.log('In If2:');
              return;
            }
            var mainDiv = component.find('main-div');
            $A.util.removeClass(mainDiv, 'slds-is-open');
          }
        }), 200);
      },

      searchOption: function (component, event, helper) {
        var idx = component.get('v.auraidmodal');
        var wordSearch = document.getElementById(idx).value;
        var input = document.getElementById(idx);
        input.setAttribute("autocomplete", "off");
        if (wordSearch.length > 1) {
          helper.setInputValue(component, event, helper);
        }
        if (wordSearch.length == 0) {
          component.set('v.searchVar', null);
          var options = component.get("v.options");
          component.set("v.options_", options);
        }
        if (event.keyCode === 8 && wordSearch.length == 0) {
          var options = component.get("v.options");
          component.set("v.options_", options);
        }
      },

      autocompleteFntn: function (component, event, helper) {
        var idx = component.get('v.auraidmodal');
        var input = document.getElementById(idx);
        if (input.getAttribute("autocomplete") !== "off") {
          input.setAttribute("autocomplete", "off");
        }
      },

      backspaceEvent: function (component, event, helper) {
        var KeyID = event.keyCode;
        switch (KeyID) {
          case 8:
            var options = component.get("v.options");
            component.set("v.options_", options);
            break;
          case 46:
            var options = component.get("v.options");
            component.set("v.options_", options);
            break;
          default:
            break;
        }
      },

      applyChanges: function (component, event, helper) {
        component.set("v.loaded", true);
        event.stopPropagation();
        var values = helper.getSelectedValues(component);
        helper.closeDropdown(component);
        helper.despatchSelectChangeEvent(component, values);
      },

      closeDropdown: function (component, event, helper) {
        helper.closeDropdown(component, event, helper);
      }

    })