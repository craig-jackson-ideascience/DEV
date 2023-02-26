({
    hadleSelection_helper : function(component, event, helper) {
        var params = event.getParams();
        var payload = params.payload;
        console.log("payload:::::@SK==>"+payload);
        console.log(JSON.stringify(payload));
        if (payload) {
            var step = payload.step;
            var data = payload.data;
            //console.log("data:::::@SK==>"+data);
            //console.log(JSON.stringify(data));
            data.forEach(function(obj) {
                for (var k in obj) {
                    if (k === 'Days_String__c') {
                        component.set("v.daysFromPurchaseDate", obj[k]);                        
                    } else if(k === 'count') {
                        component.set("v.countOfRecords", obj[k]);
                    }
                }
            });
        }
        
        //var daysFromPurchaseDate = component.get("v.daysFromPurchaseDate");
        //console.log("daysFromPurchaseDate:::::@SK==>"+daysFromPurchaseDate);
        //var countOfRecords = component.get("v.countOfRecords");
        //console.log("countOfRecords:::::@SK==>"+countOfRecords);
        helper.accountReceivableDetails(component, event, helper);
    },
    
    accountReceivableDetails: function(component, event, helper) {
        var daysFromPurchaseDate = component.get("v.daysFromPurchaseDate");
        var foundationRecord = component.get("v.foundationRecord");
        var foundationId = foundationRecord.Id;
        var countOfRecords = component.get("v.countOfRecords");
        
        console.log("daysFromPurchaseDate:::::@SK==>"+daysFromPurchaseDate);
        console.log("foundationId:::::@SK==>"+foundationId);
        console.log("countOfRecords:::::@SK==>"+countOfRecords);
        
        if(daysFromPurchaseDate == 1) {
            component.set("v.Days", '30');
        } else if(daysFromPurchaseDate == 2) {
            component.set("v.Days", '60');
        } else if(daysFromPurchaseDate == 3) {
            component.set("v.Days", '90');
        } else if(daysFromPurchaseDate == 4)  {
            component.set("v.Days", '120+');
        }
        var action = component.get("c.getAccountReceivableDetails");
        action.setParams({
            "foundationId": foundationId,
            "daysFromPurchaseDate": daysFromPurchaseDate
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state:New:::=>"+state);
            //$A.get('e.force:refreshView').fire();
            if (state === "SUCCESS") {
                //console.log("response.getReturnValue=====:::@SK::=> " + response.getReturnValue());
                //console.log("response.getReturnValue=====:::@SK::=> " + JSON.stringify(response.getReturnValue()));
                
                var oRes = response.getReturnValue();
                
                if(oRes != null && oRes.length > 0 && oRes != undefined) {
                    component.set("v.ARDetails", oRes);
                    component.set("v.ifNoRecordsFound",false); 
                    var ARDetails = component.get("v.ARDetails");
                    console.log("ARDetails=====:::@SK::=>");
                    console.log(ARDetails);
                    
                }
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
                component.set("v.ifNoRecordsFound",true);
            } 
                else if (state === "ERROR") {
                    //  $A.get('e.force:refreshView').fire();
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    viewReport_helper: function(component, event, helper) {
        
        var navService = component.find("navService");
        var foundationRecord = component.get("v.foundationRecord");
        var foundationId = foundationRecord.Id;
        var foundationName = foundationRecord.Name;
        var pageReference = {
            type: "standard__component",
            attributes: {
                componentName: "c__waveAnalyticsAccountReceivableReportView_cmp"
            },
            state: { 
                "c__foundationId" : foundationId,
                "c__foundationName" : foundationName
            }
        };
        component.set("v.pageReference", pageReference);
        
        const handleUrl = (url) => {
            window.open(url);
        };
        const handleError = (error) => {
            console.log(error);
        };
            navService.generateUrl(pageReference).then(handleUrl, handleError);
    },
})