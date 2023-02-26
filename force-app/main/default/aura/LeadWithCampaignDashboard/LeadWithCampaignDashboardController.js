({
    filteronOnLeadWithCampaign: function(component, event, helper) {        
        var selectedFoundation = event.getParam('selectedProject');
        component.set('v.foundationRecord',selectedFoundation); 
        //console.log('>>>>>:: '+selectedFoundation+' Id>>>>> ' +selectedFoundation.Id );
        
        if(selectedFoundation!=null){
            component.set('v.isWADisplay',true);  
        }        
        component.set("v.dashboardData",'');
        var filtData='{"datasets": {"Leads_With_CampaignMember": [{"fields": ["CampaignId.Project__c.Id"], "filter": {"operator": "matches", "values":["'+selectedFoundation.Id+'"] } } ] } }';
        component.set("v.dashboardData",filtData);     
        
    },
    
    viewAll: function(component , event, helper) {
        helper.viewAll_helper(component, event, helper);
    },
})