({
    onPageReferenceChange_helper : function(component, event, helper, sortField) {
        console.log('onPageReferenceChange_helper:::');
        var foundationId = component.get("v.foundationId");
        //console.log('foundationId:::@SK=>' + foundationId);
        //
        var action = component.get("c.getOpportunityDetails");
        action.setParams({
            "foundationId": foundationId,
            "sortField": sortField,
            "isAsc": component.get("v.isAsc")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state::::=>"+state);
            //$A.get('e.force:refreshView').fire();
            if (state === "SUCCESS") {
                component.set("v.ifNoRecordsFound" , false);
                //console.log("response.getReturnValue=====:::@SK::=> " + response.getReturnValue());
                //console.log("response.getReturnValue=====:::@SK::=> " + JSON.stringify(response.getReturnValue()));
                
                var oRes = response.getReturnValue();
                
                if(oRes != null && oRes.length > 0 && oRes != undefined) {
                    component.set("v.opportunityList", oRes);
                    var oppDetails = component.get("v.opportunityList");
                    console.log("oppDetails=====:::@SK::=>");
                    console.log(oppDetails);
                    
                }
            }
            else if (state === "INCOMPLETE") {
                component.set("v.ifNoRecordsFound" , true);
                console.log("INCOMPLETE");
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
    
    //getPicklist Values of Opportunity Type
	getOppTypePicklist: function(component, event) {
        var action = component.get("c.getOpportunityType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                component.set("v.oppTypeMap", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    //helper for get the filterData of Opportunity by OppType
    handleTypeOnChange_helper:function(component, event, helper, sortField) {
        var oppType = component.get("v.selectedOppType");
       // alert(oppType);
        //var oppType = event.getSource().get("v.value");
        console.log('ooooppptype::: '+oppType);
        console.log('sortField::: '+sortField);
        var foundationId = component.get("v.foundationId");
        console.log('foundationId::::: '+foundationId);
        var action = component.get("c.OpportunityListWrapperWithOppTypeFilter");
        action.setParams({            
            "foundationId": foundationId,       
            "sortField": sortField,
            "isAsc": component.get("v.isAsc"),
            "oppType": oppType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state:New:::=>"+state);
            //$A.get('e.force:refreshView').fire();
            if (state === "SUCCESS") {
                component.set("v.ifNoRecordsFound",false);
                var oRes = response.getReturnValue();  
                console.log("oppDetails::"+JSON.stringify(oRes));
                if(oRes != null && oRes.length > 0) {
                    component.set("v.opportunityList", oRes);
                    var oppDetails = component.get("v.opportunityList");
                    //console.log("oppDetails::"+oppDetails);
                    var pageSize = component.get("v.pageSize");
                    //console.log("pageSize::"+pageSize);
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length;
                    //console.log("totalLength::"+totalLength);
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.currentPage",1);
                    //console.log("currentPage::"+component.get("v.currentPage"));
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.opportunityList").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));  
                    //console.log("totalPagesCount::"+component.get("v.totalPagesCount"));
                }else{
                    component.set("v.ifNoRecordsFound",true);
                    var compList=[];
                    component.set("v.opportunityList", compList);
                    //console.log("pageSize::"+pageSize);
                    var totalLength = 0;
                    //console.log("totalLength::"+totalLength);
                    component.set("v.totalRecordsCount", 0);
                    component.set("v.startPage",0);
                    component.set("v.currentPage",0);
                    //console.log("currentPage::"+component.get("v.currentPage"));
                    component.set("v.endPage",0);
                    var PaginationLst = [];
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", 0);  
                    component.set("v.membershipDetails", null);
                }
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
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
    
    sortHelper: function(component, event, helper, sortFieldName) {
        var currentDir = component.get("v.arrowDirection");
        
        if (currentDir == 'arrowdown') {
            // set the arrowDirection attribute for conditionally rendred arrow sign  
            component.set("v.arrowDirection", 'arrowup');
            // set the isAsc flag to true for sort in Assending order.  
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        
        var oppType = component.get("v.selectedOppType");
        if(oppType != null){
            helper.handleTypeOnChange_helper(component, event, helper, sortFieldName);
        } else {
            helper.onPageReferenceChange_helper(component, event, helper, sortFieldName);
        }
        // call the onLoad function for call server side method with pass sortFieldName 
        //this.onPageReferenceChange_helper(component, event, helper, sortFieldName);
    },
})