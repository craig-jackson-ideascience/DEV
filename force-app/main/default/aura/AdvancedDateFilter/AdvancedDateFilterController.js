/**
 * Created by cloudroutesolutions on 10/02/21.
 */
({
    deselectValue: function (component, event, helper) {
        var options = component.get("v.options_");

        //shift key ADDS to the list (unless clicking on a previously selected item)
        //also, shift key does not close the dropdown (uses mouse out to do that)

        options.forEach(function (element) {
            console.log(element);
            element.selected = selected == "true" ? false : true;

        });



    },

    reInit: function (component, event, helper) {
        component.set("v.initialized", false);
        helper.init(component);
    },

    init: function (component, event, helper) {
        helper.init(component);
    },

    handleClick: function (component, event, helper) {
        var mainDiv = component.find('main-div');
        $A.util.toggleClass(mainDiv, 'slds-is-open');
        /* Clicks within the dropdown won't make
           it past the dropdown itself */
        //        $(mainDiv).click(function(e){
        //          e.stopPropagation();
        //        });

        var options = component.get("v.options");
        component.set("v.options_", options);
        var labels = helper.getSelectedLabels(component);
        /* helper.setInfoText(component, labels); */
    },

    handleSelection: function (component, event, helper) {
        var item = event.currentTarget;

        if (item && item.dataset) {
            var value = item.dataset.value;
            console.log({
                value
            });
            var selected = item.dataset.selected;
            console.log({
                selected
            });

            console.log(value.endsWith('is equalLessThan' + '_Plus_To_Date'));
            if (value == 'All') {
                component.set("v.selectedSoqlOperator", value);
            } else if (value.endsWith('_Plus_To_Date')) {
                component.set("v.selectedSoqlOperator", 'equalLessThan');
            } else {
                component.set("v.selectedSoqlOperator", 'equal');
            }


            var options = component.get("v.options_");

            //shift key ADDS to the list (unless clicking on a previously selected item)
            //also, shift key does not close the dropdown (uses mouse out to do that)
            //if (event.shiftKey) {
            console.log('-INSIDE SHIFT CLICK-');
			var isSelectionChanged = false;
            options.forEach(function (element) {
                if (element.value == value) {
	                if(!element.selected){
    	                element.selected = selected == "true" ? false : true;
		                isSelectionChanged = true;
		            }
                } else if (element.selected) {
                    element.selected = false;
                }
            });
            //}
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
            if(isSelectionChanged){
                component.set("v.options_", options);
                var values = helper.getSelectedValues(component);
                component.set("v.selectedItems", values);
                var labels = helper.getSelectedLabels(component);
    
                helper.setInfoText(component, labels);
                helper.dispatchSelectChangeEvent(component, values);
            }
        }
    },

    handleToggleCustomDateSelection: function (component, event, helper) {
        helper.toggleCustomDateSelection(component, event, helper);
    },

    handleActive: function (cmp, event, helper) {
        var tab = event.getSource();
        cmp.set("v.selectedTabDate", tab.get('v.id'));
        switch (tab.get('v.id')) {
            case 'absolute':
                //helper.loadOperatorOptions(cmp, event);
                break;
            case 'relative':
                var options = [{
                        label: 'Year',
                        value: 'Year'
                    },
                    {
                        label: 'Quarter',
                        value: 'Quarter'
                    },
                    {
                        label: 'Month',
                        value: 'Month'
                    },
                    {
                        label: 'Week',
                        value: 'Week'
                    },
                    {
                        label: 'Day',
                        value: 'Day'
                    }
                ];
                cmp.set("v.relativeButtonOptions", options);
        }
    },

    handleDateOperatorChange: function (cmp, event) {
        // Get the string of the "value" attribute on the selected option
        var selectedOptionValue = cmp.find("operatorDate").get("v.value");
        console.log({
            selectedOptionValue
        });
        cmp.set("v.selectedDateOperator", selectedOptionValue);
        cmp.set("v.fromPicklist", true);
    },

    handleDateInputChange: function (component, event, helper) {
        // Get the string of the "value" attribute on the selected option
        //helper.dateInputChange(component, event, helper);
        var dateOperator = component.get("v.selectedDateOperator");
        console.log({
            dateOperator
        });
        var date = event.getParam("value");
        console.log({
            date
        });
        if (dateOperator == 'both') {

        } else if (dateOperator == 'to') {

        } else {

        }
    },

    handleRelativeFilterOption: function (component, event, helper) {
        var selectedButtonLabel = event.getSource().get("v.label");
        console.log("Button label: " + selectedButtonLabel);
        component.set("v.selectedRelativeFilterOption", selectedButtonLabel);
    },

    handleApplyRelativeFilter: function (component, event, helper) {
        var from = component.get("v.selectedRelativeFilterFromValue"); //from 1 year ago
        var to = component.get("v.selectedRelativeFilterToValue"); //to 1 year ahead
        var selectedType = component.get("v.selectedRelativeType"); // calendar or fiscal year
        console.log({
            from
        });
        console.log({
            to
        });

        from = from > 0 ? from : -(from);
        var lastNo = '';
        var nextNo = '';
        var selectedButtonLabel = component.get("v.selectedRelativeFilterOption");
        if (selectedType == 'Calendar') {
            if (selectedButtonLabel == 'Year') {
                lastNo = 'LAST_N_YEARS:' + from;
                nextNo = 'NEXT_N_YEARS:' + to;
            } else if (selectedButtonLabel == 'Quarter') {
                lastNo = 'LAST_N_QUARTERS:' + from;
                nextNo = 'NEXT_N_QUARTERS:' + to;
            } else if (selectedButtonLabel == 'Month') {
                lastNo = 'LAST_N_MONTHS:' + from;
                nextNo = 'NEXT_N_MONTHS:' + to;
            } else if (selectedButtonLabel == 'Week') {
                lastNo = 'LAST_N_WEEKS:' + from;
                nextNo = 'NEXT_N_WEEKS:' + to;
            } else if (selectedButtonLabel == 'Day') {
                lastNo = 'LAST_N_DAYS:' + from;
                nextNo = 'NEXT_N_DAYS:' + to;
            }
        } else if (selectedType == 'Fiscal Year') {
            if (selectedButtonLabel == 'Year') {
                lastNo = 'LAST_N_FISCAL_YEARS:' + from;
                nextNo = 'NEXT_N_FISCAL_YEARS:' + to;
            } else if (selectedButtonLabel == 'Quarter') {
                lastNo = 'LAST_N_FISCAL_QUARTERS:' + from;
                nextNo = 'NEXT_N_FISCAL_QUARTERS:' + to;
            } else if (selectedButtonLabel == 'Month') {
                lastNo = 'LAST_N_MONTHS:' + from;
                nextNo = 'NEXT_N_MONTHS:' + to;
            } else if (selectedButtonLabel == 'Week') {
                lastNo = 'LAST_N_WEEKS:' + from;
                nextNo = 'NEXT_N_WEEKS:' + to;
            }
        }
        var values = [];
        values.push(lastNo);
        values.push(nextNo);
        console.log({
            values
        });
        
        helper.dispatchSelectChangeEvent(component, values);
    },

    handleRelativeTypeFilterOption: function (component, event, helper) {
        var calendarYear = component.find('calendarYear');
        var fiscalYear = component.find('fiscalYear');
        var selectedButtonLabel = event.getSource().get("v.value");
        component.set("v.selectedRelativeType", selectedButtonLabel);
        if (selectedButtonLabel == 'Fiscal Year') {
            var options = [{
                    label: 'Year',
                    value: 'Year'
                },
                {
                    label: 'Quarter',
                    value: 'Quarter'
                },
                {
                    label: 'Month',
                    value: 'Month'
                },
                {
                    label: 'Week',
                    value: 'Week'
                }
            ];
            component.set("v.relativeButtonOptions", options);

            $A.util.addClass(fiscalYear, 'slds-button_brand');
            $A.util.addClass(fiscalYear, 'colorWhite');
            $A.util.removeClass(calendarYear, 'slds-button_brand');
            $A.util.removeClass(calendarYear, 'colorWhite');
        } else {
            var options = [{
                    label: 'Year',
                    value: 'Year'
                },
                {
                    label: 'Quarter',
                    value: 'Quarter'
                },
                {
                    label: 'Month',
                    value: 'Month'
                },
                {
                    label: 'Week',
                    value: 'Week'
                },
                {
                    label: 'Day',
                    value: 'Day'
                }
            ];
            component.set("v.relativeButtonOptions", options);
            $A.util.addClass(calendarYear, 'slds-button_brand');
            $A.util.addClass(calendarYear, 'colorWhite');
            $A.util.removeClass(fiscalYear, 'slds-button_brand');
            $A.util.removeClass(fiscalYear, 'colorWhite');
        }

    },

    handleFromEditMode: function (component) {
        component.set("v.isFromEditMode", !component.get("v.isFromEditMode"));
    },
    handleToEditMode: function (component) {
        component.set("v.isToEditMode", !component.get("v.isToEditMode"));
    },

    handleApplyFilter: function (component, event, helper) {
        // Get the string of the "value" attribute on the selected option
        helper.applyFilter(component, event, helper);
    },

    handleCustomDate: function (component, event, helper) {
        var item = event.currentTarget;

        if (item && item.dataset) {
            var value = item.dataset.value;
            console.log({
                value
            });
            var selected = item.dataset.selected;
            console.log({
                selected
            });

            var options = component.get("v.options_");

            //shift key ADDS to the list (unless clicking on a previously selected item)
            //also, shift key does not close the dropdown (uses mouse out to do that)
            //if (event.shiftKey) {
            console.log('-INSIDE SHIFT CLICK-');

            options.forEach(function (element) {
                if (element.value == value) {
                    element.selected = selected == "true" ? false : true;
                }
            });

            component.set("v.options_", options);
            var values = helper.getSelectedValues(component);
            component.set("v.selectedItems", values);
            var labels = helper.getSelectedLabels(component);

            helper.setInfoText(component, labels);
            

            component.set("v.customSelected", true);

            //c.toggleCustomDateSelection(component, event, helper);
            helper.toggleCustomDateSelection(component, event, helper);
            //helper.loadOperatorOptions(component, event);
            /*var a = component.get('c.toggleCustomDateSelection');
            $A.enqueueAction(a);*/
            //helper.dispatchSelectChangeEvent(component, values);
        }
    },



    /*hanldeFocusOut: function (component, event, helper) {
        console.log('#Mouse Leave--#');
        component.set("v.dropdownOver", false);
        var mainDiv = component.find('main-div');
        $A.util.removeClass(mainDiv, 'slds-is-open');
    },*/

    hanldeFocusOut: function (component, event, helper) {
        console.log('#Mouse Leave--#');
        if(component.get("v.fromPicklist") == false){
            component.set("v.dropdownOver", false);
            var mainDiv = component.find('main-div');
            $A.util.removeClass(mainDiv, 'slds-is-open');
        }else{
            component.set("v.fromPicklist", false);
        }
    },

    handleMouseEnter: function (component, event, helper) {
        console.log('Mouse Enter');
        //document.getElementById('focusId').focus();
        component.set("v.dropdownOver", true);
    },

    handleMouseOutButton: function (component, event, helper) {
        console.log('MOuse Enter Out');
        //document.getElementById('focusId').focus();
        window.setTimeout(
            $A.getCallback(function () {
                //   console.log('timeout:');
                if (component.isValid()) {
                    //   console.log('In If:');
                    //if dropdown over, user has hovered over the dropdown, so don't close.
                    if (component.get("v.dropdownOver")) {
                        //   console.log('In If2:');
                        return;
                    }
                    var mainDiv = component.find('main-div');
                    $A.util.removeClass(mainDiv, 'slds-is-open');
                }
            }), 200
        );
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
    }

})