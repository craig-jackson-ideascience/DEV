({
    foundationId : function(component, event, helper) {
        helper.getOppTypePicklist(component, event);
        var FoundationRecord=event.getParam("selectedProject");
        helper.doInit_helper(component, event, helper, 'Name',FoundationRecord);
    },
    
    onSelection : function(component, event, helper) {
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
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
    
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.opportunityList");
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
    
    sortByName: function(component, event, helper) {
        /*var selectedType = component.find("typePicklist");
        var oppType;
        console.log('1. '+oppType);
        if(selectedType==null||event.getSource()!=null||oppType!="undefined"){
          oppType = event.getSource().get("v.value"); 
        }else{
          oppType = selectedType.get("v.value");
        }
		console.log('2. '+oppType);      
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'Name');*/
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, 'Name');
    },
    
    sortByAccountName: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'Account.Name');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, 'Account.Name');
    },
    
    sortByAmount: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'Amount');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, 'Amount');
    },
    
    sortByType: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'Type');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, 'Type');
    },
    
    sortByStage: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'StageName');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, 'StageName');
    },
    
    sortByProbability: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'Probability');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, 'Probability');
    },
    
    sortByCloseDate: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'CloseDate');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, 'CloseDate');
    },
    
    sortByAge: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        //component.set("v.selectedTabsoft", 'Age');
        // call the helper function with pass sortField Name   
        //helper.sortHelper(component, event, helper, 'Age');
    },
    
    sortByCreatedDate: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'CreatedDate');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, 'CreatedDate');
    },
    
    viewAll: function(component , event, helper) {
        helper.viewAll_helper(component, event, helper);
    },
    
    handleTypeOnChange: function(component, event, helper){
        var selectedType = component.find("typePicklist");
        
        var oppType;
        //alert(oppType);
        if(selectedType==null||event.getSource()!=null){
            oppType=event.getSource().get("v.value"); 
        }else{
            oppType = selectedType.get("v.value");
        }
        component.set("v.selectedOppType",oppType);
        //alert('oppType::: '+oppType);
        //alert('selectedOppType:::: '+component.get("v.selectedOppType"));
        helper.handleTypeOnChange_helper(component, event, helper, 'Name');
    },
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    
    createOpp : function(component, event, helper){
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Opportunity"
            
            // Optionally Specify Record Type Id
        });
        createRecordEvent.fire();
    },
})