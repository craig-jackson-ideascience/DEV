({
    doInit : function(component, event, helper) {
        helper.setupTable(component);
    },
    
    sortTable : function(component, event, helper) {
        component.set("v.isLoading", true);
        setTimeout(function(){
            var childObj = event.target;
            var parObj = childObj.parentNode;
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
            }
            var sortBy = parObj.name, //event.getSource().get("v.name"),
                sortDirection = component.get("v.sortDirection"),
                sortDirection = sortDirection === "asc" ? "desc" : "asc"; //change the direction for next time

            component.set("v.sortBy", sortBy);
            component.set("v.sortDirection", sortDirection);
            helper.sortData(component, sortBy, sortDirection);
            component.set("v.isLoading", false);
        }, 0);
    },

    calculateWidth : function(component, event, helper) {
        var childObj = event.target;
        var parObj = childObj.parentNode;
        var startOffset = parObj.offsetWidth - event.pageX;
        component.set("v.startOffset", startOffset);
    },
    
    setNewWidth : function(component, event, helper) {
        var childObj = event.target;
        var parObj = childObj.parentNode;
        while(parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
        }
        var startOffset = component.get("v.startOffset");
        var newWidth = startOffset + event.pageX;
        parObj.style.width = newWidth+'px';
    },
    
    editField : function(component, event, helper) {
        //set the child component value.
        component.set("v.changed",true);
        var vx = component.get("v.method");
        //fire event from child and capture in parent
        $A.enqueueAction(vx);
        var field = event.getSource(),
            indexes = field.get("v.name"),
            rowIndex = indexes.split('-')[0],
            colIndex = indexes.split('-')[1];
                
        var data = component.get("v.tableData");
        data[rowIndex].fields[colIndex].mode = 'edit';
        data[rowIndex].fields[colIndex].tdClassName = 'slds-cell-edit slds-is-edited';
        component.set("v.tableData", data);        
        component.set("v.isEditModeOn", true);
    },
    
    onInputChange : function(component, event, helper){
        var field = event.getSource(),
            value = field.get("v.type") == 'checkbox' ? field.get("v.checked") : field.get("v.value"), //Added by Priyesh @Cloudroute to get the checkbox value
            indexes = field.get("v.name"),
            rowIndex = indexes.split('-')[0],
            colIndex = indexes.split('-')[1];
            console.log('value--->'+value);
        helper.updateTable(component, rowIndex, colIndex, value);
        
    },

    onRowAction : function(component, event, helper){
        var actionEvent = component.getEvent("dataTableRowActionEvent"),
            indexes = event.target.id, //rowIndex-colIndex-actionName
            params = indexes.split('-'),
            data = component.get("v.dataCache");

        actionEvent.setParams({
            actionName: params[2],
            rowData: data[params[0]]
        });
        actionEvent.fire();
    },
    
    closeEditMode : function(component, event, helper){
        component.set("v.buttonsDisabled", true);
        component.set("v.buttonClicked", "Cancel");
        component.set("v.isLoading", true);
        setTimeout(function(){
            var dataCache = component.get("v.dataCache");
            var originalData = component.get("v.tableDataOriginal");
            component.set("v.data", JSON.parse(JSON.stringify(dataCache)));
            component.set("v.tableData", JSON.parse(JSON.stringify(originalData)));
            component.set("v.isEditModeOn", false);
            console.log('2222');
            component.set("v.isLoading", false);
            component.set("v.error", "");
            component.set("v.buttonsDisabled", false);
            component.set("v.buttonClicked", "");
        }, 0);
    },
    
    saveRecords : function(component, event, helper){
        component.set("v.buttonsDisabled", true);
        component.set("v.buttonClicked", "Save");
        component.set("v.isLoading", true);
        var data =JSON.stringify(component.get("v.modifiedRecords"));
        console.log('data-->'+data);
        console.log('data-->'+data.length);
        setTimeout(function(){
            var saveEvent = component.getEvent("dataTableSaveEvent");
            console.log('saveEvent-->'+saveEvent);
            console.log('saveEventStatus-->'+saveEvent.status__c);
            saveEvent.setParams({
                tableAuraId: component.get("v.auraId"),
                recordsString: JSON.stringify(component.get("v.modifiedRecords")),
                //recordsString: data,
            });
            saveEvent.fire();
            
        }, 0);
        
        //Added
        component.set("v.buttonsDisabled", true);
        component.set("v.buttonClicked", "Cancel");
        component.set("v.isLoading", true);
        setTimeout(function(){
            var dataCache = component.get("v.dataCache");
            var originalData = component.get("v.tableDataOriginal");
            component.set("v.data", JSON.parse(JSON.stringify(dataCache)));
            component.set("v.tableData", JSON.parse(JSON.stringify(originalData)));
            component.set("v.isEditModeOn", false);
            //component.set("v.isLoading", false);
            component.set("v.error", "");
            component.set("v.buttonsDisabled", false);
            component.set("v.buttonClicked", "");
        }, 0);
         
    },
    
    //Added new 
    UpdateInsertRecord : function(component, event, helper){
        console.log('inside DataTable Update Insert');
        component.set("v.buttonsDisabled", true);
        component.set("v.buttonClicked", "Save");
        component.set("v.isLoading", true);
        component.set("v.isLoading1", true);
        var data =JSON.stringify(component.get("v.modifiedRecords"));
        console.log('data-->'+data.length);
        setTimeout(function(){
            var saveEvent = component.getEvent("dataTableSaveEvent");
            console.log('saveEvent-->'+saveEvent);
            console.log('saveEventStatus-->'+saveEvent.status__c);
            saveEvent.setParams({
                tableAuraId: component.get("v.auraId"),
                recordsString: JSON.stringify(component.get("v.modifiedRecords")),
                //recordsString: data,
            });
            saveEvent.fire();
            
        }, 0);
        
        //Added
        component.set("v.buttonsDisabled", true);
        component.set("v.buttonClicked", "Cancel");
        //component.set("v.isLoading", true);
        setTimeout(function(){
            var dataCache = component.get("v.dataCache");
            var originalData = component.get("v.tableDataOriginal");
            component.set("v.data", JSON.parse(JSON.stringify(dataCache)));
            component.set("v.tableData", JSON.parse(JSON.stringify(originalData)));
            component.set("v.isEditModeOn", false);
            //component.set("v.isLoading", false);
            component.set("v.error", "");
            component.set("v.buttonsDisabled", false);
            component.set("v.buttonClicked", "");
        }, 0);
         
    },
    //End
    
    finishSaving : function(component, event, helper){
        var params = event.getParam('arguments');
        var isLoading =component.get("v.isLoading1");
        if(params){
            var result = params.result, //Valid values are "SUCCESS" or "ERROR"
                data = params.data, //refreshed data from server
                message = params.message;
                
            if(result === "SUCCESS"){//success
                if(data){
                    console.log('Inside Data');
                    helper.setupData(component, data);
                }else{
                    console.log('Inside Else');
                    var dataCache = component.get("v.dataCache"),
                        updatedData = component.get("v.updatedTableData");
                    
                    
                    component.set("v.data", JSON.parse(JSON.stringify(dataCache)));
                    component.set("v.tableDataOriginal", JSON.parse(JSON.stringify(updatedData)));
                    component.set("v.tableData", JSON.parse(JSON.stringify(updatedData))); 
                }
                component.set("v.isEditModeOn", false);
            }else{
                if(message) component.set("v.error", message);
            }
        }
        component.set("v.isLoading", true);
        component.set("v.buttonsDisabled", false);
        component.set("v.buttonClicked", "");
    },
    copyLink : function(component, event, helper){
        var vx = component.get("v.method");
        //fire event from child and capture in parent
        $A.enqueueAction(vx);
        var sampledata = component.get("v.data");
        //alert(JSON.stringify(sampledata));
        console.log('sampledata-->'+JSON.stringify(sampledata));
        var id =event.target.id;
        for (var i = 0; i < sampledata.length; i++) {
            if(id == i){
                console.log('Inside');
                component.set("v.ContactName",sampledata[i].Contact_Name__c);
                component.set("v.ContactId",sampledata[i].Contact__c);
                              }
        }
        console.log('Contact Name-->'+component.get("v.ContactName"));
        console.log('Id-->'+id);
        component.set("v.CopyLink",true);
        window.setTimeout(
                $A.getCallback(function() {
                     component.set("v.CopyLink",false);
                }), 100
            );
    }
})