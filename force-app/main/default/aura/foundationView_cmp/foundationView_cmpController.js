({
    doInit : function(component, event, helper) {
        //console.log(':::::doInit In:::::');
        helper.loggedInUserRole_Helper(component, event, helper);        
    },
    onSelection : function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        console.log('selectedRec--->'+selectedRec);
        var recordId = component.get("v.SelectID");
		console.log('recordId----'+recordId);	
        var getSelectedNumber = component.get("v.selectedCount");
        console.log('getSelectedNumber--->'+getSelectedNumber);
        if (selectedRec == true) {
            getSelectedNumber++; 
            var selectedProject = event.getSource().get("v.text");
            component.set("v.foundationId",selectedProject.Id);
            //alert(selectedProject.Id);
            //For Purchase History
            var developerName = '0FK2M000000XdEWWA0';
           /* var evt = $A.get('e.wave:update');
            var dataString = '{"datasets": {"PurchaseHistoryDS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedProject.Id+'"] } } ] } }';
            evt.setParams({
                value: dataString,
                id: developerName,
                type: "dashboard"
            });
            evt.fire();*/
            
            var evt_ds = $A.get('e.wave:update');
            var dataString_ds = '{"datasets": {"PurchaseHistory_DS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedProject.Id+'"] } } ], "PurchaseHistoryDS": [{"fields": ["Projects__c.Id"], "filter": {"operator": "matches", "values":["'+selectedProject.Id+'"] } } ] } } ';
            evt_ds.setParams({
                value: dataString_ds,
                id: developerName,
                type: "dashboard"
            });
            evt_ds.fire();
            
            //For Products By Foundation
            var developerName1 = '0FK2M000000XdEgWAK';
            var dataString1 = '{"datasets": {"PurchaseHistoryDS": [{"fields": ["Projects__c.Id"],"filter": {"operator": "matches", "values":["'+selectedProject.Id+'"] } } ]} }';
            var evt1 = $A.get('e.wave:update');
            evt1.setParams({
                value: dataString1,
                id: developerName1,
                type: "dashboard"
            });
            evt1.fire();            
            //For AccountReceivable
            var developerName2 = '0FK2M000000bof4WAA';
            var dataString2 = '{"datasets":{"PurchaseHistoryDS":[{"fields":["Projects__c.Id"], "filter":{"operator": "matches", "values":["'+selectedProject.Id+'"]}}]}}';
            var evt2 = $A.get('e.wave:update');
            evt2.setParams({
                value: dataString2,
                id: developerName2,
                type: "dashboard"
            });
            evt2.fire();
            
            var developerNameAR = '0FK2M000000bofJWAQ';
            var dataStringAR = '{"datasets":{"PurchaseHistoryDS":[{"fields":["Projects__c.Id"], "filter":{"operator": "matches", "values":["'+selectedProject.Id+'"]}}]}}';
            var evtAR = $A.get('e.wave:update');
            evtAR.setParams({
                value: dataStringAR,
                id: developerNameAR,
                type: "dashboard"
            });
            evtAR.fire();
            
            helper.sendFoundationToMembershipCMP(component, event, helper, selectedProject);
            
            var getcurrentCheckbox = component.find("selectedCheckbox");
            for (var i = 0; i < getcurrentCheckbox.length; i++) {                
                if (selectedProject.Id != getcurrentCheckbox[i].get("v.text").Id) {
                    getcurrentCheckbox[i].set("v.value",false);
                } 
            }
            var getSelectedCheckbox = component.get("v.foundationRecordListForAll");
            // alert(getSelectedCheckbox.length);
            //console.log('objProject'+getSelectedCheckbox.objProject.Id);
            for (var i = 0; i < getSelectedCheckbox.length; i++) {  
                if(getSelectedCheckbox[i].objProject!=null){
                    
                    if (selectedProject.Id != getSelectedCheckbox[i].objProject.Id) {
                        getSelectedCheckbox[i].isChecked=false;//set("v.value",false);
                    }else{
                        getSelectedCheckbox[i].isChecked=true;//set("v.value",false);
                        var recordId = getSelectedCheckbox[i].objProject;
                        component.set("v.SelectedProject",recordId);
                        console.log('recordId'+recordId);
                    }
                }
            } 
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
    },
    
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.foundationRecordListForAll");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
    
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var foundationRecordListForAll = component.get("v.foundationRecordListForAll");
        var PaginationList = component.get("v.PaginationList");
        console.log('PaginationList----'+PaginationList);
        // play a for loop on all records list 
        for (var i = 0; i < foundationRecordListForAll.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                foundationRecordListForAll[i].isChecked = true;
                component.set("v.selectedCount", foundationRecordListForAll.length);
            } else {
                foundationRecordListForAll[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(foundationRecordListForAll[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.foundationRecordListForAll", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },
    
    sortByName: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'Current_Year_Revenue__c');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, 'Current_Year_Revenue__c');
    },
})