({

    showContent : function(component,returnValue,helper){
        var asset = component.get('v.asset');
        if (!$A.util.isUndefinedOrNull(asset.Projects__c )) {
            if (asset.Auto_Renew__c == 1 || asset.Is_Person_Account__c) {
                if (!asset.Renewal_Opportunity_Created__c) {
                    component.set('v.content',"Please confirm membership renewal");
                    component.set('v.isRenewable',true);
                }else{
                    component.set('v.content',"This membership has already been renewed");
                }
            }else{
                component.set('v.content',"This membership has been cancelled- unable to renew");
                
            }
        }else{
            component.set('v.content',"Only membership assets can be renewed");
        }
    },
    handleOkHelper : function(component,event,helper){
        if(component.get('v.isRenewable')){
            component.find("service").callApex(component,helper, "c.executeBatchForAutoRenewal", 
                                               {"asstId": component.get('v.recordId')}, 
                                               this.handleOkHelperSuccess);
        }else{
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    handleOkHelperSuccess : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        
    }
})