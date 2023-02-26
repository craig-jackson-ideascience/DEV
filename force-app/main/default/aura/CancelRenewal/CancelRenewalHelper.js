({
    
    showContent : function(component,returnValue,helper){
        var asset = component.get('v.asset');
        if (!$A.util.isUndefinedOrNull(asset.Projects__c )) {
            if (asset.Auto_Renew__c) {
                if (!asset.Renewal_Opportunity_Created__c) {
                    component.set("v.content","Cancel this membership?");
                    component.set("v.isCancel",true);
                } else {
                    component.set("v.content","Membership renewal opportunity has been created");
                }
            } else {
                component.set("v.content","Renewal has already been cancelled for this Asset");
            }
        }
    },
    handleOkHelper : function(component,event,helper){
        if(component.get('v.isCancel')){
            $A.util.addClass(component.find('content'),'slds-hide');
            $A.util.removeClass( component.find('cancellationReason'),'slds-hide');
            if(!$A.util.isUndefinedOrNull(component.find('cancellationReason').get('v.value')) && component.find('cancellationReason').get('v.value') != ""){
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                var asset = component.get('v.asset');
                asset.Auto_Renew__c = false;
                asset.Cancellation_Date__c = today;
                asset.Cancellation_Reason__c = component.find('cancellationReason').get('v.value');
                component.find("cancelRewal").saveRecord($A.getCallback(function(saveResult) {
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                    }
                    else if (saveResult.state === "ERROR") {
                        console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                    } else {
                        console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                    }
                }));
            }
        }else{
            $A.get("e.force:closeQuickAction").fire();
        }
    }
 
})