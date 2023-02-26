({
	 doInit: function(component, event, helper) {
       helper.doInit(component,event);
    },
    openRecord: function(component, event, helper) {
        helper.openRecord(component,event, helper);
    },
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },
    openopp: function(component, event, helper) {
        helper.openopp(component,event, helper);
    },
    sortByName: function(component, event, helper) {
        helper.sortBy(component, "Title");
    },
    sortByAmount: function(component, event, helper) {
        helper.sortBy(component, "Parent");
    },
    sortBycompany: function(component, event, helper) {
        console.log('sortBycompany');
        helper.sortBy(component, "LastModified");
    },
    sortByEmail: function(component, event, helper) {
        helper.sortBy(component, "CreatedBy");
    },
    onChangeVal:function (component, event, helper) {
        var val = event.getSource().get("v.value");
        console.log('val'+val);
        
        var action = component.get("c.fetchopportunity");
        action.setParams({"accountId": component.get("v.recordId"),"RecordTypeName":val});
        var pageSize = component.get("v.pageSize");
        action.setCallback(this, function(response) {
            //store state of response
            
            var state = response.getState();
            console.log('state-->'+state); 
            if (state === "SUCCESS") {
                //
                component.set("v.pageNumber",1);
                component.set('v.NotesAndAttach', response.getReturnValue());
                var records = component.get('v.NotesAndAttach');
                if (records.length > 0) {
                    component.set("v.totalRecords", records.length);
                    component.set("v.maxPage", Math.ceil((records.length) / pageSize));
                    var pageNumber = component.get("v.pageNumber");
                    var pageRecords = records.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
                    component.set("v.AttachmentList", pageRecords);
                }else{
                    component.set("v.AttachmentList", null);
                    component.set("v.totalRecords",0);
                }
            }
                
           });
        $A.enqueueAction(action);
    },
     doInit1: function(component, event, helper) {
        
        var action = component.get("c.getRecordTypeList");
        action.setCallback(this, function(result){
            var Opportunity = result.getReturnValue();
            component.set("v.Opportunity", Opportunity);
        });
        $A.enqueueAction(action);
    } ,
})