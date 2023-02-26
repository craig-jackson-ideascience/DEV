({
  doInit: function(component, event) {
        console.log('onLoad call');
        //call apex class method
        var action = component.get('c.fetchopportunity');
        action.setParams({
            "accountId": component.get("v.recordId"),
        });
      var pageSize = component.get("v.pageSize");
        action.setCallback(this, function(response) {
            //store state of response
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                //set response value in ListOfContact attribute on component.
                component.set('v.NotesAndAttach', response.getReturnValue());
                var records = component.get('v.NotesAndAttach');
                if (records.length > 0) {
                    component.set("v.totalRecords", records.length);
                    component.set("v.maxPage", Math.ceil((records.length) / pageSize));
                    var pageNumber = component.get("v.pageNumber");
                    var pageRecords = records.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
                    component.set("v.AttachmentList", pageRecords);
                }
            }
           });
        $A.enqueueAction(action);
    },
    openRecord:function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": 'https://linuxfoundation.my.salesforce.com/'+event.target.id });
        urlEvent.fire();
    },
    openopp:function (component, event, helper) {
        console.log('window.location.origin--->'+window.location.origin);
        var sfdcBaseURL = window.location.origin;
        //sfdcBaseURL =sfdcBaseURL 
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            
            "url": 'https://linuxfoundation.lightning.force.com/lightning/r/Opportunity/'+event.target.id+'/view'
        });
        urlEvent.fire();
    },
   renderPage: function(component) {
        console.log('Hiii');
        var pageSize = component.get("v.pageSize");
        var records = component.get("v.NotesAndAttach"),
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
        console.log('pageRecords----->>>>>>'+pageRecords);
        component.set("v.AttachmentList", pageRecords);
        component.set("v.pageSize",pageSize);
        
    },
    
   /* sortBy: function(component, field) {
        var records = component.get('v.AttachmentList');
        console.log('records-->'+JSON.stringify(records));
        var result = records.map(function(o){
            o.Checked = false;
            return o;
        });
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = result;
        //console.log('result--->'+JSON.stringify(result));
        console.log('sortAsc--->'+sortAsc);
        console.log('sortField--->'+sortField);
        console.log('field--->'+field);
        sortAsc = field == sortField? !sortAsc: true;
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.AttachmentList",records);
        //this.afterSort(component,  records);
    },*/
    sortBy: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.AttachmentList"),
            fieldPath = field.split(/\./),
            fieldValue = this.fieldValue;
        sortAsc = sortField != field || !sortAsc;
        records.sort(function(a,b){
            var aValue = fieldValue(a, fieldPath),
                bValue = fieldValue(b, fieldPath),
                t1 = aValue == bValue,
                t2 = (!aValue && bValue) || (aValue < bValue);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.AttachmentList", records);
        //this.renderPage(component);     
    },
   fieldValue: function(object, fieldPath) {
        var result = object;
        fieldPath.forEach(function(field) {
            if(result) {
                result = result[field];
            }
        });
        return result;
    },
})