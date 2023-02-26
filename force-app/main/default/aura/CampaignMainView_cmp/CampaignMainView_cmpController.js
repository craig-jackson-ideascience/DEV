({
    onPageReferenceChange : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        //console.log('myPageRef:::'+myPageRef);
        var fId = myPageRef.state.c__foundationId;
        component.set("v.foundationId",fId);
        var fName = myPageRef.state.c__foundationName;
        component.set("v.foundationName",fName);
        //console.log('myPageRef :: ' + myPageRef + '\n foundationId :: ' + fId + '\n foundationName :: ' + fName);
        helper.onPageReferenceChange_helper(component, event, helper, fId, 'Name');
    },
    
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.campaignList");
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
    
    viewAll: function(component , event, helper) {
        helper.viewAll_helper(component, event, helper);
    },
    
    onSelection : function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        //console.log('28> selectedRec:: ' + selectedRec);
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++; 
            var selectedCampaign = event.getSource().get("v.text");
            var selectedCampaignId = selectedCampaign.Id;
            //console.log('33> selectedCampaign:: ' + selectedCampaign);
            
            //helper.sendSelectedCampaign(component, event, helper, selectedCampaignId);
            
            var getcurrentCheckbox = component.find("selectedCheckbox");
            //console.log('38> getcurrentCheckbox:: ' + getcurrentCheckbox);
            for (var i = 0; i < getcurrentCheckbox.length; i++) {                
                if (selectedCampaign.Id != getcurrentCheckbox[i].get("v.text").Id) {
                    getcurrentCheckbox[i].set("v.value",false);
                } 
            }
            var getSelectedCheckbox = component.get("v.campaignList");
            //console.log('45> getSelectedCheckbox:: ' + getSelectedCheckbox);
            // alert(getSelectedCheckbox.length);
            for (var i = 0; i < getSelectedCheckbox.length; i++) {  
                if(getSelectedCheckbox[i].objCampaign!=null){
                    if (selectedCampaign.Id != getSelectedCheckbox[i].objCampaign.Id) {
                        getSelectedCheckbox[i].isChecked=false;//set("v.value",false);
                    }else{
                        getSelectedCheckbox[i].isChecked=true;//set("v.value",false);
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
    
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var foundationRecordListForAll = component.get("v.foundationRecordListForAll");
        var PaginationList = component.get("v.PaginationList");
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
        component.set("v.selectedTabsoft", 'Name');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, 'Name');
    },
    
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    
    submitDetails: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        component.set("v.isModalOpen", false);
    },
})