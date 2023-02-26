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
        helper.getOppTypePicklist(component, event);
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
    }
})