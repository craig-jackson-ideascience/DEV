({
    handleRecordUpdatedHelper: function(component, event, helper) {
        component.find("service").callApex(component,helper, "c.findDuplicates", 
                                           {"lead":component.get('v.lead') }, 
                                           this.findDuplicatesSuccess);
    },
    findDuplicatesSuccess : function(component,returnValue,helper){
        if(Object.keys(returnValue).length !== 0){
            if(!$A.util.isUndefinedOrNull(returnValue.alternateEmail)){
                component.set('v.alternateEmail',JSON.parse(returnValue.alternateEmail)); 
            }
            if(!$A.util.isUndefinedOrNull(returnValue.duplicateLeads)){
                component.set('v.duplicateLeads',JSON.parse(returnValue.duplicateLeads)); 
            }
        }
    },
    handleConvertHelper : function(component,event,helper){
        component.find("service").callApex(component,helper, "c.convertLeadRecord", 
                                           {"accountId": component.get('v.alternateEmail.Contact_Name__r.AccountId'),
                                            "contactId":component.get('v.alternateEmail.Contact_Name__c'),
                                            "leadId":component.get('v.lead.Id'),
                                            "ownerId": component.get('v.lead.OwnerId')}, 
                                           this.convertLeadRecordSuccess);
    },
    handleMergeHelper : function(component,event,helper){
        var lead = JSON.parse(JSON.stringify(component.get('v.lead')));
        delete lead.SystemModstamp;
        component.find("service").callApex(component,helper, "c.mergeLeadRecords", 
                                           {"masterLead":lead,
                                            "duplicateLeadString":JSON.stringify(component.get('v.duplicateLeads'))}, 
                                           this.convertLeadRecordSuccess);
    },
    convertLeadRecordSuccess : function(component,returnValue,helper){
        if(!$A.util.isUndefinedOrNull(returnValue)){
            var navigateToContact = $A.get("e.force:navigateToSObject");
            navigateToContact.setParams({
                "recordId": returnValue,
                "slideDevName": "detail"
            });
            navigateToContact.fire();
        }
    }
})