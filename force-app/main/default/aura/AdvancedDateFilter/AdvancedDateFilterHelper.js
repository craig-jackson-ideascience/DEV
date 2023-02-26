/**
 * Created by cloudroutesolutions on 10/02/21.
 */
({
    init: function (component) {

        //note, we get options and set options_
        //options_ is the private version and we use this from now on.
        //this is to allow us to sort the options array before rendering
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
        var selectedDateValues = this.getJsonFromUrl().c__selectedDateValues;
        component.set("v.selectedDateValues", selectedDateValues);
        component.set("v.placeHolderText", selectedDateValues);
        if (selectedDateValues && selectedDateValues != '') {
            options.forEach(function (element) {
                console.log(element);
                if(selectedDateValues == element.value){
                    element.selected = true;
                }else{
                    element.selected = false;
                }
            });
        }
        component.set("v.options_", options);
        var labels = this.getSelectedLabels(component);
        this.setInfoText(component, labels);

        this.loadOperatorOptions(component);
    },



    setInfoText: function (component, values) {
        var txt = component.get('v.defaultText');
        if (values.length == 0) {
            component.set("v.infoText", txt);
        }
        if (values.length == 1) {
            component.set("v.infoText", values[0]);
        }
        else if (values.length > 1) {
            component.set("v.infoText", values[0] + ' to ' + values[1]);
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
        return values;
    },

    getSelectedLabels: function (component) {
        var options = component.get("v.options_");
        var labels = [];
        var isDefault = true;
        options.forEach(function (element) {
            console.log(element);
            if (element.selected) {
                isDefault = false;
                labels.push(element.label);
            }
        });
        if(isDefault){
            labels.push(component.get("v.defaultText"));
        }
        return labels;
    },

    dispatchSelectChangeEvent: function (component, values) {
        var passCompareOperator = component.get("v.selectedSoqlOperator");
        var componentType = component.get("v.componentType");
        console.log({passCompareOperator});
        var compEvent = component.getEvent("AdvancedDateChangedEvent");
        compEvent.setParams({ "dateValues": values });
        compEvent.setParams({ "compareOperator": passCompareOperator });
        compEvent.setParams({"type": componentType});
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

    toggleCustomDateSelection: function (component, event, helper) {
            var customDateDiv = component.find('custom-date-filter');
           console.log({customDateDiv});
           var standardDateDiv = component.find('standard-date-filter');
           console.log({standardDateDiv});
            $A.util.toggleClass(standardDateDiv, 'slds-hide');
            $A.util.toggleClass(customDateDiv, 'slds-hide');

            var today = new Date();
            component.set("v.minFromDate", (today.getFullYear()-5) + "-" + ("0" + (today.getMonth())).slice(-2) + "-" + today.getDate());
            component.set("v.maxFromDate", (today.getFullYear() + "-" + ("0" + (today.getMonth())).slice(-2) + "-" + today.getDate()));
            component.set("v.selectedFromDate", (today.getFullYear()-5) + "-" + ("0" + (today.getMonth())).slice(-2) + "-" + ("0" + (today.getDate())).slice(-2));

            console.log('minFrom=='+(today.getFullYear()-5) + "-" + ("0" + (today.getMonth())).slice(-2) + "-" + today.getDate());
            console.log('maxFrom=='+(today.getFullYear() + "-" + ("0" + (today.getMonth())).slice(-2) + "-" + today.getDate()));
            console.log('selectedFromDate=='+(today.getFullYear()-5) + "-" + ("0" + (today.getMonth())).slice(-2) + "-" + today.getDate());

            component.set("v.minToDate", ((today.getFullYear()-5) + "-" + ("0" + (today.getMonth())).slice(-2) + "-" + 2));
            component.set("v.maxToDate", (today.getFullYear() + "-" + ("0" + (today.getMonth())).slice(-2) + "-" + today.getDate()));
            component.set("v.selectedToDate", (today.getFullYear() + "-" + ("0" + (today.getMonth())).slice(-2) + "-" + ("0" + (today.getDate())).slice(-2)));

            console.log('maxTo=='+(today.getFullYear() + "-" + ("0" + (today.getMonth())).slice(-2) + "-" + today.getDate()));
            console.log('minTo=='+((today.getFullYear()-5) + "-" + ("0" + (today.getMonth())).slice(-2) + "-" + 2));
            console.log('selectedToDate=='+(today.getFullYear() + "-" + ("0" + (today.getMonth())).slice(-2) + "-" + today.getDate()));

    
            
       
        },

    loadOperatorOptions:function (cmp) {
        var options = [
                        {label: 'Between', value: 'both'},
                        {label: 'Less Than Or Equal To', value: 'to'},
                        {label: 'Greater Than Or Equal To', value: 'from'}
                ];
        cmp.set("v.absoluteSelectedDateOperator", options);
    },

    /*dateInputChange:function (cmp, event, helper) {
       var dateOperator = cmp.get("v.absoluteSelectedDateOperator");
       console.log({dateOperator});
       var date = cmp.get("v.date");
       if(dateOperator == 'both'){

       }else if(dateOperator == 'to'){

       }else {

       }
    },*/

    applyFilter:function (cmp, event, helper) {
       var activeTab = cmp.get("v.selectedTabDate");
       var dateValues = [];
       if(activeTab == 'absolute'){
            var dateOperator = cmp.get("v.selectedDateOperator");
            console.log({dateOperator});
            if(dateOperator == 'both'){
                var fromDate = cmp.get("v.selectedFromDate");
                var toDate = cmp.get("v.selectedToDate");
                dateValues.push(toDate); //<=
                dateValues.push(fromDate); //>=
                cmp.set("v.selectedSoqlOperator", 'between'); // for between, 0th of dateValues should be lessThan(<=) and 1st should be (>=) [createdDate <= AND >=]
            }else if(dateOperator == 'to'){
                var toDate = cmp.get("v.selectedToDate");
                dateValues.push(toDate);
                cmp.set("v.selectedSoqlOperator", 'lessThanEqual');
            }else {
                var fromDate = cmp.get("v.selectedFromDate");
                dateValues.push(fromDate);
                cmp.set("v.selectedSoqlOperator", 'greaterThanEqual');
            }
       }
       console.log({dateValues});
       helper.setInfoText(cmp, dateValues);
       this.dispatchSelectChangeEvent(cmp, dateValues);
    },

    getJsonFromUrl: function () {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function (part) {
            console.log({ part });
            var item = part.split("=");
            console.log({ item });
            console.log(decodeURIComponent(item[1]));
            result[item[0]] = decodeURIComponent(item[1]);
            console.log(result[item[0]]);
        });
        return result;
    }
})