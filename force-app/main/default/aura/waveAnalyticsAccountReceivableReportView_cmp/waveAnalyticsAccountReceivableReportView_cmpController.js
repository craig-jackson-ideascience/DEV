({
	onPageReferenceChange: function(component, event, helper) {
       var myPageRef = component.get("v.pageReference");
        //console.log('myPageRef:::'+myPageRef);
        var foundationId = myPageRef.state.c__foundationId;
        var foundtionName = myPageRef.state.c__foundtionName;
        component.set("v.foundationId",foundationId);
        component.set("v.foundtionName",foundtionName);
        console.log('===foundationId:nn:::@SK=>'+component.get("v.foundationId"));
        console.log('===FoundationName::nn::@SK=>'+component.get("v.foundtionName"));
        
        helper.arReportViewData_helper(component, event, helper);
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
    
    sortByAccountName: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'Price');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, 'Price');
    },
    
     sortByDays: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'Days__c');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, helper, 'Days__c');
    },
})