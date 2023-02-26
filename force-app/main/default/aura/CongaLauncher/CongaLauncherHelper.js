({
    handleRecordUpdatedHelper : function(component,event,helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            component.find("service").callApex(component, helper, "c.getSessionIdAndServerUrl", { }, this.getSessionIdSuccess);
        }
    },
    getSessionIdSuccess : function(component,returnValue,helper){
        var sessionId = returnValue.sessionId;
        var serverUrl = returnValue.serverUrl;
        var opportunityRecordType = component.get('v.Quote').Opportunity_RecordType__c;
        var quoteId = component.get('v.Quote').Id;
        var opportunityName = encodeURIComponent(component.get('v.Quote').Opportunity_Name__c);
        var contactId = component.get('v.Quote').Contact_ID__c;
        if(opportunityRecordType == 'Event'){
            window.open('https://composer.congamerge.com?SolMgr=1&sessionId='+sessionId+'&serverUrl='+serverUrl+'&Id='+quoteId+'&ReportId=00O41000008Yl8W&QueryId=a1R41000005hQwm,a1R41000005hQwr,a1R41000005hQww,a1R2M000008GwaS,a1R2M0000085Ubo,[ProductItems]a1R41000006icXk?pv0='+quoteId+'&TemplateId=a1Z2M000004wLAY&TemplateGroup=Events&EmailSubject=Quotation&OFN='+opportunityName+'&DefaultPDF=1&LiveEditVisible=0&DocuSignVisible=1&DocuSignR1Id='+contactId+'&DocuSignR1IdDocuSignR1Type=Signer&DocuSignR1Role=Signer+1','',"width=600,height=600");
            $A.get("e.force:closeQuickAction").fire();
        }else if(opportunityRecordType == 'Corporate Training' || opportunityRecordType == 'Training PO'){
            window.open('https://composer.congamerge.com?SolMgr=1&sessionId='+sessionId+'&serverUrl='+serverUrl+'&Id='+quoteId+'&QueryId=a1R2M000008Ggna,a1R41000005hQwr,a1R41000005hQww,[ProductItems]a1R2M000008Gcb9UAC,[HeaderQuery]a1R2M000008H3CP?pv0='+quoteId+'&TemplateGroup=Training&EmailSubject=Quotation&OFN='+opportunityName+'&DefaultPDF=1&LiveEditVisible=0&DocuSignVisible=1&sc0=1','',"width=600,height=600");
            $A.get("e.force:closeQuickAction").fire();
        }else{
            helper.showToast('Error!','error','The Record Type of Opportunity must be either Event or Training');
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }
})