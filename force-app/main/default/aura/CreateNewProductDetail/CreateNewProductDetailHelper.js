({
    fetchListOfRecordTypes: function(component, event, helper) {
      var action = component.get("c.fetchRecordTypeValues");
      action.setCallback(this, function(response) {
         component.set("v.lstOfRecordType", response.getReturnValue());
      });
      $A.enqueueAction(action);
   },

    createRecordProject : function(component,event,helper) {
        component.find("service").callApex(component, helper, "c.getRecTypeIdProject", {
            "recordTypeLabel": component.find("selectid").get("v.value"),
            "recordId": component.get('v.recordId')
        },this.getRecordTypeIdSuccess);
    },

    createRecordOther : function(component,event,helper) {
        component.find("service").callApex(component, helper, "c.getRecordTypeId", {
            "objectName": component.get('v.sObjectName'),
        },this.getRecordTypeIdSuccess);
    },

    /**
     * Method to fire createRecord Event for creation of product detail record
     */ 
    getRecordTypeIdSuccess: function(component,returnValue,helper){
        var recordTypeId = returnValue;
        //if it is launched from project record
        if(component.get('v.showRecordTypeModal')){
            //get recordtypeid
            recordTypeId = returnValue['RecordTypeId'];
        }
        var objectName = component.get('v.sObjectName');
        
        //createrecord event
        var createProductDetailsEvent = $A.get("e.force:createRecord");
        createProductDetailsEvent.setParams({
            "entityApiName": "Product_Details__c",
            "defaultFieldValues":  helper.getDefaultValueJSON(component,objectName,returnValue),
            "recordTypeId" : recordTypeId,
            "navigationLocation":"RELATED_LIST"
        });
        createProductDetailsEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
    },

    /**
     * Method to get DefaultFieldValues that to be populated on createRecord Form
     */ 
    getDefaultValueJSON : function(component,objectName,returnValue){
        var recordId = component.get('v.recordId');
        //If Object is project
        if(objectName==="Project__c"){
            var selectedRecordType = component.find("selectid").get("v.value");
            var defaultFieldValues = {
                'Project__c' : recordId,
            }
            //For Membership recordtype prepopulate LF_Membership_Required__c on product detail
            if(selectedRecordType == 'Membership'){
                defaultFieldValues['LF_Membership_Required__c'] = returnValue['ProjectRecord'].LF_Membership_Required__c;
            }
            return defaultFieldValues;
        }else if(objectName==="Event__c"){
            return {'Event__c' : recordId};
        }else{
            return {'Training__c' : recordId};
        }
    }
})