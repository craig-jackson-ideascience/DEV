({
    doInit_helper : function(component, event, helper, sortField) {
        var foundationId = component.get("v.recordId");
        //console.log('foundationId Id helper::: ' + foundationId);
        
        var selectedType = component.find("selectType");
        var oppType = selectedType.get("v.value");
        console.log('oppType find:::=> ' + oppType);
        
        helper.opportunityDetails_helper(component, event, helper, sortField);
    },
    
    opportunityDetails_helper : function(component, event, helper, sortField) {
        
        var foundationId = component.get("v.recordId");
        //console.log('foundationId:::@SK=>' + foundationId);
        
        var action = component.get("c.getOpportunityDetails");
        action.setParams({
            "foundationId": foundationId,
            "sortField": sortField,
            "isAsc": component.get("v.isAsc")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ifNoRecordsFound" , false);
                var oRes = response.getReturnValue();
                //console.log("oRes::");
                //console.log(oRes);
                
                if(oRes != null && oRes.length > 0 && oRes != undefined) {
                    
                    component.set("v.opportunityList", oRes);
                    var oppDetails = component.get("v.opportunityList");
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
                    
        			helper.foundationName_helper(component, event, helper);
                    
                }else{
                    // if there is no records then display message
                    //helper.foundationId_helper(component, event, helper);
                    component.set("v.ifNoRecordsFound" , true);
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
    
    foundationName_helper : function(component, event, helper) {
        var foundationId = component.get("v.recordId");
        //console.log('foundationId Id helper::: ' + foundationId);
        
        var action = component.get("c.getFoundationName");
        action.setParams({
            "foundationId": foundationId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var oRes = response.getReturnValue();
                //console.log("foundationName::");
                //console.log(oRes);
                
                if(oRes != null && oRes.length > 0 && oRes != undefined) {
                    
                    component.set("v.foundationName", oRes);
                    var foundationName = component.get("v.foundationName");
                    
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
    
    // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    
    // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]); 
                }
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    
    sortHelper: function(component, event, helper, sortFieldName) {
        var currentDir = component.get("v.arrowDirection");
        //alert(sortFieldName);
        if (currentDir == 'arrowdown') {
            // set the arrowDirection attribute for conditionally rendred arrow sign  
            component.set("v.arrowDirection", 'arrowup');
            // set the isAsc flag to true for sort in Assending order.  
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        
        var selectedType = component.find("selectType");
        var oppType = selectedType.get("v.value");
        
        helper.onChange_helper(component, event, helper, sortFieldName, oppType);
    },
    
    onChange_helper : function(component, event, helper, sortField, oppType) {
        var foundationId = component.get("v.recordId");
        //console.log('foundationId:::=> ' + foundationId);
        
        var action = component.get("c.getOpportunityDetailsWithOppTypeFilter");
        action.setParams({            
            "foundationId": foundationId,       
            "sortField": sortField,
            "isAsc": component.get("v.isAsc"),
            "oppType": oppType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log("state:New:::=>"+state);
            //$A.get('e.force:refreshView').fire();
            if (state === "SUCCESS") {
                component.set("v.ifNoRecordsFound",false);
                var oRes = response.getReturnValue();  
                //console.log("oppDetails::::=> ");
                //console.log(JSON.stringify(oRes));
                if(oRes != null && oRes.length > 0) {
                    component.set("v.opportunityList", oRes);
                    var oppDetails = component.get("v.opportunityList");
                    //console.log("oppDetails::::=> ");
                    //console.log(oppDetails);
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
    
    viewAll_helper: function(component, event, helper) {
        var foundationId = component.get("v.recordId");
        var foundationName = component.get("v.foundationName");
        var navService = component.find("navService");        
        var pageReference = {
            type: "standard__component",
            attributes: {
                componentName: "c__waveAnalyticsOpportunityView_cmp"
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