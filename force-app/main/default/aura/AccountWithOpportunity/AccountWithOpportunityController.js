({
    doInit: function(component, event, helper) {
        helper.doInit(component,event, 'Name');
    },
    editAccount: function(component, event, helper) {
        helper.editAccount(component,event, helper);
    },
    openRecord: function(component, event, helper) {
        helper.openRecord(component,event, helper);
    },
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },
    handleKeyUp: function(component, event, helper) {
        helper.searchCommunity(component, event, helper);
    },
    sortName: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Name');
        helper.sortHelper(component, event, 'Name');
    },
    sortRelatedTo: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Related_To__c');
        helper.sortHelper(component, event, 'Related_To__c');
    },
    sortRecordType: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Opportunity.RecordType.Name'); 
        helper.sortHelper(component, event, 'Opportunity.RecordType.Name');
    },
    
    sortType: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Opportunity.Type');
        helper.sortHelper(component, event, 'Opportunity.Type');
    },
    sortAmount: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Opportunity.Amount');
        helper.sortHelper(component, event, 'Opportunity.Amount');
    },
    
    sortStageName: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Opportunity.StageName');
        helper.sortHelper(component, event, 'Opportunity.StageName');
    },
    
    ProductName: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Product_Name__c');
        helper.sortHelper(component, event, 'Product_Name__c');
    },
    TotalPrice: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'TotalPrice');
        helper.sortHelper(component, event, 'TotalPrice');
    },
    
    InstallDate: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Opportunity.Parent_Asset__r.InstallDate');
        helper.sortHelper(component, event, 'Opportunity.Parent_Asset__r.InstallDate');
    },
    
    EndDate: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'End_Date__c');
        helper.sortHelper(component, event, 'End_Date__c');
    },
    
    
})