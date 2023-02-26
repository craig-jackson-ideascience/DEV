({
    doInit : function(component, event, helper) {
        var foundationId = component.get("v.recordId");
        //console.log('foundationId Id doInt::: ' + foundationId);
        
        helper.doInit_helper(component, event, helper, 'Name');
    },
    
    onChange: function(component, event, helper) {
        
        var selectedType = component.find("selectType");
        var oppType = selectedType.get("v.value");
        
        helper.onChange_helper(component, event, helper, 'Name', oppType);
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
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'Name');
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
})