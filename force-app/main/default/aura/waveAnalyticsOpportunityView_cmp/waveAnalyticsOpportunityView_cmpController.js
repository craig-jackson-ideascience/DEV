({
	onPageReferenceChange: function(component, event, helper) {
       var myPageRef = component.get("v.pageReference");
        //console.log('myPageRef:::'+myPageRef);
        var fId = myPageRef.state.c__foundationId;
        component.set("v.foundationId",fId);
        var fName = myPageRef.state.c__foundationName;
        component.set("v.foundationName",fName);
        //console.log('===FoundationId::::@SK=>'+component.get("v.foundtionId"));
        //console.log('===FoundationName::::@SK=>'+component.get("v.foundtionName"));
        
        helper.onPageReferenceChange_helper(component, event, helper, 'Name');
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
})